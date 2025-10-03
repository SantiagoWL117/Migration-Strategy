#!/usr/bin/env python3
"""
Properly convert MySQL dumps to PostgreSQL format
Handles:
- Long single-line INSERT statements
- _binary keyword removal
- Target schema conversion (staging.xxx)
"""

import os
import re

# Source dumps directory
dumps_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/dumps"

# Output directory
output_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/pg_ready"
os.makedirs(output_dir, exist_ok=True)

# Files to convert
files_to_convert = [
    ("menuca_v1_combo_groups.sql", "staging.v1_combo_groups"),
    ("menuca_v1_combos.sql", "staging.v1_combos"),
    ("menuca_v1_ingredient_groups.sql", "staging.v1_ingredient_groups"),
    ("menuca_v1_ingredients.sql", "staging.v1_ingredients"),
    ("menuca_v1_menu.sql", "staging.v1_menu"),
    ("menuca_v1_menuothers.sql", "staging.v1_menuothers"),
    ("menuca_v2_global_ingredients.sql", "staging.v2_global_ingredients"),
    ("menuca_v2_restaurants_combo_groups.sql", "staging.v2_restaurants_combo_groups"),
    ("menuca_v2_restaurants_combo_groups_items.sql", "staging.v2_restaurants_combo_groups_items"),
    ("menuca_v2_restaurants_courses.sql", "staging.v2_restaurants_courses"),
    ("menuca_v2_restaurants_dishes.sql", "staging.v2_restaurants_dishes"),
    ("menuca_v2_restaurants_dishes_customization.sql", "staging.v2_restaurants_dishes_customization"),
    ("menuca_v2_restaurants_ingredient_groups.sql", "staging.v2_restaurants_ingredient_groups"),
    ("menuca_v2_restaurants_ingredient_groups_items.sql", "staging.v2_restaurants_ingredient_groups_items"),
    ("menuca_v2_restaurants_ingredients.sql", "staging.v2_restaurants_ingredients"),
]

def convert_file(source_file, target_table):
    """Convert MySQL dump to PostgreSQL format"""
    source_path = os.path.join(dumps_dir, source_file)
    output_file = source_file.replace(".sql", "_pg.sql")
    output_path = os.path.join(output_dir, output_file)
    
    print(f"Converting {source_file} → {output_file}")
    
    with open(source_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Find INSERT INTO statements
    # MySQL format: INSERT INTO `table_name` VALUES (...),...;
    insert_pattern = r"INSERT INTO `[^`]+` VALUES (.+?);"
    matches = re.findall(insert_pattern, content, re.DOTALL)
    
    if not matches:
        print(f"  ⚠️  No INSERT statements found in {source_file}")
        return
    
    # Build PostgreSQL INSERT statements
    pg_statements = []
    for values_part in matches:
        # Remove _binary keyword
        values_part = values_part.replace("_binary ", "")
        
        # Create PostgreSQL INSERT
        pg_statement = f"INSERT INTO {target_table} VALUES {values_part};"
        pg_statements.append(pg_statement)
    
    # Write output file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(f"-- Converted from MySQL to PostgreSQL\n")
        f.write(f"-- Source: {source_file}\n")
        f.write(f"-- Target: {target_table}\n\n")
        
        for statement in pg_statements:
            f.write(statement + "\n")
    
    print(f"  ✅ Wrote {len(pg_statements)} INSERT statements to {output_file}")

# Convert all files
print("=" * 60)
print("MySQL → PostgreSQL Conversion")
print("=" * 60)

for source_file, target_table in files_to_convert:
    convert_file(source_file, target_table)

print("\n" + "=" * 60)
print("✅ Conversion complete!")
print(f"📁 Output directory: {output_dir}")
print("=" * 60)

