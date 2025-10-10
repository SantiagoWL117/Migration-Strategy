-- ============================================================================
-- MenuCA V3 - Combo Fix Validation Script
-- ============================================================================
-- Purpose: Validate combo_items migration fix was successful
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025
-- Usage: Run after fix_combo_items_migration.sql
-- ============================================================================

\timing
\echo '\n=== COMBO FIX VALIDATION SUITE ==='
\echo 'Run Date:' `date`

-- ============================================================================
-- TEST 1: OVERALL STATISTICS
-- ============================================================================

\echo '\n=== TEST 1: Overall Statistics ==='

SELECT 
  'Combo Groups' as entity,
  COUNT(*) as count
FROM menuca_v3.combo_groups

UNION ALL

SELECT 
  'Combo Items' as entity,
  COUNT(*) as count
FROM menuca_v3.combo_items

UNION ALL

SELECT 
  'Groups With Items' as entity,
  COUNT(DISTINCT combo_group_id) as count
FROM menuca_v3.combo_items

UNION ALL

SELECT 
  'Orphaned Groups' as entity,
  COUNT(*) as count
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
WHERE ci.id IS NULL;

-- ============================================================================
-- TEST 2: ORPHAN RATE (Target: < 1%)
-- ============================================================================

\echo '\n=== TEST 2: Orphan Rate Check (Target: < 1%) ==='

SELECT 
  total_groups,
  groups_with_items,
  orphaned_groups,
  ROUND(orphan_pct, 2) as orphan_percentage,
  CASE 
    WHEN orphan_pct < 1.0 THEN 'PASS - Excellent' 
    WHEN orphan_pct < 5.0 THEN 'PASS - Acceptable'
    WHEN orphan_pct < 20.0 THEN 'WARNING - Needs Investigation'
    ELSE 'FAIL - Migration Incomplete'
  END as status
FROM (
  SELECT 
    COUNT(*) as total_groups,
    COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
    COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned_groups,
    ((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100) as orphan_pct
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
) stats;

-- ============================================================================
-- TEST 3: EXPECTED VS ACTUAL ITEM COUNTS
-- ============================================================================

\echo '\n=== TEST 3: Expected vs Actual Item Counts (Top 20 Mismatches) ==='

SELECT 
  cg.id as combo_group_id,
  cg.name as combo_name,
  cg.legacy_v1_id,
  cg.combo_rules->>'item_count' as expected_count,
  COUNT(ci.id) as actual_count,
  CASE 
    WHEN cg.combo_rules->>'item_count' = COUNT(ci.id)::text THEN 'MATCH'
    WHEN COUNT(ci.id) = 0 THEN 'ORPHANED'
    ELSE 'MISMATCH'
  END as status
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
WHERE cg.combo_rules->>'item_count' IS NOT NULL
GROUP BY cg.id, cg.name, cg.legacy_v1_id, cg.combo_rules
HAVING cg.combo_rules->>'item_count' != COUNT(ci.id)::text
  OR COUNT(ci.id) = 0
ORDER BY 
  CASE 
    WHEN COUNT(ci.id) = 0 THEN 1 
    ELSE 2 
  END,
  ABS((cg.combo_rules->>'item_count')::int - COUNT(ci.id)::int) DESC
LIMIT 20;

-- ============================================================================
-- TEST 4: ITEM COUNT DISTRIBUTION
-- ============================================================================

\echo '\n=== TEST 4: Item Count Distribution ==='

SELECT 
  item_count,
  COUNT(*) as combo_groups_with_this_count,
  ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) as percentage
FROM (
  SELECT 
    cg.id,
    COUNT(ci.id) as item_count
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
  GROUP BY cg.id
) subquery
GROUP BY item_count
ORDER BY item_count;

-- ============================================================================
-- TEST 5: SAMPLE COMBO GROUPS (Well-Populated)
-- ============================================================================

\echo '\n=== TEST 5: Sample Well-Populated Combo Groups (Top 10) ==='

