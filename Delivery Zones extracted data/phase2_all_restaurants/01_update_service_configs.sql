-- Update restaurant_service_configs for ALL 164 restaurants
-- Based on V1 data extraction from restaurants_dump.sql

-- Imilio's Pizzeria (V1 ID: 89)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 45 WHERE restaurant_id = 7;

-- Mama Rosa (V1 ID: 94)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 18.0, delivery_time_minutes = 35 WHERE restaurant_id = 12;

-- Papa Joe's Pizza - Downtown (V1 ID: 95)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 13;

-- New Mee Fung Restaurant (V1 ID: 101)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 8.0, delivery_time_minutes = 65 WHERE restaurant_id = 15;

-- House of Lasagna (V1 ID: 117)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 22;

-- Eastview Pizza (V1 ID: 124)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 28;

-- Milano (V1 ID: 127)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 31;

-- Mozza Pizza Gatineau (V1 ID: 132)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 17.0, delivery_time_minutes = 45 WHERE restaurant_id = 1011;

-- Kiki Lebanese Pineview Pizza (V1 ID: 142)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 44;

-- Bobbie's Pizza & Subs (V1 ID: 143)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 40 WHERE restaurant_id = 45;

-- Mr Mozzarella - Nepean (V1 ID: 145)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 47;

-- Merivale Pizza & Wings (V1 ID: 146)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 48;

-- Milano (V1 ID: 161)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 55;

-- Milano (V1 ID: 164)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 57;

-- Milano (V1 ID: 172)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 59;

-- Roulas Grecque et Pizza (V1 ID: 173)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 9.99, delivery_time_minutes = 50 WHERE restaurant_id = 1016;

-- Vanier Pizza & Subs (V1 ID: 175)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 62;

-- Number One Chinese Take Out (V1 ID: 179)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 65;

-- Aylmer BBQ (V1 ID: 183)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 8.0, delivery_time_minutes = 50 WHERE restaurant_id = 69;

-- Papa Pizza - Hull (V1 ID: 184)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 70;

-- Cathay Restaurants (V1 ID: 187)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 45 WHERE restaurant_id = 72;

-- Milano (V1 ID: 190)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 75;

-- Lorenzo's Pizzeria - Vanier (V1 ID: 192)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 77;

-- Season's Pizza (V1 ID: 199)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 83;

-- The Original Georgie's (V1 ID: 200)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 60 WHERE restaurant_id = 84;

-- Milano (V1 ID: 204)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 88;

-- Milano (V1 ID: 205)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 89;

-- Milano (V1 ID: 206)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 90;

-- Milano (V1 ID: 207)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 91;

-- Milano (V1 ID: 208)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 58 WHERE restaurant_id = 92;

-- Milano (V1 ID: 209)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 93;

-- Milano (V1 ID: 211)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 55 WHERE restaurant_id = 95;

-- Milano (V1 ID: 213)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 97;

-- Lemongrass Thai Cuisine (V1 ID: 219)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 25.0, delivery_time_minutes = 65 WHERE restaurant_id = 1010;

-- Restaurant Le Choix (V1 ID: 225)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 106;

-- Restaurant Chez Gerry (V1 ID: 228)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 40 WHERE restaurant_id = 109;

-- Papa Pizza Des Flandres (V1 ID: 231)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 1012;

-- Mano City Pizza (V1 ID: 238)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 16.0, delivery_time_minutes = 45 WHERE restaurant_id = 118;

-- Milano (V1 ID: 245)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 123;

-- Carlo's Pizza (V1 ID: 246)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 18.0, delivery_time_minutes = 45 WHERE restaurant_id = 124;

-- Milano (V1 ID: 248)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 126;

-- Centertown Donair & Pizza (V1 ID: 255)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 59 WHERE restaurant_id = 131;

-- Riverside Pizzeria (V1 ID: 257)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 133;

-- Pizza Bravo (V1 ID: 264)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 60 WHERE restaurant_id = 139;

-- Tony's Pizza (V1 ID: 275)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 143;

-- Pho Dau Bo Restaurant - Kitchener (V1 ID: 280)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 10.0, delivery_time_minutes = 30 WHERE restaurant_id = 147;

-- Hong Kong Chinese Food Takeout (V1 ID: 294)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 160;

-- Lucky King Take Out (V1 ID: 312)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 23.5, delivery_time_minutes = 60 WHERE restaurant_id = 174;

-- Indian Punjabi Clay Oven (V1 ID: 318)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 35.0, delivery_time_minutes = 60 WHERE restaurant_id = 180;

-- Charm Thai Cuisine (V1 ID: 323)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 25.0, delivery_time_minutes = 60 WHERE restaurant_id = 943;

-- Milano (V1 ID: 328)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 190;

-- Colonnade Pizza (V1 ID: 334)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 20.0, delivery_time_minutes = 60 WHERE restaurant_id = 196;

-- Pho Bo Ga King - Somerset (V1 ID: 337)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 20.0, delivery_time_minutes = 59 WHERE restaurant_id = 199;

-- Mont Liban Bakery & Shawarma (V1 ID: 344)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 205;

