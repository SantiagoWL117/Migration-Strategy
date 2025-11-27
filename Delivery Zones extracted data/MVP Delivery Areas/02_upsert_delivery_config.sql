-- Update restaurant_delivery_config for MVP restaurants
-- Based on V1 data extraction from restaurants_dump.sql

-- Lucky Star Chinese Food (V1 ID: 90)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (8, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Champa Thai Cuisine (V1 ID: 203)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (87, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Ginkgo Garden (V1 ID: 224)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (105, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Hung Mein (V1 ID: 239)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (119, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Orchid Sushi (V1 ID: 387)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (245, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';
