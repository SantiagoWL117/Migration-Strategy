"""
Phase 4.1: Extract hideOnDays BLOB Data - Simple Direct Approach
==================================================================

Extract id and hideOnDays hex BLOB from SQL dump using direct pattern matching.

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
    print("Phase 4.1: Extract hideOnDays BLOB to CSV (Simple Method)")
    print("=" * 70)
    print()
    
    print(f"Reading: {DUMP_FILE}")
    
    with open(DUMP_FILE, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    print(f"File size: {len(content):,} bytes")
    
    # Pattern to match each row: (id, ..., 0x..., ...)
    # We want to capture: row ID (first number) and last hex value
    # Pattern explanation:
    # \((\d+),  - Opening paren, capture ID, comma
    # .*?       - Any characters (non-greedy)
    # (0x[0-9A-Fa-f]+)  - Capture last hex value
    # ,'[YN]','[ny]'\)  - End pattern before closing paren (last two columns)
    
    pattern = re.compile(r'\((\d+),.*?(0x[0-9A-Fa-f]+),\'[YN]\',\'[ny]\'\)', re.DOTALL)
    
    matches = pattern.findall(content)
    
    print(f"Found {len(matches)} dish records with hideOnDays BLOB")
    
    if len(matches) == 0:
        print("\nERROR: No matches found!")
        print("Let me try a simpler pattern...")
        
        # Simpler: just find all (id, and last 0x pattern before end
        simple_pattern = re.compile(r'\((\d+),[^(]*?(0x[0-9A-Fa-f]+)[^(]*?\)', re.DOTALL)
        matches = simple_pattern.findall(content)
        print(f"Simple pattern found: {len(matches)} matches")
    
    # Create output directory
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    
    # Write to CSV
    print(f"\nWriting to: {OUTPUT_CSV}")
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'hideondays_hex'])
        
        for dish_id, hex_value in matches:
            writer.writerow([dish_id, hex_value])
    
    print(f"✓ CSV created with {len(matches)} rows")
    print()
    print("=" * 70)
    print("SUCCESS!")
    print("=" * 70)
    print(f"Output: {OUTPUT_CSV}")
    print(f"Records: {len(matches)}")
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


