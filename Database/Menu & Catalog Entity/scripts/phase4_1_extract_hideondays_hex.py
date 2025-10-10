"""
Phase 4.1: Extract hideOnDays BLOB Data from SQL Dump to CSV
============================================================

Purpose: Extract id and hex-encoded hideOnDays BLOB from the SQL dump
         and save to CSV for further processing.

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
    
    # Find the INSERT INTO statement (note: backtick escaping)
    insert_match = re.search(r'INSERT INTO `\w+` VALUES (.+);', content, re.DOTALL)
    
    if not insert_match:
        # Try without backticks
        insert_match = re.search(r'INSERT INTO \w+ VALUES (.+);', content, re.DOTALL)
    
    if not insert_match:
        raise ValueError("Could not find INSERT INTO statement in dump file")
    
    values_section = insert_match.group(1)
    
    # Split into individual rows
    # Each row is like: (id, col2, col3, ..., 0x613A32..., col_n, col_n+1)
    rows = re.split(r'\),\(', values_section)
    
    print(f"Found {len(rows)} rows in dump")
    
    results = []
    hex_pattern = re.compile(r'0x[0-9A-Fa-f]+')
    
    for i, row in enumerate(rows, 1):
        # Clean up first and last rows
        row = row.lstrip('(').rstrip(')')
        
        # Find all hex BLOB values in this row
        hex_blobs = hex_pattern.findall(row)
        
        if not hex_blobs:
            print(f"WARNING: Row {i} has no hex BLOB data, skipping")
            continue
        
        # Extract the dish ID (first column)
        # Split on comma, but be careful with commas in quoted strings
        parts = re.split(r',(?=(?:[^\']*\'[^\']*\')*[^\']*$)', row)
        
        if len(parts) < 1:
            print(f"WARNING: Row {i} could not be parsed, skipping")
            continue
        
        dish_id = parts[0].strip()
        
        # The hideOnDays BLOB should be near the end
        # Based on the schema, it's likely the last or second-to-last hex value
        hideondays_hex = hex_blobs[-1]  # Take the last hex value
        
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

