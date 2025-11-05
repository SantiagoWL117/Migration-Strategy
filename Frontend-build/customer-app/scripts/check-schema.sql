-- ================================================
-- Database Schema Check for Yelp Integration
-- Run this to verify your database is ready
-- ================================================

-- 1. Check if restaurant_reviews table exists
-- ================================================
SELECT
  table_name,
  table_schema
FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
  AND table_name = 'restaurant_reviews';

-- Expected: 1 row with table_name = 'restaurant_reviews'


-- 2. Check restaurant_reviews table structure
-- ================================================
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name = 'restaurant_reviews'
ORDER BY ordinal_position;

-- Required columns for Yelp integration:
-- - id (primary key)
-- - restaurant_id (foreign key to restaurants)
-- - user_id (can be NULL for external reviews)
-- - order_id (can be NULL for external reviews)
-- - rating (integer 1-5)
-- - review_text (text)
-- - created_at (timestamp)
-- - source (text, e.g., 'yelp', 'menu.ca')
-- - external_review_id (text, nullable)
-- - external_user_name (text, nullable)
-- - external_user_image (text, nullable)
-- - yelp_business_id (text, nullable)
-- - yelp_business_url (text, nullable)


-- 3. Check if required columns exist
-- ================================================
SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_reviews'
        AND column_name = 'restaurant_id'
    ) THEN '✓' ELSE '✗'
  END as has_restaurant_id,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_reviews'
        AND column_name = 'rating'
    ) THEN '✓' ELSE '✗'
  END as has_rating,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_reviews'
        AND column_name = 'review_text'
    ) THEN '✓' ELSE '✗'
  END as has_review_text,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_reviews'
        AND column_name = 'source'
    ) THEN '✓' ELSE '✗'
  END as has_source;

-- All should show '✓'


-- 4. Check foreign key to restaurants table
-- ================================================
SELECT
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'menuca_v3.restaurant_reviews'::regclass
  AND contype = 'f';

-- Should show foreign key to restaurants table


-- 5. Check current review count
-- ================================================
SELECT
  COUNT(*) as total_reviews,
  COUNT(CASE WHEN source = 'yelp' THEN 1 END) as yelp_reviews,
  COUNT(CASE WHEN source = 'menu.ca' THEN 1 END) as menuca_reviews
FROM menuca_v3.restaurant_reviews;

-- Before import: yelp_reviews should be 0


-- 6. Check active restaurants count
-- ================================================
SELECT
  COUNT(*) as total_active_restaurants,
  COUNT(CASE WHEN rl.id IS NOT NULL THEN 1 END) as with_location
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id AND rl.is_active = true
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true;

-- Expected: ~75 restaurants with locations


-- 7. Sample restaurant data for matching
-- ================================================
SELECT
  r.id,
  r.name,
  rl.phone,
  rl.street_address,
  rl.postal_code
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id AND rl.is_active = true
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true
LIMIT 5;

-- Verify restaurants have phone and address data


-- 8. If table doesn't exist, here's a migration to create it
-- ================================================
-- UNCOMMENT BELOW IF TABLE DOESN'T EXIST

-- CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_reviews (
--   id BIGSERIAL PRIMARY KEY,
--   restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
--   user_id INTEGER REFERENCES menuca_v3.users(id) ON DELETE SET NULL,
--   order_id INTEGER REFERENCES menuca_v3.orders(id) ON DELETE SET NULL,
--   rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
--   review_text TEXT,
--   source VARCHAR(50) DEFAULT 'menu.ca' CHECK (source IN ('menu.ca', 'yelp')),
--   external_review_id VARCHAR(255),
--   external_user_name VARCHAR(255),
--   external_user_image TEXT,
--   yelp_business_id VARCHAR(255),
--   yelp_business_url TEXT,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--   deleted_at TIMESTAMP WITH TIME ZONE,
--   deleted_by INTEGER
-- );

-- CREATE INDEX idx_restaurant_reviews_restaurant_id ON menuca_v3.restaurant_reviews(restaurant_id);
-- CREATE INDEX idx_restaurant_reviews_source ON menuca_v3.restaurant_reviews(source);
-- CREATE INDEX idx_restaurant_reviews_yelp_business_id ON menuca_v3.restaurant_reviews(yelp_business_id);
-- CREATE INDEX idx_restaurant_reviews_created_at ON menuca_v3.restaurant_reviews(created_at DESC);


-- 9. If missing columns, here's how to add them
-- ================================================
-- UNCOMMENT IF NEEDED

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'menu.ca';

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS external_review_id VARCHAR(255);

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS external_user_name VARCHAR(255);

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS external_user_image TEXT;

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS yelp_business_id VARCHAR(255);

-- ALTER TABLE menuca_v3.restaurant_reviews
-- ADD COLUMN IF NOT EXISTS yelp_business_url TEXT;

-- CREATE INDEX IF NOT EXISTS idx_restaurant_reviews_source
--   ON menuca_v3.restaurant_reviews(source);

-- CREATE INDEX IF NOT EXISTS idx_restaurant_reviews_yelp_business_id
--   ON menuca_v3.restaurant_reviews(yelp_business_id);
