#!/usr/bin/env python3
"""
Final extraction script for 2 restaurants with deliveryArea polygon data
Handles the complex escaping in the V1 dump correctly
"""
import re
import json
import sys
import codecs

if hasattr(sys.stdout, 'buffer'):
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

# Target restaurants
restaurants = {
    968: {'v3_id': 730, 'name': 'Friendly Restaurant and Pizzeria'},
    1062: {'v3_id': 818, 'name': 'Milano'}
}

print("="*100)
print("EXTRACTING DELIVERY AREA POLYGONS")
print("="*100)

content = open('Database/Legacy Schemas/v1_restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore').read()

extracted = []

for v1_id, info in restaurants.items():
    print(f"\n[{v1_id}] {info['name']} (V3 ID: {info['v3_id']})")
    
    # Find record
    pattern = rf'\({v1_id},'
    match = re.search(pattern, content)
    if not match:
        print("  ERROR: Not found!")
        continue
    
    # Find BLOB start
    start = match.start()
    chunk = content[start:]
    
    # Pattern: _binary 's:LENGTH:\\"JSON\\"'
    blob_match = re.search(r"_binary 's:(\d+):", chunk)
    if not blob_match:
        print("  ERROR: No BLOB found!")
        continue
    
    length = int(blob_match.group(1))
    blob_data_start = blob_match.end()
    
    # Extract the exact BLOB content
    blob_content = chunk[blob_data_start:blob_data_start+length]
    
    print(f"  BLOB length: {length}, extracted: {len(blob_content)}")
    
    # Clean the JSON:
    # 1. Remove opening and closing \\"
    if blob_content.startswith('\\"') and blob_content.endswith('\\"'):
        json_escaped = blob_content[2:-2]
    else:
        json_escaped = blob_content
    
    # 2. Unescape all \" to "
    json_clean = json_escaped.replace('\\"', '"')
    
    # 3. Remove any leading/trailing quotes that might be left
    json_clean = json_clean.strip().strip('"').strip()
    
    print(f"  JSON preview: {json_clean[:80]}...")
    
    # Parse JSON
    try:
        areas_data = json.loads(json_clean)
        print(f"  [OK] Parsed {len(areas_data)} delivery area(s)")
        
        # Process each area
        for area_num, coords in areas_data.items():
            if not coords or not isinstance(coords, dict):
                continue
            
            points = []
            for coord in coords.values():
                lat = coord.get('lat') or coord.get('Ya') or coord.get('ob') or coord.get('hb')
                lng = coord.get('lng') or coord.get('Za') or coord.get('pb') or coord.get('ib')
                
                if lat and lng:
                    points.append((float(lng), float(lat)))  # PostGIS: lng, lat
            
            if len(points) < 3:
                print(f"    Area {area_num}: Only {len(points)} points - SKIP")
                continue
            
            # Close polygon
            if points[0] != points[-1]:
                points.append(points[0])
            
            # Build WKT
            wkt_points = ', '.join([f"{lng} {lat}" for lng, lat in points])
            wkt = f"POLYGON(({wkt_points}))"
            
            extracted.append({
                'v1_id': v1_id,
                'v3_id': info['v3_id'],
                'name': info['name'],
                'area_number': int(area_num),
                'wkt': wkt,
                'num_points': len(points)
            })
            
            print(f"    Area {area_num}: {len(points)} points [OK]")
            
    except Exception as e:
        print(f"  ERROR: {e}")
        continue

# Generate SQL
print("\n" + "="*100)
print(f"EXTRACTED {len(extracted)} DELIVERY AREAS")
print("="*100)

if not extracted:
    print("\nNo data extracted!")
    sys.exit(1)

sql_lines = [
    "-- Migration SQL for 2 Restaurants with Polygon Data",
    "-- Extracted from V1 dump",
    "-- V1 IDs: 968 (Friendly Restaurant), 1062 (Milano)",
    "",
    "BEGIN;",
    ""
]

for data in extracted:
    sql = f"""-- V1 ID {data['v1_id']}: {data['name']} → V3 ID {data['v3_id']}, Area {data['area_number']}
INSERT INTO menuca_v3.restaurant_delivery_areas (
    restaurant_id,
    area_number,
    area_name,
    geometry
) VALUES (
    {data['v3_id']},
    {data['area_number']},
    'Delivery Zone {data['area_number']}',
    ST_GeomFromText('{data['wkt']}', 4326)
);
"""
    sql_lines.append(sql)

sql_lines.append("COMMIT;")
sql_lines.append("-- ROLLBACK; -- Uncomment to test without committing")

with open('Delivery Zones extracted data/v1_2_restaurants_migration.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines))

print(f"\n[OK] SQL file generated: v1_2_restaurants_migration.sql")
print(f"[OK] Total areas: {len(extracted)}")
for data in extracted:
    print(f"  - V1 ID {data['v1_id']} → V3 ID {data['v3_id']}, Area {data['area_number']}, {data['num_points']} points")

print("\n" + "="*100)
print("READY TO MIGRATE!")
print("="*100)

