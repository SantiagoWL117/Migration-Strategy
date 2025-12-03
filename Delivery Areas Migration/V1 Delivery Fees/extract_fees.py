#!/usr/bin/env python3
"""
Extract Delivery Fees from V1 Dump
==================================
Parses SQL dump file and extracts delivery fees from the fee column.
Generates UPDATE statements for menuca_v3.restaurant_delivery_areas.
"""

import json
import re
from datetime import datetime

print("=" * 70)
print("V1 DELIVERY FEES EXTRACTION")
print("=" * 70)
print()

# =============================================================================
# STEP 1: Load ID Mappings
# =============================================================================
print("[STEP 1] Loading ID mappings...")

with open('id_mappings.json', 'r', encoding='utf-8') as f:
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

# Find the INSERT statement
insert_start = dump_content.find("INSERT INTO `santiago_restaurants_delivery_areas` VALUES ")
if insert_start == -1:
    print("  ERROR: Could not find INSERT statement in dump file")
    exit(1)

# Find the end
values_start = insert_start + len("INSERT INTO `santiago_restaurants_delivery_areas` VALUES ")
insert_end = dump_content.find("');", values_start)
if insert_end == -1:
    insert_end = dump_content.find(");", values_start)
if insert_end == -1:
    print("  ERROR: Could not find end of INSERT statement")
    exit(1)

values_str = dump_content[values_start:insert_end+2]
print(f"  Found INSERT statement ({len(values_str)} chars)")

# Parse individual records
# Format: (id,'name','address',_binary 'fee_data')
raw_records = re.split(r'\'\),\(', values_str)
print(f"  Split into {len(raw_records)} raw segments")

records = []
for i, raw in enumerate(raw_records):
    # Clean up first and last records
    if i == 0:
        raw = raw.lstrip('(')
    if i == len(raw_records) - 1:
        raw = raw.rstrip("')")
        raw = raw.rstrip(")")
    else:
        raw = raw + "'"
    
    # Pattern: id,'name','address',_binary 'fee'
    match = re.match(r"(\d+),'((?:[^'\\]|\\.)*)','((?:[^'\\]|\\.)*)',_binary '(.*)", raw, re.DOTALL)
    if match:
        v1_id = int(match.group(1))
        name = match.group(2).replace("\\'", "'")
        address = match.group(3).replace("\\'", "'")
        fee_data = match.group(4).rstrip("'")
        records.append({
            'v1_id': v1_id,
            'name': name,
            'address': address,
            'fee_data': fee_data
        })

print(f"  Extracted {len(records)} records")
print()

# =============================================================================
# STEP 3: Extract and Parse Fee Data
# =============================================================================
print("[STEP 3] Extracting fee data...")
print("-" * 70)

extracted_fees = []

def parse_php_array(data):
    """Parse PHP serialized array for fees"""
    # Format: a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"3.00\";...}
    # Note: quotes may be escaped as \"
    fees = {}
    
    # First try with escaped quotes (common in SQL dumps)
    pattern = r'i:(\d+);s:(\d+):\\"([^\\]*)\\";'
    matches = re.findall(pattern, data)
    
    if not matches:
        # Try without escaped quotes
        pattern = r'i:(\d+);s:(\d+):"([^"]*)";'
        matches = re.findall(pattern, data)
    
    for index, length, value in matches:
        if value and value.strip():
            # Clean up the value
            value = value.strip()
            # Skip empty strings
            if value:
                fees[int(index)] = value
    
    return fees

for record in records:
    v1_id = record['v1_id']
    name = record['name']
    fee_data = record['fee_data']
    
    # Check if this restaurant is in our mappings
    if v1_id not in id_mappings:
        continue
    
    mapping = id_mappings[v1_id]
    v3_id = mapping['v3_id']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    fees = {}
    
    # Check if it's a PHP serialized array
    if fee_data.startswith('a:'):
        fees = parse_php_array(fee_data)
        if fees:
            print(f"  PHP array found: {len(fees)} fee tier(s)")
            for idx, val in sorted(fees.items()):
                print(f"    Area {idx + 1}: ${val}")
        else:
            print(f"  PHP array found but no valid fees")
    
    # Check if it's a simple value
    elif fee_data and fee_data != '0':
        # Handle special formats like '5<40,0>40'
        if '<' in fee_data or '>' in fee_data:
            print(f"  Special format (skipped): {fee_data}")
        else:
            try:
                fee_val = float(fee_data)
                fees[0] = fee_data
                print(f"  Simple value: ${fee_data}")
            except ValueError:
                print(f"  Invalid value: {fee_data}")
    else:
        print(f"  No fee data (0 or empty)")
    
    if fees:
        extracted_fees.append({
            'v1_id': v1_id,
            'v3_id': v3_id,
            'name': name,
            'fees': fees
        })

print()
print("-" * 70)
print(f"Extraction complete: {len(extracted_fees)} restaurants with fee data")

# Save extracted fees
with open('extracted_fees.json', 'w', encoding='utf-8') as f:
    json.dump(extracted_fees, f, indent=2, ensure_ascii=False)
