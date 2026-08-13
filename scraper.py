import psycopg2
import anthropic
import requests
from bs4 import BeautifulSoup
import os
import time
import io
import hashlib
import pdfplumber

db_url = os.environ.get("DATABASE_URL", "NOT SET")
print(f"DATABASE_URL starts with: {db_url[:30]}")
apify_key = os.environ.get("APIFY_API_KEY", "NOT SET")
print(f"APIFY_API_KEY starts with: {apify_key[:10]}")

VERMONT_PLACES = {
    "addison", "albany", "alburgh", "andover", "arlington", "athens",
    "baltimore", "barnet", "barre", "barton", "belvidere", "bennington",
    "benson", "berlin", "bethel", "bloomfield", "bolton", "bradford",
    "braintree", "brandon", "brattleboro", "bridgewater", "bridport",
    "brighton", "bristol", "brookfield", "brookline", "brownington",
    "brunswick", "burke", "burlington", "cabot", "calais", "cambridge",
    "canaan", "castleton", "cavendish", "charleston", "charlotte", "chelsea",
    "chester", "chittenden", "clarendon", "colchester", "concord", "corinth",
    "cornwall", "coventry", "craftsbury", "danby", "danville", "derby",
    "dorset", "dover", "dummerston", "duxbury", "east haven",
    "east montpelier", "eden", "elmore", "enosburg", "essex", "fairfax",
    "fairfield", "fair haven", "fayston", "ferrisburgh", "fletcher",
    "franklin", "glover", "goshen", "grafton", "granby", "grand isle",
    "granville", "groton", "guildhall", "guilford", "halifax", "hancock",
    "hardwick", "hartford", "hartland", "highgate", "hinesburg", "holland",
    "huntington", "hyde park", "irasburg", "isle la motte", "jamaica",
    "jay", "jericho", "johnson", "lincoln", "londonderry", "lowell",
    "ludlow", "lunenburg", "lyndon", "lyndonville", "maidstone", "manchester",
    "marlboro", "marshfield", "mendon", "middlebury", "middlesex",
    "middletown springs", "milton", "monkton", "montgomery", "montpelier",
    "moretown", "morgan", "morristown", "morrisville", "mount holly",
    "newark", "newbury", "newfane", "newport", "north hero", "northfield",
    "norton", "norwich", "orange", "orwell", "panton", "pawlet", "peacham",
    "peru", "pittsfield", "pittsford", "plainfield", "plymouth", "pomfret",
    "poultney", "pownal", "proctor", "putney", "randolph", "reading",
    "readsboro", "richford", "richmond", "ripton", "rochester", "rockingham",
    "roxbury", "royalton", "rupert", "rutland", "ryegate",
    "saint albans", "st albans", "saint george", "st george",
    "saint johnsbury", "st johnsbury", "salisbury", "sandgate", "searsburg",
    "shaftsbury", "sharon", "sheffield", "shelburne", "sheldon", "shoreham",
    "shrewsbury", "south burlington", "south hero", "springfield",
    "stamford", "stannard", "starksboro", "stowe", "strafford", "stratton",
    "sudbury", "sunderland", "sutton", "swanton", "thetford", "tinmouth",
    "topsham", "townshend", "troy", "tunbridge", "underhill", "vergennes",
    "vernon", "vershire", "victory", "waltham", "wardsboro", "warren",
    "washington", "waterbury", "waterford", "waterville", "weathersfield",
    "wells", "west fairlee", "west haven", "west rutland", "west windsor",
    "westfield", "westford", "westminster", "westmore", "weston", "wheelock",
    "whiting", "whitingham", "williamstown", "williston", "wilmington",
    "windham", "windsor", "winhall", "winooski", "wolcott", "woodbury",
    "woodford", "woodstock", "worcester",
    "addison county", "bennington county", "caledonia county",
    "chittenden county", "essex county", "franklin county",
    "grand isle county", "lamoille county", "orange county",
    "orleans county", "rutland county", "washington county",
    "windham county", "windsor county",
    "vermont", "vt", "green mountain", "champlain valley",
    "northeast kingdom", "mad river valley"
}

