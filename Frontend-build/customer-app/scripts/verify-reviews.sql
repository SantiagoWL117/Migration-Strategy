-- ================================================
-- Yelp Reviews Verification Queries
-- Use these queries to verify data after running the import script
-- ================================================

-- 1. OVERVIEW: Total reviews imported
-- ================================================
SELECT
  source,
  COUNT(*) as total_reviews,
  ROUND(AVG(rating), 2) as avg_rating,
  MIN(created_at) as oldest_review,
  MAX(created_at) as newest_review
FROM menuca_v3.restaurant_reviews
GROUP BY source
ORDER BY total_reviews DESC;

-- Expected output:
-- source | total_reviews | avg_rating | oldest_review | newest_review
-- yelp   | 174          | 4.32       | 2023-01-15    | 2024-10-30


-- 2. COVERAGE: Restaurants with reviews
-- ================================================
SELECT
  COUNT(DISTINCT r.id) as total_active_restaurants,
  COUNT(DISTINCT rv.restaurant_id) as restaurants_with_reviews,
  ROUND(
    COUNT(DISTINCT rv.restaurant_id)::numeric /
    COUNT(DISTINCT r.id) * 100, 1
  ) as coverage_percentage
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id AND rv.source = 'yelp'
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true;

-- Expected output:
-- total_active_restaurants | restaurants_with_reviews | coverage_percentage
-- 75                      | 58                       | 77.3


-- 3. BY RESTAURANT: Reviews per restaurant
-- ================================================
SELECT
  r.id,
  r.name,
  r.slug,
  COUNT(rv.id) as review_count,
  ROUND(AVG(rv.rating), 1) as avg_rating,
  MIN(rv.rating) as min_rating,
  MAX(rv.rating) as max_rating,
  STRING_AGG(DISTINCT rv.yelp_business_id, ', ') as yelp_id
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id AND rv.source = 'yelp'
WHERE r.status = 'active'
GROUP BY r.id, r.name, r.slug
ORDER BY review_count DESC, avg_rating DESC
LIMIT 20;

-- Shows top 20 restaurants by review count


-- 4. RESTAURANTS WITHOUT REVIEWS: Need manual investigation
-- ================================================
SELECT
  r.id,
  r.name,
  r.slug,
  rl.phone,
  rl.street_address,
  rl.postal_code
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id AND rl.is_active = true
LEFT JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id AND rv.source = 'yelp'
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true
  AND rv.id IS NULL
ORDER BY r.name;

-- Use this to manually search these restaurants on Yelp
-- URL format: https://www.yelp.com/search?find_desc={name}&find_loc={address}


-- 5. SAMPLE REVIEWS: View actual review content
-- ================================================
SELECT
  r.name as restaurant,
  rv.rating,
  rv.external_user_name as reviewer,
  rv.review_text as review_excerpt,
  rv.created_at as review_date,
  rv.yelp_business_url
FROM menuca_v3.restaurant_reviews rv
JOIN menuca_v3.restaurants r ON r.id = rv.restaurant_id
WHERE rv.source = 'yelp'
ORDER BY rv.created_at DESC
LIMIT 10;

-- Shows 10 most recent reviews


-- 6. RATING DISTRIBUTION: How many 1-5 star reviews?
-- ================================================
SELECT
  rating,
  COUNT(*) as review_count,
  ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER () * 100, 1) as percentage,
  REPEAT('█', (COUNT(*) / 10)::integer) as bar_chart
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp'
GROUP BY rating
ORDER BY rating DESC;

-- Expected output:
-- rating | review_count | percentage | bar_chart
-- 5      | 85           | 48.9       | ████████
-- 4      | 62           | 35.6       | ██████
-- 3      | 20           | 11.5       | ██
-- 2      | 5            | 2.9        | ▌
-- 1      | 2            | 1.1        | ▌


-- 7. DUPLICATE CHECK: Ensure no duplicate Yelp reviews
-- ================================================
SELECT
  external_review_id,
  COUNT(*) as duplicate_count
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp'
  AND external_review_id IS NOT NULL
GROUP BY external_review_id
HAVING COUNT(*) > 1;

-- Should return 0 rows (no duplicates)


