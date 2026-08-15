import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    const results = await sql(
      `SELECT organization_name, last_scrape_status, last_scrape_error, last_scrape_at
       FROM organizations
       ORDER BY last_scrape_at DESC NULLS LAST`
    );
    res.status(200).json({ success: true, count: results.length, data: results });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}