NON_VERMONT_SIGNALS = [
    "new york city", "nyc", "park city", "utah", "boston", "massachusetts",
    "new hampshire", " nh ", "chicago", "denver", "seattle", "los angeles",
    "san francisco", "miami", "atlanta", "philadelphia", "washington dc",
    "portland, or", "portland, me", "new jersey", "pennsylvania",
    "california", "colorado", "florida", "texas", "ohio", "michigan"
]

BAD_PHRASES = [
    "further details can be found",
    "more information available",
    "visit their website for",
    "check their calendar",
    "details available elsewhere",
    "no further details",
]

BAD_TITLE_PATTERNS = [
    "events -",
    "events (",
    "has an event",
    "community calendar events",
]

VALID_TYPES = ["event", "volunteer", "fundraiser", "news", "donate"]


def make_hash(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def get_db_connection():
    return psycopg2.connect(os.environ["DATABASE_URL"])


def hash_exists(cursor, source_hash):
    cursor.execute(
        "SELECT id FROM content WHERE source_hash = %s LIMIT 1",
        (source_hash,)
    )
    return cursor.fetchone() is not None


def is_vermont_content(title, description, org_town):
    combined = (title + " " + description + " " + org_town).lower()
    for place in NON_VERMONT_SIGNALS:
        if place in combined:
            print(f"  BLOCKED: non-Vermont location in '{title}'")
            return False
    for place in VERMONT_PLACES:
        if place in combined:
            return True
    return True


def is_valid_record(record, org_town):
    title = record.get("title", "").strip()
    description = record.get("description", "").strip()
    content_type = record.get("content_type", "").strip().lower()
    if not title or not content_type:
        return False
    if content_type not in VALID_TYPES:
        return False
    for phrase in BAD_PHRASES:
        if phrase in description.lower():
            print(f"  BLOCKED: bad phrase in '{title}'")
            return False
    for pattern in BAD_TITLE_PATTERNS:
        if pattern in title.lower():
            print(f"  BLOCKED: generic title '{title}'")
            return False
    if len(title) < 5:
        return False
    if not is_vermont_content(title, description, org_town):
        return False
    return True


def extract_pdf_text(pdf_url):
    try:
        response = requests.get(pdf_url, timeout=15)
        pdf_file = io.BytesIO(response.content)
        text = ""
        with pdfplumber.open(pdf_file) as pdf:
            for page in pdf.pages[:5]:
                text += page.extract_text() or ""
        return text[:3000]
    except Exception:
        return ""


def scrape_website(url):
    try:
        headers = {"User-Agent": "VermontNonprofitPulse/1.0"}
        response = requests.get(url, timeout=10, headers=headers)
        soup = BeautifulSoup(response.text, "html.parser")
        for tag in soup(["script", "style", "nav", "footer"]):
            tag.decompose()
        text = soup.get_text(separator=" ", strip=True)
        pdf_text = ""
        for link in soup.find_all("a", href=True):
            href = link["href"]
            if href.endswith(".pdf") and any(
                w in href.lower() for w in ["newsletter", "calendar", "events"]
            ):
                full_url = (
                    href if href.startswith("http")
                    else url.rstrip("/") + "/" + href.lstrip("/")
                )
                print(f"  Found PDF: {full_url}")
                pdf_text += extract_pdf_text(full_url)
        combined = text[:2000]
        if pdf_text:
            combined += "\nPDF CONTENT: " + pdf_text[:2000]
        return combined
    except Exception as e:
        return f"Error: {e}"


def scrape_multiple_pages(urls):
    combined = []
    for url in urls:
        text = scrape_website(url)
        if not text.startswith("Error"):
            combined.append(text)
    return "\n".join(combined)[:5000]


def fetch_facebook_posts(facebook_url, limit=20):
    APIFY_API_KEY = os.environ["APIFY_API_KEY"]
    ACTOR_ID = "KoJrdxJCTtpon81KY"
    headers = {
        "Authorization": f"Bearer {APIFY_API_KEY}",
        "Content-Type": "application/json"
    }
    run_response = requests.post(
        f"https://api.apify.com/v2/acts/{ACTOR_ID}/runs",
        json={"startUrls": [{"url": facebook_url}], "resultsLimit": limit},
        headers=headers
    )
    run_id = run_response.json().get("data", {}).get("id")
    print(f"  Apify run started: {run_id}")
    for i in range(30):
        time.sleep(10)
        status_response = requests.get(
            f"https://api.apify.com/v2/actor-runs/{run_id}",
            headers=headers
        )
        status_data = status_response.json()
        status = status_data.get("data", {}).get("status")
        if status == "SUCCEEDED":
            dataset_id = status_data.get("data", {}).get("defaultDatasetId")
            results = requests.get(
                f"https://api.apify.com/v2/datasets/{dataset_id}/items",
                headers=headers
            ).json()
            page_name = facebook_url.rstrip("/").split("/")[-1]
            filtered = [
                p for p in results
                if page_name in str(p.get("url", ""))
            ]
            return filtered
        elif status in ["FAILED", "ABORTED"]:
            print("  Apify run failed")
            return []
    return []


def tag_content(raw_text, org_name, org_town):
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    prompt = (
        "You are helping build Vermont Nonprofit Pulse, a Vermont-only nonprofit aggregator. "
        "Read this content from " + org_name + " based in " + org_town + ", Vermont. "
        "Extract specific named events, volunteer opportunities, fundraisers, or news items. "
        "STRICT RULES: "
        "1. Only include items that take place in Vermont or directly benefit Vermont residents. "
        "2. Skip any events in other states. "
        "3. Only include items with a specific name not just a date. "
        "4. Write meaningful 2-sentence descriptions using only details from the content. "
        "5. Never write that details are available elsewhere. "
        "6. Never group multiple events into one entry. "
        "7. If an item only has a date with no name skip it. "
        "8. Extract specific dates when mentioned - never mark a dated event as Ongoing. "
        "For each qualifying item return: "
        "TITLE: [specific name] "
        "TYPE: [Event/Volunteer/Fundraiser/News/Donate] "
        "DATE: [specific date if mentioned, or Ongoing only for truly recurring programs] "
        "DESCRIPTION: [2 sentences with real details] "
        "--- "
        "Content: " + raw_text + " "
        "If nothing qualifies say NO ITEMS FOUND."
    )
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1500,
        messages=[{"role": "user", "content": prompt}]
    )
    return message.content[0].text


