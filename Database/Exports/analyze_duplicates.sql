-- Analyze duplicates where name_en = name_fr
-- Categorize by type

-- 1. Count by pattern
SELECT 'English phrases (with/and)' as category, COUNT(DISTINCT name_en) as unique_names, COUNT(*) as total_rows
FROM menuca_v3.dishes
WHERE name_en = name_fr AND (name_en ILIKE '%with %' OR name_en ILIKE '% and %')
UNION ALL
SELECT 'Numbered items', COUNT(DISTINCT name_en), COUNT(*)
FROM menuca_v3.dishes
WHERE name_en = name_fr AND name_en ~ '^\d+\.'
UNION ALL
SELECT 'Contains French accents', COUNT(DISTINCT name_en), COUNT(*)
FROM menuca_v3.dishes
WHERE name_en = name_fr AND name_en ~ '[àâéèêïîôùûçÀÂÉÈÊÏÎÔÙÛÇ]'
UNION ALL
SELECT 'Simple/Brand names', COUNT(DISTINCT name_en), COUNT(*)
FROM menuca_v3.dishes
WHERE name_en = name_fr 
  AND name_en NOT ILIKE '%with %' 
  AND name_en NOT ILIKE '% and %'
  AND name_en !~ '^\d+\.'
  AND name_en !~ '[àâéèêïîôùûçÀÂÉÈÊÏÎÔÙÛÇ]'
ORDER BY total_rows DESC;

