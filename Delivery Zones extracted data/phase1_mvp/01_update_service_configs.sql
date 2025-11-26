-- Update restaurant_service_configs for MVP restaurants
-- Based on V1 data extraction from restaurants_dump.sql

-- Lucky Star Chinese Food (V1 ID: 90)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 60 WHERE restaurant_id = 8;

-- Champa Thai Cuisine (V1 ID: 203)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 30.0, delivery_time_minutes = 55 WHERE restaurant_id = 87;

-- Ginkgo Garden (V1 ID: 224)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 17.0, delivery_time_minutes = 60 WHERE restaurant_id = 105;

-- Hung Mein (V1 ID: 239)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 55 WHERE restaurant_id = 119;

-- Orchid Sushi (V1 ID: 387)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 45 WHERE restaurant_id = 245;
