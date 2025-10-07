"""
Clean menuca_v2_restaurants_delivery_areas.csv to remove geometry BLOB column
"""
import re
import os

# Change to script directory
script_dir = os.path.dirname(os.path.abspath(__file__))
base_dir = os.path.dirname(script_dir)
os.chdir(base_dir)

print(f"Working directory: {os.getcwd()}")

# Read the SQL dump
dump_path = 'dumps/menuca_v2_restaurants_delivery_areas.sql'
print(f"Reading {dump_path}...")

with open(dump_path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find INSERT statement
insert_match = re.search(r'INSERT INTO `restaurants_delivery_areas` VALUES (.+?);', content, re.DOTALL)
if not insert_match:
    print('ERROR: No INSERT statement found')
    exit(1)

values_text = insert_match.group(1)
print(f"Found INSERT statement")

# Parse individual rows by splitting on ),(
# But we need to be careful with nested parentheses in BLOB data
rows = []
current_row = ""
depth = 0
i = 0

while i < len(values_text):
    char = values_text[i]
    
    if char == '(':
        depth += 1
        if depth == 1:
            current_row = ""
        else:
            current_row += char
    elif char == ')':
        depth -= 1
        if depth == 0:
            if current_row:
                rows.append(current_row)
        else:
            current_row += char
    else:
        if depth > 0:
            current_row += char
    
    i += 1

print(f"Parsed {len(rows)} rows")

# Now parse each row to extract only first 8 columns (exclude geometry)
parsed_rows = []

for row_text in rows:
    # Split by commas, but respect quotes
    parts = []
    current = ""
    in_quotes = False
    skip_blob = False
    
    i = 0
    while i < len(row_text):
        # Check for _binary marker
        if row_text[i:i+7] == '_binary':
            skip_blob = True
            break
        
        char = row_text[i]
        
        if char == "'" and (i == 0 or row_text[i-1] != '\\'):
            in_quotes = not in_quotes
            current += char
        elif char == ',' and not in_quotes:
            parts.append(current)
            current = ""
        else:
            current += char
        
        i += 1
    
    # Add last part if not skipping
    if current and not skip_blob:
        parts.append(current)
    
    # Take only first 8 columns
    if len(parts) >= 8:
        parsed_rows.append(parts[:8])
    else:
        print(f"WARNING: Row has only {len(parts)} columns: {row_text[:100]}")

print(f"Successfully parsed {len(parsed_rows)} rows with 8 columns each")

# Write clean CSV
csv_path = 'CSV/menuca_v2_restaurants_delivery_areas.csv'
print(f"Writing to {csv_path}...")

with open(csv_path, 'w', encoding='utf-8', newline='') as f:
    # Header (8 columns - no geometry)
    f.write('id,restaurant_id,area_number,area_name,delivery_fee,min_order_value,is_complex,coords\n')
    
    for row in parsed_rows:
        cleaned = []
        for val in row:
            val = val.strip()
            
            # Handle NULL
            if val == 'NULL' or val == '':
                cleaned.append('')
            # Handle quoted strings
            elif val.startswith("'") and val.endswith("'"):
                # Remove SQL quotes
                val = val[1:-1]
                # Unescape doubled quotes
                val = val.replace("''", "'")
                # CSV-quote if contains comma, quote, or newline
                if ',' in val or '"' in val or '\n' in val:
                    val = '"' + val.replace('"', '""') + '"'
                cleaned.append(val)
            else:
                # Numeric or other
                cleaned.append(val)
        
        f.write(','.join(cleaned) + '\n')

print(f"✅ Successfully wrote {len(parsed_rows)} rows to CSV")
print(f"   Columns: id, restaurant_id, area_number, area_name, delivery_fee, min_order_value, is_complex, coords")
print(f"   geometry BLOB column excluded")

