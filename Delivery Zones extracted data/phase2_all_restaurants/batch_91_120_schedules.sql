-- Insert delivery schedules for batch_91_120
-- WARNING: This will DELETE existing delivery schedules and replace with V1 data

-- Delete existing delivery schedules for batch restaurants
DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN (696,736,601,745,714,638,644,726,602,616,701,735,624,727,614,646,607,680,715,660,651,641,636,681,721,716,630,711,712,730) AND type = 'delivery';

-- Milano (V1: 824, V3: 601)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (601, 'delivery', 7, 7, '11:00', '23:59');

-- Papa Pizza Cantley (V1: 825, V3: 602)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 4, 4, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (602, 'delivery', 7, 7, '11:00', '22:00');

-- Aroy Thai (V1: 830, V3: 607)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 2, 2, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 2, 2, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 3, 3, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 3, 3, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 4, 4, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 4, 4, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 5, 5, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 5, 5, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 6, 6, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 6, 6, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 7, 7, '11:00', '15:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (607, 'delivery', 7, 7, '16:00', '21:00');

-- Marina Pizza des Flandres (V1: 838, V3: 614)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (614, 'delivery', 7, 7, '16:00', '22:00');

-- Papa Grecque Maloney (V1: 840, V3: 616)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (616, 'delivery', 7, 7, '11:00', '23:00');

-- Milano (V1: 850, V3: 624)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (624, 'delivery', 7, 7, '11:00', '21:00');

-- Asia Garden Ottawa (V1: 856, V3: 630)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 2, 2, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 3, 3, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 4, 4, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 5, 5, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 6, 6, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (630, 'delivery', 7, 7, '15:00', '23:30');

-- Joes Family Pizzeria (V1: 863, V3: 636)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (636, 'delivery', 2, 2, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (636, 'delivery', 3, 3, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (636, 'delivery', 4, 4, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (636, 'delivery', 5, 5, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (636, 'delivery', 6, 6, '10:30', '21:00');

-- Digby's Restaurant (V1: 865, V3: 638)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 2, 2, '17:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 3, 3, '17:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 4, 4, '17:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 5, 5, '17:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 6, 6, '17:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (638, 'delivery', 7, 7, '17:00', '23:00');

-- China Moon (V1: 869, V3: 641)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 1, 1, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 2, 2, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 3, 3, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 4, 4, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 5, 5, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 6, 6, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (641, 'delivery', 7, 7, '15:00', '22:00');

-- Mozza Pizza Hull (V1: 872, V3: 644)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 1, 1, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 2, 2, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 3, 3, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 4, 4, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 5, 5, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (644, 'delivery', 7, 7, '11:00', '23:59');

-- JC Royal Thai Cuisine (V1: 874, V3: 646)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 2, 2, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 3, 3, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 4, 4, '11:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 5, 5, '11:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 6, 6, '12:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (646, 'delivery', 7, 7, '16:00', '21:00');

-- Milano (V1: 879, V3: 651)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 1, 1, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 2, 2, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 3, 3, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 4, 4, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 5, 5, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 6, 6, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (651, 'delivery', 7, 7, '11:00', '23:30');

-- Milano (V1: 889, V3: 660)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 1, 1, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 2, 2, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 3, 3, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 4, 4, '10:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 5, 5, '10:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 6, 6, '10:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (660, 'delivery', 7, 7, '10:30', '21:00');

-- Milano (V1: 913, V3: 680)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 4, 4, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (680, 'delivery', 7, 7, '11:00', '22:30');

-- Oka's Hull (V1: 914, V3: 681)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 5, 5, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 6, 6, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (681, 'delivery', 7, 7, '15:00', '21:00');

-- Pizza Maisonneuve (V1: 930, V3: 696)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 5, 5, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (696, 'delivery', 7, 7, '11:00', '23:59');

-- Milano (V1: 937, V3: 701)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 1, 1, '13:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 2, 2, '14:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 3, 3, '12:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 4, 4, '12:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 5, 5, '17:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 6, 6, '17:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (701, 'delivery', 7, 7, '17:00', '21:00');

-- Supreme Pizzeria (V1: 947, V3: 711)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 1, 1, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 2, 2, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 3, 3, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 4, 4, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 5, 5, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 6, 6, '10:30', '21:40');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (711, 'delivery', 7, 7, '10:30', '21:40');

-- Patate Lou Lou (V1: 948, V3: 712)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 1, 1, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 2, 2, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 3, 3, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 4, 4, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 5, 5, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 6, 6, '11:00', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (712, 'delivery', 7, 7, '11:00', '20:30');

-- Ogilvie Pizza (V1: 951, V3: 714)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 2, 2, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 3, 3, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 4, 4, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 5, 5, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 6, 6, '15:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (714, 'delivery', 7, 7, '15:30', '23:59');

-- La Poutinerie Ogilvie (V1: 952, V3: 715)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 5, 5, '11:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (715, 'delivery', 7, 7, '11:00', '23:00');

-- PizzaRama (V1: 953, V3: 716)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (716, 'delivery', 7, 7, '11:00', '23:00');

-- La Maison Pho (V1: 959, V3: 721)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 1, 1, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 2, 2, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 3, 3, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 6, 6, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (721, 'delivery', 7, 7, '12:00', '20:00');

-- Pizza Joanna (V1: 964, V3: 726)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 1, 1, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 2, 2, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 3, 3, '15:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 4, 4, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 5, 5, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (726, 'delivery', 6, 6, '15:00', '23:59');

-- La Maison du Burger (V1: 965, V3: 727)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 5, 5, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 6, 6, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 7, 7, '00:00', '02:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (727, 'delivery', 7, 7, '11:00', '23:59');

-- Friendly Restaurant and Pizzeria (V1: 968, V3: 730)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 1, 1, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 2, 2, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 3, 3, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 4, 4, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 5, 5, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 6, 6, '08:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (730, 'delivery', 7, 7, '08:00', '20:00');

-- Amicci Pizza (V1: 973, V3: 735)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 1, 1, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (735, 'delivery', 7, 7, '16:00', '22:00');

-- Greber Pizza et Shawarma (V1: 974, V3: 736)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 1, 1, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 2, 2, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 3, 3, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 4, 4, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 5, 5, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 6, 6, '16:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (736, 'delivery', 7, 7, '16:00', '22:00');

-- Sala Thai (V1: 983, V3: 745)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 1, 1, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 2, 2, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 3, 3, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 4, 4, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 5, 5, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 6, 6, '11:30', '20:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (745, 'delivery', 7, 7, '11:30', '20:30');

