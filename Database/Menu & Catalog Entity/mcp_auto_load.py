#!/usr/bin/env python3
"""
Automated MCP loading script - loads all batch files via Supabase MCP
"""

import os
import glob

# Directory with batch files
batch_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"

# Get all batch files sorted
batch_files = sorted(glob.glob(os.path.join(batch_dir, "*.sql")))

print("=" * 60)
print(f"📊 Found {len(batch_files)} batch files to load")
print("=" * 60)
print()

# Read each file and output the SQL for MCP
for idx, batch_file in enumerate(batch_files, 1):
    filename = os.path.basename(batch_file)
    
    with open(batch_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Extract just the INSERT statement (skip comments)
    lines = content.split('\n')
    sql_lines = [line for line in lines if not line.startswith('--') and line.strip()]
    sql = '\n'.join(sql_lines).strip()
    
    if sql:
        print(f"BATCH {idx}/{len(batch_files)}: {filename}")
        print(f"SQL_START")
        print(sql)
        print(f"SQL_END")
        print()

print("=" * 60)
print("✅ All batch SQL statements ready for MCP")
print("=" * 60)

