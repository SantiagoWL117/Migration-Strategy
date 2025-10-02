-- ============================================================================
-- COMPREHENSIVE V3 DATA VALIDATION - PRE-PRODUCTION CHECKLIST
-- ============================================================================
-- Purpose: Final validation before moving staging.v3_* → production
-- Date: 2025-10-02
-- Author: Brian Lapp
-- ============================================================================
-- This validation covers:
-- 1. Row count verification
-- 2. FK integrity checks
-- 3. Data quality validation
-- 4. Business logic checks
-- 5. BLOB deserialization status
-- 6. Missing data analysis
-- 7. Price validation
-- 8. Orphaned records detection
-- ============================================================================

\timing on
\set QUIET off

-- ============================================================================
-- SECTION 1: ROW COUNT VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '1. ROW COUNT VERIFICATION'
\echo '============================================================'
\echo ''

-- Summary of all V3 tables
SELECT 
  'SUMMARY' as check_type,
  'v3_courses' as table_name,
  COUNT(*) as v3_count,
  (SELECT COUNT(*) FROM staging.v1_courses WHERE name IS NOT NULL) as v1_source,
  (SELECT COUNT(*) FROM staging.v2_restaurants_courses WHERE staging.yn_to_boolean(enabled) = true) +
  (SELECT COUNT(*) FROM staging.v2_global_courses WHERE staging.yn_to_boolean(enabled) = true) as v2_source,
  'Courses (menu categories)' as description
FROM staging.v3_courses

UNION ALL

SELECT 
  'SUMMARY',
  'v3_dishes',
  COUNT(*),
  (SELECT COUNT(*) FROM staging.v1_menu WHERE COALESCE(exclude_from_v3, false) = false),
  (SELECT COUNT(*) FROM staging.v2_restaurants_dishes WHERE COALESCE(exclude_from_v3, false) = false),
  'Menu items/dishes'
FROM staging.v3_dishes

UNION ALL

SELECT 
  'SUMMARY',
  'v3_dish_customizations',
  COUNT(*),
  0, -- V1 not extracted yet
  (SELECT COUNT(*) FROM staging.v2_restaurants_dishes_customization WHERE COALESCE(exclude_from_v3, false) = false),
  'Customization options'
FROM staging.v3_dish_customizations

UNION ALL

SELECT 
  'SUMMARY',
  'v3_ingredient_groups',
  COUNT(*),
  (SELECT COUNT(*) FROM staging.v1_ingredient_groups WHERE name IS NOT NULL),
  (SELECT COUNT(*) FROM staging.v2_restaurants_ingredient_groups WHERE staging.yn_to_boolean(enabled) = true),
  'Ingredient groups'
FROM staging.v3_ingredient_groups

UNION ALL

SELECT 
  'SUMMARY',
  'v3_ingredients',
  COUNT(*),
  (SELECT COUNT(*) FROM staging.v1_ingredients WHERE name IS NOT NULL),
  (SELECT COUNT(*) FROM staging.v2_restaurants_ingredients WHERE staging.yn_to_boolean(enabled) = true),
  'Individual ingredients'
FROM staging.v3_ingredients

UNION ALL

SELECT 
  'SUMMARY',
  'v3_combo_groups',
  COUNT(*),
  (SELECT COUNT(*) FROM staging.v1_combo_groups WHERE name IS NOT NULL),
  (SELECT COUNT(*) FROM staging.v2_restaurants_combo_groups WHERE staging.yn_to_boolean(enabled) = true),
  'Combo meal groups'
FROM staging.v3_combo_groups

UNION ALL

SELECT 
  'SUMMARY',
  'v3_combo_items',
  COUNT(*),
  (SELECT COUNT(*) FROM staging.v1_combos),
  (SELECT COUNT(*) FROM staging.v2_restaurants_combo_groups_items),
  'Items within combos'
FROM staging.v3_combo_items;

