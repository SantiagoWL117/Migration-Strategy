#!/usr/bin/env python3
"""
Create CSV for Supabase import - CORRECTED for actual V1 schema
V1 has NO created_at/updated_at - those were added in V2!
"""

import re
import csv

print("=" * 80)
print("  Create CSV for Supabase Import (V1 Correct Schema)")
print("=" * 80)
print()

# Read dump
dump_file = "dumps/menuca_v1_restaurant_admins.sql"
print(f"[1/4] Reading {dump_file}...")

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

# V1 ACTUAL schema (NO created_at/updated_at!)
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
    'show_all_stats',
    'fb_token',
    'show_order_management',
    'send_statement',
    'send_statement_to',
    'allow_ar',
    'show_clients'
]

csv_rows = []
processed = 0
skipped = 0

for idx, record in enumerate(records):
    try:
        # V1 field order (actual):
        # 0=id, 1=admin_user_id, 2=password, 3=fname, 4=lname, 5=email,
        # 6=user_type, 7=restaurant, 8=lastlogin, 9=activeUser, 10=loginCount,
        # 11=allowed_restaurants (BLOB - skip)
        # 12=showAllStats, 13=fb_token, 14=showOrderManagement, 
        # 15=sendStatement, 16=sendStatementTo, 17=allowAr, 18=showClients
        
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
                continue
            
            current += char
        
        # Add last field
        if current:
            fields.append(current.strip())
        
        # Need at least 18 fields (0-17) plus BLOB at 11
        if len(fields) < 18:
            print(f"  [SKIP] Record {idx+1}: Only {len(fields)} fields (expected 18+)")
            skipped += 1
            continue
        
        # Extract fields
        legacy_id = fields[0].strip()
        restaurant_id = fields[7].strip()
        fname = fields[3].strip().strip("'").replace("''", "'")
        lname = fields[4].strip().strip("'").replace("''", "'")
        email = fields[5].strip().strip("'").replace("''", "'")
        password = fields[2].strip().strip("'").replace("''", "'")
        lastlogin = fields[8].strip().strip("'")
        active_user = fields[9].strip().strip("'")
        login_count = fields[10].strip()
        # Skip field 11 (BLOB - allowed_restaurants)
        show_all_stats = fields[12].strip().strip("'") if len(fields) > 12 else ''
        fb_token = fields[13].strip().strip("'").replace("''", "'") if len(fields) > 13 else ''
        show_order_management = fields[14].strip().strip("'") if len(fields) > 14 else ''
        send_statement = fields[15].strip().strip("'") if len(fields) > 15 else ''
        send_statement_to = fields[16].strip().strip("'").replace("''", "'") if len(fields) > 16 else ''
        allow_ar = fields[17].strip().strip("'") if len(fields) > 17 else ''
        show_clients = fields[18].strip().strip("'") if len(fields) > 18 else ''
        
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
            show_all_stats,
            fb_token,
            show_order_management,
            send_statement,
            send_statement_to,
            allow_ar,
            show_clients
        ])
        processed += 1
        
        if processed % 50 == 0:
            print(f"  Processed {processed} records...", end='\r')
    
    except Exception as e:
        print(f"\n  [ERROR] Record {idx+1}: {str(e)}")
        skipped += 1

print(f"\n[OK] Processed {processed} records")
if skipped > 0:
    print(f"[WARN] Skipped {skipped} records")
print()

# Write CSV
output_file = "CSV/v1_restaurant_admins_for_import_CORRECTED.csv"
print(f"[WRITE] Creating {output_file}...")

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(csv_header)
    writer.writerows(csv_rows)

print(f"[OK] CSV file created")
print()

print("=" * 80)
print("  SUMMARY")
print("=" * 80)
print(f"  Total records: {processed}")
print(f"  Output file:   {output_file}")
print(f"  Columns:       {len(csv_header)}")
print("=" * 80)
print()
print("[IMPORTANT] V1 Schema Corrections:")
print("  - V1 has NO created_at or updated_at columns")
print("  - V1 has 7 additional columns after login_count (excluding BLOB):")
print("    * showAllStats, fb_token, showOrderManagement,")
print("    * sendStatement, sendStatementTo, allowAr, showClients")
print()
print("[READY] CSV file ready for Supabase import!")

