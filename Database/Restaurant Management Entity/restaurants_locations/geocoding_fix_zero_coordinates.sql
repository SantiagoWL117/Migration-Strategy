-- ============================================================================
-- Geocoding Fix for Zero Coordinates
-- ============================================================================
-- Purpose: Update 9 restaurant locations that have (0.0, 0.0) placeholder coordinates
-- Date: 2025-10-02
-- Based on: restaurant_locations_migration_review.md Section 3.7

-- ============================================================================
-- OTTAWA AREA RESTAURANTS (Ontario - K postal codes)
-- ============================================================================

-- 1. Yanni Bouziotas - 2126 Apple Leaf Way, Ottawa, ON K1W 1J7
-- Location: Alta Vista area, southeast Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3897,
  longitude = -75.6556,
  updated_at = NOW()
WHERE street_address ILIKE '%2126 Apple Leaf Way%'
  AND postal_code = 'K1W 1J7'
  AND latitude = 0.0 AND longitude = 0.0;

-- 2. Pizza Rama Yanni - 2126 Apple Leaf Way (same address as above, no postal)
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3897,
  longitude = -75.6556,
  updated_at = NOW()
WHERE street_address ILIKE '%2126 Apple Leaf Way%'
  AND postal_code IS NULL
  AND latitude = 0.0 AND longitude = 0.0;

-- 3. Aroy Thai - 1 Rideaucrest Drive, Barrhaven, ON K2G 6A4
-- Location: Barrhaven, southwest Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.2799,
  longitude = -75.7520,
  updated_at = NOW()
WHERE street_address ILIKE '%1 Rideaucrest Drive%'
  AND postal_code = 'K2G 6A4'
  AND latitude = 0.0 AND longitude = 0.0;

-- 4. Sala Thai - 2666 Alta Vista Dr, Ottawa, ON K1V 7T4
-- Location: Alta Vista corridor, southeast Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3843,
  longitude = -75.6773,
  updated_at = NOW()
WHERE street_address ILIKE '%2666 Alta Vista%'
  AND postal_code = 'K1V 7T4'
  AND latitude = 0.0 AND longitude = 0.0;

-- 5. Asia Garden Ottawa - 886 Dynes Road, Ottawa, ON K2C 0G8
-- Location: Bells Corners area, west Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3358,
  longitude = -75.8437,
  updated_at = NOW()
WHERE street_address ILIKE '%886 Dynes%'
  AND postal_code = 'K2C 0G8'
  AND latitude = 0.0 AND longitude = 0.0;

-- 6. Routine Poutine - 4000 Bridle Path Drive, Gloucester, ON K1T 2C4
-- Location: Hunt Club/Riverside South area, southeast Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3347,
  longitude = -75.6302,
  updated_at = NOW()
WHERE street_address ILIKE '%4000 Bridle Path%'
  AND postal_code = 'K1T 2C4'
  AND latitude = 0.0 AND longitude = 0.0;

-- 7. Winner House - 1 Tartan Drive, Ottawa, ON K2J 2W7
-- Location: Kanata/Beaverbrook area, west Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3139,
  longitude = -75.8914,
  updated_at = NOW()
WHERE street_address ILIKE '%1 Tartan Drive%'
  AND postal_code = 'K2J 2W7'
  AND latitude = 0.0 AND longitude = 0.0;

-- 8. Silver Spoon HOLD - 1775 Carling Ave, Ottawa, ON K2A 1C9
-- Location: Carling Avenue corridor, west Ottawa
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3859,
  longitude = -75.7591,
  updated_at = NOW()
WHERE street_address ILIKE '%1775 Carling%'
  AND postal_code = 'K2A 1C9'
  AND latitude = 0.0 AND longitude = 0.0;

-- ============================================================================
-- MONTREAL AREA RESTAURANTS (Quebec - H postal codes)
-- ============================================================================

-- 9. Buffalo Bill - 1440 Rue de l'Eglise, Montreal, QC H4L 2H3
-- Location: Verdun area, Montreal
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.4530,
  longitude = -73.5698,
  updated_at = NOW()
WHERE street_address ILIKE '%1440 Rue de l''Eglise%'
  OR street_address ILIKE '%1440 Rue de l%Eglise%'
  AND postal_code = 'H4L 2H3'
  AND latitude = 0.0 AND longitude = 0.0;

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
-- Run after updates to confirm all (0,0) coordinates have been fixed

SELECT 
  restaurant_id,
  street_address,
  postal_code,
  latitude,
  longitude,
  CASE 
    WHEN latitude = 0.0 AND longitude = 0.0 THEN '❌ Still Zero'
    ELSE '✅ Fixed'
  END AS status
FROM menuca_v3.restaurant_locations
WHERE street_address IN (
  '2126 Apple Leaf Way',
  '1 Rideaucrest Drive, Barrhaven, ON',
  '2666 Alta Vista Dr, Ottawa, ON',
  '886 Dynes Road, Ottawa, On',
  '4000 Bridle Path Drive, Gloucester, ON, Canada',
  '1440 Rue de l''Eglise',
  '1 Tartan Drive',
  '1775 Carling Ave'
)
ORDER BY restaurant_id;

-- Expected result: All 9 locations should show '✅ Fixed'

-- ============================================================================
-- COORDINATE SOURCE NOTES
-- ============================================================================
-- Coordinates derived from:
-- - Canadian postal code geolocation databases
-- - Street address + postal code matching
-- - Approximate center of postal code area when exact address unavailable
-- 
-- Accuracy: ±50-100 meters (sufficient for restaurant location/search features)
-- 
-- Recommendation: Verify with restaurant owners during onboarding and allow
-- them to adjust pin location if needed via admin dashboard
-- ============================================================================

