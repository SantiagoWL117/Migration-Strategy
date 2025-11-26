-- Insert delivery fees for batch_91_120

-- Milano (V1: 824, V3: 601)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (601, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (601, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Papa Pizza Cantley (V1: 825, V3: 602)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (602, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;

-- Aroy Thai (V1: 830, V3: 607)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (607, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Marina Pizza des Flandres (V1: 838, V3: 614)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (614, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Papa Grecque Maloney (V1: 840, V3: 616)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (616, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Milano (V1: 850, V3: 624)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (624, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Asia Garden Ottawa (V1: 856, V3: 630)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (630, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (630, 'distance', 1, 3.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.5;

-- Joes Family Pizzeria (V1: 863, V3: 636)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (636, 'distance', 1, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (636, 'distance', 1, 6.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 6.99;

-- Digby's Restaurant (V1: 865, V3: 638)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (638, 'distance', 1, 1.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.5;

-- China Moon (V1: 869, V3: 641)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (641, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;

-- Mozza Pizza Hull (V1: 872, V3: 644)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (644, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 879, V3: 651)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (651, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 889, V3: 660)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (660, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;

-- Milano (V1: 913, V3: 680)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (680, 'distance', 1, 2.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (680, 'distance', 1, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (680, 'distance', 2, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (680, 'distance', 3, 3.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.99;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (680, 'distance', 4, 4.99, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.99;

-- Oka's Hull (V1: 914, V3: 681)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (681, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (681, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Pizza Maisonneuve (V1: 930, V3: 696)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (696, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;

-- Milano (V1: 937, V3: 701)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (701, 'distance', 1, 0.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 0.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (701, 'distance', 1, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- Supreme Pizzeria (V1: 947, V3: 711)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (711, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;

-- Patate Lou Lou (V1: 948, V3: 712)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (712, 'distance', 1, 3.25, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.25;

-- Ogilvie Pizza (V1: 951, V3: 714)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (714, 'distance', 1, 1.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 1.5;

-- La Poutinerie Ogilvie (V1: 952, V3: 715)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (715, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- PizzaRama (V1: 953, V3: 716)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (716, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (716, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Pizza Joanna (V1: 964, V3: 726)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (726, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (726, 'distance', 1, 4.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 4.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (726, 'distance', 2, 5.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 5.0;

-- La Maison du Burger (V1: 965, V3: 727)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (727, 'distance', 1, 2.25, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.25;

-- Friendly Restaurant and Pizzeria (V1: 968, V3: 730)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (730, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (730, 'distance', 1, 6.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 6.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (730, 'distance', 2, 8.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 8.5;

-- Amicci Pizza (V1: 973, V3: 735)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (735, 'distance', 1, 2.5, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.5;
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (735, 'distance', 1, 3.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 3.0;

-- Greber Pizza et Shawarma (V1: 974, V3: 736)
INSERT INTO menuca_v3.restaurant_delivery_fees (restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) VALUES (736, 'distance', 1, 2.0, NULL) ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = 2.0;

