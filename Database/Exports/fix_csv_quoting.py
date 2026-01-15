#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix CSV quoting issues for PostgreSQL COPY command."""

import csv
import sys

input_file = sys.argv[1] if len(sys.argv) > 1 else 'Database/Exports/dishes_needing_translation.csv'
output_file = 'temp_import.csv'

# Read the raw file
with open(input_file, 'r', encoding='utf-8-sig') as f:
    reader = csv.reader(f)
    rows = list(reader)

# Write properly formatted CSV
with open(output_file, 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f, quoting=csv.QUOTE_ALL)
    
    for row in rows:
        if len(row) >= 2:
            writer.writerow([row[0], row[1]])

print(f"Processed {len(rows)-1} translations")
print(f"Output: {output_file}")
