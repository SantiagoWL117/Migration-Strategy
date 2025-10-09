#!/usr/bin/env python3
"""
FINAL WORKING SOLUTION: Read line 51 directly (no regex), then split and convert.
"""

import re
from pathlib import Path

def parse_final(dump_file, output_dir, batch_size=50):
    """Read line 51 directly, split, then convert."""
    
    print(f"Reading: {dump_file}")
    with open(dump_file, 'r', encoding='latin1') as f:
        lines = f.readlines()
    
    # Line 51 (index 50) contains the INSERT
    line51 = lines[50]
    print(f"Line 51 length: {len(line51):,} chars")
    
    # Extract just the VALUES part
    # Format: INSERT INTO `tablets` VALUES (...);
    start_idx = line51.find('VALUES ') + 7
    end_idx = line51.rfind(');')
    
    raw_values = line51[start_idx:end_idx+1]
    print(f"VALUES content: {len(raw_values):,} chars")
    print(f"Found {raw_values.count('),(')} row separators")
    
    # Split on ),( in raw data
    print("\\nSplitting rows...")
    parts = raw_values.split('),(')
    print(f"Split into {len(parts)} parts")
    
    # Convert binary in each row
    print("Converting _binary fields...")
    
    def to_hex(m):
        return f"E'\\\\x{m.group(1).encode('latin1').hex()}'"
    
    rows = []
    for i, part in enumerate(parts):
        # Convert binary
        converted = re.sub(r"_binary '((?:[^'\\\\]|\\\\.|'')*?)'", to_hex, part)
        
        # Add parentheses
        if i == 0:
            rows.append(converted + ')')
        elif i == len(parts) - 1:
            rows.append('(' + converted)
        else:
            rows.append('(' + converted + ')')
    
    print(f"Converted {len(rows)} rows")
    
    # Verify sample IDs
    print("\\nSample IDs:")
    for idx in [0, 1, 10, 100, 500, 893]:
        if idx < len(rows):
            id_match = re.search(r'^\((\d+),', rows[idx])
            if id_match:
                print(f"  Row {idx}: ID={id_match.group(1)}")
    
    # Write output
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / "v1_tablets_FINAL.sql"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- PostgreSQL INSERT for staging.v1_tablets\\n")
        f.write("-- Source: menuca_v1_tablets.sql\\n")
        f.write(f"-- Total rows: {len(rows)}\\n")
        f.write(f"-- Batch size: {batch_size}\\n")
        f.write("--\\n")
        f.write("-- Load each batch via Supabase MCP mcp_supabase_execute_sql\\n")
        f.write("-- Verify after: SELECT COUNT(*) FROM staging.v1_tablets;\\n\\n")
        
        for batch_idx in range(0, len(rows), batch_size):
            batch = rows[batch_idx:batch_idx + batch_size]
            batch_num = (batch_idx // batch_size) + 1
            first_id = batch_idx + 1
            last_id = min(batch_idx + batch_size, len(rows))
            
            f.write(f"-- ========================================\\n")
            f.write(f"-- Batch {batch_num}: Rows {first_id}-{last_id}\\n")
            f.write(f"-- ========================================\\n")
            f.write("INSERT INTO staging.v1_tablets\\n")
            f.write("(id, designator, key, restaurant, printing, config_edit, v2, fw_ver, sw_ver,\\n")
            f.write(" desynced, last_boot, last_check, created_at, modified_at)\\n")
            f.write("VALUES\\n")
            f.write(",\\n".join(batch))
            f.write(";\\n\\n")
    
    print(f"\\n{'='*60}")
    print(f"✅ OUTPUT: {output_file}")
    print(f"✅ ROWS: {len(rows)}")
    print(f"✅ BATCHES: {(len(rows) + batch_size - 1) // batch_size}")
    print(f"{'='*60}")
    
    if len(rows) == 894:
        print("\\n🎉🎉🎉 SUCCESS! All 894 rows extracted and converted!")
        print("\\n📋 NEXT STEPS:")
        print("1. Review the output file")
        print("2. Load batch 1 via Supabase MCP (test)")
        print("3. If successful, load remaining batches")
        print("4. Verify: SELECT COUNT(*) FROM staging.v1_tablets;")
        print("5. Should return: 894")
        return True
    else:
        print(f"\\n⚠️  Expected 894, got {len(rows)}")
        return False

def main():
    script_dir = Path(__file__).parent
    dump_file = script_dir / "menuca_v1_tablets.sql"
    output_dir = script_dir / "FINAL"
    
    if not dump_file.exists():
        print(f"ERROR: {dump_file} not found")
        return 1
    
    success = parse_final(dump_file, output_dir, batch_size=50)
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())

