-- ================================================================
-- Menu & Catalog Entity - Source Table Row Counts
-- Purpose: Get row counts from all V1 and V2 source tables
-- Date: January 7, 2025
-- ================================================================

-- ================================================================
-- SECTION 1: V1 TABLES (menuca_v1 schema)
-- ================================================================

SELECT 
    'menuca_v1' AS schema_name,
    'courses' AS table_name,
    COUNT(*) AS row_count,
    'Menu categories/sections' AS description
FROM menuca_v1.courses

UNION ALL

SELECT 
    'menuca_v1',
    'menu',
    COUNT(*),
    'Dishes (main menu items)'
FROM menuca_v1.menu

UNION ALL

SELECT 
    'menuca_v1',
    'menuothers',
    COUNT(*),
    'Side dishes, extras, drinks (with BLOB pricing)'
FROM menuca_v1.menuothers

UNION ALL

SELECT 
    'menuca_v1',
    'ingredients',
    COUNT(*),
    'Individual ingredients/toppings'
FROM menuca_v1.ingredients

UNION ALL

SELECT 
    'menuca_v1',
    'ingredient_groups',
    COUNT(*),
    'Ingredient groupings (with BLOB item lists)'
FROM menuca_v1.ingredient_groups

UNION ALL

SELECT 
    'menuca_v1',
    'combo_groups',
    COUNT(*),
    'Combo meal configurations (with BLOB options)'
FROM menuca_v1.combo_groups

UNION ALL

SELECT 
    'menuca_v1',
    'combos',
    COUNT(*),
    'Combo meal items (junction table)'
FROM menuca_v1.combos

-- ================================================================
-- SECTION 2: V2 TABLES (menuca_v2 schema)
-- ================================================================
-- NOTE: menuca_v2.courses and menuca_v2.menu excluded (deprecated/not used)
-- ================================================================

UNION ALL

SELECT 
    'menuca_v2',
    'global_courses',
    COUNT(*),
    'Global/shared course templates'
FROM menuca_v2.global_courses

UNION ALL

SELECT 
    'menuca_v2',
    'global_ingredients',
    COUNT(*),
    'Global/shared ingredient templates'
FROM menuca_v2.global_ingredients

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_courses',
    COUNT(*),
    'Restaurant-specific courses'
FROM menuca_v2.restaurants_courses

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_dishes',
    COUNT(*),
    'Restaurant dishes (with JSON pricing)'
FROM menuca_v2.restaurants_dishes

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_dishes_customization',
    COUNT(*),
    'Dish customization options (JSON configs)'
FROM menuca_v2.restaurants_dishes_customization

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_combo_groups',
    COUNT(*),
    'Combo meal groups'
FROM menuca_v2.restaurants_combo_groups

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_combo_groups_items',
    COUNT(*),
    'Combo group items/dishes'
FROM menuca_v2.restaurants_combo_groups_items

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_ingredient_groups',
    COUNT(*),
    'Ingredient groups (with BLOB items)'
FROM menuca_v2.restaurants_ingredient_groups

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_ingredient_groups_items',
    COUNT(*),
    'Ingredient group items (junction table)'
FROM menuca_v2.restaurants_ingredient_groups_items

UNION ALL

SELECT 
    'menuca_v2',
    'restaurants_ingredients',
    COUNT(*),
    'Restaurant-specific ingredients'
FROM menuca_v2.restaurants_ingredients

-- ================================================================
-- ORDER BY: Schema first, then table name
-- ================================================================
ORDER BY 
    CASE schema_name 
        WHEN 'menuca_v1' THEN 1 
        WHEN 'menuca_v2' THEN 2 
    END,
    table_name;

-- ================================================================
-- EXPECTED OUTPUT FORMAT:
-- ================================================================
-- +-------------+----------------------------------+-----------+------------------------------------------+
-- | schema_name | table_name                       | row_count | description                              |
-- +-------------+----------------------------------+-----------+------------------------------------------+
-- | menuca_v1   | combo_groups                     |     62353 | Combo meal configurations (with BLOB)    |
-- | menuca_v1   | combos                           |     16461 | Combo meal items (junction table)        |
-- | menuca_v1   | courses                          |     12924 | Menu categories/sections                 |
-- | menuca_v1   | ingredient_groups                |     13255 | Ingredient groupings (with BLOB)         |
-- | menuca_v1   | ingredients                      |     52305 | Individual ingredients/toppings          |
-- | menuca_v1   | menu                             |    117704 | Dishes (main menu items)                 |
-- | menuca_v1   | menuothers                       |     70381 | Side dishes, extras (with BLOB pricing)  |
-- | menuca_v2   | global_courses                   |        33 | Global/shared course templates           |
-- | menuca_v2   | global_ingredients               |      5023 | Global/shared ingredient templates       |
-- | menuca_v2   | restaurants_combo_groups         |        13 | Combo meal groups                        |
-- | menuca_v2   | restaurants_combo_groups_items   |       220 | Combo group items/dishes                 |
-- | menuca_v2   | restaurants_courses              |      1269 | Restaurant-specific courses              |
-- | menuca_v2   | restaurants_dishes               |     10289 | Restaurant dishes (with JSON pricing)    |
-- | menuca_v2   | restaurants_dishes_customization |     13412 | Dish customization options (JSON)        |
-- | menuca_v2   | restaurants_ingredient_groups    |       588 | Ingredient groups (with BLOB items)      |
-- | menuca_v2   | restaurants_ingredient_groups... |      3108 | Ingredient group items (junction table)  |
-- | menuca_v2   | restaurants_ingredients          |      2681 | Restaurant-specific ingredients          |
-- +-------------+----------------------------------+-----------+------------------------------------------+
-- 17 rows in set (menuca_v2.courses and menuca_v2.menu excluded)
-- ================================================================

-- ================================================================
-- ALTERNATIVE: Summary by Schema
-- ================================================================

-- Uncomment to get summary totals by schema:
/*
SELECT 
    schema_name,
    COUNT(*) AS table_count,
    SUM(row_count) AS total_rows
FROM (
    -- Include all UNION ALL queries from above
    ...
) AS source_counts
GROUP BY schema_name
ORDER BY schema_name;
*/

-- ================================================================
-- NOTES:
-- ================================================================
-- 1. This query assumes both menuca_v1 and menuca_v2 databases exist
-- 2. BLOB columns are noted but not counted separately
-- 3. Run this query from any database context (cross-schema query)
-- 4. Expected total: ~380,655 rows across 17 tables (excludes v2.courses and v2.menu)
-- 5. EXCLUDED: menuca_v2.courses (1,269 rows) - deprecated, not used in production
-- 6. EXCLUDED: menuca_v2.menu (95 rows) - deprecated, not used in production
-- ================================================================

