-- ============================================================================
-- POST-MIGRATION VALIDATION CHECKS
-- Generated: 2025-11-25 17:21:40
-- ============================================================================
-- Run these checks AFTER executing the migration to ensure data integrity.
-- ============================================================================

-- CHECK 1: All restaurants have delivery areas
SELECT 
  'Restaurants with Areas' as check_name,
  COUNT(DISTINCT restaurant_id) as count,
  82 as expected
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014);
-- Expected: 82

-- CHECK 2: Total areas inserted
SELECT 
  'Total Areas Inserted' as check_name,
  COUNT(*) as count,
  91 as expected
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014);
-- Expected: 91 (88 from V2 + 3 from V1)

-- CHECK 3: Verify all geometries are valid
SELECT 
  'Invalid Geometries' as check_name,
  COUNT(*) as count
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014)
AND NOT ST_IsValid(geometry);
-- Expected: 0

-- CHECK 4: Verify area numbering is sequential per restaurant
WITH area_numbers AS (
  SELECT 
    restaurant_id,
    array_agg(area_number ORDER BY area_number) as numbers,
    MAX(area_number) as max_num
  FROM menuca_v3.restaurant_delivery_areas
  WHERE restaurant_id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014)
  GROUP BY restaurant_id
)
SELECT 
  'Sequential Numbering Errors' as check_name,
  COUNT(*) as count
FROM area_numbers
WHERE array_length(numbers, 1) != max_num;
-- Expected: 0

-- CHECK 5: Detailed per-restaurant summary
SELECT 
  r.id as v3_id,
  r.name,
  r.legacy_v2_id,
  r.legacy_v1_id,
  COUNT(da.id) as areas_count,
  STRING_AGG(da.area_number::text, ',' ORDER BY da.area_number) as area_numbers,
  MIN(ST_NPoints(da.geometry)) as min_points,
  MAX(ST_NPoints(da.geometry)) as max_points,
  BOOL_AND(ST_IsValid(da.geometry)) as all_valid
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_delivery_areas da ON da.restaurant_id = r.id
WHERE r.id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014)
GROUP BY r.id, r.name, r.legacy_v2_id, r.legacy_v1_id
ORDER BY areas_count DESC, r.name;

-- CHECK 6: Summary statistics
SELECT 
  COUNT(DISTINCT restaurant_id) as restaurants_migrated,
  COUNT(*) as total_areas,
  ROUND(AVG(ST_NPoints(geometry)), 2) as avg_points_per_polygon,
  MIN(ST_NPoints(geometry)) as min_points,
  MAX(ST_NPoints(geometry)) as max_points,
  ROUND(AVG(ST_Area(geometry::geography)), 2) as avg_area_sq_meters
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (7, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 57, 59, 62, 65, 69, 70, 72, 75, 77, 83, 84, 88, 89, 90, 91, 92, 93, 95, 97, 123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 199, 205, 211, 234, 241, 267, 269, 328, 349, 350, 367, 376, 437, 491, 497, 502, 507, 511, 515, 521, 696, 924, 950, 952, 954, 960, 962, 963, 964, 965, 966, 967, 973, 974, 976, 977, 981, 985, 1010, 1014);

-- CHECK 7: Test spatial queries (sample point)
-- This tests if spatial indexing is working correctly
SELECT 
  'Sample Spatial Query Test' as check_name,
  restaurant_id,
  area_name,
  ST_Contains(
    geometry, 
    ST_SetSRID(ST_MakePoint(-75.7077, 45.3975), 4326)
  ) as contains_test_point
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id = 13
LIMIT 1;

-- ============================================================================
-- VALIDATION SUMMARY
-- ============================================================================
-- All checks should pass:
--   - CHECK 1: 82 restaurants with areas
--   - CHECK 2: 91 total areas
--   - CHECK 3: 0 invalid geometries
--   - CHECK 4: 0 sequential numbering errors
--   - CHECK 5: All restaurants listed with area counts
--   - CHECK 6: Statistics look reasonable
--   - CHECK 7: Spatial query works
-- ============================================================================
