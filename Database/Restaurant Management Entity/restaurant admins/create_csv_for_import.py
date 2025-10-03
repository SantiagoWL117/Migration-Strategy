#!/usr/bin/env python3
"""
Create CSV file for Supabase manual import
Parses V1 restaurant_admins dump and creates CSV (NO BLOB data)
"""

import re
import csv

print("=" * 80)
print("  Create CSV for Supabase Import")
print("=" * 80)
print()

# Read the V1 dump file
dump_file = "dumps/menuca_v1_restaurant_admins.sql"
print(f"[1/4] Reading {dump_file}...")

with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print("[OK] File loaded")
print()

# Extract INSERT statement
print("[2/4] Extracting INSERT statement...")
match = re.search(r'INSERT INTO `restaurant_admins` VALUES (.+);', content, re.DOTALL)

if not match:
    print("[ERROR] Could not find INSERT statement")
    exit(1)

values_section = match.group(1)
print("[OK] INSERT statement found")
print()

# Split by record separator
print("[3/4] Parsing records...")
records = values_section.split('),\n(')

# Clean up first and last records
records[0] = records[0].lstrip().lstrip('(')
records[-1] = records[-1].rstrip().rstrip(')')

print(f"[OK] Found {len(records)} records")
print()

# Parse each record into CSV rows
csv_rows = []
csv_header = [
    'legacy_admin_id',
    'legacy_v1_restaurant_id', 
    'fname',
    'lname',
    'email',
    'password_hash',
    'lastlogin',
    'login_count',
    'active_user',
    'send_statement',
    'created_at',
    'updated_at'
]

print("[4/4] Converting to CSV format...")
skipped = 0

for record in records:
    # Split by comma, but be careful with quoted strings
    # V1 structure: id, restaurant, user_type, fname, lname, email, password, lastlogin, 
    #               login_count, active_user, send_statement, allowed_restaurants, created_at, updated_at
    
    # Use regex to split properly (handles quoted strings)
    parts = re.findall(r"'(?:[^']|'')*'|[^,]+", record)
    
    if len(parts) < 14:
        skipped += 1
        continue
    
    # Extract fields (excluding BLOB at index 11)
    legacy_admin_id = parts[0].strip()
    legacy_v1_restaurant_id = parts[1].strip()
    # Skip user_type (parts[2]) - not needed
    fname = parts[3].strip().strip("'").replace("''", "'")
    lname = parts[4].strip().strip("'").replace("''", "'")
    email = parts[5].strip().strip("'").replace("''", "'")
    password_hash = parts[6].strip().strip("'").replace("''", "'")
    lastlogin = parts[7].strip().strip("'").replace("''", "'")
    login_count = parts[8].strip()
    active_user = parts[9].strip().strip("'")
    send_statement = parts[10].strip().strip("'")
    # Skip BLOB at parts[11] - allowed_restaurants
    created_at = parts[12].strip().strip("'").replace("''", "'") if parts[12].strip() != 'NULL' else ''
    updated_at = parts[13].strip().strip("'").replace("''", "'") if parts[13].strip() != 'NULL' else ''
    
    csv_rows.append([
        legacy_admin_id,
        legacy_v1_restaurant_id,
        fname,
        lname,
        email,
        password_hash,
        lastlogin,
        login_count,
        active_user,
        send_statement,
        created_at,
        updated_at
    ])

print(f"[OK] Converted {len(csv_rows)} records")
if skipped > 0:
    print(f"[WARN] Skipped {skipped} malformed records")
print()

# Write CSV file
output_file = "CSV/v1_restaurant_admins_for_import.csv"
print(f"[WRITE] Creating {output_file}...")

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(csv_header)
    writer.writerows(csv_rows)

print(f"[OK] CSV file created: {output_file}")
print()

print("=" * 80)
print("  SUMMARY")
print("=" * 80)
print(f"  Total records: {len(csv_rows)}")
print(f"  Output file:   {output_file}")
print(f"  Columns:       {len(csv_header)}")
print("=" * 80)
print()
print("✅ Ready for Supabase import!")
print()
print("📋 Next Steps:")
print("   1. Go to Supabase Dashboard → Table Editor")
print("   2. Select 'staging.v1_restaurant_admin_users' table")
print("   3. Click 'Import data from CSV'")
print("   4. Upload: CSV/v1_restaurant_admins_for_import.csv")
print("   5. Verify column mapping matches")
print("   6. Click 'Import'")

