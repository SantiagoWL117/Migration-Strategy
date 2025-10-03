-- ============================================================================
-- Fix V2 Price Arrays → V3 Price Objects
-- ============================================================================
-- Purpose: Convert V2 JSON array prices to V3 JSONB object format
-- Bug: V2 stores prices as ["9.95"] but V3 expects {"default": "9.95"}
-- Date: 2025-10-02
-- ============================================================================

-- STEP 1: Create function to convert V2 array format to V3 object format
CREATE OR REPLACE FUNCTION staging.parse_v2_price_array(price_j_text TEXT)
RETURNS JSONB AS $$
DECLARE
  price_array JSONB;
  prices_obj JSONB := '{}'::jsonb;
  price_count INTEGER;
BEGIN
  -- Handle NULL or empty
  IF price_j_text IS NULL OR TRIM(price_j_text) = '' THEN
    RETURN '{"default": "0.00"}'::jsonb;
  END IF;
  
  -- Try to parse as JSON
  BEGIN
    price_array := price_j_text::jsonb;
  EXCEPTION WHEN OTHERS THEN
    -- If parsing fails, return default
    RETURN '{"default": "0.00"}'::jsonb;
  END;
  
  -- Check if it's an array
  IF jsonb_typeof(price_array) != 'array' THEN
    -- If it's already an object, return it
    IF jsonb_typeof(price_array) = 'object' THEN
      RETURN price_array;
    ELSE
      RETURN '{"default": "0.00"}'::jsonb;
    END IF;
  END IF;
  
  -- Get array length
  price_count := jsonb_array_length(price_array);
  
  -- Convert array to object based on count
  IF price_count = 0 THEN
    prices_obj := '{"default": "0.00"}'::jsonb;
    
  ELSIF price_count = 1 THEN
    -- Single price: {"default": "price"}
    prices_obj := jsonb_build_object('default', price_array->0);
    
  ELSIF price_count = 2 THEN
    -- Two prices: {"small": "p1", "large": "p2"}
    prices_obj := jsonb_build_object(
      'small', price_array->0,
      'large', price_array->1
    );
    
  ELSIF price_count = 3 THEN
    -- Three prices: {"small": "p1", "medium": "p2", "large": "p3"}
    prices_obj := jsonb_build_object(
      'small', price_array->0,
      'medium', price_array->1,
      'large', price_array->2
    );
    
  ELSIF price_count >= 4 THEN
    -- Four or more: {"xsmall": "p1", "small": "p2", "medium": "p3", "large": "p4"}
    prices_obj := jsonb_build_object(
      'xsmall', price_array->0,
      'small', price_array->1,
      'medium', price_array->2,
      'large', price_array->3
    );
  END IF;
  
  RETURN prices_obj;
  
EXCEPTION WHEN OTHERS THEN
  -- Fallback on any error
  RETURN '{"default": "0.00"}'::jsonb;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- TEST THE FUNCTION
-- ============================================================================
SELECT 
  'Test 1: Single price array' as test,
  staging.parse_v2_price_array('["14.95"]') as result,
  '{"default": "14.95"}' as expected;

SELECT 
  'Test 2: Multiple price array' as test,
  staging.parse_v2_price_array('["9.50", "11.00", "12.50"]') as result,
  '{"small": "9.50", "medium": "11.00", "large": "12.50"}' as expected;

-- ============================================================================
-- STEP 2: Create backup before update
-- ============================================================================
CREATE TABLE IF NOT EXISTS staging.v3_dishes_backup_before_v2_price_fix AS
SELECT * FROM staging.v3_dishes 
WHERE prices = '{"default": "0.00"}'::jsonb
  AND restaurant_id IN (SELECT id FROM staging.v2_restaurants);

SELECT 'Backup created: ' || COUNT(*) || ' V2 dishes backed up' as status
FROM staging.v3_dishes_backup_before_v2_price_fix;

-- ============================================================================
-- STEP 3: Update V2 dishes with correct prices
-- ============================================================================

-- Update dishes from V2 source with proper price parsing
UPDATE staging.v3_dishes d
SET 
  prices = staging.parse_v2_price_array(v2d.price_j),
  updated_at = NOW()
FROM staging.v2_restaurants_dishes v2d
JOIN staging.v2_restaurants_courses v2c ON v2d.course_id = v2c.id
WHERE d.name = v2d.name
  AND d.restaurant_id = v2c.restaurant_id
  AND d.prices = '{"default": "0.00"}'::jsonb
  AND v2d.price_j IS NOT NULL
  AND TRIM(v2d.price_j) != '';

-- Show how many were updated
SELECT 
  '✅ Updated V2 dishes with correct prices' as status,
  COUNT(*) as count
FROM staging.v3_dishes d
WHERE d.restaurant_id IN (SELECT id FROM staging.v2_restaurants)
  AND d.prices != '{"default": "0.00"}'::jsonb;

-- ============================================================================
-- STEP 4: Re-activate dishes that now have valid prices
-- ============================================================================

UPDATE staging.v3_dishes
SET 
  is_available = true,
  updated_at = NOW()
WHERE prices != '{"default": "0.00"}'::jsonb
  AND is_available = false
  AND restaurant_id IN (
    SELECT id FROM staging.v2_restaurants WHERE LOWER(active) = 'y'
  );

SELECT 
  '✅ Re-activated V2 dishes with valid prices' as status,
  COUNT(*) as count
FROM staging.v3_dishes
WHERE restaurant_id IN (SELECT id FROM staging.v2_restaurants WHERE LOWER(active) = 'y')
  AND is_available = true
  AND prices != '{"default": "0.00"}'::jsonb;

-- ============================================================================
-- STEP 5: Verification
-- ============================================================================

-- Check V2 active restaurants now
SELECT 
  'V2 Active Restaurants - AFTER FIX' as check_type,
  COUNT(DISTINCT d.restaurant_id) as restaurant_count,
  COUNT(*) as total_dishes,
  COUNT(*) FILTER (WHERE d.prices = '{"default": "0.00"}'::jsonb) as zero_price_dishes,
  COUNT(*) FILTER (WHERE d.prices != '{"default": "0.00"}'::jsonb) as valid_price_dishes,
  COUNT(*) FILTER (WHERE d.is_available = true) as active_dishes,
  ROUND(COUNT(*) FILTER (WHERE d.prices != '{"default": "0.00"}'::jsonb) * 100.0 / COUNT(*), 2) || '%' as valid_price_percentage
FROM staging.v3_dishes d
JOIN staging.v2_restaurants r ON d.restaurant_id = r.id
WHERE LOWER(r.active) = 'y';

-- Sample dishes to verify
SELECT 
  d.restaurant_id,
  d.name,
  d.prices,
  d.is_available,
  'Should be valid now' as note
FROM staging.v3_dishes d
JOIN staging.v2_restaurants r ON d.restaurant_id = r.id
WHERE LOWER(r.active) = 'y'
LIMIT 10;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To undo:
-- UPDATE staging.v3_dishes d
-- SET prices = b.prices, is_available = b.is_available
-- FROM staging.v3_dishes_backup_before_v2_price_fix b
-- WHERE d.id = b.id;
-- ============================================================================

