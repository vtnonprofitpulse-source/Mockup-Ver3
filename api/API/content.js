import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    
    const { type, county, town, mission, search } = req.query;
    
    let query = `
      SELECT id, organization_name, content_type, title, description, 
             town, county, mission_area, source_url, event_date, status
      FROM content 
      WHERE status = 'active'
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (type) {
      query += ` AND LOWER(content_type) = LOWER($${paramCount})`;
      params.push(type);
      paramCount++;
    }
    
    if (county) {
      query += ` AND LOWER(county) = LOWER($${paramCount})`;
      params.push(county);
      paramCount++;
    }
    
    if (town) {
      query += ` AND LOWER(town) = LOWER($${paramCount})`;
      params.push(town);
      paramCount++;
    }
    
    if (mission) {
      query += ` AND LOWER(mission_area) = LOWER($${paramCount})`;
      params.push(mission);
      paramCount++;
    }
    
    if (search) {
      query += ` AND (LOWER(title) LIKE LOWER($${paramCount}) OR LOWER(description) LIKE LOWER($${paramCount}) OR LOWER(organization_name) LIKE LOWER($${paramCount}))`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    query += ` ORDER BY id DESC LIMIT 50`;
    
    const results = await sql(query, params);
    
    res.status(200).json({ success: true, count: results.length, data: results });
    
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}
