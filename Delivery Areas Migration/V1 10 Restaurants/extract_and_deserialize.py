#!/usr/bin/env python3
"""
Extract and Deserialize V1 Delivery Areas
==========================================
Parses SQL dump file and extracts delivery area polygons for 10 restaurants.
Outputs PostGIS-compatible SQL INSERT statements.
"""

import json
import re
import os
from datetime import datetime

print("=" * 70)
print("V1 DELIVERY AREAS EXTRACTION - 10 Restaurants")
print("=" * 70)
print()

# =============================================================================
# STEP 1: Load ID Mappings
# =============================================================================
print("[STEP 1] Loading ID mappings...")

with open('v1_id_mappings.json', 'r', encoding='utf-8') as f:
    mappings_data = json.load(f)

id_mappings = {m['v1_id']: m for m in mappings_data['mappings']}
print(f"  Loaded {len(id_mappings)} restaurant mappings")
print()

# =============================================================================
# STEP 2: Parse SQL Dump File
# =============================================================================
print("[STEP 2] Parsing SQL dump file...")

dump_file = '../../Database/Legacy Dumps/v1_restaurants_delivery_areas_dump.sql'

with open(dump_file, 'r', encoding='utf-8') as f:
    dump_content = f.read()

# Find the INSERT statement - look for VALUES until the final );
# The data contains semicolons in JSON, so we can't use ; as the terminator
# Instead, find from VALUES to the line that ends with );
insert_start = dump_content.find("INSERT INTO `santiago_restaurants_delivery_areas` VALUES ")
if insert_start == -1:
    print("  ERROR: Could not find INSERT statement in dump file")
    exit(1)

# Find the end - look for '); that ends the INSERT
values_start = insert_start + len("INSERT INTO `santiago_restaurants_delivery_areas` VALUES ")
insert_end = dump_content.find("');", values_start)
if insert_end == -1:
    print("  ERROR: Could not find end of INSERT statement")
    exit(1)

values_str = dump_content[values_start:insert_end+2]  # Include the final ')
print(f"  Found INSERT statement ({len(values_str)} chars)")

# Parse individual records
# Format: (id,'name','address',_binary 'blob_data')
# Note: Names and addresses can contain escaped apostrophes like \'
# Split by record separators and parse each one

# Split by "),(" to get individual records
raw_records = re.split(r'\'\),\(', values_str)
print(f"  Split into {len(raw_records)} raw segments")

records = []
for i, raw in enumerate(raw_records):
    # Clean up first and last records
    if i == 0:
        raw = raw.lstrip('(')
    if i == len(raw_records) - 1:
        raw = raw.rstrip("')")
    else:
        raw = raw + "'"  # Add back the trailing quote we split on
    
    # Pattern: id,'name','address',_binary 'blob'
    # Handle escaped quotes in name/address
    match = re.match(r"(\d+),'((?:[^'\\]|\\.)*)','((?:[^'\\]|\\.)*)',_binary '(.*)", raw, re.DOTALL)
    if match:
        v1_id = match.group(1)
        name = match.group(2).replace("\\'", "'")  # Unescape quotes
        address = match.group(3).replace("\\'", "'")
        blob = match.group(4).rstrip("'")  # Remove trailing quote if present
        records.append((v1_id, name, address, blob))

print(f"  Extracted {len(records)} records")
print()

# =============================================================================
# STEP 3: Extract BLOB Data
# =============================================================================
print("[STEP 3] Extracting BLOB data...")

extracted_blobs = []

for record in records:
    v1_id = int(record[0])
    name = record[1]
    address = record[2]
    blob_data = record[3]
    
    if v1_id in id_mappings:
        mapping = id_mappings[v1_id]
        extracted_blobs.append({
            'v1_id': v1_id,
            'v3_id': mapping['v3_id'],
            'restaurant_name': name,
            'address': address,
            'blob_data': blob_data
        })
        print(f"  [{v1_id}] {name} -> V3 ID: {mapping['v3_id']}")

print(f"\n  Total extracted: {len(extracted_blobs)} restaurants")

# Save extracted blobs
with open('v1_blob_deliveryArea.json', 'w', encoding='utf-8') as f:
    json.dump(extracted_blobs, f, indent=2, ensure_ascii=False)
print(f"  Saved: v1_blob_deliveryArea.json")
print()

# =============================================================================
# STEP 4: Deserialize BLOB Data
# =============================================================================
print("[STEP 4] Deserializing delivery area coordinates...")
print("-" * 70)

area_results = {}
total_zones = 0
errors = []

