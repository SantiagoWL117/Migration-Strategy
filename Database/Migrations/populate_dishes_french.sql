-- ============================================================================
-- Populate dishes.name_fr from translated_dishes.csv
-- ============================================================================
-- 
-- Purpose: Load French translations from CSV and update dishes table
-- 
-- Current State:
--   - Total dishes: 24,069
--   - Has name_fr: 10,536 (43.8%)
--   - Needs name_fr: 13,533 (56.2%)
--   - CSV translations available: 6,979
--
-- Expected Outcome: Up to 6,979 additional dishes receive French translations
--
-- Usage:
--   1. Copy translated_dishes.csv to a location accessible by psql
--   2. Update the \copy path below to point to the CSV file
--   3. Run: psql -h <host> -U <user> -d <database> -f populate_dishes_french.sql
--
-- ============================================================================

BEGIN;

-- ============================================================================
-- Step 1: Create Staging Table
-- ============================================================================

CREATE TEMP TABLE dish_translations_staging (
    name_en TEXT,
    name_fr TEXT
);

-- ============================================================================
-- Step 2: Load CSV Data
-- ============================================================================
-- NOTE: Update the path below to the actual location of translated_dishes.csv
-- The path must be accessible from the psql client machine

\copy dish_translations_staging(name_en, name_fr) FROM 'translated_dishes.csv' WITH (FORMAT csv, HEADER true);

-- Show loaded count
SELECT 'Loaded translations:' AS status, COUNT(*) AS count FROM dish_translations_staging;

-- ============================================================================
-- Step 3: Clean Staging Data
-- ============================================================================

-- Remove leading/trailing whitespace and quotes from both columns
UPDATE dish_translations_staging
SET name_en = TRIM(BOTH '"' FROM TRIM(name_en)),
    name_fr = TRIM(BOTH '"' FROM TRIM(name_fr));

-- Remove empty rows
DELETE FROM dish_translations_staging 
WHERE name_en IS NULL OR name_en = '' OR name_fr IS NULL OR name_fr = '';

-- Remove duplicates, keeping first occurrence
DELETE FROM dish_translations_staging a
USING dish_translations_staging b
WHERE a.ctid > b.ctid AND a.name_en = b.name_en;

-- Show cleaned count
SELECT 'After cleanup:' AS status, COUNT(*) AS count FROM dish_translations_staging;

-- ============================================================================
-- Step 4: Preview Matches (before update)
-- ============================================================================

-- Current state
SELECT 'BEFORE UPDATE - Dishes Status:' AS status;
SELECT 
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

-- Count matches for dishes needing French
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN dish_translations_staging t ON d.name_en = t.name_en
WHERE d.name_fr IS NULL;

-- ============================================================================
-- Step 5: Apply Translations
-- ============================================================================

UPDATE menuca_v3.dishes d
SET name_fr = t.name_fr,
    updated_at = NOW()
FROM dish_translations_staging t
WHERE d.name_en = t.name_en
  AND d.name_fr IS NULL;

-- Report rows updated
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN dish_translations_staging t ON d.name_en = t.name_en
WHERE d.name_fr = t.name_fr;

-- ============================================================================
-- Step 6: Verify Results
-- ============================================================================

SELECT 'AFTER UPDATE - Dishes Status:' AS status;
SELECT 
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

-- Show sample of updated dishes
SELECT 'Sample updated dishes:' AS status;
SELECT d.id, d.name_en, d.name_fr, d.updated_at
FROM menuca_v3.dishes d
WHERE d.updated_at >= NOW() - INTERVAL '1 minute'
ORDER BY d.id
LIMIT 10;

-- ============================================================================
-- Commit or Rollback
-- ============================================================================
-- Review the results above. If satisfied, keep COMMIT. 
-- If there are issues, change to ROLLBACK.

COMMIT;

-- ============================================================================
-- Cleanup (temp table auto-dropped at end of session)
-- ============================================================================

SELECT 'Migration completed successfully!' AS status;

