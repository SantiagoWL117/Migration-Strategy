#!/usr/bin/env python3
"""
Execute Step 1b SQL via Supabase connection
Uses direct SQL execution
"""

import os

# Read the SQL file
sql_file = "Database/Restaurant Management Entity/restaurant admins/step1b_bulk_insert_fixed.sql"

print("=" * 80)
print("  Step 1b: Execute via Supabase MCP")
print("=" * 80)
print()

with open(sql_file, 'r', encoding='utf-8') as f:
    sql_content = f.read()

# Count INSERT statements
insert_count = sql_content.count("(")
print(f"[INFO] SQL file loaded: {len(sql_content)} characters")
print(f"[INFO] Estimated records: {insert_count // 12}")  # Rough estimate
print()

# Write SQL for Supabase execution
output_file = "temp_execute.sql"
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(sql_content)

print(f"[READY] SQL prepared: {output_file}")
print()
print("[NEXT] Execute this file using Supabase MCP execute_sql tool")
print("       Pass the complete SQL content to mcp_supabase_execute_sql")