-- 8. DATA QUALITY: Check for missing fields
-- ================================================
SELECT
  COUNT(*) as total_reviews,
  COUNT(CASE WHEN rating IS NULL THEN 1 END) as missing_rating,
  COUNT(CASE WHEN review_text IS NULL OR review_text = '' THEN 1 END) as missing_text,
  COUNT(CASE WHEN external_review_id IS NULL THEN 1 END) as missing_yelp_id,
  COUNT(CASE WHEN external_user_name IS NULL THEN 1 END) as missing_user_name,
  COUNT(CASE WHEN yelp_business_id IS NULL THEN 1 END) as missing_business_id
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp';

-- All counts should be 0 (all fields populated)


-- 9. COMPARISON: Yelp vs Menu.ca reviews (if any)
-- ================================================
SELECT
  source,
  COUNT(*) as review_count,
  ROUND(AVG(rating), 2) as avg_rating,
  COUNT(DISTINCT restaurant_id) as restaurant_count
FROM menuca_v3.restaurant_reviews
GROUP BY source
ORDER BY source;

-- Shows breakdown by source


-- 10. TOP RATED RESTAURANTS: Based on Yelp data
-- ================================================
SELECT
  r.name,
  r.slug,
  COUNT(rv.id) as review_count,
  ROUND(AVG(rv.rating), 1) as avg_rating,
  MAX(rv.yelp_business_url) as yelp_url
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id
WHERE rv.source = 'yelp'
  AND r.status = 'active'
GROUP BY r.id, r.name, r.slug
HAVING COUNT(rv.id) >= 3  -- At least 3 reviews for reliability
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;

-- Shows top 10 restaurants by average Yelp rating


-- 11. RECENT ACTIVITY: When were reviews added?
-- ================================================
SELECT
  DATE(created_at) as review_date,
  COUNT(*) as reviews_added
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp'
GROUP BY DATE(created_at)
ORDER BY review_date DESC
LIMIT 7;

-- Shows review activity by date (last 7 days)


-- 12. REVIEWER ANALYSIS: Most active Yelp reviewers in dataset
-- ================================================
SELECT
  external_user_name as reviewer,
  COUNT(*) as review_count,
  ROUND(AVG(rating), 1) as avg_rating_given,
  COUNT(DISTINCT restaurant_id) as restaurants_reviewed
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp'
  AND external_user_name IS NOT NULL
GROUP BY external_user_name
HAVING COUNT(*) > 1
ORDER BY review_count DESC
LIMIT 10;

-- Shows reviewers who reviewed multiple restaurants


-- 13. EXPORT FOR FRONTEND: Reviews with restaurant details
-- ================================================
SELECT
  rv.id,
  rv.restaurant_id,
  r.name as restaurant_name,
  r.slug as restaurant_slug,
  rv.rating,
  rv.review_text,
  rv.external_user_name as reviewer_name,
  rv.external_user_image as reviewer_image,
  rv.created_at as review_date,
  rv.yelp_business_url,
  rv.source
FROM menuca_v3.restaurant_reviews rv
JOIN menuca_v3.restaurants r ON r.id = rv.restaurant_id
WHERE rv.source = 'yelp'
  AND r.status = 'active'
ORDER BY r.name, rv.created_at DESC;

-- Use this structure for frontend API queries


-- 14. CLEANUP: Delete all Yelp reviews (use with caution!)
-- ================================================
-- UNCOMMENT ONLY IF YOU NEED TO RE-RUN THE IMPORT
-- DELETE FROM menuca_v3.restaurant_reviews
-- WHERE source = 'yelp';

-- To re-import after deletion:
-- npx tsx scripts/fetch-yelp-reviews.ts


-- 15. UPDATE RESTAURANT METADATA: Calculate and store aggregates
-- ================================================
-- This is useful if you have columns in restaurants table for cached stats
-- UPDATE menuca_v3.restaurants r
-- SET
--   average_rating = subq.avg_rating,
--   review_count = subq.review_count
-- FROM (
--   SELECT
--     restaurant_id,
--     ROUND(AVG(rating), 1) as avg_rating,
--     COUNT(*) as review_count
--   FROM menuca_v3.restaurant_reviews
--   WHERE source = 'yelp'
--   GROUP BY restaurant_id
-- ) subq
-- WHERE r.id = subq.restaurant_id;
