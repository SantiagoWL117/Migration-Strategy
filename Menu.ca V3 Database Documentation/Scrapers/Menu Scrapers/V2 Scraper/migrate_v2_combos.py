"""
V2 Combo Data Migration Script
Migrates combo groups, sections, modifier groups, modifiers, and prices from V2 MySQL dumps
to V3 PostgreSQL using standalone combo modifiers (not linked to regular modifier_groups).
"""

import os
import sys
import re
import json
import subprocess
import tempfile
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Any
from pathlib import Path

# Add parent directory to path for config import
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import DB_CONNECTION_STRING, PSQL_PATH

# V2 restaurant_id to V3 restaurant_id mapping
RESTAURANT_MAPPING = {
    1637: 950,   # Kirkwood Pizza
    1639: 952,   # River Pizza
    1660: 963,   # Chicco Pizza Shawarma Anger
    1661: 964,   # Chicco Pizza Maloney
    1663: 966,   # Chicco Pizza de l'Hopital
    1664: 967,   # Chicco Pizza St-Louis
    1668: 971,   # Little Gyros Greek Grill
    1670: 973,   # Capital Bites
    1671: 974,   # Pachino Pizza
    1673: 976,   # Pizza Marie
    1674: 977,   # Capri Pizza
}

DUMPS_DIR = Path(__file__).parent / "dumps"


def parse_mysql_insert(sql_content: str, table_name: str) -> List[Tuple]:
    """Parse MySQL INSERT statement and extract values."""
    pattern = rf"INSERT INTO `{table_name}` VALUES\s*(.+?);"
    match = re.search(pattern, sql_content, re.DOTALL)
    if not match:
        return []
    
    values_str = match.group(1)
    rows = []
    
    # Parse tuples - handle nested parentheses in JSON
    i = 0
    while i < len(values_str):
        if values_str[i] == '(':
            # Find matching closing parenthesis
            depth = 1
            start = i + 1
            i += 1
            in_string = False
            escape_next = False
            
            while i < len(values_str) and depth > 0:
                char = values_str[i]
                if escape_next:
                    escape_next = False
                elif char == '\\':
                    escape_next = True
                elif char == "'" and not escape_next:
                    in_string = not in_string
                elif not in_string:
                    if char == '(':
                        depth += 1
                    elif char == ')':
                        depth -= 1
                i += 1
            
            row_str = values_str[start:i-1]
            rows.append(row_str)
        else:
            i += 1
    
    return rows


def parse_combo_groups(content: str) -> Dict[int, Dict]:
    """Parse combo_groups dump file."""
    groups = {}
    rows = parse_mysql_insert(content, "menu_v3_combo_groups")
    
    for row_str in rows:
        # Format: (id, restaurant_v2_id, 'group_name')
        match = re.match(r"(\d+),(\d+),'([^']*)'", row_str)
        if match:
            id_, restaurant_v2_id, group_name = match.groups()
            groups[int(id_)] = {
                'id': int(id_),
                'restaurant_v2_id': int(restaurant_v2_id),
                'group_name': group_name
            }
    
    return groups


def extract_json_strings(row_str: str) -> List[str]:
    """Extract JSON strings from a row, handling nested objects."""
    json_strings = []
    i = 0
    while i < len(row_str):
        # Look for start of JSON string: '{"
        if row_str[i:i+3] == "'{\"" or row_str[i:i+2] == "'{":
            # Find matching closing brace and quote
            start = i + 1  # After opening quote
            brace_depth = 0
            j = start
            in_string = False
            escape_next = False
            
            while j < len(row_str):
                char = row_str[j]
                if escape_next:
                    escape_next = False
                elif char == '\\':
                    escape_next = True
                elif char == '"' and not escape_next:
                    in_string = not in_string
                elif not in_string:
                    if char == '{':
                        brace_depth += 1
                    elif char == '}':
                        brace_depth -= 1
                        if brace_depth == 0:
                            # Check for closing quote
                            if j + 1 < len(row_str) and row_str[j + 1] == "'":
                                json_str = row_str[start:j + 1]
                                # Unescape the JSON
                                json_str = json_str.replace('\\"', '"')
                                json_strings.append(json_str)
                                i = j + 2
                                break
                j += 1
            else:
                i += 1
        else:
            i += 1
    
    return json_strings


