-- Fix v1_ingredients Column Mapping Issue
-- 
-- Problem: Data was loaded with wrong column order
-- MySQL: (id, restaurant, availableFor, name, price, lang, type, order)
-- Loaded as: (id, restaurant_id, name, price, language, type, display_order, available_for)
--
-- Solution: Remap the data to correct columns

BEGIN;

-- Step 1: Create a backup
CREATE TABLE IF NOT EXISTS staging.v1_ingredients_premapping_backup AS 
SELECT * FROM staging.v1_ingredients;

-- Step 2: Create temp table with correct mapping
CREATE TEMP TABLE v1_ingredients_corrected AS
SELECT 
    id,
    restaurant_id,
    name AS available_for_value,           -- Column 3 from load = availableFor from MySQL
    price AS actual_name,                   -- Column 4 from load = name from MySQL
    language AS actual_price,               -- Column 5 from load = price from MySQL
    type AS actual_language,                -- Column 6 from load = lang from MySQL
    display_order AS actual_type,           -- Column 7 from load = type from MySQL
    available_for AS actual_display_order   -- Column 8 from load = order from MySQL
FROM staging.v1_ingredients;

-- Step 3: Clear the staging table
TRUNCATE TABLE staging.v1_ingredients;

-- Step 4: Reload with correct mapping
INSERT INTO staging.v1_ingredients (
    id,
    restaurant_id,
    available_for,
    name,
    price,
    language,
    type,
    display_order
)
SELECT 
    id,
    restaurant_id,
    available_for_value,
    actual_name,
    actual_price,
    actual_language,
    actual_type,
    actual_display_order
FROM v1_ingredients_corrected;

-- Step 5: Verification
SELECT 
    'Before Fix' as status,
    COUNT(*) as total_rows,
    COUNT(DISTINCT actual_name) as unique_names
FROM v1_ingredients_corrected
UNION ALL
SELECT 
    'After Fix' as status,
    COUNT(*) as total_rows,
    COUNT(DISTINCT name) as unique_names  
FROM staging.v1_ingredients;

-- Step 6: Sample data check
SELECT 
    id,
    restaurant_id,
    name,
    price,
    language,
    type,
    display_order,
    available_for
FROM staging.v1_ingredients
WHERE name IS NOT NULL
  AND name != ''
  AND name != '0'
ORDER BY id
LIMIT 20;

COMMIT;

