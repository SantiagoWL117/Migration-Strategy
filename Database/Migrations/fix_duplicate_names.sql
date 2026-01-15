-- SQL Migration: Fix dishes where name_en = name_fr with English phrases
-- These need proper French translations
-- Date: 2026-01-12

BEGIN;

-- Create staging table
CREATE TEMPORARY TABLE duplicate_fixes (
    current_name TEXT,
    new_name_fr TEXT
);

-- Import the CSV data
\copy duplicate_fixes (current_name, new_name_fr) FROM 'temp_import.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

-- Show what we're about to update
SELECT 'Fixes to apply:' AS status, COUNT(*) AS count FROM duplicate_fixes;

-- Check how many will match
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN duplicate_fixes f ON d.name_en = f.current_name
WHERE d.name_en = d.name_fr;

-- Update the dishes table (only where name_en = name_fr)
UPDATE menuca_v3.dishes d
SET 
    name_fr = f.new_name_fr,
    updated_at = NOW()
FROM duplicate_fixes f
WHERE d.name_en = f.current_name
  AND d.name_en = d.name_fr;

-- Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Drop staging table
DROP TABLE duplicate_fixes;

-- Final verification - check remaining duplicates with English phrases
SELECT 'Remaining English phrases:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE name_en = name_fr 
  AND (name_en ILIKE '%with %' OR name_en ILIKE '% and %');

-- Sample the updated records
SELECT 'Sample updated records:' AS status;
SELECT name_en, name_fr
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute'
LIMIT 10;

COMMIT;

SELECT 'Migration completed!' AS status;

