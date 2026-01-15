-- Move menu_cache from restaurants to separate table
-- Date: January 15, 2026
-- Context: Resolving IO crisis - TOAST data decompression on every PostgREST query

BEGIN;

-- Step 1: Create dedicated cache table
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_menu_cache (
  restaurant_id BIGINT PRIMARY KEY REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  menu_cache_en JSONB,
  menu_cache_fr JSONB,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Step 2: Copy existing cache data
INSERT INTO menuca_v3.restaurant_menu_cache (restaurant_id, menu_cache_en, menu_cache_fr, updated_at)
SELECT id, menu_cache_en, menu_cache_fr, COALESCE(menu_cache_updated_at, now())
FROM menuca_v3.restaurants
WHERE menu_cache_en IS NOT NULL OR menu_cache_fr IS NOT NULL
ON CONFLICT (restaurant_id) DO UPDATE SET
  menu_cache_en = EXCLUDED.menu_cache_en,
  menu_cache_fr = EXCLUDED.menu_cache_fr,
  updated_at = EXCLUDED.updated_at;

-- Step 3: Create index for cache lookups by update time
CREATE INDEX IF NOT EXISTS idx_menu_cache_updated 
ON menuca_v3.restaurant_menu_cache (updated_at DESC);

COMMIT;
