#!/usr/bin/env python3
"""
Extract MVP restaurant data using proper MySQL dump parsing
This uses a character-by-character state machine to properly handle the SQL syntax
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
    """Check if BLOB content looks like a fee structure"""
    return len(content) < 1000 and 's:' in content and 'i:' in content and content.count('i:') < 20

def parse_restaurant_record(record_str):
    """
    Parse a single restaurant record and extract columns by position
    This is a simplified column counter that splits by comma while respecting quoted strings
    """
    columns = []
    current = ""
    in_string = False
    escape_next = False
    paren_depth = 0
    
    # Remove leading ( and trailing )
    record_str = record_str.strip()
    if record_str.startswith('('):
        record_str = record_str[1:]
    if record_str.endswith(')'):
        record_str = record_str[:-1]
    
    i = 0
    while i < len(record_str):
        char = record_str[i]
        
        if escape_next:
            current += char
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            current += char
            i += 1
            continue
        
        if char == "'" and not in_string:
            in_string = True
            current += char
        elif char == "'" and in_string:
            in_string = False
            current += char
        elif char == '(' and not in_string:
            paren_depth += 1
            current += char
        elif char == ')' and not in_string:
            paren_depth -= 1
            current += char
        elif char == ',' and not in_string and paren_depth == 0:
            columns.append(current.strip())
            current = ""
        else:
            current += char
        
        i += 1
    
    # Add the last column
    if current:
        columns.append(current.strip())
    
    return columns

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

# Find all INSERT INTO restaurants statements
print("Finding INSERT INTO restaurants statements...")
insert_positions = []
pos = 0
while True:
    pos = content.find('INSERT INTO `restaurants` VALUES ', pos)
    if pos == -1:
        break
    insert_positions.append(pos)
    pos += 1

print(f"Found {len(insert_positions)} INSERT statements\n")

# Process each INSERT statement
for insert_idx, insert_pos in enumerate(insert_positions):
    # Find the end of this INSERT (the terminating ;)
    # We need to be careful as ; can appear in strings
    end_pos = insert_pos
    in_string = False
    escape_next = False
    
    i = insert_pos + 34  # Skip "INSERT INTO `restaurants` VALUES "
    while i < len(content):
        char = content[i]
        
        if escape_next:
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            i += 1
            continue
        
        if char == "'" and not in_string:
            in_string = True
        elif char == "'" and in_string:
            in_string = False
        elif char == ';' and not in_string:
            end_pos = i
            break
        
        i += 1
    
    insert_statement = content[insert_pos:end_pos]
    
    # Extract the VALUES section
    values_match = re.search(r'VALUES\s+(.+)$', insert_statement, re.DOTALL)
    if not values_match:
        continue
    
    values_section = values_match.group(1)
    
    # Split into individual records by ),(
    # This is tricky because ),( can appear in strings
    records = []
    current_record = ""
    in_string = False
    escape_next = False
    paren_depth = 0
    
    i = 0
    while i < len(values_section):
        char = values_section[i]
        
        if escape_next:
            current_record += char
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            current_record += char
            i += 1
            continue
        
        if char == "'" and not in_string:
            in_string = True
            current_record += char
        elif char == "'" and in_string:
            in_string = False
            current_record += char
        elif char == '(' and not in_string:
            paren_depth += 1
            current_record += char
        elif char == ')' and not in_string:
            paren_depth -= 1
            current_record += char
            
            # Check if this is a record boundary ),
            if paren_depth == 0 and i + 1 < len(values_section) and values_section[i + 1] == ',':
                records.append(current_record)
                current_record = ""
                i += 2  # Skip ),
                continue
        else:
            current_record += char
        
        i += 1
    
    # Add the last record
    if current_record:
        records.append(current_record)
    
    # Check each record for MVP restaurant IDs
    for record in records:
        columns = parse_restaurant_record(record)
        
        if len(columns) < 10:
            continue
        
        # Column 0 is the restaurant ID
        try:
            restaurant_id = int(columns[0])
        except (ValueError, IndexError):
            continue
        
        if restaurant_id not in mvp_v1_ids:
            continue
        
        print(f"[FOUND] V1 ID {restaurant_id} ({mapping[restaurant_id]['restaurant_name']})")
        print(f"  Record has {len(columns)} columns")
        
        # Extract target columns (0-indexed)
        # Column 8: delivery_schedule (BLOB)
        # Column 16: delivery_time (int)
        # Column 21: delivery (enum '1'/'0')
        # Column 23: fee (BLOB)  
        # Column 24: min_order (varchar)
        # Column 31: multipleDeliveryArea (enum 'Y'/'N')
        # Column 32: deliveryArea (BLOB)
        # Column 142: use_delivery_areas (enum 'y'/'n')
        
        delivery_enabled = columns[21] if len(columns) > 21 else "NULL"
        min_order = columns[24] if len(columns) > 24 else "NULL"
        delivery_time = columns[16] if len(columns) > 16 else "NULL"
        multipleDeliveryArea = columns[31] if len(columns) > 31 else "NULL"
        use_delivery_areas = columns[142] if len(columns) > 142 else "NULL"
        
        delivery_schedule_blob = columns[8] if len(columns) > 8 else ""
        fee_blob = columns[23] if len(columns) > 23 else ""
        deliveryArea_blob = columns[32] if len(columns) > 32 else ""
        
        # Extract BLOB content (remove _binary ' prefix and ' suffix)
        def extract_blob(col):
            if col.startswith("_binary '") and col.endswith("'"):
                return col[9:-1]
            elif col.startswith("'") and col.endswith("'"):
                return col[1:-1]
            return col
        
        delivery_schedule_blob = extract_blob(delivery_schedule_blob)
        fee_blob = extract_blob(fee_blob)
        deliveryArea_blob = extract_blob(deliveryArea_blob)
        
        print(f"  delivery_enabled: {delivery_enabled}")
        print(f"  min_order: {min_order}")
        print(f"  delivery_time: {delivery_time} minutes")
        print(f"  multipleDeliveryArea: {multipleDeliveryArea}")
        print(f"  use_delivery_areas: {use_delivery_areas}")
        print(f"  delivery_schedule BLOB: {len(delivery_schedule_blob)} chars")
        print(f"  fee BLOB: {len(fee_blob)} chars")
        print(f"  deliveryArea BLOB: {len(deliveryArea_blob)} chars")
        print()
        
        map_entry = mapping[restaurant_id]
        
        # Clean up the values (remove quotes)
        def clean_value(val):
            if isinstance(val, str) and val.startswith("'") and val.endswith("'"):
                return val[1:-1]
            return val
        
        # Store non-BLOB data
        results.append({
            'v1_id': restaurant_id,
            'v3_id': map_entry['v3_id'],
            'restaurant_name': map_entry['restaurant_name'],
            'delivery_enabled': clean_value(delivery_enabled),
            'min_order': clean_value(min_order),
            'delivery_time': clean_value(delivery_time),
            'multipleDeliveryArea': clean_value(multipleDeliveryArea),
            'use_delivery_areas': clean_value(use_delivery_areas),
            'deliveryArea_blob_length': len(deliveryArea_blob),
            'delivery_schedule_blob_length': len(delivery_schedule_blob),
            'fee_blob_length': len(fee_blob)
        })
        
        # Store BLOB data
        blob_data['deliveryArea'].append({
            'v1_id': restaurant_id,
            'v3_id': map_entry['v3_id'],
            'restaurant_name': map_entry['restaurant_name'],
            'blob_data': deliveryArea_blob,
            'target_table': 'menuca_v3.restaurant_delivery_areas',
            'target_columns': ['restaurant_id', 'area_geometry', 'coordinates']
        })
        
        blob_data['delivery_schedule'].append({
            'v1_id': restaurant_id,
            'v3_id': map_entry['v3_id'],
            'restaurant_name': map_entry['restaurant_name'],
            'blob_data': delivery_schedule_blob,
            'target_table': 'menuca_v3.restaurant_schedules',
            'target_columns': ['restaurant_id', 'type', 'day_start', 'time_start', 'time_stop']
        })
        
        blob_data['fee'].append({
            'v1_id': restaurant_id,
            'v3_id': map_entry['v3_id'],
            'restaurant_name': map_entry['restaurant_name'],
            'blob_data': fee_blob,
            'target_table': 'menuca_v3.restaurant_delivery_fees',
            'target_columns': ['restaurant_id', 'fee_type', 'tier_value', 'total_delivery_fee']
        })

print(f"\n{'='*60}")
print(f"Extraction complete!")
print(f"Found {len(results)} out of {len(mvp_v1_ids)} MVP restaurants")
print(f"{'='*60}\n")

# Save results
csv_path = 'extracted_data/phase1_mvp/mvp_extracted_data.csv'
with open(csv_path, 'w', newline='', encoding='utf-8') as f:
    if results:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
print(f"Saved non-BLOB data to: {csv_path}")

# Save BLOB data
for blob_type, blobs in blob_data.items():
    if blobs:
        json_path = f'extracted_data/phase1_mvp/mvp_blob_{blob_type}.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(blobs, f, indent=2, ensure_ascii=False)
        print(f"Saved {blob_type} BLOBs to: {json_path}")

print("\nDone!")

