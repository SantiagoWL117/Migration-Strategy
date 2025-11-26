#!/usr/bin/env python3
"""
Extract MVP restaurant data by searching for IDs directly
"""

import csv
import json
import re

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

def is_fee_structure(content):
    # Simple heuristic: fee structures are usually short serialized arrays with numeric data
    return len(content) < 500 and 's:' in content and ('i:' in content or 'd:' in content)

print("Loading SQL dump file...")
with open('Database/v1_structure/restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print(f"File loaded: {len(content):,} characters\n")

results = []
blob_data = {
    'deliveryArea': [],
    'delivery_schedule': [],
    'fee': []
}

for v1_id in mvp_v1_ids:
    print(f"Searching for V1 ID {v1_id} ({mapping[v1_id]['restaurant_name']})...")
    
    # Search for pattern ),(ID, or VALUES (ID,
    pattern = rf'[,\(]{v1_id},\d+,'
    match = re.search(pattern, content)
    
    if not match:
        print(f"  [NOT FOUND]")
        continue
    
    print(f"  [FOUND] at position {match.start():,}")
    
    # Find the start of this record (search backwards for ),( or VALUES ()
    start_pos = match.start()
    for i in range(start_pos, max(0, start_pos - 1000), -1):
        if content[i-7:i] == 'VALUES ' or content[i-2:i] == '),(':
            start_pos = i
            break
    
    # Find the end of this record (search forward for ),(  or );)
    end_pos = match.end()
    depth = 0
    in_string = False
    escape_next = False
    
    for i in range(end_pos, min(len(content), end_pos + 500000)):
        char = content[i]
        
        if escape_next:
            escape_next = False
            continue
        
        if char == '\\':
            escape_next = True
            continue
        
        if char == "'" and not in_string:
            in_string = True
        elif char == "'" and in_string:
            in_string = False
        
        if not in_string:
            # Look for ),( pattern (next record) or ); (end of INSERT)
            if content[i:i+2] == '),(':
                end_pos = i
                break
            elif content[i:i+2] == ');':
                end_pos = i
                break
    
    record = content[start_pos:end_pos]
    print(f"  Record length: {len(record):,} characters")
    
    # Extract all _binary fields (BLOBs)
    blob_matches = list(re.finditer(r"_binary '(.*?)'(?=,|$|\))", record, re.DOTALL))
    print(f"  Found {len(blob_matches)} BLOB fields")
    
    # Store basic info
    map_entry = mapping[v1_id]
    results.append({
        'v1_id': v1_id,
        'v3_id': map_entry['v3_id'],
        'restaurant_name': map_entry['restaurant_name'],
        'record_length': len(record),
        'num_blobs': len(blob_matches)
    })
    
    # Save BLOB data (we'll identify which is which by content patterns)
    for idx, blob_match in enumerate(blob_matches):
        blob_content = blob_match.group(1)
        
        # Try to identify the BLOB type
        if 'delivery_schedule' in blob_content or '"start"' in blob_content or '"stop"' in blob_content:
            blob_type = 'delivery_schedule'
        elif 'deliveryArea' in blob_content or '"lat"' in blob_content or '"lng"' in blob_content:
            blob_type = 'deliveryArea'
        elif len(blob_content) < 500 and ('fee' in blob_content.lower() or is_fee_structure(blob_content)):
            blob_type = 'fee'
        else:
            blob_type = f'unknown_{idx}'
        
        if blob_type in blob_data:
            blob_data[blob_type].append({
                'v1_id': v1_id,
                'v3_id': map_entry['v3_id'],
                'restaurant_name': map_entry['restaurant_name'],
                'blob_data': blob_content,
                'blob_length': len(blob_content)
            })
    
    print()

print(f"Extraction complete!")
print(f"Found {len(results)} out of {len(mvp_v1_ids)} MVP restaurants\n")

# Save results
csv_path = 'extracted_data/phase1_mvp/mvp_found_records.csv'
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    if results:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
print(f"Saved summary to: {csv_path}")

# Save BLOB data
for blob_type, blobs in blob_data.items():
    if blobs:
        json_path = f'extracted_data/phase1_mvp/mvp_blob_{blob_type}.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(blobs, f, indent=2, ensure_ascii=False)
        print(f"Saved {blob_type} BLOBs to: {json_path}")

print("\nDone!")

