-- ============================================================================
-- FIX MISSING DISH_SIZE_VARIANT MAPPINGS
-- ============================================================================
-- Date: 2026-01-22
-- Purpose: Map dish_prices with NULL dish_size_variant_id to correct variants
-- Records Affected: ~290 (true size variants only)
-- 
-- ALREADY FIXED: Protein variants (14) → mapped to Standard (1)
-- ============================================================================

-- ============================================================================
-- SUMMARY OF MAPPINGS
-- ============================================================================
-- 
-- | Missing size_variant     | Count | Map To                    | Reason           |
-- |--------------------------|-------|---------------------------|------------------|
-- | X-Large (17")            | 22    | 5 (x-large)               | X-Large tier     |
-- | X-Large(18")             | 18    | 27 (18-inch)              | 18" dimension    |
-- | XLarge 17"               | 15    | 5 (x-large)               | X-Large tier     |
-- | Extra Large              | 18    | 5 (x-large)               | X-Large tier     |
-- | Extra Grosse             | 5     | 5 (x-large)               | X-Large French   |
-- | Large(15")               | 18    | 25 (large-15)             | Large 15"        |
-- | Large 15"                | 15    | 25 (large-15)             | Large 15"        |
-- | Grande(15")              | 7     | 25 (large-15)             | Large 15" French |
-- | Large 12"                | 22    | 4 (large)                 | Large (GF menu)  |
-- | Grosse                   | 7     | 4 (large)                 | Large French     |
-- | Large Size Gluten Free   | 11    | 4 (large)                 | Large            |
-- | Medium(12")              | 18    | 21 (medium-12)            | Medium 12"       |
-- | Medium 12"               | 15    | 21 (medium-12)            | Medium 12"       |
-- | Moyen                    | 14    | 3 (medium)                | Medium French    |
-- | Moyenne(12")             | 7     | 21 (medium-12)            | Medium 12" Fr    |
-- | Small(9")                | 18    | 19 (small-9)              | Small 9"         |
-- | Small 9"                 | 15    | 19 (small-9)              | Small 9"         |
-- | Small 10"                | 22    | 2 (small)                 | Small (GF menu)  |
-- | Small (10")              | 19    | 2 (small)                 | Small 10"        |
-- | Small Size Gluten Free   | 11    | 2 (small)                 | Small            |
-- | Smalll                   | 1     | 2 (small)                 | Typo             |
-- | Small x 2                | 12    | 28 (2x-small)             | Combo            |
-- | Medium x 2               | 12    | 29 (2x-medium)            | Combo            |
-- | Large x 2                | 12    | 30 (2x-large)             | Combo            |
-- | 2x Small(9")             | 3     | 28 (2x-small)             | Combo            |
-- | 2x Medium(12")           | 3     | 29 (2x-medium)            | Combo            |
-- | 2x Large(15")            | 3     | 30 (2x-large)             | Combo            |
-- | 2 x Small (9")           | 3     | 28 (2x-small)             | Combo            |
-- | 2 x Medium (12")         | 3     | 29 (2x-medium)            | Combo            |
-- | 2 x Large (15")          | 3     | 30 (2x-large)             | Combo            |
-- 
-- SKIPPED (not food sizes, no modifier matching needed):
-- | Large Rolls              | 30    | SKIP - Sushi rolls        |
-- | Large Sandwich           | 5     | SKIP - Sandwich portion   |
-- | Small Sandwich           | 5     | SKIP - Sandwich portion   |
-- | Small (2 rolls)          | 3     | SKIP - Spring roll count  |
-- | Small Box                | 2     | SKIP - Package            |
-- | Small (6)                | 2     | SKIP - Quantity pack      |
-- | Medium (12)              | 2     | SKIP - Quantity pack      |
-- | Large (24)               | 2     | SKIP - Quantity pack      |
-- | Medium Sauce             | 2     | SKIP - Sauce portion      |
-- | Petite Ail               | 1     | SKIP - Garlic sauce       |
-- | Grande Ail               | 1     | SKIP - Garlic sauce       |
-- | Petite Boîte 120g        | 1     | SKIP - Box weight         |
-- | Grande Boîte 225g        | 1     | SKIP - Box weight         |
-- | Petit avec boulettes     | 1     | SKIP - Combo description  |
-- | Large Pack               | 1     | SKIP - Package            |
-- | Small Pack               | 1     | SKIP - Package            |
-- | Small Chili              | 1     | SKIP - Bowl size          |
-- | Grandes                  | 1     | SKIP - Unclear (fries?)   |
-- | Petites                  | 1     | SKIP - Unclear (fries?)   |
-- | Small.Large              | 1     | SKIP - Data error         |
-- ============================================================================

BEGIN;

-- ============================================================================
-- X-LARGE TIER (modifier_size_variant_id = 5)
-- ============================================================================

-- X-Large (17") → x-large (id: 5)
-- Restaurants: Mr Mozzarella - Nepean, Papa Joe's Pizza - Downtown
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 5
WHERE size_variant = 'X-Large (17")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 22 rows

-- X-Large(18") → 18-inch (id: 27)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 27
WHERE size_variant = 'X-Large(18")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 18 rows

-- XLarge 17" → x-large (id: 5)
-- Restaurant: River Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 5
WHERE size_variant = 'XLarge 17"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 15 rows

-- Extra Large → x-large (id: 5)
-- Restaurant: Imilio's Pizzeria
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 5
WHERE size_variant = 'Extra Large'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 18 rows

-- Extra Grosse → x-large (id: 5)
-- Restaurant: Patate Lou Lou
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 5
WHERE size_variant = 'Extra Grosse'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 5 rows

-- ============================================================================
-- LARGE TIER (modifier_size_variant_id = 4)
-- ============================================================================

-- Large(15") → large-15 (id: 25)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 25
WHERE size_variant = 'Large(15")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 18 rows

-- Large 15" → large-15 (id: 25)
-- Restaurant: River Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 25
WHERE size_variant = 'Large 15"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 15 rows

-- Grande(15") → large-15 (id: 25)
-- Restaurant: Econo Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 25
WHERE size_variant = 'Grande(15")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 7 rows

-- Large 12" → large (id: 4) - Colonnade Gluten Free menu
-- Note: 12" is their "Large" for gluten-free pizzas (only 2 sizes: 10"/12")
-- Restaurant: Colonnade Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 4
WHERE size_variant = 'Large 12"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 22 rows

-- Grosse → large (id: 4)
-- Restaurant: Patate Lou Lou
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 4
WHERE size_variant = 'Grosse'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 7 rows

-- Large Size Gluten Free → large (id: 4)
-- Restaurant: Colonnade Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 4
WHERE size_variant = 'Large Size Gluten Free'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 11 rows

-- ============================================================================
-- MEDIUM TIER (modifier_size_variant_id = 3)
-- ============================================================================

-- Medium(12") → medium-12 (id: 21)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 21
WHERE size_variant = 'Medium(12")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 18 rows

-- Medium 12" → medium-12 (id: 21)
-- Restaurant: River Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 21
WHERE size_variant = 'Medium 12"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 15 rows

-- Moyen → medium (id: 3)
-- Restaurant: Greber Pizza et Shawarma
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 3
WHERE size_variant = 'Moyen'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 14 rows

-- Moyenne(12") → medium-12 (id: 21)
-- Restaurant: Econo Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 21
WHERE size_variant = 'Moyenne(12")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 7 rows

-- ============================================================================
-- SMALL TIER (modifier_size_variant_id = 2)
-- ============================================================================

-- Small(9") → small-9 (id: 19)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 19
WHERE size_variant = 'Small(9")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 18 rows

-- Small 9" → small-9 (id: 19)
-- Restaurant: River Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 19
WHERE size_variant = 'Small 9"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 15 rows

-- Small 10" → small (id: 2) - Colonnade Gluten Free menu
-- Restaurant: Colonnade Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 2
WHERE size_variant = 'Small 10"'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 22 rows

-- Small (10") → small (id: 2)
-- Restaurants: Capital Bites, Mr Mozzarella - Nepean
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 2
WHERE size_variant = 'Small (10")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 19 rows

-- Small Size Gluten Free → small (id: 2)
-- Restaurant: Colonnade Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 2
WHERE size_variant = 'Small Size Gluten Free'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 11 rows

-- Smalll → small (id: 2) - Typo
-- Restaurant: Kiki Lebanese Pineview Pizza
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 2
WHERE size_variant = 'Smalll'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 1 row

-- ============================================================================
-- COMBO TIERS (2x sizes)
-- ============================================================================

-- Small x 2 → 2x-small (id: 28)
-- Restaurant: Milano
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 28
WHERE size_variant = 'Small x 2'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 12 rows

-- Medium x 2 → 2x-medium (id: 29)
-- Restaurant: Milano
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 29
WHERE size_variant = 'Medium x 2'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 12 rows

-- Large x 2 → 2x-large (id: 30)
-- Restaurant: Milano
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 30
WHERE size_variant = 'Large x 2'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 12 rows

-- 2x Small(9") → 2x-small (id: 28)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 28
WHERE size_variant = '2x Small(9")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- 2x Medium(12") → 2x-medium (id: 29)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 29
WHERE size_variant = '2x Medium(12")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- 2x Large(15") → 2x-large (id: 30)
-- Restaurant: Mama Rosa
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 30
WHERE size_variant = '2x Large(15")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- 2 x Small (9") → 2x-small (id: 28)
-- Restaurant: Papa Joe's Pizza - Downtown
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 28
WHERE size_variant = '2 x Small (9")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- 2 x Medium (12") → 2x-medium (id: 29)
-- Restaurant: Papa Joe's Pizza - Downtown
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 29
WHERE size_variant = '2 x Medium (12")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- 2 x Large (15") → 2x-large (id: 30)
-- Restaurant: Papa Joe's Pizza - Downtown
UPDATE menuca_v3.dish_prices
SET dish_size_variant_id = 30
WHERE size_variant = '2 x Large (15")'
AND dish_size_variant_id IS NULL
AND deleted_at IS NULL;
-- Expected: 3 rows

-- ============================================================================
-- VERIFICATION QUERY (run after COMMIT)
-- ============================================================================
-- 
-- SELECT 
--     CASE 
--         WHEN dish_size_variant_id IS NULL THEN 'STILL MISSING'
--         ELSE 'FIXED'
--     END AS status,
--     COUNT(*) AS count
-- FROM menuca_v3.dish_prices
-- WHERE deleted_at IS NULL
-- AND size_variant IN (
--     'X-Large (17")', 'X-Large(18")', 'XLarge 17"', 'Extra Large', 'Extra Grosse',
--     'Large(15")', 'Large 15"', 'Grande(15")', 'Large 12"', 'Grosse', 'Large Size Gluten Free',
--     'Medium(12")', 'Medium 12"', 'Moyen', 'Moyenne(12")',
--     'Small(9")', 'Small 9"', 'Small 10"', 'Small (10")', 'Small Size Gluten Free', 'Smalll',
--     'Small x 2', 'Medium x 2', 'Large x 2',
--     '2x Small(9")', '2x Medium(12")', '2x Large(15")',
--     '2 x Small (9")', '2 x Medium (12")', '2 x Large (15")'
-- )
-- GROUP BY status;

COMMIT;

-- ============================================================================
-- POST-FIX: Rebuild menu caches for affected restaurants
-- ============================================================================
-- 
-- SELECT menuca_v3.rebuild_menu_cache(restaurant_id)
-- FROM (
--     SELECT DISTINCT d.restaurant_id
--     FROM menuca_v3.dish_prices dp
--     JOIN menuca_v3.dishes d ON d.id = dp.dish_id
--     WHERE dp.size_variant IN (
--         'X-Large (17")', 'X-Large(18")', 'XLarge 17"', 'Extra Large', 'Extra Grosse',
--         'Large(15")', 'Large 15"', 'Grande(15")', 'Large 12"', 'Grosse', 'Large Size Gluten Free',
--         'Medium(12")', 'Medium 12"', 'Moyen', 'Moyenne(12")',
--         'Small(9")', 'Small 9"', 'Small 10"', 'Small (10")', 'Small Size Gluten Free', 'Smalll',
--         'Small x 2', 'Medium x 2', 'Large x 2',
--         '2x Small(9")', '2x Medium(12")', '2x Large(15")',
--         '2 x Small (9")', '2 x Medium (12")', '2 x Large (15")'
--     )
-- ) AS affected;
-- 
-- Affected restaurants:
-- - Imilio's Pizzeria (7)
-- - Mama Rosa (12)
-- - Papa Joe's Pizza - Downtown (13)
-- - Mr Mozzarella - Nepean (47)
-- - Patate Lou Lou (712)
-- - River Pizza (952)
-- - Greber Pizza et Shawarma (736)
-- - Econo Pizza (1009)
-- - Colonnade Pizza (783, 784, 785)
-- - Capital Bites (973)
-- - Milano (multiple locations)
-- - Kiki Lebanese Pineview Pizza (44)
