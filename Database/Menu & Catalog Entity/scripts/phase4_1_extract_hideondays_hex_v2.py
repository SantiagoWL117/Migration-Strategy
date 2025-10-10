"""
Phase 4.1: Extract hideOnDays BLOB Data from SQL Dump to CSV (Version 2)
==========================================================================

Purpose: Extract id and hex-encoded hideOnDays BLOB from the SQL dump
         and save to CSV for further processing.

Approach: Directly extract hex BLOB values without relying on complex regex

Input:  menuca_v1_menu_hideondays_BLOB.sql
Output: menuca_v1_menu_hideondays_hex.csv

Author: AI Assistant
Date: 2025-01-09
"""

import re
import csv
import os

# Configuration
DUMP_FILE = r"Database\Menu & Catalog Entity\dumps\menuca_v1_menu_hideondays_BLOB.sql"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menu_hideondays_hex.csv"

def extract_hideondays_from_dump(dump_file):
    """
    Extract dish IDs and hex-encoded hideOnDays BLOB from SQL dump.
    
    Returns:
        list of tuples: [(id, hideondays_hex), ...]
    """
    print(f"Reading dump file: {dump_file}")
    
    with open(dump_file, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Find all rows that look like: (id, ..., 0x..., ...)
    # The hideOnDays hex BLOB appears near the end of each row
    # Pattern: Look for opening paren, capture first number (ID), then find last hex value before closing paren
    
    # First, find the INSERT INTO line and extract the full VALUES section
    lines = content.split('\n')
    data_lines = []
    in_data = False
    
    for line in lines:
        if 'INSERT INTO' in line and 'VALUES' in line:
            in_data = True
            # Extract the part after VALUES
            parts = line.split('VALUES', 1)
            if len(parts) > 1:
                data_lines.append(parts[1])
        elif in_data:
            data_lines.append(line)
    
    if not data_lines:
        raise ValueError("No INSERT INTO VALUES statement found")
    
    full_data = ''.join(data_lines)
    
    # Now split by ),( to get individual rows
    # Remove leading ( and trailing );
    full_data = full_data.strip()
    if full_data.startswith('('):
        full_data = full_data[1:]
    if full_data.endswith(');'):
        full_data = full_data[:-2]
    elif full_data.endswith(')'):
        full_data = full_data[:-1]
    
    # Split into rows
    rows = full_data.split('),(')
    
    print(f"Found {len(rows)} rows in dump")
    
    results = []
    hex_pattern = re.compile(r'(0x[0-9A-Fa-f]+)')
    
    for i, row in enumerate(rows, 1):
        # Find all hex values in this row
        hex_matches = hex_pattern.findall(row)
        
        if not hex_matches:
            print(f"WARNING: Row {i} has no hex BLOB data, skipping")
            continue
        
        # Extract dish ID (first number in the row)
        id_match = re.match(r'^(\d+)', row)
        if not id_match:
            print(f"WARNING: Row {i} has no ID at start, skipping")
            continue
        
        dish_id = id_match.group(1)
        
        # The hideOnDays BLOB should be the last hex value in the row
        # (or close to last - there might be other values after it)
        hideondays_hex = hex_matches[-1]
        
        results.append((dish_id, hideondays_hex))
        
        if i % 100 == 0:
            print(f"Processed {i} rows...")
    
    print(f"Successfully extracted {len(results)} dish hideOnDays records")
    
    return results

def save_to_csv(data, output_file):
    """
    Save extracted data to CSV.
    
    Args:
        data: list of tuples [(id, hideondays_hex), ...]
        output_file: path to output CSV file
    """
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    print(f"Writing to CSV: {output_file}")
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        
        # Write header (lowercase to match PostgreSQL)
        writer.writerow(['id', 'hideondays_hex'])
        
        # Write data
        for row in data:
            writer.writerow(row)
    
    print(f"CSV file created successfully with {len(data)} rows")

def main():
    """Main execution function."""
    print("=" * 70)
    print("Phase 4.1: Extract hideOnDays BLOB to CSV")
    print("=" * 70)
    print()
    
    try:
        # Extract data from dump
        data = extract_hideondays_from_dump(DUMP_FILE)
        
        # Save to CSV
        save_to_csv(data, OUTPUT_CSV)
        
        print()
        print("=" * 70)
        print("SUCCESS: hideOnDays BLOB data extracted to CSV")
        print("=" * 70)
        print(f"Output file: {OUTPUT_CSV}")
        print(f"Total records: {len(data)}")
        print()
        print("Next step: Run phase4_1_deserialize_hideondays.py")
        
    except Exception as e:
        print()
        print("=" * 70)
        print(f"ERROR: {e}")
        print("=" * 70)
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())


