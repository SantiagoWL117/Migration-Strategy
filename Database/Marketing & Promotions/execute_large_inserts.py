#!/usr/bin/env python3
"""
Execute large INSERT statements via direct psql connection
Handles BLOBs and long INSERT statements
"""

import subprocess
import os
from pathlib import Path

STAGING_DIR = Path(__file__).parent / "staging_inserts"

# Remaining files to load
LARGE_INSERTS = [
    "staging_v1_deals_load.sql",
    "staging_v1_coupons_load.sql",
    "staging_v2_restaurants_deals_load.sql",
]

def execute_sql_file(sql_file: Path):
    """Execute SQL file using psql via Supabase connection"""
    print(f"\n📥 Executing {sql_file.name}...")
    
    # Read the SQL
    with open(sql_file, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # Write to temp file for psql
    temp_sql = sql_file.parent / f"temp_{sql_file.name}"
    with open(temp_sql, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"   📄 SQL file: {len(sql_content)} bytes")
    
    # For now, just show what would be executed
    # In production, would use:
    # subprocess.run(['psql', '-h', HOST, '-U', USER, '-d', DB, '-f', str(temp_sql)])
    
    # Extract and show INSERT line
    lines = sql_content.split('\n')
    for i, line in enumerate(lines, 1):
        if line.startswith('INSERT INTO'):
            insert_line_num = i
            insert_preview = line[:100] + "..." if len(line) > 100 else line
            print(f"   🔍 INSERT at line {i}: {insert_preview}")
            print(f"   📊 INSERT statement: {len(line)} characters")
            break
    
    print(f"   ✅ Ready for manual execution")
    
    # Clean up temp file
    # temp_sql.unlink(missing_ok=True)


def main():
    """Execute all large INSERT files"""
    print("🎯 Execute Large INSERT Statements")
    print("="*70)
    
    for filename in LARGE_INSERTS:
        filepath = STAGING_DIR / filename
        
        if not filepath.exists():
            print(f"\n⚠️  {filename} not found!")
            continue
        
        execute_sql_file(filepath)
    
    print(f"\n{'='*70}")
    print("✅ All files processed")
    print("\n💡 Next Step: Execute these SQL files manually via Supabase MCP")
    print("   or use psql command line to load them into staging tables")


if __name__ == "__main__":
    main()
