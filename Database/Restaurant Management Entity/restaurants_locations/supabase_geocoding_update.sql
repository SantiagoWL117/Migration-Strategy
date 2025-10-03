-- ============================================================================
-- Supabase-Compatible Geocoding Update for Zero Coordinates
-- ============================================================================
-- Purpose: Update 9 restaurant locations with correct lat/long coordinates
-- Date: 2025-10-02
-- Target: menuca_v3.restaurant_locations
-- ============================================================================

-- Begin transaction - all updates will succeed or all will rollback
BEGIN;

-- Update restaurants one by one using their unique addresses

-- 1. Yanni Bouziotas - 2126 Apple Leaf Way, Ottawa, ON K1W 1J7
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3897,
  longitude = -75.6556,
  updated_at = NOW()
WHERE street_address = '2126 Apple Leaf Way'
  AND postal_code = 'K1W 1J7'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 2. Pizza Rama Yanni - 2126 Apple Leaf Way (no postal code)
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3897,
  longitude = -75.6556,
  updated_at = NOW()
WHERE street_address = '2126 Apple Leaf Way'
  AND postal_code IS NULL
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 3. Aroy Thai - 1 Rideaucrest Drive, Barrhaven, ON K2G 6A4
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.2799,
  longitude = -75.7520,
  updated_at = NOW()
WHERE street_address = '1 Rideaucrest Drive, Barrhaven, ON'
  AND postal_code = 'K2G 6A4'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 4. Sala Thai - 2666 Alta Vista Dr, Ottawa, ON K1V 7T4
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3843,
  longitude = -75.6773,
  updated_at = NOW()
WHERE street_address = '2666 Alta Vista Dr, Ottawa, ON'
  AND postal_code = 'K1V 7T4'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 5. Asia Garden Ottawa - 886 Dynes Road, Ottawa, On K2C 0G8
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3358,
  longitude = -75.8437,
  updated_at = NOW()
WHERE street_address = '886 Dynes Road, Ottawa, On'
  AND postal_code = 'K2C 0G8'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 6. Routine Poutine - 4000 Bridle Path Drive, Gloucester, ON, Canada K1T 2C4
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3347,
  longitude = -75.6302,
  updated_at = NOW()
WHERE street_address = '4000 Bridle Path Drive, Gloucester, ON, Canada'
  AND postal_code = 'K1T 2C4'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 7. Buffalo Bill - 1440 Rue de l'Eglise, Montreal, QC H4L 2H3
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.4530,
  longitude = -73.5698,
  updated_at = NOW()
WHERE street_address = '1440 Rue de l''Eglise'
  AND postal_code = 'H4L 2H3'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 8. Winner House - 1 Tartan Drive, Ottawa, ON K2J 2W7
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3139,
  longitude = -75.8914,
  updated_at = NOW()
WHERE street_address = '1 Tartan Drive'
  AND postal_code = 'K2J 2W7'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- 9. Silver Spoon HOLD - 1775 Carling Ave, Ottawa, ON K2A 1C9
UPDATE menuca_v3.restaurant_locations
SET 
  latitude = 45.3859,
  longitude = -75.7591,
  updated_at = NOW()
WHERE street_address = '1775 Carling Ave'
  AND postal_code = 'K2A 1C9'
  AND latitude = 0.0 
  AND longitude = 0.0;

-- ============================================================================
-- VERIFICATION: Check that all updates were successful
-- ============================================================================

SELECT 
  restaurant_id,
  street_address,
  postal_code,
  ROUND(latitude::numeric, 4) as latitude,
  ROUND(longitude::numeric, 4) as longitude,
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

-- Expected: All 9 rows should show status = '✅ Fixed'

-- ============================================================================
-- Pre-commit check: Verify all updates before committing
-- ============================================================================

-- Count updates that will be committed
DO $$
DECLARE
  updated_count INTEGER;
  remaining_zeros INTEGER;
BEGIN
  -- Count how many records were updated
  SELECT COUNT(*) INTO updated_count
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
  AND latitude != 0.0 AND longitude != 0.0;

  -- Count remaining zero coordinates
  SELECT COUNT(*) INTO remaining_zeros
  FROM menuca_v3.restaurant_locations
  WHERE latitude = 0.0 AND longitude = 0.0;

  RAISE NOTICE 'Updated records: %', updated_count;
  RAISE NOTICE 'Remaining zero coordinates: %', remaining_zeros;

  IF updated_count < 9 THEN
    RAISE EXCEPTION 'Expected to update 9 records, but only updated %. Rolling back.', updated_count;
  END IF;

  IF remaining_zeros > 0 THEN
    RAISE WARNING 'There are still % records with zero coordinates (may be unrelated restaurants)', remaining_zeros;
  END IF;
END $$;

-- Commit the transaction if all checks passed
COMMIT;

-- ============================================================================
-- Post-commit verification
-- ============================================================================

-- Final check: Count remaining zero coordinates
SELECT COUNT(*) AS remaining_zero_coords
FROM menuca_v3.restaurant_locations
WHERE latitude = 0.0 AND longitude = 0.0;

-- Expected: 0 rows

-- Show updated restaurants
SELECT 
  restaurant_id,
  street_address,
  postal_code,
  ROUND(latitude::numeric, 4) as latitude,
  ROUND(longitude::numeric, 4) as longitude,
  '✅ Updated' as status
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

