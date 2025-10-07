#!/usr/bin/env python3
"""
Convert all SQL dumps to CSV files for Delivery Operations migration
Phase 2: Data Extraction
"""

import re
import csv
import os
from pathlib import Path

# Get script directory
script_dir = Path(__file__).parent
dumps_dir = script_dir / "dumps"
csv_dir = script_dir / "CSV"

# Create CSV directory if it doesn't exist
csv_dir.mkdir(exist_ok=True)

print("="*60)
print("Delivery Operations - Phase 2: Data Extraction")
print("="*60)
print()

def extract_values_from_insert(insert_line):
    """Extract individual value tuples from an INSERT statement"""
    # Find the VALUES (...) portion
    match = re.search(r'VALUES\s+(.+);?\s*$', insert_line, re.DOTALL)
    if not match:
        return []
    
    values_str = match.group(1).strip()
    if values_str.endswith(';'):
        values_str = values_str[:-1]
    
    # Parse the value tuples
    rows = []
    current_row = []
    current_value = ""
    in_string = False
    escape_next = False
    paren_depth = 0
    
    for char in values_str:
        if escape_next:
            current_value += char
            escape_next = False
            continue
        
        if char == '\\':
            escape_next = True
            current_value += char
            continue
        
        if char == "'" and not escape_next:
            in_string = not in_string
            current_value += char
            continue
        
        if not in_string:
            if char == '(':
                paren_depth += 1
                if paren_depth == 1:
                    # Start of a new row
                    continue
            elif char == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    # End of current row
                    if current_value:
                        current_row.append(current_value.strip())
                    if current_row:
                        rows.append(current_row)
                    current_row = []
                    current_value = ""
                    continue
            elif char == ',' and paren_depth == 1:
                # End of current value
                current_row.append(current_value.strip())
                current_value = ""
                continue
        
        current_value += char
    
    return rows

def clean_value(value):
    """Clean a SQL value for CSV output"""
    value = value.strip()
    
    if value == 'NULL' or value == '':
        return ''
    
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

def convert_dump_to_csv(dump_file, csv_file, headers):
    """Convert a SQL dump file to CSV"""
    print(f"Converting {dump_file.name} to CSV...")
    
    # Read the entire dump file
    with open(dump_file, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Find all INSERT statements
    insert_pattern = r'INSERT INTO [^;]+;'
    inserts = re.findall(insert_pattern, content, re.DOTALL)
    
    if not inserts:
        print(f"  WARNING: No INSERT statements found in {dump_file.name}")
        return 0
    
    # Extract all rows
    all_rows = []
    for insert in inserts:
        rows = extract_values_from_insert(insert)
        all_rows.extend(rows)
    
    # Write to CSV
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        
        for row in all_rows:
            cleaned_row = [clean_value(val) for val in row]
            writer.writerow(cleaned_row)
    
    print(f"  SUCCESS: Converted {len(all_rows)} rows to {csv_file.name}")
    return len(all_rows)

# Conversion configurations
conversions = [
    {
        'name': 'V1 delivery_info',
        'dump': 'menuca_v1_delivery_info.sql',
        'csv': 'menuca_v1_delivery_info.csv',
        'headers': ['id', 'restaurant_id', 'sendToDelivery', 'disable_until', 'email', 'notes', 'commission', 'rpd']
    },
    {
        'name': 'V1 distance_fees',
        'dump': 'menuca_v1_distance_fees.sql',
        'csv': 'menuca_v1_distance_fees.csv',
        'headers': ['id', 'restaurant_id', 'distance', 'driver_earning', 'restaurant_pays', 'vendor_pays', 'delivery_fee']
    },
    {
        'name': 'V1 tookan_fees',
        'dump': 'menuca_v1_tookan_fees.sql',
        'csv': 'menuca_v1_tookan_fees.csv',
        'headers': ['id', 'restaurant_id', 'area', 'driver_earnings', 'restaurant', 'vendor', 'total_fare']
    },
    {
        'name': 'V2 restaurants_delivery_schedule',
        'dump': 'menuca_v2_restaurants_delivery_schedule.sql',
        'csv': 'menuca_v2_restaurants_delivery_schedule.csv',
        'headers': ['id', 'restaurant_id', 'day', 'start', 'stop']
    },
    {
        'name': 'V2 restaurants_delivery_fees',
        'dump': 'menuca_v2_restaurants_delivery_fees.sql',
        'csv': 'menuca_v2_restaurants_delivery_fees.csv',
        'headers': ['id', 'restaurant_id', 'area_or_distances', 'delivery_fee', 'min_order_value', 'company_id']
    },
    {
        'name': 'V2 twilio',
        'dump': 'menuca_v2_twilio.sql',
        'csv': 'menuca_v2_twilio.csv',
        'headers': ['id', 'restaurant_id', 'enable_call', 'phone', 'added_by', 'added_at', 'updated_by', 'updated_at']
    },
    {
        'name': 'V2 restaurants_delivery_areas',
        'dump': 'menuca_v2_restaurants_delivery_areas.sql',
        'csv': 'menuca_v2_restaurants_delivery_areas.csv',
        'headers': ['id', 'restaurant_id', 'area_number', 'area_name', 'delivery_fee', 'min_order_value', 'is_complex', 'coords']
    }
]

# Run all conversions
results = []
total_rows = 0

print("Starting conversions...")
print()

for i, config in enumerate(conversions, 1):
    print(f"[{i}/{len(conversions)}] {config['name']}")
    
    dump_path = dumps_dir / config['dump']
    csv_path = csv_dir / config['csv']
    
    if not dump_path.exists():
        print(f"  ERROR: Dump file not found: {dump_path}")
        results.append({'name': config['name'], 'status': 'FAILED', 'reason': 'File not found'})
        continue
    
    try:
        row_count = convert_dump_to_csv(dump_path, csv_path, config['headers'])
        total_rows += row_count
        results.append({'name': config['name'], 'status': 'SUCCESS', 'rows': row_count})
    except Exception as e:
        print(f"  ERROR: {e}")
        results.append({'name': config['name'], 'status': 'FAILED', 'reason': str(e)})
    
    print()

# V1 restaurants delivery flags - special handling
print(f"[8/8] Extracting V1 restaurants delivery flags...")
print("  This requires special handling - will be done separately")
print()

# Summary
print("="*60)
print("Phase 2 Conversion Summary")
print("="*60)
print()

for result in results:
    if result['status'] == 'SUCCESS':
        print(f"[OK] {result['name']} - {result['rows']} rows")
    else:
        reason = result.get('reason', 'Unknown error')
        print(f"[FAILED] {result['name']} - {reason}")

print()
print(f"Total rows converted: {total_rows}")
print(f"CSV files created: {len([r for r in results if r['status'] == 'SUCCESS'])}")
print()
print("Phase 2: Data Extraction - COMPLETE!")
print()
print("Next Steps:")
print("  1. Review CSV files in the CSV/ folder")
print("  2. Extract V1 restaurants delivery flags manually")
print("  3. Proceed to Phase 3: Create Staging Tables")

