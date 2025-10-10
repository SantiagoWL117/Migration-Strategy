#!/usr/bin/env python3
"""
Phase 4.2: Extract menuothers BLOB data to CSV
Extracts id, restaurant, dishId, content (hex), type, groupId
"""
import re
import csv
import os

DUMP_FILE = r"Database\Menu & Catalog Entity\dumps\menuca_v1_menuothers_BLOB.sql"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menuothers_hex.csv"

def main():
    print("=" * 70)
    print("Phase 4.2: Extract menuothers BLOB to CSV")
    print("=" * 70)
    print()

    print(f"Reading: {DUMP_FILE}")

    # Read file with UTF-8 encoding
    with open(DUMP_FILE, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    print(f"File size: {len(content):,} characters")

    # Find INSERT INTO statement
    idx = content.find('INSERT INTO')
    if idx == -1:
        raise ValueError("INSERT INTO not found!")

    print("Found INSERT INTO statement")

    # Find the VALUES section (case-insensitive)
    # Find where VALUES starts after INSERT
    values_pattern = re.compile(r'VALUES\s*\n', re.IGNORECASE)
    values_match = values_pattern.search(content, idx)
    if not values_match:
        raise ValueError("VALUES not found in INSERT statement!")
    
    values_start = values_match.end()

    # Extract VALUES content
    values_section = content[values_start:].strip()
    
    # Remove trailing semicolon
    if values_section.endswith(';'):
        values_section = values_section[:-1]

    print(f"VALUES section length: {len(values_section):,} characters")

    # Split into individual rows by ),( pattern
    print("Splitting rows...")
    raw_rows = re.split(r'\),\s*\n\s*\(', values_section)
    
    # Clean first and last rows (remove outer parentheses)
    if raw_rows:
        raw_rows[0] = raw_rows[0].lstrip('(\n ')
        raw_rows[-1] = raw_rows[-1].rstrip(');)\n ')
    
    print(f"Found {len(raw_rows)} rows")
    print("Extracting columns...")

    extracted_data = []
    
    # Pattern to match a row: (id, restaurant, dishId, 0xHEX, 'type', groupId)
    # Using a more flexible regex that handles:
    # - Numbers
    # - Hex values (0x...)
    # - Quoted strings
    # - NULL values
    
    for i, row_str in enumerate(raw_rows):
        row_str = row_str.strip()
        
        # Split by comma, being careful with hex values
        # Pattern: number,number,number,0xHEX,'string',number
        
        # Use regex to extract values
        # Match: digits, hex (0x...), quoted strings, NULL
        parts = []
        
        # Split on commas but preserve hex values and quoted strings
        # Simple approach: find commas that are not within hex or quotes
        
        # Extract values one by one
        # Expected: (id, restaurant, dishId, content_hex, 'type', groupId)
        
        # Match pattern: number, number, number, 0xHEX, 'string', number/NULL
        pattern = r'^(\d+),(\d+),(\d+),(0x[0-9a-fA-F]+),\'([^\']*)\',(\d+|NULL)$'
        match = re.match(pattern, row_str)
        
        if match:
            record = {
                'id': match.group(1),
                'restaurant': match.group(2),
                'dishId': match.group(3),
                'content_hex': match.group(4),
                'type': match.group(5),
                'groupId': match.group(6) if match.group(6) != 'NULL' else ''
            }
            extracted_data.append(record)
        else:
            # Try alternative pattern with NULL content
            pattern_null = r'^(\d+),(\d+),(\d+),(NULL),\'([^\']*)\',(\d+|NULL)$'
            match = re.match(pattern_null, row_str)
            if match:
                record = {
                    'id': match.group(1),
                    'restaurant': match.group(2),
                    'dishId': match.group(3),
                    'content_hex': '',  # NULL
                    'type': match.group(5),
                    'groupId': match.group(6) if match.group(6) != 'NULL' else ''
                }
                extracted_data.append(record)
            else:
                print(f"  Warning: Could not parse row {i}: {row_str[:100]}...")
        
        if (i + 1) % 10000 == 0:
            print(f"  Processed {i + 1:,} rows...")

    print(f"\nExtracted {len(extracted_data):,} records")

    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['id', 'restaurant', 'dishId', 'content_hex', 'type', 'groupId'])
        writer.writeheader()
        writer.writerows(extracted_data)

    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(extracted_data):,}")
    print()
    print("Next step: Run phase4_2_deserialize_menuothers.py")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()

