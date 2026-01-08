"""
Migration script to create dish_modifier_groups and modifier_group_details
from V2 restaurants_dishes_customization data.

Uses psql for all CRUD operations per project guidelines.
"""

import os
import sys
import re
import json
import subprocess
from datetime import datetime
from pathlib import Path

# Add parent directories to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# =============================================================================
# Configuration
# =============================================================================

# Path to psql
PSQL_PATH = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"

# Database connection string from environment
def get_db_connection():
    """Load DB connection from .env file."""
    env_paths = [
        Path(__file__).parent.parent.parent.parent / ".env files" / ".env",
        Path(__file__).parent.parent.parent.parent / ".env",
    ]
    for env_path in env_paths:
        if env_path.exists():
            with open(env_path, 'r') as f:
                for line in f:
                    if line.startswith('DB_CONNECTION_STRING='):
                        return line.strip().split('=', 1)[1].strip('"\'')
    return os.getenv('DB_CONNECTION_STRING')

DB_CONNECTION_STRING = get_db_connection()

# V2 Restaurant mapping (legacy_v2_id -> v3_restaurant_id)
RESTAURANT_MAPPING = {
    1678: 981,   # Al-s Drive In
    1670: 973,   # Capital Bites
    1674: 977,   # Capri Pizza
    1663: 966,   # Chicco Pizza de l'Hopital
    1661: 964,   # Chicco Pizza Maloney
    1660: 963,   # Chicco Pizza Shawarma Anger
    1664: 967,   # Chicco Pizza St-Louis
    1658: 961,   # Chicco Shawarma Cantley
    1662: 965,   # Chicco Shawarma Maloney
    1654: 957,   # Cosenza
    1657: 960,   # Cuisine Bombay Indienne
    1637: 950,   # Kirkwood Pizza
    1642: 825,   # La Nawab
    1668: 971,   # Little Gyros Greek Grill
    1671: 974,   # Pachino Pizza
    1171: 147,   # Pho Dau Bo Restaurant - Kitchener
    1673: 976,   # Pizza Marie
    1639: 952,   # River Pizza
    1157: 133,   # Riverside Pizzeria
    1285: 1020,  # Sushi Presse
    1641: 954,   # Wandee Thai
}

V3_RESTAURANT_IDS = list(RESTAURANT_MAPPING.values())

# Customization type columns in order
CUSTOMIZATION_TYPES = [
    ('crust', 'crust_customization', 'crust_display_order'),
    ('custom_ingredient', 'custom_ingredient_customization', 'custom_ingredient_display_order'),
    ('premium_toppings', 'premium_toppings_customization', 'premium_toppings_display_order'),
    ('extra', 'extra_customization', 'extra_display_order'),
    ('dressing', 'dressing_customization', 'dressing_display_order'),
    ('sauce', 'sauce_customization', 'sauce_display_order'),
    ('dip', 'dip_customization', 'dip_display_order'),
    ('drink', 'drink_customization', 'drink_display_order'),
    ('side_dish', 'side_dish_customization', 'side_dish_display_order'),
    ('cook_method', 'cook_method_customization', 'cook_method_display_order'),
    ('desert', 'desert_customization', 'desert_display_order'),
]

# =============================================================================
# Database Functions (using psql)
# =============================================================================

def execute_psql_query(query):
    """Execute a query via psql and return results as list of dicts."""
    if not DB_CONNECTION_STRING:
        print("ERROR: DB_CONNECTION_STRING not found")
        return []
    
    # Write query to temp file
    temp_file = Path(__file__).parent / "temp_query.sql"
    with open(temp_file, 'w', encoding='utf-8') as f:
        f.write(query)
    
    try:
        result = subprocess.run(
            [PSQL_PATH, DB_CONNECTION_STRING, "-t", "-A", "-F", "|", "-f", str(temp_file)],
            capture_output=True, text=True, encoding='utf-8', errors='replace'
        )
        
        if result.returncode != 0:
            print(f"ERROR: {result.stderr}")
            return []
        
        # Parse output
        rows = []
        for line in result.stdout.strip().split('\n'):
            if line:
                rows.append(line.split('|'))
        return rows
    finally:
        if temp_file.exists():
            temp_file.unlink()


