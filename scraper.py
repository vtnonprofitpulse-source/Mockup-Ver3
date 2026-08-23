import psycopg2
import anthropic
import requests
from bs4 import BeautifulSoup
import os
import sys
import time
import io
import hashlib
import pdfplumber
import re
import json
import html
from dateutil import parser as dateutil_parser
from datetime import datetime
from urllib.parse import urljoin, urlparse

# Bump this whenever a meaningful logic/prompt change ships. Folded into
# every content hash below, so a version bump forces every page to be
# reprocessed on the next run automatically - no manual wipe needed.
# Root cause this fixes: source_hash previously only reflected page
# content, not code version, so bug fixes silently never reached pages
# whose source content hadn't changed (August 16, 2026).
SCRAPER_VERSION = "2"

NON_SPECIFIC_DATE_WORDS = {"ongoing", "tbd", "n/a", "none", "unknown", ""}


MONTH_NAMES_PATTERN = (
    r'(January|February|March|April|May|June|July|August|September|'
    r'October|November|December|Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)'
)


def extract_clean_date_phrase(text):
    """Find just the date itself within a longer sentence, so fuzzy parsing
    never has to guess which number is the date - fixes a real bug where
    ordinal numbers in an event's own name (e.g. '21st Annual...') were
    being misread as the day/year (Aug 16, 2026: Kelly Brush Ride parsed
    as 2012-09-21 instead of 2026-09-12).
    Returns (phrase, has_explicit_year) - the year-explicit flag matters
    because a year we have to infer needs a much tighter trust bound than
    a year the source actually stated (see parse_event_date)."""
    pattern = re.compile(
        MONTH_NAMES_PATTERN + r'\.?\s+(\d{1,2})(?:st|nd|rd|th)?(?:\s*[-\u2013]\s*\d{1,2})?,?\s*(\d{4})?',
        re.IGNORECASE
    )
    m = pattern.search(text)
    if m:
        month, day, year = m.group(1), m.group(2), m.group(3)
        phrase = f"{month} {day}, {year}" if year else f"{month} {day}"
        return phrase, bool(year)
    numeric_pattern = re.compile(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b')
    m2 = numeric_pattern.search(text)
    if m2:
        return m2.group(0), True
    return None, False


def parse_event_date(date_text):
    """
    Convert Claude's free-text DATE field into a real date, or None.
    Returns None (SQL NULL) for anything that isn't a specific date,
    rather than ever writing text like 'Ongoing' into a date column.
    Extracts a clean, isolated date phrase first rather than fuzzy-parsing
    a whole sentence. Caps any date more than ~6 months out uniformly,
    regardless of whether the year appeared to be explicit in the source -
    fixes a real bug (Aug 16, 2026) where stale Facebook posts got dated a
    full year into the future. Deliberately does NOT trust Claude's own
    apparent 'explicit year' more loosely, since we can't verify that claim
    is honest rather than a confident-looking wrong guess - a blunt,
    uniform cap is safer than a clever distinction that assumes good faith.
    """
    if not date_text:
        return None
    cleaned = date_text.strip().lower()
    if cleaned in NON_SPECIFIC_DATE_WORDS:
        return None
    clean_phrase, has_explicit_year = extract_clean_date_phrase(date_text)
    if not clean_phrase:
        return None
    try:
        parsed = dateutil_parser.parse(clean_phrase, fuzzy=False, default=datetime.now())
        delta_days = (parsed.date() - datetime.now().date()).days
        if delta_days > 180:
            return None
        if abs(delta_days) > 730:
            return None
        return parsed.date()
    except (ValueError, OverflowError):
        return None

db_url = os.environ.get("DATABASE_URL", "NOT SET")
print(f"DATABASE_URL starts with: {db_url[:30]}")
apify_key = os.environ.get("APIFY_API_KEY", "NOT SET")
print(f"APIFY_API_KEY starts with: {apify_key[:10]}")
print(f"anthropic library version: {anthropic.__version__}")
print(f"requests library version: {requests.__version__}")

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

VALID_TYPES = ["event", "volunteer", "fundraiser", "news", "donate",
               "employment", "class"]


def make_hash(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def record_scrape_status(cursor, conn, org_name, status, error_message=None):
    """Record what happened when we tried to scrape this org, so failures
    are visible instead of silently disappearing into a log nobody sees.
    Wrapped defensively so a missing column can never break the real scrape.
    Also defensive against the connection itself being dead (e.g. a dropped
    SSL connection) - a failed rollback attempt on a dead connection used to
    cascade into an uncaught exception that crashed the whole script instead
    of just skipping this one status log (confirmed real recurrence, August
    16, 2026)."""
    try:
        cursor.execute(
            "UPDATE organizations SET last_scrape_status = %s, "
            "last_scrape_error = %s, last_scrape_at = NOW() "
            "WHERE organization_name = %s",
            (status, error_message, org_name)
        )
        conn.commit()
    except Exception:
        try:
            conn.rollback()
        except Exception:
            pass


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


def is_valid_record(record, org_town, event_date=None):
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
    # A dated item that has already happened should never be saved (this
    # always means a wrong-date extraction or stale archived content) -
    # except News, which is allowed to legitimately reference the past.
    if content_type != "news" and event_date is not None:
        if event_date < datetime.now().date():
            print(f"  BLOCKED: past date {event_date} for '{title}'")
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
        return text[:4000]
    except Exception:
        return ""


RELEVANT_LINK_KEYWORDS = [
    "event", "class", "workshop", "program", "calendar", "ride", "volunteer"
]

EXCLUDED_LINK_PATTERNS = [
    "privacy", "terms", "staff", "board", "facebook.com", "twitter.com",
    "instagram.com", "linkedin.com", "youtube.com", "tiktok.com",
    "mailto:", "tel:"
]

MAX_DISCOVERED_LINKS = 5
LEVEL2_MAX_PAGES_TO_EXPAND = 2
LEVEL2_MAX_LINKS_PER_PAGE = 3
LEVEL2_TOTAL_CAP = 6
MAX_TOTAL_EXTRA_LINKS = 10


def discover_relevant_links(homepage_url, existing_urls, max_links=MAX_DISCOVERED_LINKS):
    """Find an organization's own events/classes/programs pages automatically
    by scanning its homepage for matching links, instead of relying on a
    person to manually find and hardcode each org's page structure.
    Same-domain only, one level deep, bounded to max_links - see Gate
    'Coverage still incomplete' mechanism refinement, August 15 2026."""
    discovered = []
    try:
        headers = {"User-Agent": "VermontNonprofitPulse/1.0"}
        response = requests.get(homepage_url, timeout=10, headers=headers)
        soup = BeautifulSoup(response.text, "html.parser")
        homepage_domain = urlparse(homepage_url).netloc.replace("www.", "")

        seen = set(existing_urls)
        for link in soup.find_all("a", href=True):
            if len(discovered) >= max_links:
                break
            href = link["href"]
            link_text = link.get_text(strip=True).lower()
            href_lower = href.lower()

            if any(pattern in href_lower for pattern in EXCLUDED_LINK_PATTERNS):
                continue

            full_url = urljoin(homepage_url, href)
            link_domain = urlparse(full_url).netloc.replace("www.", "")
            if link_domain != homepage_domain:
                continue

            if full_url in seen:
                continue

            if any(kw in href_lower or kw in link_text for kw in RELEVANT_LINK_KEYWORDS):
                discovered.append(full_url)
                seen.add(full_url)
    except Exception:
        pass
    return discovered


def discover_all_relevant_links(org_urls, max_total_extra=MAX_TOTAL_EXTRA_LINKS):
    """Two-level discovery: first find relevant pages linked from the org's
    homepage (e.g. an 'Events' listing page), then look one level deeper
    from those pages for individual item pages (e.g. VMBA's own
    /event/velo-stowe/ page) - where the cleanest, most unambiguous single-
    event data actually lives, per the 'Coverage still incomplete' finding.
    Bounded at every level: at most LEVEL2_MAX_PAGES_TO_EXPAND level-1 pages
    are expanded further, at most LEVEL2_TOTAL_CAP level-2 links are added,
    and the combined total never exceeds max_total_extra - cost stays
    predictable and identical in shape for every organization."""
    seen = set(org_urls)
    level1_links = discover_relevant_links(org_urls[0], seen, max_links=MAX_DISCOVERED_LINKS)
    seen.update(level1_links)

    # Expansion candidates for level 2: freshly-discovered pages AND the
    # org's own pre-configured URLs beyond the homepage (e.g. an
    # already-known events listing page like VMBA's /events/) - both are
    # good places to find individual item sub-links.
    expansion_candidates = (
        level1_links[:LEVEL2_MAX_PAGES_TO_EXPAND]
        + org_urls[1:1 + LEVEL2_MAX_PAGES_TO_EXPAND]
    )

    level2_links = []
    for url in expansion_candidates:
        if len(level2_links) >= LEVEL2_TOTAL_CAP:
            break
        links = discover_relevant_links(url, seen, max_links=LEVEL2_MAX_LINKS_PER_PAGE)
        for l in links:
            if l not in seen and len(level2_links) < LEVEL2_TOTAL_CAP:
                level2_links.append(l)
                seen.add(l)

    return (level1_links + level2_links)[:max_total_extra]


def unfold_ical_lines(text):
    """RFC 5545 line folding: continuation lines start with a space or tab
    and should be joined back to the previous line before parsing."""
    lines = text.replace("\r\n", "\n").split("\n")
    unfolded = []
    for line in lines:
        if line.startswith(" ") or line.startswith("\t"):
            if unfolded:
                unfolded[-1] += line[1:]
        else:
            unfolded.append(line)
    return unfolded


def unescape_ical_text(text):
    return (text.replace("\\n", " ").replace("\\N", " ")
                .replace("\\,", ",").replace("\\;", ";").replace("\\\\", "\\"))


def parse_ical_date(value):
    """Extract the date portion regardless of time/timezone/Z-suffix
    variants - deliberately simple rather than fuzzy-parsing a format with
    several real-world variations, since VNP only stores a date, not an
    exact time, so this sidesteps timezone-conversion edge cases entirely."""
    digits = re.sub(r'[^0-9]', '', value)
    if len(digits) < 8:
        return None
    try:
        return datetime(int(digits[0:4]), int(digits[4:6]), int(digits[6:8])).date()
    except ValueError:
        return None


def extract_ical_events(ics_text, source_url):
    """Extract event records directly from a real iCal/.ics calendar feed -
    the most authoritative structured source available when an org
    provides one (confirmed real example: VMBA's calendar export). Pure
    deterministic parsing, no AI judgment, no new dependency - tested
    against realistic real-format data including line-folded descriptions
    and both timed and all-day event variants (August 2026)."""
    records = []
    lines = unfold_ical_lines(ics_text)
    current = None
    for line in lines:
        if line.startswith("BEGIN:VEVENT"):
            current = {}
        elif line.startswith("END:VEVENT"):
            if current and current.get("title") and current.get("date"):
                records.append({
                    "title": current["title"],
                    "content_type": "Event",
                    "description": current.get("description") or f"{current['title']} - see event page for details.",
                    "event_date_override": current["date"],
                    "source_url_override": current.get("url", source_url),
                })
            current = None
        elif current is not None:
            if line.startswith("SUMMARY"):
                _, _, value = line.partition(":")
                current["title"] = unescape_ical_text(value.strip())
            elif line.startswith("DESCRIPTION"):
                _, _, value = line.partition(":")
                current["description"] = unescape_ical_text(value.strip())[:500]
            elif line.startswith("DTSTART"):
                _, _, value = line.partition(":")
                current["date"] = parse_ical_date(value.strip())
            elif line.startswith("URL"):
                _, _, value = line.partition(":")
                current["url"] = value.strip()
    return records


def discover_ical_feed(candidate_urls):
    """Probe a small set of candidate URLs for a working iCal feed by
    directly checking whether appending '?ical=1' returns real VCALENDAR
    data - not by guessing from platform/CMS, which can't reliably predict
    whether a working feed actually exists (confirmed real example:
    VMBA's ?ical=1 feed, found August 16, 2026). Self-verifying: either
    the response is valid or it isn't, no inference involved. Returns the
    feed text if found, else None."""
    headers = {"User-Agent": "VermontNonprofitPulse/1.0"}
    tried = set()
    for url in candidate_urls:
        base = url.split("?")[0].rstrip("/")
        probe_url = base + "/?ical=1"
        if probe_url in tried:
            continue
        tried.add(probe_url)
        try:
            response = requests.get(probe_url, timeout=10, headers=headers)
            if response.status_code == 200 and response.text.strip().startswith("BEGIN:VCALENDAR"):
                return response.text
        except requests.RequestException:
            continue
    return None


def extract_jsonld_events(soup, source_url):
    """Extract event records directly from the page's own structured data
    (schema.org Event via JSON-LD), if present - a real, deterministic
    alternative to asking Claude to disambiguate dates from flattened text.
    Confirmed real fix for the VMBA date-misattribution bug (STP - 2026
    Velo Stowe getting Trail Work Night's date): both events are separate,
    self-contained JSON objects in the source data, making cross-
    contamination between neighboring events structurally impossible here,
    unlike parsing flattened HTML text ever could guarantee.
    Generic - checks for the data's presence on any page, not tied to
    WordPress, Yoast, or any specific plugin/platform (August 2026)."""
    records = []
    for script in soup.find_all("script", type="application/ld+json"):
        if not script.string:
            continue
        try:
            data = json.loads(script.string)
        except (TypeError, ValueError):
            continue

        if isinstance(data, dict) and "@graph" in data:
            candidates = data["@graph"]
        elif isinstance(data, list):
            candidates = data
        else:
            candidates = [data]

        for item in candidates:
            if not isinstance(item, dict) or item.get("@type") != "Event":
                continue
            name = html.unescape(item.get("name", "")).strip()
            start_date_raw = item.get("startDate")
            if not name or not start_date_raw:
                continue
            try:
                parsed_date = dateutil_parser.parse(start_date_raw).date()
            except (ValueError, TypeError):
                continue

            description = html.unescape(item.get("description", "") or "")
            # Strip the "Read more..." link artifact WordPress often embeds
            # at the end of JSON-LD descriptions.
            description = re.sub(r'<a class="moretag".*', '', description).strip()
            if not description:
                description = f"{name} - see event page for details."

            records.append({
                "title": name,
                "content_type": "Event",
                "description": description[:500],
                "event_date_override": parsed_date,
                "source_url_override": item.get("url", source_url),
            })
    return records


def scrape_website(url):
    try:
        headers = {"User-Agent": "VermontNonprofitPulse/1.0"}
        response = requests.get(url, timeout=10, headers=headers)
        soup = BeautifulSoup(response.text, "html.parser")
        # Capture structured event data BEFORE stripping script tags below -
        # this is where it lives, and it was previously being destroyed
        # before we ever got a chance to look at it (August 2026).
        jsonld_events = extract_jsonld_events(soup, url)
        # Strip navigation/header/footer boilerplate - many real sites (e.g.
        # WordPress themes) put large menus in <header> without a <nav> tag,
        # which previously ate into the truncation budget before any real
        # content was reached.
        for tag in soup(["script", "style", "nav", "footer", "header"]):
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
        # Truncation limits raised substantially (was 2000/page, 5000 total)
        # - real event calendar pages routinely exceed those limits before
        # reaching the actual dated content, causing missed and misattributed
        # events. Claude can easily handle this much more text.
        combined = text[:6000]
        if pdf_text:
            combined += "\nPDF CONTENT: " + pdf_text[:3000]
        return combined, jsonld_events
    except Exception as e:
        return f"Error: {e}", []


def process_single_page(url, org, cursor, conn):
    """Process exactly one discovered page for an organization - scrape,
    check for changes, extract via JSON-LD and Claude, and save. Each
    record is saved with THIS page's own URL as its source, not the org's
    generic homepage - fixes the source-link attribution bug (confirmed
    affecting every organization using standard AI extraction, found
    August 22, 2026, right before the FPF meeting). Returns
    (saved_count, jsonld_saved_count, had_content)."""
    text, jsonld_events = scrape_website(url)
    if text.startswith("Error"):
        return 0, 0, False

    page_hash = make_hash(org["name"] + url + text + SCRAPER_VERSION)

    jsonld_saved = 0
    if jsonld_events:
        jsonld_saved = save_to_database(
            jsonld_events, org["name"], org["town"], org["county"],
            org["mission"], url, page_hash, cursor, conn
        )
        if jsonld_saved:
            print(f"  Saved {jsonld_saved} from structured event data ({url})")

    if hash_exists(cursor, page_hash):
        return 0, jsonld_saved, True

    if not text:
        return 0, jsonld_saved, True

    tagged = tag_content(text, org["name"], org["town"])
    if "NO ITEMS FOUND" in tagged:
        return 0, jsonld_saved, True

    records = parse_results(tagged)
    saved = save_to_database(
        records, org["name"], org["town"], org["county"],
        org["mission"], url, page_hash, cursor, conn
    )
    return saved, jsonld_saved, True


def scrape_multiple_pages(urls):
    combined = []
    errors = []
    all_jsonld_events = []
    for url in urls:
        text, jsonld_events = scrape_website(url)
        if text.startswith("Error"):
            errors.append(f"{url}: {text}")
        else:
            combined.append(text)
            all_jsonld_events.extend(jsonld_events)
    return "\n".join(combined)[:15000], errors, all_jsonld_events


def fetch_facebook_posts(facebook_url, limit=20):
    APIFY_API_KEY = os.environ["APIFY_API_KEY"]
    ACTOR_ID = "KoJrdxJCTtpon81KY"
    headers = {
        "Authorization": f"Bearer {APIFY_API_KEY}",
        "Content-Type": "application/json"
    }
    run_response = requests.post(
        f"https://api.apify.com/v2/acts/{ACTOR_ID}/runs",
        params={"build": "0.99.1329"},
        json={"startUrls": [{"url": facebook_url}], "resultsLimit": limit},
        headers=headers
    )
    if run_response.status_code not in (200, 201):
        print(f"  Apify run failed to start: HTTP {run_response.status_code} - {run_response.text[:300]}")
        return []
    run_id = run_response.json().get("data", {}).get("id")
    if not run_id:
        print(f"  Apify run failed to start: no run id in response - {run_response.text[:300]}")
        return []
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
    today_str = datetime.now().strftime("%B %d, %Y")
    prompt = (
        "Today's date is " + today_str + ". "
        "You are helping build Vermont Nonprofit Pulse, a Vermont-only nonprofit aggregator. "
        "Read this content from " + org_name + " based in " + org_town + ", Vermont. "
        "Extract specific named events, volunteer opportunities, fundraisers, "
        "news items, paid job postings, or classes/workshops/trainings. "
        "STRICT RULES: "
        "1. Only include items that take place in Vermont or directly benefit Vermont residents. "
        "2. Skip any events in other states. "
        "3. Only include items with a specific name not just a date. "
        "4. Write meaningful 2-sentence descriptions using only details from the content. "
        "5. Never write that details are available elsewhere. "
        "6. Never group multiple events into one entry. "
        "7. If an item only has a date with no name skip it. "
        "8. Extract specific dates when mentioned - never mark a dated event as Ongoing. "
        "8b. If a date is mentioned without a year (e.g. 'Saturday, September 12'), "
        "use today's actual date above to determine the year: use this year if that date "
        "hasn't happened yet this year, or next year if it has already passed. Never guess "
        "a year based on anything other than today's actual date given above. "
        "9. If the content lists multiple items close together, be careful to pair "
        "each date only with its own specific item - never reuse a nearby item's "
        "date for a different item. "
        "10. Employment means a paid staff position or paid apprenticeship only. "
        "Volunteer means an unpaid opportunity - ride leaders, event volunteers, "
        "and similar unpaid roles are always Volunteer, never Employment. "
        "11. Class means a class, workshop, training, or skill-building session "
        "(e.g. a bike repair class or earn-a-bike program), whether one-time or recurring. "
        "12. If the content mentions a specific date or date range anywhere in its text "
        "(for example 'running from July 30 through August 2', or 'closed on August 11'), "
        "that counts as a specific date even if it isn't labeled as an event date - use the "
        "first/start date of that range as DATE. Only use Ongoing when no specific date or "
        "date range appears anywhere in the content for that item. "
        "13. If you provide a DATE, you must also quote the exact short phrase from the "
        "content that states that date, word-for-word, as DATE_EVIDENCE. This must be a "
        "verbatim quote copied exactly from the content, not a paraphrase. Leave blank if DATE is Ongoing. "
        "14. If DATE is Ongoing and the content states a clear recurring day-of-week pattern "
        "(for example 'every Tuesday', 'every Monday evening', 'the 3rd Sunday of the month', "
        "'last Thursday of each month'), also provide RECURRENCE in exactly this format and "
        "nothing else: for weekly patterns write 'weekly:DAY' (e.g. 'weekly:tuesday'); for "
        "monthly patterns write 'monthly:POSITION:DAY' where POSITION is 1st, 2nd, 3rd, 4th, "
        "or last (e.g. 'monthly:3rd:sunday'). DAY must be a full lowercase day name (monday "
        "through sunday). If the pattern is unclear, irregular, or doesn't fit this exact "
        "format, leave RECURRENCE blank rather than guessing - never invent a pattern. "
        "For each qualifying item return: "
        "TITLE: [specific name] "
        "TYPE: [Event/Volunteer/Fundraiser/News/Donate/Employment/Class] "
        "DATE: [specific date if mentioned, or Ongoing only for truly recurring programs] "
        "DATE_EVIDENCE: [exact verbatim phrase from the content stating this date, or blank if Ongoing] "
        "RECURRENCE: [weekly:day or monthly:position:day format, or blank] "
        "DESCRIPTION: [2 sentences with real details] "
        "--- "
        "Content: " + raw_text + " "
        "If nothing qualifies say NO ITEMS FOUND."
    )
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=3000,
        messages=[{"role": "user", "content": prompt}]
    )
    return message.content[0].text


def normalize_title(title):
    """Lowercase and strip punctuation/spacing so minor formatting
    differences (dashes, capitalization, extra spaces) don't create
    false-different event identities."""
    t = title.lower()
    t = re.sub(r'[^a-z0-9]+', ' ', t)
    t = re.sub(r'\s+', ' ', t).strip()
    return t


def make_series_key(title, org_name):
    """Fingerprint for 'this recurring thing' independent of any specific
    date - used to recognize when a new dated occurrence (e.g. this week's
    Trail Work Night) is really the same recurring series as a previously
    saved occurrence, so the date gets updated in place instead of piling
    up a new row every time a new occurrence's page gets discovered.
    Generic - works for any org's recurring events automatically, no
    per-org configuration (August 16, 2026)."""
    normalized = normalize_title(title)
    return make_hash(normalized + "|" + org_name.strip().lower())


def find_existing_series_row(cursor, series_key):
    """Find an existing active row for this recurring series, if any -
    dated or undated, doesn't matter, since series_key is title+org only.
    Previously restricted to dated existing rows and only checked when the
    new record itself had a date - that restriction was the actual dated-
    vs-Ongoing dedup gap (VMBA's Trail Work Night showing as two rows,
    found August 2026): a dated and an undated record of the exact same
    real thing were structurally never compared. Removing the restriction
    closes it using the same exact-title mechanism already trusted all
    session, not a new fuzzy judgment call."""
    cursor.execute(
        "SELECT id, event_date FROM content WHERE series_key = %s "
        "AND status = 'active' LIMIT 1",
        (series_key,)
    )
    return cursor.fetchone()


def find_existing_by_event_key(cursor, event_key):
    """Find an existing active row with this exact event_key, if any - lets
    reprocessing (e.g. after a SCRAPER_VERSION bump) correctly update a
    stale record in place, rather than the update silently failing because
    the fresh INSERT collides with the old row's event_key and gets
    skipped. Closes a gap the series_key mechanism didn't cover: it only
    helped dated items, this covers undated ones too (August 16, 2026)."""
    if not event_key:
        return None
    cursor.execute(
        "SELECT id FROM content WHERE event_key = %s AND status = 'active' LIMIT 1",
        (event_key,)
    )
    row = cursor.fetchone()
    return row[0] if row else None


DEDUP_STOPWORDS = {
    'a', 'an', 'the', 'and', 'or', 'of', 'to', 'in', 'on', 'at', 'for', 'with',
    'is', 'are', 'this', 'that', 'it', 'its', 'their', 'our', 'we', 'will',
    'be', 'as', 'by', 'from', 'all', 'can', 'has', 'have', 'was', 'were',
    'which', 'who', 'into'
}


def significant_words(text):
    """Lowercase words with common filler stripped, for description
    similarity comparison. Not used for anything else - specifically for
    detecting the same real event described in different wording."""
    words = re.findall(r"[a-z0-9]+", (text or "").lower())
    return set(w for w in words if w not in DEDUP_STOPWORDS and len(w) > 2)


def description_similarity(desc_a, desc_b):
    """How much of the smaller description's significant words are also
    present in the other - a simple, fully deterministic word-overlap
    metric, no AI judgment involved. Validated against real duplicate
    pairs found August 16, 2026 (scored 0.77-0.88) and stress-tested
    against the hardest real false-positive risk, Kelly Brush's
    'Adaptive Rec Talks' series - genuinely different events with
    near-identical template wording (scored 0.62-0.68). This alone
    cannot safely distinguish those - see find_duplicate_by_description,
    which requires this AND a matching date/undated-status together."""
    a = significant_words(desc_a)
    b = significant_words(desc_b)
    if not a or not b:
        return 0.0
    overlap = len(a & b)
    return overlap / min(len(a), len(b))


DEDUP_SIMILARITY_THRESHOLD = 0.65


def title_containment_match(title_a, title_b):
    """Check whether one title's meaningful words are fully contained
    within the other - e.g. 'Reward Volunteers' within 'Reward Volunteers
    Program'. Deliberately stricter than a general word-overlap ratio:
    requires full containment, not just partial overlap. This matters
    because general overlap ratios proved genuinely unsafe on their own -
    confirmed against real data that template-based titles like 'Adaptive
    Rec Talks - Tennis' vs '...Pickleball' score HIGHER on general overlap
    (0.75) than some real duplicate pairs this check is meant to catch,
    yet are genuinely different real events. Full containment correctly
    separates them (neither is a full subset of the other), while still
    catching real cases like the ones above. Tested against 3 real
    duplicate pairs (all correctly matched), 5 real near-miss titles from
    actual production data (all correctly stayed separate), and all 10
    Adaptive Rec Talks pairs (all correctly stayed separate) before
    shipping (August 22, 2026)."""
    words_a = significant_words(title_a)
    words_b = significant_words(title_b)
    if not words_a or not words_b:
        return False
    shorter, longer = (words_a, words_b) if len(words_a) <= len(words_b) else (words_b, words_a)
    return shorter.issubset(longer)


def find_duplicate_by_description(cursor, org_name, event_date, title, description):
    """Find an existing active row at the same organization whose title or
    description is similar enough to be the same real-world event
    described in different wording - e.g. 'Fall Fundo' vs 'The 2026 Fall
    Fundo'. Checks two categories of candidate, both required to match on
    title containment OR description similarity, never on date alone:
    1. Same date (or both undated) - the original check.
    2. One dated, the other undated - closes the 'dated instance vs
       generic recurring description' gap (Betty's Bikes' Potluck Dinner
       pattern, found August 2026). Deliberately NOT extended to two
       different specific dates - confirmed via the Adaptive Rec Talks
       case that description similarity alone cannot safely distinguish
       different real dated occurrences from each other; the exact-date
       requirement stays essential for that comparison, this only relaxes
       it for the narrower, safer dated-vs-undated shape.
    Returns (row_id, existing_event_date) so the caller can merge
    intelligently - preferring to keep/upgrade to a real date rather than
    silently discarding one - or None if no match."""
    if event_date:
        cursor.execute(
            "SELECT id, title, description, event_date FROM content WHERE organization_name = %s "
            "AND status = 'active' AND event_date = %s",
            (org_name, event_date)
        )
    else:
        cursor.execute(
            "SELECT id, title, description, event_date FROM content WHERE organization_name = %s "
            "AND status = 'active' AND event_date IS NULL",
            (org_name,)
        )
    for row_id, existing_title, existing_desc, existing_date in cursor.fetchall():
        if title_containment_match(title, existing_title):
            return row_id, existing_date
        if description_similarity(description, existing_desc) >= DEDUP_SIMILARITY_THRESHOLD:
            return row_id, existing_date

    # Dated-vs-undated cross-check - never dated-vs-a-different-date.
    if event_date:
        cursor.execute(
            "SELECT id, title, description, event_date FROM content WHERE organization_name = %s "
            "AND status = 'active' AND event_date IS NULL",
            (org_name,)
        )
    else:
        cursor.execute(
            "SELECT id, title, description, event_date FROM content WHERE organization_name = %s "
            "AND status = 'active' AND event_date IS NOT NULL",
            (org_name,)
        )
    for row_id, existing_title, existing_desc, existing_date in cursor.fetchall():
        if title_containment_match(title, existing_title):
            return row_id, existing_date
        if description_similarity(description, existing_desc) >= DEDUP_SIMILARITY_THRESHOLD:
            return row_id, existing_date

    return None


def make_event_key(title, event_date, org_name):
    """Build a fingerprint so the same real-world item - dated or
    undated/recurring - is recognized as one item, not several, no matter
    how many times or how differently it gets reworded across scrapes.
    Dated items: title + date. Undated/Ongoing items: title + org, since
    there's no date to anchor identity - closes the gap where 'Pedals to
    the People', 'Ride Leaders Needed', and 'Trail Work Night' were each
    duplicating under slightly different wording (found August 15, 2026)."""
    normalized = normalize_title(title)
    if event_date:
        return make_hash(normalized + "|" + str(event_date))
    else:
        return make_hash(normalized + "|" + org_name.strip().lower() + "|ongoing")


def normalize_ws(text):
    return re.sub(r'\s+', ' ', text).strip().lower()


def verify_date_attribution(records, raw_text):
    """Deterministic check that each record's date actually belongs to it,
    not a nearby item - catches misattribution like STP/Trail Work Night
    (Aug 15, 2026). Requires Claude's DATE_EVIDENCE quote to appear verbatim
    in the source, and to belong to this item in reading order (the title
    that most recently preceded the evidence) - not just whichever title is
    numerically closest, which was tested and found unreliable."""
    raw_norm = normalize_ws(raw_text)
    title_positions = []
    for r in records:
        title = r.get("title", "").strip()
        pos = raw_norm.find(normalize_ws(title)[:40]) if title else -1
        title_positions.append(pos)

    for i, record in enumerate(records):
        date_text = record.get("date_text", "").strip()
        evidence = record.get("date_evidence", "").strip()
        if not date_text:
            continue
        if not evidence:
            print(f"  DATE VERIFICATION: no evidence for '{record.get('title')}' - clearing date")
            record["date_text"] = ""
            continue
        evidence_norm = normalize_ws(evidence)
        occurrences = [m.start() for m in re.finditer(re.escape(evidence_norm), raw_norm)]
        if not occurrences:
            print(f"  DATE VERIFICATION: evidence not found verbatim for "
                  f"'{record.get('title')}' - clearing date")
            record["date_text"] = ""
            continue
        confirmed = False
        for occ in occurrences:
            preceding = [(tp, idx) for idx, tp in enumerate(title_positions) if tp != -1 and tp <= occ]
            if not preceding:
                continue
            owner_idx = max(preceding, key=lambda x: x[0])[1]
            if owner_idx == i:
                confirmed = True
                break
        if not confirmed:
            print(f"  DATE VERIFICATION: evidence for '{record.get('title')}' "
                  f"belongs to a different item - clearing date")
            record["date_text"] = ""
    return records


VALID_DAYS = {"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}
VALID_POSITIONS = {"1st", "2nd", "3rd", "4th", "last"}


def validate_recurrence_pattern(raw):
    """Strictly validate a recurrence pattern against the exact closed
    format - anything not matching is discarded (returns None), never
    partially trusted or guessed at. This is the safety net: even if
    Claude's day-of-week judgment is imperfect, an invalid pattern just
    means no 'next occurrence' feature for that item (falls back to plain
    Ongoing, today's existing safe behavior) - never a wrong computed date."""
    if not raw:
        return None
    raw = raw.strip().lower()
    parts = raw.split(":")
    if len(parts) == 2 and parts[0] == "weekly":
        if parts[1] in VALID_DAYS:
            return raw
        return None
    if len(parts) == 3 and parts[0] == "monthly":
        if parts[1] in VALID_POSITIONS and parts[2] in VALID_DAYS:
            return raw
        return None
    return None


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
            elif line.startswith("DATE_EVIDENCE:"):
                record["date_evidence"] = line.replace("DATE_EVIDENCE:", "").strip()
            elif line.startswith("RECURRENCE:"):
                record["recurrence_raw"] = line.replace("RECURRENCE:", "").strip()
            elif line.startswith("DATE:"):
                record["date_text"] = line.replace("DATE:", "").strip()
        if "title" in record and "content_type" in record:
            records.append(record)
    return records


def save_to_database(records, org_name, town, county, mission_area,
                     source_url, source_hash, cursor, conn):
    saved = 0
    updated = 0
    blocked = 0
    for record in records:
        if "event_date_override" in record:
            # Real, structured data (e.g. JSON-LD) - never re-derive this
            # from text, and never subject it to the AI-hallucination
            # future-date cap, since it isn't a guess to begin with.
            event_date = record["event_date_override"]
        else:
            event_date = parse_event_date(record.get("date_text", ""))
        record_source_url = record.get("source_url_override", source_url)
        if not is_valid_record(record, town, event_date):
            blocked += 1
            continue
        series_key = make_series_key(record.get("title", ""), org_name)
        event_key = make_event_key(record.get("title", ""), event_date, org_name)
        recurrence_pattern = validate_recurrence_pattern(record.get("recurrence_raw", ""))

        duplicate_match = find_duplicate_by_description(
            cursor, org_name, event_date, record.get("title", ""), record.get("description", "")
        )
        if duplicate_match:
            dup_id, dup_existing_date = duplicate_match
            final_date = event_date if event_date else dup_existing_date
            try:
                cursor.execute(
                    "UPDATE content SET event_date = %s, description = %s, "
                    "title = %s, source_url = %s, source_hash = %s, "
                    "event_key = %s WHERE id = %s",
                    (final_date, record.get("description"), record.get("title"),
                     record_source_url, source_hash,
                     make_event_key(record.get("title", ""), final_date, org_name),
                     dup_id)
                )
                conn.commit()
                updated += 1
                continue
            except Exception as e:
                conn.rollback()
                print(f"  Skipped (update): {e}")
                continue

        existing_series_match = find_existing_series_row(cursor, series_key)
        if existing_series_match:
            existing_id, existing_date = existing_series_match
            # Prefer a real date over "Ongoing" - if this record has one and
            # the existing row doesn't, that's an upgrade, not a downgrade.
            # If the existing row already has a date and this new record
            # doesn't, keep the existing date rather than erasing it.
            final_date = event_date if event_date else existing_date
            try:
                cursor.execute(
                    "UPDATE content SET event_date = %s, description = %s, "
                    "title = %s, source_url = %s, source_hash = %s, "
                    "event_key = %s WHERE id = %s",
                    (final_date, record.get("description"), record.get("title"),
                     record_source_url, source_hash,
                     make_event_key(record.get("title", ""), final_date, org_name),
                     existing_id)
                )
                conn.commit()
                updated += 1
                continue
            except Exception as e:
                conn.rollback()
                print(f"  Skipped (update): {e}")
                continue

        existing_by_event_key = find_existing_by_event_key(cursor, event_key)
        if existing_by_event_key:
            try:
                cursor.execute(
                    "UPDATE content SET event_date = %s, description = %s, "
                    "title = %s, content_type = %s, source_url = %s, "
                    "source_hash = %s, series_key = %s WHERE id = %s",
                    (event_date, record.get("description"), record.get("title"),
                     record.get("content_type"), record_source_url, source_hash,
                     series_key, existing_by_event_key)
                )
                conn.commit()
                updated += 1
                continue
            except Exception as e:
                conn.rollback()
                print(f"  Skipped (update): {e}")
                continue

        try:
            cursor.execute(
                "INSERT INTO content (organization_name, content_type, title, "
                "description, event_date, event_key, series_key, recurrence_pattern, "
                "town, county, mission_area, source_url, source_hash, status) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (org_name, record.get("content_type"), record.get("title"),
                 record.get("description"), event_date, event_key, series_key,
                 recurrence_pattern, town, county, mission_area, record_source_url,
                 source_hash, "active")
            )
            conn.commit()
            saved += 1
        except Exception as e:
            # Reset the connection immediately so one bad record can never
            # block or wipe out any other record's save in this batch.
            conn.rollback()
            print(f"  Skipped: {e}")
    if blocked > 0:
        print(f"  Blocked {blocked} records by validation layer")
    if updated > 0:
        print(f"  Updated {updated} recurring occurrence(s) in place")
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
    {
        "name": "AALV (Association of Africans Living in Vermont)",
        "urls": ["https://www.aalv-vt.org"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.aalv-vt.org"
    },
    {
        "name": "ACLU of Vermont",
        "urls": ["https://www.acluvt.org/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "https://www.acluvt.org/"
    },
    {
        "name": "I Am A Vermonter",
        "urls": ["https://www.iamavermonter.org/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.iamavermonter.org/"
    },
    {
        "name": "Migrant Justice",
        "urls": ["https://migrantjustice.net/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://migrantjustice.net/"
    },
    {
        "name": "Peace and Justice Center",
        "urls": ["https://www.pjcvt.org/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.pjcvt.org/"
    },
    {
        "name": "The Root Social Justice Center",
        "urls": ["https://www.therootsjc.org/mission"],
        "town": "Brattleboro", "county": "Windham",
        "mission": "Justice & Legal",
        "source_url": "https://www.therootsjc.org/mission"
    },
    {
        "name": "Vermont Association for Justice",
        "urls": ["https://www.vermontjustice.org/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "https://www.vermontjustice.org/"
    },
    {
        "name": "Vermont Bar Association",
        "urls": ["https://www.vtbar.org/pro-bono-legal-services/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "https://www.vtbar.org/pro-bono-legal-services/"
    },
    {
        "name": "Vermont Legal Aid",
        "urls": ["https://www.vtlegalaid.org/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.vtlegalaid.org/"
    },
    {
        "name": "Legal Services Vermont",
        "urls": ["https://legalservicesvt.org/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://legalservicesvt.org/"
    },
    {
        "name": "Vermont Partnership for Fairness and Diversity",
        "urls": ["http://www.vermontpartnership.org/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "http://www.vermontpartnership.org/"
    },
    {
        "name": "Somali Bantu Community Association of Vermont",
        "urls": ["https://somalibantuvermont.org"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://somalibantuvermont.org"
    },
    {
        "name": "Rutland Area NAACP",
        "urls": ["https://naacprutland.org"],
        "town": "Rutland", "county": "Rutland",
        "mission": "Justice & Legal",
        "source_url": "https://naacprutland.org"
    },
    {
        "name": "Disability Rights Vermont",
        "urls": ["https://disabilityrightsvt.org/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "https://disabilityrightsvt.org/"
    },
    {
        "name": "Vermont Asylum Assistance Project",
        "urls": ["https://www.vaapvt.org/"],
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.vaapvt.org/"
    },
    {
        "name": "Community Justice Network of Vermont",
        "urls": ["https://cjnvt.org/"],
        "town": "Montpelier", "county": "Washington",
        "mission": "Justice & Legal",
        "source_url": "https://cjnvt.org/"
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
    {
        "name": "Pride Rides VT",
        "facebook_url": "https://www.facebook.com/PrideRidesVT/",
        "town": "Barre", "county": "Washington",
        "mission": "Bikes & Pedestrian",
        "source_url": "https://prideridesvt.com/"
    },
    {
        "name": "Community Voices for Immigrant Rights",
        "facebook_url": "https://www.facebook.com/CVIRBurlington/",
        "town": "Burlington", "county": "Chittenden",
        "mission": "Justice & Legal",
        "source_url": "https://www.facebook.com/CVIRBurlington/"
    },
    {
        "name": "Racial Equity Alliance of Lamoille",
        "facebook_url": "https://www.facebook.com/REALamoilleVT/",
        "town": "Morrisville", "county": "Lamoille",
        "mission": "Justice & Legal",
        "source_url": "https://www.facebook.com/REALamoilleVT/"
    },
]

total_saved = 0
error_count = 0
total_orgs_attempted = 0
conn = get_db_connection()
cursor = conn.cursor()

print("=== WEBSITE SCRAPING ===")
for org in website_nonprofits:
    print(f"Processing {org['name']}...")
    total_orgs_attempted += 1
    try:
        discovered_links = discover_all_relevant_links(org["urls"])
        if discovered_links:
            print(f"  Discovered {len(discovered_links)} relevant page(s): {discovered_links}")
        all_urls = org["urls"] + discovered_links

        ical_feed = discover_ical_feed(all_urls)
        if ical_feed:
            ical_events = extract_ical_events(ical_feed, org["source_url"])
            if ical_events:
                ical_hash = make_hash(org["name"] + "ical" + SCRAPER_VERSION)
                ical_saved = save_to_database(
                    ical_events, org["name"], org["town"], org["county"],
                    org["mission"], org["source_url"], ical_hash, cursor, conn
                )
                if ical_saved:
                    print(f"  Saved {ical_saved} from iCal feed ({len(ical_events)} events found)")
                total_saved += ical_saved

        org_saved = 0
        any_content_found = False
        for url in all_urls:
            saved, jsonld_saved, had_content = process_single_page(url, org, cursor, conn)
            org_saved += saved + jsonld_saved
            if had_content:
                any_content_found = True

        total_saved += org_saved

        if not any_content_found:
            print("  No content found on any page")
            record_scrape_status(cursor, conn, org["name"], "no_content", "No content found on any page")
            continue

        print(f"  Saved {org_saved} new records")
        record_scrape_status(cursor, conn, org["name"], "ok")
    except Exception as e:
        print(f"  Error: {e}")
        error_count += 1
        record_scrape_status(cursor, conn, org["name"], "error", str(e))

print("\n=== FACEBOOK SCRAPING ===")
for org in facebook_nonprofits:
    print(f"Processing {org['name']} via Facebook...")
    total_orgs_attempted += 1
    try:
        posts = fetch_facebook_posts(org["facebook_url"], limit=20)
        print(f"  Found {len(posts)} posts")

        if not posts:
            record_scrape_status(cursor, conn, org["name"], "no_content", "Apify returned zero posts")
            continue

        new_posts = []
        for post in posts:
            post_url = post.get("url", "")
            post_hash = make_hash(post_url + SCRAPER_VERSION)
            if not hash_exists(cursor, post_hash):
                new_posts.append((post, post_hash))

        print(f"  {len(new_posts)} new posts not yet in database")

        posts_saved_any = False
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
                posts_saved_any = True
                print(f"  Saved {saved} records from post")

        record_scrape_status(
            cursor, conn, org["name"],
            "ok" if posts_saved_any else "no_items"
        )
    except Exception as e:
        print(f"  Error: {e}")
        error_count += 1
        record_scrape_status(cursor, conn, org["name"], "error", str(e))

cursor.close()
conn.close()
print(f"\n=== COMPLETE: {total_saved} total new records saved ===")

# Widespread-failure detection: one organization erroring is normal and
# shouldn't block the rest of the run - but if MOST organizations fail the
# same way (as happened August 21, 2026, when a deprecated API parameter
# silently broke almost everything), that's a serious problem that should
# be loud and visible, not hidden behind a green checkmark. Exiting
# non-zero here causes GitHub Actions to mark the run as failed, which
# triggers its default failure notification - turning a silent, easily-
# missed failure into something that actually gets noticed.
if total_orgs_attempted > 0:
    failure_rate = error_count / total_orgs_attempted
    if failure_rate > 0.4:
        print(
            f"\n!!! WIDESPREAD FAILURE: {error_count} of {total_orgs_attempted} "
            f"organizations errored ({failure_rate:.0%}) - failing this run "
            f"loudly rather than reporting false success !!!"
        )
        sys.exit(1)
