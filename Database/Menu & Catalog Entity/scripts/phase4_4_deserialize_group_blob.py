#!/usr/bin/env python3
"""
Phase 4.4 Step 5: Deserialize combo_groups.group BLOB (MOST COMPLEX)
Parses group BLOB (modifier pricing) -> combo_group_modifier_pricing CSV
Triple-nested structure: modifier_type -> ingredient_group_id -> ingredient_id -> price
"""
import csv
import json
import binascii
import phpserialize
from typing import List, Dict
from decimal import Decimal, InvalidOperation

INPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_groups_hex.csv"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_group_modifier_pricing_deserialized.csv"
ERROR_LOG = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_group_modifier_pricing_errors.txt"

# Modifier type mapping
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

# Size order for multi-size pricing
SIZE_ORDER = ['S', 'M', 'L', 'XL', 'XXL']

# Price constraints
MIN_PRICE = Decimal('0.00')
MAX_PRICE = Decimal('50.00')

def validate_price(price_str: str) -> bool:
    """Validate price is within range."""
    try:
        price = Decimal(price_str.strip())
        return MIN_PRICE <= price <= MAX_PRICE
    except (InvalidOperation, ValueError):
        return False

def parse_group_blob(combo_group_id: int, group_hex: str, error_log_file) -> List[Dict]:
    """
    Parse group BLOB: triple-nested modifier pricing.
    
    Structure:
    {
      'ci': {                           # Modifier type
        7: {                            # Ingredient group ID
          278: "2,3,4",                 # Ingredient ID: multi-size prices
          281: "2,3,4",
          282: "0.00"                   # Single price
        }
      },
      'br': {...}
    }
    
    Returns:
        List of combo_group_modifier_pricing dictionaries
    """
    # Handle empty hex
    if not group_hex or group_hex == '0x':
        return []
    
    try:
        # Convert hex to bytes
        hex_str = group_hex[2:] if group_hex.startswith('0x') else group_hex
        blob_bytes = binascii.unhexlify(hex_str)
        
        # Parse PHP serialized data
        group_data = phpserialize.loads(blob_bytes)
        
        # Should be a dict
        if not isinstance(group_data, dict):
            error_log_file.write(f"Combo {combo_group_id}: Invalid BLOB structure (not dict)\n")
            return []
        
        records = []
        
        # Level 1: Modifier types
        for mod_type_key, mod_type_data in group_data.items():
            # Decode modifier type
            if isinstance(mod_type_key, bytes):
                mod_type = mod_type_key.decode('utf-8')
            else:
                mod_type = str(mod_type_key)
            
            # Map to full word
            full_mod_type = MODIFIER_TYPE_MAP.get(mod_type, mod_type)
            
            if not isinstance(mod_type_data, dict):
                continue
            
            # Level 2: Ingredient groups
            for ing_group_key, ing_group_data in mod_type_data.items():
                # Decode ingredient group ID
                try:
                    if isinstance(ing_group_key, int):
                        ingredient_group_id = ing_group_key
                    elif isinstance(ing_group_key, bytes):
                        ingredient_group_id = int(ing_group_key.decode('utf-8'))
                    else:
                        ingredient_group_id = int(ing_group_key)
                except:
                    continue
                
                if not isinstance(ing_group_data, dict):
                    continue
                
                # Level 3: Ingredients with pricing
                pricing_rules = {}
                
                for ingredient_key, price_val in ing_group_data.items():
                    # Decode ingredient ID
                    try:
                        if isinstance(ingredient_key, int):
                            ingredient_id = ingredient_key
                        elif isinstance(ingredient_key, bytes):
                            ingredient_id = int(ingredient_key.decode('utf-8'))
                        else:
                            ingredient_id = int(ingredient_key)
                    except:
                        continue
                    
                    # Decode price value
                    if isinstance(price_val, bytes):
                        price_str = price_val.decode('utf-8')
                    elif isinstance(price_val, str):
                        price_str = price_val
                    else:
                        price_str = str(price_val)
                    
                    # Check if multi-size pricing
                    if ',' in price_str:
                        # Multi-size pricing
                        prices = [p.strip() for p in price_str.split(',') if p.strip()]
                        
                        # Validate all prices
                        valid_prices = [p for p in prices if validate_price(p)]
                        
                        if len(valid_prices) != len(prices):
                            error_log_file.write(f"Combo {combo_group_id}, ModType {full_mod_type}, Group {ingredient_group_id}, Ingredient {ingredient_id}: Invalid multi-size prices\n")
                            continue
                        
                        # Map to sizes
                        price_by_size = {}
                        for i, price in enumerate(valid_prices):
                            if i < len(SIZE_ORDER):
                                price_by_size[SIZE_ORDER[i]] = float(Decimal(price))
                        
                        pricing_rules[str(ingredient_id)] = price_by_size
                    else:
                        # Single price
                        if not validate_price(price_str):
                            error_log_file.write(f"Combo {combo_group_id}, ModType {full_mod_type}, Group {ingredient_group_id}, Ingredient {ingredient_id}: Invalid price '{price_str}'\n")
                            continue
                        
                        pricing_rules[str(ingredient_id)] = float(Decimal(price_str))
                
                # Create record if we have pricing rules
                if pricing_rules:
                    record = {
                        'combo_group_id': combo_group_id,
                        'ingredient_group_id': ingredient_group_id,
                        'modifier_type': full_mod_type,
                        'pricing_rules': json.dumps(pricing_rules)
                    }
                    records.append(record)
        
        return records
    
    except Exception as e:
        error_log_file.write(f"Error parsing combo {combo_group_id}: {e}\n")
        return []

