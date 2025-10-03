#!/usr/bin/env python3
"""
Execute all SQL batches directly to staging table
Reads generated batch files and executes INSERT statements
"""

import glob
import os

print("="*80)
print("  Execute All Batches - Step 1b")
print("="*80)
print()

# Find all batch files
batch_files = sorted(glob.glob("Database/Restaurant Management Entity/restaurant admins/step1b_batch_*.sql"))

if not batch_files:
    print("[ERROR] No batch files found")
    exit(1)

print(f"[INFO] Found {len(batch_files)} batch files")
print()

# Read all INSERTs and combine
all_inserts = []
for batch_file in batch_files:
    print(f"[READ] {os.path.basename(batch_file)}")
    with open(batch_file, 'r', encoding='utf-8') as f:
        content = f.read()
        # Extract just the INSERT statements
        lines = content.split('\n')
        for line in lines:
            if line.strip().startswith('INSERT INTO'):
                # Find the full INSERT statement (multiple lines)
                idx = lines.index(line)
                insert_lines = []
                for i in range(idx, len(lines)):
                    insert_lines.append(lines[i])
                    if lines[i].strip().endswith(');'):
                        break
                all_inserts.append('\n'.join(insert_lines))

print(f"[OK] Extracted {len(all_inserts)} INSERT statements")
print()

# Generate single SQL file with all inserts as VALUES list
print("[GEN] Generating bulk INSERT file...")

output = []
output.append("-- Step 1b: Bulk Load All 493 Records")
output.append("-- Generated for Supabase MCP execution")
output.append("")
output.append("BEGIN;")
output.append("")
output.append("TRUNCATE TABLE staging.v1_restaurant_admin_users;")
output.append("")

# Combine into bulk INSERT
output.append("INSERT INTO staging.v1_restaurant_admin_users (")
output.append("    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,")
output.append("    password_hash, lastlogin, login_count, active_user, send_statement,")
output.append("    created_at, updated_at")
output.append(") VALUES")

# Parse each INSERT to extract VALUES
values_list = []
for insert in all_inserts:
    # Extract the VALUES clause
    if 'VALUES (' in insert:
        values_start = insert.index('VALUES (') + 8
        values_end = insert.rindex(');')
        values_clause = insert[values_start:values_end]
        values_list.append(f"    ({values_clause})")

# Join with commas
output.append(',\n'.join(values_list) + ';')

output.append("")
output.append("COMMIT;")
output.append("")
output.append("-- Verification")
output.append("SELECT COUNT(*) AS total FROM staging.v1_restaurant_admin_users;")
output.append("SELECT COUNT(*) AS restaurant_admins FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id > 0;")
output.append("SELECT COUNT(*) AS global_admins FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id = 0;")

# Write
output_file = "Database/Restaurant Management Entity/restaurant admins/step1b_bulk_insert.sql"
with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(output))

print(f"[OK] Generated: {output_file}")
print()
print("="*80)
print(" READY TO EXECUTE")
print("="*80)
print(f" File: {output_file}")
print(f" Records: {len(values_list)}")
print("="*80)
print()
print("[NEXT] Execute this file using Supabase MCP")

