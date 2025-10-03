#!/usr/bin/env python3
"""
Fix bulk INSERT generation - proper VALUES extraction
"""

import re

print("="*80)
print("  Fix Bulk INSERT Generation")
print("="*80)
print()

# Read the original INSERT statements file
input_file = "Database/Restaurant Management Entity/restaurant admins/step1b_insert_statements.sql"

print(f"[READ] {input_file}")
with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

print("[OK] File read")
print()

# Extract all INSERT statements
print("[PARSE] Extracting INSERT statements...")
insert_pattern = r'INSERT INTO staging\.v1_restaurant_admin_users \([^)]+\) VALUES \(([^;]+)\);'
matches = re.findall(insert_pattern, content, re.DOTALL)

print(f"[OK] Found {len(matches)} INSERT statements")
print()

# Generate bulk INSERT
print("[GEN] Generating bulk INSERT...")

output = []
output.append("-- Step 1b: Bulk Load All 493 Records (FIXED)")
output.append("-- Generated for Supabase MCP execution")
output.append("")
output.append("BEGIN;")
output.append("")
output.append("TRUNCATE TABLE staging.v1_restaurant_admin_users;")
output.append("")
output.append("INSERT INTO staging.v1_restaurant_admin_users (")
output.append("    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,")
output.append("    password_hash, lastlogin, login_count, active_user, send_statement,")
output.append("    created_at, updated_at")
output.append(") VALUES")

# Add VALUES clauses
values_lines = []
for i, values in enumerate(matches):
    # Clean up the values
    values_clean = values.strip()
    if i < len(matches) - 1:
        values_lines.append(f"    ({values_clean}),")
    else:
        values_lines.append(f"    ({values_clean});")

output.extend(values_lines)

output.append("")
output.append("COMMIT;")
output.append("")
output.append("-- Verification")
output.append("SELECT COUNT(*) AS total FROM staging.v1_restaurant_admin_users;")
output.append("SELECT COUNT(*) AS restaurant_admins FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id > 0;")
output.append("SELECT COUNT(*) AS global_admins FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id = 0;")

# Write
output_file = "Database/Restaurant Management Entity/restaurant admins/step1b_bulk_insert_fixed.sql"
with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(output))

print(f"[OK] Generated: {output_file}")
print()

# Verify unique records
print("[VERIFY] Checking for duplicates...")
legacy_ids = []
for values in matches:
    # Extract first field (legacy_admin_id)
    first_field = values.strip().split(',')[0].strip()
    legacy_ids.append(first_field)

unique_ids = set(legacy_ids)
print(f"  Total records: {len(legacy_ids)}")
print(f"  Unique IDs: {len(unique_ids)}")

if len(legacy_ids) == len(unique_ids):
    print("  [OK] No duplicates found!")
else:
    print(f"  [WARN] {len(legacy_ids) - len(unique_ids)} duplicates found")

# Show sample IDs
print(f"\n  Sample IDs: {', '.join(list(legacy_ids)[:10])}")

print()
print("="*80)
print(" READY TO EXECUTE")
print("="*80)
print(f" File: {output_file}")
print(f" Records: {len(matches)}")
print("="*80)

