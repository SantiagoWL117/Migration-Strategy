-- Update restaurant_delivery_config for ALL 164 restaurants
-- Based on V1 data extraction from restaurants_dump.sql

-- Imilio's Pizzeria (V1 ID: 89)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (7, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mama Rosa (V1 ID: 94)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (12, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Joe's Pizza - Downtown (V1 ID: 95)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (13, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- New Mee Fung Restaurant (V1 ID: 101)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (15, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- House of Lasagna (V1 ID: 117)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (22, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Eastview Pizza (V1 ID: 124)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (28, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 127)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (31, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mozza Pizza Gatineau (V1 ID: 132)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1011, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Kiki Lebanese Pineview Pizza (V1 ID: 142)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (44, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Bobbie's Pizza & Subs (V1 ID: 143)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (45, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mr Mozzarella - Nepean (V1 ID: 145)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (47, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Merivale Pizza & Wings (V1 ID: 146)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (48, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 161)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (55, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 164)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (57, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 172)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (59, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Roulas Grecque et Pizza (V1 ID: 173)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1016, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Vanier Pizza & Subs (V1 ID: 175)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (62, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Number One Chinese Take Out (V1 ID: 179)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (65, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Aylmer BBQ (V1 ID: 183)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (69, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Pizza - Hull (V1 ID: 184)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (70, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Cathay Restaurants (V1 ID: 187)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (72, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 190)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (75, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Lorenzo's Pizzeria - Vanier (V1 ID: 192)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (77, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Season's Pizza (V1 ID: 199)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (83, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- The Original Georgie's (V1 ID: 200)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (84, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 204)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (88, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 205)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (89, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 206)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (90, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 207)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (91, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 208)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (92, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 209)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (93, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 211)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (95, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 213)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (97, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Lemongrass Thai Cuisine (V1 ID: 219)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1010, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Restaurant Le Choix (V1 ID: 225)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (106, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Restaurant Chez Gerry (V1 ID: 228)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (109, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Pizza Des Flandres (V1 ID: 231)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1012, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mano City Pizza (V1 ID: 238)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (118, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 245)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (123, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Carlo's Pizza (V1 ID: 246)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (124, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 248)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (126, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Centertown Donair & Pizza (V1 ID: 255)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (131, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Riverside Pizzeria (V1 ID: 257)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (133, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pizza Bravo (V1 ID: 264)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (139, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Tony's Pizza (V1 ID: 275)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (143, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pho Dau Bo Restaurant - Kitchener (V1 ID: 280)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (147, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Hong Kong Chinese Food Takeout (V1 ID: 294)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (160, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Lucky King Take Out (V1 ID: 312)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (174, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Indian Punjabi Clay Oven (V1 ID: 318)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (180, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Charm Thai Cuisine (V1 ID: 323)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (943, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 328)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (190, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Colonnade Pizza (V1 ID: 334)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (196, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pho Bo Ga King - Somerset (V1 ID: 337)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (199, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mont Liban Bakery & Shawarma (V1 ID: 344)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (205, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Pizza Maloney (V1 ID: 346)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1013, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Erman Pizza (V1 ID: 350)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (211, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- New Mukut Restaurant Indian Cuisine (V1 ID: 374)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (234, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Beneci Pizza (V1 ID: 383)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (241, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 411)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (265, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Lucky Fortune (V1 ID: 413)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (267, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Shaan Tandoori (V1 ID: 415)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (269, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- JN Pizza (V1 ID: 489)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (328, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Sushi Express Chambly (V1 ID: 511)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1017, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 512)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (349, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 513)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (350, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Xtreme Pizza (V1 ID: 532)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (367, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Sachi Sushi (V1 ID: 542)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (376, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Yorgo's - Nepean (V1 ID: 547)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (985, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Papa Joe's Fried Chicken - Downtown (V1 ID: 612)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (437, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- iCook Pho You (V1 ID: 669)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (479, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Ting's Kitchen (V1 ID: 694)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (941, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Light of India (V1 ID: 695)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (491, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Rangoli (V1 ID: 701)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (497, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Pizza Val-Des-Monts (V1 ID: 703)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1014, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- New Hong Kong (V1 ID: 707)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (502, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pizza Lovers Hunt Club (V1 ID: 712)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (507, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Egg Roll Factory (V1 ID: 716)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (511, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Napolis (V1 ID: 721)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (515, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- HaNoi Pho (V1 ID: 727)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (519, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Palermo Pizzeria (V1 ID: 729)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (521, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Papa Grecque des Flandres (V1 ID: 758)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (540, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Aahar The Taste of India (V1 ID: 781)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (561, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pizza des Hautes Plaines (V1 ID: 782)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (562, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 785)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (565, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 789)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (569, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Crispy's (V1 ID: 805)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (584, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 807)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (586, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 815)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (593, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Supreme Pizzeria (V1 ID: 817)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (595, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Sushi Fleury (V1 ID: 818)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (596, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 824)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (601, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Papa Pizza Cantley (V1 ID: 825)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (602, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Aroy Thai (V1 ID: 830)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (607, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Marina Pizza des Flandres (V1 ID: 838)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (614, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Grecque Maloney (V1 ID: 840)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (616, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 850)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (624, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Asia Garden Ottawa (V1 ID: 856)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (630, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Joes Family Pizzeria (V1 ID: 863)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (636, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Digby's Restaurant (V1 ID: 865)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (638, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- China Moon (V1 ID: 869)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (641, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mozza Pizza Hull (V1 ID: 872)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (644, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- JC Royal Thai Cuisine (V1 ID: 874)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (646, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 879)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (651, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 889)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (660, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 913)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (680, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Oka's Hull (V1 ID: 914)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (681, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Pizza Maisonneuve (V1 ID: 930)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (696, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 937)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (701, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Supreme Pizzeria (V1 ID: 947)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (711, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Patate Lou Lou (V1 ID: 948)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (712, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Ogilvie Pizza (V1 ID: 951)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (714, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- La Poutinerie Ogilvie (V1 ID: 952)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (715, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- PizzaRama (V1 ID: 953)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (716, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- La Maison Pho (V1 ID: 959)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (721, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pizza Joanna (V1 ID: 964)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (726, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- La Maison du Burger (V1 ID: 965)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (727, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Friendly Restaurant and Pizzeria (V1 ID: 968)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (730, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Amicci Pizza (V1 ID: 973)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (735, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Greber Pizza et Shawarma (V1 ID: 974)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (736, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Sala Thai (V1 ID: 983)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (745, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 987)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (749, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 989)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (751, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Little Gyros Greek Grill (V1 ID: 998)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (756, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- All Out Burger Bank St. (V1 ID: 1013)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (924, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Colonnade Pizza (V1 ID: 1025)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (783, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Colonnade Pizza (V1 ID: 1027)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (784, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Colonnade Pizza (V1 ID: 1028)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (785, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Poutinerie Québecurds Hull (V1 ID: 1032)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (789, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Nachos Loco Hull (V1 ID: 1033)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (790, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Dumpling Bowl (V1 ID: 1035)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (792, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- All Out Burger Gladstone (V1 ID: 1038)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (948, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Pizza Chem. de Masson (V1 ID: 1039)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (795, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Burger (V1 ID: 1041)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (797, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Kabylie Pizza (V1 ID: 1042)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (798, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Nachos Loco Gatineau (V1 ID: 1045)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (801, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Poutinerie Québecurds Gatineau (V1 ID: 1046)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (1015, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Crispy's Bank Street (V1 ID: 1050)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (806, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Oh My Grill (V1 ID: 1051)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (807, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Grecque Cantley (V1 ID: 1054)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (810, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Golden Center Pizza (V1 ID: 1059)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (815, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Dépanneur Généreux (V1 ID: 1060)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (816, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 1062)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (818, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Milano (V1 ID: 1063)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (819, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Vieux Hull Pizza (V1 ID: 1064)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (820, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 1065)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (821, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Papa Burger Maloney (V1 ID: 1066)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (822, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Prima Pizza (V1 ID: 1069)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (824, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- La Nawab V2 (V1 ID: 1070)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (825, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- All Out Burger Montreal Rd (V1 ID: 1071)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (949, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Pizzalicious (V1 ID: 1074)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (829, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 1082)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (835, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Souvlaki Souvlaki (V1 ID: 1083)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (836, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 1084)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (837, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 1087)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (840, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- All Out Burger (V1 ID: 1088)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (841, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Milano (V1 ID: 1089)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (842, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Mykonos Greek Grill (V1 ID: 1092)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (845, true, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = true, delivery_method = 'radius';

-- Mykonos Greek Grill (V1 ID: 1093)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (846, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';

-- Sushiyana (V1 ID: 1094)
INSERT INTO menuca_v3.restaurant_delivery_config (restaurant_id, use_multiple_areas, delivery_method) VALUES (847, false, 'radius') ON CONFLICT (restaurant_id) DO UPDATE SET use_multiple_areas = false, delivery_method = 'radius';
