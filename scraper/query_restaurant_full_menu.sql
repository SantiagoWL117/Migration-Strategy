-- Single comprehensive query to get all restaurant menu information
-- Usage for Supabase SQL Editor: Change the restaurant_id value below

-- =====================================================================
-- CONFIGURATION: Change the restaurant ID here
-- =====================================================================
WITH config AS (
    SELECT 924 AS restaurant_id  -- <<<< CHANGE THIS VALUE
)

-- Main query: Join everything together
SELECT 
    restaurants.id as restaurant_id,
    restaurants.name as restaurant_name,
    restaurant_locations.street_address as address,
    restaurants.created_at,
    courses.id as course_id,
    courses.name as course_name,
    courses.description as course_description,
    courses.display_order as course_order,
    dishes.id as dish_id,
    dishes.name as dish_name,
    dishes.description as dish_description,
    dishes.display_order as dish_order,
    dish_prices.size_variant,
    dish_prices.price,
    dish_prices.display_order as price_order,
    modifier_groups.id as modifier_group_id,
    modifier_groups.name as modifier_group_name,
    dish_modifiers.modifier_type,
    modifier_groups.min_selections,
    modifier_groups.max_selections,
    dish_modifier_prices.id as modifier_price_id,
    dish_modifiers.name as modifier_name,
    dish_modifier_prices.price as modifier_price,
    dish_modifier_prices.display_order as modifier_order
FROM menuca_v3.restaurants
CROSS JOIN config
LEFT JOIN menuca_v3.restaurant_locations ON restaurants.id = restaurant_locations.restaurant_id 
    AND restaurant_locations.deleted_at IS NULL
LEFT JOIN menuca_v3.courses ON restaurants.id = courses.restaurant_id 
    AND courses.deleted_at IS NULL
LEFT JOIN menuca_v3.dishes ON courses.id = dishes.course_id 
    AND dishes.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_prices ON dishes.id = dish_prices.dish_id 
    AND dish_prices.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifiers ON dishes.id = dish_modifiers.dish_id 
    AND dish_modifiers.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups ON dish_modifiers.modifier_group_id = modifier_groups.id
LEFT JOIN menuca_v3.dish_modifier_prices ON dish_modifiers.id = dish_modifier_prices.dish_modifier_id 
    AND dish_modifier_prices.deleted_at IS NULL
WHERE restaurants.id = config.restaurant_id
ORDER BY courses.display_order, dishes.display_order, dish_prices.display_order, 
         modifier_groups.name, dish_modifier_prices.display_order;