SELECT 
  cg.id,
  cg.name,
  cg.restaurant_id,
  cg.legacy_v1_id,
  COUNT(ci.id) as item_count,
  string_agg(d.name, ' | ' ORDER BY ci.display_order) as dishes
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
GROUP BY cg.id, cg.name, cg.restaurant_id, cg.legacy_v1_id
ORDER BY item_count DESC, cg.id
LIMIT 10;

-- ============================================================================
-- TEST 6: ORPHANED COMBO GROUPS (If Any Remain)
-- ============================================================================

\echo '\n=== TEST 6: Remaining Orphaned Combo Groups (Sample) ==='

SELECT 
  cg.id,
  cg.name,
  cg.restaurant_id,
  cg.legacy_v1_id,
  cg.legacy_v2_id,
  cg.combo_rules->>'item_count' as expected_items,
  cg.is_active,
  cg.source_system
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
WHERE ci.id IS NULL
ORDER BY 
  CASE 
    WHEN cg.legacy_v1_id IS NOT NULL THEN 1
    WHEN cg.legacy_v2_id IS NOT NULL THEN 2
    ELSE 3
  END,
  cg.id
LIMIT 20;

-- ============================================================================
-- TEST 7: V1 VS V2 SOURCE BREAKDOWN
-- ============================================================================

\echo '\n=== TEST 7: Source System Breakdown ==='

SELECT 
  cg.source_system,
  COUNT(DISTINCT cg.id) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(DISTINCT cg.id) - COUNT(DISTINCT ci.combo_group_id) as orphaned,
  ROUND(
    ((COUNT(DISTINCT cg.id) - COUNT(DISTINCT ci.combo_group_id))::numeric / 
     COUNT(DISTINCT cg.id)::numeric * 100),
    2
  ) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
WHERE cg.source_system IS NOT NULL
GROUP BY cg.source_system
ORDER BY cg.source_system;

-- ============================================================================
-- TEST 8: RESTAURANT COVERAGE
-- ============================================================================

\echo '\n=== TEST 8: Restaurant Combo Coverage ==='

SELECT 
  'Restaurants with Combo Groups' as metric,
  COUNT(DISTINCT restaurant_id) as count
FROM menuca_v3.combo_groups

UNION ALL

SELECT 
  'Restaurants with Active Combo Items' as metric,
  COUNT(DISTINCT cg.restaurant_id) as count
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;

-- ============================================================================
-- TEST 9: DISHES IN COMBOS
-- ============================================================================

\echo '\n=== TEST 9: Dish Usage in Combos ==='

SELECT 
  'Total Unique Dishes in Combos' as metric,
  COUNT(DISTINCT dish_id) as count
FROM menuca_v3.combo_items

UNION ALL

SELECT 
  'Total Dish-Combo Associations' as metric,
  COUNT(*) as count
FROM menuca_v3.combo_items

UNION ALL

SELECT 
  'Most Referenced Dish' as metric,
  COUNT(*) as count
FROM menuca_v3.combo_items
GROUP BY dish_id
ORDER BY count DESC
LIMIT 1;

-- ============================================================================
-- TEST 10: RECENTLY CREATED ITEMS
-- ============================================================================

\echo '\n=== TEST 10: Recently Created Combo Items (Last Hour) ==='

SELECT 
  COUNT(*) as items_created_last_hour,
  MIN(created_at) as first_created,
  MAX(created_at) as last_created
FROM menuca_v3.combo_items
WHERE created_at >= NOW() - INTERVAL '1 hour';

-- ============================================================================
-- TEST 11: DATA INTEGRITY CHECKS
-- ============================================================================

\echo '\n=== TEST 11: Data Integrity Checks ==='

-- Check for null dish_ids
SELECT 
  'Combo Items with NULL dish_id' as check_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM menuca_v3.combo_items
WHERE dish_id IS NULL

UNION ALL

-- Check for null combo_group_ids
SELECT 
  'Combo Items with NULL combo_group_id' as check_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM menuca_v3.combo_items
WHERE combo_group_id IS NULL

UNION ALL

-- Check for invalid dish references
SELECT 
  'Combo Items with Invalid dish_id' as check_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM menuca_v3.combo_items ci
