#!/usr/bin/env python3
"""
Extract V1 ingredient_groups non-BLOB columns from SQL dump to CSV.

Source: menuca_v1_ingredient_groups.sql (13,252 records)
Output: menuca_v1_ingredient_groups.csv
Columns: id, name, type, course, dish, restaurant, lang, useInCombo, isGlobal

BLOB columns (item, price) are SKIPPED - already deserialized in Phase 4.3
"""

import re
import csv
from pathlib import Path

# Paths
DUMP_FILE = Path("Database/Menu & Catalog Entity/dumps/menuca_v1_ingredient_groups.sql")
OUTPUT_CSV = Path("Database/Menu & Catalog Entity/CSV/menuca_v1_ingredient_groups.csv")

# CSV headers matching staging table schema
HEADERS = ['id', 'name', 'type', 'course', 'dish', 'restaurant', 'lang', 'useInCombo', 'isGlobal']

def extract_string_value(value):
    """Extract string value from SQL format."""
    if value == 'NULL':
        return None
    # Remove quotes and unescape
    value = value.strip()
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
    elif value.startswith('_binary '):
        # Handle _binary 'value' format - extract the quoted value
        match = re.search(r"_binary\s+'([^']*)'", value)
        if match:
            value = match.group(1)
    # Unescape single quotes
    value = value.replace("\\'", "'").replace("''", "'")
    return value if value else None

def parse_ingredient_group_row(row_text):
    """
    Parse one ingredient group row from SQL INSERT.
    Format: (id,'name','type',course,dish,_binary 'BLOB',_binary 'BLOB',restaurant,'lang','useInCombo','isGlobal')
    We skip the BLOB columns (indexes 5 and 6).
    """
    try:
        # Remove leading/trailing parentheses and whitespace
        row_text = row_text.strip()
        if row_text.startswith('('):
            row_text = row_text[1:]
        if row_text.endswith(')'):
            row_text = row_text[:-1]
        
        # Manual parsing to handle complex BLOBs
        parts = []
        current = ""
        in_quotes = False
        in_binary = False
        paren_depth = 0
        i = 0
        
        while i < len(row_text):
            char = row_text[i]
            
            # Check for _binary keyword
            if not in_quotes and row_text[i:i+7] == '_binary':
                in_binary = True
                current += char
                i += 1
                continue
            
            # Track quotes
            if char == "'" and (i == 0 or row_text[i-1] != '\\'):
                in_quotes = not in_quotes
                current += char
            # Track nested structures in BLOBs
            elif char == '(' and in_binary:
                paren_depth += 1
                current += char
            elif char == ')' and in_binary and paren_depth > 0:
                paren_depth -= 1
                current += char
            # Comma separator (not inside quotes or binary blob)
            elif char == ',' and not in_quotes and paren_depth == 0:
                parts.append(current.strip())
                current = ""
                in_binary = False
            else:
                current += char
            
            i += 1
        
        # Add last part
        if current:
            parts.append(current.strip())
        
        # We expect 11 parts total
        if len(parts) < 11:
            print(f"Warning: Row has only {len(parts)} parts, expected 11")
            return None
        
        # Extract non-BLOB columns
        # Columns: 0=id, 1=name, 2=type, 3=course, 4=dish, 5=item(BLOB-SKIP), 6=price(BLOB-SKIP), 7=restaurant, 8=lang, 9=useInCombo, 10=isGlobal
        record = {
            'id': parts[0].strip(),
            'name': extract_string_value(parts[1]),
            'type': extract_string_value(parts[2]),
            'course': parts[3].strip() if parts[3].strip() != 'NULL' else '0',
            'dish': parts[4].strip() if parts[4].strip() != 'NULL' else '0',
            # Skip parts[5] (item BLOB) and parts[6] (price BLOB)
            'restaurant': parts[7].strip(),
            'lang': extract_string_value(parts[8]),
            'useInCombo': extract_string_value(parts[9]),
            'isGlobal': extract_string_value(parts[10])
        }
        
        return record
        
    except Exception as e:
        print(f"Error parsing row: {e}")
        print(f"Row text (first 200 chars): {row_text[:200]}")
        return None

def main():
    print("=" * 70)
    print("V1 ingredient_groups SQL -> CSV Converter")
    print("=" * 70)
    print(f"Source: {DUMP_FILE}")
    print(f"Output: {OUTPUT_CSV}")
    print()
    
    # Read SQL dump
    print("Reading SQL dump...")
    with open(DUMP_FILE, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Find INSERT statement
    print("Parsing INSERT statement...")
    insert_match = re.search(r'INSERT INTO `?ingredient_groups`?.*?VALUES\s*\(', content, re.IGNORECASE | re.DOTALL)
    if not insert_match:
        print("ERROR: Could not find INSERT INTO statement!")
        return
    
    # Start from the opening parenthesis after VALUES
    values_start = insert_match.end() - 1  # Back up to include the '('
    values_section = content[values_start:].strip()
    
    # Remove trailing semicolon if present
    if values_section.endswith(';'):
        values_section = values_section[:-1]
    
    # Split into rows - look for "),\n(" pattern but handle edge cases
    print("Splitting rows...")
    # Use a more robust pattern that handles newlines and spaces
    raw_rows = re.split(r'\),\s*\n\s*\(', values_section)
    
    # Clean up first and last rows
    if raw_rows:
        raw_rows[0] = raw_rows[0].lstrip('(')
        raw_rows[-1] = raw_rows[-1].rstrip(')')
    
    print(f"Found {len(raw_rows)} rows to process")
    
    # Parse rows
    records = []
    errors = 0
    
    for idx, row_text in enumerate(raw_rows):
        if idx % 1000 == 0:
            print(f"Processing row {idx+1}/{len(raw_rows)}...")
        
        record = parse_ingredient_group_row(row_text)
        if record:
            records.append(record)
        else:
            errors += 1
    
    print()
    print(f"Successfully parsed: {len(records)} records")
    print(f"Errors: {errors}")
    
    # Write to CSV
    print()
    print(f"Writing to {OUTPUT_CSV}...")
    OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=HEADERS)
        writer.writeheader()
        writer.writerows(records)
    
    print(f"✅ CSV created: {len(records)} records written")
    
    # Summary
    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Total records: {len(records)}")
    print(f"Expected: 13,252")
    print(f"Match: {'✅ YES' if len(records) >= 13250 else '❌ NO'}")
    print()
    print("Next Steps:")
    print("1. Upload CSV to Supabase: staging.menuca_v1_ingredient_groups")
    print("2. Verify row count matches")
    print("3. Resume Phase 5")
    print("=" * 70)

if __name__ == "__main__":
    main()

