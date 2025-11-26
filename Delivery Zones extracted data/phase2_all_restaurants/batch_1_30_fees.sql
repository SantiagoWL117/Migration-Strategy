-- Insert delivery fees for batch_1_30

-- Mama Rosa (V1: 94, V3: 12)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (12, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Papa Joe's Pizza - Downtown (V1: 95, V3: 13)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (13, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- House of Lasagna (V1: 117, V3: 22)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (22, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Milano (V1: 127, V3: 31)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (31, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Mozza Pizza Gatineau (V1: 132, V3: 1011)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1011, 'distance', 1, 4.89, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.89;

-- Kiki Lebanese Pineview Pizza (V1: 142, V3: 44)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (44, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (44, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;

-- Bobbie's Pizza & Subs (V1: 143, V3: 45)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (45, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Mr Mozzarella - Nepean (V1: 145, V3: 47)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (47, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

-- Merivale Pizza & Wings (V1: 146, V3: 48)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (48, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Milano (V1: 161, V3: 55)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (55, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 164, V3: 57)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (57, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 172, V3: 59)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (59, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Roulas Grecque et Pizza (V1: 173, V3: 1016)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1016, 'distance', 1, 4.95, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.95;

-- Number One Chinese Take Out (V1: 179, V3: 65)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (65, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Aylmer BBQ (V1: 183, V3: 69)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (69, 'distance', 1, 2.25, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.25;

-- Papa Pizza - Hull (V1: 184, V3: 70)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (70, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Cathay Restaurants (V1: 187, V3: 72)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (72, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

-- Milano (V1: 190, V3: 75)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (75, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

-- Lorenzo's Pizzeria - Vanier (V1: 192, V3: 77)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (77, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- The Original Georgie's (V1: 200, V3: 84)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (84, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (84, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (84, 'distance', 2, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (84, 'distance', 3, 10.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 10.0;

-- Milano (V1: 204, V3: 88)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (88, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (88, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (88, 'distance', 2, 6.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 6.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (88, 'distance', 3, 7.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 7.0;

-- Milano (V1: 205, V3: 89)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (89, 'distance', 1, 1.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (89, 'distance', 1, 7.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 7.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (89, 'distance', 2, 10.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 10.0;

-- Milano (V1: 206, V3: 90)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (90, 'distance', 1, 1.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.99;

-- Milano (V1: 207, V3: 91)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (91, 'distance', 1, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;

-- Milano (V1: 208, V3: 92)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (92, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

