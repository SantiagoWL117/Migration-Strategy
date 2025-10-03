#!/usr/bin/env python3
"""
Fix v1_courses by removing the corrupt row 693
"""

import re

# Read the original dump
with open("dumps/menuca_v1_courses.sql", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Extract the INSERT statement
match = re.search(r'INSERT INTO `courses` VALUES (.+);', content, re.DOTALL)
if not match:
    print("❌ Could not find INSERT statement")
    exit(1)

values_part = match.group(1)

# Row 692 is the last good row: (692,'Special From Our Chef','','n',0,0,'t',0,'',90,'en',15)
# Row 693 starts the corruption: (693,'Combination Dinners 自選套餐 ','<span style=...
# We want to keep everything UP TO and INCLUDING row 692, then terminate

# Find the last occurrence of row 692
last_good_row_pattern = r",\(692,'Special From Our Chef','','n',0,0,'t',0,'',90,'en',15\)"

match_692 = re.search(last_good_row_pattern, values_part)
if not match_692:
    print("❌ Could not find row 692")
    exit(1)

# Keep everything up to and including row 692
fixed_values = values_part[:match_692.end()]

# Write the fixed version
with open("fixed/menuca_v1_courses_CLEAN.sql", "w", encoding="utf-8") as f:
    f.write("-- Fixed V1 Courses (removed corrupt row 693)\n")
    f.write("-- Target: staging.v1_courses\n\n")
    f.write(f"INSERT INTO staging.v1_courses VALUES {fixed_values};\n")

print("✅ Fixed! Corrupt row 693 removed.")
print("📝 File: fixed/menuca_v1_courses_CLEAN.sql")

# Verify
with open("fixed/menuca_v1_courses_CLEAN.sql", "r") as f:
    lines = f.readlines()
    if lines[-1].strip().endswith(';'):
        print(f"✅ File ends correctly with semicolon ({len(lines)} lines)")
    else:
        print(f"⚠️  File may not end correctly")