LEFT JOIN menuca_v3.dishes d ON ci.dish_id = d.id
WHERE d.id IS NULL

UNION ALL

-- Check for invalid combo_group references
SELECT 
  'Combo Items with Invalid combo_group_id' as check_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM menuca_v3.combo_items ci
LEFT JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
WHERE cg.id IS NULL;

-- ============================================================================
-- TEST 12: DUPLICATE CHECK
-- ============================================================================

\echo '\n=== TEST 12: Duplicate Combo Items Check ==='

SELECT 
  combo_group_id,
  dish_id,
  COUNT(*) as duplicate_count,
  CASE WHEN COUNT(*) > 1 THEN 'DUPLICATE' ELSE 'OK' END as status
FROM menuca_v3.combo_items
GROUP BY combo_group_id, dish_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- ============================================================================
-- SUMMARY REPORT
-- ============================================================================

\echo '\n=== VALIDATION SUMMARY ==='

DO $$
DECLARE
  v_total_groups INT;
  v_groups_with_items INT;
  v_orphaned INT;
  v_orphan_pct NUMERIC;
  v_total_items INT;
  v_integrity_issues INT;
BEGIN
  -- Get metrics
  SELECT COUNT(*) INTO v_total_groups FROM menuca_v3.combo_groups;
  SELECT COUNT(DISTINCT combo_group_id) INTO v_groups_with_items FROM menuca_v3.combo_items;
  v_orphaned := v_total_groups - v_groups_with_items;
  v_orphan_pct := (v_orphaned::NUMERIC / v_total_groups::NUMERIC) * 100;
  SELECT COUNT(*) INTO v_total_items FROM menuca_v3.combo_items;
  
  -- Count integrity issues
  SELECT 
    COUNT(*) INTO v_integrity_issues
  FROM menuca_v3.combo_items ci
  LEFT JOIN menuca_v3.dishes d ON ci.dish_id = d.id
  LEFT JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
  WHERE d.id IS NULL OR cg.id IS NULL OR ci.dish_id IS NULL OR ci.combo_group_id IS NULL;
  
  -- Print summary
  RAISE NOTICE '';
  RAISE NOTICE '╔════════════════════════════════════════════════╗';
  RAISE NOTICE '║         COMBO FIX VALIDATION SUMMARY           ║';
  RAISE NOTICE '╠════════════════════════════════════════════════╣';
  RAISE NOTICE '║ Total Combo Groups:        % ║', LPAD(v_total_groups::text, 18, ' ');
  RAISE NOTICE '║ Groups With Items:         % ║', LPAD(v_groups_with_items::text, 18, ' ');
  RAISE NOTICE '║ Orphaned Groups:           % ║', LPAD(v_orphaned::text, 18, ' ');
  RAISE NOTICE '║ Orphan Rate:               % ║', LPAD(ROUND(v_orphan_pct, 2)::text || '%', 18, ' ');
  RAISE NOTICE '║ Total Combo Items:         % ║', LPAD(v_total_items::text, 18, ' ');
  RAISE NOTICE '║ Data Integrity Issues:     % ║', LPAD(v_integrity_issues::text, 18, ' ');
  RAISE NOTICE '╠════════════════════════════════════════════════╣';
  
  IF v_orphan_pct < 1.0 AND v_integrity_issues = 0 THEN
    RAISE NOTICE '║ RESULT: ✓ PASS - Migration Successful        ║';
  ELSIF v_orphan_pct < 5.0 AND v_integrity_issues = 0 THEN
    RAISE NOTICE '║ RESULT: ⚠ PASS - Acceptable Orphan Rate      ║';
  ELSIF v_integrity_issues > 0 THEN
    RAISE NOTICE '║ RESULT: ✗ FAIL - Data Integrity Issues       ║';
  ELSE
    RAISE NOTICE '║ RESULT: ✗ FAIL - High Orphan Rate            ║';
  END IF;
  
  RAISE NOTICE '╚════════════════════════════════════════════════╝';
  RAISE NOTICE '';
END $$;

\echo '\n=== VALIDATION COMPLETE ==='

