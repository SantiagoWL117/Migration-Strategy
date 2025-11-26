-- Insert delivery fees for batch_61_90

-- Shaan Tandoori (V1: 415, V3: 269)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (269, 'distance', 1, 4.95, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.95;

-- JN Pizza (V1: 489, V3: 328)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (328, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (328, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Sushi Express Chambly (V1: 511, V3: 1017)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1017, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1017, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Milano (V1: 513, V3: 350)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (350, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (350, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Xtreme Pizza (V1: 532, V3: 367)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (367, 'distance', 1, 1.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.5;

-- Yorgo's - Nepean (V1: 547, V3: 985)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (985, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (985, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

-- Papa Joe's Fried Chicken - Downtown (V1: 612, V3: 437)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (437, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

-- Ting's Kitchen (V1: 694, V3: 941)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (941, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Light of India (V1: 695, V3: 491)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (491, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Rangoli (V1: 701, V3: 497)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (497, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Papa Pizza Val-Des-Monts (V1: 703, V3: 1014)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (1014, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

-- New Hong Kong (V1: 707, V3: 502)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (502, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Pizza Lovers Hunt Club (V1: 712, V3: 507)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (507, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

-- Egg Roll Factory (V1: 716, V3: 511)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (511, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Napolis (V1: 721, V3: 515)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (515, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Palermo Pizzeria (V1: 729, V3: 521)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (521, 'distance', 1, 1.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (521, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (521, 'distance', 2, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;

-- Papa Grecque des Flandres (V1: 758, V3: 540)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (540, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Aahar The Taste of India (V1: 781, V3: 561)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (561, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Pizza des Hautes Plaines (V1: 782, V3: 562)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (562, 'distance', 1, 2.95, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.95;

-- Milano (V1: 785, V3: 565)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (565, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

-- Milano (V1: 789, V3: 569)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (569, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (569, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Crispy's (V1: 805, V3: 584)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (584, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;

-- Milano (V1: 807, V3: 586)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (586, 'distance', 1, 1.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (586, 'distance', 1, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (586, 'distance', 2, 6.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 6.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (586, 'distance', 3, 9.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 9.99;

-- Supreme Pizzeria (V1: 817, V3: 595)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (595, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Sushi Fleury (V1: 818, V3: 596)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (596, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (596, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

