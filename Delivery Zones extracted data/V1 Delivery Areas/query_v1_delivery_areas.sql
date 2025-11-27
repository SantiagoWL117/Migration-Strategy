-- Query V1 dump to find restaurants with non-empty deliveryArea BLOB data
-- Target: Unmigrated restaurants (101 total)

SELECT 
    id as v1_id,
    name as restaurant_name,
    multipleDeliveryArea,
    CASE 
        WHEN deliveryArea IS NULL THEN 'NULL'
        WHEN LENGTH(deliveryArea) = 0 THEN 'EMPTY'
        WHEN LENGTH(deliveryArea) > 0 THEN 'HAS_DATA'
    END as deliveryArea_status,
    LENGTH(deliveryArea) as blob_size_bytes,
    deliveryRadius,
    deliverToArea,
    delivery as delivery_enabled,
    latitude,
    longitude
FROM restaurants
WHERE id IN (
    161, 225, 228, 238, 246, 334, 411, 669, 695, 727, 758, 781, 782, 785, 789,
    805, 807, 815, 817, 818, 824, 825, 830, 838, 840, 850, 856, 863, 865, 869,
    872, 874, 879, 889, 913, 914, 937, 947, 948, 951, 952, 953, 959, 964, 965,
    968, 973, 974, 983, 987, 989, 998, 1025, 1027, 1028, 1032, 1033, 1035, 1039,
    1041, 1042, 1045, 1050, 1051, 1054, 1059, 1060, 1062, 1063, 1064, 1065, 1066,
    1069, 1070, 1074, 1080, 1082, 1083, 1084, 1087, 1088, 1089, 1092, 1093, 1094,
    694, 323, 1038, 1071, 364, 1095, 132, 231, 346, 1046, 173, 511
)
ORDER BY 
    CASE 
        WHEN deliveryArea IS NULL THEN 3
        WHEN LENGTH(deliveryArea) = 0 THEN 2
        WHEN LENGTH(deliveryArea) > 0 THEN 1
    END,
    id;

