#!/usr/bin/env python3
"""
Phase 4.2: Deserialize menuothers.content BLOB to dish_modifiers
Creates 100K-350K dish_modifier records from 70,381 menuothers rows
"""
import csv
import json
import phpserialize
import binascii
from decimal import Decimal, InvalidOperation
from typing import List, Dict, Optional

INPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menuothers_hex.csv"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menuothers_deserialized.csv"
ERROR_LOG = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menuothers_errors.txt"

# Size order mapping (approved decision: standard order fallback)
SIZE_ORDER = ['S', 'M', 'L', 'XL', 'XXL']

# Price constraints (approved decision: $0-$50 range)
MIN_PRICE = Decimal('0.00')
MAX_PRICE = Decimal('50.00')

# Type code mapping (approved decision: full words)
TYPE_MAPPING = {
    'ci': 'custom_ingredients',
    'e': 'extras',
    'sd': 'side_dishes',
    'd': 'drinks',
    'sa': 'sauces',
    'br': 'bread',
    'dr': 'dressing',
    'cm': 'cooking_method'
}

def validate_price(price_str: str) -> Optional[Decimal]:
    """Validate and convert price string to Decimal."""
    try:
        price = Decimal(price_str.strip())
        if price < MIN_PRICE or price > MAX_PRICE:
            return None
        return price
    except (InvalidOperation, ValueError):
        return None

def parse_menuothers_blob(
    menuothers_id: int,
    restaurant: int,
    dish_id: int,
    content_hex: str,
    modifier_type_code: str,
    group_id: Optional[int],
    error_log_file
) -> List[Dict]:
    """
    Parse PHP serialized content BLOB and create dish_modifier records.
    
    Returns:
        List of dish_modifier dictionaries
    """
    # Handle NULL/empty hex
    if not content_hex or content_hex == '0x' or content_hex.upper() == 'NULL':
        return []
    
    try:
        # Convert hex to bytes
        # Remove '0x' prefix
        hex_str = content_hex[2:] if content_hex.startswith('0x') else content_hex
        blob_bytes = binascii.unhexlify(hex_str)
        
        # Parse PHP serialized data
        data = phpserialize.loads(blob_bytes)
        
        # Extract content dict and radio group
        content_dict = data.get(b'content', {})
        if isinstance(content_dict, bytes):
            content_dict = {}
        
        radio_group = data.get(b'radio', group_id)
        if isinstance(radio_group, bytes):
            try:
                radio_group = int(radio_group.decode('utf-8'))
            except:
                radio_group = group_id
        
        # Map type code to full name
        modifier_type = TYPE_MAPPING.get(modifier_type_code, 'other')
        
        records = []
        
        # Iterate through ingredients in content
        for ing_id_key, price_str in content_dict.items():
            # Extract ingredient ID
            if isinstance(ing_id_key, int):
                ingredient_id = ing_id_key
            else:
                try:
                    ingredient_id = int(ing_id_key)
                except:
                    continue
            
            # Extract price string
            if isinstance(price_str, bytes):
                price_str = price_str.decode('utf-8')
            elif not isinstance(price_str, str):
                price_str = str(price_str)
            
            # Check if multi-size pricing (comma-separated)
            if ',' in price_str:
                # Multi-size pricing
                prices = [p.strip() for p in price_str.split(',') if p.strip()]
                
                # Validate all prices
                validated_prices = []
                for p in prices:
                    validated = validate_price(p)
                    if validated is not None:
                        validated_prices.append(float(validated))
                    else:
                        break
                
                if len(validated_prices) != len(prices):
                    # Skip if any price invalid
                    continue
                
                # Map prices to sizes
                price_by_size = {}
                for i, price in enumerate(validated_prices):
                    if i < len(SIZE_ORDER):
                        price_by_size[SIZE_ORDER[i]] = price
                
                record = {
                    'menuothers_id': menuothers_id,
                    'restaurant': restaurant,
                    'dish_id': dish_id,
                    'ingredient_id': ingredient_id,
                    'ingredient_group_id': int(radio_group) if radio_group else '',
                    'base_price': '',
                    'price_by_size': json.dumps(price_by_size),
                    'modifier_type': modifier_type,
                    'is_included': 'false'
                }
                
            else:
                # Single price
                price = validate_price(price_str)
                
                if price is None:
                    continue
                
                record = {
                    'menuothers_id': menuothers_id,
                    'restaurant': restaurant,
                    'dish_id': dish_id,
                    'ingredient_id': ingredient_id,
                    'ingredient_group_id': int(radio_group) if radio_group else '',
                    'base_price': float(price),
                    'price_by_size': '',
                    'modifier_type': modifier_type,
                    'is_included': 'true' if price == Decimal('0.00') else 'false'
                }
            
            records.append(record)
        
        return records
    
    except Exception as e:
        # Log error
        error_log_file.write(f"Error parsing menuothers_id={menuothers_id}: {e}\n")
        return []

