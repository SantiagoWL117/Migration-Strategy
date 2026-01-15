-- SQL Migration: Populate modifier_groups.name_fr with French translations
-- Date: 2026-01-12
-- Source: Database/Exports/translations/translated_modifier_groups.csv (813 translations)

BEGIN;

-- Create a temporary staging table
CREATE TEMPORARY TABLE modifier_group_translations_staging (
    name_en VARCHAR(255),
    name_fr VARCHAR(255)
);

-- Load data from the CSV file into the staging table
\copy modifier_group_translations_staging (name_en, name_fr) FROM 'C:/Users/santi/Menu.ca/Legacy Database/Migration Strategy/Database/Exports/translations/translated_modifier_groups.csv' WITH (FORMAT CSV, HEADER true, ENCODING 'UTF8');

-- Show statistics
SELECT 'Translations loaded:' AS status, COUNT(*) AS count FROM modifier_group_translations_staging;

-- Clean up staging table: Remove entries where name_en or name_fr is NULL or empty
DELETE FROM modifier_group_translations_staging
WHERE name_en IS NULL OR TRIM(name_en) = ''
   OR name_fr IS NULL OR TRIM(name_fr) = '';

SELECT 'After cleanup:' AS status, COUNT(*) AS count FROM modifier_group_translations_staging;

-- Remove duplicates, keeping first occurrence
DELETE FROM modifier_group_translations_staging a
USING modifier_group_translations_staging b
WHERE a.ctid < b.ctid
  AND a.name_en = b.name_en;

SELECT 'After deduplication:' AS status, COUNT(*) AS count FROM modifier_group_translations_staging;

-- Check how many will match
SELECT 'Modifier groups to be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.modifier_groups mg
JOIN modifier_group_translations_staging ts ON mg.name_en = ts.name_en
WHERE mg.name_fr IS NULL OR TRIM(mg.name_fr) = '';

-- Update the modifier_groups table with French translations
UPDATE menuca_v3.modifier_groups mg
SET name_fr = ts.name_fr,
    updated_at = NOW()
FROM modifier_group_translations_staging ts
WHERE mg.name_en = ts.name_en
  AND (mg.name_fr IS NULL OR TRIM(mg.name_fr) = '')
  AND ts.name_fr IS NOT NULL
  AND TRIM(ts.name_fr) != '';

-- Show results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.modifier_groups
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Final statistics
SELECT 'Final status - Total modifier groups:' AS status, COUNT(*) AS count
FROM menuca_v3.modifier_groups;

SELECT 'Final status - With translations:' AS status, COUNT(*) AS count
FROM menuca_v3.modifier_groups
WHERE name_fr IS NOT NULL AND TRIM(name_fr) != '';

SELECT 'Final status - Missing translations:' AS status, COUNT(*) AS count
FROM menuca_v3.modifier_groups
WHERE name_fr IS NULL OR TRIM(name_fr) = '';

-- Sample updated records
SELECT 'Sample updated records:' AS status;
SELECT name_en, name_fr
FROM menuca_v3.modifier_groups
WHERE updated_at >= NOW() - INTERVAL '1 minute'
LIMIT 10;

-- Drop the temporary staging table
DROP TABLE modifier_group_translations_staging;

COMMIT;

SELECT 'Migration completed!' AS status;
