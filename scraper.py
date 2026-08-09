import psycopg2
import anthropic
import requests
from bs4 import BeautifulSoup
import os
import time

# Debug — verify environment variables are set
db_url = os.environ.get('DATABASE_URL', 'NOT SET')
print(f"DATABASE_URL starts with: {db_url[:30]}")
apify_key = os.environ.get('APIFY_API_KEY', 'NOT SET')
print(f"APIFY_API_KEY starts with: {apify_key[:10]}")

def get_db_connection():
    return psycopg2.connect(os.environ['DATABASE_URL'])

def scrape_website(url):
    try:
        headers = {'User-Agent': 'VermontNonprofitPulse/1.0'}
        response = requests.get(url, timeout=10, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')
        for tag in soup(['script', 'style', 'nav', 'footer']):
            tag.decompose()
        text = soup.get_text(separator=' ', strip=True)
        return text[:2000]
    except Exception as e:
        return f"Error: {e}"

def fetch_facebook_posts(facebook_url, limit=20):
    APIFY_API_KEY = os.environ['APIFY_API_KEY']
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
    run_id = run_response.json().get('data', {}).get('id')
    print(f"  Apify run started: {run_id}")

    for i in range(30):
        time.sleep(10)
        status_response = requests.get(
            f"https://api.apify.com/v2/actor-runs/{run_id}",
            headers=headers
        )
        status_data = status_response.json()
        status = status_data.get('data', {}).get('status')
        if status == 'SUCCEEDED':
            dataset_id = status_data.get('data', {}).get('defaultDatasetId')
            results = requests.get(
                f"https://api.apify.com/v2/datasets/{dataset_id}/items",
                headers=headers
            ).json()
            page_name = facebook_url.rstrip('/').split('/')[-1]
            filtered = [p for p in results if page_name in str(p.get('url', ''))]
            return filtered
        elif status in ['FAILED', 'ABORTED']:
            print(f"  Apify run failed")
            return []
    return []

def tag_content(raw_text, org_name):
    client = anthropic.Anthropic(api_key=os.environ['ANTHROPIC_API_KEY'])
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        messages=[{
            "role": "user",
            "content": f"""You are helping build Vermont Nonprofit Pulse, a database of Vermont nonprofit events and opportunities.

Read this content from {org_name} and extract any events, volunteer opportunities, fundraisers, or news items.

For each item found, return it in this exact format:
TITLE: [title of the item]
TYPE: [Event, Volunteer, Fundraiser, News, or Donate]
DATE: [date if mentioned, or Ongoing if no specific date]
DESCRIPTION: [2 sentence description]
---

Content:
{raw_text}

Only include real specific items. If no clear items are found, say NO ITEMS FOUND."""
        }]
    )
    return message.content[0].text

def tag_facebook_posts(posts, org_name):
    combined_text = "\n\n".join([
        f"Post: {p.get('text', '')[:500]}"
        for p in posts if p.get('text')
    ])
    if not combined_text:
        return "NO ITEMS FOUND"
    return tag_content(combined_text, org_name)

def parse_results(tagged_text):
    records = []
    items = tagged_text.strip().split('---')
    for item in items:
        if not item.strip() or 'NO ITEMS FOUND' in item:
            continue
        record = {}
        for line in item.strip().split('\n'):
            if line.startswith('TITLE:'):
                record['title'] = line.replace('TITLE:', '').strip()
            elif line.startswith('TYPE:'):
                record['content_type'] = line.replace('TYPE:', '').strip()
            elif line.startswith('DESCRIPTION:'):
                record['description'] = line.replace('DESCRIPTION:', '').strip()
        if 'title' in record and 'content_type' in record:
            records.append(record)
    return records

def save_to_database(records, org_name, town, county, mission_area, source_url):
    conn = get_db_connection()
    cursor = conn.cursor()
    saved = 0
    for record in records:
        try:
            cursor.execute("""
                INSERT INTO content 
                (organization_name, content_type, title, description,
                 town, county, mission_area, source_url, status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                org_name,
                record.get('content_type'),
                record.get('title'),
                record.get('description'),
                town, county, mission_area, source_url, 'active'
            ))
            saved += 1
        except Exception as e:
            print(f"  Skipped duplicate: {record.get('title')}")
    conn.commit()
    cursor.close()
    conn.close()
    return saved

# Website-scraped nonprofits
website_nonprofits = [
    {"name": "Old Spokes Home", "url": "https://www.oldspokeshome.com", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
    {"name": "Bellows Falls Community Bike Project", "url": "https://bfbike.org", "town": "Bellows Falls", "county": "Windham", "mission": "Bikes & Pedestrian"},
    {"name": "Freeride Montpelier", "url": "https://freeridemontpelier.org", "town": "Montpelier", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Green Mountain Foster Bikes", "url": "https://www.greenmountainfosterbikes.org", "town": "Middlesex", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Bennington Bike Hub", "url": "https://ourbikehub.org", "town": "Bennington", "county": "Bennington", "mission": "Bikes & Pedestrian"},
    {"name": "Betty's Bikes", "url": "https://www.bettysbikes.org", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
    {"name": "Vermont Mountain Bike Association", "url": "https://vmba.org", "town": "Waterbury", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Kelly Brush Foundation", "url": "https://kellybrushfoundation.org", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
]

# Facebook-scraped nonprofits
facebook_nonprofits = [
    {"name": "Local Motion", "facebook_url": "https://www.facebook.com/localmotionvt/", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian", "source_url": "https://www.localmotion.org"},
]

total_saved = 0

# Scrape websites
print("=== WEBSITE SCRAPING ===")
for org in website_nonprofits:
    print(f"Processing {org['name']}...")
    try:
        raw_text = scrape_website(org['url'])
        if raw_text.startswith('Error'):
            print(f"  Scraping failed: {raw_text}")
            continue
        tagged = tag_content(raw_text, org['name'])
        if 'NO ITEMS FOUND' in tagged:
            print(f"  No items found")
            continue
        records = parse_results(tagged)
        saved = save_to_database(records, org['name'], org['town'], org['county'], org['mission'], org['url'])
        total_saved += saved
        print(f"  Saved {saved} new records")
    except Exception as e:
        print(f"  Error: {e}")

# Scrape Facebook pages
print("\n=== FACEBOOK SCRAPING ===")
for org in facebook_nonprofits:
    print(f"Processing {org['name']} via Facebook...")
    try:
        posts = fetch_facebook_posts(org['facebook_url'], limit=20)
        print(f"  Found {len(posts)} posts")
        if not posts:
            continue
        tagged = tag_facebook_posts(posts, org['name'])
        if 'NO ITEMS FOUND' in tagged:
            print(f"  No items found")
            continue
        records = parse_results(tagged)
        saved = save_to_database(records, org['name'], org['town'], org['county'], org['mission'], org['source_url'])
        total_saved += saved
        print(f"  Saved {saved} new records")
    except Exception as e:
        print(f"  Error: {e}")

print(f"\n=== COMPLETE: {total_saved} total new records saved ===")
