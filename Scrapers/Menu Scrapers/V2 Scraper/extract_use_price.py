"""
Extract use_price data from V2 combo_group_items dump
and update V3 dish_prices with correct modifier_size_variant_id
"""
import re
import json
import sys
import os

# Add parent directory to path for config import
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import DB_CONNECTION_STRING, PSQL_PATH
import subprocess
import tempfile

def extract_use_price_from_dump():
    """Parse the V2 dump and extract use_price data"""
    dump_path = os.path.join(os.path.dirname(__file__), 'dumps', 'combo_group_items_dump.sql')
    
    with open(dump_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the INSERT statement
    insert_match = re.search(r'INSERT INTO.*?VALUES\s*(.*?);', content, re.DOTALL)
    if not insert_match:
        print('No INSERT found')
        return []
    
    values_str = insert_match.group(1)
    
    # Extract all records
    records = []
    depth = 0
    current_record = ''
    for char in values_str:
        if char == '(':
            if depth == 0:
                current_record = ''
            depth += 1
        elif char == ')':
            depth -= 1
            if depth == 0:
                records.append(current_record)
                current_record = ''
        if depth > 0:
            current_record += char
    
    print(f'Found {len(records)} combo_group_items records')
    
    # Parse each record using escaped quote pattern
    # Pattern: \"modifier_group_id\": \"tier_value\" where tier is 1-4
    tier_pattern = r'\\"(\d+)\\":\s*\\"([1-4])\\"'
    
    use_price_data = []
    for record in records:
        record = record.lstrip('(')
        parts = record.split(',', 2)
        if len(parts) < 2:
            continue
        record_id = parts[0].strip()
        group_id = parts[1].strip()
        
        matches = re.findall(tier_pattern, record)
        for mg_source_id, tier in matches:
            use_price_data.append({
                'record_id': record_id,
                'combo_group_source_id': group_id,
                'modifier_group_source_id': mg_source_id,
                'price_tier': tier
            })
    
    return use_price_data


def get_v2_combo_dishes():
    """Get all V2 combo dishes and their current dish_prices"""
    sql = '''
    SELECT 
        d.id as dish_id,
        d.name as dish_name,
        r.id as restaurant_id,
        r.name as restaurant_name,
        r.legacy_v2_id,
        cg.id as combo_group_id,
        cg.source_id as combo_group_source_id,
        dp.id as dish_price_id,
        dp.size_variant,
        dp.dish_size_variant_id,
        dsv.modifier_size_variant_id as current_modifier_size_variant_id
    FROM menuca_v3.dishes d
    JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
    JOIN menuca_v3.dish_combo_groups dcg ON dcg.dish_id = d.id
    JOIN menuca_v3.combo_groups cg ON cg.id = dcg.combo_group_id AND cg.deleted_at IS NULL
    JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id AND dp.deleted_at IS NULL AND dp.is_active = true
    LEFT JOIN menuca_v3.dish_size_variants dsv ON dsv.id = dp.dish_size_variant_id
    WHERE r.legacy_v2_id IN (1637, 1639, 1660, 1661, 1663, 1664, 1668, 1670, 1671, 1673, 1674)
      AND d.deleted_at IS NULL
    ORDER BY r.name, d.name, dp.display_order;
    '''
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        f.write(sql)
        sql_file = f.name
    
    env = os.environ.copy()
    env['PGCLIENTENCODING'] = 'UTF8'
    result = subprocess.run(
        [PSQL_PATH, DB_CONNECTION_STRING, '-t', '-A', '-F', '|', '-f', sql_file],
        capture_output=True, text=True, encoding='utf-8', errors='replace', env=env
    )
    
    dishes = []
    for line in result.stdout.strip().split('\n'):
        if line:
            parts = line.split('|')
            if len(parts) >= 11:
                dishes.append({
                    'dish_id': int(parts[0]),
                    'dish_name': parts[1],
                    'restaurant_id': int(parts[2]),
                    'restaurant_name': parts[3],
                    'legacy_v2_id': int(parts[4]) if parts[4] else None,
                    'combo_group_id': int(parts[5]),
                    'combo_group_source_id': int(parts[6]) if parts[6] else None,
                    'dish_price_id': int(parts[7]),
                    'size_variant': parts[8],
                    'dish_size_variant_id': int(parts[9]) if parts[9] else None,
                    'current_modifier_size_variant_id': int(parts[10]) if parts[10] else None
                })
    
    return dishes


def get_dish_size_variant_for_msv(msv_id):
    """Get the dish_size_variant_id that maps to the given modifier_size_variant_id"""
    # Map modifier_size_variant_id to dish_size_variant_id
    # These are the standard sizes that have direct mappings
    msv_to_dsv = {
        1: 1,   # standard -> standard
        2: 2,   # small -> small
        3: 3,   # medium -> medium
        4: 4,   # large -> large
        5: 5,   # x-large -> x-large
    }
    return msv_to_dsv.get(msv_id)


def main():
    print("=" * 80)
    print("EXTRACTING use_price DATA FROM V2 DUMP")
    print("=" * 80)
    
    # Step 1: Extract use_price from V2 dump
    use_price_data = extract_use_price_from_dump()
    
    # Group by combo_group_source_id and get the first (most common) tier for each
    combo_group_tiers = {}
    for entry in use_price_data:
        cg_source = int(entry['combo_group_source_id'])
        tier = entry['price_tier']
        if cg_source not in combo_group_tiers:
            combo_group_tiers[cg_source] = tier
    
    print(f"\nFound {len(use_price_data)} use_price entries")
    print(f"Unique combo groups with tier values: {len(combo_group_tiers)}")
    
    # Step 2: Get V2 combo dishes
    print("\n" + "=" * 80)
    print("V2 COMBO DISHES AND THEIR CURRENT dish_prices")
    print("=" * 80)
    
    v2_dishes = get_v2_combo_dishes()
    print(f"\nFound {len(v2_dishes)} V2 combo dish prices")
    
    # Group by combo_group_source_id
    dishes_by_cg = {}
    for dish in v2_dishes:
        cg_source = dish['combo_group_source_id']
        if cg_source not in dishes_by_cg:
            dishes_by_cg[cg_source] = []
        dishes_by_cg[cg_source].append(dish)
    
    # Step 3: Map use_price to dish_prices updates
    print("\n" + "=" * 80)
    print("MAPPING use_price TO dish_prices UPDATES")
    print("=" * 80)
    
    # Price tier to modifier_size_variant_id mapping
    # Based on display_order: 1=small, 2=medium, 3=large, 4=x-large
    tier_to_msv_id = {
        '1': 2,  # Small
        '2': 3,  # Medium
        '3': 4,  # Large
        '4': 5,  # X-Large
    }
    
    updates = []
    seen_prices = set()
    
    for cg_source, tier in combo_group_tiers.items():
        target_msv_id = tier_to_msv_id.get(tier)
        target_dsv_id = get_dish_size_variant_for_msv(target_msv_id) if target_msv_id else None
        
        if cg_source in dishes_by_cg and target_msv_id and target_dsv_id:
            for dish in dishes_by_cg[cg_source]:
                # Skip if already seen this price (dishes can have multiple combo groups)
                if dish['dish_price_id'] in seen_prices:
                    continue
                seen_prices.add(dish['dish_price_id'])
                
                # Only update if current modifier_size_variant_id doesn't match target
                if dish['current_modifier_size_variant_id'] != target_msv_id:
                    updates.append({
                        'dish_price_id': dish['dish_price_id'],
                        'dish_id': dish['dish_id'],
                        'dish_name': dish['dish_name'],
                        'restaurant_id': dish['restaurant_id'],
                        'restaurant_name': dish['restaurant_name'],
                        'combo_group_source_id': cg_source,
                        'current_dsv_id': dish['dish_size_variant_id'],
                        'current_msv_id': dish['current_modifier_size_variant_id'],
                        'target_dsv_id': target_dsv_id,
                        'target_msv_id': target_msv_id,
                        'price_tier': tier
                    })
    
    print(f"\nFound {len(updates)} dish_prices that need updating:")
    print("-" * 140)
    print(f"{'Price ID':<10} {'Dish ID':<10} {'Rest ID':<8} {'Restaurant':<20} {'Dish Name':<30} {'CG Src':<8} {'Curr DSV':<10} {'Tgt DSV':<10} {'Tier':<6}")
    print("-" * 140)
    for upd in updates:
        print(f"{upd['dish_price_id']:<10} {upd['dish_id']:<10} {upd['restaurant_id']:<8} {upd['restaurant_name'][:19]:<20} {upd['dish_name'][:29]:<30} {upd['combo_group_source_id']:<8} {upd['current_dsv_id'] or 'NULL':<10} {upd['target_dsv_id']:<10} {upd['price_tier']:<6}")
    
    return updates


def generate_sql_updates(updates):
    """Generate SQL UPDATE statements"""
    sql_statements = []
    sql_statements.append("-- V2 Combo Dish Price Updates based on use_price field")
    sql_statements.append("-- Updates dish_size_variant_id to match the required modifier_size_variant_id")
    sql_statements.append("")
    sql_statements.append("BEGIN;")
    sql_statements.append("")
    
    for upd in updates:
        sql_statements.append(f"-- Dish: {upd['dish_name']} (ID: {upd['dish_id']})")
        sql_statements.append(f"-- Restaurant: {upd['restaurant_name']} (ID: {upd['restaurant_id']})")
        sql_statements.append(f"-- Combo Group Source ID: {upd['combo_group_source_id']}, Price Tier: {upd['price_tier']}")
        sql_statements.append(f"UPDATE menuca_v3.dish_prices SET dish_size_variant_id = {upd['target_dsv_id']} WHERE id = {upd['dish_price_id']};")
        sql_statements.append("")
    
    sql_statements.append("COMMIT;")
    return "\n".join(sql_statements)


def execute_updates(updates):
    """Execute the SQL updates"""
    if not updates:
        print("\nNo updates to execute.")
        return
    
    sql = generate_sql_updates(updates)
    
    # Save SQL to file
    sql_file = os.path.join(os.path.dirname(__file__), 'migrations', 'update_v2_dish_prices_use_price.sql')
    os.makedirs(os.path.dirname(sql_file), exist_ok=True)
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f"\nSQL saved to: {sql_file}")
    
    # Execute
    print("\nExecuting updates...")
    env = os.environ.copy()
    env['PGCLIENTENCODING'] = 'UTF8'
    result = subprocess.run(
        [PSQL_PATH, DB_CONNECTION_STRING, '-f', sql_file],
        capture_output=True, text=True, encoding='utf-8', errors='replace', env=env
    )
    print(result.stdout)
    if result.stderr:
        print("STDERR:", result.stderr)
    print(f"Exit code: {result.returncode}")


if __name__ == '__main__':
    import sys
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    
    updates = main()
    
    if updates:
        print("\n" + "=" * 80)
        print("EXECUTE UPDATES?")
        print("=" * 80)
        execute_updates(updates)

