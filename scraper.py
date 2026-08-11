import psycopg2
import anthropic
import requests
from bs4 import BeautifulSoup
import os
import time
import io
import pdfplumber

db_url = os.environ.get("DATABASE_URL", "NOT SET")
print(f"DATABASE_URL starts with: {db_url[:30]}")
apify_key = os.environ.get("APIFY_API_KEY", "NOT SET")
print(f"APIFY_API_KEY starts with: {apify_key[:10]}")

def get_db_connection():
    return psycopg2.connect(os.environ["DATABASE_URL"])

def extract_pdf_text(pdf_url):
    try:
        response = requests.get(pdf_url, timeout=15)
        pdf_file = io.BytesIO(response.content)
        text = ""
        with pdfplumber.open(pdf_file) as pdf:
            for page in pdf.pages[:5]:
                text += page.extract_text() or ""
        return text[:3000]
    except Exception as e:
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
            if href.endswith(".pdf") and any(w in href.lower() for w in ["newsletter", "calendar", "events"]):
                full_url = href if href.startswith("http") else url.rstrip("/") + "/" + href.lstrip("/")
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
            filtered = [p for p in results if page_name in str(p.get("url", ""))]
            return filtered
        elif status in ["FAILED", "ABORTED"]:
            print("  Apify run failed")
            return []
    return []

def tag_content(raw_text, org_name):
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    prompt = (
        "You are helping build Vermont Nonprofit Pulse. "
        "Read this content from " + org_name + " and extract specific named events, "
        "volunteer opportunities, fundraisers, or news items. "
        "RULES: Only include items with a specific name not just a date. "
        "Write meaningful 2-sentence descriptions using only details from the content provided. "
        "Never write that details are available elsewhere. "
        "Never group multiple events into one entry. "
        "If an item only has a date with no name skip it. "
        "For each qualifying item return:\n"
        "TITLE: [specific name]\n"
        "TYPE: [Event/Volunteer/Fundraiser/News/Donate]\n"
        "DATE: [specific date or Ongoing]\n"
        "DESCRIPTION: [2 sentences with real details]\n"
        "---\n"
        "Content: " + raw_text + "\n"
        "If nothing qualifies say NO ITEMS FOUND."
    )
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1500,
        messages=[{"role": "user", "content": prompt}]
    )
    return message.content[0].text

def tag_facebook_posts(posts, org_name):
    combined_text = "\n".join([
        f"Post: {p.get('text', '')[:500]}"
        for p in posts if p.get("text")
    ])
    if not combined_text:
        return "NO ITEMS FOUND"
    return tag_content(combined_text, org_name)

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

def save_to_database(records, org_name, town, county, mission_area, source_url):
    conn = get_db_connection()
    cursor = conn.cursor()
    saved = 0
    for record in records:
        try:
            cursor.execute(
                "INSERT INTO content (organization_name, content_type, title, description, town, county, mission_area, source_url, status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (org_name, record.get("content_type"), record.get("title"), record.get("description"), town, county, mission_area, source_url, "active")
            )
            saved += 1
        except Exception as e:
            print(f"  Skipped duplicate")
    conn.commit()
    cursor.close()
    conn.close()
    return saved

website_nonprofits = [
    {"name": "Old Spokes Home", "urls": ["https://www.oldspokeshome.com", "https://www.oldspokeshome.com/support-old-spokes-home"], "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian", "source_url": "https://www.oldspokeshome.com"},
    {"name": "Bellows Falls Community Bike Project", "urls": ["https://bfbike.org"], "town": "Bellows Falls", "county": "Windham", "mission": "Bikes & Pedestrian", "source_url": "https://bfbike.org"},
    {"name": "Freeride Montpelier", "urls": ["https://freeridemontpelier.org"], "town": "Montpelier", "county": "Washington", "mission": "Bikes & Pedestrian", "source_url": "https://freeridemontpelier.org"},
    {"name": "Green Mountain Foster Bikes", "urls": ["https://www.greenmountainfosterbikes.org"], "town": "Middlesex", "county": "Washington", "mission": "Bikes & Pedestrian", "source_url": "https://www.greenmountainfosterbikes.org"},
    {"name": "Bennington Bike Hub", "urls": ["https://ourbikehub.org"], "town": "Bennington", "county": "Bennington", "mission": "Bikes & Pedestrian", "source_url": "https://ourbikehub.org"},
    {"name": "Bettys Bikes", "urls": ["https://www.bettysbikes.org"], "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian", "source_url": "https://www.bettysbikes.org"},
    {"name": "Vermont Mountain Bike Association", "urls": ["https://vmba.org", "https://vmba.org/events/"], "town": "Waterbury", "county": "Washington", "mission": "Bikes & Pedestrian", "source_url": "https://vmba.org"},
    {"name": "Kelly Brush Foundation", "urls": ["https://kellybrushfoundation.org"], "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian", "source_url": "https://kellybrushfoundation.org"},
    {"name": "Pride Rides VT", "urls": ["https://prideridesvt.com/"], "town": "Barre", "county": "Washington", "mission": "Bikes & Pedestrian", "source_url": "https://prideridesvt.com/"},
]

facebook_nonprofits = [
    {"name": "Local Motion", "facebook_url": "https://www.facebook.com/localmotionvt/", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian", "source_url": "https://www.localmotion.org"},
]

total_saved = 0

print("=== WEBSITE SCRAPING ===")
for org in website_nonprofits:
    print(f"Processing {org['name']}...")
    try:
        raw_text = scrape_multiple_pages(org["https://www.oldspokeshome.com"])
        if not raw_text:
            print("  No content found")
            continue
        tagged = tag_content(raw_text, org["name"])
        if "NO ITEMS FOUND" in tagged:
            print("  No items found")
            continue
        records = parse_results(tagged)
        saved = save_to_database(records, org["name"], org["town"], org["county"], org["mission"], org["source_url"])
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
        if not posts:
            continue
        tagged = tag_facebook_posts(posts, org["name"])
        if "NO ITEMS FOUND" in tagged:
            print("  No items found")
            continue
        records = parse_results(tagged)
        saved = save_to_database(records, org["name"], org["town"], org["county"], org["mission"], org["source_url"])
        total_saved += saved
        print(f"  Saved {saved} new records")
    except Exception as e:
        print(f"  Error: {e}")

print(f"\n=== COMPLETE: {total_saved} total new records saved ===")
