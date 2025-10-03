#!/usr/bin/env python3
"""
Menu & Catalog Data Loader
Converts MySQL dumps to PostgreSQL and loads into Supabase staging tables
"""

import re
import os
from pathlib import Path

# Supabase connection details
PROJECT_REF = "nthpbtdjhhnwfxqsxbvy"
ACCESS_TOKEN = "sbp_dffd84abb668062f7b8aa549d7a923a1b3b4fe30"
DB_URL = f"postgresql://postgres.[{PROJECT_REF}]:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres"

# File mappings: source_file -> target_table
V1_MAPPINGS = {
    'menuca_v1_courses.sql': 'staging.v1_courses',
    'menuca_v1_menu.sql': 'staging.v1_menu',
    'menuca_v1_menuothers.sql': 'staging.v1_menuothers',
    'menuca_v1_combo_groups.sql': 'staging.v1_combo_groups',
    'menuca_v1_combos.sql': 'staging.v1_combos',
    'menuca_v1_ingredient_groups.sql': 'staging.v1_ingredient_groups',
    'menuca_v1_ingredients.sql': 'staging.v1_ingredients',
}

V2_MAPPINGS = {
    'menuca_v2_restaurants_courses.sql': 'staging.v2_restaurants_courses',
    'menuca_v2_restaurants_dishes.sql': 'staging.v2_restaurants_dishes',
    'menuca_v2_restaurants_dishes_customization.sql': 'staging.v2_restaurants_dishes_customization',
    'menuca_v2_restaurants_combo_groups.sql': 'staging.v2_restaurants_combo_groups',
    'menuca_v2_restaurants_combo_groups_items.sql': 'staging.v2_restaurants_combo_groups_items',
    'menuca_v2_restaurants_ingredient_groups.sql': 'staging.v2_restaurants_ingredient_groups',
    'menuca_v2_restaurants_ingredient_groups_items.sql': 'staging.v2_restaurants_ingredient_groups_items',
    'menuca_v2_restaurants_ingredients.sql': 'staging.v2_restaurants_ingredients',
    'menuca_v2_custom_ingredients.sql': 'staging.v2_custom_ingredients',
    'menuca_v2_global_courses.sql': 'staging.v2_global_courses',
    'menuca_v2_global_dishes.sql': 'staging.v2_global_dishes',
    'menuca_v2_global_ingredients.sql': 'staging.v2_global_ingredients',
}


def extract_insert_statements(sql_file):
    """Extract INSERT INTO statements from MySQL dump"""
    with open(sql_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Find INSERT INTO statements
    pattern = r'INSERT INTO `\w+` VALUES (.*?);'
    matches = re.findall(pattern, content, re.DOTALL)
    
    return matches


def convert_mysql_to_postgres(insert_values, table_name):
    """
    Convert MySQL INSERT VALUES to PostgreSQL format
    
    MySQL:  INSERT INTO `table` VALUES (1,'text',NULL),(2,'text2',NULL);
    Postgres: INSERT INTO staging.table VALUES (1,'text',NULL),(2,'text2',NULL);
    """
    # The insert_values already contains the full VALUES clause
    # Just need to prepend the INSERT INTO statement
    
    # Build full INSERT statement
    sql = f"INSERT INTO {table_name} VALUES {insert_values};\n"
    
    return sql


def create_loading_sql(source_file, target_table):
    """Create a PostgreSQL-compatible SQL file from MySQL dump"""
    print(f"📄 Processing: {source_file} -> {target_table}")
    
    dump_path = Path(f"dumps/{source_file}")
    if not dump_path.exists():
        print(f"  ⚠️  File not found, skipping")
        return None
    
    # Extract INSERT statements
    insert_values_list = extract_insert_statements(dump_path)
    
    if not insert_values_list:
        print(f"  ⚠️  No INSERT statements found, skipping")
        return None
    
    print(f"  ✅ Found {len(insert_values_list)} INSERT statement(s)")
    
    # Convert to PostgreSQL format
    postgres_sql = []
    for values in insert_values_list:
        postgres_sql.append(convert_mysql_to_postgres(values, target_table))
    
    # Write to output file
    output_file = f"converted/{source_file.replace('.sql', '_postgres.sql')}"
    os.makedirs("converted", exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- Auto-converted from MySQL to PostgreSQL\n")
        f.write(f"-- Source: {source_file}\n")
        f.write(f"-- Target: {target_table}\n\n")
        f.write('\n'.join(postgres_sql))
    
    print(f"  ✅ Saved to: {output_file}")
    
    return output_file


def main():
    print("🚀 Menu & Catalog Data Loader")
    print("=" * 60)
    
    # Process V1 files
    print("\n📦 Processing V1 Tables...")
    print("-" * 60)
    for source, target in V1_MAPPINGS.items():
        create_loading_sql(source, target)
    
    # Process V2 files
    print("\n📦 Processing V2 Tables...")
    print("-" * 60)
    for source, target in V2_MAPPINGS.items():
        create_loading_sql(source, target)
    
    print("\n" + "=" * 60)
    print("✅ Conversion Complete!")
    print("\n📝 Next Steps:")
    print("1. Review converted SQL files in: ./converted/")
    print("2. Use Supabase SQL Editor to load each file")
    print("3. Or use psql to bulk load:")
    print(f"   psql {DB_URL} -f converted/FILE.sql")


if __name__ == "__main__":
    main()

