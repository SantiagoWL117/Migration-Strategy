#!/usr/bin/env python3
"""
Debug column positions by examining parsed data
"""

import re

def parse_restaurant_record(record_str):
    """Parse a single restaurant record and extract columns"""
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

# Find Ginkgo Garden (ID 224)
print("\nSearching for Ginkgo Garden (ID 224)...")

# Find all INSERT INTO restaurants statements
insert_positions = []
pos = 0
while True:
    pos = content.find('INSERT INTO `restaurants` VALUES ', pos)
    if pos == -1:
        break
    insert_positions.append(pos)
    pos += 1

print(f"Found {len(insert_positions)} INSERT statements")

# Process each INSERT to find ID 224
for insert_pos in insert_positions:
    # Find the end of this INSERT
    end_pos = insert_pos
    in_string = False
    escape_next = False
    
    i = insert_pos + 34
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
    
    # Split into records
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
            
            if paren_depth == 0 and i + 1 < len(values_section) and values_section[i + 1] == ',':
                records.append(current_record)
                current_record = ""
                i += 2
                continue
        else:
            current_record += char
        
        i += 1
    
    if current_record:
        records.append(current_record)
    
    # Check for ID 224
    for record in records:
        columns = parse_restaurant_record(record)
        
        if len(columns) < 10:
            continue
        
        try:
            restaurant_id = int(columns[0])
        except (ValueError, IndexError):
            continue
        
        if restaurant_id == 224:
            print(f"\n[FOUND] Ginkgo Garden (ID 224)")
            print(f"Total columns: {len(columns)}\n")
            
            # Print specific columns we're interested in
            print("Key columns:")
            print(f"  Col 0 (ID): {columns[0]}")
            print(f"  Col 3 (name): {columns[3][:50]}")
            print(f"  Col 4 (address): {columns[4][:50]}")
            print(f"  Col 8 (delivery_schedule BLOB): {columns[8][:100]}...")
            print(f"  Col 16 (delivery_time): {columns[16]}")
            print(f"  Col 17 (takeout_time): {columns[17]}")
            print(f"  Col 20 (pickup): {columns[20]}")
            print(f"  Col 21 (delivery): {columns[21]}")
            print(f"  Col 22 (takeout): {columns[22]}")
            print(f"  Col 23 (fee BLOB): {columns[23][:100]}...")
            print(f"  Col 24 (min_order): {columns[24][:50]}")
            print(f"  Col 25 (active): {columns[25]}")
            print(f"  Col 30 (deliveryRadius): {columns[30]}")
            print(f"  Col 31 (multipleDeliveryArea): {columns[31]}")
            print(f"  Col 32 (deliveryArea BLOB): {columns[32][:100]}...")
            
            # Check if we have col 141 and 142
            if len(columns) > 141:
                print(f"  Col 141 (deliveryServiceExtra): {columns[141]}")
            if len(columns) > 142:
                print(f"  Col 142 (use_delivery_areas): {columns[142]}")
            
            exit(0)

print("\nID 224 not found!")