def parse_results(tagged_text):
    records = []
    items = tagged_text.strip().split("---")
    for item in items:
        if not item.strip() or "NO ITEMS FOUND" in item:
            continue
        record = {}
        for line in item.strip().split("\n"):
            if line.startswith("TITLE:"):
                record["title"] = line.replace("TITLE:", "").strip()
            elif line.startswith("TYPE:"):
                record["content_type"] = line.replace("TYPE:", "").strip()
            elif line.startswith("DESCRIPTION:"):
                record["description"] = line.replace("DESCRIPTION:", "").strip()
        if "title" in record and "content_type" in record:
            records.append(record)
    return records


def save_to_database(records, org_name, town, county, mission_area,
                     source_url, source_hash, cursor, conn):
    saved = 0
    blocked = 0
    for record in records:
        if not is_valid_record(record, town):
            blocked += 1
            continue
        try:
            cursor.execute(
                "INSERT INTO content (organization_name, content_type, title, "
                "description, town, county, mission_area, source_url, "
                "source_hash, status) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (org_name, record.get("content_type"), record.get("title"),
                 record.get("description"), town, county, mission_area,
                 source_url, source_hash, "active")
            )
            saved += 1
        except Exception as e:
            print(f"  Skipped: {e}")
    conn.commit()
    if blocked > 0:
        print(f"  Blocked {blocked} records by validation layer")
    return saved