-- ============================================================================
-- SECTION 2: FOREIGN KEY INTEGRITY CHECKS
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '2. FOREIGN KEY INTEGRITY CHECKS'
\echo '============================================================'
\echo ''

-- Check 1: Dishes with invalid course_id
SELECT 
  'FK_CHECK' as check_type,
  'v3_dishes → v3_courses' as relationship,
  COUNT(*) as invalid_count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ PASS'
    ELSE '❌ FAIL'
  END as status
FROM staging.v3_dishes d
LEFT JOIN staging.v3_courses c ON d.course_id = c.id
WHERE d.course_id IS NOT NULL AND c.id IS NULL

UNION ALL

-- Check 2: Customizations with invalid dish_id
SELECT 
  'FK_CHECK',
  'v3_dish_customizations → v3_dishes',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_dish_customizations dc
LEFT JOIN staging.v3_dishes d ON dc.dish_id = d.id
WHERE d.id IS NULL

UNION ALL

-- Check 3: Customizations with invalid ingredient_group_id
SELECT 
  'FK_CHECK',
  'v3_dish_customizations → v3_ingredient_groups',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_dish_customizations dc
LEFT JOIN staging.v3_ingredient_groups ig ON dc.ingredient_group_id = ig.id
WHERE dc.ingredient_group_id IS NOT NULL AND ig.id IS NULL

UNION ALL

-- Check 4: Ingredients with invalid group_id
SELECT 
  'FK_CHECK',
  'v3_ingredients → v3_ingredient_groups',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_ingredients i
LEFT JOIN staging.v3_ingredient_groups ig ON i.ingredient_group_id = ig.id
WHERE ig.id IS NULL

UNION ALL

-- Check 5: Combo items with invalid combo_group_id
SELECT 
  'FK_CHECK',
  'v3_combo_items → v3_combo_groups',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_combo_items ci
LEFT JOIN staging.v3_combo_groups cg ON ci.combo_group_id = cg.id
WHERE cg.id IS NULL

UNION ALL

-- Check 6: Combo items with invalid dish_id
SELECT 
  'FK_CHECK',
  'v3_combo_items → v3_dishes',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_combo_items ci
LEFT JOIN staging.v3_dishes d ON ci.dish_id = d.id
WHERE ci.dish_id IS NOT NULL AND d.id IS NULL;

-- ============================================================================
-- SECTION 3: DATA QUALITY CHECKS
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '3. DATA QUALITY CHECKS'
\echo '============================================================'
\echo ''

-- Check 1: Courses with blank names
SELECT 
  'QUALITY_CHECK' as check_type,
  'Courses with blank names' as check_name,
  COUNT(*) as issue_count,
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END as status
FROM staging.v3_courses
WHERE name IS NULL OR TRIM(name) = ''

UNION ALL

-- Check 2: Dishes with blank names
SELECT 
  'QUALITY_CHECK',
  'Dishes with blank names',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_dishes
WHERE name IS NULL OR TRIM(name) = ''

UNION ALL

-- Check 3: Dishes with NULL prices
SELECT 
  'QUALITY_CHECK',
  'Dishes with NULL prices',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_dishes
WHERE prices IS NULL

UNION ALL

-- Check 4: Dishes with invalid JSONB prices
SELECT 
  'QUALITY_CHECK',
  'Dishes with invalid JSONB prices',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_dishes
WHERE jsonb_typeof(prices) != 'object' OR prices = '{}'::jsonb

UNION ALL

-- Check 5: Invalid language codes
SELECT 
  'QUALITY_CHECK',
  'Invalid language codes (not en/fr)',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_courses
WHERE language NOT IN ('en', 'fr')

UNION ALL

-- Check 6: Negative display orders
SELECT 
  'QUALITY_CHECK',
  'Negative display_order values',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM (
  SELECT display_order FROM staging.v3_courses WHERE display_order < 0
  UNION ALL
  SELECT display_order FROM staging.v3_dishes WHERE display_order < 0
  UNION ALL
  SELECT display_order FROM staging.v3_dish_customizations WHERE display_order < 0
) subq;

