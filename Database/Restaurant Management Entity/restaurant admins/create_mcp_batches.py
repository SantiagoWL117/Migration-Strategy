#!/usr/bin/env python3
"""
Split the bulk INSERT into smaller batches for MCP execution
Creates multiple SQL files that can be executed sequentially
"""

import re

sql_file = "Database/Restaurant Management Entity/restaurant admins/step1b_bulk_insert_fixed.sql"

print("=" * 80)
print("  Create MCP-friendly Batches")
print("=" * 80)
print()

# Read the SQL
with open(sql_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract the VALUES section
match = re.search(r'VALUES\s+(.*?);', content, re.DOTALL)
if not match:
    print("[ERROR] Could not parse VALUES section")
    exit(1)

values_section = match.group(1)

# Split by record separator: ),\n    (
records = values_section.split('),\n    (')

# Clean up first and last records
records[0] = records[0].lstrip().lstrip('(')
records[-1] = records[-1].rstrip().rstrip(')')

print(f"[OK] Found {len(records)} records")
print()

# Create batches of 50 records each
batch_size = 50
num_batches = (len(records) + batch_size - 1) // batch_size

print(f"[INFO] Creating {num_batches} batches ({batch_size} records each)")
print()

batch_files = []

for i in range(num_batches):
    start_idx = i * batch_size
    end_idx = min((i + 1) * batch_size, len(records))
    batch_records = records[start_idx:end_idx]
    
    # Build batch SQL
    batch_sql = []
    batch_sql.append(f"-- Step 1b Batch {i+1}/{num_batches}: Records {start_idx+1}-{end_idx}")
    
    if i == 0:
        batch_sql.append("BEGIN;")
        batch_sql.append("TRUNCATE TABLE staging.v1_restaurant_admin_users;")
        batch_sql.append("")
    
    batch_sql.append("INSERT INTO staging.v1_restaurant_admin_users (")
    batch_sql.append("    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,")
    batch_sql.append("    password_hash, lastlogin, login_count, active_user, send_statement,")
    batch_sql.append("    created_at, updated_at")
    batch_sql.append(") VALUES")
    
    # Add records
    for j, record in enumerate(batch_records):
        if j < len(batch_records) - 1:
            batch_sql.append(f"    ({record}),")
        else:
            batch_sql.append(f"    ({record});")
    
    batch_sql.append("")
    
    # Only commit on last batch
    if i == num_batches - 1:
        batch_sql.append("COMMIT;")
        batch_sql.append("")
        batch_sql.append("-- Verification")
        batch_sql.append("SELECT COUNT(*) AS total FROM staging.v1_restaurant_admin_users;")
    
    # Write batch file
    batch_file = f"Database/Restaurant Management Entity/restaurant admins/step1b_mcp_batch_{i+1:02d}.sql"
    with open(batch_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(batch_sql))
    
    batch_files.append(batch_file)
    print(f"[CREATED] Batch {i+1:02d}: {len(batch_records)} records -> {batch_file}")

print()
print("=" * 80)
print(f"[DONE] Created {len(batch_files)} batch files")
print("=" * 80)
print()
print("[NEXT] Execute each batch file sequentially using Supabase MCP")

