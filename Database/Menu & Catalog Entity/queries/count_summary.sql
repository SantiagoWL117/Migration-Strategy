-- ================================================================
-- Menu & Catalog - Quick Row Count Summary
-- Run this for a quick overview
-- ================================================================

-- SCHEMA TOTALS
SELECT 
    'SUMMARY' AS type,
    'menuca_v1' AS schema_name,
    7 AS table_count,
    (SELECT COUNT(*) FROM menuca_v1.courses) +
    (SELECT COUNT(*) FROM menuca_v1.menu) +
    (SELECT COUNT(*) FROM menuca_v1.menuothers) +
    (SELECT COUNT(*) FROM menuca_v1.ingredients) +
    (SELECT COUNT(*) FROM menuca_v1.ingredient_groups) +
    (SELECT COUNT(*) FROM menuca_v1.combo_groups) +
    (SELECT COUNT(*) FROM menuca_v1.combos) AS total_rows

UNION ALL

SELECT 
    'SUMMARY',
    'menuca_v2',
    12,
    (SELECT COUNT(*) FROM menuca_v2.courses) +
    (SELECT COUNT(*) FROM menuca_v2.global_courses) +
    (SELECT COUNT(*) FROM menuca_v2.global_ingredients) +
    (SELECT COUNT(*) FROM menuca_v2.menu) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_courses) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_dishes) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_dishes_customization) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_combo_groups) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_combo_groups_items) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredient_groups) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredient_groups_items) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredients)

UNION ALL

SELECT 
    'TOTAL',
    'BOTH SCHEMAS',
    19,
    (SELECT COUNT(*) FROM menuca_v1.courses) +
    (SELECT COUNT(*) FROM menuca_v1.menu) +
    (SELECT COUNT(*) FROM menuca_v1.menuothers) +
    (SELECT COUNT(*) FROM menuca_v1.ingredients) +
    (SELECT COUNT(*) FROM menuca_v1.ingredient_groups) +
    (SELECT COUNT(*) FROM menuca_v1.combo_groups) +
    (SELECT COUNT(*) FROM menuca_v1.combos) +
    (SELECT COUNT(*) FROM menuca_v2.courses) +
    (SELECT COUNT(*) FROM menuca_v2.global_courses) +
    (SELECT COUNT(*) FROM menuca_v2.global_ingredients) +
    (SELECT COUNT(*) FROM menuca_v2.menu) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_courses) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_dishes) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_dishes_customization) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_combo_groups) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_combo_groups_items) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredient_groups) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredient_groups_items) +
    (SELECT COUNT(*) FROM menuca_v2.restaurants_ingredients);

-- ================================================================
-- EXPECTED OUTPUT:
-- ================================================================
-- +---------+--------------+-------------+------------+
-- | type    | schema_name  | table_count | total_rows |
-- +---------+--------------+-------------+------------+
-- | SUMMARY | menuca_v1    |           7 |    345,383 |
-- | SUMMARY | menuca_v2    |          12 |     36,636 |
-- | TOTAL   | BOTH SCHEMAS |          19 |    382,019 |
-- +---------+--------------+-------------+------------+
-- ================================================================

