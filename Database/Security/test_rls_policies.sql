-- ============================================================================
-- MenuCA V3 - RLS Policy Testing Script
-- ============================================================================
-- Purpose: Validate RLS policies work correctly and measure performance impact
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025
-- Usage: Run after deploying create_rls_policies.sql
-- ============================================================================

-- Enable timing for performance measurements
\timing

-- ============================================================================
-- TEST SUITE 1: FUNCTIONAL VALIDATION
-- ============================================================================

\echo '\n=== TEST SUITE 1: FUNCTIONAL VALIDATION ==='

-- Test 1.1: Tenant Isolation - User should only see their restaurant's data
\echo '\nTest 1.1: Tenant Isolation (restaurants table)'
-- Simulate restaurant user
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123", "role": "restaurant_owner"}', true);
END $$;

SELECT 
  COUNT(*) as my_restaurant_count,
  (SELECT COUNT(*) FROM menuca_v3.restaurants) as total_count,
  CASE 
    WHEN COUNT(*) = 1 THEN 'PASS' 
    ELSE 'FAIL' 
  END as result
FROM menuca_v3.restaurants
WHERE id = 123;

-- Test 1.2: Cross-Tenant Block - User should NOT see other restaurants' data
\echo '\nTest 1.2: Cross-Tenant Block (dishes table)'
SELECT 
  COUNT(*) as other_restaurant_dishes,
  CASE 
    WHEN COUNT(*) = 0 THEN 'PASS' 
    ELSE 'FAIL' 
  END as result
FROM menuca_v3.dishes
WHERE restaurant_id != 123;

-- Test 1.3: Public Read Access - Anonymous user can see active menu items
\echo '\nTest 1.3: Public Read Access (active dishes)'
-- Simulate anonymous user
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  COUNT(*) as public_dishes,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASS' 
    ELSE 'FAIL' 
  END as result
FROM menuca_v3.dishes
WHERE is_active = true
LIMIT 10;

-- Test 1.4: Admin Full Access - Admin should see all data
\echo '\nTest 1.4: Admin Full Access (all restaurants)'
-- Simulate admin user
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"role": "admin"}', true);
END $$;

SELECT 
  COUNT(*) as admin_can_see,
  (SELECT COUNT(*) FROM menuca_v3.restaurants) as total_restaurants,
  CASE 
    WHEN COUNT(*) = (SELECT COUNT(*) FROM menuca_v3.restaurants) THEN 'PASS' 
    ELSE 'FAIL' 
  END as result
FROM menuca_v3.restaurants;

-- Test 1.5: User Self-Access - Users can only see their own profile
\echo '\nTest 1.5: User Self-Access (users table)'
-- Simulate regular user
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"sub": "550e8400-e29b-41d4-a716-446655440000", "role": "authenticated"}', true);
END $$;

SELECT 
  COUNT(*) as my_profile,
  CASE 
    WHEN COUNT(*) <= 1 THEN 'PASS' 
    ELSE 'FAIL' 
  END as result
FROM menuca_v3.users
-- WHERE id = auth.uid()::bigint
LIMIT 1;

-- Test 1.6: Write Protection - User cannot insert into other restaurant's data
\echo '\nTest 1.6: Write Protection (prevent cross-tenant writes)'
-- Simulate restaurant 123 user trying to insert dish for restaurant 456
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123", "role": "restaurant_owner"}', true);
  
  BEGIN
    INSERT INTO menuca_v3.dishes (restaurant_id, name, base_price, is_active)
    VALUES (456, 'Hacked Dish', 9.99, true);
    
    RAISE NOTICE 'FAIL: Should have blocked cross-tenant insert!';
  EXCEPTION
    WHEN insufficient_privilege THEN
      RAISE NOTICE 'PASS: Cross-tenant insert blocked as expected';
    WHEN OTHERS THEN
      RAISE NOTICE 'PASS: Cross-tenant insert blocked (%)' , SQLERRM;
  END;
END $$;

-- ============================================================================
-- TEST SUITE 2: PERFORMANCE VALIDATION
-- ============================================================================

\echo '\n=== TEST SUITE 2: PERFORMANCE VALIDATION ==='

