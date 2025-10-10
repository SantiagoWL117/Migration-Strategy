#!/usr/bin/env python3
"""
Phase 4.4 Step 3: Deserialize combo_groups.dish BLOB
Parses dish BLOB (array of dish IDs) → combo_items CSV
"""
import csv
import binascii
import phpserialize
from typing import List, Dict

INPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_groups_hex.csv"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_items_deserialized.csv"
ERROR_LOG = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_items_errors.txt"

def parse_dish_blob(combo_group_id: int, combo_name: str, dish_hex: str, error_log_file) -> List[Dict]:
    """
    Parse dish BLOB: array of dish IDs.
    
    Example BLOB:
    a:2:{i:0;i:456;i:1;i:789;}  → Dishes 456 and 789
    
    Returns:
        List of combo_item dictionaries
    """
    # Handle empty hex
    if not dish_hex or dish_hex == '0x':
        return []
    
    try:
        # Convert hex to bytes
        hex_str = dish_hex[2:] if dish_hex.startswith('0x') else dish_hex
        blob_bytes = binascii.unhexlify(hex_str)
        
        # Parse PHP serialized data
        dish_data = phpserialize.loads(blob_bytes)
        
        # Should be a dict/array
        if not isinstance(dish_data, dict):
            error_log_file.write(f"Combo {combo_group_id}: Invalid BLOB structure (not array)\n")
            return []
        
        records = []
        
        # Iterate through dish IDs
        for order_key, dish_id_val in dish_data.items():
            # Extract dish ID
            if isinstance(dish_id_val, int):
                dish_id = dish_id_val
            elif isinstance(dish_id_val, bytes):
                try:
                    dish_id = int(dish_id_val.decode('utf-8'))
                except:
                    error_log_file.write(f"Combo {combo_group_id}: Could not decode dish ID from bytes\n")
                    continue
            elif isinstance(dish_id_val, str):
                try:
                    # Handle decimal dish IDs like "756.2"
                    if '.' in dish_id_val:
                        dish_id = int(float(dish_id_val))
                    else:
                        dish_id = int(dish_id_val)
                except:
                    error_log_file.write(f"Combo {combo_group_id}: Could not parse dish ID '{dish_id_val}'\n")
                    continue
            else:
                error_log_file.write(f"Combo {combo_group_id}: Unknown dish ID type {type(dish_id_val)}\n")
                continue
            
            # Get display order from array index
            try:
                display_order = int(order_key)
            except:
                display_order = 0
            
            record = {
                'combo_group_id': combo_group_id,
                'dish_id': dish_id,
                'display_order': display_order
            }
            records.append(record)
        
        return records
    
    except Exception as e:
        error_log_file.write(f"Error parsing combo {combo_group_id}: {e}\n")
        return []

def main():
    print("=" * 70)
    print("Phase 4.4 Step 3: Deserialize dish BLOB -> combo_items")
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
        f.write("Phase 4.4 Step 3: dish BLOB Deserialization Errors\n")
        f.write("=" * 50 + "\n\n")
    
    all_items = []
    success_count = 0
    error_count = 0
    empty_count = 0
    
    # Statistics
    stats = {
        'single_dish': 0,
        'multi_dish': 0,
        'total_dishes': 0
    }
    
    print("Deserializing dish BLOBs...")
    with open(ERROR_LOG, 'a', encoding='utf-8') as error_log_file:
        for i, row in enumerate(rows):
            combo_group_id = int(row['id'])
            combo_name = row['name']
            dish_hex = row['dish_hex']
            
            # Parse dish BLOB
            items = parse_dish_blob(combo_group_id, combo_name, dish_hex, error_log_file)
            
            if items:
                all_items.extend(items)
                success_count += 1
                
                # Update statistics
                if len(items) == 1:
                    stats['single_dish'] += 1
                else:
                    stats['multi_dish'] += 1
                stats['total_dishes'] += len(items)
            elif not dish_hex or dish_hex == '0x':
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
    print(f"  Total combo_items extracted: {len(all_items):,}")
    print()
    print("Combo Distribution:")
    print(f"  Single-dish combos: {stats['single_dish']:,}")
    print(f"  Multi-dish combos: {stats['multi_dish']:,}")
    print()
    print(f"  Avg dishes per combo: {stats['total_dishes'] / max(success_count, 1):.1f}")
    print()
    
    # Write to CSV
    print(f"Writing to: {OUTPUT_CSV}")
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['combo_group_id', 'dish_id', 'display_order']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_items)
    
    print()
    print("=" * 70)
    print("Success!")
    print("=" * 70)
    print(f"  Output: {OUTPUT_CSV}")
    print(f"  Rows: {len(all_items):,}")
    print(f"  Error log: {ERROR_LOG}")
    print()
    print("Next step: Deserialize options BLOB (phase4_4_deserialize_options_blob.py)")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()