def execute_psql_file(sql_file_path):
    """Execute a SQL file via psql."""
    if not DB_CONNECTION_STRING:
        print("ERROR: DB_CONNECTION_STRING not found")
        return False
    
    result = subprocess.run(
        [PSQL_PATH, DB_CONNECTION_STRING, "-v", "ON_ERROR_STOP=1", "-f", str(sql_file_path)],
        capture_output=True, text=True, encoding='utf-8', errors='replace'
    )
    
    if result.returncode != 0:
        print(f"ERROR: {result.stderr}")
        print(f"STDOUT: {result.stdout}")
        return False
    
    print(result.stdout)
    return True


# =============================================================================
# Data Loading Functions
# =============================================================================

def load_v3_dish_mapping():
    """Load V3 dishes with source_id for V2 restaurants."""
    restaurant_ids = ','.join(str(r) for r in V3_RESTAURANT_IDS)
    query = f"""
    SELECT d.id, d.source_id, d.restaurant_id
    FROM menuca_v3.dishes d
    WHERE d.restaurant_id IN ({restaurant_ids})
      AND d.deleted_at IS NULL
      AND d.source_id IS NOT NULL;
    """
    
    rows = execute_psql_query(query)
    # source_id -> v3_dish_id
    mapping = {}
    for row in rows:
        if len(row) >= 3:
            v3_id, source_id, restaurant_id = int(row[0]), int(row[1]), int(row[2])
            mapping[source_id] = {'v3_id': v3_id, 'restaurant_id': restaurant_id}
    
    print(f"  Loaded {len(mapping)} V3 dishes with source_id")
    return mapping


def load_v3_modifier_group_mapping():
    """Load V3 modifier_groups with source_system for V2 restaurants."""
    restaurant_ids = ','.join(str(r) for r in V3_RESTAURANT_IDS)
    query = f"""
    SELECT mg.id, mg.source_system, mg.restaurant_id, mg.name
    FROM menuca_v3.modifier_groups mg
    WHERE mg.restaurant_id IN ({restaurant_ids})
      AND mg.deleted_at IS NULL
      AND mg.source_system IS NOT NULL;
    """
    
    rows = execute_psql_query(query)
    # (restaurant_id, source_system) -> v3_modifier_group_id
    mapping = {}
    for row in rows:
        if len(row) >= 4:
            v3_id, source_system, restaurant_id, name = int(row[0]), row[1], int(row[2]), row[3]
            mapping[(restaurant_id, source_system)] = {'v3_id': v3_id, 'name': name}
    
    print(f"  Loaded {len(mapping)} V3 modifier_groups with source_system")
    return mapping


def load_existing_dish_modifier_groups():
    """Load existing dish_modifier_groups for V2 restaurants to avoid duplicates."""
    restaurant_ids = ','.join(str(r) for r in V3_RESTAURANT_IDS)
    query = f"""
    SELECT dmg.dish_id, dmg.modifier_group_id
    FROM menuca_v3.dish_modifier_groups dmg
    JOIN menuca_v3.modifier_groups mg ON dmg.modifier_group_id = mg.id
    WHERE mg.restaurant_id IN ({restaurant_ids})
      AND dmg.deleted_at IS NULL;
    """
    
    rows = execute_psql_query(query)
    existing = set()
    for row in rows:
        if len(row) >= 2:
            existing.add((int(row[0]), int(row[1])))
    
    print(f"  Found {len(existing)} existing dish_modifier_groups")
    return existing


# =============================================================================
# Dump Parsing Functions
# =============================================================================

