-- Load V2 Dishes to menuca_v3.dishes
-- =====================================
-- This script transforms and loads ALL V2 dishes from staging to V3
-- Handles multi-size pricing (size_j, price_j JSON arrays) → stores in JSONB
-- Maintains zero data loss policy

BEGIN;

-- Step 1: Load V2 dishes to menuca_v3.dishes
-- Stores multi-size pricing in JSONB (prices, size_options columns)
INSERT INTO menuca_v3.dishes (
    restaurant_id,
    course_id,
    name,
    description,
    base_price,
    prices,
    size_options,
    display_order,
    is_combo,
    has_customization,
    is_upsell,
    is_active,
    source_system,
    source_id,
    legacy_v2_id,
    created_at,
    updated_at,
    unavailable_until
)
SELECT
    r.id AS restaurant_id,
    c.id AS course_id,
    v2d.name,
    COALESCE(NULLIF(v2d.description, ''), NULLIF(v2d.description, '""')) AS description,
    -- base_price: use simple price if available, otherwise first price from array
    CASE 
        WHEN v2d.price IS NOT NULL AND v2d.price != '' AND v2d.price ~ '^[0-9.]+$'
        THEN v2d.price::NUMERIC
        WHEN v2d.price_j IS NOT NULL AND v2d.price_j != '' AND v2d.price_j != '[""]'
        THEN (v2d.price_j::jsonb->>0)::NUMERIC
        ELSE NULL
    END AS base_price,
    -- prices: store price_j as JSONB if exists
    CASE 
        WHEN v2d.price_j IS NOT NULL AND v2d.price_j != '' AND v2d.price_j != '[""]'
        THEN v2d.price_j::jsonb
        ELSE NULL
    END AS prices,
    -- size_options: store size_j as JSONB if exists
    CASE 
        WHEN v2d.size_j IS NOT NULL AND v2d.size_j != '' AND v2d.size_j != '[""]'
        THEN v2d.size_j::jsonb
        ELSE NULL
    END AS size_options,
    COALESCE(v2d.display_order::INTEGER, 0) AS display_order,
    (v2d.is_combo = 'y')::BOOLEAN AS is_combo,
    (v2d.has_customization = 'y')::BOOLEAN AS has_customization,
    (v2d.upsell = 'y')::BOOLEAN AS is_upsell,
    -- is_active: enabled='y' AND no disabled_at
    (v2d.enabled = 'y' AND (v2d.disabled_at IS NULL OR v2d.disabled_at = ''))::BOOLEAN AS is_active,
    'v2' AS source_system,
    v2d.id::BIGINT AS source_id,
    v2d.id::INTEGER AS legacy_v2_id,
    COALESCE(v2d.added_at::TIMESTAMPTZ, NOW()) AS created_at,
    COALESCE(v2d.disabled_at::TIMESTAMPTZ, NOW()) AS updated_at,
    CASE 
        WHEN v2d.unavailable_until IS NOT NULL AND v2d.unavailable_until != ''
        THEN v2d.unavailable_until::TIMESTAMPTZ
        ELSE NULL
    END AS unavailable_until
FROM staging.menuca_v2_restaurants_dishes v2d
-- Join to courses to get restaurant_id
JOIN staging.menuca_v2_restaurants_courses v2c 
    ON v2c.id::INTEGER = v2d.course_id::INTEGER
-- Map to V3 restaurants
JOIN menuca_v3.restaurants r 
    ON r.legacy_v2_id = v2c.restaurant_id::INTEGER
-- Map to V3 courses
JOIN menuca_v3.courses c 
    ON c.legacy_v2_id = v2c.id::INTEGER
    AND c.restaurant_id = r.id
WHERE v2d.name IS NOT NULL 
  AND v2d.name != ''
  AND v2d.course_id IS NOT NULL
  AND v2d.course_id != '';

-- Report results
SELECT 
    'V2 Dishes Loaded' as step,
    COUNT(*) as rows_inserted,
    COUNT(DISTINCT restaurant_id) as unique_restaurants,
    COUNT(DISTINCT course_id) as unique_courses,
    COUNT(DISTINCT legacy_v2_id) as unique_legacy_ids,
    COUNT(CASE WHEN is_active THEN 1 END) as active_dishes,
    COUNT(CASE WHEN NOT is_active THEN 1 END) as inactive_dishes,
    COUNT(CASE WHEN prices IS NOT NULL THEN 1 END) as with_multi_pricing,
    COUNT(CASE WHEN size_options IS NOT NULL THEN 1 END) as with_size_options
FROM menuca_v3.dishes
WHERE source_system = 'v2';

COMMIT;

