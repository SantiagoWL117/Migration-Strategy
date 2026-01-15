-- SQL Migration: Populate combo_groups.name_fr with French translations
-- Date: 2026-01-12
-- Source: Database/Exports/translations/translated_combo_groups.csv (948 translations)

BEGIN;

-- Create a temporary staging table
CREATE TEMPORARY TABLE combo_group_translations_staging (
    name_en VARCHAR(255),
    name_fr VARCHAR(255)
);

-- Load data from the CSV file into the staging table
\copy combo_group_translations_staging (name_en, name_fr) FROM 'C:/Users/santi/Menu.ca/Legacy Database/Migration Strategy/Database/Exports/translations/translated_combo_groups_fixed.csv' WITH (FORMAT CSV, HEADER true, ENCODING 'UTF8');

-- Show statistics
SELECT 'Translations loaded:' AS status, COUNT(*) AS count FROM combo_group_translations_staging;

-- Clean up staging table: Remove entries where name_en or name_fr is NULL or empty
DELETE FROM combo_group_translations_staging
WHERE name_en IS NULL OR TRIM(name_en) = ''
   OR name_fr IS NULL OR TRIM(name_fr) = '';

SELECT 'After cleanup:' AS status, COUNT(*) AS count FROM combo_group_translations_staging;

-- Remove duplicates, keeping first occurrence
DELETE FROM combo_group_translations_staging a
USING combo_group_translations_staging b
WHERE a.ctid < b.ctid
  AND a.name_en = b.name_en;

SELECT 'After deduplication:' AS status, COUNT(*) AS count FROM combo_group_translations_staging;

-- Check how many will match
SELECT 'Combo groups to be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_groups cg
JOIN combo_group_translations_staging ts ON cg.name_en = ts.name_en
WHERE cg.name_fr IS NULL OR TRIM(cg.name_fr) = '';

-- Update the combo_groups table with French translations
UPDATE menuca_v3.combo_groups cg
SET name_fr = ts.name_fr,
    updated_at = NOW()
FROM combo_group_translations_staging ts
WHERE cg.name_en = ts.name_en
  AND (cg.name_fr IS NULL OR TRIM(cg.name_fr) = '')
  AND ts.name_fr IS NOT NULL
  AND TRIM(ts.name_fr) != '';

-- Show results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_groups
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Final statistics
SELECT 'Final status - Total combo groups:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_groups;

SELECT 'Final status - With translations:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_groups
WHERE name_fr IS NOT NULL AND TRIM(name_fr) != '';

SELECT 'Final status - Missing translations:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_groups
WHERE name_fr IS NULL OR TRIM(name_fr) = '';

-- Calculate percentage
SELECT 
    'Completion rate:' AS status,
    ROUND(100.0 * COUNT(*) FILTER (WHERE name_fr IS NOT NULL AND TRIM(name_fr) != '') / COUNT(*), 2) || '%' AS percentage
FROM menuca_v3.combo_groups;

-- Sample updated records
SELECT 'Sample updated records:' AS status;
SELECT name_en, name_fr
FROM menuca_v3.combo_groups
WHERE updated_at >= NOW() - INTERVAL '1 minute'
LIMIT 10;

-- Drop the temporary staging table
DROP TABLE combo_group_translations_staging;

COMMIT;

SELECT 'Migration completed!' AS status;
