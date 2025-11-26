-- Insert delivery schedules for batch_31_60
-- WARNING: This will DELETE existing delivery schedules and replace with V1 data

-- Delete existing delivery schedules for batch restaurants
DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN (143,180,109,1013,147,126,205,196,118,1012,211,241,133,139,199,131,190,106,95,174,943,267,1010,123,234,265,160,97,124,93) AND type = 'delivery';

-- Milano (V1: 209, V3: 93)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (93, 'delivery', 7, 7, '11:00', '21:00');

-- Milano (V1: 211, V3: 95)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (95, 'delivery', 7, 7, '11:00', '23:59');

-- Milano (V1: 213, V3: 97)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (97, 'delivery', 7, 7, '11:00', '23:00');

-- Lemongrass Thai Cuisine (V1: 219, V3: 1010)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 1, 1, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 2, 2, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 3, 3, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 4, 4, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 5, 5, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 6, 6, '12:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1010, 'delivery', 7, 7, '12:00', '20:30');

-- Restaurant Le Choix (V1: 225, V3: 106)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 1, 1, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 2, 2, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 3, 3, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 4, 4, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 5, 5, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 6, 6, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (106, 'delivery', 7, 7, '15:00', '20:00');

-- Restaurant Chez Gerry (V1: 228, V3: 109)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 1, 1, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 2, 2, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 3, 3, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 4, 4, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 5, 5, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 6, 6, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (109, 'delivery', 7, 7, '16:00', '21:00');

-- Papa Pizza Des Flandres (V1: 231, V3: 1012)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 4, 4, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 5, 5, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 6, 6, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1012, 'delivery', 7, 7, '11:00', '23:00');

-- Mano City Pizza (V1: 238, V3: 118)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 1, 1, '10:00', '21:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 2, 2, '10:00', '21:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 3, 3, '10:00', '21:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 4, 4, '10:00', '21:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 5, 5, '10:00', '22:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 6, 6, '10:00', '22:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (118, 'delivery', 7, 7, '13:00', '21:45');

-- Milano (V1: 245, V3: 123)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (123, 'delivery', 7, 7, '11:00', '21:00');

-- Carlo's Pizza (V1: 246, V3: 124)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (124, 'delivery', 7, 7, '16:00', '22:00');

-- Milano (V1: 248, V3: 126)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 2, 2, '00:00', '00:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 3, 3, '00:00', '00:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 4, 4, '00:00', '00:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 5, 5, '00:00', '01:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 6, 6, '00:00', '02:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 7, 7, '00:00', '02:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (126, 'delivery', 7, 7, '12:30', '22:40');

-- Centertown Donair & Pizza (V1: 255, V3: 131)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 2, 2, '11:00', '19:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 3, 3, '11:00', '19:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 6, 6, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (131, 'delivery', 7, 7, '15:00', '19:00');

-- Riverside Pizzeria (V1: 257, V3: 133)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 1, 1, '13:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 2, 2, '13:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 3, 3, '13:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 4, 4, '13:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 5, 5, '13:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 6, 6, '13:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (133, 'delivery', 7, 7, '13:00', '21:00');

-- Pizza Bravo (V1: 264, V3: 139)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 1, 1, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 2, 2, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 3, 3, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 4, 4, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 5, 5, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 6, 6, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (139, 'delivery', 7, 7, '15:00', '21:00');

-- Tony's Pizza (V1: 275, V3: 143)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 1, 1, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 2, 2, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 3, 3, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 4, 4, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 5, 5, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (143, 'delivery', 7, 7, '11:00', '23:59');

-- Pho Dau Bo Restaurant - Kitchener (V1: 280, V3: 147)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 1, 1, '10:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 2, 2, '10:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 3, 3, '10:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 4, 4, '10:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 5, 5, '09:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 6, 6, '09:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (147, 'delivery', 7, 7, '09:30', '22:00');

-- Hong Kong Chinese Food Takeout (V1: 294, V3: 160)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 2, 2, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 3, 3, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 4, 4, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 5, 5, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 6, 6, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (160, 'delivery', 7, 7, '15:00', '22:00');

-- Lucky King Take Out (V1: 312, V3: 174)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 2, 2, '11:30', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 3, 3, '11:30', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 4, 4, '11:30', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 5, 5, '11:30', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 6, 6, '16:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (174, 'delivery', 7, 7, '16:00', '21:30');

-- Indian Punjabi Clay Oven (V1: 318, V3: 180)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 1, 1, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 1, 1, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 2, 2, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 2, 2, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 3, 3, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 3, 3, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 4, 4, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 4, 4, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 5, 5, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 5, 5, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 6, 6, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (180, 'delivery', 7, 7, '17:00', '21:00');

-- Charm Thai Cuisine (V1: 323, V3: 943)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 1, 1, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 2, 2, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 3, 3, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 4, 4, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 5, 5, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 6, 6, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (943, 'delivery', 7, 7, '15:00', '20:30');

-- Milano (V1: 328, V3: 190)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 1, 1, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 2, 2, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 3, 3, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 4, 4, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 5, 5, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (190, 'delivery', 7, 7, '14:00', '21:30');

-- Colonnade Pizza (V1: 334, V3: 196)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 1, 1, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 2, 2, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 3, 3, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 4, 4, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 5, 5, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 6, 6, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (196, 'delivery', 7, 7, '15:00', '21:30');

-- Pho Bo Ga King - Somerset (V1: 337, V3: 199)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 1, 1, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 2, 2, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 3, 3, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 4, 4, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 5, 5, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 6, 6, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (199, 'delivery', 7, 7, '16:00', '23:00');

-- Mont Liban Bakery & Shawarma (V1: 344, V3: 205)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 2, 2, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 3, 3, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 4, 4, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 5, 5, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (205, 'delivery', 7, 7, '16:00', '22:00');

-- Papa Pizza Maloney (V1: 346, V3: 1013)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1013, 'delivery', 7, 7, '11:00', '23:00');

-- Erman Pizza (V1: 350, V3: 211)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 5, 5, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 6, 6, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 7, 7, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (211, 'delivery', 7, 7, '11:00', '23:00');

-- New Mukut Restaurant Indian Cuisine (V1: 374, V3: 234)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 1, 1, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 2, 2, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 3, 3, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 4, 4, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 5, 5, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 6, 6, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (234, 'delivery', 7, 7, '17:00', '19:00');

-- Beneci Pizza (V1: 383, V3: 241)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 1, 1, '15:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 2, 2, '15:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 3, 3, '15:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 4, 4, '15:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 6, 6, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (241, 'delivery', 7, 7, '15:00', '20:00');

-- Milano (V1: 411, V3: 265)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 2, 2, '11:00', '19:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 3, 3, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 6, 6, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (265, 'delivery', 7, 7, '16:00', '20:00');

-- Lucky Fortune (V1: 413, V3: 267)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (267, 'delivery', 7, 7, '11:30', '21:00');

