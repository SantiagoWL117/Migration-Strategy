#!/usr/bin/env python3
"""
Parse restaurants_dump.sql for MVP restaurants
Extract 7 target columns for delivery & zones data
"""

import re
import csv
import json
import sys

# MVP Restaurant V1 IDs
mvp_v1_ids = [224, 387, 90, 203, 239]

# Load mapping
mapping = {}
with open('extracted_data/v1_v3_mapping.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v1_id = int(row['legacy_v1_id'])
        mapping[v1_id] = {
            'v3_id': row['v3_id'],
            'restaurant_name': row['restaurant_name']
        }

print("Starting MVP Restaurant Delivery Data Extraction...")
print("\nTarget MVP Restaurants:")
for v1_id in mvp_v1_ids:
    if v1_id in mapping:
        print(f"  V3 ID: {mapping[v1_id]['v3_id']} | V1 ID: {v1_id} | {mapping[v1_id]['restaurant_name']}")

# Results storage
results = []
blob_data = {
    'deliveryArea': [],
    'delivery_schedule': [],
    'fee': []
}

found_count = 0
line_count = 0

print(f"\nParsing dump file: Database/v1_structure/restaurants_dump.sql")
print("This may take a few minutes...")

# Read the dump file
with open('Database/v1_structure/restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    in_restaurants_insert = False
    buffer = ""
    
    for line in f:
        line_count += 1
        
        if line_count % 10000 == 0:
            print(f"  Processed {line_count} lines, found {found_count}/{len(mvp_v1_ids)} MVP restaurants...")
        
        # Check if we're in a restaurants INSERT statement
        if "INSERT INTO `restaurants` VALUES" in line:
            in_restaurants_insert = True
            buffer = line
            continue
        
        if in_restaurants_insert:
            buffer += line
            
            # Check if the INSERT statement is complete
            if line.strip().endswith(');'):
                # Parse the INSERT statement
                # Find all restaurant records in this INSERT
                # Match pattern: ),(ID,
                matches = list(re.finditer(r'\((\d+),', buffer))
                
                for match in matches:
                    restaurant_id = int(match.group(1))
                    
                    if restaurant_id in mvp_v1_ids:
                        print(f"\nFound MVP restaurant V1 ID: {restaurant_id}")
                        
                        # Find the start and end of this restaurant's data
                        start_pos = match.start()
                        
                        # Find the next restaurant or end of VALUES
                        next_match = re.search(r'\),\s*\(', buffer[start_pos+10:])
                        if next_match:
                            end_pos = start_pos + 10 + next_match.start() + 1
                        else:
                            # This is the last restaurant
                            end_pos = buffer.rfind(');')
                        
                        restaurant_data = buffer[start_pos:end_pos]
                        
                        # Extract specific columns using regex
                        # This is a simplified extraction - we'll use a basic column counter
                        # Split by comma, but be careful with embedded commas in strings
                        
                        # For now, let's use a simpler approach: search for specific patterns
                        # Extract min_order (column 25) - it's a varchar before 'N' or 'Y' active flag
                        min_order_match = re.search(r",'(\d+)'(?=,'[YN]','[yn]')", restaurant_data)
                        min_order = min_order_match.group(1) if min_order_match else "NULL"
                        
                        # Extract delivery_time (column 17) - int before takeout_time
                        delivery_time_match = re.search(r',(\d+),(?:\d+|NULL),NULL,', restaurant_data)
                        delivery_time = delivery_time_match.group(1) if delivery_time_match else "NULL"
                        
                        # Extract multipleDeliveryArea (column 32) - enum 'Y' or 'N'
                        multiple_area_match = re.search(r",'([YN])',_binary", restaurant_data)
                        multipleDeliveryArea = multiple_area_match.group(1) if multiple_area_match else "NULL"
                        
                        # Extract BLOBs - they appear as _binary 'content'
                        blob_matches = list(re.finditer(r"_binary '(.*?)'(?=,|$)", restaurant_data, re.DOTALL))
                        
                        # Typically: deliveryArea (column 33), delivery_schedule (column 9), fee (column 24)
                        # We need to identify which BLOB is which based on position
                        
                        delivery_schedule_blob = blob_matches[0].group(1) if len(blob_matches) > 0 else ""
                        fee_blob = blob_matches[1].group(1) if len(blob_matches) > 1 else ""
                        deliveryArea_blob = blob_matches[2].group(1) if len(blob_matches) > 2 else ""
                        
                        # Get mapping info
                        map_entry = mapping.get(restaurant_id, {})
                        v3_id = map_entry.get('v3_id', 'unknown')
                        restaurant_name = map_entry.get('restaurant_name', 'unknown')
                        
                        # Store non-BLOB data
                        results.append({
                            'v1_id': restaurant_id,
                            'v3_id': v3_id,
                            'restaurant_name': restaurant_name,
                            'min_order': min_order,
                            'delivery_time': delivery_time,
                            'multipleDeliveryArea': multipleDeliveryArea,
                            'use_delivery_areas': 'TODO',  # Need to extract
                            'deliveryArea_blob': f"Length: {len(deliveryArea_blob)} chars",
                            'delivery_schedule_blob': f"Length: {len(delivery_schedule_blob)} chars",
                            'fee_blob': f"Length: {len(fee_blob)} chars"
                        })
                        
                        # Store BLOB data
                        blob_data['deliveryArea'].append({
                            'v1_id': restaurant_id,
                            'v3_id': v3_id,
                            'restaurant_name': restaurant_name,
                            'blob_data': deliveryArea_blob,
                            'target_table': 'menuca_v3.restaurant_delivery_areas',
                            'target_columns': ['restaurant_id', 'area_geometry', 'coordinates']
                        })
                        
                        blob_data['delivery_schedule'].append({
                            'v1_id': restaurant_id,
                            'v3_id': v3_id,
                            'restaurant_name': restaurant_name,
                            'blob_data': delivery_schedule_blob,
                            'target_table': 'menuca_v3.restaurant_schedules',
                            'target_columns': ['restaurant_id', 'type', 'day_start', 'time_start', 'time_stop']
                        })
                        
                        blob_data['fee'].append({
                            'v1_id': restaurant_id,
                            'v3_id': v3_id,
                            'restaurant_name': restaurant_name,
                            'blob_data': fee_blob,
                            'target_table': 'menuca_v3.restaurant_delivery_fees',
                            'target_columns': ['restaurant_id', 'fee_type', 'tier_value', 'total_delivery_fee']
                        })
                        
                        found_count += 1
                        
                        if found_count == len(mvp_v1_ids):
                            print("\nAll MVP restaurants found! Stopping parse.")
                            break
                
                in_restaurants_insert = False
                buffer = ""
                
                if found_count == len(mvp_v1_ids):
                    break

print(f"\n\nParsing complete!")
print(f"Found {found_count} out of {len(mvp_v1_ids)} MVP restaurants")

# Export results
csv_path = 'extracted_data/phase1_mvp/mvp_extracted_data.csv'
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    if results:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
print(f"\nExported non-BLOB data to: {csv_path}")

# Export BLOB data as JSON
with open('extracted_data/phase1_mvp/mvp_blob_deliveryArea.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data['deliveryArea'], f, indent=2, ensure_ascii=False)

with open('extracted_data/phase1_mvp/mvp_blob_delivery_schedule.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data['delivery_schedule'], f, indent=2, ensure_ascii=False)

with open('extracted_data/phase1_mvp/mvp_blob_fee.json', 'w', encoding='utf-8') as f:
    json.dump(blob_data['fee'], f, indent=2, ensure_ascii=False)

print("Exported BLOB data to JSON files")
print("\nExtraction Summary:")
print(f"  - CSV: {csv_path}")
print(f"  - BLOB (deliveryArea): extracted_data/phase1_mvp/mvp_blob_deliveryArea.json")
print(f"  - BLOB (delivery_schedule): extracted_data/phase1_mvp/mvp_blob_delivery_schedule.json")
print(f"  - BLOB (fee): extracted_data/phase1_mvp/mvp_blob_fee.json")
print("\nDone!")

