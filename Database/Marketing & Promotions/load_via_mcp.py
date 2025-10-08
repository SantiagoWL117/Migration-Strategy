#!/usr/bin/env python3
"""
Load extracted SQL files into staging via Supabase Python client
Note: This simulates what would be done via Supabase MCP execute_sql
"""

from pathlib import Path
import json

STAGING_INSERTS_DIR = Path(__file__).parent / "staging_inserts_fixed"

# Files to load in order
LOAD_FILES = [
    "staging_v1_deals_load.sql",
    "staging_v1_coupons_load.sql",
    "staging_v2_restaurants_deals_load.sql",
]


def prepare_sql_for_loading(sql_file: Path) -> dict:
    """Prepare SQL file for loading - extract just the INSERT statement"""
    print(f"\n📥 Preparing {sql_file.name}...")
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract just the INSERT statement (lines after "INSERT INTO" up to semicolon)
    lines = content.split('\n')
    
    # Find INSERT line
    insert_start = None
    for i, line in enumerate(lines):
        if line.startswith('INSERT INTO'):
            insert_start = i
            break
    
    if insert_start is None:
        print(f"   ❌ No INSERT found")
        return None
    
    # Collect all lines from INSERT to first semicolon
    sql_lines = []
    for line in lines[insert_start:]:
        sql_lines.append(line)
        if line.rstrip().endswith(';'):
            break
    
    insert_sql = '\n'.join(sql_lines)
    
    print(f"   📊 INSERT statement: {len(insert_sql):,} bytes")
    print(f"   📄 Lines: {len(sql_lines)}")
    
    # Count number of value tuples (rough estimate)
    value_count = insert_sql.count('),(')
    print(f"   🔢 Estimated rows: {value_count + 1}")
    
    return {
        'file': sql_file.name,
        'sql': insert_sql,
        'size': len(insert_sql),
        'rows_estimate': value_count + 1
    }


def main():
    """Prepare all SQL files for loading"""
    print("🎯 Prepare SQL Files for Supabase MCP Loading")
    print("="*70)
    
    prepared = []
    
    for filename in LOAD_FILES:
        filepath = STAGING_INSERTS_DIR / filename
        
        if not filepath.exists():
            print(f"\n⚠️  {filename} not found!")
            continue
        
        result = prepare_sql_for_loading(filepath)
        if result:
            prepared.append(result)
    
    print(f"\n{'='*70}")
    print(f"📊 Summary: {len(prepared)} files prepared")
    print("="*70)
    
    # Show summary
    for item in prepared:
        print(f"\n{item['file']}:")
        print(f"  Size: {item['size']:,} bytes")
        print(f"  Rows: ~{item['rows_estimate']}")
    
    print(f"\n💡 Next: Execute these SQL statements via Supabase MCP execute_sql")
    print("   Files are in: staging_inserts_fixed/")
    
    # Write execution script
    exec_script = Path(__file__).parent / "execute_all_loads.sh"
    with open(exec_script, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("# Execute all staging loads via Supabase MCP\n\n")
        for item in prepared:
            f.write(f"echo 'Loading {item['file']}...'\n")
            f.write(f"# supabase db execute --file staging_inserts_fixed/{item['file']}\n\n")
    
    print(f"📝 Execution script written to: {exec_script.name}")


if __name__ == "__main__":
    main()
