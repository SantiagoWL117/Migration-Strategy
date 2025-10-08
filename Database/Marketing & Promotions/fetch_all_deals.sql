\o all_194_deals.json
SELECT json_agg(row_to_json(t))::text FROM (
  SELECT id, exceptions, active_days, items
  FROM staging.v1_deals
  ORDER BY id
) t;
\o