-- ============================================================================
-- SECTION 4: BUSINESS LOGIC VALIDATION
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '4. BUSINESS LOGIC VALIDATION'
\echo '============================================================'
\echo ''

-- Check 1: Customizations with invalid selection logic (min > max)
SELECT 
  'BUSINESS_LOGIC' as check_type,
  'Customizations: min > max' as check_name,
  COUNT(*) as issue_count,
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END as status
FROM staging.v3_dish_customizations
WHERE max_selections > 0 AND min_selections > max_selections

UNION ALL

-- Check 2: Customizations with free > max
SELECT 
  'BUSINESS_LOGIC',
  'Customizations: free > max',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_dish_customizations
WHERE max_selections > 0 AND free_selections > max_selections

UNION ALL

-- Check 3: Dishes without courses
SELECT 
  'BUSINESS_LOGIC',
  'Dishes without assigned course',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_dishes
WHERE course_id IS NULL

UNION ALL

-- Check 4: Global courses with restaurant_id
SELECT 
  'BUSINESS_LOGIC',
  'Global courses with restaurant_id (should be NULL)',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_courses
WHERE is_global = true AND restaurant_id IS NOT NULL

UNION ALL

-- Check 5: Non-global courses without restaurant_id
SELECT 
  'BUSINESS_LOGIC',
  'Non-global courses without restaurant_id',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '⚠️ WARNING' END
FROM staging.v3_courses
WHERE is_global = false AND restaurant_id IS NULL;

-- ============================================================================
-- SECTION 5: BLOB DESERIALIZATION STATUS
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '5. BLOB DESERIALIZATION STATUS'
\echo '============================================================'
\echo ''

SELECT 
  'BLOB_STATUS' as check_type,
  'V1 ingredient_groups.item BLOB' as blob_field,
  COUNT(*) as total_blobs,
  '❌ NOT DESERIALIZED' as status,
  'Requires external PHP/Python script' as action_needed
FROM staging.v1_ingredient_groups
WHERE item IS NOT NULL AND TRIM(item::text) != ''

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 ingredient_groups.price BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_ingredient_groups
WHERE price IS NOT NULL AND TRIM(price::text) != ''

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 combo_groups.dish BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_combo_groups
WHERE dish IS NOT NULL AND TRIM(dish::text) != ''

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 combo_groups.options BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_combo_groups
WHERE options IS NOT NULL AND TRIM(options::text) != ''

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 combo_groups.group_data BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_combo_groups
WHERE group_data IS NOT NULL AND TRIM(group_data::text) != ''

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 menu.hideOnDays BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_menu
WHERE hideondays IS NOT NULL

UNION ALL

SELECT 
  'BLOB_STATUS',
  'V1 menuothers.content BLOB',
  COUNT(*),
  '❌ NOT DESERIALIZED',
  'Requires external PHP/Python script'
FROM staging.v1_menuothers
WHERE content IS NOT NULL AND TRIM(content) != '';

-- ============================================================================
-- SECTION 6: MISSING DATA ANALYSIS
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '6. MISSING DATA ANALYSIS'
\echo '============================================================'
\echo ''

-- Missing V1 dish customizations
SELECT 
  'MISSING_DATA' as check_type,
  'V1 dish customizations not extracted' as data_category,
  COUNT(*) as affected_rows,
  '⚠️ PENDING' as status,
  'V1 menu has 30+ customization columns to extract' as note
FROM staging.v1_menu
WHERE COALESCE(exclude_from_v3, false) = false
  AND (
    staging.yn_to_boolean(hasbread) = true OR
    staging.yn_to_boolean(hascustomisation) = true OR
    staging.yn_to_boolean(hasdressing) = true OR
    staging.yn_to_boolean(hassauce) = true OR
    staging.yn_to_boolean(hassidedish) = true OR
    staging.yn_to_boolean(hasdrinks) = true OR
    staging.yn_to_boolean(hasextras) = true OR
    staging.yn_to_boolean(hascookmethod) = true
  )