def main():
    print("=" * 70)
    print("Phase 4.4 Step 5: Deserialize group BLOB -> modifier_pricing")
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
        f.write("Phase 4.4 Step 5: group BLOB Deserialization Errors\n")
        f.write("=" * 50 + "\n\n")
    
    all_pricing = []
    success_count = 0
    error_count = 0
    empty_count = 0
    
    # Statistics
    stats = {
        'total_modifier_types': 0,
        'total_ingredient_groups': 0,
        'total_ingredients': 0
    }
    
    print("Deserializing group BLOBs (triple-nested structure)...")
    with open(ERROR_LOG, 'a', encoding='utf-8') as error_log_file:
        for i, row in enumerate(rows):
            combo_group_id = int(row['id'])
            group_hex = row['group_hex']
            
            # Parse group BLOB
            pricing_records = parse_group_blob(combo_group_id, group_hex, error_log_file)
            
            if pricing_records:
                all_pricing.extend(pricing_records)
                success_count += 1
                
                # Update statistics
                stats['total_ingredient_groups'] += len(pricing_records)
                for rec in pricing_records:
                    pricing_obj = json.loads(rec['pricing_rules'])
                    stats['total_ingredients'] += len(pricing_obj)
            elif not group_hex or group_hex == '0x':
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
    print(f"  Total modifier_pricing records: {len(all_pricing):,}")
    print()
    print("Pricing Breakdown:")
    print(f"  Total ingredient groups: {stats['total_ingredient_groups']:,}")
    print(f"  Total ingredients priced: {stats['total_ingredients']:,}")
    print()
    print(f"  Avg ingredient groups per combo: {stats['total_ingredient_groups'] / max(success_count, 1):.1f}")
    print(f"  Avg ingredients per group: {stats['total_ingredients'] / max(stats['total_ingredient_groups'], 1):.1f}")
    print()
    
    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['combo_group_id', 'ingredient_group_id', 'modifier_type', 'pricing_rules']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_pricing)
    
    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(all_pricing):,}")
    print(f"  Error log: {ERROR_LOG}")
    print()
    print("Next step: Create staging tables for all 3 deserialized CSVs")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()


