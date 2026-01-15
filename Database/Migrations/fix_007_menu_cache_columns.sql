-- FIX #7: Add Menu Cache Columns to Restaurants Table
-- 
-- This adds pre-computed menu cache columns that store the full menu JSON
-- for both English and French. This reduces response time from ~887ms to <10ms.
--
-- Storage estimate: 186 restaurants × 2 languages × ~1MB avg = ~400MB

-- Step 1: Add cache columns
ALTER TABLE menuca_v3.restaurants 
ADD COLUMN IF NOT EXISTS menu_cache_en jsonb,
ADD COLUMN IF NOT EXISTS menu_cache_fr jsonb,
ADD COLUMN IF NOT EXISTS menu_cache_updated_at timestamptz;

-- Step 2: Add index for cache lookups (though primary key should suffice)
CREATE INDEX IF NOT EXISTS idx_restaurants_menu_cache_updated 
ON menuca_v3.restaurants (menu_cache_updated_at DESC NULLS LAST)
WHERE menu_cache_updated_at IS NOT NULL;

COMMENT ON COLUMN menuca_v3.restaurants.menu_cache_en IS 'Pre-computed English menu JSON from get_restaurant_menu()';
COMMENT ON COLUMN menuca_v3.restaurants.menu_cache_fr IS 'Pre-computed French menu JSON from get_restaurant_menu()';
COMMENT ON COLUMN menuca_v3.restaurants.menu_cache_updated_at IS 'Timestamp of last cache rebuild';