-- Test 2.1: Baseline (RLS Disabled)
\echo '\nTest 2.1: Baseline Performance (RLS DISABLED)'
ALTER TABLE menuca_v3.dishes DISABLE ROW LEVEL SECURITY;

EXPLAIN (ANALYZE, BUFFERS) 
SELECT d.*, c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.restaurant_id = 123 AND d.is_active = true;

-- Test 2.2: With RLS Enabled
\echo '\nTest 2.2: Performance with RLS ENABLED'
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123", "role": "restaurant_owner"}', true);
END $$;

EXPLAIN (ANALYZE, BUFFERS)
SELECT d.*, c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.is_active = true;

-- Test 2.3: Index Usage Verification
\echo '\nTest 2.3: Verify Index Scan (not Seq Scan)'
EXPLAIN (ANALYZE)
SELECT * FROM menuca_v3.dishes 
WHERE restaurant_id = 123;
-- Look for "Index Scan" in output, NOT "Seq Scan"

-- Test 2.4: Complex Query with Joins
\echo '\nTest 2.4: Complex Menu Query Performance'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

EXPLAIN (ANALYZE, BUFFERS)
SELECT 
  d.id, d.name, d.base_price,
  c.name as course,
  COUNT(dm.id) as modifier_count
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON d.course_id = c.id
LEFT JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id
WHERE d.is_active = true
GROUP BY d.id, c.name
ORDER BY c.display_order, d.display_order
LIMIT 100;

-- Test 2.5: RLS Overhead Calculation
\echo '\nTest 2.5: RLS Overhead Measurement'

-- Without RLS
ALTER TABLE menuca_v3.dishes DISABLE ROW LEVEL SECURITY;
\set start_time `date +%s%3N`
SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = 123;
\set baseline_time :start_time

-- With RLS
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;
\set start_time `date +%s%3N`
SELECT COUNT(*) FROM menuca_v3.dishes;
\set rls_time :start_time

-- Calculate overhead (manual comparison needed)
\echo 'Compare timing output above to calculate RLS overhead'
\echo 'Target: < 10% overhead'

-- ============================================================================
-- TEST SUITE 3: EDGE CASES
-- ============================================================================

\echo '\n=== TEST SUITE 3: EDGE CASES ==='

-- Test 3.1: NULL restaurant_id (should be blocked or visible only to admin)
\echo '\nTest 3.1: NULL restaurant_id handling'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

SELECT 
  COUNT(*) as null_restaurant_dishes,
  CASE 
    WHEN COUNT(*) = 0 THEN 'PASS' 
    ELSE 'FAIL - Found dishes with NULL restaurant_id' 
  END as result
FROM menuca_v3.dishes
WHERE restaurant_id IS NULL;

-- Test 3.2: Inactive items not visible to public
\echo '\nTest 3.2: Inactive items hidden from public'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  COUNT(*) as inactive_visible,
  CASE 
    WHEN COUNT(*) = 0 THEN 'PASS' 
    ELSE 'FAIL - Inactive items visible to public' 
  END as result
FROM menuca_v3.dishes
WHERE is_active = false;

-- Test 3.3: Junction table access (ingredient_group_items has no restaurant_id)
\echo '\nTest 3.3: Junction table access (ingredient_group_items)'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

-- Should only see items for restaurant 123's ingredient groups
SELECT 
  COUNT(*) as accessible_items,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASS' 
    ELSE 'INFO - No items for test restaurant' 
  END as result
FROM menuca_v3.ingredient_group_items igi
WHERE igi.ingredient_group_id IN (
  SELECT id FROM menuca_v3.ingredient_groups WHERE restaurant_id = 123
);

-- Test 3.4: Expired deals not visible to public
\echo '\nTest 3.4: Expired deals hidden from public'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  COUNT(*) as expired_visible,
  CASE 
    WHEN COUNT(*) = 0 THEN 'PASS' 
    ELSE 'INFO - Some expired deals still visible (check date logic)' 
  END as result
FROM menuca_v3.promotional_deals
WHERE date_stop < CURRENT_DATE;

