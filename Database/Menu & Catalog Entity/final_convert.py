#!/usr/bin/env python3
"""
Final MySQL to PostgreSQL conversion
Handles massive single-line INSERT statements
"""

import os
import re

# Source dumps directory
dumps_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/dumps"

# Output directory
output_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg"
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
    """Convert MySQL dump to PostgreSQL format - line by line"""
    source_path = os.path.join(dumps_dir, source_file)
    output_file = source_file.replace(".sql", "_final_pg.sql")
    output_path = os.path.join(output_dir, output_file)
    
    print(f"Converting {source_file} → {output_file}")
    
    insert_count = 0
    
    with open(source_path, 'r', encoding='utf-8', errors='ignore') as infile:
        with open(output_path, 'w', encoding='utf-8') as outfile:
            # Write header
            outfile.write(f"-- Converted from MySQL to PostgreSQL\n")
            outfile.write(f"-- Source: {source_file}\n")
            outfile.write(f"-- Target: {target_table}\n\n")
            
            for line in infile:
                # Check if this is an INSERT statement
                if line.startswith("INSERT INTO"):
                    # Extract the VALUES part
                    # MySQL format: INSERT INTO `table_name` VALUES (...);
                    match = re.match(r"INSERT INTO `[^`]+` VALUES (.+);", line)
                    
                    if match:
                        values_part = match.group(1)
                        
                        # Remove _binary keyword
                        values_part = values_part.replace("_binary ", "")
                        
                        # Write PostgreSQL INSERT
                        outfile.write(f"INSERT INTO {target_table} VALUES {values_part};\n")
                        insert_count += 1
    
    print(f"  ✅ Wrote {insert_count} INSERT statements to {output_file}")

# Convert all files
print("=" * 60)
print("Final MySQL → PostgreSQL Conversion")
print("=" * 60)

for source_file, target_table in files_to_convert:
    convert_file(source_file, target_table)

print("\n" + "=" * 60)
print("✅ Conversion complete!")
print(f"📁 Output directory: {output_dir}")
print("=" * 60)

