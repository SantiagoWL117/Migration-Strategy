#!/usr/bin/env python3
"""
Create CSV file for Supabase manual import - FIXED VERSION
Parses V1 restaurant_admins dump and creates CSV (NO BLOB data)
"""

import re
import csv

print("=" * 80)
print("  Create CSV for Supabase Import (Fixed)")
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

# Split by record separator: ),( 
# V1 structure per record: (id, restaurant, password, fname, lname, email, user_type, 
#                           send_statement, lastlogin, active_user, login_count, BLOB, created_at, updated_at)
print("[3/4] Parsing records...")
records_raw = values_section.split('),(')

# Clean up first and last
records_raw[0] = records_raw[0].lstrip('(')
records_raw[-1] = records_raw[-1].rstrip(')')

print(f"[OK] Found {len(records_raw)} records")
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
processed = 0
skipped = 0

for record in records_raw:
    try:
        # Parse using regex to handle quoted strings and BLOB data
        # Pattern: number, number,'string','string','string','string','char',num,'datetime','char',num,_binary'...',NULL|'datetime',NULL|'datetime'
        
        # More robust: split by comma but respect quotes
        parts = []
        current = ''
        in_quote = False
        in_binary = False
        depth = 0
        
        i = 0
        while i < len(record):
            char = record[i]
            
            # Handle _binary prefix
            if record[i:i+7] == '_binary':
                in_binary = True
                # Skip until we find the closing quote after the binary data
                binary_start = i
                i += 7
                while i < len(record):
                    if record[i] == "'" and not in_binary:
                        break
                    if record[i] == "'" and in_binary and record[i-1] != '\\':
                        # Check if this is the end of the binary string
                        if i + 1 < len(record) and record[i+1] in ',)':
                            i += 1
                            break
                    i += 1
                # Mark as BLOB_SKIPPED
                parts.append('BLOB_SKIPPED')
                current = ''
                i += 1
                continue
            
            if char == "'" and (i == 0 or record[i-1] != '\\'):
                in_quote = not in_quote
                current += char
            elif char == ',' and not in_quote:
                parts.append(current.strip())
                current = ''
            else:
                current += char
            
            i += 1
        
        # Add last part
        if current:
            parts.append(current.strip())
        
        if len(parts) < 14:
            skipped += 1
            continue
        
        # Extract fields (V1 order: id, restaurant, password, fname, lname, email, user_type, 
        #                          send_statement, lastlogin, active_user, login_count, BLOB, created_at, updated_at)
        legacy_admin_id = parts[0].strip()
        legacy_v1_restaurant_id = parts[1].strip()
        password_hash = parts[2].strip().strip("'").replace("''", "'")
        fname = parts[3].strip().strip("'").replace("''", "'")
        lname = parts[4].strip().strip("'").replace("''", "'")
        email = parts[5].strip().strip("'").replace("''", "'")
        # Skip user_type at parts[6]
        send_statement = parts[7].strip().strip("'")
        lastlogin = parts[8].strip().strip("'")
        active_user = parts[9].strip().strip("'")
        login_count = parts[10].strip()
        # Skip BLOB at parts[11]
        created_at = parts[12].strip().strip("'") if parts[12].strip().upper() != 'NULL' else ''
        updated_at = parts[13].strip().strip("'") if parts[13].strip().upper() != 'NULL' else ''
        
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
        processed += 1
        
    except Exception as e:
        print(f"[WARN] Error parsing record {len(csv_rows)+1}: {str(e)[:50]}")
        skipped += 1

print(f"[OK] Converted {processed} records")
if skipped > 0:
    print(f"[WARN] Skipped {skipped} records")
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
print(f"  Total records: {processed}")
print(f"  Output file:   {output_file}")
print(f"  Columns:       {len(csv_header)}")
print("=" * 80)
print()
print("[READY] Ready for Supabase import!")
print()
print("[NEXT STEPS]")
print("   1. Go to Supabase Dashboard -> Table Editor")
print("   2. Select 'staging.v1_restaurant_admin_users' table")
print("   3. Click 'Import data from CSV'")
print("   4. Upload: CSV/v1_restaurant_admins_for_import.csv")
print("   5. Verify column mapping matches")
print("   6. Click 'Import'")