def parse_customization_dump(dump_path):
    """
    Parse the restaurants_dishes_customization data from the dump file.
    Returns list of (dish_id, customization_type, json_config, display_order) tuples.
    """
    print(f"  Parsing {dump_path}...")
    
    with open(dump_path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Find INSERT statements for restaurants_dishes_customization
    pattern = r"INSERT INTO `restaurants_dishes_customization` VALUES\s*(.+?)(?:;|\Z)"
    matches = re.findall(pattern, content, re.DOTALL)
    
    customizations = []
    
    for match in matches:
        # Parse VALUES clause - each row is (...), (...), ...
        rows = parse_values_clause(match)
        
        for row in rows:
            if len(row) < 35:  # Need at least all columns
                continue
            
            try:
                # Row structure based on table schema:
                # 0: id, 1: dish_id, 2: dish_info, 3: has_customization,
                # then pairs of (flag, json_config, display_order) for each type
                dish_id = parse_int(row[1])
                if dish_id is None:
                    continue
                
                has_customization = row[3].strip("'") == 'y'
                if not has_customization:
                    continue
                
                # Parse each customization type
                col_idx = 4  # Start after has_customization
                
                for type_name, json_col, order_col in CUSTOMIZATION_TYPES:
                    if col_idx + 2 >= len(row):
                        break
                    
                    flag = row[col_idx].strip("'")
                    json_str = row[col_idx + 1]
                    display_order = parse_int(row[col_idx + 2])
                    
                    col_idx += 3
                    
                    if flag != 'y' or json_str == 'NULL':
                        continue
                    
                    # Parse JSON config
                    config = parse_json_config(json_str)
                    if config and 'group' in config:
                        customizations.append({
                            'dish_id': dish_id,
                            'type': type_name,
                            'config': config,
                            'display_order': display_order or 0,
                        })
                        
            except Exception as e:
                # Skip malformed rows
                continue
    
    print(f"  Found {len(customizations)} dish customization entries with modifier groups")
    return customizations


def parse_values_clause(values_str):
    """Parse VALUES clause into list of row tuples."""
    rows = []
    current_row = []
    current_value = ""
    depth = 0
    in_string = False
    escape_next = False
    string_char = None
    
    i = 0
    while i < len(values_str):
        char = values_str[i]
        
        if escape_next:
            current_value += char
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            current_value += char
            i += 1
            continue
        
        if in_string:
            current_value += char
            if char == string_char:
                # Check for escaped quote
                if i + 1 < len(values_str) and values_str[i + 1] == string_char:
                    current_value += values_str[i + 1]
                    i += 2
                    continue
                in_string = False
            i += 1
            continue
        
        if char in ("'", '"'):
            in_string = True
            string_char = char
            current_value += char
            i += 1
            continue
        
        if char == '(':
            if depth == 0:
                current_row = []
                current_value = ""
            else:
                current_value += char
            depth += 1
            i += 1
            continue
        
        if char == ')':
            depth -= 1
            if depth == 0:
                if current_value:
                    current_row.append(current_value.strip())
                rows.append(current_row)
            else:
                current_value += char
            i += 1
            continue
        
        if char == ',' and depth == 1:
            current_row.append(current_value.strip())
            current_value = ""
            i += 1
            continue
        
        if depth > 0:
            current_value += char
        
        i += 1
    
    return rows


def parse_int(value):
    """Parse integer from string value."""
    if value is None or value == 'NULL':
        return None
    try:
        return int(value.strip("'\""))
    except (ValueError, TypeError):
        return None


def parse_json_config(json_str):
    """Parse JSON config from MySQL dump format."""
    if json_str == 'NULL' or not json_str:
        return None
    
    # Remove surrounding quotes
    json_str = json_str.strip()
    if json_str.startswith("'") and json_str.endswith("'"):
        json_str = json_str[1:-1]
    
    # Unescape quotes
    json_str = json_str.replace("\\'", "'")
    json_str = json_str.replace('\\"', '"')
    
    try:
        return json.loads(json_str)
    except json.JSONDecodeError:
        return None


# =============================================================================
# SQL Generation Functions
# =============================================================================

def generate_migration_sql(customizations, dish_mapping, modifier_group_mapping, existing_dmg):
    """Generate SQL for dish_modifier_groups and modifier_group_details."""
    
    dmg_inserts = []  # (dish_id, modifier_group_id)
    mgd_inserts = []  # (dish_id, name, min, max, display_order, free_items, dmg_ref)
    
    # Track what we're inserting to create references
    dmg_refs = {}  # (dish_id, modifier_group_id) -> ref_index
    
    skipped_no_dish = 0
    skipped_no_mg = 0
    skipped_existing = 0
    
    for cust in customizations:
        v2_dish_id = cust['dish_id']
        config = cust['config']
        
        # Get V3 dish
        dish_info = dish_mapping.get(v2_dish_id)
        if not dish_info:
            skipped_no_dish += 1
            continue
        
        v3_dish_id = dish_info['v3_id']
        restaurant_id = dish_info['restaurant_id']
        
        # Get V3 modifier group
        v2_group_id = str(config.get('group', ''))
        mg_info = modifier_group_mapping.get((restaurant_id, v2_group_id))
        if not mg_info:
            skipped_no_mg += 1
            continue
        
        v3_mg_id = mg_info['v3_id']
        
        # Check if already exists
        if (v3_dish_id, v3_mg_id) in existing_dmg:
            skipped_existing += 1
            continue
        
        # Check if we're already inserting this
        dmg_key = (v3_dish_id, v3_mg_id)
        if dmg_key not in dmg_refs:
            dmg_refs[dmg_key] = len(dmg_inserts)
            dmg_inserts.append(dmg_key)
            existing_dmg.add(dmg_key)  # Track to avoid duplicates
        
        # Extract modifier_group_details fields
        name = config.get('title_paid') or config.get('title_free') or config.get('title') or mg_info['name']
        min_sel = parse_int(config.get('min')) or 0
        max_sel = parse_int(config.get('max')) or 1
        display_order = cust['display_order'] or parse_int(config.get('display_order')) or 0
        free_items = parse_int(config.get('free')) or 0
        
        mgd_inserts.append({
            'dish_id': v3_dish_id,
            'name': name,
            'min_selections': min_sel,
            'max_selections': max_sel,
            'display_order': display_order,
            'free_items': free_items,
            'dmg_ref': dmg_refs[dmg_key],
        })
    
    print(f"\n  Statistics:")
    print(f"    dish_modifier_groups to insert: {len(dmg_inserts)}")
    print(f"    modifier_group_details to insert: {len(mgd_inserts)}")
    print(f"    Skipped (no V3 dish): {skipped_no_dish}")
    print(f"    Skipped (no V3 modifier_group): {skipped_no_mg}")
    print(f"    Skipped (already exists): {skipped_existing}")
    
    # Generate SQL
    sql_lines = []
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- V2 Dish Modifier Groups Migration")
    sql_lines.append(f"-- Generated: {datetime.now().isoformat()}")
    sql_lines.append("-- ============================================================")
    sql_lines.append("")
    sql_lines.append("BEGIN;")
    sql_lines.append("")
    
    # Create temp table for dish_modifier_groups with reference indexes
    sql_lines.append("-- Create temp table to track inserted dish_modifier_groups")
    sql_lines.append("CREATE TEMP TABLE dmg_insert_map (")
    sql_lines.append("    ref_idx INTEGER,")
    sql_lines.append("    dish_id BIGINT,")
    sql_lines.append("    modifier_group_id BIGINT,")
    sql_lines.append("    dmg_id BIGINT")
    sql_lines.append(");")
    sql_lines.append("")
    
    # Insert dish_modifier_groups
    if dmg_inserts:
        sql_lines.append("-- ============================================================")
        sql_lines.append("-- STEP 1: Insert dish_modifier_groups")
        sql_lines.append("-- ============================================================")
        sql_lines.append("")
        
        for idx, (dish_id, mg_id) in enumerate(dmg_inserts):
            sql_lines.append(f"WITH inserted AS (")
            sql_lines.append(f"    INSERT INTO menuca_v3.dish_modifier_groups (dish_id, modifier_group_id)")
            sql_lines.append(f"    VALUES ({dish_id}, {mg_id})")
            sql_lines.append(f"    RETURNING id")
            sql_lines.append(f")")
            sql_lines.append(f"INSERT INTO dmg_insert_map (ref_idx, dish_id, modifier_group_id, dmg_id)")
            sql_lines.append(f"SELECT {idx}, {dish_id}, {mg_id}, id FROM inserted;")
            sql_lines.append("")
        
        sql_lines.append(f"-- Inserted {len(dmg_inserts)} dish_modifier_groups")
        sql_lines.append("")
    
    # Insert modifier_group_details
    if mgd_inserts:
        sql_lines.append("-- ============================================================")
        sql_lines.append("-- STEP 2: Insert modifier_group_details")
        sql_lines.append("-- ============================================================")
        sql_lines.append("")
        
        for mgd in mgd_inserts:
            name_escaped = mgd['name'].replace("'", "''") if mgd['name'] else 'Modifier'
            sql_lines.append(f"INSERT INTO menuca_v3.modifier_group_details")
            sql_lines.append(f"    (dish_id, name, min_selections, max_selections, display_order, free_items, dish_modifier_group_id)")
            sql_lines.append(f"SELECT {mgd['dish_id']}, '{name_escaped}', {mgd['min_selections']}, {mgd['max_selections']}, {mgd['display_order']}, {mgd['free_items']}, dmg_id")
            sql_lines.append(f"FROM dmg_insert_map WHERE ref_idx = {mgd['dmg_ref']};")
            sql_lines.append("")
        
        sql_lines.append(f"-- Inserted {len(mgd_inserts)} modifier_group_details")
        sql_lines.append("")
    
    # Cleanup
    sql_lines.append("-- Cleanup temp table")
    sql_lines.append("DROP TABLE dmg_insert_map;")
    sql_lines.append("")
    
    # Commit
    sql_lines.append("COMMIT;")
    sql_lines.append("")
    
    # Verification queries
    restaurant_ids = ','.join(str(r) for r in V3_RESTAURANT_IDS)
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- Verification")
    sql_lines.append("-- ============================================================")
    sql_lines.append("")
    sql_lines.append("SELECT 'dish_modifier_groups' as table_name, COUNT(*) as count")
    sql_lines.append("FROM menuca_v3.dish_modifier_groups dmg")
    sql_lines.append("JOIN menuca_v3.modifier_groups mg ON dmg.modifier_group_id = mg.id")
    sql_lines.append(f"WHERE mg.restaurant_id IN ({restaurant_ids});")
    sql_lines.append("")
    sql_lines.append("SELECT 'modifier_group_details' as table_name, COUNT(*) as count")
    sql_lines.append("FROM menuca_v3.modifier_group_details mgd")
    sql_lines.append("JOIN menuca_v3.dishes d ON mgd.dish_id = d.id")
    sql_lines.append(f"WHERE d.restaurant_id IN ({restaurant_ids});")
    sql_lines.append("")
    
    return '\n'.join(sql_lines)


# =============================================================================
# Main
# =============================================================================

def main():
    """Main migration function."""
    print("=" * 60)
    print("V2 Dish Modifier Groups Migration")
    print("=" * 60)
    print()
    
    # Check args
    dry_run = '--dry-run' in sys.argv or '-n' in sys.argv
    apply = '--apply' in sys.argv
    
    if not dry_run and not apply:
        print("Usage: python migrate_dish_modifier_links.py [--dry-run | --apply]")
        print("  --dry-run  Generate SQL file only, do not execute")
        print("  --apply    Generate and execute the migration")
        return
    
    # Find dump file
    dump_path = Path(__file__).parent / "dumps" / "courses_dishes_dishes_customization_dump.sql"
    if not dump_path.exists():
        print(f"ERROR: Dump file not found: {dump_path}")
        return
    
    print(f"Mode: {'DRY RUN' if dry_run else 'APPLY'}")
    print(f"Dump: {dump_path}")
    print()
    
    # Load V3 mappings
    print("Loading V3 data...")
    dish_mapping = load_v3_dish_mapping()
    modifier_group_mapping = load_v3_modifier_group_mapping()
    existing_dmg = load_existing_dish_modifier_groups()
    print()
    
    # Parse customization dump
    print("Parsing customization dump...")
    customizations = parse_customization_dump(dump_path)
    print()
    
    # Generate SQL
    print("Generating migration SQL...")
    sql = generate_migration_sql(customizations, dish_mapping, modifier_group_mapping, existing_dmg)
    
    # Write SQL file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = Path(__file__).parent / "migrations" / f"dish_modifier_links_{timestamp}.sql"
    output_path.parent.mkdir(exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print(f"\n  SQL written to: {output_path}")
    
    if apply:
        print("\nExecuting migration...")
        success = execute_psql_file(output_path)
        if success:
            print("\n✅ Migration completed successfully!")
        else:
            print("\n❌ Migration failed!")
    else:
        print("\nDry run complete. Review the SQL file and run with --apply to execute.")


if __name__ == "__main__":
    # Configure stdout for Unicode
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    
    main()







