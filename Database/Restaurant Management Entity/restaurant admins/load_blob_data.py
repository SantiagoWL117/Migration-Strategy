#!/usr/bin/env python3
# Load BLOB data from V1 dump into staging table

import re
import psycopg2
import os
import sys

DB_URL = os.getenv('SUPABASE_DB_URL')

if not DB_URL:
    print("ERROR: SUPABASE_DB_URL environment variable not set")
    sys.exit(1)

print("=" * 80)
print("  Load BLOB Data from V1 Dump to Staging Table")
print("=" * 80)
print()

# Read V1 dump
dump_file = "dumps/menuca_v1_restaurant_admins.sql"
print(f"[1/4] Reading V1 dump: {dump_file}")

with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

print("[OK] File loaded")
print()

# Extract INSERT statement
print("[2/4] Parsing INSERT statement...")
match = re.search(r"INSERT INTO `restaurant_admins` VALUES (.+);", content, re.DOTALL)

if not match:
    print("ERROR: Could not find INSERT statement")
    sys.exit(1)

values_block = match.group(1).strip()
print("[OK] INSERT statement found")
print()

# Split records
print("[3/4] Splitting records...")
records = re.split(r'\),\(', values_block)

# Clean first and last records
records[0] = records[0].lstrip('(')
records[-1] = records[-1].rstrip(');')

print(f"[OK] Found {len(records)} records")
print()

# Parse BLOB data (field index 11)
print("[4/4] Extracting BLOB data and updating staging table...")
conn = psycopg2.connect(DB_URL)
cursor = conn.cursor()

updated = 0
skipped = 0

for record in records:
    # Split by comma, but be careful with quoted strings and BLOBs
    # Field 0: id
    # Field 11: allowed_restaurants (BLOB)
    
    # Extract ID (first field)
    id_match = re.match(r'^(\d+),', record)
    if not id_match:
        continue
    
    legacy_id = int(id_match.group(1))
    
    # Extract BLOB (field 11) - it's after 10 commas and before field 12
    # The BLOB starts with _binary ' and ends with '
    blob_match = re.search(r"_binary '([^']*(?:''[^']*)*)'", record)
    
    if blob_match:
        blob_hex = blob_match.group(1)
        
        # Convert escaped quotes
        blob_hex = blob_hex.replace("''", "'")
        
        # Convert to bytes
        blob_bytes = blob_hex.encode('latin-1')
        
        # Update staging table
        try:
            cursor.execute("""
                UPDATE staging.v1_restaurant_admin_users
                SET allowed_restaurants = %s
                WHERE legacy_admin_id = %s
            """, (blob_bytes, legacy_id))
            
            if cursor.rowcount > 0:
                updated += 1
                if updated % 50 == 0:
                    print(f"  Updated {updated} records...")
            
        except Exception as e:
            print(f"  ERROR updating record {legacy_id}: {e}")
            skipped += 1
    else:
        # No BLOB data for this record
        skipped += 1

conn.commit()
print(f"[OK] Updated {updated} records with BLOB data")
print(f"      Skipped {skipped} records (no BLOB data)")
print()

cursor.close()
conn.close()

print("[SUCCESS] BLOB data loaded into staging table")
print()

