#!/usr/bin/env python3
"""
Phase 4.4 Step 2: Extract combo_groups hex BLOBs to CSV
Extracts id, name, restaurant, dish_hex, options_hex, group_hex from SQL dump
"""
import re
import csv
import os

DUMP_FILE = r"Database\Menu & Catalog Entity\dumps\menuca_v1_combo_groups_HEX.sql"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_groups_hex.csv"

def main():
    print("=" * 70)
    print("Phase 4.4 Step 2: Extract combo_groups hex to CSV")
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

    # Split into individual rows by looking for patterns like: ),\n(id,
    print("Splitting rows...")
    # Use a more robust pattern that handles multi-line hex values
    raw_rows = re.split(r'\),\s*\n\s*\((?=\d+,)', values_section)
    
    # Clean first and last rows (remove outer parentheses)
    if raw_rows:
        raw_rows[0] = raw_rows[0].lstrip('(\n ')
        raw_rows[-1] = raw_rows[-1].rstrip(');)\n ')
    
    # Remove all newlines from each row (hex values span multiple lines)
    raw_rows = [row.replace('\n', '').replace('\r', '') for row in raw_rows]
    
    print(f"Found {len(raw_rows)} rows")
    print("Extracting columns...")

    extracted_data = []
    
    # Pattern: (id, 'name' or NULL, restaurant, 0xHEX or NULL, 0xHEX or NULL, 0xHEX or NULL)
    
    for i, row_str in enumerate(raw_rows):
        row_str = row_str.strip()
        
        try:
            # Extract ID (first number)
            id_match = re.match(r'^(\d+),', row_str)
            if not id_match:
                print(f"  Warning: Could not extract ID from row {i}")
                continue
            
            row_id = id_match.group(1)
            remaining = row_str[id_match.end():]
            
            # Extract name (NULL or 'string')
            if remaining.startswith('NULL,'):
                name = ''
                remaining = remaining[5:]
            else:
                # Extract quoted string (handle escaped quotes)
                name_match = re.match(r"'((?:[^']|'')*)',", remaining)
                if name_match:
                    name = name_match.group(1).replace("''", "'")
                    remaining = remaining[name_match.end():]
                else:
                    print(f"  Warning: Could not extract name from row {i}")
                    continue
            
            # Extract restaurant (number)
            restaurant_match = re.match(r'(\d+),', remaining)
            if restaurant_match:
                restaurant = restaurant_match.group(1)
                remaining = remaining[restaurant_match.end():]
            else:
                print(f"  Warning: Could not extract restaurant from row {i}")
                continue
            
            # Extract dish_hex (0xHEX or NULL)
            if remaining.startswith('NULL,'):
                dish_hex = ''
                remaining = remaining[5:]
            else:
                dish_match = re.match(r'(0x[0-9a-fA-F]+),', remaining)
                if dish_match:
                    dish_hex = dish_match.group(1)
                    remaining = remaining[dish_match.end():]
                else:
                    print(f"  Warning: Could not extract dish_hex from row {i}")
                    continue
            
            # Extract options_hex (0xHEX or NULL)
            if remaining.startswith('NULL,'):
                options_hex = ''
                remaining = remaining[5:]
            else:
                options_match = re.match(r'(0x[0-9a-fA-F]+),', remaining)
                if options_match:
                    options_hex = options_match.group(1)
                    remaining = remaining[options_match.end():]
                else:
                    print(f"  Warning: Could not extract options_hex from row {i}")
                    continue
            
            # Extract group_hex (0xHEX or NULL) - last column, no comma
            if remaining.startswith('NULL'):
                group_hex = ''
            else:
                group_match = re.match(r'(0x[0-9a-fA-F]+)', remaining)
                if group_match:
                    group_hex = group_match.group(1)
                else:
                    print(f"  Warning: Could not extract group_hex from row {i}")
                    continue
            
            record = {
                'id': row_id,
                'name': name,
                'restaurant': restaurant,
                'dish_hex': dish_hex,
                'options_hex': options_hex,
                'group_hex': group_hex
            }
            extracted_data.append(record)
        
        except Exception as e:
            print(f"  Warning: Error parsing row {i}: {e}")
            continue
        
        if (i + 1) % 5000 == 0:
            print(f"  Processed {i + 1:,} rows...")

    print(f"\nExtracted {len(extracted_data):,} records")

    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['id', 'name', 'restaurant', 'dish_hex', 'options_hex', 'group_hex'])
        writer.writeheader()
        writer.writerows(extracted_data)

    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(extracted_data):,}")
    print()
    print("Next step: Deserialize each BLOB separately")
    print("  1. phase4_4_deserialize_dish_blob.py")
    print("  2. phase4_4_deserialize_options_blob.py")
    print("  3. phase4_4_deserialize_group_blob.py")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()

