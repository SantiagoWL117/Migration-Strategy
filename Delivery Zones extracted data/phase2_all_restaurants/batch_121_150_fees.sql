-- Insert delivery fees for batch_121_150

-- Milano (V1: 987, V3: 749)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (749, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

-- Milano (V1: 989, V3: 751)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (751, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Colonnade Pizza (V1: 1025, V3: 783)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (783, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Colonnade Pizza (V1: 1027, V3: 784)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (784, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Colonnade Pizza (V1: 1028, V3: 785)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (785, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Poutinerie Québecurds Hull (V1: 1032, V3: 789)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (789, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Nachos Loco Hull (V1: 1033, V3: 790)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (790, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Papa Pizza Chem. de Masson (V1: 1039, V3: 795)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (795, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Papa Burger (V1: 1041, V3: 797)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (797, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Kabylie Pizza (V1: 1042, V3: 798)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (798, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (798, 'distance', 1, 4.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.5;

-- Nachos Loco Gatineau (V1: 1045, V3: 801)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (801, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (801, 'distance', 1, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (801, 'distance', 2, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (801, 'distance', 3, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (801, 'distance', 4, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;

-- Poutinerie Québecurds Gatineau (V1: 1046, V3: 1015)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1015, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1015, 'distance', 1, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1015, 'distance', 2, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1015, 'distance', 3, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1015, 'distance', 4, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;

-- Crispy's Bank Street (V1: 1050, V3: 806)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (806, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Golden Center Pizza (V1: 1059, V3: 815)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (815, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Dépanneur Généreux (V1: 1060, V3: 816)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (816, 'distance', 1, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (816, 'distance', 1, 7.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 7.0;

-- Milano (V1: 1062, V3: 818)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 1, 6.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 6.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 2, 7.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 7.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 3, 9.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 9.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 4, 13.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 13.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 5, 16.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 16.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 6, 28.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 28.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 7, 32.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 32.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (818, 'distance', 8, 40.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 40.0;

-- Milano (V1: 1063, V3: 819)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (819, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (819, 'distance', 1, 5.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.99;

-- Milano (V1: 1065, V3: 821)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (821, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Papa Burger Maloney (V1: 1066, V3: 822)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (822, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Pizzalicious (V1: 1074, V3: 829)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (829, 'distance', 1, 1.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.5;