def parse_combo_group_items(content: str) -> Dict[int, Dict]:
    """Parse combo_group_items dump file."""
    items = {}
    rows = parse_mysql_insert(content, "menu_v3_combo_group_items")
    
    for row_str in rows:
        # Format: (id, group_id, item_count, 'dish_title_json', 'has_json', 'header_json', 
        #          'min_json', 'max_json', 'free_json', 'display_order_json', 
        #          'use_only_this_item_types_in_combo_json', use_price, dish_count, dishes_to_choose_from)
        
        try:
            # Extract numeric fields first
            match = re.match(r"(\d+),(\d+),(\d+),", row_str)
            if not match:
                continue
            
            id_ = int(match.group(1))
            group_id = int(match.group(2))
            item_count = int(match.group(3))
            
            # Extract JSON fields using proper parsing
            json_fields = extract_json_strings(row_str)
            
            # IMPORTANT: dish_title is an ARRAY '[...]' not an object '{...}'
            # So extract_json_strings SKIPS it, making all indices shifted!
            # Actual json_fields order: [has, header, min, max, free, display_order, use_only_this_item_types, ...]
            # has is index 0, NOT index 1!
            if len(json_fields) >= 1:
                has_json = json_fields[0] if len(json_fields) > 0 else '{}'
                header_json = json_fields[1] if len(json_fields) > 1 else '{}'
                min_json = json_fields[2] if len(json_fields) > 2 else '{}'
                max_json = json_fields[3] if len(json_fields) > 3 else '{}'
                free_json = json_fields[4] if len(json_fields) > 4 else '{}'
                display_order_json = json_fields[5] if len(json_fields) > 5 else '{}'
                use_types_json = json_fields[6] if len(json_fields) > 6 else '{}'
                
                items[id_] = {
                    'id': id_,
                    'group_id': group_id,
                    'item_count': item_count,
                    'has': parse_json_safe(has_json),
                    'header': parse_json_safe(header_json),
                    'min': parse_json_safe(min_json),
                    'max': parse_json_safe(max_json),
                    'free': parse_json_safe(free_json),
                    'display_order': parse_json_safe(display_order_json),
                    'use_only_this_item_types_in_combo': parse_json_safe(use_types_json),
                }
        except Exception as e:
            print(f"Error parsing combo_group_item row {row_str[:50]}: {e}")
            continue
    
    return items


def parse_json_safe(json_str: str) -> Dict:
    """Safely parse JSON string."""
    try:
        # Handle escaped quotes
        json_str = json_str.replace("\\'", "'")
        return json.loads(json_str)
    except:
        return {}


def parse_modifier_groups(content: str) -> Dict[int, Dict]:
    """Parse modifier_groups dump file."""
    groups = {}
    rows = parse_mysql_insert(content, "menu_v3_modifier_groups")
    
    for row_str in rows:
        # Format: (id, restaurant_v2_id, 'group_name', 'group_type')
        match = re.match(r"(\d+),(\d+),'([^']*)','([^']*)'", row_str)
        if match:
            id_, restaurant_v2_id, group_name, group_type = match.groups()
            groups[int(id_)] = {
                'id': int(id_),
                'restaurant_v2_id': int(restaurant_v2_id),
                'group_name': group_name,
                'group_type': group_type
            }
    
    return groups


