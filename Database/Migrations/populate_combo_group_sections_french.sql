-- SQL Migration: Populate combo_group_sections.use_header_fr with French translations
-- Date: 2026-01-12
-- Source: Database/Exports/translations/translated_combo_group_sections.csv (198 translations)

BEGIN;

-- Create a temporary staging table
CREATE TEMPORARY TABLE combo_group_section_translations_staging (
    use_header_en VARCHAR(255),
    use_header_fr VARCHAR(255)
);

-- Load data from the CSV file into the staging table
\copy combo_group_section_translations_staging (use_header_en, use_header_fr) FROM 'C:/Users/santi/Menu.ca/Legacy Database/Migration Strategy/Database/Exports/translations/translated_combo_group_sections_fixed.csv' WITH (FORMAT CSV, HEADER true, ENCODING 'UTF8');

-- Show statistics
SELECT 'Translations loaded:' AS status, COUNT(*) AS count FROM combo_group_section_translations_staging;

-- Clean up staging table: Remove entries where use_header_en or use_header_fr is NULL or empty
DELETE FROM combo_group_section_translations_staging
WHERE use_header_en IS NULL OR TRIM(use_header_en) = ''
   OR use_header_fr IS NULL OR TRIM(use_header_fr) = '';

SELECT 'After cleanup:' AS status, COUNT(*) AS count FROM combo_group_section_translations_staging;

-- Remove duplicates, keeping first occurrence
DELETE FROM combo_group_section_translations_staging a
USING combo_group_section_translations_staging b
WHERE a.ctid < b.ctid
  AND a.use_header_en = b.use_header_en;

SELECT 'After deduplication:' AS status, COUNT(*) AS count FROM combo_group_section_translations_staging;

-- Check how many will match
SELECT 'Combo group sections to be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_group_sections cgs
JOIN combo_group_section_translations_staging ts ON cgs.use_header_en = ts.use_header_en
WHERE cgs.use_header_fr IS NULL OR TRIM(cgs.use_header_fr) = '';

-- Update the combo_group_sections table with French translations
UPDATE menuca_v3.combo_group_sections cgs
SET use_header_fr = ts.use_header_fr
FROM combo_group_section_translations_staging ts
WHERE cgs.use_header_en = ts.use_header_en
  AND (cgs.use_header_fr IS NULL OR TRIM(cgs.use_header_fr) = '')
  AND ts.use_header_fr IS NOT NULL
  AND TRIM(ts.use_header_fr) != '';

-- Show results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_group_sections cgs
JOIN combo_group_section_translations_staging ts ON cgs.use_header_en = ts.use_header_en
WHERE cgs.use_header_fr = ts.use_header_fr;

-- Final statistics
SELECT 'Final status - Total combo group sections:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_group_sections;

SELECT 'Final status - With translations:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_group_sections
WHERE use_header_fr IS NOT NULL AND TRIM(use_header_fr) != '';

SELECT 'Final status - Missing translations:' AS status, COUNT(*) AS count
FROM menuca_v3.combo_group_sections
WHERE use_header_fr IS NULL OR TRIM(use_header_fr) = '';

-- Calculate percentage
SELECT 
    'Completion rate:' AS status,
    ROUND(100.0 * COUNT(*) FILTER (WHERE use_header_fr IS NOT NULL AND TRIM(use_header_fr) != '') / COUNT(*), 2) || '%' AS percentage
FROM menuca_v3.combo_group_sections;

-- Sample updated records
SELECT 'Sample updated records:' AS status;
SELECT use_header_en, use_header_fr
FROM menuca_v3.combo_group_sections
WHERE use_header_fr IS NOT NULL AND TRIM(use_header_fr) != ''
ORDER BY id DESC
LIMIT 10;

-- Drop the temporary staging table
DROP TABLE combo_group_section_translations_staging;

COMMIT;

SELECT 'Migration completed!' AS status;
