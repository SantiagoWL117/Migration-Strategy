#!/usr/bin/env python3
"""
Extract polygon data for V1 IDs 968 and 1062 and generate V3 migration SQL
"""
import re
import json

# Target restaurants with polygon data
target_restaurants = {
    968: {'v3_id': 730, 'name': 'Friendly Restaurant and Pizzeria'},
    1062: {'v3_id': 818, 'name': 'Milano'}
}

print("="*100)
print("EXTRACTING POLYGON DATA FOR 2 RESTAURANTS")
print("="*100)

# Read the V1 dump
with open('Database/Legacy Schemas/v1_restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

extracted_data = []

for v1_id, info in target_restaurants.items():
    v3_id = info['v3_id']
    name = info['name']
    
    print(f"\n[{v1_id}] Processing: {name} (V3 ID: {v3_id})")
    
    # Find the record
    pattern = rf"\({v1_id},'([^']*)',"
    match = re.search(pattern, content)
    
    if not match:
        print(f"  ERROR: Restaurant not found in dump!")
        continue
    
    # Extract the record chunk - make it large enough for big polygons
    start_pos = match.start()
    chunk = content[start_pos:start_pos+200000]  # 200KB should be enough
    
    # Find the deliveryArea BLOB - two-step approach
    # Step 1: Find the BLOB start pattern
    blob_start = re.search(r"_binary 's:(\d+):", chunk)
    
    if not blob_start:
        print(f"  ERROR: Could not find BLOB start pattern!")
        continue
    
    blob_length_int = int(blob_start.group(1))
    blob_length = blob_start.group(1)
    
    # Step 2: Extract the JSON content using the specified length
    # The format is: s:LENGTH:\\"JSON_HERE\\"
    # The JSON is exactly blob_length_int characters
    json_start_pos = blob_start.end()
    
    # Check if it starts with \\" (the opening quote for the JSON string)
    if not chunk[json_start_pos:json_start_pos+3] == '\\\\"':
        print(f"  WARNING: Expected \\\" but got: {repr(chunk[json_start_pos:json_start_pos+10])}")
    
    # Extract exactly blob_length_int characters starting from the opening \\"
    json_str = chunk[json_start_pos:json_start_pos+blob_length_int]
    
    if len(json_str) < blob_length_int:
        print(f"  ERROR: Not enough data! Expected {blob_length_int} chars, got {len(json_str)}")
        continue
    
    print(f"  BLOB length: {blob_length} characters")
    
    # Parse the JSON
    try:
        # Debug: show first 100 chars
        print(f"  Raw JSON (first 100 chars): {repr(json_str[:100])}")
        
        # The JSON string is escaped: \\"{\\"1\\":{...}}\\"
        # First, check what we actually have
        print(f"  Starts with backslash-quote: {json_str[:3]}")
        print(f"  Ends with backslash-quote: {json_str[-3:]}")
        
        # Remove the opening and closing \\" (backslash-backslash-quote)
        # In Python string literals, \\\\" means: backslash backslash quote
        # But in the actual data, it's: backslash quote
        # So we need to look for: \\"
        if json_str.startswith('\\"') and json_str.endswith('\\"'):
            json_str = json_str[2:-2]
            print(f"  After trimming quotes (first 100): {repr(json_str[:100])}")
        
        # Now unescape the remaining backslashes
        # Replace \\" with "
        json_str_clean = json_str.replace('\\"', '"')
        print(f"  After unescaping (first 100): {repr(json_str_clean[:100])}")
        
        areas = json.loads(json_str_clean)
        
        print(f"  Found {len(areas)} delivery area(s)")
        
        # Process each area
        for area_num, coordinates in areas.items():
            if not coordinates:
                continue
            
            print(f"    Area {area_num}: {len(coordinates)} coordinate points")
            
            # Extract coordinates
            points = []
            for coord in coordinates.values() if isinstance(coordinates, dict) else coordinates:
                # Check for different coordinate key variations
                lat = coord.get('lat') or coord.get('Ya') or coord.get('ob') or coord.get('hb')
                lng = coord.get('lng') or coord.get('Za') or coord.get('pb') or coord.get('ib')
                
                if lat is not None and lng is not None:
                    points.append((float(lng), float(lat)))  # PostGIS uses lng,lat order
            
            if len(points) < 3:
                print(f"      WARNING: Only {len(points)} points - need at least 3!")
                continue
            
            # Close the polygon if not already closed
            if points[0] != points[-1]:
                points.append(points[0])
            
            print(f"      Valid polygon with {len(points)} points (including closing point)")
            
            # Build WKT polygon string
            wkt_points = ', '.join([f"{lng} {lat}" for lng, lat in points])
            wkt = f"POLYGON(({wkt_points}))"
            
            extracted_data.append({
                'v1_id': v1_id,
                'v3_id': v3_id,
                'name': name,
                'area_number': int(area_num),
                'area_name': f"Delivery Zone {area_num}",
                'wkt': wkt,
                'num_points': len(points)
            })
            
    except Exception as e:
        print(f"  ERROR parsing JSON: {e}")
        continue

# Generate SQL
print("\n" + "="*100)
print("GENERATING MIGRATION SQL")
print("="*100)

sql_statements = []

sql_statements.append("-- Migration SQL for 2 Restaurants with Polygon Data")
sql_statements.append("-- Generated from V1 dump analysis")
sql_statements.append("-- V1 IDs: 968, 1062")
sql_statements.append("")
sql_statements.append("BEGIN;")
sql_statements.append("")

for data in extracted_data:
    sql = f"""-- V1 ID {data['v1_id']}: {data['name']} → V3 ID {data['v3_id']}
INSERT INTO menuca_v3.restaurant_delivery_areas (
    restaurant_id,
    area_number,
    area_name,
    geometry
) VALUES (
    {data['v3_id']},
    {data['area_number']},
    '{data['area_name']}',
    ST_GeomFromText('{data['wkt']}', 4326)
);
"""
    sql_statements.append(sql)

sql_statements.append("COMMIT;")
sql_statements.append("-- ROLLBACK; -- Use this instead if you want to test first")

# Write SQL file
sql_output = '\n'.join(sql_statements)
with open('Delivery Zones extracted data/v1_2_restaurants_migration.sql', 'w', encoding='utf-8') as f:
    f.write(sql_output)

import sys
import codecs
if hasattr(sys.stdout, 'buffer'):
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

print(f"\n[OK] SQL file generated: v1_2_restaurants_migration.sql")

# Generate validation queries
validation_sql = f"""-- Validation Queries for 2 Restaurant Migration

-- Check if restaurants exist in V3
SELECT id, name, legacy_v1_id 
FROM menuca_v3.restaurants 
WHERE id IN (730, 818)
ORDER BY id;

-- Count delivery areas BEFORE migration
SELECT COUNT(*) as before_count 
FROM menuca_v3.restaurant_delivery_areas 
WHERE restaurant_id IN (730, 818);

-- After migration, verify inserted areas
SELECT 
    restaurant_id,
    area_number,
    area_name,
    ST_IsValid(geometry) as is_valid_polygon,
    ST_NumPoints(geometry) as num_points,
    ST_Area(geometry::geography) as area_square_meters
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (730, 818)
ORDER BY restaurant_id, area_number;

-- Check for any invalid geometries
SELECT restaurant_id, area_number, ST_IsValidReason(geometry) as reason
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id IN (730, 818)
AND NOT ST_IsValid(geometry);
"""

with open('Delivery Zones extracted data/v1_2_restaurants_validation.sql', 'w', encoding='utf-8') as f:
    f.write(validation_sql)

print(f"[OK] Validation queries generated: v1_2_restaurants_validation.sql")

# Print summary
print("\n" + "="*100)
print("EXTRACTION SUMMARY")
print("="*100)

for data in extracted_data:
    print(f"\n[OK] V1 ID {data['v1_id']} -> V3 ID {data['v3_id']}")
    print(f"  Name: {data['name']}")
    print(f"  Area: {data['area_name']}")
    print(f"  Points: {data['num_points']}")

print(f"\n{'='*100}")
print(f"Total delivery areas to migrate: {len(extracted_data)}")
print(f"{'='*100}")

# Save extraction details
details = {
    'extraction_date': '2025-11-26',
    'source': 'v1_restaurants_dump.sql',
    'restaurants_processed': len(target_restaurants),
    'delivery_areas_extracted': len(extracted_data),
    'restaurants': [
        {
            'v1_id': data['v1_id'],
            'v3_id': data['v3_id'],
            'name': data['name'],
            'area_number': data['area_number'],
            'num_points': data['num_points']
        }
        for data in extracted_data
    ]
}

with open('Delivery Zones extracted data/v1_2_restaurants_extraction_details.json', 'w', encoding='utf-8') as f:
    json.dump(details, f, indent=2, ensure_ascii=False)

print(f"\n[OK] Extraction details saved: v1_2_restaurants_extraction_details.json")
print(f"\n{'='*100}")
print("READY TO MIGRATE!")
print("="*100)
print("\nNext steps:")
print("1. Review the generated SQL file: v1_2_restaurants_migration.sql")
print("2. Run validation queries BEFORE migration: v1_2_restaurants_validation.sql")
print("3. Execute the migration SQL")
print("4. Run validation queries AFTER migration to verify")
print("="*100)

