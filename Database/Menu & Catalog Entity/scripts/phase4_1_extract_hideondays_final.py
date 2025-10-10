"""
Phase 4.1: Extract hideOnDays BLOB Data - Final Working Version
================================================================

The entire INSERT statement is on one massive line.
We need to read it as a single line and split by row delimiters.

Author: AI Assistant
Date: 2025-01-09
"""

import re
import csv
import os

DUMP_FILE = r"Database\Menu & Catalog Entity\dumps\menuca_v1_menu_hideondays_BLOB.sql"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menu_hideondays_hex.csv"

def main():
    print("=" * 70)
    print("Phase 4.1: Extract hideOnDays BLOB to CSV")
    print("=" * 70)
    print()
    
    print(f"Reading: {DUMP_FILE}")
    
    with open(DUMP_FILE, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    print(f"File size: {len(content):,} bytes")
    
    # Find INSERT INTO using regex (case insensitive)
    insert_match = re.search(r'INSERT INTO[^\n]*\n?([^\n]+)', content, re.IGNORECASE | re.DOTALL)
    
    if not insert_match:
        # Try finding it in the content directly
        idx = content.upper().find('INSERT INTO')
        if idx == -1:
            raise ValueError("No INSERT INTO statement found!")
        
        # Extract from that point forward
        insert_section = content[idx:]
        # Find the line containing INSERT
        newline_idx = insert_section.find('\n', insert_section.find('VALUES'))
        if newline_idx == -1:
            insert_line = insert_section
        else:
            insert_line = insert_section[:newline_idx]
    else:
        insert_line = content[insert_match.start():]
        # Get up to first real newline or end
        newline_idx = insert_line.find('\n',  insert_line.find('VALUES') + 100)  # Look past VALUES
        if newline_idx > 0:
            insert_line = insert_line[:newline_idx]
    
    print(f"INSERT line length: {len(insert_line):,} chars")
    
    # Extract VALUES section
    values_start = insert_line.find('VALUES ')
    if values_start == -1:
        raise ValueError("No VALUES found in INSERT statement!")
    
    values_section = insert_line[values_start + 7:]  # Skip "VALUES "
    
    # Remove trailing semicolon and whitespace
    values_section = values_section.rstrip(';').rstrip()
    
    # Split by ),( to get individual rows
    rows = values_section.split('),(')
    
    # Clean first and last rows
    if rows:
        rows[0] = rows[0].lstrip('(')
        rows[-1] = rows[-1].rstrip(')')
    
    print(f"Found {len(rows)} rows")
    
    # Extract ID and hideOnDays hex from each row
    results = []
    hex_pattern = re.compile(r'0x[0-9A-Fa-f]+')
    
    for i, row in enumerate(rows, 1):
        # Get ID (first value)
        id_match = re.match(r'^(\d+),', row)
        if not id_match:
            print(f"WARNING: Row {i} has no ID")
            continue
        
        dish_id = id_match.group(1)
        
        # Get all hex values
        hex_matches = hex_pattern.findall(row)
        
        if not hex_matches:
            print(f"WARNING: Row {i} (ID={dish_id}) has no hex BLOB")
            continue
        
        # The hideOnDays is the last hex value
        hideondays_hex = hex_matches[-1]
        
        results.append((dish_id, hideondays_hex))
        
        if i % 100 == 0:
            print(f"Processed {i}/{len(rows)} rows...")
    
    print(f"\nExtracted {len(results)} records with hideOnDays BLOB")
    
    # Create output directory
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    
    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'hideondays_hex'])
        
        for row in results:
            writer.writerow(row)
    
    print(f"CSV created with {len(results)} rows")
    print()
    print("=" * 70)
    print("SUCCESS!")
    print("=" * 70)
    print(f"Output: {OUTPUT_CSV}")
    print(f"Records: {len(results)}")
    print()
    print("Next: Run phase4_1_deserialize_hideondays.py")
    
    return 0

if __name__ == "__main__":
    try:
        exit(main())
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()
        exit(1)

