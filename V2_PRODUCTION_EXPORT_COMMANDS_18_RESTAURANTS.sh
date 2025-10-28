-- ========================================
-- V2 PRODUCTION EXPORT QUERIES FOR SQL WORKBENCH
-- FOR: Santiago (SQL Workbench User)
-- ========================================
-- 
-- CRITICAL: 18 restaurants are LIVE on menu.ca but missing dish data in V3
-- These SQL queries will export all necessary data for migration
--
-- Restaurant IDs that need data recovery:
-- 1635 - All Out Burger Gladstone
-- 1636 - All Out Burger Montreal Rd  
-- 1637 - Kirkwood Pizza
-- 1639 - River Pizza
-- 1641 - Wandee Thai
-- 1642 - La Nawab
-- 1654 - Cosenza
-- 1657 - Cuisine Bombay Indienne
-- 1658 - Chicco Shawarma Cantley
-- 1659 - Chicco Pizza & Shawarma Buckingham
-- 1664 - Chicco Pizza St-Louis
-- 1665 - Zait and Zaatar
-- 1668 - Little Gyros Greek Grill
-- 1673 - Pizza Marie
-- 1674 - Capri Pizza
-- 1676 - Routine Poutine
-- 1677 - Chef Rad Halal Pizza & Burgers
-- 1678 - Al-s Drive In
--
-- ========================================
-- INSTRUCTIONS FOR SQL WORKBENCH:
-- ========================================
-- 1. Connect to V2 Production Database (menuca_v2)
-- 2. Run each query below in order (Query 1 through Query 6)
-- 3. Export each result as CSV using SQL Workbench's export function
-- 4. Save files with the exact names shown
-- 5. Upload all 6 CSV files for import into V3 staging
-- ========================================

-- ========================================
-- QUERY 1: Export Restaurant Courses
-- Save as: v2_18_restaurants_courses.csv
-- ========================================

SELECT 
  id,
  restaurant_id,
  language_id,
  global_course_id,
  name,
  description,
  display_order,
  available_for,
  time_period,
  enabled,
  added_by,
  added_at,
  disabled_by,
  disabled_at
FROM restaurants_courses
WHERE restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY restaurant_id, display_order;

-- Expected: ~150-200 rows (14-16 courses per restaurant)


-- ========================================
-- QUERY 2: Export Restaurant Dishes (CRITICAL)
-- Save as: v2_18_restaurants_dishes.csv
-- ========================================

SELECT 
  rd.id,
  rd.global_dish_id,
  rd.course_id,
  rd.has_customization,
  rd.is_combo,
  rd.name,
  rd.description,
  rd.size,
  rd.size_j,
  rd.price,
  rd.price_j,
  rd.display_order,
  rd.dish_image,
  rd.upsell,
  rd.enabled,
  rd.added_by,
  rd.added_at,
  rd.disabled_by,
  rd.disabled_at,
  rd.unavailable_until,
  rd.unavailabled_by
FROM restaurants_dishes rd
JOIN restaurants_courses rc ON rc.id = rd.course_id
WHERE rc.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
  AND rd.enabled = 'y'
ORDER BY rc.restaurant_id, rd.course_id, rd.display_order;

-- Expected: ~1,500-2,500 rows (80-150 dishes per restaurant)


-- ========================================
-- QUERY 3: Export Ingredient Groups (Modifiers)
-- Save as: v2_18_ingredient_groups.csv
-- ========================================

SELECT 
  id,
  restaurant_id,
  global_ingredient_group_id,
  name,
  display_order,
  min,
  max,
  free,
  enabled,
  added_by,
  added_at
FROM restaurants_ingredient_groups
WHERE restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY restaurant_id, display_order;

-- Expected: ~100-200 rows (5-15 groups per restaurant)


-- ========================================
-- QUERY 4: Export Ingredients/Modifier Options (CRITICAL)
-- Save as: v2_18_ingredients.csv
-- ========================================

SELECT 
  i.id,
  i.global_ingredient_id,
  i.group_id,
  i.name,
  i.price,
  i.display_order,
  i.enabled,
  i.added_by,
  i.added_at,
  i.disabled_by,
  i.disabled_at
FROM restaurants_ingredients i
JOIN restaurants_ingredient_groups ig ON ig.id = i.group_id
WHERE ig.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY ig.restaurant_id, i.group_id, i.display_order;

