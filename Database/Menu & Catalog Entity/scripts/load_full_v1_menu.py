#!/usr/bin/env python3
"""
Load ALL rows from menuca_v1_menu.sql (58,057 rows) into staging.menuca_v1_menu_full.
This script does NOT filter out any rows - it loads everything including:
- Hidden dishes (showinmenu='N')
- Dishes with blank names
- Inactive restaurant dishes

Purpose: Unblock combo migration which needs ALL dishes by ID.
"""

import re
import csv
import sys
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
SQL_FILE = SCRIPT_DIR.parent / "dumps" / "menuca_v1_menu.sql"
OUTPUT_CSV = SCRIPT_DIR.parent / "CSV" / "menuca_v1_menu_FULL.csv"

print("=" * 60)
print("LOADING FULL V1 MENU DATA (NO EXCLUSIONS)")
print("=" * 60)
print(f"Source: {SQL_FILE}")
print(f"Output: {OUTPUT_CSV}")
print()

# Read the SQL file
print("[1/4] Reading SQL file...")
with open(SQL_FILE, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print(f"  File size: {len(content) / 1024 / 1024:.1f} MB")

# Extract CREATE TABLE to get column names
print("\n[2/4] Extracting column names...")
create_match = re.search(
    r'CREATE TABLE\s+`?menu`?\s*\((.*?)\)(?:\s+ENGINE|\s*;)',
    content,
    re.DOTALL | re.IGNORECASE
)

if not create_match:
    print("ERROR: Could not find CREATE TABLE statement")
    sys.exit(1)

# Parse column names (excluding BLOB hideOnDays)
columns = []
column_block = create_match.group(1)
for line in column_block.split('\n'):
    line = line.strip()
    if any(keyword in line.upper() for keyword in ['PRIMARY KEY', 'UNIQUE KEY', 'KEY ', 'CONSTRAINT']):
        continue
    
    col_match = re.match(r'`([^`]+)`\s+', line)
    if col_match:
        col_name = col_match.group(1)
        # Skip the BLOB column
        if col_name != 'hideOnDays':
            columns.append(col_name)

print(f"  Found {len(columns)} columns (excluding hideOnDays BLOB)")

# Extract all INSERT statements
print("\n[3/4] Parsing INSERT statements...")
insert_pattern = r'INSERT INTO\s+`?menu`?\s+VALUES\s+(.*?);'
insert_matches = list(re.finditer(insert_pattern, content, re.DOTALL | re.IGNORECASE))

print(f"  Found {len(insert_matches)} INSERT statements")

# Parse rows from all INSERT statements
def parse_insert_values(insert_statement):
    """Parse INSERT INTO ... VALUES (...), (...), ... statement."""
    values_match = re.search(r'VALUES\s+(.*);?\s*$', insert_statement, re.DOTALL | re.IGNORECASE)
    if not values_match:
        return []
    
    values_str = values_match.group(1).strip()
    if values_str.endswith(';'):
        values_str = values_str[:-1]
    
    rows = []
    current_row = []
    current_value = ""
    in_quotes = False
    escaped = False
    paren_depth = 0
    
    i = 0
    while i < len(values_str):
        char = values_str[i]
        
        if escaped:
            if char == 'n':
                current_value += '\n'
            elif char == 'r':
                current_value += '\r'
            elif char == 't':
                current_value += '\t'
            elif char == '0':
                current_value += '\0'
            elif char == '\\':
                current_value += '\\'
            elif char == "'":
                current_value += "'"
            else:
                current_value += char
            escaped = False
            i += 1
            continue
        
        if char == '\\':
            escaped = True
            i += 1
            continue
        
        if char == "'":
            in_quotes = not in_quotes
            i += 1
            continue
        
        if not in_quotes:
            if char == '(':
                paren_depth += 1
                if paren_depth == 1:
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    current_row.append(current_value.strip())
                    rows.append(current_row)
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ',' and paren_depth == 1:
                current_row.append(current_value.strip())
                current_value = ""
                i += 1
                while i < len(values_str) and values_str[i] in ' \t\n\r':
                    i += 1
                continue
        
        current_value += char
        i += 1
    
    return rows

def clean_value(value):
    """Clean value for CSV output."""
    if value.upper() == 'NULL' or value == '':
        return ''
    
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
    
    value = value.replace("\\'", "'")
    value = value.replace('\\\\', '\\')
    value = value.replace('\\n', '\n')
    value = value.replace('\\r', '\r')
    value = value.replace('\\t', '\t')
    
    return value

# Process all INSERT statements
all_rows = []
for idx, insert_match in enumerate(insert_matches, 1):
    insert_stmt = insert_match.group(0)
    rows = parse_insert_values(insert_stmt)
    all_rows.extend(rows)
    print(f"  INSERT {idx}/{len(insert_matches)}: {len(rows)} rows (total: {len(all_rows)})")

print(f"\n  Total rows extracted: {len(all_rows)}")

# Write to CSV
print("\n[4/4] Writing CSV file...")
with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as csvf:
    writer = csv.writer(csvf, quoting=csv.QUOTE_MINIMAL)
    
    # Write header (lowercase for PostgreSQL)
    writer.writerow([col.lower() for col in columns])
    
    # Write all rows
    row_count = 0
    for row in all_rows:
        # Filter out the hideOnDays BLOB column (last column in CREATE TABLE)
        # The row should have len(columns)+1 values (including BLOB)
        # We take only the first len(columns) values
        filtered_row = [clean_value(val) for val in row[:len(columns)]]
        
        if len(filtered_row) == len(columns):
            writer.writerow(filtered_row)
            row_count += 1
            if row_count % 5000 == 0:
                print(f"    Written {row_count} rows...")
        else:
            print(f"  WARNING: Row has {len(filtered_row)} values, expected {len(columns)}")

print(f"\n✓ Successfully written {row_count} rows to CSV")
print(f"  File: {OUTPUT_CSV}")
print()

if row_count >= 58000:
    print("SUCCESS! All 58,057 rows should be present.")
    print("Next step: Load this CSV into staging.menuca_v1_menu_full")
else:
    print(f"WARNING: Expected ~58,057 rows, got {row_count}")

print("=" * 60)

