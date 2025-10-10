#!/usr/bin/env python3
"""Analyze all CSV files for columns exceeding VARCHAR(500)"""

import csv
from pathlib import Path

CSV_DIR = Path(__file__).parent.parent / "CSV"

print("Analyzing all CSV files for VARCHAR(500) violations...")
print("=" * 80)

violations = []

for csv_file in sorted(CSV_DIR.glob("*.csv")):
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        try:
            headers = next(reader)
        except StopIteration:
            continue
        
        # Track max length per column
        max_lens = {h: 0 for h in headers}
        
        for row in reader:
            for i, val in enumerate(row):
                if i < len(headers):
                    col_name = headers[i]
                    val_len = len(str(val))
                    if val_len > max_lens[col_name]:
                        max_lens[col_name] = val_len
        
        # Check for violations
        table_violations = [(col, max_lens[col]) for col in headers if max_lens[col] > 500]
        
        if table_violations:
            violations.append((csv_file.name, table_violations))
            print(f"\n[ISSUE] {csv_file.name}")
            for col, max_len in table_violations:
                print(f"  - {col}: {max_len} chars (exceeds 500)")
        else:
            print(f"[OK] {csv_file.name}")

print("\n" + "=" * 80)
print("\nSummary:")
if violations:
    print(f"\nFound {len(violations)} file(s) with VARCHAR(500) violations:")
    for csv_name, cols in violations:
        table_name = csv_name.replace('.csv', '')
        print(f"\n  {table_name}:")
        for col, max_len in cols:
            print(f"    ALTER TABLE staging.{table_name}")
            print(f"    ALTER COLUMN {col} TYPE TEXT;")
            print()
else:
    print("\nAll CSV files are compatible with VARCHAR(500) limits!")