-- Expected: ~500-1,500 rows (multiple options per group)


-- ========================================
-- QUERY 5: Export Dish Customizations (Links dishes to modifiers)
-- Save as: v2_18_dish_customizations.csv
-- ========================================

SELECT 
  dc.*
FROM restaurants_dishes_customization dc
JOIN restaurants_dishes rd ON rd.id = dc.dish_id
JOIN restaurants_courses rc ON rc.id = rd.course_id
WHERE rc.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
  AND rd.enabled = 'y'
ORDER BY rc.restaurant_id, dc.dish_id;

-- Expected: ~2,000-5,000 rows (multiple customization rules per dish)


-- ========================================
-- QUERY 6: Export Combo Groups (Optional)
-- Save as: v2_18_combo_groups.csv
-- ========================================

SELECT 
  cg.*
FROM restaurants_combo_groups cg
WHERE cg.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY cg.restaurant_id;

-- Expected: ~50-100 rows (if restaurants have combo items)


-- ========================================
-- QUERY 7: Export Combo Items (Optional)
-- Save as: v2_18_combo_items.csv
-- ========================================

SELECT 
  ci.*
FROM restaurants_combo_groups_items ci
JOIN restaurants_combo_groups cg ON cg.id = ci.combo_group_id
WHERE cg.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY cg.restaurant_id, ci.combo_group_id;

-- Expected: ~200-500 rows


-- ========================================
-- VERIFICATION QUERIES (Run BEFORE export)
-- ========================================

-- Check how many courses exist for these restaurants
SELECT 
  restaurant_id,
  COUNT(*) AS course_count
FROM restaurants_courses
WHERE restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
GROUP BY restaurant_id
ORDER BY restaurant_id;

-- Check how many dishes exist
SELECT 
  rc.restaurant_id,
  COUNT(rd.id) AS dish_count
FROM restaurants_courses rc
LEFT JOIN restaurants_dishes rd ON rd.course_id = rc.id AND rd.enabled = 'y'
WHERE rc.restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
GROUP BY rc.restaurant_id
ORDER BY rc.restaurant_id;

-- Check restaurant names
SELECT id, name FROM restaurants
WHERE id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
ORDER BY id;


-- ========================================
-- EXPECTED RESULTS SUMMARY
-- ========================================
-- 
-- After running all queries, you should have 7 CSV files:
-- 1. v2_18_restaurants_courses.csv (~150-200 rows)
-- 2. v2_18_restaurants_dishes.csv (~1,500-2,500 rows) ⭐ CRITICAL
-- 3. v2_18_ingredient_groups.csv (~100-200 rows) ⭐ CRITICAL
-- 4. v2_18_ingredients.csv (~500-1,500 rows) ⭐ CRITICAL
-- 5. v2_18_dish_customizations.csv (~2,000-5,000 rows) ⭐ CRITICAL
-- 6. v2_18_combo_groups.csv (~50-100 rows)
-- 7. v2_18_combo_items.csv (~200-500 rows)
--
-- Upload all files for import into V3 staging.
-- 
-- ========================================
-- NOTES FOR SANTIAGO
-- ========================================
--
-- WHY WE NEED THIS:
-- - These 18 restaurants are LIVE and taking orders on menu.ca
-- - Kirkwood Pizza confirmed: https://kirkwoodpizza.ca
-- - All Out Burger confirmed: https://gladstone.alloutburger.com
-- - Current V2 staging has ZERO dish data (export was corrupted)
-- - Cannot scrape websites (modifiers load via JS modals, not in HTML)
--
-- WHAT THIS RECOVERS:
-- - $36,000/month revenue (18 × $2k/month)
-- - Estimated 1,500-3,000 menu items
-- - All modifier/customization data (required for ordering)
-- - Completes MenuCA V3 migration (95.8% → 99%+ coverage)
--
-- EXECUTION IN SQL WORKBENCH:
-- 1. Connect to V2 production database
-- 2. Run Query 1, export result as CSV
-- 3. Run Query 2, export result as CSV
-- 4. Continue for all 7 queries
-- 5. Upload all CSV files
-- 6. Notify Brian - I'll handle the rest
--
-- Questions? Contact Brian
-- ========================================

