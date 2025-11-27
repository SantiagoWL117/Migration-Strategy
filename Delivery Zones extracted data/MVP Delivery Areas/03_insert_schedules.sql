-- Insert delivery schedules for MVP restaurants
-- Based on V1 delivery_schedule BLOB deserialization
-- Target table: menuca_v3.restaurant_schedules

-- Lucky Star Chinese Food (V1 ID: 90, V3 ID: 8)
-- 7 schedule entries

INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 1, 1, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 2, 2, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 3, 3, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 4, 4, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 5, 5, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 6, 6, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (8, 'delivery', 7, 7, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;

-- Champa Thai Cuisine (V1 ID: 203, V3 ID: 87)
-- 13 schedule entries

INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 1, 1, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 1, 1, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 2, 2, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 2, 2, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 3, 3, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 3, 3, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 4, 4, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 4, 4, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 5, 5, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 5, 5, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 6, 6, '11:30', '14:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 6, 6, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (87, 'delivery', 7, 7, '16:00', '20:45') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;

-- Ginkgo Garden (V1 ID: 224, V3 ID: 105)
-- 6 schedule entries

INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 2, 2, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 3, 3, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 4, 4, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 5, 5, '11:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 6, 6, '15:30', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (105, 'delivery', 7, 7, '15:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;

-- Hung Mein (V1 ID: 239, V3 ID: 119)
-- 9 schedule entries

INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 1, 1, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 2, 2, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 3, 3, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 4, 4, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 5, 5, '15:00', '23:59') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 6, 6, '00:00', '01:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 6, 6, '15:00', '23:59') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 7, 7, '00:00', '01:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (119, 'delivery', 7, 7, '15:00', '22:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;

-- Orchid Sushi (V1 ID: 387, V3 ID: 245)
-- 7 schedule entries

INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 1, 1, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 2, 2, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 3, 3, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 4, 4, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 5, 5, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 6, 6, '16:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, type, day_start, day_stop, time_start, time_stop) VALUES (245, 'delivery', 7, 7, '11:00', '21:00') ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;
