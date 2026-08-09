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

def
