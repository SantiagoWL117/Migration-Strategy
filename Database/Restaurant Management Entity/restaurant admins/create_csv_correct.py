#!/usr/bin/env python3
"""
Create CSV for Supabase import - Using PROVEN parser logic
"""

import re
import csv

print("="*80)
print("  Create CSV for Supabase Import (Correct Version)")
print("="*80)
print()

# Read dump
dump_file = "dumps/menuca_v1_restaurant_admins.sql"
print("[1/4] Reading dump file...")

with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print("[OK] File loaded")
print()

# Find the INSERT statement
print("[2/4] Finding INSERT statement...")
match = re.search(r"INSERT INTO `restaurant_admins` VALUES (.+);", content, re.DOTALL)

if not match:
    print("[ERROR] No INSERT found")
    exit(1)

values_block = match.group(1).strip()
print(f"[OK] INSERT block found")
print()

# Split by "),(
print("[3/4] Splitting records...")
records = re.split(r'\),\(', values_block)

# Clean first and last
if records:
    records[0] = records[0].lstrip('(')
    records[-1] = records[-1].rstrip(')')

print(f"[OK] Found {len(records)} records")
print()

# Parse each record to CSV
print("[4/4] Parsing fields...")

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

csv_rows = []
processed = 0
skipped = 0

for idx, record in enumerate(records):
    try:
        # Field mapping (from proven parser):
        # 0=id, 1=admin_user_id, 2=password, 3=fname, 4=lname, 5=email,
        # 6=user_type, 7=restaurant, 8=lastlogin, 9=activeUser, 10=loginCount
        # 11=BLOB (skipped), 12=created_at, 13=updated_at
        
        fields = []
        current = ""
        in_quote = False
        escaped = False
        comma_count = 0
        
        for i, char in enumerate(record):
            if escaped:
                current += char
                escaped = False
                continue
            
            if char == '\\':
                current += char
                escaped = True
                continue
            
            if char == "'":
                in_quote = not in_quote
                current += char
                continue
            
            if char == ',' and not in_quote:
                fields.append(current.strip())
                current = ""
                comma_count += 1
                # We need fields 0-10, then skip BLOB, then get 12-13
                # Stop after 14 commas to get fields 0-13
                if comma_count >= 13:
                    # After 13 commas, current field is field 13 (updated_at)
                    break
                continue
            
            current += char
        
        # Add last field (updated_at)
        if current:
            fields.append(current.strip())
        
        if len(fields) < 13:
            skipped += 1
            continue
        
        # Extract fields
        legacy_id = fields[0].strip()
        restaurant_id = fields[7].strip()  # restaurant at index 7
        fname = fields[3].strip().strip("'").replace("''", "'")
        lname = fields[4].strip().strip("'").replace("''", "'")
        email = fields[5].strip().strip("'").replace("''", "'")
        password = fields[2].strip().strip("'").replace("''", "'")
        lastlogin = fields[8].strip().strip("'").replace("''", "'")
        active_user = fields[9].strip().strip("'").replace("''", "'")
        login_count = fields[10].strip()
        # Skip field 11 (BLOB)
        created_at = fields[12].strip().strip("'").replace("''", "'") if len(fields) > 12 and fields[12].strip().upper() != 'NULL' else ''
        updated_at = fields[13].strip().strip("'").replace("''", "'") if len(fields) > 13 and fields[13].strip().upper() != 'NULL' else ''
        
        # send_statement is always 'n' for all records
        send_statement = 'n'
        
        csv_rows.append([
            legacy_id,
            restaurant_id,
            fname,
            lname,
            email,
            password,
            lastlogin if lastlogin.upper() != 'NULL' else '',
            login_count,
            active_user,
            send_statement,
            created_at,
            updated_at
        ])
        processed += 1
        
        if processed % 50 == 0:
            print(f"  Processed {processed} records...", end='\r')
    
    except Exception as e:
        print(f"\n  [ERROR] Record {idx+1}: {str(e)[:100]}")
        skipped += 1

print(f"\n[OK] Processed {processed} records")
if skipped > 0:
    print(f"[WARN] Skipped {skipped} records")
print()

# Write CSV
output_file = "CSV/v1_restaurant_admins_for_import.csv"
print(f"[WRITE] Creating {output_file}...")

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(csv_header)
    writer.writerows(csv_rows)

print(f"[OK] CSV file created")
print()

print("="*80)
print("  SUMMARY")
print("="*80)
print(f"  Total records: {processed}")
print(f"  Output file:   {output_file}")
print(f"  Columns:       {len(csv_header)}")
print("="*80)
print()
print("[READY] CSV file ready for Supabase import!")
print()
print("[NEXT STEPS]")
print("   1. Go to: https://supabase.com/dashboard")
print("   2. Navigate to: Table Editor -> staging.v1_restaurant_admin_users")
print("   3. Click: 'Insert' dropdown -> 'Import data from CSV'")
print("   4. Upload: Database/Restaurant Management Entity/restaurant admins/CSV/v1_restaurant_admins_for_import.csv")
print("   5. Verify column mapping")
print("   6. Click 'Import'")
print("   7. Expected: 493 records loaded")

