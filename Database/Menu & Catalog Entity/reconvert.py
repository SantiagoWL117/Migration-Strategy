#!/usr/bin/env python3
"""
Properly convert MySQL dumps to PostgreSQL
Handles full INSERT statements without truncation
"""

import re
from pathlib import Path

def extract_insert(mysql_dump):
    """Extract INSERT statement from MySQL dump"""
    # Find the INSERT INTO line
    match = re.search(r'(INSERT INTO `\w+` VALUES .+?);', mysql_dump, re.DOTALL)
    if match:
        return match.group(1)
    return None

def convert_to_postgres(insert_sql, target_table):
    """Convert MySQL INSERT to PostgreSQL format"""
    if not insert_sql:
        return None
    
    # Remove MySQL backticks from table name
    insert_sql = re.sub(r'INSERT INTO `(\w+)`', r'INSERT INTO ' + target_table, insert_sql)
    
    return insert_sql

# File mappings
MAPPINGS = {
    'menuca_v1_courses.sql': 'staging.v1_courses',
    'menuca_v1_combos.sql': 'staging.v1_combos',
    'menuca_v2_restaurants_courses.sql': 'staging.v2_restaurants_courses',
    'menuca_v2_restaurants_dishes.sql': 'staging.v2_restaurants_dishes',
    'menuca_v2_restaurants_dishes_customization.sql': 'staging.v2_restaurants_dishes_customization',
    'menuca_v2_restaurants_combo_groups.sql': 'staging.v2_restaurants_combo_groups',
    'menuca_v2_restaurants_combo_groups_items.sql': 'staging.v2_restaurants_combo_groups_items',
    'menuca_v2_restaurants_ingredient_groups.sql': 'staging.v2_restaurants_ingredient_groups',
    'menuca_v2_restaurants_ingredient_groups_items.sql': 'staging.v2_restaurants_ingredient_groups_items',
    'menuca_v2_restaurants_ingredients.sql': 'staging.v2_restaurants_ingredients',
    'menuca_v2_global_ingredients.sql': 'staging.v2_global_ingredients',
}

print("🔄 Reconverting SQL Files")
print("=" * 60)

dumps_dir = Path("dumps")
output_dir = Path("fixed")
output_dir.mkdir(exist_ok=True)

for source_file, target_table in MAPPINGS.items():
    source_path = dumps_dir / source_file
    
    if not source_path.exists():
        print(f"⚠️  {source_file} not found")
        continue
    
    print(f"📄 {source_file} → {target_table}")
    
    # Read source
    with open(source_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Extract and convert
    insert_sql = extract_insert(content)
    if not insert_sql:
        print(f"   ❌ No INSERT found")
        continue
    
    postgres_sql = convert_to_postgres(insert_sql, target_table)
    
    # Write output
    output_file = output_dir / (source_file.replace('.sql', '_fixed.sql'))
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"-- Auto-converted from MySQL to PostgreSQL\n")
        f.write(f"-- Source: {source_file}\n")
        f.write(f"-- Target: {target_table}\n\n")
        f.write(postgres_sql + "\n")
    
    # Check size
    size = len(postgres_sql)
    print(f"   ✅ {size:,} bytes → {output_file}")

print("=" * 60)
print("✅ Conversion complete!")
print("\nFiles saved to: ./fixed/")

