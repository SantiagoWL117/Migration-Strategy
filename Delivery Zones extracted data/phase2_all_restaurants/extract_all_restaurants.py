#!/usr/bin/env python3
"""
Extract V1 delivery data for ALL 164 active restaurants
Phase 2: Full migration
"""

import re
import csv
import json
import os

# Read V1 to V3 mapping
v1_v3_mapping = {}
with open('../v1_v3_mapping.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['legacy_v1_id']:  # Skip rows without V1 ID
            v1_v3_mapping[row['legacy_v1_id']] = {
                'v3_id': row['v3_id'],
                'restaurant_name': row['restaurant_name']
            }

print(f"Loaded {len(v1_v3_mapping)} V1-V3 restaurant mappings")
print(f"V1 IDs to extract: {sorted([int(v1_id) for v1_id in v1_v3_mapping.keys()])[:10]}... (showing first 10)")

# Read the dump file
dump_file = '../../Database/v1_structure/restaurants_dump.sql'
print(f"\nReading dump file: {dump_file}")

with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
    dump_content = f.read()

print(f"Dump file size: {len(dump_content)} bytes")

# Find all INSERT statements
insert_pattern = re.compile(r"INSERT INTO `restaurants` VALUES \((.*?)\);", re.DOTALL)
inserts = list(insert_pattern.finditer(dump_content))

print(f"Found {len(inserts)} INSERT statements")

# Storage for extracted data
extracted_data = []
blob_data_schedule = []
blob_data_area = []
blob_data_fee = []

restaurants_found = 0
restaurants_not_found = []

# Process each INSERT statement
for insert_match in inserts:
    values_section = insert_match.group(1)
    
    # Split by '),(' to get individual records
    records = re.split(r'\),\s*\(', values_section)
    
    for record in records:
        # Extract restaurant ID (first column)
        id_match = re.match(r'^(\d+),', record)
        if not id_match:
            continue
        
        restaurant_id = id_match.group(1)
        
        # Check if this is one of our target restaurants
        if restaurant_id not in v1_v3_mapping:
            continue
        
        restaurants_found += 1
        v3_id = v1_v3_mapping[restaurant_id]['v3_id']
        restaurant_name = v1_v3_mapping[restaurant_id]['restaurant_name']
        
        # Split record into columns
        # Need to carefully parse to handle quoted strings and BLOB data
        columns = []
        current_col = ""
        in_quotes = False
        in_binary = False
        i = 0
        
        while i < len(record):
            char = record[i]
            
            # Check for _binary prefix
            if record[i:i+8] == '_binary ' and not in_quotes:
                in_binary = True
                current_col += record[i:i+8]
                i += 8
                continue
            
            if char == "'" and (i == 0 or record[i-1] != '\\'):
                in_quotes = not in_quotes
                current_col += char
            elif char == ',' and not in_quotes:
                columns.append(current_col.strip())
                current_col = ""
                in_binary = False
            else:
                current_col += char
            
            i += 1
        
        # Add last column
        if current_col:
            columns.append(current_col.strip())
        
        # Extract specific columns (0-indexed positions from V1_DELIVERY_ZONES_COLUMN_MAPPING.md)
        # Col 0: id
        # Col 2: delivery (delivery_enabled)
        # Col 8: delivery_schedule (BLOB)
        # Col 16: delivery_time
        # Col 23: fee (BLOB)
        # Col 24: min_order
        # Col 31: multipleDeliveryArea
        # Col 32: deliveryArea (BLOB)
        # Col 142: use_delivery_areas
        
        try:
            delivery_enabled = columns[2] if len(columns) > 2 else 'NULL'
            delivery_schedule_blob = columns[8] if len(columns) > 8 else 'NULL'
            delivery_time = columns[16] if len(columns) > 16 else 'NULL'
            fee_blob = columns[23] if len(columns) > 23 else 'NULL'
            min_order = columns[24] if len(columns) > 24 else 'NULL'
            multiple_delivery_area = columns[31] if len(columns) > 31 else 'NULL'
            delivery_area_blob = columns[32] if len(columns) > 32 else 'NULL'
            use_delivery_areas = columns[142] if len(columns) > 142 else 'NULL'
            
            # Clean up values
            delivery_enabled = delivery_enabled.strip("'")
            min_order = min_order.strip("'")
            delivery_time = delivery_time.strip("'")
            multiple_delivery_area = multiple_delivery_area.strip("'")
            use_delivery_areas = use_delivery_areas.strip("'")
            
            # Store non-BLOB data
            extracted_data.append({
                'v1_id': restaurant_id,
                'v3_id': v3_id,
                'restaurant_name': restaurant_name,
                'delivery_enabled': delivery_enabled,
                'min_order': min_order,
                'delivery_time': delivery_time,
                'multipleDeliveryArea': multiple_delivery_area,
                'use_delivery_areas': use_delivery_areas,
                'deliveryArea_blob_length': len(delivery_area_blob) if delivery_area_blob != 'NULL' else 0,
                'delivery_schedule_blob_length': len(delivery_schedule_blob) if delivery_schedule_blob != 'NULL' else 0,
                'fee_blob_length': len(fee_blob) if fee_blob != 'NULL' else 0
            })
            
            # Store BLOB data (raw)
            if delivery_schedule_blob != 'NULL':
                blob_data_schedule.append({
                    'v1_id': restaurant_id,
                    'v3_id': v3_id,
                    'restaurant_name': restaurant_name,
                    'blob_data': delivery_schedule_blob,
                    'target_table': 'restaurant_schedules',
                    'target_columns': ['restaurant_id', 'type', 'day_start', 'day_stop', 'time_start', 'time_stop']
                })
            
            if delivery_area_blob != 'NULL':
                blob_data_area.append({
                    'v1_id': restaurant_id,
                    'v3_id': v3_id,
                    'restaurant_name': restaurant_name,
                    'blob_data': delivery_area_blob,
                    'target_table': 'restaurant_delivery_areas',
                    'target_columns': ['restaurant_id', 'area_number', 'area_name', 'geometry']
                })
            
            if fee_blob != 'NULL':
                blob_data_fee.append({
                    'v1_id': restaurant_id,
                    'v3_id': v3_id,
                    'restaurant_name': restaurant_name,
                    'blob_data': fee_blob,
                    'target_table': 'restaurant_delivery_fees',
                    'target_columns': ['restaurant_id', 'fee_type', 'tier_value', 'total_delivery_fee']
                })
            
            if restaurants_found % 10 == 0:
                print(f"Processed {restaurants_found} restaurants...")
        
        except Exception as e:
            print(f"ERROR processing restaurant {restaurant_id}: {e}")
            restaurants_not_found.append({
                'v1_id': restaurant_id,
                'v3_id': v3_id,
                'restaurant_name': restaurant_name,
                'error': str(e)
            })

print(f"\n=== Extraction Complete ===")
print(f"Restaurants found in dump: {restaurants_found}/{len(v1_v3_mapping)}")
print(f"Restaurants with errors: {len(restaurants_not_found)}")

# Save non-BLOB data to CSV
csv_file = 'all_restaurants_extracted_data.csv'
with open(csv_file, 'w', encoding='utf-8', newline='') as f:
    if extracted_data:
        writer = csv.DictWriter(f, fieldnames=extracted_data[0].keys())
        writer.writeheader()
        writer.writerows(extracted_data)
        print(f"\nSaved non-BLOB data to: {csv_file}")

# Save BLOB data to JSON
with open('all_restaurants_blob_delivery_schedule.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data_schedule, f, indent=2)
    print(f"Saved schedule BLOB data to: all_restaurants_blob_delivery_schedule.json")

with open('all_restaurants_blob_deliveryArea.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data_area, f, indent=2)
    print(f"Saved area BLOB data to: all_restaurants_blob_deliveryArea.json")

with open('all_restaurants_blob_fee.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data_fee, f, indent=2)
    print(f"Saved fee BLOB data to: all_restaurants_blob_fee.json")

# Save error log if any
if restaurants_not_found:
    with open('extraction_errors.json', 'w', encoding='utf-8') as f:
        json.dump(restaurants_not_found, f, indent=2)
        print(f"\nSaved error log to: extraction_errors.json")

print("\n=== Summary ===")
print(f"Total restaurants to extract: {len(v1_v3_mapping)}")
print(f"Successfully extracted: {restaurants_found}")
print(f"With schedule data: {len(blob_data_schedule)}")
print(f"With area data: {len(blob_data_area)}")
print(f"With fee data: {len(blob_data_fee)}")
print(f"Errors: {len(restaurants_not_found)}")
