#!/usr/bin/env python3
"""
Extract INSERT statements from MySQL dumps (handles very large single-line INSERTs)
"""

import re
from pathlib import Path

DUMP_DIR = Path(__file__).parent / "dumps"
OUTPUT_DIR = Path(__file__).parent / "staging_inserts_fixed"
OUTPUT_DIR.mkdir(exist_ok=True)

# Files to process
DUMPS = [
    ("menuca_v1_deals.sql", "staging.v1_deals"),
    ("menuca_v1_coupons.sql", "staging.v1_coupons"),
    ("menuca_v2_restaurants_deals.sql", "staging.v2_restaurants_deals"),
]


def extract_insert_statement(dump_file: Path) -> str | None:
    """Extract INSERT statement from MySQL dump - handles massive single-line INSERTs"""
    print(f"📖 Processing {dump_file.name}...")
    
    if not dump_file.exists():
        print(f"   ⚠️  File not found")
        return None
    
    # Read entire file (even if INSERT is on one massive line)
    with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print(f"   📄 File size: {len(content):,} bytes")
    
    # Find INSERT INTO statement
    # Pattern: INSERT INTO `table` VALUES (...);
    # Use non-greedy match and handle BLOB data
    match = re.search(
        r"INSERT INTO `\w+` VALUES\s+(.+?);(?:\s*!|$)",
        content,
        re.DOTALL | re.MULTILINE
    )
    
    if not match:
        # Try simpler pattern
        match = re.search(r"INSERT INTO `\w+` VALUES\s+(.+)$", content, re.DOTALL | re.MULTILINE)
        if match:
            values_clause = match.group(1).rstrip(';').rstrip()
        else:
            print(f"   ❌ No INSERT found")
            return None
    else:
        values_clause = match.group(1)
    
    print(f"   ✅ Found INSERT: {len(values_clause):,} chars")
    return values_clause


def convert_mysql_to_postgres(values_clause: str) -> str:
    """Convert MySQL INSERT VALUES to PostgreSQL format"""
    result = values_clause
    
    # Handle MySQL escape sequences
    result = result.replace(r"\'", "''")  # \' -> ''
    result = result.replace(r'\"', '"')    # \" -> "
    result = result.replace(r"\\", "\\")   # \\ -> \
    
    # Convert BLOB hex format: _binary 'hex' or 0xHEX -> decode('hex', 'hex')
    result = re.sub(r"_binary\s+'([^']+)'", r"'\1'", result)  # Keep as text for now
    result = re.sub(r"_binary\s+0x([0-9a-fA-F]+)", r"decode('\1', 'hex')", result)
    
    return result


def generate_load_sql(dump_filename: str, table_name: str):
    """Generate PostgreSQL INSERT statement"""
    dump_file = DUMP_DIR / dump_filename
    
    values = extract_insert_statement(dump_file)
    if not values:
        return False
    
    # Convert to PostgreSQL
    pg_values = convert_mysql_to_postgres(values)
    
    # Generate SQL
    sql = f"""-- Load {dump_filename} into {table_name}
-- Generated from MySQL dump
-- File size: {len(pg_values):,} characters

INSERT INTO {table_name} VALUES
{pg_values}
ON CONFLICT (id) DO NOTHING;

-- Verification
SELECT COUNT(*) as row_count FROM {table_name};
"""
    
    # Write to file
    output_file = OUTPUT_DIR / f"{table_name.replace('.', '_')}_load.sql"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print(f"   💾 Written to {output_file.name} ({len(sql):,} bytes)")
    return True


def main():
    """Process all dumps"""
    print("🎯 Extracting INSERT statements (FIXED for large files)")
    print("="*70)
    
    success_count = 0
    for dump_filename, table_name in DUMPS:
        if generate_load_sql(dump_filename, table_name):
            success_count += 1
        print()
    
    print("="*70)
    print(f"✅ Extraction complete! {success_count}/{len(DUMPS)} files processed")
    print(f"📁 Output files in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