def main():
    print("=" * 70)
    print("Phase 4.2: Deserialize menuothers.content BLOB")
    print("=" * 70)
    print()

    print(f"Reading: {INPUT_CSV}")
    
    with open(INPUT_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    
    print(f"  Loaded {len(rows):,} menuothers records")
    print()
    
    # Initialize error log
    with open(ERROR_LOG, 'w', encoding='utf-8') as f:
        f.write("Phase 4.2: menuothers Deserialization Errors\n")
        f.write("=" * 50 + "\n\n")
    
    all_modifiers = []
    success_count = 0
    error_count = 0
    
    # Statistics
    stats = {
        'single_price': 0,
        'multi_size': 0,
        'free_modifiers': 0,
        'by_type': {}
    }
    
    print("Deserializing BLOBs...")
    with open(ERROR_LOG, 'a', encoding='utf-8') as error_log_file:
        for i, row in enumerate(rows):
            menuothers_id = int(row['id'])
            restaurant = int(row['restaurant'])
            dish_id = int(row['dishId'])
            content_hex = row['content_hex']
            modifier_type = row['type']
            group_id = int(row['groupId']) if row['groupId'] and row['groupId'].strip() else None
            
            # Parse BLOB
            modifiers = parse_menuothers_blob(
                menuothers_id,
                restaurant,
                dish_id,
                content_hex,
                modifier_type,
                group_id,
                error_log_file
            )
            
            if modifiers:
                all_modifiers.extend(modifiers)
                success_count += 1
                
                # Update statistics
                for mod in modifiers:
                    if mod['base_price'] != '':
                        stats['single_price'] += 1
                        if mod['is_included'] == 'true':
                            stats['free_modifiers'] += 1
                    else:
                        stats['multi_size'] += 1
                    
                    mod_type = mod['modifier_type']
                    stats['by_type'][mod_type] = stats['by_type'].get(mod_type, 0) + 1
            else:
                error_count += 1
            
            if (i + 1) % 10000 == 0:
                print(f"  Processed {i + 1:,} / {len(rows):,} ({(i + 1) * 100 / len(rows):.1f}%)")
    
    print()
    print("=" * 70)
    print("Deserialization Results")
    print("=" * 70)
    print(f"  Successfully parsed: {success_count:,} menuothers rows")
    print(f"  Errors/Empty: {error_count:,} menuothers rows")
    print(f"  Total modifiers extracted: {len(all_modifiers):,}")
    print()
    print("Pricing Breakdown:")
    print(f"  Single price modifiers: {stats['single_price']:,}")
    print(f"  Multi-size modifiers: {stats['multi_size']:,}")
    print(f"  Free/included modifiers: {stats['free_modifiers']:,}")
    print()
    print("Modifier Type Breakdown:")
    for mod_type, count in sorted(stats['by_type'].items(), key=lambda x: x[1], reverse=True):
        print(f"  {mod_type}: {count:,}")
    print()
    
    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        fieldnames = [
            'menuothers_id', 'restaurant', 'dish_id', 'ingredient_id', 
            'ingredient_group_id', 'base_price', 'price_by_size', 
            'modifier_type', 'is_included'
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_modifiers)
    
    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(all_modifiers):,}")
    print(f"  Error log: {ERROR_LOG}")
    print()
    print("Next step: Load to staging table (staging.v1_menuothers_parsed)")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()

