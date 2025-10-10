"""
Phase 4.1: Extract hideOnDays - Working Version
================================================

Direct string search approach.
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
    
    # The file is UTF-16 LE encoded (Windows mysqldump format)
    with open(DUMP_FILE, 'r', encoding='utf-16-le', errors='replace') as f:
        content = f.read()
    
    print(f"File size: {len(content):,} characters")
    
    # Direct string search
    idx = content.find('INSERT INTO')
    if idx == -1:
        raise ValueError("INSERT INTO not found!")
    
    print(f"Found INSERT INTO at position {idx}")
    
    # Extract from VALUES onward
    values_idx = content.find('VALUES', idx)
    if values_idx == -1:
        raise ValueError("VALUES not found!")
    
    print(f"Found VALUES at position {values_idx}")
    
    # Get everything from VALUES to the end or semicolon
    values_section = content[values_idx + 7:]  # Skip "VALUES "
    
    # Find the ending semicolon
    end_idx = values_section.rfind(');')
    if end_idx != -1:
        values_section = values_section[:end_idx + 1]  # Include the )
    
    # Remove trailing semicolon and whitespace
    values_section = values_section.rstrip(';').rstrip()
    
    # Split by ),( to get individual rows
    print("Splitting rows...")
    rows = values_section.split('),(')
    
    # Clean first and last rows
    if rows:
        rows[0] = rows[0].lstrip('(')
        rows[-1] = rows[-1].rstrip(')')
    
    print(f"Found {len(rows)} rows")
    
    # Extract ID and hideOnDays hex from each row
    print("Extracting ID and hex values...")
    results = []
    hex_pattern = re.compile(r'0x[0-9A-Fa-f]+')
    
    for i, row in enumerate(rows, 1):
        # Get ID (first value)
        id_match = re.match(r'^(\d+),', row)
        if not id_match:
            continue
        
        dish_id = id_match.group(1)
        
        # Get all hex values
        hex_matches = hex_pattern.findall(row)
        
        if not hex_matches:
            continue
        
        # The hideOnDays is the last hex value
        hideondays_hex = hex_matches[-1]
        
        results.append((dish_id, hideondays_hex))
        
        if i % 100 == 0:
            print(f"Processed {i}/{len(rows)} rows...")
    
    print(f"\nExtracted {len(results)} records")
    
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
    
    return 0

if __name__ == "__main__":
    try:
        exit(main())
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()
        exit(1)

