#!/usr/bin/env python3
"""
Simple V1 Parser - Extract data and load to staging via MCP
Excludes BLOB data
"""

import re

print("="*80)
print("  Step 1b: Parse V1 Data and Generate SQL")
print("="*80)
print()

# Read dump
dump_file = "Database/Restaurant Management Entity/restaurant admins/dumps/menuca_v1_restaurant_admins.sql"
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
print(f"[OK] INSERT block found ({len(values_block)} chars)")
print()

# Split by "),(
print("[3/4] Splitting records...")

# Use regex to split - match ")," followed by "(" 
# This splits between records
records = re.split(r'\),\(', values_block)

# Clean first and last
if records:
    records[0] = records[0].lstrip('(')
    records[-1] = records[-1].rstrip(')')

print(f"[OK] Found {len(records)} records")
print()

# Now parse each record
print("[4/4] Parsing fields...")

sql_lines = []
sql_lines.append("-- Step 1b: V1 restaurant_admins Data (BLOB excluded)")
sql_lines.append("-- Total records: " + str(len(records)))
sql_lines.append("")
sql_lines.append("BEGIN;")
sql_lines.append("")
sql_lines.append("TRUNCATE TABLE staging.v1_restaurant_admin_users;")
sql_lines.append("")

processed = 0
skipped = 0

for idx, record in enumerate(records):
    try:
        # The format is:
        # id,admin_user_id,password,fname,lname,email,user_type,restaurant,lastlogin,activeUser,loginCount,_binary'...',more...
        
        # Strategy: Extract first 11 fields, ignore rest (including BLOB)
        # Split by comma, but respect quoted strings
        
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
                # Stop after 11 fields (0-10) - we don't need the BLOB and beyond
                if comma_count >= 11:
                    break
                continue
            
            current += char
        
        # Add last field
        if current and comma_count < 11:
            fields.append(current.strip())
        
        if len(fields) < 11:
            print(f"  [SKIP] Record {idx+1}: Only {len(fields)} fields")
            skipped += 1
            continue
        
        # Extract needed fields
        # Fields: 0=id, 1=admin_user_id, 2=password, 3=fname, 4=lname, 5=email, 
        #         6=user_type, 7=restaurant, 8=lastlogin, 9=activeUser, 10=loginCount
        legacy_id = fields[0]
        restaurant_id = fields[7]
        fname = fields[3]
        lname = fields[4]
        email = fields[5]
        password = fields[2]
        lastlogin = fields[8]
        active_user = fields[9]
        login_count = fields[10]
        
        # Convert NULLs
        if lastlogin.upper() == 'NULL':
            lastlogin = 'NULL'
        
        # Generate INSERT
        insert = f"""INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    {legacy_id}, {restaurant_id}, {fname}, {lname}, {email},
    {password}, {lastlogin}, {login_count}, {active_user}, 'n',
    NULL, NULL
);"""
        
        sql_lines.append(insert)
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

sql_lines.append("")
sql_lines.append("COMMIT;")
sql_lines.append("")
sql_lines.append("-- Verification")
sql_lines.append("SELECT COUNT(*) FROM staging.v1_restaurant_admin_users;")
sql_lines.append("SELECT COUNT(*) FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id > 0;")
sql_lines.append("SELECT COUNT(*) FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id = 0;")

# Write
output_file = "Database/Restaurant Management Entity/restaurant admins/step1b_insert_statements.sql"
print(f"[WRITE] {output_file}...")

with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines))

print("[OK] SQL file generated")
print()
print("="*80)
print("  SUMMARY")
print("="*80)
print(f"  Total records parsed: {len(records)}")
print(f"  Successfully processed: {processed}")
print(f"  Skipped: {skipped}")
print(f"  Output: {output_file}")
print("="*80)
print()
print("[NEXT] Execute SQL using Supabase MCP")

