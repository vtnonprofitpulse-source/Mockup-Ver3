import psycopg2
import anthropic
import requests
from bs4 import BeautifulSoup
import os

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

def tag_content(raw_text, org_name):
    client = anthropic.Anthropic(api_key=os.environ['ANTHROPIC_API_KEY'])
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        messages=[{
            "role": "user",
            "content": f"""You are helping build Vermont Nonprofit Pulse, a database of Vermont nonprofit events and opportunities.

Read this text scraped from {org_name} website and extract any events, volunteer opportunities, fundraisers, or news items.

For each item found, return it in this exact format:
TITLE: [title of the item]
TYPE: [Event, Volunteer, Fundraiser, News, or Donate]
DATE: [date if mentioned, or Ongoing if no specific date]
DESCRIPTION: [2 sentence description]
---

Website text:
{raw_text}

Only include real specific items. If no clear items are found, say NO ITEMS FOUND."""
        }]
    )
    return message.content[0].text

def parse_results(tagged_text, org_name, town, county, mission_area, source_url):
    records = []
    items = tagged_text.strip().split('---')
    for item in items:
        if not item.strip() or 'NO ITEMS FOUND' in item:
            continue
        record = {
            'organization_name': org_name,
            'town': town,
            'county': county,
            'mission_area': mission_area,
            'source_url': source_url,
            'status': 'active'
        }
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

def save_to_database(records):
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
                record.get('organization_name'),
                record.get('content_type'),
                record.get('title'),
                record.get('description'),
                record.get('town'),
                record.get('county'),
                record.get('mission_area'),
                record.get('source_url'),
                record.get('status')
            ))
            saved += 1
        except Exception as e:
            print(f"Skipped duplicate: {record.get('title')}")
    conn.commit()
    cursor.close()
    conn.close()
    return saved

# List of nonprofits to scrape
nonprofits = [
    {"name": "Old Spokes Home", "url": "https://www.oldspokeshome.com", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
    {"name": "Bellows Falls Community Bike Project", "url": "https://bfbike.org", "town": "Bellows Falls", "county": "Windham", "mission": "Bikes & Pedestrian"},
    {"name": "Freeride Montpelier", "url": "https://freeridemontpelier.org", "town": "Montpelier", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Green Mountain Foster Bikes", "url": "https://www.greenmountainfosterbikes.org", "town": "Middlesex", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Bennington Bike Hub", "url": "https://ourbikehub.org", "town": "Bennington", "county": "Bennington", "mission": "Bikes & Pedestrian"},
    {"name": "Betty's Bikes", "url": "https://www.bettysbikes.org", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
    {"name": "Vermont Mountain Bike Association", "url": "https://vmba.org", "town": "Waterbury", "county": "Washington", "mission": "Bikes & Pedestrian"},
    {"name": "Kelly Brush Foundation", "url": "https://kellybrushfoundation.org", "town": "Burlington", "county": "Chittenden", "mission": "Bikes & Pedestrian"},
]

total_saved = 0
for org in nonprofits:
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
        records = parse_results(tagged, org['name'], org['town'], org['county'], org['mission'], org['url'])
        saved = save_to_database(records)
        total_saved += saved
        print(f"  Saved {saved} records")
    except Exception as e:
        print(f"  Error: {e}")

print(f"\nTotal new records saved: {total_saved}")