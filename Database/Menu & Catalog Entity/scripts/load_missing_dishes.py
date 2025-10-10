#!/usr/bin/env python3
"""
Load missing menu dishes CSV into staging.menuca_v1_menu_full
"""
import csv
import os
from pathlib import Path

# Get Supabase connection details from environment
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
    print("❌ Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
    exit(1)

# Use supabase-py client
try:
    from supabase import create_client, Client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
except ImportError:
    print("❌ Error: supabase package not installed. Run: pip install supabase")
    exit(1)

# Path to CSV file
CSV_FILE = Path(__file__).parent.parent / "CSV" / "missed_menu_files.csv"

print("=" * 70)
print("Loading Missing Menu Dishes into staging.menuca_v1_menu_full")
print("=" * 70)
print(f"CSV File: {CSV_FILE}")

# Read and process CSV
rows_to_insert = []
with open(CSV_FILE, 'r', encoding='utf-8') as f:
    # CSV is semicolon-delimited
    reader = csv.DictReader(f, delimiter=';')
    
    for row in reader:
        # Convert NULL strings to None
        processed_row = {}
        for key, value in row.items():
            if value == 'NULL' or value == '':
                processed_row[key] = None
            else:
                processed_row[key] = value
        
        # Add source_type to indicate this is from menu table
        processed_row['source_type'] = 'menu'
        rows_to_insert.append(processed_row)

print(f"✓ Read {len(rows_to_insert)} rows from CSV")

# Insert in batches of 500 to avoid timeout
BATCH_SIZE = 500
total_inserted = 0
errors = []

for i in range(0, len(rows_to_insert), BATCH_SIZE):
    batch = rows_to_insert[i:i+BATCH_SIZE]
    try:
        # Insert into staging.menuca_v1_menu_full
        # Use upsert to avoid duplicates (on conflict do update)
        response = supabase.table('menuca_v1_menu_full') \
            .upsert(batch, on_conflict='id', schema='staging') \
            .execute()
        
        total_inserted += len(batch)
        print(f"  ✓ Inserted batch {i//BATCH_SIZE + 1}: {len(batch)} rows (total: {total_inserted})")
        
    except Exception as e:
        error_msg = f"❌ Error inserting batch {i//BATCH_SIZE + 1}: {str(e)}"
        print(error_msg)
        errors.append(error_msg)

print("=" * 70)
print(f"✓ Successfully inserted {total_inserted} rows")
if errors:
    print(f"⚠️  {len(errors)} errors occurred")
    for err in errors:
        print(f"   {err}")
else:
    print("✓ No errors!")
print("=" * 70)