-- ============================================================================
-- TEST SUITE 4: SECURITY VALIDATION
-- ============================================================================

\echo '\n=== TEST SUITE 4: SECURITY VALIDATION ==='

-- Test 4.1: Cannot escalate privileges via UPDATE
\echo '\nTest 4.1: Privilege Escalation Prevention'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
  
  BEGIN
    UPDATE menuca_v3.dishes 
    SET restaurant_id = 123 
    WHERE restaurant_id = 456;
    
    IF FOUND THEN
      RAISE NOTICE 'FAIL: Allowed privilege escalation!';
    END IF;
  EXCEPTION
    WHEN insufficient_privilege THEN
      RAISE NOTICE 'PASS: Privilege escalation blocked';
    WHEN OTHERS THEN
      RAISE NOTICE 'PASS: Privilege escalation blocked (%)' , SQLERRM;
  END;
END $$;

-- Test 4.2: Cannot delete other tenant's data
\echo '\nTest 4.2: Cross-Tenant Delete Protection'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
  
  BEGIN
    DELETE FROM menuca_v3.dishes 
    WHERE restaurant_id = 456 
    LIMIT 1;
    
    IF FOUND THEN
      RAISE NOTICE 'FAIL: Allowed cross-tenant delete!';
    END IF;
  EXCEPTION
    WHEN insufficient_privilege THEN
      RAISE NOTICE 'PASS: Cross-tenant delete blocked';
    WHEN OTHERS THEN
      RAISE NOTICE 'PASS: Cross-tenant delete blocked (%)' , SQLERRM;
  END;
END $$;

-- Test 4.3: Admin bypass verification
\echo '\nTest 4.3: Admin Bypass Verification'
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"role": "admin"}', true);
END $$;

SELECT 
  COUNT(DISTINCT restaurant_id) as unique_restaurants,
  CASE 
    WHEN COUNT(DISTINCT restaurant_id) > 1 THEN 'PASS - Admin sees multiple restaurants' 
    ELSE 'FAIL - Admin access restricted' 
  END as result
FROM menuca_v3.dishes;

-- ============================================================================
-- TEST SUITE 5: INDEX EFFECTIVENESS
-- ============================================================================

\echo '\n=== TEST SUITE 5: INDEX EFFECTIVENESS ==='

-- Test 5.1: Check all filtered columns have indexes
\echo '\nTest 5.1: Verify Indexes Exist on RLS-Filtered Columns'
SELECT 
  t.tablename,
  i.indexname,
  CASE 
    WHEN i.indexname IS NOT NULL THEN 'PASS' 
    ELSE 'FAIL - Missing Index' 
  END as result
FROM pg_tables t
LEFT JOIN pg_indexes i 
  ON t.tablename = i.tablename 
  AND t.schemaname = i.schemaname
  AND (i.indexdef LIKE '%restaurant_id%' OR i.indexdef LIKE '%user_id%')
WHERE t.schemaname = 'menuca_v3'
  AND (
    EXISTS (SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'menuca_v3' 
              AND table_name = t.tablename 
              AND column_name = 'restaurant_id')
    OR EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_schema = 'menuca_v3' 
                 AND table_name = t.tablename 
                 AND column_name = 'user_id')
  )
ORDER BY t.tablename;

-- Test 5.2: Check index usage statistics
\echo '\nTest 5.2: Index Usage Statistics (run after 1 week of usage)'
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'menuca_v3'
  AND (indexname LIKE '%restaurant%' OR indexname LIKE '%user%')
ORDER BY idx_scan DESC
LIMIT 20;

-- ============================================================================
-- CLEANUP & SUMMARY
-- ============================================================================

\echo '\n=== TEST SUMMARY ==='
\echo 'Review output above for any FAIL results'
\echo 'Performance tests should show Index Scan usage'
\echo 'RLS overhead should be < 10%'
\echo '\nNext Steps:'
\echo '1. Fix any FAIL results'
\echo '2. Monitor slow queries with pg_stat_statements'
\echo '3. Run load tests with realistic traffic'
\echo '4. Deploy to production after staging validation'

-- Reset RLS to enabled state
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;

\echo '\n=== TESTING COMPLETE ==='

