#!/usr/bin/env python3
"""Quick investigation of hideOnDays column in dump"""

import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DUMP_FILE = SCRIPT_DIR.parent / "dumps" / "menuca_v1_menu.sql"

print("Reading dump file...")
with open(DUMP_FILE, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Find CREATE TABLE
create_match = re.search(
    r'CREATE TABLE.*?\((.*?)\)(?:\s+ENGINE|\s*;)',
    content,
    re.DOTALL | re.IGNORECASE
)

if create_match:
    cols = re.findall(r'`([^`]+)`', create_match.group(1))
    print(f"\nTotal columns: {len(cols)}")
    
    if 'hideOnDays' in cols:
        idx = cols.index('hideOnDays')
        print(f"\nhideOnDays at index: {idx}")
        print(f"Columns around it:")
        for i in range(max(0, idx-2), min(len(cols), idx+3)):
            print(f"  {i}: {cols[i]}")
    else:
        print("\nERROR: hideOnDays column not found!")
        print("Available columns:", cols)

# Find first INSERT and check VALUES
insert_match = re.search(r'VALUES\s+\((.*?)\)\s*[,;]', content, re.DOTALL)
if insert_match:
    values_str = insert_match.group(1)
    # Count commas to estimate fields
    print(f"\nFirst INSERT VALUES has approximately {values_str.count(',')+1} fields")
    
    # Show a sample
    print(f"\nFirst 500 chars of VALUES:")
    print(values_str[:500])