-- Papa Pizza Maloney (V1 ID: 346)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 8.0, delivery_time_minutes = 40 WHERE restaurant_id = 1013;

-- Erman Pizza (V1 ID: 350)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 211;

-- New Mukut Restaurant Indian Cuisine (V1 ID: 374)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 12.0, delivery_time_minutes = 55 WHERE restaurant_id = 234;

-- Beneci Pizza (V1 ID: 383)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 50 WHERE restaurant_id = 241;

-- Milano (V1 ID: 411)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 15 WHERE restaurant_id = 265;

-- Lucky Fortune (V1 ID: 413)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 45 WHERE restaurant_id = 267;

-- Shaan Tandoori (V1 ID: 415)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 30.0, delivery_time_minutes = 60 WHERE restaurant_id = 269;

-- JN Pizza (V1 ID: 489)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 328;

-- Sushi Express Chambly (V1 ID: 511)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 40 WHERE restaurant_id = 1017;

-- Milano (V1 ID: 512)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 349;

-- Milano (V1 ID: 513)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 350;

-- Xtreme Pizza (V1 ID: 532)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 45 WHERE restaurant_id = 367;

-- Sachi Sushi (V1 ID: 542)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 376;

-- Yorgo's - Nepean (V1 ID: 547)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 45 WHERE restaurant_id = 985;

-- Papa Joe's Fried Chicken - Downtown (V1 ID: 612)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 437;

-- iCook Pho You (V1 ID: 669)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 15 WHERE restaurant_id = 479;

-- Ting's Kitchen (V1 ID: 694)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 35.0, delivery_time_minutes = 60 WHERE restaurant_id = 941;

-- Light of India (V1 ID: 695)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 35.0, delivery_time_minutes = 60 WHERE restaurant_id = 491;

-- Rangoli (V1 ID: 701)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 25.0, delivery_time_minutes = 40 WHERE restaurant_id = 497;

-- Papa Pizza Val-Des-Monts (V1 ID: 703)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 75 WHERE restaurant_id = 1014;

-- New Hong Kong (V1 ID: 707)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 25.0, delivery_time_minutes = 45 WHERE restaurant_id = 502;

-- Pizza Lovers Hunt Club (V1 ID: 712)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 40 WHERE restaurant_id = 507;

-- Egg Roll Factory (V1 ID: 716)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 45 WHERE restaurant_id = 511;

-- Napolis (V1 ID: 721)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 14.0, delivery_time_minutes = 50 WHERE restaurant_id = 515;

-- HaNoi Pho (V1 ID: 727)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0.0, delivery_time_minutes = 15 WHERE restaurant_id = 519;

-- Palermo Pizzeria (V1 ID: 729)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 50 WHERE restaurant_id = 521;

-- Papa Grecque des Flandres (V1 ID: 758)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 540;

-- Aahar The Taste of India (V1 ID: 781)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 30.0, delivery_time_minutes = 60 WHERE restaurant_id = 561;

-- Pizza des Hautes Plaines (V1 ID: 782)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 45 WHERE restaurant_id = 562;

-- Milano (V1 ID: 785)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 565;

-- Milano (V1 ID: 789)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 569;

-- Crispy's (V1 ID: 805)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 584;

-- Milano (V1 ID: 807)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 586;

-- Milano (V1 ID: 815)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 15 WHERE restaurant_id = 593;

-- Supreme Pizzeria (V1 ID: 817)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 595;

-- Sushi Fleury (V1 ID: 818)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 596;

-- Milano (V1 ID: 824)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 601;

-- Papa Pizza Cantley (V1 ID: 825)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 48 WHERE restaurant_id = 602;

-- Aroy Thai (V1 ID: 830)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 10.0, delivery_time_minutes = 50 WHERE restaurant_id = 607;

-- Marina Pizza des Flandres (V1 ID: 838)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 614;

-- Papa Grecque Maloney (V1 ID: 840)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 616;

-- Milano (V1 ID: 850)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 624;

-- Asia Garden Ottawa (V1 ID: 856)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 32.0, delivery_time_minutes = 55 WHERE restaurant_id = 630;

-- Joes Family Pizzeria (V1 ID: 863)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 60 WHERE restaurant_id = 636;

-- Digby's Restaurant (V1 ID: 865)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 45 WHERE restaurant_id = 638;

-- China Moon (V1 ID: 869)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 45 WHERE restaurant_id = 641;

-- Mozza Pizza Hull (V1 ID: 872)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 14.0, delivery_time_minutes = 45 WHERE restaurant_id = 644;

-- JC Royal Thai Cuisine (V1 ID: 874)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 646;

-- Milano (V1 ID: 879)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 651;

-- Milano (V1 ID: 889)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 660;

-- Milano (V1 ID: 913)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 680;

-- Oka's Hull (V1 ID: 914)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 13.0, delivery_time_minutes = 45 WHERE restaurant_id = 681;

-- Pizza Maisonneuve (V1 ID: 930)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 696;

-- Milano (V1 ID: 937)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 701;

-- Supreme Pizzeria (V1 ID: 947)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 711;

-- Patate Lou Lou (V1 ID: 948)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 5.0, delivery_time_minutes = 90 WHERE restaurant_id = 712;

