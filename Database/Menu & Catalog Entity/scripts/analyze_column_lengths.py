#!/usr/bin/env python3
"""Analyze column lengths in CSV file to identify values exceeding VARCHAR(500)"""

import csv
from pathlib import Path

csv_file = Path(__file__).parent.parent / "CSV" / "menuca_v2_restaurants_combo_groups_items.csv"

with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    headers = next(reader)
    
    print(f"Analyzing: {csv_file.name}")
    print(f"Columns: {len(headers)}")
    print()
    
    # Track max length per column
    max_lens = {h: 0 for h in headers}
    max_vals = {h: '' for h in headers}
    row_nums = {h: 0 for h in headers}
    
    for row_num, row in enumerate(reader, start=2):  # Start at 2 (header is 1)
        for i, val in enumerate(row):
            if i < len(headers):
                col_name = headers[i]
                val_len = len(str(val))
                if val_len > max_lens[col_name]:
                    max_lens[col_name] = val_len
                    max_vals[col_name] = str(val)
                    row_nums[col_name] = row_num
    
    print("Column Length Analysis:")
    print("=" * 80)
    
    # Sort by length descending
    for col_name in sorted(headers, key=lambda h: max_lens[h], reverse=True):
        max_len = max_lens[col_name]
        status = "[TOO LONG]" if max_len > 500 else "[OK]"
        
        print(f"\n{col_name}:")
        print(f"  Max Length: {max_len} chars {status}")
        
        if max_len > 500:
            print(f"  Row Number: {row_nums[col_name]}")
            print(f"  Sample Value: {max_vals[col_name][:200]}...")
        elif max_len > 400:
            print(f"  [WARNING] Close to limit ({max_len}/500)")
    
    print("\n" + "=" * 80)
    print("\nColumns exceeding VARCHAR(500):")
    too_long = [col for col in headers if max_lens[col] > 500]
    if too_long:
        for col in too_long:
            print(f"  - {col}: {max_lens[col]} chars")
    else:
        print("  None")

