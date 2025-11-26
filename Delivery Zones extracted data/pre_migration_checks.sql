-- ============================================================================
-- PRE-MIGRATION VALIDATION CHECKS
-- Generated: 2025-11-25 17:21:40
-- ============================================================================
-- Run these checks BEFORE executing the migration to ensure the database
-- is in the correct state.
-- ============================================================================

-- CHECK 1: Current delivery area count
SELECT 
  'Current Areas' as check_name,
  COUNT(*) as count
FROM menuca_v3.restaurant_delivery_areas;

-- CHECK 2: Verify all target restaurants exist in V3
SELECT 
  'Missing Restaurants' as check_name,
  COUNT(*) as count
FROM (
  VALUES (7), (12), (13), (15), (22), (28), (31), (44), (45), (47), (48), (57), (59), (62), (65), (69), (70), (72), (75), (77), (83), (84), (88), (89), (90), (91), (92), (93), (95), (97), (123), (124), (126), (131), (133), (139), (143), (147), (160), (174), (180), (190), (199), (205), (211), (234), (241), (267), (269), (328), (349), (350), (367), (376), (437), (491), (497), (502), (507), (511), (515), (521), (696), (924), (950), (952), (954), (960), (962), (963), (964), (965), (966), (967), (973), (974), (976), (977), (981), (985), (1010), (1014)
) AS migration_restos(restaurant_id)
WHERE restaurant_id NOT IN (
  SELECT id FROM menuca_v3.restaurants
);
-- Expected: 0 (all restaurants should exist)

-- CHECK 3: Check if any target restaurants already have areas
SELECT 
  'Restaurants with Existing Areas' as check_name,
  COUNT(DISTINCT r.id) as count
FROM menuca_v3.restaurants r
INNER JOIN menuca_v3.restaurant_delivery_areas da ON da.restaurant_id = r.id
WHERE r.id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014);
-- Note: MVP restaurants (5) already have areas from Phase 1
-- Expected: 5 (only MVP restaurants)

-- CHECK 4: Verify PostGIS extension is enabled
SELECT 
  'PostGIS Enabled' as check_name,
  CASE WHEN COUNT(*) > 0 THEN 'YES' ELSE 'NO' END as status
FROM pg_extension 
WHERE extname = 'postgis';
-- Expected: YES

-- CHECK 5: List restaurants to be migrated
SELECT 
  r.id as v3_id,
  r.name,
  r.legacy_v2_id,
  r.legacy_v1_id,
  COUNT(da.id) as existing_areas
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_delivery_areas da ON da.restaurant_id = r.id
WHERE r.id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014)
GROUP BY r.id, r.name, r.legacy_v2_id, r.legacy_v1_id
ORDER BY r.id;

-- ============================================================================
-- VALIDATION GATE
-- ============================================================================
-- Before proceeding:
--   - CHECK 2 should return 0 (no missing restaurants)
--   - CHECK 4 should return YES (PostGIS enabled)
--   - Review CHECK 5 to confirm restaurant list
-- ============================================================================
