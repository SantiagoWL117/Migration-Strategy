#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Create properly formatted courses CSV file."""

import csv

# Read from the open file and write properly
with open('Database/Exports/translations/translated_courses.csv', 'r', encoding='utf-8') as infile:
    # Check if file is empty or has issues
    content = infile.read()
    print(f"Original file size: {len(content)} bytes")
    
# Since the original appears empty, let's just copy the data from the fixed file
with open('Database/Exports/translations/translated_courses_fixed.csv', 'r', encoding='utf-8') as infile:
    lines = [line.rstrip('\n\r') for line in infile if line.strip()]
    
print(f"Read {len(lines)} lines from fixed file")

# Write with proper CSV formatting
with open('Database/Exports/translations/courses_import.csv', 'w', encoding='utf-8', newline='') as outfile:
    for line in lines:
        outfile.write(line + '\n')

print(f"Written to courses_import.csv")

# Verify
with open('Database/Exports/translations/courses_import.csv', 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    count = sum(1 for row in reader)
    print(f"Verified: {count} rows (including header)")

