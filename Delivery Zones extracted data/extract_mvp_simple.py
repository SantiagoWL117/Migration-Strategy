#!/usr/bin/env python3
"""
Simple extractor for MVP restaurants from SQL dump
"""

import re
import csv
import json

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

print("Loading SQL dump file...")
with open('Database/v1_structure/restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print(f"File loaded: {len(content)} characters")

# Find all INSERT INTO restaurants statements
insert_pattern = r'INSERT INTO `restaurants` VALUES \((.*?)\);'
inserts = list(re.finditer(insert_pattern, content, re.DOTALL))
print(f"Found {len(inserts)} INSERT INTO restaurants statements")

results = []
found_ids = []

# Process each INSERT statement
for insert_match in inserts:
    values_section = insert_match.group(1)
    
    # Split by ),( to get individual restaurant records
    # Be careful - there might be ),( inside strings/blobs
    # Use a simple split for now and refine if needed
    records = re.split(r'\),\s*\(', values_section)
    
    print(f"  Processing INSERT with ~{len(records)} records...")
    
    for record in records:
        # Extract the restaurant ID (first column)
        # Remove leading/trailing parentheses and whitespace first
        record = record.strip().lstrip('(').rstrip(')')
        id_match = re.match(r'^(\d+),', record)
        if not id_match:
            continue
        
        restaurant_id = int(id_match.group(1))
        
        if restaurant_id in mvp_v1_ids and restaurant_id not in found_ids:
            print(f"\n✓ Found MVP restaurant V1 ID: {restaurant_id} ({mapping[restaurant_id]['restaurant_name']})")
            found_ids.append(restaurant_id)
            
            # Save the raw record for now
            map_entry = mapping[restaurant_id]
            results.append({
                'v1_id': restaurant_id,
                'v3_id': map_entry['v3_id'],
                'restaurant_name': map_entry['restaurant_name'],
                'raw_data_length': len(record)
            })

print(f"\n\nFound {len(found_ids)} out of {len(mvp_v1_ids)} MVP restaurants")
print(f"Found IDs: {sorted(found_ids)}")
print(f"Missing IDs: {sorted(set(mvp_v1_ids) - set(found_ids))}")

# Save basic results
with open('extracted_data/phase1_mvp/found_restaurants.csv', 'w', newline='', encoding='utf-8') as f:
    if results:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
        print(f"\nSaved results to: extracted_data/phase1_mvp/found_restaurants.csv")