website_nonprofits = [
    {
        "name": "Old Spokes Home",
        "urls": [
            "https://www.oldspokeshome.com",
            "https://www.oldspokeshome.com/support-old-spokes-home"
        ],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://www.oldspokeshome.com"
    },
    {
        "name": "Bellows Falls Community Bike Project",
        "urls": ["https://bfbike.org"],
        "town": "Bellows Falls", "county": "Windham",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://bfbike.org"
    },
    {
        "name": "Freeride Montpelier",
        "urls": ["https://freeridemontpelier.org"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://freeridemontpelier.org"
    },
    {
        "name": "Green Mountain Foster Bikes",
        "urls": ["https://www.greenmountainfosterbikes.org"],
        "town": "Middlesex", "county": "Washington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://www.greenmountainfosterbikes.org"
    },
    {
        "name": "Bennington Bike Hub",
        "urls": ["https://ourbikehub.org"],
        "town": "Bennington", "county": "Bennington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://ourbikehub.org"
    },
    {
        "name": "Bettys Bikes",
        "urls": ["https://www.bettysbikes.org"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://www.bettysbikes.org"
    },
    {
        "name": "Vermont Mountain Bike Association",
        "urls": ["https://vmba.org", "https://vmba.org/events/"],
        "town": "Waterbury", "county": "Washington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://vmba.org"
    },
    {
        "name": "Kelly Brush Foundation",
        "urls": ["https://kellybrushfoundation.org"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://kellybrushfoundation.org"
    },
    {
        "name": "Pride Rides VT",
        "urls": ["https://prideridesvt.com/"],
        "town": "Barre", "county": "Washington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://prideridesvt.com/"
    },
]

facebook_nonprofits = [
    {
        "name": "Local Motion",
        "facebook_url": "https://www.facebook.com/localmotionvt/",
        "town": "Burlington", "county": "Chittenden",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://www.localmotion.org"
    },
]

total_saved = 0
conn = get_db_connection()
cursor = conn.cursor()

print("=== WEBSITE SCRAPING ===")
for org in website_nonprofits:
    print(f"Processing {org['name']}...")
    try:
        raw_text = scrape_multiple_pages(org["urls"])
        if not raw_text:
            print("  No content found")
            continue

        source_hash = make_hash(org["name"] + raw_text)

        if hash_exists(cursor, source_hash):
            print("  No changes since last scrape - skipping Claude")
            continue

        tagged = tag_content(raw_text, org["name"], org["town"])
        if "NO ITEMS FOUND" in tagged:
            print("  No items found")
            continue

        records = parse_results(tagged)
        saved = save_to_database(
            records, org["name"], org["town"], org["county"],
            org["mission"], org["source_url"], source_hash, cursor, conn
        )
        total_saved += saved
        print(f"  Saved {saved} new records")
    except Exception as e:
        print(f"  Error: {e}")

print("\n=== FACEBOOK SCRAPING ===")
for org in facebook_nonprofits:
    print(f"Processing {org['name']} via Facebook...")
    try:
        posts = fetch_facebook_posts(org["facebook_url"], limit=20)
        print(f"  Found {len(posts)} posts")

        new_posts = []
        for post in posts:
            post_url = post.get("url", "")
            post_hash = make_hash(post_url)
            if not hash_exists(cursor, post_hash):
                new_posts.append((post, post_hash))

        print(f"  {len(new_posts)} new posts not yet in database")

        for post, post_hash in new_posts:
            post_text = post.get("text", "")
            if not post_text:
                continue
            tagged = tag_content(post_text, org["name"], org["town"])
            if "NO ITEMS FOUND" in tagged:
                continue
            records = parse_results(tagged)
            saved = save_to_database(
                records, org["name"], org["town"], org["county"],
                org["mission"], post.get("url", org["source_url"]),
                post_hash, cursor, conn
            )
            total_saved += saved
            if saved > 0:
                print(f"  Saved {saved} records from post")

    except Exception as e:
        print(f"  Error: {e}")

cursor.close()
conn.close()
print(f"\n=== COMPLETE: {total_saved} total new records saved ===")