def parse_modifier_names(content: str) -> Dict[str, Dict]:
    """Parse modifier_names dump file. Returns hash -> name mapping."""
    names = {}
    rows = parse_mysql_insert(content, "menu_v3_modifier_names")
    
    for row_str in rows:
        # Format: (id, 'hash', restaurant_v2_id, 'name')
        match = re.match(r"(\d+),'([^']*)',(\d+),'([^']*)'", row_str)
        if match:
            id_, hash_, restaurant_v2_id, name = match.groups()
            key = f"{restaurant_v2_id}_{hash_}"  # Unique key per restaurant
            names[key] = {
                'id': int(id_),
                'hash': hash_,
                'restaurant_v2_id': int(restaurant_v2_id),
                'name': name
            }
    
    return names


def parse_modifiers(content: str) -> Dict[int, List[Dict]]:
    """Parse modifiers dump file. Returns group_id -> list of modifiers mapping."""
    modifiers = {}
    rows = parse_mysql_insert(content, "menu_v3_modifiers")
    
    for row_str in rows:
        # Format: (id, group_id, 'item_hash', 'price', price_j_or_NULL)
        match = re.match(r"(\d+),(\d+),'([^']*)','([^']*)',(NULL|'[^']*'|\{[^}]*\})", row_str)
        if match:
            id_, group_id, item_hash, price, price_j = match.groups()
            group_id = int(group_id)
            
            if group_id not in modifiers:
                modifiers[group_id] = []
            
            modifiers[group_id].append({
                'id': int(id_),
                'group_id': group_id,
                'item_hash': item_hash,
                'price': price,
                'price_j': None if price_j == 'NULL' else price_j
            })
    
    return modifiers


def escape_sql_string(s: str) -> str:
    """Escape string for SQL."""
    if s is None:
        return 'NULL'
    return s.replace("'", "''")


def parse_price_string(price_str: str) -> List[Tuple[str, float]]:
    """Parse price string to list of (size, price) tuples."""
    prices = []
    if not price_str or price_str == '':
        return [('Standard', 0.00)]
    
    # Handle comma-separated prices (Small, Medium, Large, X-Large)
    size_names = ['Small', 'Medium', 'Large', 'X-Large']
    parts = price_str.split(',')
    
    if len(parts) == 1:
        try:
            price = float(parts[0].strip())
            prices.append(('Standard', price))
        except ValueError:
            prices.append(('Standard', 0.00))
    else:
        for i, part in enumerate(parts[:4]):
            try:
                price = float(part.strip())
                size = size_names[i] if i < len(size_names) else f'Size_{i+1}'
                prices.append((size, price))
            except ValueError:
                continue
    
    return prices if prices else [('Standard', 0.00)]