-- Ogilvie Pizza (V1 ID: 951)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 50 WHERE restaurant_id = 714;

-- La Poutinerie Ogilvie (V1 ID: 952)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 40 WHERE restaurant_id = 715;

-- PizzaRama (V1 ID: 953)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 8.0, delivery_time_minutes = 40 WHERE restaurant_id = 716;

-- La Maison Pho (V1 ID: 959)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 60 WHERE restaurant_id = 721;

-- Pizza Joanna (V1 ID: 964)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 12.0, delivery_time_minutes = 45 WHERE restaurant_id = 726;

-- La Maison du Burger (V1 ID: 965)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 727;

-- Friendly Restaurant and Pizzeria (V1 ID: 968)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 30.0, delivery_time_minutes = 60 WHERE restaurant_id = 730;

-- Amicci Pizza (V1 ID: 973)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 735;

-- Greber Pizza et Shawarma (V1 ID: 974)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 736;

-- Sala Thai (V1 ID: 983)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 15 WHERE restaurant_id = 745;

-- Milano (V1 ID: 987)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 749;

-- Milano (V1 ID: 989)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 751;

-- Little Gyros Greek Grill (V1 ID: 998)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 15 WHERE restaurant_id = 756;

-- All Out Burger Bank St. (V1 ID: 1013)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 5.0, delivery_time_minutes = 15 WHERE restaurant_id = 924;

-- Colonnade Pizza (V1 ID: 1025)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 20.0, delivery_time_minutes = 50 WHERE restaurant_id = 783;

-- Colonnade Pizza (V1 ID: 1027)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 20.0, delivery_time_minutes = 50 WHERE restaurant_id = 784;

-- Colonnade Pizza (V1 ID: 1028)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 20.0, delivery_time_minutes = 50 WHERE restaurant_id = 785;

-- Poutinerie Québecurds Hull (V1 ID: 1032)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 789;

-- Nachos Loco Hull (V1 ID: 1033)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 790;

-- Dumpling Bowl (V1 ID: 1035)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 45 WHERE restaurant_id = 792;

-- All Out Burger Gladstone (V1 ID: 1038)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 58 WHERE restaurant_id = 948;

-- Papa Pizza Chem. de Masson (V1 ID: 1039)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 795;

-- Papa Burger (V1 ID: 1041)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 797;

-- Kabylie Pizza (V1 ID: 1042)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 798;

-- Nachos Loco Gatineau (V1 ID: 1045)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 801;

-- Poutinerie Québecurds Gatineau (V1 ID: 1046)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 1015;

-- Crispy's Bank Street (V1 ID: 1050)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 15.0, delivery_time_minutes = 55 WHERE restaurant_id = 806;

-- Oh My Grill (V1 ID: 1051)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 60 WHERE restaurant_id = 807;

-- Papa Grecque Cantley (V1 ID: 1054)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 810;

-- Golden Center Pizza (V1 ID: 1059)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 35 WHERE restaurant_id = 815;

-- Dépanneur Généreux (V1 ID: 1060)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 50 WHERE restaurant_id = 816;

-- Milano (V1 ID: 1062)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 50 WHERE restaurant_id = 818;

-- Milano (V1 ID: 1063)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 819;

-- Vieux Hull Pizza (V1 ID: 1064)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 10.0, delivery_time_minutes = 45 WHERE restaurant_id = 820;

-- Milano (V1 ID: 1065)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 20.0, delivery_time_minutes = 50 WHERE restaurant_id = 821;

-- Papa Burger Maloney (V1 ID: 1066)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 822;

-- Prima Pizza (V1 ID: 1069)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 13.0, delivery_time_minutes = 45 WHERE restaurant_id = 824;

-- La Nawab V2 (V1 ID: 1070)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 5.0, delivery_time_minutes = 15 WHERE restaurant_id = 825;

-- All Out Burger Montreal Rd (V1 ID: 1071)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 15 WHERE restaurant_id = 949;

-- Pizzalicious (V1 ID: 1074)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 45 WHERE restaurant_id = 829;

-- Milano (V1 ID: 1082)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 30 WHERE restaurant_id = 835;

-- Souvlaki Souvlaki (V1 ID: 1083)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 836;

-- Milano (V1 ID: 1084)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 40 WHERE restaurant_id = 837;

-- Milano (V1 ID: 1087)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 0, delivery_time_minutes = 40 WHERE restaurant_id = 840;

-- All Out Burger (V1 ID: 1088)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = false, delivery_min_order = 0, delivery_time_minutes = 15 WHERE restaurant_id = 841;

-- Milano (V1 ID: 1089)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 50 WHERE restaurant_id = 842;

-- Mykonos Greek Grill (V1 ID: 1092)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 45 WHERE restaurant_id = 845;

-- Mykonos Greek Grill (V1 ID: 1093)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 846;

-- Sushiyana (V1 ID: 1094)
UPDATE menuca_v3.restaurant_service_configs SET has_delivery_enabled = true, delivery_min_order = 15.0, delivery_time_minutes = 60 WHERE restaurant_id = 847;
