#!/usr/bin/env python3
"""
Extract INSERT statements from MySQL dumps and convert to PostgreSQL format
Generates separate SQL files for loading into staging
"""

import re
from pathlib import Path

DUMP_DIR = Path(__file__).parent / "dumps"
OUTPUT_DIR = Path(__file__).parent / "staging_inserts"
OUTPUT_DIR.mkdir(exist_ok=True)

# Mapping: dump file -> (staging table, special handling)
DUMPS = [
    ("menuca_v1_deals.sql", "staging.v1_deals", True),  # Has BLOBs
    ("menuca_v1_coupons.sql", "staging.v1_coupons", False),
    ("menuca_v2_restaurants_deals.sql", "staging.v2_restaurants_deals", True),  # Has JSON
    ("menuca_v2_restaurants_deals_splits.sql", "staging.v2_restaurants_deals_splits", True),
    ("menuca_v2_restaurants_tags.sql", "staging.v2_restaurants_tags", False),
]


def extract_insert(dump_file: Path) -> str | None:
    """Extract INSERT statement from MySQL dump"""
    print(f"📖 Processing {dump_file.name}...")
    
    if not dump_file.exists():
        print(f"   ⚠️  File not found")
        return None
    
    with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Find INSERT INTO statement
    match = re.search(r"INSERT INTO `\w+` VALUES (.+?);", content, re.DOTALL)
    
    if not match:
        print(f"   ⚠️  No INSERT found")
        return None
    
    values_clause = match.group(1)
    print(f"   ✅ Found INSERT with {len(values_clause)} chars")
    
    return values_clause


def convert_to_postgres(values_clause: str, has_special: bool) -> str:
    """Convert MySQL VALUES to PostgreSQL format"""
    # MySQL escape sequences -> PostgreSQL
    result = values_clause.replace(r"\'", "''")  # \' -> ''
    result = result.replace(r'\"', '"')          # \" -> "
    
    if has_special:
        # Convert BLOB hex format: 0x... -> decode('\x...')
        result = re.sub(r"0x([0-9a-fA-F]+)", r"decode('\1', 'hex')", result)
    
    return result


def generate_load_sql(dump_filename: str, table_name: str, has_special: bool):
    """Generate PostgreSQL INSERT statement"""
    dump_file = DUMP_DIR / dump_filename
    
    values = extract_insert(dump_file)
    if not values:
        return
    
    # Convert to PostgreSQL
    pg_values = convert_to_postgres(values, has_special)
    
    # Generate SQL
    sql = f"""-- Load {dump_filename} into {table_name}
-- Generated from MySQL dump

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
    
    print(f"   💾 Written to {output_file.name}")


def main():
    """Process all dumps"""
    print("🎯 Extracting INSERT statements from dumps")
    print("="*70)
    
    for dump_filename, table_name, has_special in DUMPS:
        generate_load_sql(dump_filename, table_name, has_special)
    
    print("\n✅ Extraction complete!")
    print(f"📁 Output files in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
