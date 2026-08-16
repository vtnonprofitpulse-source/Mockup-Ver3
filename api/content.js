import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    const { type, county, town, mission, search } = req.query;

    let contentQuery = `SELECT c.id, c.organization_name, c.content_type, c.title, c.description, c.town, c.county, c.mission_area, c.source_url, c.event_date, c.recurrence_pattern, c.status, 'content' as record_type, COALESCE(o2.featured, false) as featured FROM content c LEFT JOIN organizations o2 ON o2.organization_name = c.organization_name WHERE c.status = 'active' AND (c.event_date IS NULL OR c.event_date >= CURRENT_DATE)`;

    let orgsQuery = `SELECT o.id + 10000 as id, o.organization_name, 'Directory' as content_type, o.organization_name as title, o.mission_statement as description, o.town, o.county, o.mission_area, o.website_url as source_url, NULL as event_date, NULL as recurrence_pattern, o.status, 'organization' as record_type, o.featured as featured FROM organizations o WHERE o.status = 'active' AND NOT EXISTS (SELECT 1 FROM content c2 WHERE c2.organization_name = o.organization_name AND c2.status = 'active' AND (c2.event_date IS NULL OR c2.event_date >= CURRENT_DATE))`;

    const params = [];
    let paramCount = 1;

    if (type && type !== 'Directory') {
      contentQuery += ` AND LOWER(c.content_type) = LOWER($${paramCount})`;
      params.push(type);
      paramCount++;
    }
    if (county) {
      contentQuery += ` AND LOWER(c.county) = LOWER($${paramCount})`;
      orgsQuery += ` AND LOWER(o.county) = LOWER($${paramCount})`;
      params.push(county);
      paramCount++;
    }
    if (town) {
      contentQuery += ` AND LOWER(c.town) = LOWER($${paramCount})`;
      orgsQuery += ` AND LOWER(o.town) = LOWER($${paramCount})`;
      params.push(town);
      paramCount++;
    }
    if (mission) {
      contentQuery += ` AND LOWER(c.mission_area) = LOWER($${paramCount})`;
      orgsQuery += ` AND LOWER(o.mission_area) = LOWER($${paramCount})`;
      params.push(mission);
      paramCount++;
    }
    if (search) {
      contentQuery += ` AND (LOWER(c.title) LIKE LOWER($${paramCount}) OR LOWER(c.description) LIKE LOWER($${paramCount}) OR LOWER(c.organization_name) LIKE LOWER($${paramCount}))`;
      orgsQuery += ` AND (LOWER(o.organization_name) LIKE LOWER($${paramCount}) OR LOWER(o.mission_statement) LIKE LOWER($${paramCount}))`;
      params.push(`%${search}%`);
      paramCount++;
    }

    const combinedQuery = `
      SELECT * FROM (
        (${contentQuery}) UNION ALL (${orgsQuery})
      ) combined
      ORDER BY 
        featured DESC,
        organization_name ASC,
        (event_date IS NULL) ASC,
        event_date ASC,
        CASE LOWER(content_type)
          WHEN 'fundraiser' THEN 1
          WHEN 'event' THEN 2
          WHEN 'volunteer' THEN 3
          WHEN 'employment' THEN 4
          WHEN 'class' THEN 5
          WHEN 'donate' THEN 6
          WHEN 'news' THEN 7
          WHEN 'directory' THEN 8
          ELSE 9
        END ASC,
        id DESC
      LIMIT 100
    `;

    const results = await sql(combinedQuery, params);
    res.status(200).json({ success: true, count: results.length, data: results });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}
