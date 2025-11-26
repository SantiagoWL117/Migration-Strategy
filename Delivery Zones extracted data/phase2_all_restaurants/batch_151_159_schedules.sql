-- Insert delivery schedules for batch_151_159
-- WARNING: This will DELETE existing delivery schedules and replace with V1 data

-- Delete existing delivery schedules for batch restaurants
DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN (847,836,842,845,846,840,837,835) AND type = 'delivery';

-- Milano (V1: 1082, V3: 835)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (835, 'delivery', 7, 7, '11:00', '23:00');

-- Souvlaki Souvlaki (V1: 1083, V3: 836)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (836, 'delivery', 7, 7, '11:00', '23:00');

-- Milano (V1: 1084, V3: 837)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 6, 6, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (837, 'delivery', 7, 7, '11:00', '21:00');

-- Milano (V1: 1087, V3: 840)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 1, 1, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 2, 2, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 3, 3, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 4, 4, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 5, 5, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 6, 6, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (840, 'delivery', 7, 7, '11:00', '23:30');

-- Milano (V1: 1089, V3: 842)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (842, 'delivery', 7, 7, '11:00', '21:00');

-- Mykonos Greek Grill (V1: 1092, V3: 845)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (845, 'delivery', 7, 7, '11:00', '21:00');

-- Mykonos Greek Grill (V1: 1093, V3: 846)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 1, 1, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (846, 'delivery', 7, 7, '11:00', '23:00');

-- Sushiyana (V1: 1094, V3: 847)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 1, 1, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 2, 2, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 3, 3, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 6, 6, '15:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (847, 'delivery', 7, 7, '15:00', '20:00');

