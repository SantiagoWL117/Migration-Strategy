
-- Check which audited restaurants have V1/V2 source data
WITH audited_restaurants AS (
    SELECT DISTINCT restaurant_id
    FROM (VALUES 
        -- Add restaurant IDs from audit
        (561),
        (735),
        (607),
        (630),
        (69),
        (124),
        (833),
        (836),
        (269),
        (83),
        (841),
        (745),
        (777),
        (978),
        (106),
        (109),
        (497),
        (824),
        (716),
        (829),
        (260),
        (847),
        (981),
        (45),
        (87),
        (641),
        (957),
        (584),
        (806),
        (792),
        (28),
        (511),
        (735),
        (607),
        (630),
        (241),
        (973),
        (977),
        (124),
        (72),
        (131),
        (943),
        (962),
        (964),
        (963),
        (967),
        (966),
        (961),
        (965),
        (783),
        (784),
        (785),
        (196),
        (960),
        (638),
        (730),
        (930),
        (211),
        (736),
        (519),
        (160),
        (22),
        (119),
        (7),
        (180),
        (646),
        (38),
        (328),
        (636),
        (798),
        (84),
        (820),
        (985),
        (31),
        (35),
        (47),
        (57),
        (59),
        (90),
        (91),
        (93),
        (95),
        (126),
        (190),
        (349),
        (350),
        (515),
        (565),
        (586),
        (624),
        (644),
        (660),
        (680),
        (751),
        (790),
        (801),
        (819),
        (821),
        (837),
        (205),
        (62),
        (89),
        (714),
        (807),
        (681),
        (245),
        (521),
        (797),
        (822),
        (810),
        (616),
        (540),
        (437),
        (13),
        (70),
        (795),
        (112),
        (207),
        (498),
        (712),
        (199),
        (147),
        (139),
        (726),
        (507),
        (696),
        (976),
        (562),
        (846),
        (845),
        (502),
        (680),
        (35),
        (15),
        (234),
        (376),
        (711),
        (595),
        (348),
        (479),
        (789),
        (802)
    ) AS t(restaurant_id)
),
v1_data AS (
    SELECT DISTINCT CAST(restaurant AS INTEGER) as v1_restaurant_id
    FROM staging.menuca_v1_menu
),
v2_data AS (
    SELECT DISTINCT restaurant_id as v2_restaurant_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
),
mapping AS (
    SELECT 
        arm.new_restaurant_id as v3_restaurant_id,
        arm.old_restaurant_id as v1_restaurant_id,
        'v1' as source
    FROM archive.restaurant_id_mapping arm
    WHERE arm.old_restaurant_id IS NOT NULL
    UNION ALL
    SELECT 
        r.id as v3_restaurant_id,
        r.legacy_v2_id as v2_restaurant_id,
        'v2' as source
    FROM menuca_v3.restaurants r
    WHERE r.legacy_v2_id IS NOT NULL
)
SELECT 
    ar.restaurant_id,
    r.name,
    CASE 
        WHEN m.source = 'v1' AND v1.v1_restaurant_id IS NOT NULL THEN 'v1'
        WHEN m.source = 'v2' AND v2.v2_restaurant_id IS NOT NULL THEN 'v2'
        ELSE 'none'
    END as source_data_available,
    CASE 
        WHEN m.source = 'v1' AND v1.v1_restaurant_id IS NOT NULL THEN 'Re-import from staging.menuca_v1_menu'
        WHEN m.source = 'v2' AND v2.v2_restaurant_id IS NOT NULL THEN 'Re-import from V2 (check staging)'
        ELSE 'Scrape from live menu URL'
    END as recommendation
FROM audited_restaurants ar
LEFT JOIN menuca_v3.restaurants r ON ar.restaurant_id = r.id
LEFT JOIN mapping m ON ar.restaurant_id = m.v3_restaurant_id
LEFT JOIN v1_data v1 ON m.v1_restaurant_id = v1.v1_restaurant_id AND m.source = 'v1'
LEFT JOIN v2_data v2 ON m.v2_restaurant_id = v2.v2_restaurant_id AND m.source = 'v2'
ORDER BY ar.restaurant_id;
