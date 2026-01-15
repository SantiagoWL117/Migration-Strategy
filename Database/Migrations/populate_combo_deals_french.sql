-- SQL Migration: Populate French translations for combo deals
-- Source: gap_combo_deals.csv
-- Date: 2026-01-12

BEGIN;

-- 1. Create a temporary staging table
CREATE TEMPORARY TABLE combo_deals_staging (
    name_en TEXT,
    name_fr TEXT
);

-- 2. Import the CSV data
\copy combo_deals_staging (name_en, name_fr) FROM 'temp_import.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

-- 3. Log loaded translations
SELECT 'Loaded translations:' AS status, COUNT(*) AS count FROM combo_deals_staging;

-- 4. Clean up empty/null entries
DELETE FROM combo_deals_staging
WHERE name_en IS NULL OR TRIM(name_en) = ''
   OR name_fr IS NULL OR TRIM(name_fr) = '';

SELECT 'After cleanup:' AS status, COUNT(*) AS count FROM combo_deals_staging;

-- 5. Update dishes table
UPDATE menuca_v3.dishes d
SET name_fr = s.name_fr,
    updated_at = NOW()
FROM combo_deals_staging s
WHERE d.name_en = s.name_en
  AND d.name_fr IS NULL
  AND s.name_fr IS NOT NULL
  AND TRIM(s.name_fr) != '';

-- 6. Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- 7. Drop staging table
DROP TABLE combo_deals_staging;

-- 8. Final verification
SELECT 
    'FINAL STATUS' AS status,
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

COMMIT;

SELECT 'Migration completed!' AS status;