for restaurant in extracted_blobs:
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['restaurant_name']
    blob_data = restaurant['blob_data']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    # Clean up the blob data
    # Remove HTML tags like <br>
    cleaned = re.sub(r'<br\s*/?>', '', blob_data)
    
    # The deliveryArea BLOB is in PHP serialized format: s:LENGTH:"JSON_STRING"
    # The data may have escaped backslashes like \" representing actual quotes
    
    # First, handle the case where quotes are escaped with backslash
    # Pattern: s:NUMBER:\"{ ... }\"
    match = re.search(r's:(\d+):\\"(\{.+\})\\";?', cleaned, re.DOTALL)
    
    if not match:
        # Try without escaped quotes (standard format)
        match = re.search(r's:(\d+):"(\{.+\})";?', cleaned, re.DOTALL)
    
    if not match:
        print(f"  WARNING: Could not extract JSON from serialized format")
        print(f"  Raw data preview: {blob_data[:100]}...")
        errors.append(f"{name} (V1 ID: {v1_id}): Could not parse BLOB")
        continue
    
    json_string = match.group(2)
    
    # Unescape the JSON string (remove backslashes before quotes)
    json_string = json_string.replace('\\"', '"')
    json_string = json_string.replace('\\\\', '\\')
    
    try:
        areas = json.loads(json_string)
    except json.JSONDecodeError as e:
        print(f"  ERROR: JSON decode failed - {e}")
        print(f"  JSON preview: {json_string[:200]}...")
        errors.append(f"{name} (V1 ID: {v1_id}): JSON decode error")
        continue
    
    print(f"  Successfully decoded JSON")
    
    # Process each delivery zone (1-10)
    area_entries = []
    
    for zone_num, coordinates in areas.items():
        # Skip empty zones
        if not coordinates:
            continue
        
        # Handle both array format [{...}] and object format {"0":{...}}
        if isinstance(coordinates, dict):
            # Convert object to list
            coord_list = [coordinates[k] for k in sorted(coordinates.keys(), key=lambda x: int(x))]
        elif isinstance(coordinates, list):
            coord_list = coordinates
        else:
            continue
        
        if not coord_list:
            continue
        
        # Extract lat/lng from various key formats
        # Key mappings discovered from V1/V2 data:
        #   lat/lng - standard
        #   nb/ob - Papa Pizza, Vieux Hull (nb=lat, ob=lng)
        #   Ya/Za - Lucky Star format
        #   k/B - Mano City format
        #   k/A - Orchid Sushi format
        #   lb/mb - Hung Mein format
        #   d/e - Papa Pizza Maloney format
        points = []
        for point in coord_list:
            lat = None
            lng = None
            
            # Try different latitude keys (45.x values)
            for key in ['lat', 'nb', 'Ya', 'k', 'lb', 'd']:
                if key in point:
                    lat = point[key]
                    break
            
            # Try different longitude keys (-75.x values)
            for key in ['lng', 'ob', 'Za', 'A', 'B', 'mb', 'pb', 'e']:
                if key in point:
                    lng = point[key]
                    break
            
            if lat is not None and lng is not None:
                # PostGIS uses lng,lat order (X,Y)
                points.append(f"{lng} {lat}")
        
        if len(points) < 3:
            print(f"  Zone {zone_num}: Skipped (only {len(points)} points)")
            continue
        
        # Close the polygon by repeating the first point
        if points[0] != points[-1]:
            points.append(points[0])
        
        polygon_wkt = f"POLYGON(({','.join(points)}))"
        
        area_entries.append({
            'restaurant_id': v3_id,
            'area_number': int(zone_num),
            'area_name': f"Delivery Zone {zone_num}",
            'coordinates_count': len(coord_list),
            'polygon_wkt': polygon_wkt
        })
        
        total_zones += 1
        print(f"  Zone {zone_num}: {len(coord_list)} coordinates -> PostGIS polygon")
    
    area_results[str(v1_id)] = {
        'v1_id': v1_id,
        'v3_id': v3_id,
        'restaurant_name': name,
        'area_entries': area_entries
    }

print()
print("-" * 70)
print(f"Deserialization complete: {len(area_results)} restaurants, {total_zones} delivery zones")

# Save deserialized areas
with open('deserialized_areas.json', 'w', encoding='utf-8') as f:
    json.dump(area_results, f, indent=2, ensure_ascii=False)
print(f"Saved: deserialized_areas.json")
print()

# =============================================================================
# STEP 5: Generate Migration SQL
# =============================================================================
print("[STEP 5] Generating migration SQL...")

sql_lines = []
sql_lines.append("-- ============================================================================")
sql_lines.append("-- V1 Delivery Areas Migration (10 Restaurants)")
sql_lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
sql_lines.append("-- ============================================================================")
sql_lines.append("--")
sql_lines.append(f"-- Total Restaurants: {len(area_results)}")
sql_lines.append(f"-- Total Delivery Zones: {total_zones}")
sql_lines.append("--")
sql_lines.append("-- Source: V1 deliveryArea BLOB (deserialized)")
sql_lines.append("-- Target: menuca_v3.restaurant_delivery_areas")
sql_lines.append("-- ============================================================================")
sql_lines.append("")
sql_lines.append("BEGIN;")
sql_lines.append("")