print(f"Saved: extracted_fees.json")
print()

# =============================================================================
# STEP 4: Generate Migration SQL
# =============================================================================
print("[STEP 4] Generating migration SQL...")

sql_lines = []
sql_lines.append("-- ============================================================================")
sql_lines.append("-- V1 Delivery Fees Migration")
sql_lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
sql_lines.append("-- ============================================================================")
sql_lines.append("--")
sql_lines.append(f"-- Total Restaurants with Fee Data: {len(extracted_fees)}")
sql_lines.append("--")
sql_lines.append("-- Source: V1 fee BLOB column (deserialized)")
sql_lines.append("-- Target: menuca_v3.restaurant_delivery_areas.delivery_fee")
sql_lines.append("-- ============================================================================")
sql_lines.append("")
sql_lines.append("BEGIN;")
sql_lines.append("")

update_count = 0

for restaurant in extracted_fees:
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['name']
    fees = restaurant['fees']
    
    sql_lines.append(f"-- Restaurant: {name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
    
    for area_index, fee_value in sorted(fees.items()):
        area_number = area_index + 1  # Convert 0-based index to 1-based area_number
        
        # Parse the fee value
        try:
            fee_float = float(fee_value)
        except ValueError:
            sql_lines.append(f"-- Skipping Area {area_number}: invalid fee value '{fee_value}'")
            continue
        
        sql_lines.append(f"UPDATE menuca_v3.restaurant_delivery_areas")
        sql_lines.append(f"SET delivery_fee = {fee_float:.2f}")
        sql_lines.append(f"WHERE restaurant_id = {v3_id}")
        sql_lines.append(f"  AND area_number = {area_number}")
        sql_lines.append(f"  AND (delivery_fee IS NULL OR delivery_fee = 0);")
        sql_lines.append(f"-- Area {area_number}: ${fee_float:.2f}")
        update_count += 1
    
    sql_lines.append("")

sql_lines.append("COMMIT;")
sql_lines.append("")
sql_lines.append("-- ============================================================================")
sql_lines.append("-- MIGRATION COMPLETE")
sql_lines.append(f"-- Total UPDATE statements: {update_count}")
sql_lines.append("-- ============================================================================")

# Write SQL file
sql_content = '\n'.join(sql_lines)
with open('fees_migration.sql', 'w', encoding='utf-8') as f:
    f.write(sql_content)
print(f"Saved: fees_migration.sql ({len(sql_content)} bytes)")
print(f"Total UPDATE statements: {update_count}")
print()

# =============================================================================
# STEP 5: Generate Report
# =============================================================================
print("[STEP 5] Generating extraction report...")

report_lines = []
report_lines.append("# V1 Delivery Fees Extraction Report")
report_lines.append("")
report_lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
report_lines.append("")
report_lines.append("## Summary")
report_lines.append("")
report_lines.append("| Metric | Value |")
report_lines.append("|--------|-------|")
report_lines.append(f"| Restaurants in Dump | {len(records)} |")
report_lines.append(f"| Restaurants Mapped | {len(id_mappings)} |")
report_lines.append(f"| Restaurants with Fees | {len(extracted_fees)} |")
report_lines.append(f"| Total UPDATE Statements | {update_count} |")
report_lines.append("")
report_lines.append("## Extracted Fees")
report_lines.append("")
report_lines.append("| V1 ID | V3 ID | Restaurant | Area 1 | Area 2 | Area 3+ |")
report_lines.append("|-------|-------|------------|--------|--------|---------|")

for restaurant in extracted_fees:
    fees = restaurant['fees']
    area1 = fees.get(0, '-')
    area2 = fees.get(1, '-')
    area3plus = ', '.join([f"${fees[k]}" for k in sorted(fees.keys()) if k > 1]) or '-'
    
    if area1 != '-':
        area1 = f"${area1}"
    if area2 != '-':
        area2 = f"${area2}"
    
    report_lines.append(f"| {restaurant['v1_id']} | {restaurant['v3_id']} | {restaurant['name']} | {area1} | {area2} | {area3plus} |")

report_lines.append("")
report_lines.append("## Files Generated")
report_lines.append("")
report_lines.append("| File | Description |")
report_lines.append("|------|-------------|")
report_lines.append("| `id_mappings.json` | V1 to V3 ID mappings |")
report_lines.append("| `extracted_fees.json` | Parsed fee data |")
report_lines.append("| `fees_migration.sql` | UPDATE statements |")
report_lines.append("")
report_lines.append("## Next Steps")
report_lines.append("")
report_lines.append("1. Review the extracted data in `extracted_fees.json`")
report_lines.append("2. Execute `fees_migration.sql` against menuca_v3 database")
report_lines.append("3. Verify delivery_fee values were updated correctly")

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
print(f"  - Restaurants with fees: {len(extracted_fees)}")
print(f"  - UPDATE statements: {update_count}")
print()
print("Output files:")
print("  - extracted_fees.json")
print("  - fees_migration.sql")
print("  - EXTRACTION_REPORT.md")
print()

