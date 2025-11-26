-- Insert delivery fees for batch_151_159

-- Milano (V1: 1082, V3: 835)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (835, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Souvlaki Souvlaki (V1: 1083, V3: 836)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (836, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Milano (V1: 1084, V3: 837)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (837, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Milano (V1: 1087, V3: 840)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (840, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 1089, V3: 842)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (842, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Mykonos Greek Grill (V1: 1092, V3: 845)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (845, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (845, 'distance', 1, 5.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.99;

-- Mykonos Greek Grill (V1: 1093, V3: 846)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (846, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (846, 'distance', 1, 5.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.99;

