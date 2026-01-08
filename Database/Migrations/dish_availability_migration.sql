-- ============================================================
-- DISH AVAILABILITY MIGRATION SCRIPT
-- Migrates V2 show_on day restrictions to menuca_v3.dish_availability
-- 
-- Source: V2 restaurants_dishes_customization.dish_info.show_on
-- Target: menuca_v3.dish_availability
--
-- Day Mapping:
--   0 = Sunday, 1 = Monday, 2 = Tuesday, 3 = Wednesday
--   4 = Thursday, 5 = Friday, 6 = Saturday
--
-- Generated: 2026-01-05
-- ============================================================

BEGIN;

-- Verify target table is empty or prepare for merge
SELECT COUNT(*) as existing_records FROM menuca_v3.dish_availability;

-- ============================================================
-- WANDEE THAI - Lunch Menu (Hidden on Sun/Sat - weekdays only)
-- V2 dish_ids: 8317-8344 -> Missing days: 0, 6
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- LA1. Poh Pia Pak (2) - v3_id: 173536
  (173536, 0, true), (173536, 6, true),
  -- LA2. Poh Pia Goong (2) - v3_id: 173537
  (173537, 0, true), (173537, 6, true),
  -- LA3. Fresh Wraps (2) - v3_id: 173538
  (173538, 0, true), (173538, 6, true),
  -- LS1. Tom Yum Gai - v3_id: 173539
  (173539, 0, true), (173539, 6, true),
  -- LS2. Tom Yum Goong - v3_id: 173540
  (173540, 0, true), (173540, 6, true),
  -- LS3. Tom Kha Gai - v3_id: 173541
  (173541, 0, true), (173541, 6, true),
  -- LS4. Tom Kha Goong - v3_id: 173542
  (173542, 0, true), (173542, 6, true),
  -- LN1. Pad Thai - v3_id: 173543
  (173543, 0, true), (173543, 6, true),
  -- LN2. Pad Kee Mau - v3_id: 173544
  (173544, 0, true), (173544, 6, true),
  -- LN3. Pad Ba Mee Egg Noodle Stir-Fry - v3_id: 173545
  (173545, 0, true), (173545, 6, true),
  -- LN4. Pad See Ew - v3_id: 173546
  (173546, 0, true), (173546, 6, true),
  -- LR1. Khao Pad - v3_id: 173547
  (173547, 0, true), (173547, 6, true),
  -- LR2. Khao Pad Kra Paow - v3_id: 173548
  (173548, 0, true), (173548, 6, true),
  -- LG1. Gaeng Khiao Wan - v3_id: 173549
  (173549, 0, true), (173549, 6, true),
  -- LG2. Gaeng Ka Ri Gai - v3_id: 173550
  (173550, 0, true), (173550, 6, true),
  -- LG3. Gaeng Panang - v3_id: 173551
  (173551, 0, true), (173551, 6, true),
  -- LG4. Gaeng Dan - v3_id: 173552
  (173552, 0, true), (173552, 6, true),
  -- LP1. Pad Kra Paow - v3_id: 173553
  (173553, 0, true), (173553, 6, true),
  -- LP2. Pad Med Ma'Muang Gai - v3_id: 173554
  (173554, 0, true), (173554, 6, true),
  -- LP3. Pad Khing - v3_id: 173555
  (173555, 0, true), (173555, 6, true),
  -- LP4. Pad Prik Khing - v3_id: 173556
  (173556, 0, true), (173556, 6, true),
  -- LP5. Pad Ma Khua Yaow - v3_id: 173557
  (173557, 0, true), (173557, 6, true),
  -- LP6. Pad Kra Tiam Prik Thai - v3_id: 173558
  (173558, 0, true), (173558, 6, true),
  -- LP7. Pad Pak Ruam Mit - v3_id: 173559
  (173559, 0, true), (173559, 6, true),
  -- LC1. Combo 1 - v3_id: 173560
  (173560, 0, true), (173560, 6, true),
  -- LC2. Combo 2 - v3_id: 173561
  (173561, 0, true), (173561, 6, true),
  -- LC3. Combo 3 - v3_id: 173562
  (173562, 0, true), (173562, 6, true),
  -- LC4. Combo 4 - v3_id: 173563
  (173563, 0, true), (173563, 6, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- KIRKWOOD PIZZA - Daily Specials (Each visible only on their day)
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- Hawaiian Plus - v3_id: 173121 (only Monday: hide 0,2,3,4,5,6)
  (173121, 0, true), (173121, 2, true), (173121, 3, true), (173121, 4, true), (173121, 5, true), (173121, 6, true),
  -- Pepsi - v3_id: 173218 (hide Monday: 1)
  (173218, 1, true),
  -- MONDAY SPECIAL - Large Pepperoni Pizza - v3_id: 173067 (only Mon: hide 0,2,3,4,5,6)
  (173067, 0, true), (173067, 2, true), (173067, 3, true), (173067, 4, true), (173067, 5, true), (173067, 6, true),
  -- TUESDAY SPECIAL - Medium Hawaiian Pizza - v3_id: 173068 (only Tue: hide 0,1,3,4,5,6)
  (173068, 0, true), (173068, 1, true), (173068, 3, true), (173068, 4, true), (173068, 5, true), (173068, 6, true),
  -- WEDNESDAY SPECIAL - Medium Combination Pizza - v3_id: 173069 (only Wed: hide 0,1,2,4,5,6)
  (173069, 0, true), (173069, 1, true), (173069, 2, true), (173069, 4, true), (173069, 5, true), (173069, 6, true),
  -- THURSDAY SPECIAL - Medium La Belle Pizza - v3_id: 173070 (only Thu: hide 0,1,2,3,5,6)
  (173070, 0, true), (173070, 1, true), (173070, 2, true), (173070, 3, true), (173070, 5, true), (173070, 6, true),
  -- FRIDAY SPECIAL - Medium Vegetarian Pizza - v3_id: 173071 (only Fri: hide 0,1,2,3,4,6)
  (173071, 0, true), (173071, 1, true), (173071, 2, true), (173071, 3, true), (173071, 4, true), (173071, 6, true),
  -- SATURDAY SPECIAL - Medium Meat Lovers Pizza - v3_id: 173072 (only Sat: hide 0,1,2,3,4,5)
  (173072, 0, true), (173072, 1, true), (173072, 2, true), (173072, 3, true), (173072, 4, true), (173072, 5, true),
  -- SUNDAY SPECIAL - Medium Mexican Pizza - v3_id: 173073 (only Sun: hide 1,2,3,4,5,6)
  (173073, 1, true), (173073, 2, true), (173073, 3, true), (173073, 4, true), (173073, 5, true), (173073, 6, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- LA NAWAB - Légume Biryani (only Monday)
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- Légume Biryani - v3_id: 171324 (only Mon: hide 0,2,3,4,5,6)
  (171324, 0, true), (171324, 2, true), (171324, 3, true), (171324, 4, true), (171324, 5, true), (171324, 6, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- CAPRI PIZZA - Saturday Kids Special (only Saturday)
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- Saturday Kids Special - v3_id: 171935 (only Sat: hide 0,1,2,3,4,5)
  (171935, 0, true), (171935, 1, true), (171935, 2, true), (171935, 3, true), (171935, 4, true), (171935, 5, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- LITTLE GYROS GREEK GRILL - Daily Specials (Deal of the Day)
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- Gyros Pita (Deal) - v3_id: 173266 (only Mon: hide 0,2,3,4,5,6)
  (173266, 0, true), (173266, 2, true), (173266, 3, true), (173266, 4, true), (173266, 5, true), (173266, 6, true),
  -- Gyros Dinner - v3_id: 173267 (only Mon: hide 0,2,3,4,5,6)
  (173267, 0, true), (173267, 2, true), (173267, 3, true), (173267, 4, true), (173267, 5, true), (173267, 6, true),
  -- Pork Pita Combo with Side - v3_id: 173268 (only Tue: hide 0,1,3,4,5,6)
  (173268, 0, true), (173268, 1, true), (173268, 3, true), (173268, 4, true), (173268, 5, true), (173268, 6, true),
  -- Chicken Pita with Side - v3_id: 173269 (only Wed: hide 0,1,2,4,5,6)
  (173269, 0, true), (173269, 1, true), (173269, 2, true), (173269, 4, true), (173269, 5, true), (173269, 6, true),
  -- Large Greek Salad with Grilled Chicken Breast & Pita Bread - v3_id: 173270 (only Thu: hide 0,1,2,3,5,6)
  (173270, 0, true), (173270, 1, true), (173270, 2, true), (173270, 3, true), (173270, 5, true), (173270, 6, true),
  -- Fish & Chips (1pc) with Greek Salad - v3_id: 173271 (only Fri: hide 0,1,2,3,4,6)
  (173271, 0, true), (173271, 1, true), (173271, 2, true), (173271, 3, true), (173271, 4, true), (173271, 6, true),
  -- Fish & Chips (2pcs) with Greek Salad - v3_id: 173272 (only Fri: hide 0,1,2,3,4,6)
  (173272, 0, true), (173272, 1, true), (173272, 2, true), (173272, 3, true), (173272, 4, true), (173272, 6, true),
  -- Mike's Classic Burger Combo with Fries - v3_id: 173273 (only Sat: hide 0,1,2,3,4,5)
  (173273, 0, true), (173273, 1, true), (173273, 2, true), (173273, 3, true), (173273, 4, true), (173273, 5, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- LITTLE GYROS GREEK GRILL - Lunch Special (Hidden on Sun/Sat - weekdays only)
-- V2 dish_ids: 10590-10617 -> Missing days: 0, 6
-- ============================================================

INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES
  -- Spartan Classic Burger - v3_id: 173238
  (173238, 0, true), (173238, 6, true),
  -- Spartan Classic Burger Combo - v3_id: 173239
  (173239, 0, true), (173239, 6, true),
  -- The Hercules Burger - v3_id: 173240
  (173240, 0, true), (173240, 6, true),
  -- The Hercules Burger Combo - v3_id: 173241
  (173241, 0, true), (173241, 6, true),
  -- Poutine - v3_id: 173242
  (173242, 0, true), (173242, 6, true),
  -- Mikes Poutine - v3_id: 173243
  (173243, 0, true), (173243, 6, true),
  -- Gyros Pita - v3_id: 173244
  (173244, 0, true), (173244, 6, true),
  -- Gyros Pita Combo - v3_id: 173245
  (173245, 0, true), (173245, 6, true),
  -- Pork Souvlaki Pita - v3_id: 173246
  (173246, 0, true), (173246, 6, true),
  -- Pork Souvlaki Pita Combo - v3_id: 173247
  (173247, 0, true), (173247, 6, true),
  -- Chicken Souvlaki Pita - v3_id: 173248
  (173248, 0, true), (173248, 6, true),
  -- Chicken Souvlaki Pita Combo - v3_id: 173249
  (173249, 0, true), (173249, 6, true),
  -- Falafel in a Pita - v3_id: 173250
  (173250, 0, true), (173250, 6, true),
  -- Falafel in a Pita Combo - v3_id: 173251
  (173251, 0, true), (173251, 6, true),
  -- Meat Lover Salad - v3_id: 173252
  (173252, 0, true), (173252, 6, true),
  -- Kids Chicken Fingers with Fries - v3_id: 173253
  (173253, 0, true), (173253, 6, true),
  -- Kids Souvlaki with Fries - v3_id: 173254
  (173254, 0, true), (173254, 6, true),
  -- Kids Souvlaki with Rice - v3_id: 173255
  (173255, 0, true), (173255, 6, true),
  -- Kids Souvlaki with Potatoes - v3_id: 173256
  (173256, 0, true), (173256, 6, true),
  -- Onion Rings - v3_id: 173257
  (173257, 0, true), (173257, 6, true),
  -- Fries - v3_id: 173258
  (173258, 0, true), (173258, 6, true),
  -- Chicken Fingers with Fries - v3_id: 173259
  (173259, 0, true), (173259, 6, true),
  -- Backlava - v3_id: 173260
  (173260, 0, true), (173260, 6, true),
  -- Large Greek Salad with Tzatziki Pita Bread - v3_id: 173261
  (173261, 0, true), (173261, 6, true),
  -- Large Greek Salad with Chicken Breast - v3_id: 173262
  (173262, 0, true), (173262, 6, true),
  -- Chicken Souvlaki Skewers (2 skewers) - v3_id: 173263
  (173263, 0, true), (173263, 6, true),
  -- Pork Souvlaki Skewers (2 skewers) - v3_id: 173264
  (173264, 0, true), (173264, 6, true),
  -- Fresh Cod Fish - v3_id: 173265
  (173265, 0, true), (173265, 6, true)
ON CONFLICT (dish_id, day_of_week) DO NOTHING;

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Count inserted records by restaurant
SELECT 
    r.name as restaurant,
    COUNT(*) as availability_records
FROM menuca_v3.dish_availability da
JOIN menuca_v3.dishes d ON da.dish_id = d.id
JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id
GROUP BY r.name
ORDER BY r.name;

-- Show sample of inserted data
SELECT 
    r.name as restaurant,
    d.name as dish,
    da.day_of_week,
    CASE da.day_of_week 
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_name,
    da.is_hidden
FROM menuca_v3.dish_availability da
JOIN menuca_v3.dishes d ON da.dish_id = d.id
JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id
ORDER BY r.name, d.name, da.day_of_week
LIMIT 20;

COMMIT;





