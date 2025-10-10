#!/usr/bin/env python3
"""
Phase 4.4 Step 4: Deserialize combo_groups.options BLOB
Parses options BLOB (combo rules) -> combo_rules JSONB CSV
"""
import csv
import json
import binascii
import phpserialize
from typing import Dict, Optional

INPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_groups_hex.csv"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_rules_deserialized.csv"
ERROR_LOG = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_rules_errors.txt"

# Modifier type mapping: abbreviations -> full words
MODIFIER_TYPE_MAP = {
    'ci': 'custom_ingredients',
    'e': 'extras',
    'sd': 'side_dishes',
    'd': 'drinks',
    'sa': 'sauces',
    'br': 'bread',
    'dr': 'dressing',
    'cm': 'cooking_method'
}

def parse_options_blob(combo_group_id: int, combo_name: str, options_hex: str, error_log_file) -> Optional[str]:
    """
    Parse options BLOB: combo rules and modifier configuration.
    
    Returns:
        JSONB string with combo_rules structure
    """
    # Handle empty hex
    if not options_hex or options_hex == '0x':
        return None
    
    try:
        # Convert hex to bytes
        hex_str = options_hex[2:] if options_hex.startswith('0x') else options_hex
        blob_bytes = binascii.unhexlify(hex_str)
        
        # Parse PHP serialized data
        options_data = phpserialize.loads(blob_bytes)
        
        # Should be a dict
        if not isinstance(options_data, dict):
            error_log_file.write(f"Combo {combo_group_id}: Invalid BLOB structure (not dict)\n")
            return None
        
        # Build JSON structure
        combo_rules = {}
        modifier_rules = {}
        
        for key, value in options_data.items():
            # Decode key if bytes
            if isinstance(key, bytes):
                key = key.decode('utf-8')
            
            # Handle different config types
            if key == 'combo' or key == 'itemcount':
                # Item count
                if isinstance(value, bytes):
                    combo_rules['item_count'] = int(value.decode('utf-8'))
                elif isinstance(value, (int, str)):
                    combo_rules['item_count'] = int(value)
            
            elif key == 'showPizzaIcons':
                # UI setting
                if isinstance(value, bytes):
                    combo_rules['show_pizza_icons'] = value.decode('utf-8') == 'Y'
                elif isinstance(value, str):
                    combo_rules['show_pizza_icons'] = value == 'Y'
            
            elif key == 'displayHeader':
                # Multi-item labels
                if isinstance(value, bytes):
                    combo_rules['display_header'] = value.decode('utf-8')
                elif isinstance(value, str):
                    combo_rules['display_header'] = value
            
            elif key in MODIFIER_TYPE_MAP or (isinstance(key, str) and key in MODIFIER_TYPE_MAP):
                # Modifier configuration
                full_type = MODIFIER_TYPE_MAP.get(key, key)
                
                if isinstance(value, dict):
                    # Nested modifier config
                    mod_config = {}
                    
                    for mod_key, mod_val in value.items():
                        if isinstance(mod_key, bytes):
                            mod_key = mod_key.decode('utf-8')
                        if isinstance(mod_val, bytes):
                            mod_val = mod_val.decode('utf-8')
                        
                        if mod_key == 'has':
                            mod_config['enabled'] = mod_val == 'Y'
                        elif mod_key == 'min':
                            mod_config['min'] = int(mod_val) if mod_val else 0
                        elif mod_key == 'max':
                            mod_config['max'] = int(mod_val) if mod_val else 0
                        elif mod_key == 'free':
                            mod_config['free_quantity'] = int(mod_val) if mod_val else 0
                        elif mod_key == 'order':
                            mod_config['display_order'] = int(mod_val) if mod_val else 0
                        elif mod_key == 'header':
                            mod_config['display_header'] = mod_val
                    
                    modifier_rules[full_type] = mod_config
                else:
                    # Simple value (enabled/disabled)
                    if isinstance(value, bytes):
                        value = value.decode('utf-8')
                    modifier_rules[full_type] = {'enabled': value == 'Y'}
        
        # Add modifier_rules to combo_rules
        if modifier_rules:
            combo_rules['modifier_rules'] = modifier_rules
        
        # Convert to JSON string
        return json.dumps(combo_rules)
    
    except Exception as e:
        error_log_file.write(f"Error parsing combo {combo_group_id}: {e}\n")
        return None

def main():
    print("=" * 70)
    print("Phase 4.4 Step 4: Deserialize options BLOB -> combo_rules")
    print("=" * 70)
    print()

    print(f"Reading: {INPUT_CSV}")
    
    with open(INPUT_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    
    print(f"  Loaded {len(rows):,} combo_groups")
    print()
    
    # Initialize error log
    with open(ERROR_LOG, 'w', encoding='utf-8') as f:
        f.write("Phase 4.4 Step 4: options BLOB Deserialization Errors\n")
        f.write("=" * 50 + "\n\n")
    
    all_rules = []
    success_count = 0
    error_count = 0
    empty_count = 0
    
    # Statistics
    stats = {
        'has_item_count': 0,
        'has_modifier_rules': 0,
        'has_display_header': 0
    }
    
    print("Deserializing options BLOBs...")
    with open(ERROR_LOG, 'a', encoding='utf-8') as error_log_file:
        for i, row in enumerate(rows):
            combo_group_id = int(row['id'])
            combo_name = row['name']
            options_hex = row['options_hex']
            
            # Parse options BLOB
            combo_rules_json = parse_options_blob(combo_group_id, combo_name, options_hex, error_log_file)
            
            if combo_rules_json:
                record = {
                    'combo_group_id': combo_group_id,
                    'combo_rules': combo_rules_json
                }
                all_rules.append(record)
                success_count += 1
                
                # Update statistics
                rules_obj = json.loads(combo_rules_json)
                if 'item_count' in rules_obj:
                    stats['has_item_count'] += 1
                if 'modifier_rules' in rules_obj:
                    stats['has_modifier_rules'] += 1
                if 'display_header' in rules_obj:
                    stats['has_display_header'] += 1
            elif not options_hex or options_hex == '0x':
                empty_count += 1
            else:
                error_count += 1
            
            if (i + 1) % 5000 == 0:
                print(f"  Processed {i + 1:,} / {len(rows):,} ({(i + 1) * 100 / len(rows):.1f}%)")
    
    print()
    print("=" * 70)
    print("Deserialization Results")
    print("=" * 70)
    print(f"  Successfully parsed: {success_count:,} combos")
    print(f"  Empty BLOBs: {empty_count:,} combos")
    print(f"  Errors: {error_count:,} combos")
    print(f"  Total combo_rules extracted: {len(all_rules):,}")
    print()
    print("Rule Breakdown:")
    print(f"  With item_count: {stats['has_item_count']:,}")
    print(f"  With modifier_rules: {stats['has_modifier_rules']:,}")
    print(f"  With display_header: {stats['has_display_header']:,}")
    print()
    
    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['combo_group_id', 'combo_rules']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_rules)
    
    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(all_rules):,}")
    print(f"  Error log: {ERROR_LOG}")
    print()
    print("Next step: Deserialize group BLOB (phase4_4_deserialize_group_blob.py)")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()


