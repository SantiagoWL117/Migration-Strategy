#!/usr/bin/env python3
"""
Extract polygon data for 2 restaurants using Phase 1 MVP method
This method successfully extracted 6 delivery areas for MVP restaurants
"""
import re
import json
import sys
import codecs

# Fix Unicode output on Windows
if hasattr(sys.stdout, 'buffer'):
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

# Target restaurants
restaurants = {
    968: {'v3_id': 730, 'name': 'Friendly Restaurant and Pizzeria'},
    1062: {'v3_id': 818, 'name': 'Milano'}
}

print("="*100)
print("EXTRACTING POLYGON DATA USING PHASE 1 MVP METHOD")
print("="*100)

# Read V1 dump
with open('Database/Legacy Schemas/v1_restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

extracted_areas = []

for v1_id, info in restaurants.items():
    v3_id = info['v3_id']
    name = info['name']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    # Find the restaurant record
    pattern = rf'\({v1_id},\'([^\']*)\',\'([^\']*)\',_binary \'([^\']+)\''
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        print(f"  ERROR: Restaurant not found in dump!")
        continue
    
    blob_data = match.group(3)
    
    print(f"  Found BLOB data (length: {len(blob_data)} chars)")
    
    # Phase 1 MVP Method (lines 213-224 from deserialize_blobs.py):
    # First unescape the data
    unescaped = blob_data.replace('\\"', '"')
    
    # Extract JSON string from serialized format
    # The format is s:LENGTH:"JSON_STRING" but after unescaping quotes are literal
    # Match: s:NUMBER:"{...}"
    json_match = re.search(r's:(\d+):"(\{.+?\})";?\s*', unescaped, re.DOTALL)
    
    if not json_match:
        print(f"  ERROR: Could not extract JSON from BLOB!")
        print(f"  Unescaped preview (first 200 chars): {unescaped[:200]}")
        continue
    
    json_string = json_match.group(2)  # Group 2 is the JSON content
    
    try:
        # Decode the JSON
        areas = json.loads(json_string)
        
        print(f"  Successfully decoded {len(areas)} delivery area(s)")
        
        # V1 format: {"1":[polygon points],"2":[...],...}
        for area_number, points_data in areas.items():
            if not points_data or not isinstance(points_data, dict):
                continue
            
            # Extract coordinates
            polygon_points = []
            
            # Points are keyed as "0", "1", "2", etc.
            for point_key in sorted(points_data.keys(), key=lambda x: int(x) if x.isdigit() else 0):
                point = points_data[point_key]
                
                # Check for different coordinate key variations
                lat = point.get('lat') or point.get('Ya') or point.get('ob') or point.get('hb')
                lng = point.get('lng') or point.get('Za') or point.get('pb') or point.get('ib')
                
                if lat is not None and lng is not None:
                    # PostGIS uses (longitude, latitude) order
                    polygon_points.append((float(lng), float(lat)))
            
            if len(polygon_points) < 3:
                print(f"    Area {area_number}: Only {len(polygon_points)} points - SKIP (need at least 3)")
                continue
            
            # Close the polygon (first point = last point)
            if polygon_points[0] != polygon_points[-1]:
                polygon_points.append(polygon_points[0])
            
            # Generate WKT (Well-Known Text) format for PostGIS
            wkt_coords = ', '.join([f"{lng} {lat}" for lng, lat in polygon_points])
            wkt = f"POLYGON(({wkt_coords}))"
            
            extracted_areas.append({
                'v1_id': v1_id,
                'v3_id': v3_id,
                'restaurant_name': name,
                'area_number': int(area_number),
                'area_name': f"Delivery Zone {area_number}",
                'geometry_wkt': wkt,
                'num_points': len(polygon_points)
            })
            
            print(f"    Area {area_number}: {len(polygon_points)} points (including closing point) [OK]")
    
    except json.JSONDecodeError as e:
        print(f"  ERROR decoding JSON: {e}")
        print(f"  JSON string (first 200 chars): {json_string[:200]}")
    except Exception as e:
        print(f"  ERROR: {e}")

# Generate Migration SQL
print("\n" + "="*100)
print(f"EXTRACTION COMPLETE: {len(extracted_areas)} DELIVERY AREAS")
print("="*100)

if not extracted_areas:
    print("\nERROR: No delivery areas were extracted!")
    exit(1)

# Build SQL file
sql_lines = [
    "-- Migration SQL for 2 Restaurants with Delivery Area Polygons",
    "-- Extracted from V1 dump using Phase 1 MVP method",
    "-- Date: 2025-11-26",
    "--",
    "-- Restaurants:",
    f"--   V1 ID 968  -> V3 ID 730 (Friendly Restaurant and Pizzeria)",
    f"--   V1 ID 1062 -> V3 ID 818 (Milano - 2609 Laurier St, Rockland)",
    "",
    "BEGIN;",
    ""
]

for area in extracted_areas:
    sql = f"""-- {area['restaurant_name']} - Area {area['area_number']}
INSERT INTO menuca_v3.restaurant_delivery_areas (
    restaurant_id,
    area_number,
    area_name,
    geometry
) VALUES (
    {area['v3_id']},
    {area['area_number']},
    '{area['area_name']}',
    ST_GeomFromText('{area['geometry_wkt']}', 4326)
);
"""
    sql_lines.append(sql)

sql_lines.append("")
sql_lines.append("COMMIT;")
sql_lines.append("-- ROLLBACK;  -- Uncomment to test without committing")

# Write SQL file
sql_output = '\n'.join(sql_lines)
with open('Delivery Zones extracted data/v1_2_restaurants_final_migration.sql', 'w', encoding='utf-8') as f:
    f.write(sql_output)

print(f"\n[OK] Migration SQL generated: v1_2_restaurants_final_migration.sql")

# Write detailed JSON
details = {
    'extraction_date': '2025-11-26',
    'method': 'Phase 1 MVP deserialization',
    'source_file': 'v1_restaurants_dump.sql',
    'total_restaurants': len(restaurants),
    'total_areas_extracted': len(extracted_areas),
    'areas': [
        {
            'v1_id': area['v1_id'],
            'v3_id': area['v3_id'],
            'restaurant_name': area['restaurant_name'],
            'area_number': area['area_number'],
            'num_points': area['num_points']
        }
        for area in extracted_areas
    ]
}

with open('Delivery Zones extracted data/v1_2_restaurants_extraction_details.json', 'w', encoding='utf-8') as f:
    json.dump(details, f, indent=2, ensure_ascii=False)

print(f"[OK] Extraction details saved: v1_2_restaurants_extraction_details.json")

# Generate validation queries
validation_sql = """-- Pre-Migration Validation Queries

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
"""

with open('Delivery Zones extracted data/v1_2_restaurants_validation.sql', 'w', encoding='utf-8') as f:
    f.write(validation_sql)

print(f"[OK] Validation queries generated: v1_2_restaurants_validation.sql")

# Summary
print("\n" + "="*100)
print("SUMMARY")
print("="*100)
for area in extracted_areas:
    print(f"  V1 ID {area['v1_id']:4d} -> V3 ID {area['v3_id']:3d} | {area['restaurant_name']:40s} | Area {area['area_number']} | {area['num_points']:3d} points")

print(f"\n{'='*100}")
print("READY TO MIGRATE!")
print("="*100)
print("\nNext steps:")
print("1. Review: v1_2_restaurants_final_migration.sql")
print("2. Run pre-migration validation queries")
print("3. Execute the migration SQL")
print("4. Run post-migration validation to verify")
print("="*100)