for v1_id, restaurant_data in area_results.items():
    name = restaurant_data['restaurant_name']
    v3_id = restaurant_data['v3_id']
    entries = restaurant_data['area_entries']
    
    if not entries:
        sql_lines.append(f"-- {name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
        sql_lines.append(f"-- No delivery areas found")
        sql_lines.append("")
        continue
    
    sql_lines.append(f"-- Restaurant: {name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
    sql_lines.append(f"-- {len(entries)} delivery zone(s)")
    
    for entry in entries:
        area_num = entry['area_number']
        area_name = entry['area_name']
        polygon = entry['polygon_wkt']
        coord_count = entry['coordinates_count']
        
        sql_lines.append(f"INSERT INTO menuca_v3.restaurant_delivery_areas")
        sql_lines.append(f"  (restaurant_id, area_number, area_name, geometry)")
        sql_lines.append(f"VALUES")
        sql_lines.append(f"  ({v3_id}, {area_num}, '{area_name}',")
        sql_lines.append(f"   ST_GeomFromText('{polygon}', 4326))")
        sql_lines.append(f"ON CONFLICT (restaurant_id, area_number)")
        sql_lines.append(f"DO UPDATE SET")
        sql_lines.append(f"  area_name = EXCLUDED.area_name,")
        sql_lines.append(f"  geometry = EXCLUDED.geometry;")
        sql_lines.append(f"-- {coord_count} coordinates")
    
    sql_lines.append("")

sql_lines.append("COMMIT;")
sql_lines.append("")
sql_lines.append("-- ============================================================================")
sql_lines.append("-- MIGRATION COMPLETE")
sql_lines.append("-- ============================================================================")

# Write SQL file
sql_content = '\n'.join(sql_lines)
with open('v1_10_migration.sql', 'w', encoding='utf-8') as f:
    f.write(sql_content)
print(f"Saved: v1_10_migration.sql ({len(sql_content)} bytes)")
print()

# =============================================================================
# STEP 6: Generate Report
# =============================================================================
print("[STEP 6] Generating extraction report...")

report_lines = []
report_lines.append("# V1 Delivery Areas Extraction Report")
report_lines.append("")
report_lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
report_lines.append("")
report_lines.append("## Summary")
report_lines.append("")
report_lines.append(f"| Metric | Value |")
report_lines.append(f"|--------|-------|")
report_lines.append(f"| Restaurants Processed | {len(extracted_blobs)} |")
report_lines.append(f"| Restaurants with Data | {len(area_results)} |")
report_lines.append(f"| Total Delivery Zones | {total_zones} |")
report_lines.append(f"| Errors | {len(errors)} |")
report_lines.append("")
report_lines.append("## Extracted Data")
report_lines.append("")
report_lines.append("| V1 ID | V3 ID | Restaurant | Zones | Coordinates |")
report_lines.append("|-------|-------|------------|-------|-------------|")

for v1_id, data in area_results.items():
    zones = len(data['area_entries'])
    total_coords = sum(e['coordinates_count'] for e in data['area_entries'])
    report_lines.append(f"| {data['v1_id']} | {data['v3_id']} | {data['restaurant_name']} | {zones} | {total_coords} |")

report_lines.append("")
report_lines.append("## Zone Details")
report_lines.append("")

for v1_id, data in area_results.items():
    if data['area_entries']:
        report_lines.append(f"### {data['restaurant_name']}")
        for entry in data['area_entries']:
            report_lines.append(f"- **Zone {entry['area_number']}**: {entry['coordinates_count']} points")
        report_lines.append("")

if errors:
    report_lines.append("## Errors")
    report_lines.append("")
    for error in errors:
        report_lines.append(f"- {error}")
    report_lines.append("")

report_lines.append("## Files Generated")
report_lines.append("")
report_lines.append("| File | Description |")
report_lines.append("|------|-------------|")
report_lines.append("| `v1_id_mappings.json` | V1 to V3 ID mappings |")
report_lines.append("| `v1_blob_deliveryArea.json` | Raw extracted BLOB data |")
report_lines.append("| `deserialized_areas.json` | Parsed polygon coordinates |")
report_lines.append("| `v1_10_migration.sql` | V3 INSERT statements |")
report_lines.append("")
report_lines.append("## Next Steps")
report_lines.append("")
report_lines.append("1. Review the extracted data in `deserialized_areas.json`")
report_lines.append("2. Execute `v1_10_migration.sql` against menuca_v3 database")
report_lines.append("3. Verify polygons render correctly on map")

report_content = '\n'.join(report_lines)
with open('EXTRACTION_REPORT.md', 'w', encoding='utf-8') as f:
    f.write(report_content)
print(f"Saved: EXTRACTION_REPORT.md")

print()
print("=" * 70)
print("EXTRACTION COMPLETE!")
print("=" * 70)
print()
print(f"Results:")
print(f"  - Restaurants: {len(area_results)}/10")
print(f"  - Delivery Zones: {total_zones}")
print(f"  - Errors: {len(errors)}")
print()
print("Output files:")
print("  - v1_blob_deliveryArea.json")
print("  - deserialized_areas.json")
print("  - v1_10_migration.sql")
print("  - EXTRACTION_REPORT.md")
print()

