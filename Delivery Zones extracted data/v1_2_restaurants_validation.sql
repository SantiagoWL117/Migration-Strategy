-- Pre-Migration Validation Queries

-- 1. Verify restaurants exist in V3
SELECT id, name, legacy_v1_id, legacy_v2_id
FROM menuca_v3.restaurants
WHERE id IN (730, 818)
ORDER BY id;

-- 2. Check existing delivery areas BEFORE migration
SELECT restaurant_id, COUNT(*) as area_count
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (730, 818)
GROUP BY restaurant_id;

-- Post-Migration Validation Queries (run after executing migration SQL)

-- 3. Verify inserted delivery areas
SELECT 
    rda.restaurant_id,
    r.name as restaurant_name,
    rda.area_number,
    rda.area_name,
    ST_IsValid(rda.geometry) as is_valid_polygon,
    ST_NumPoints(rda.geometry) as num_points,
    ROUND(ST_Area(rda.geometry::geography)) as area_square_meters,
    ST_AsText(ST_Centroid(rda.geometry)) as centroid
FROM menuca_v3.restaurant_delivery_areas rda
JOIN menuca_v3.restaurants r ON r.id = rda.restaurant_id
WHERE rda.restaurant_id IN (730, 818)
ORDER BY rda.restaurant_id, rda.area_number;

-- 4. Check for any invalid geometries
SELECT 
    restaurant_id,
    area_number,
    ST_IsValidReason(geometry) as invalid_reason
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (730, 818)
AND NOT ST_IsValid(geometry);

-- 5. Total count
SELECT COUNT(*) as total_areas
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (730, 818);