class V2ComboMigration:
    def __init__(self):
        self.combo_groups = {}
        self.combo_group_items = {}
        self.modifier_groups = {}
        self.modifier_names = {}
        self.modifiers = {}
        
        self.sql_statements = []
        self.stats = {
            'combo_groups': 0,
            'combo_group_sections': 0,
            'combo_modifier_groups': 0,
            'combo_modifiers': 0,
            'combo_modifier_prices': 0,
        }
    
    def load_dumps(self):
        """Load all dump files."""
        print("Loading dump files...")
        
        # Load combo_groups
        with open(DUMPS_DIR / "combo_groups_dump.sql", 'r', encoding='utf-8') as f:
            self.combo_groups = parse_combo_groups(f.read())
        print(f"  Loaded {len(self.combo_groups)} combo groups")
        
        # Load combo_group_items
        with open(DUMPS_DIR / "combo_group_items_dump.sql", 'r', encoding='utf-8') as f:
            self.combo_group_items = parse_combo_group_items(f.read())
        print(f"  Loaded {len(self.combo_group_items)} combo group items")
        
        # Load modifier_groups
        with open(DUMPS_DIR / "modifier_groups_dump.sql", 'r', encoding='utf-8') as f:
            self.modifier_groups = parse_modifier_groups(f.read())
        print(f"  Loaded {len(self.modifier_groups)} modifier groups")
        
        # Load modifier_names
        with open(DUMPS_DIR / "modifiers_name_dump.sql", 'r', encoding='utf-8') as f:
            self.modifier_names = parse_modifier_names(f.read())
        print(f"  Loaded {len(self.modifier_names)} modifier names")
        
        # Load modifiers
        with open(DUMPS_DIR / "modifiers_dump.sql", 'r', encoding='utf-8') as f:
            self.modifiers = parse_modifiers(f.read())
        print(f"  Loaded modifiers for {len(self.modifiers)} groups")
    
    def generate_delete_statements(self):
        """Generate DELETE statements to clear existing V2 combo data."""
        v3_restaurant_ids = list(RESTAURANT_MAPPING.values())
        ids_str = ','.join(map(str, v3_restaurant_ids))
        
        self.sql_statements.append("-- Step 0: Add source_id column to combo_modifiers if not exists")
        self.sql_statements.append("""
ALTER TABLE menuca_v3.combo_modifiers ADD COLUMN IF NOT EXISTS source_id INT;
""")
        
        self.sql_statements.append("-- Step 1: Delete existing V2 combo data")
        self.sql_statements.append(f"""
-- Delete combo_modifier_prices for V2 restaurants
DELETE FROM menuca_v3.combo_modifier_prices
WHERE combo_modifier_id IN (
    SELECT cm.id FROM menuca_v3.combo_modifiers cm
    JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
    JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
    JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
    WHERE cg.restaurant_id IN ({ids_str})
);

-- Delete combo_modifiers for V2 restaurants
DELETE FROM menuca_v3.combo_modifiers
WHERE combo_modifier_group_id IN (
    SELECT cmg.id FROM menuca_v3.combo_modifier_groups cmg
    JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
    JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
    WHERE cg.restaurant_id IN ({ids_str})
);

-- Delete combo_modifier_groups for V2 restaurants
DELETE FROM menuca_v3.combo_modifier_groups
WHERE combo_group_section_id IN (
    SELECT cgs.id FROM menuca_v3.combo_group_sections cgs
    JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
    WHERE cg.restaurant_id IN ({ids_str})
);

-- Delete combo_group_sections for V2 restaurants
DELETE FROM menuca_v3.combo_group_sections
WHERE combo_group_id IN (
    SELECT id FROM menuca_v3.combo_groups
    WHERE restaurant_id IN ({ids_str})
);

-- Delete dish_combo_groups for V2 restaurants (to allow combo_groups deletion)
DELETE FROM menuca_v3.dish_combo_groups
WHERE combo_group_id IN (
    SELECT id FROM menuca_v3.combo_groups
    WHERE restaurant_id IN ({ids_str})
);

-- Delete combo_groups for V2 restaurants
DELETE FROM menuca_v3.combo_groups
WHERE restaurant_id IN ({ids_str});
""")
    
    def generate_insert_statements(self):
        """Generate INSERT statements for all combo data."""
        self.sql_statements.append("\n-- Step 2: Insert combo_groups")
        
        # Filter combo groups to only V2 restaurants in mapping
        valid_combo_groups = {
            k: v for k, v in self.combo_groups.items()
            if v['restaurant_v2_id'] in RESTAURANT_MAPPING
        }
        
        print(f"\nProcessing {len(valid_combo_groups)} combo groups for migration...")
        
        # Build list of combo_groups values for batch insert
        combo_groups_values = []
        for cg_id, cg in valid_combo_groups.items():
            v3_restaurant_id = RESTAURANT_MAPPING[cg['restaurant_v2_id']]
            name = escape_sql_string(cg['group_name'])
            
            # Get item_count from combo_group_items
            item_count = 1
            for item in self.combo_group_items.values():
                if item['group_id'] == cg_id:
                    item_count = item['item_count']
                    break
            
            combo_groups_values.append(f"({v3_restaurant_id}, '{name}', {item_count}, {cg_id})")
            self.stats['combo_groups'] += 1
        
        # Batch insert combo_groups
        if combo_groups_values:
            self.sql_statements.append(f"""
INSERT INTO menuca_v3.combo_groups (restaurant_id, name, special_number_of_items, source_id)
VALUES
{','.join(combo_groups_values)};
""")
        
        # Generate combo_group_sections
        self.sql_statements.append("\n-- Step 3: Insert combo_group_sections")
        
        section_types_map = {
            'crust': 'crust',
            'custom_ingredient': 'custom_ingredients',
            'premium_toppings': 'premium_toppings',
            'sauce': 'sauce',
            'dip': 'dip',
            'drink': 'drink',
            'side_dish': 'side_dish',
            'extra': 'extras',
            'dressing': 'dressing',
            'cook_method': 'cooking_method',
            'desert': 'desert',
        }
        
        for item_id, item in self.combo_group_items.items():
            if item['group_id'] not in valid_combo_groups:
                continue
            
            has_config = item.get('has', {})
            header_config = item.get('header', {})
            min_config = item.get('min', {})
            max_config = item.get('max', {})
            free_config = item.get('free', {})
            display_order_config = item.get('display_order', {})
            use_types_config = item.get('use_only_this_item_types_in_combo', {})
            
            display_order_counter = 0
            for section_type, has_value in has_config.items():
                # Check if section is enabled
                # has_value can be:
                #   - "on" (simple enabled)
                #   - {"free": "...", "paid": "..."} (enabled if either has content)
                #   - list like [''] (skip)
                
                is_enabled = False
                if has_value == 'on':
                    is_enabled = True
                elif isinstance(has_value, dict):
                    # Section is enabled if either free or paid has content
                    free_text = has_value.get('free', '')
                    paid_text = has_value.get('paid', '')
                    is_enabled = bool(free_text) or bool(paid_text)
                elif isinstance(has_value, str) and has_value:
                    is_enabled = True
                
                if not is_enabled:
                    continue
                
                v3_section_type = section_types_map.get(section_type, section_type)
                
                # Get header - try from has_config first (it contains the header text)
                use_header = ''
                if isinstance(has_value, dict):
                    use_header = has_value.get('paid', '') or has_value.get('free', '')
                
                # Fall back to header_config
                if not use_header:
                    header_obj = header_config.get(section_type, {})
                    if isinstance(header_obj, dict):
                        use_header = header_obj.get('paid', '') or header_obj.get('free', '')
                    elif isinstance(header_obj, str):
                        use_header = header_obj
                
                use_header = escape_sql_string(use_header)
                
                # Get min/max/free values
                min_val_raw = min_config.get(section_type, '0')
                if isinstance(min_val_raw, dict):
                    min_val_raw = list(min_val_raw.values())[0] if min_val_raw else '0'
                min_val = int(min_val_raw) if min_val_raw and str(min_val_raw).isdigit() else 0
                
                max_val_raw = max_config.get(section_type, '0')
                if isinstance(max_val_raw, dict):
                    max_val_raw = list(max_val_raw.values())[0] if max_val_raw else '0'
                max_val = int(max_val_raw) if max_val_raw and str(max_val_raw).isdigit() else 0
                
                free_val_raw = free_config.get(section_type, '0')
                if isinstance(free_val_raw, dict):
                    free_val_raw = list(free_val_raw.values())[0] if free_val_raw else '0'
                free_val = int(free_val_raw) if free_val_raw and str(free_val_raw).isdigit() else 0
                
                display_order_raw = display_order_config.get(section_type, str(display_order_counter))
                if isinstance(display_order_raw, dict):
                    display_order_raw = list(display_order_raw.values())[0] if display_order_raw else str(display_order_counter)
                display_order = int(display_order_raw) if display_order_raw and str(display_order_raw).isdigit() else display_order_counter
                display_order_counter += 1
                
                # Use source_id lookup to find combo_group_id
                self.sql_statements.append(f"""
INSERT INTO menuca_v3.combo_group_sections 
(combo_group_id, section_type, use_header, display_order, free_items, min_selection, max_selection, is_active)
SELECT id, '{v3_section_type}', '{use_header}', {display_order}, {free_val}, {min_val}, {max_val}, TRUE
FROM menuca_v3.combo_groups WHERE source_id = {item['group_id']};
""")
                self.stats['combo_group_sections'] += 1
                
                # Get referenced modifier group from use_only_this_item_types_in_combo
                # Format can be: {'416': ''} or '416' or {}
                mg_ids = []
                use_types_value = use_types_config.get(section_type, {})
                if isinstance(use_types_value, dict):
                    # Keys are the modifier group IDs
                    mg_ids = [k for k in use_types_value.keys() if k.isdigit()]
                elif isinstance(use_types_value, str) and use_types_value.isdigit():
                    mg_ids = [use_types_value]
                
                if not mg_ids:
                    continue
                
                # Use first modifier group ID
                mg_id = int(mg_ids[0])
                if mg_id not in self.modifier_groups:
                    print(f"  Warning: Modifier group {mg_id} not found for section {section_type}")
                    continue
                
                mg = self.modifier_groups[mg_id]
                mg_name = escape_sql_string(mg['group_name'])
                
                # Determine type_code based on max_selection
                type_code = 'CHECKBOX' if max_val > 1 else 'RADIO'
                
                # Create combo_modifier_group using section lookup
                self.sql_statements.append(f"""
INSERT INTO menuca_v3.combo_modifier_groups 
(combo_group_section_id, name, type_code, is_selected, source_id)
SELECT cgs.id, '{mg_name}', '{type_code}', TRUE, {mg_id}
FROM menuca_v3.combo_group_sections cgs
JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
WHERE cg.source_id = {item['group_id']} AND cgs.section_type = '{v3_section_type}';
""")
                self.stats['combo_modifier_groups'] += 1
                
                # Get modifiers for this group
                group_modifiers = self.modifiers.get(mg_id, [])
                restaurant_v2_id = mg['restaurant_v2_id']
                
                # Store the combo_group source_id to scope the lookups
                combo_group_source_id = item['group_id']
                
                for idx, modifier in enumerate(group_modifiers):
                    # Get modifier name from hash
                    hash_key = f"{restaurant_v2_id}_{modifier['item_hash']}"
                    name_record = self.modifier_names.get(hash_key)
                    
                    if not name_record:
                        continue
                    
                    modifier_name = escape_sql_string(name_record['name'])
                    
                    # Create combo_modifier with source_id for price linking
                    # IMPORTANT: Scope to the specific combo_group to avoid duplicates
                    # when the same modifier_group is used across multiple combo_groups
                    self.sql_statements.append(f"""
INSERT INTO menuca_v3.combo_modifiers 
(combo_modifier_group_id, name, display_order, source_id)
SELECT cmg.id, '{modifier_name}', {idx}, {modifier['id']}
FROM menuca_v3.combo_modifier_groups cmg
JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
WHERE cmg.source_id = {mg_id} AND cg.source_id = {combo_group_source_id};
""")
                    self.stats['combo_modifiers'] += 1
                    
                    # Parse and insert prices using source_id lookup
                    # IMPORTANT: Also scope to the specific combo_group
                    prices = parse_price_string(modifier['price'])
                    for size, price in prices:
                        size_escaped = escape_sql_string(size)
                        self.sql_statements.append(f"""
INSERT INTO menuca_v3.combo_modifier_prices (combo_modifier_id, size_variant, price)
SELECT cm.id, '{size_escaped}', {price:.2f}
FROM menuca_v3.combo_modifiers cm
JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
WHERE cm.source_id = {modifier['id']} AND cg.source_id = {combo_group_source_id};
""")
                        self.stats['combo_modifier_prices'] += 1
        
        # No temp tables to cleanup - using source_id lookups
    
    def generate_migration_file(self) -> str:
        """Generate the migration SQL file."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        migrations_dir = DUMPS_DIR.parent / "migrations"
        migrations_dir.mkdir(exist_ok=True)
        
        filename = migrations_dir / f"v2_combo_migration_{timestamp}.sql"
        
        header = f"""-- V2 Combo Data Migration
