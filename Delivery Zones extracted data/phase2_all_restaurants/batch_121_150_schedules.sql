-- Insert delivery schedules for batch_121_150
-- WARNING: This will DELETE existing delivery schedules and replace with V1 data

-- Delete existing delivery schedules for batch restaurants
DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN (1015,797,785,783,818,751,815,807,795,784,810,821,806,749,829,824,816,822,790,819,756,948,820,801,798,792,789) AND type = 'delivery';

-- Milano (V1: 987, V3: 749)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 1, 1, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 2, 2, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 3, 3, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 4, 4, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 5, 5, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (749, 'delivery', 7, 7, '11:00', '21:00');

-- Milano (V1: 989, V3: 751)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 4, 4, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (751, 'delivery', 7, 7, '11:00', '22:30');

-- Little Gyros Greek Grill (V1: 998, V3: 756)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 1, 1, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 2, 2, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 3, 3, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (756, 'delivery', 6, 6, '11:00', '20:00');

-- Colonnade Pizza (V1: 1025, V3: 783)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 1, 1, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 2, 2, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 3, 3, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 4, 4, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 5, 5, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 6, 6, '11:00', '21:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (783, 'delivery', 7, 7, '11:00', '21:30');

-- Colonnade Pizza (V1: 1027, V3: 784)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 1, 1, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 2, 2, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 3, 3, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 6, 6, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (784, 'delivery', 7, 7, '11:00', '20:00');

-- Colonnade Pizza (V1: 1028, V3: 785)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 1, 1, '16:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 2, 2, '11:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 3, 3, '11:00', '19:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 4, 4, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 5, 5, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 6, 6, '11:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (785, 'delivery', 7, 7, '16:00', '19:30');

-- Poutinerie Québecurds Hull (V1: 1032, V3: 789)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 4, 4, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (789, 'delivery', 7, 7, '11:00', '22:30');

-- Nachos Loco Hull (V1: 1033, V3: 790)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (790, 'delivery', 7, 7, '11:00', '22:30');

-- Dumpling Bowl (V1: 1035, V3: 792)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 1, 1, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 2, 2, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 3, 3, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 4, 4, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 5, 5, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 6, 6, '12:00', '20:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (792, 'delivery', 7, 7, '12:00', '20:00');

-- All Out Burger Gladstone (V1: 1038, V3: 948)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (948, 'delivery', 7, 7, '15:00', '21:00');

-- Papa Pizza Chem. de Masson (V1: 1039, V3: 795)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (795, 'delivery', 7, 7, '11:00', '21:00');

-- Papa Burger (V1: 1041, V3: 797)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 1, 1, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 4, 4, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 5, 5, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 6, 6, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (797, 'delivery', 7, 7, '11:00', '23:00');

-- Kabylie Pizza (V1: 1042, V3: 798)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (798, 'delivery', 7, 7, '11:00', '22:00');

-- Nachos Loco Gatineau (V1: 1045, V3: 801)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 4, 4, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (801, 'delivery', 7, 7, '11:00', '22:30');

-- Poutinerie Québecurds Gatineau (V1: 1046, V3: 1015)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 1, 1, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 2, 2, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 3, 3, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 4, 4, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 6, 6, '11:00', '22:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (1015, 'delivery', 7, 7, '11:00', '22:30');

-- Crispy's Bank Street (V1: 1050, V3: 806)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 1, 1, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 2, 2, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 3, 3, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 4, 4, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 5, 5, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 6, 6, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (806, 'delivery', 7, 7, '16:00', '22:00');

-- Oh My Grill (V1: 1051, V3: 807)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 1, 1, '12:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 2, 2, '12:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 3, 3, '12:30', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 4, 4, '12:30', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 5, 5, '12:30', '22:45');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 6, 6, '13:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (807, 'delivery', 7, 7, '13:00', '22:00');

-- Papa Grecque Cantley (V1: 1054, V3: 810)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 4, 4, '11:00', '23:30');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (810, 'delivery', 7, 7, '11:00', '22:00');

-- Golden Center Pizza (V1: 1059, V3: 815)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 5, 5, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 6, 6, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (815, 'delivery', 7, 7, '14:00', '21:00');

-- Dépanneur Généreux (V1: 1060, V3: 816)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (816, 'delivery', 7, 7, '11:00', '22:00');

-- Milano (V1: 1062, V3: 818)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 1, 1, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 2, 2, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 3, 3, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (818, 'delivery', 7, 7, '12:00', '22:00');

-- Milano (V1: 1063, V3: 819)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 1, 1, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 2, 2, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 3, 3, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 4, 4, '11:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 5, 5, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 6, 6, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (819, 'delivery', 7, 7, '11:00', '21:00');

-- Vieux Hull Pizza (V1: 1064, V3: 820)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 1, 1, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 1, 1, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 2, 2, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 2, 2, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 3, 3, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 3, 3, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 4, 4, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 5, 5, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 6, 6, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 7, 7, '00:00', '01:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (820, 'delivery', 7, 7, '11:00', '23:59');

-- Milano (V1: 1065, V3: 821)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 1, 1, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 2, 2, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 3, 3, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 4, 4, '16:00', '21:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 5, 5, '16:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 6, 6, '12:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (821, 'delivery', 7, 7, '16:00', '21:00');

-- Papa Burger Maloney (V1: 1066, V3: 822)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 1, 1, '10:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 2, 2, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 3, 3, '11:00', '23:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 4, 4, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 5, 5, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 6, 6, '10:30', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (822, 'delivery', 7, 7, '11:00', '23:00');

-- Prima Pizza (V1: 1069, V3: 824)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 1, 1, '00:00', '03:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 1, 1, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 2, 2, '00:00', '03:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 2, 2, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 3, 3, '00:00', '03:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 3, 3, '15:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 4, 4, '00:00', '03:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 4, 4, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 5, 5, '00:00', '04:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 6, 6, '00:00', '04:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 7, 7, '00:00', '04:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (824, 'delivery', 7, 7, '15:00', '23:59');

-- Pizzalicious (V1: 1074, V3: 829)
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 1, 1, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 2, 2, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 3, 3, '15:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 4, 4, '11:00', '22:00');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 5, 5, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 6, 6, '11:00', '23:59');
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (829, 'delivery', 7, 7, '15:00', '21:00');