UNION ALL

-- Missing V1 ingredients (not linked)
SELECT 
  'MISSING_DATA',
  'V1 ingredients not linked to groups',
  COUNT(*),
  '⚠️ PENDING',
  'Requires ingredient_groups.item BLOB deserialization'
FROM staging.v1_ingredients
WHERE name IS NOT NULL

UNION ALL

-- Missing V2 combo groups
SELECT 
  'MISSING_DATA',
  'V2 combo groups not migrated',
  COUNT(*),
  '⚠️ PENDING',
  'V2 combo transformation not yet built'
FROM staging.v2_restaurants_combo_groups
WHERE staging.yn_to_boolean(enabled) = true

UNION ALL

-- Missing V2 combo items
SELECT 
  'MISSING_DATA',
  'V2 combo items not migrated',
  COUNT(*),
  '⚠️ PENDING',
  'V2 combo transformation not yet built'
FROM staging.v2_restaurants_combo_groups_items

UNION ALL

-- Missing V1 menuothers data
SELECT 
  'MISSING_DATA',
  'V1 menuothers not processed',
  COUNT(*),
  '⚠️ PENDING',
  'Contains side dishes, extras, drinks with pricing'
FROM staging.v1_menuothers;

-- ============================================================================
-- SECTION 7: PRICE VALIDATION
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '7. PRICE VALIDATION'
\echo '============================================================'
\echo ''

-- Check price structure
SELECT 
  'PRICE_CHECK' as check_type,
  'Dishes with valid JSONB prices' as check_name,
  COUNT(*) as count,
  '✅ PASS' as status
FROM staging.v3_dishes
WHERE jsonb_typeof(prices) = 'object' AND prices != '{}'::jsonb

UNION ALL

-- Check for zero prices
SELECT 
  'PRICE_CHECK',
  'Dishes with default 0.00 price',
  COUNT(*),
  CASE WHEN COUNT(*) > 0 THEN '⚠️ WARNING' ELSE '✅ PASS' END
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb

UNION ALL

-- Sample price formats
SELECT 
  'PRICE_CHECK',
  'Dishes with single price (default)',
  COUNT(*),
  '✅ INFO'
FROM staging.v3_dishes
WHERE prices ? 'default' AND jsonb_object_keys(prices) = 'default'

UNION ALL

SELECT 
  'PRICE_CHECK',
  'Dishes with size-based pricing',
  COUNT(*),
  '✅ INFO'
FROM staging.v3_dishes
WHERE (prices ? 'small' OR prices ? 'medium' OR prices ? 'large');

-- ============================================================================
-- SECTION 8: ORPHANED RECORDS DETECTION
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '8. ORPHANED RECORDS DETECTION'
\echo '============================================================'
\echo ''

-- Use built-in verification views
SELECT 
  'ORPHANED_CHECK' as check_type,
  'Orphaned dishes (invalid course_id)' as check_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM staging.v3_orphaned_dishes

UNION ALL

SELECT 
  'ORPHANED_CHECK',
  'Orphaned customizations (invalid dish_id)',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_orphaned_customizations

UNION ALL

SELECT 
  'ORPHANED_CHECK',
  'Orphaned ingredients (invalid group_id)',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_orphaned_ingredients

UNION ALL

SELECT 
  'ORPHANED_CHECK',
  'Orphaned combo items',
  COUNT(*),
  CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v3_orphaned_combo_items;

-- ============================================================================
-- SECTION 9: LANGUAGE CONSISTENCY
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '9. LANGUAGE CONSISTENCY'
\echo '============================================================'
\echo ''

SELECT 
  'LANGUAGE_CHECK' as check_type,
  language,
  COUNT(*) as course_count
FROM staging.v3_courses
GROUP BY language

UNION ALL

