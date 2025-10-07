#!/usr/bin/env python3
"""
Extract delivery-related flags from V1 restaurants table dump
Excludes deliveryArea BLOB column per user decision
"""

import re
import csv
from pathlib import Path

script_dir = Path(__file__).parent
dump_file = script_dir / "dumps" / "menuca_v1_restaurants.sql"
csv_file = script_dir / "CSV" / "menuca_v1_restaurants_delivery_flags.csv"

print("Extracting V1 restaurants delivery flags...")
print()

# Define the delivery-related columns we want to extract (in order)
delivery_columns = [
    'id',
    'deliveryRadius',
    'multipleDeliveryArea',
    'sendToDelivery',
    'sendToDailyDelivery',
    'sendToGeodispatch',
    'geodispatch_username',
    'geodispatch_password',
    'geodispatch_api_key',
    'sendToDelivery_email',
    'restaurant_delivery_charge',
    'tookan_delivery',
    'tookan_tags',
    'tookan_restaurant_email',
    'tookan_delivery_as_pickup',
    'weDeliver',
    'weDeliver_driver_notes',
    'weDeliverEmail',
    'deliveryServiceExtra',
    'use_delivery_areas',
    'delivery_restaurant_id',
    'max_delivery_distance',
    'disable_delivery_until',
    'twilio_call'
]

print(f"Reading dump file: {dump_file.name}")

# Read the dump file
with open(dump_file, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find the CREATE TABLE statement to determine column positions
create_match = re.search(r'CREATE TABLE `restaurants`\s*\((.*?)\)\s*ENGINE', content, re.DOTALL)
if not create_match:
    print("ERROR: Could not find CREATE TABLE statement!")
    exit(1)

# Parse column definitions
column_defs = create_match.group(1)
all_columns = []
for line in column_defs.split('\n'):
    match = re.match(r'\s*`([a-zA-Z_][a-zA-Z0-9_]*)`', line)
    if match:
        all_columns.append(match.group(1))

print(f"Found {len(all_columns)} total columns in restaurants table")

# Find the index positions of delivery columns
column_indexes = {}
for col in delivery_columns:
    if col in all_columns:
        column_indexes[col] = all_columns.index(col)

# Find all INSERT statements by splitting on INSERT INTO
insert_blocks = content.split('INSERT INTO `restaurants` VALUES ')
insert_blocks = insert_blocks[1:]  # Skip the first block (before any INSERT)

print(f"Found {len(insert_blocks)} INSERT statement(s)")

def parse_row_tuples(values_str):
    """Parse SQL INSERT VALUES into individual row tuples"""
    # Remove trailing semicolon if present
    values_str = values_str.rstrip().rstrip(';')
    
    rows = []
    current_row = []
    current_value = ""
    in_string = False
    escape_next = False
    paren_depth = 0
    
    i = 0
    while i < len(values_str):
        char = values_str[i]
        
        if escape_next:
            current_value += char
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            current_value += char
            i += 1
            continue
        
        if char == "'" and not escape_next:
            in_string = not in_string
            current_value += char
            i += 1
            continue
        
        # Check for _binary prefix (skip BLOB data)
        if not in_string and values_str[i:i+7] == '_binary':
            # Skip until we find the closing quote of the BLOB
            current_value += '_binary'
            i += 7
            # Skip whitespace
            while i < len(values_str) and values_str[i] in ' \t\n':
                i += 1
            # Skip the BLOB string
            if i < len(values_str) and values_str[i] == "'":
                current_value += "'"
                i += 1
                blob_escape = False
                while i < len(values_str):
                    if blob_escape:
                        current_value += values_str[i]
                        blob_escape = False
                        i += 1
                        continue
                    if values_str[i] == '\\':
                        blob_escape = True
                        current_value += values_str[i]
                        i += 1
                        continue
                    current_value += values_str[i]
                    if values_str[i] == "'":
                        i += 1
                        break
                    i += 1
            continue
        
        if not in_string:
            if char == '(':
                paren_depth += 1
                if paren_depth == 1:
                    # Start of a new row tuple
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    # End of row tuple
                    if current_value.strip():
                        current_row.append(current_value.strip())
                    if current_row:
                        rows.append(current_row)
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ',' and paren_depth == 1:
                # End of a value within the row
                current_row.append(current_value.strip())
                current_value = ""
                i += 1
                continue
        
        current_value += char
        i += 1
    
    return rows

def clean_value(value):
    """Clean a SQL value for CSV output"""
    value = value.strip()
    
    if value == 'NULL' or value == '':
        return ''
    
    # Skip _binary BLOB values
    if value.startswith('_binary'):
        return '[BLOB]'
    
    # Remove surrounding quotes from strings
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
        # Unescape SQL escape sequences
        value = value.replace("\\'", "'")
        value = value.replace('\\n', '\n')
        value = value.replace('\\r', '\r')
        value = value.replace('\\t', '\t')
        value = value.replace('\\\\', '\\')
    
    return value

# Extract data
csv_rows = []

for insert_block in insert_blocks:
    # Parse all row tuples from this INSERT statement
    row_tuples = parse_row_tuples(insert_block)
    
    print(f"  Parsed {len(row_tuples)} rows from INSERT statement")
    
    for row_values in row_tuples:
        # Extract only the delivery-related columns
        extracted_values = []
        for col in delivery_columns:
            if col in column_indexes:
                idx = column_indexes[col]
                if idx < len(row_values):
                    extracted_values.append(clean_value(row_values[idx]))
                else:
                    extracted_values.append('')
            else:
                extracted_values.append('')
        
        csv_rows.append(extracted_values)

# Write to CSV
with open(csv_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(delivery_columns)
    writer.writerows(csv_rows)

print(f"\nSUCCESS: Extracted {len(csv_rows)} restaurants with delivery flags")
print(f"Columns extracted: {len(delivery_columns)}")
print(f"Output: {csv_file}")
print()
print("NOTE: deliveryArea BLOB column was EXCLUDED per user decision (no data exists)")
