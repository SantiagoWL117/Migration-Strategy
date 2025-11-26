-- Insert delivery schedules for batch_61_90
-- WARNING: This will DELETE existing delivery schedules and replace with V1 data

-- Delete existing delivery schedules for batch restaurants
DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN (350,491,511,586,502,1017,593,569,1014,437,565,540,507,985,497,367,596,519,562,328,376,515,584,595,521,941,269,479,349) AND type = 'delivery';

-- Shaan Tandoori (V1: 415, V3: 269)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 1, 1, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 1, 1, '16:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 2, 2, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 2, 2, '16:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 3, 3, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 3, 3, '16:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 4, 4, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 4, 4, '16:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 5, 5, '11:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 6, 6, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 6, 6, '16:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 7, 7, '11:30', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (269, 'delivery', 7, 7, '16:30', '21:00');

-- JN Pizza (V1: 489, V3: 328)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (328, 'delivery', 7, 7, '15:00', '21:00');

-- Sushi Express Chambly (V1: 511, V3: 1017)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 1, 1, '11:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 2, 2, '11:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 3, 3, '11:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 4, 4, '11:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 5, 5, '11:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 6, 6, '16:00', '19:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1017, 'delivery', 7, 7, '16:00', '19:45');

-- Milano (V1: 512, V3: 349)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (349, 'delivery', 7, 7, '11:00', '21:00');

-- Milano (V1: 513, V3: 350)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (350, 'delivery', 7, 7, '11:00', '21:00');

-- Xtreme Pizza (V1: 532, V3: 367)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (367, 'delivery', 7, 7, '11:00', '22:00');

-- Sachi Sushi (V1: 542, V3: 376)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 5, 5, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 6, 6, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (376, 'delivery', 7, 7, '11:00', '21:00');

-- Yorgo's - Nepean (V1: 547, V3: 985)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 1, 1, '15:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 2, 2, '15:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 3, 3, '15:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 4, 4, '15:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 6, 6, '15:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (985, 'delivery', 7, 7, '15:30', '22:00');

-- Papa Joe's Fried Chicken - Downtown (V1: 612, V3: 437)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 5, 5, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (437, 'delivery', 7, 7, '15:00', '23:00');

-- iCook Pho You (V1: 669, V3: 479)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 1, 1, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 5, 5, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 6, 6, '12:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (479, 'delivery', 7, 7, '16:00', '21:00');

-- Ting's Kitchen (V1: 694, V3: 941)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 1, 1, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 3, 3, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 4, 4, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 5, 5, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 6, 6, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (941, 'delivery', 7, 7, '16:00', '19:30');

-- Light of India (V1: 695, V3: 491)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 1, 1, '17:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 2, 2, '17:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 3, 3, '17:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 4, 4, '17:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 5, 5, '17:00', '22:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 6, 6, '17:00', '22:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (491, 'delivery', 7, 7, '17:00', '22:30');

-- Rangoli (V1: 701, V3: 497)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 1, 1, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 2, 2, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 3, 3, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 4, 4, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 5, 5, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 6, 6, '17:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (497, 'delivery', 7, 7, '17:00', '21:00');

-- Papa Pizza Val-Des-Monts (V1: 703, V3: 1014)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1014, 'delivery', 7, 7, '11:00', '21:00');

-- New Hong Kong (V1: 707, V3: 502)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 2, 2, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 6, 6, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (502, 'delivery', 7, 7, '15:00', '23:00');

-- Pizza Lovers Hunt Club (V1: 712, V3: 507)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 1, 1, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 2, 2, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 3, 3, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 4, 4, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 5, 5, '10:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 6, 6, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 6, 6, '10:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 7, 7, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (507, 'delivery', 7, 7, '12:00', '22:00');

-- Egg Roll Factory (V1: 716, V3: 511)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 1, 1, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 2, 2, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 3, 3, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 4, 4, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 5, 5, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 6, 6, '15:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (511, 'delivery', 7, 7, '15:00', '20:30');

-- Napolis (V1: 721, V3: 515)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 1, 1, '11:00', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 1, 1, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 2, 2, '11:00', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 2, 2, '17:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 3, 3, '11:00', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 3, 3, '17:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 4, 4, '11:00', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 4, 4, '17:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 5, 5, '11:00', '14:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 5, 5, '17:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (515, 'delivery', 6, 6, '16:30', '22:00');

-- HaNoi Pho (V1: 727, V3: 519)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 5, 5, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 6, 6, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (519, 'delivery', 7, 7, '11:00', '21:00');

-- Palermo Pizzeria (V1: 729, V3: 521)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (521, 'delivery', 7, 7, '12:00', '23:59');

-- Papa Grecque des Flandres (V1: 758, V3: 540)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 4, 4, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 5, 5, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 6, 6, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (540, 'delivery', 7, 7, '11:00', '23:00');

-- Pizza des Hautes Plaines (V1: 782, V3: 562)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 1, 1, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 2, 2, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 3, 3, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 4, 4, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 5, 5, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (562, 'delivery', 6, 6, '11:00', '22:30');

-- Milano (V1: 785, V3: 565)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 6, 6, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 7, 7, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (565, 'delivery', 7, 7, '11:00', '22:00');

-- Milano (V1: 789, V3: 569)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (569, 'delivery', 7, 7, '11:00', '23:59');

-- Crispy's (V1: 805, V3: 584)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 1, 1, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 2, 2, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 3, 3, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 4, 4, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 5, 5, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 6, 6, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (584, 'delivery', 7, 7, '16:00', '22:00');

-- Milano (V1: 807, V3: 586)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (586, 'delivery', 7, 7, '11:00', '22:00');

-- Milano (V1: 815, V3: 593)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 1, 1, '07:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 2, 2, '07:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 3, 3, '07:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 4, 4, '07:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 5, 5, '07:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 6, 6, '08:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (593, 'delivery', 7, 7, '09:00', '20:00');

-- Supreme Pizzeria (V1: 817, V3: 595)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 1, 1, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 2, 2, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 3, 3, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 4, 4, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 5, 5, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 6, 6, '11:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (595, 'delivery', 7, 7, '11:30', '23:59');

-- Sushi Fleury (V1: 818, V3: 596)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 5, 5, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 6, 6, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (596, 'delivery', 7, 7, '15:00', '21:00');