-- Generated: {datetime.now().isoformat()}
-- Target restaurants: {', '.join(map(str, RESTAURANT_MAPPING.values()))}

BEGIN;

"""
        
        footer = """
COMMIT;
"""
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(header)
            f.write('\n'.join(self.sql_statements))
            f.write(footer)
        
        return str(filename)
    
    def execute_migration(self, sql_file: str):
        """Execute the migration SQL file using psql."""
        print(f"\nExecuting migration: {sql_file}")
        
        try:
            result = subprocess.run(
                [PSQL_PATH, DB_CONNECTION_STRING, "-f", sql_file],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace',
                timeout=300
            )
            
            if result.returncode != 0:
                print(f"ERROR: {result.stderr}")
                return False
            
            print("Migration executed successfully!")
            print(result.stdout[:2000] if result.stdout else "")
            return True
            
        except subprocess.TimeoutExpired:
            print("ERROR: Migration timed out")
            return False
        except Exception as e:
            print(f"ERROR: {e}")
            return False
    
    def verify_migration(self):
        """Verify migration by querying counts."""
        print("\nVerifying migration...")
        
        v3_ids = ','.join(map(str, RESTAURANT_MAPPING.values()))
        
        queries = [
            ("combo_groups", f"SELECT COUNT(*) FROM menuca_v3.combo_groups WHERE restaurant_id IN ({v3_ids})"),
            ("combo_group_sections", f"""
                SELECT COUNT(*) FROM menuca_v3.combo_group_sections cgs
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id IN ({v3_ids})
            """),
            ("combo_modifier_groups", f"""
                SELECT COUNT(*) FROM menuca_v3.combo_modifier_groups cmg
                JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id IN ({v3_ids})
            """),
            ("combo_modifiers", f"""
                SELECT COUNT(*) FROM menuca_v3.combo_modifiers cm
                JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
                JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id IN ({v3_ids})
            """),
            ("combo_modifier_prices", f"""
                SELECT COUNT(*) FROM menuca_v3.combo_modifier_prices cmp
                JOIN menuca_v3.combo_modifiers cm ON cmp.combo_modifier_id = cm.id
                JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
                JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id IN ({v3_ids})
            """),
        ]
        
        for table_name, query in queries:
            try:
                result = subprocess.run(
                    [PSQL_PATH, DB_CONNECTION_STRING, "-t", "-A", "-c", query],
                    capture_output=True,
                    text=True,
                    encoding='utf-8',
                    timeout=30
                )
                count = result.stdout.strip()
                print(f"  {table_name}: {count} records")
            except Exception as e:
                print(f"  {table_name}: Error - {e}")
    
    def run(self, execute: bool = True):
        """Run the full migration."""
        print("=" * 60)
        print("V2 COMBO DATA MIGRATION")
        print("=" * 60)
        
        # Load dumps
        self.load_dumps()
        
        # Generate SQL
        print("\nGenerating SQL statements...")
        self.generate_delete_statements()
        self.generate_insert_statements()
        
        print(f"\nStatistics:")
        for table, count in self.stats.items():
            print(f"  {table}: {count} statements")
        
        # Write migration file
        sql_file = self.generate_migration_file()
        print(f"\nMigration file: {sql_file}")
        
        if execute:
            success = self.execute_migration(sql_file)
            if success:
                self.verify_migration()
        
        print("\nDone!")


if __name__ == "__main__":
    # Set console encoding
    if sys.stdout.encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    
    migration = V2ComboMigration()
    
    # Check for --dry-run flag
    execute = '--dry-run' not in sys.argv
    if not execute:
        print("DRY RUN MODE - SQL file will be generated but not executed")
    
    migration.run(execute=execute)
