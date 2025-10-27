-- MenuCA V3 Data Correction Scripts
-- Based on analysis of corruption patterns found in production data
-- Run these in order to fix the migration issues

-- ========================================
-- SCRIPT 1: Remove Duplicate Dishes
-- ========================================
-- Problem: Same dish name with null course_id appears multiple times per restaurant
-- Solution: Keep only the dish with the lowest ID (first migrated)

WITH duplicate_dishes AS (
    SELECT 
        restaurant_id,
        name,
        description,
        MIN(id) as keep_id,
        COUNT(*) as duplicate_count
    FROM menuca_v3.dishes 
    WHERE deleted_at IS NULL
    GROUP BY restaurant_id, name, description
    HAVING COUNT(*) > 1
),
dishes_to_delete AS (
    SELECT d.id
    FROM menuca_v3.dishes d
    JOIN duplicate_dishes dd ON 
        d.restaurant_id = dd.restaurant_id 
        AND d.name = dd.name 
        AND (d.description = dd.description OR (d.description IS NULL AND dd.description IS NULL))
    WHERE d.id != dd.keep_id
)
UPDATE menuca_v3.dishes 
SET deleted_at = NOW(), 
    deleted_by = 1 -- System cleanup
WHERE id IN (SELECT id FROM dishes_to_delete);

-- ========================================
-- SCRIPT 2: Remove Duplicate Courses  
-- ========================================
-- Problem: Same course name appears multiple times per restaurant
-- Solution: Keep only the course with the lowest ID

WITH duplicate_courses AS (
    SELECT 
        restaurant_id,
        name,
        MIN(id) as keep_id,
        COUNT(*) as duplicate_count
    FROM menuca_v3.courses
    WHERE deleted_at IS NULL
    GROUP BY restaurant_id, name
    HAVING COUNT(*) > 1
),
courses_to_delete AS (
    SELECT c.id
    FROM menuca_v3.courses c
    JOIN duplicate_courses dc ON 
        c.restaurant_id = dc.restaurant_id 
        AND c.name = dc.name
    WHERE c.id != dc.keep_id
)
UPDATE menuca_v3.courses
SET deleted_at = NOW(),
    deleted_by = 1
WHERE id IN (SELECT id FROM courses_to_delete);

-- ========================================
-- SCRIPT 3: Fix Orphaned Dishes (null course_id)
-- ========================================
-- Problem: Dishes with course_id = NULL can't be displayed
-- Solution: Create "Uncategorized" course and assign orphaned dishes

INSERT INTO menuca_v3.courses (restaurant_id, name, display_order, created_at, updated_at)
SELECT DISTINCT 
    d.restaurant_id,
    'Uncategorized' as name,
    999 as display_order,
    NOW() as created_at,
    NOW() as updated_at
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.deleted_at IS NULL 
  AND d.course_id IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.courses c2 
      WHERE c2.restaurant_id = d.restaurant_id 
        AND c2.name = 'Uncategorized' 
        AND c2.deleted_at IS NULL
  );

-- Update orphaned dishes to use the Uncategorized course
UPDATE menuca_v3.dishes 
SET course_id = (
    SELECT c.id 
    FROM menuca_v3.courses c 
    WHERE c.restaurant_id = dishes.restaurant_id 
      AND c.name = 'Uncategorized'
      AND c.deleted_at IS NULL
),
updated_at = NOW()
WHERE deleted_at IS NULL 
  AND course_id IS NULL;

-- ========================================
-- SCRIPT 4: Remove Duplicate Ingredient Groups
-- ========================================
-- Problem: Same ingredient group appears multiple times per restaurant
-- Solution: Keep the one with the most ingredients

WITH duplicate_ingredient_groups AS (
    SELECT 
        restaurant_id,
        name,
        MIN(id) as keep_id
    FROM menuca_v3.ingredient_groups
    WHERE deleted_at IS NULL
    GROUP BY restaurant_id, name
    HAVING COUNT(*) > 1
)
UPDATE menuca_v3.ingredient_groups
SET deleted_at = NOW(),
    deleted_by = 1
WHERE id NOT IN (SELECT keep_id FROM duplicate_ingredient_groups)
  AND (restaurant_id, name) IN (
      SELECT restaurant_id, name FROM duplicate_ingredient_groups
  );

-- ========================================
-- SCRIPT 5: Create Missing Prices for Dishes
-- ========================================
-- Problem: 533 restaurants have dishes but no prices
-- Solution: Create default $0.01 prices (better than NULL for frontend)

INSERT INTO menuca_v3.dish_prices (dish_id, price, cost, created_at, updated_at)
SELECT 
    d.id as dish_id,
    0.01 as price,  -- Minimal price to indicate "needs pricing"
    0.00 as cost,
    NOW() as created_at,
    NOW() as updated_at
FROM menuca_v3.dishes d
WHERE d.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dish_prices dp 
      WHERE dp.dish_id = d.id AND dp.deleted_at IS NULL
  );

-- ========================================
-- SCRIPT 6: Fix Multiple Prices Per Dish
-- ========================================  
-- Problem: 481 dishes have multiple prices
-- Solution: Keep the highest price (assume latest/correct)

WITH dishes_with_multiple_prices AS (
    SELECT 
        dp.dish_id,
        MAX(dp.price) as max_price,
        MIN(dp.id) as keep_id
    FROM menuca_v3.dish_prices dp
    WHERE dp.deleted_at IS NULL
    GROUP BY dp.dish_id
    HAVING COUNT(*) > 1
),
prices_to_delete AS (
    SELECT dp.id
    FROM menuca_v3.dish_prices dp
    JOIN dishes_with_multiple_prices dmp ON dp.dish_id = dmp.dish_id
    WHERE dp.price != dmp.max_price
       OR (dp.price = dmp.max_price AND dp.id != dmp.keep_id)
)
UPDATE menuca_v3.dish_prices
SET deleted_at = NOW(),
    deleted_by = 1
WHERE id IN (SELECT id FROM prices_to_delete);

-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these after the corrections to verify success:

-- Should return 0 duplicates:
SELECT COUNT(*) as remaining_duplicate_dishes
FROM (
    SELECT restaurant_id, name, description, COUNT(*)
    FROM menuca_v3.dishes 
    WHERE deleted_at IS NULL
    GROUP BY restaurant_id, name, description
    HAVING COUNT(*) > 1
) dups;

-- Should return 0 restaurants without prices:
SELECT COUNT(*) as restaurants_without_prices
FROM menuca_v3.restaurants r
WHERE r.deleted_at IS NULL 
  AND EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL)
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dishes d 
      JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id 
      WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL AND dp.deleted_at IS NULL
  );

-- Should return 0 dishes with multiple prices:
SELECT COUNT(*) as dishes_with_multiple_prices
FROM (
    SELECT dish_id
    FROM menuca_v3.dish_prices
    WHERE deleted_at IS NULL
    GROUP BY dish_id
    HAVING COUNT(*) > 1
) multi;
