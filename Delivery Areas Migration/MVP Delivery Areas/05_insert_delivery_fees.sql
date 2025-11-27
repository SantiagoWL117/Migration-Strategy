-- Insert delivery fees for MVP restaurants
-- Based on V1 fee BLOB deserialization
-- Target table: menuca_v3.restaurant_delivery_fees

-- Lucky Star Chinese Food (V1 ID: 90, V3 ID: 8)
-- 1 fee tier(s)

INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (8, 'distance', 1, 3.00, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.00;

-- Champa Thai Cuisine (V1 ID: 203, V3 ID: 87)
-- 1 fee tier(s)

INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (87, 'distance', 1, 3.00, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.00;

-- Ginkgo Garden (V1 ID: 224, V3 ID: 105)
-- 1 fee tier(s)

INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (105, 'distance', 1, 3.00, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.00;

-- Hung Mein (V1 ID: 239, V3 ID: 119)
-- 1 fee tier(s)

INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (119, 'distance', 1, 3.00, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.00;