SELECT 
  'LANGUAGE_CHECK',
  language,
  COUNT(*)
FROM staging.v3_dishes
GROUP BY language

UNION ALL

SELECT 
  'LANGUAGE_CHECK',
  language,
  COUNT(*)
FROM staging.v3_combo_groups
GROUP BY language
ORDER BY check_type, language;

-- ============================================================================
-- SECTION 10: SAMPLE DATA REVIEW
-- ============================================================================

\echo ''
\echo '============================================================'
\echo '10. SAMPLE DATA REVIEW'
\echo '============================================================'
\echo ''

-- Sample courses
\echo 'Sample Courses (first 5):'
SELECT id, restaurant_id, name, language, is_global, display_order
FROM staging.v3_courses
ORDER BY id
LIMIT 5;

\echo ''
\echo 'Sample Dishes (first 5):'
SELECT id, restaurant_id, course_id, name, prices, language
FROM staging.v3_dishes
ORDER BY id
LIMIT 5;

\echo ''
\echo 'Sample Customizations (first 5):'
SELECT id, dish_id, customization_type, title, min_selections, max_selections, free_selections
FROM staging.v3_dish_customizations
ORDER BY id
LIMIT 5;

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================

\echo ''
\echo '============================================================'
\echo 'VALIDATION SUMMARY'
\echo '============================================================'

SELECT 
  'FINAL_SUMMARY' as summary_type,
  'Total V3 Tables' as metric,
  '7' as value,
  'v3_courses, v3_dishes, v3_dish_customizations, v3_ingredient_groups, v3_ingredients, v3_combo_groups, v3_combo_items' as details

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'Total Rows Migrated',
  (SELECT COUNT(*) FROM staging.v3_courses)::text ||  ' + ' ||
  (SELECT COUNT(*) FROM staging.v3_dishes)::text || ' + ' ||
  (SELECT COUNT(*) FROM staging.v3_dish_customizations)::text || ' + ' ||
  (SELECT COUNT(*) FROM staging.v3_ingredient_groups)::text || ' + ' ||
  (SELECT COUNT(*) FROM staging.v3_combo_groups)::text || ' + ' ||
  (SELECT COUNT(*) FROM staging.v3_combo_items)::text || ' = ' ||
  (
    (SELECT COUNT(*) FROM staging.v3_courses) +
    (SELECT COUNT(*) FROM staging.v3_dishes) +
    (SELECT COUNT(*) FROM staging.v3_dish_customizations) +
    (SELECT COUNT(*) FROM staging.v3_ingredient_groups) +
    (SELECT COUNT(*) FROM staging.v3_combo_groups) +
    (SELECT COUNT(*) FROM staging.v3_combo_items)
  )::text,
  '64,913 rows total'

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'FK Integrity',
  'Run checks above',
  'Should be 0 violations'

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'Data Quality',
  'Run checks above',
  'Should have 0 critical issues'

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'BLOBs Deserialized',
  'NONE',
  '⚠️ 7 BLOB types require external processing'

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'Missing Data',
  'IDENTIFIED',
  '⚠️ V1 customizations, ingredients, V2 combos, menuothers'

UNION ALL

SELECT 
  'FINAL_SUMMARY',
  'Production Ready',
  CASE 
    WHEN (SELECT COUNT(*) FROM staging.v3_orphaned_dishes) = 0
     AND (SELECT COUNT(*) FROM staging.v3_orphaned_customizations) = 0
     AND (SELECT COUNT(*) FROM staging.v3_dishes WHERE prices IS NULL) = 0
    THEN '✅ YES (with known gaps)'
    ELSE '⚠️ REVIEW REQUIRED'
  END,
  'Check all validation sections above';

\echo ''
\echo '============================================================'
\echo '✅ VALIDATION COMPLETE'
\echo '============================================================'
\echo ''
\echo 'Review all sections above before production deployment.'
\echo 'Known gaps are documented in PHASE_2_COMPLETE_SUMMARY.md'
\echo ''

