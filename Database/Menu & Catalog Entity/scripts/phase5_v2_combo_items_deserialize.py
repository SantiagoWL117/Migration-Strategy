#!/usr/bin/env python3
"""
V2 Combo Items Deserialization Script
--------------------------------------
Deserializes V2 combo_groups_items JSON into flat CSV for loading to V3.

Input: menuca_v2_restaurants_combo_groups_items.csv (from staging)
Output: menuca_v2_combo_items_deserialized.csv

Format:
- Input: {"1": ["9552", "9553"], "2": ["9554", "9555"]}
- Output: Multiple rows with combo_group_v2_id, dish_v2_id, step, suffix, display_order
"""

import json
import csv
import sys
from pathlib import Path

# Configuration
INPUT_CSV = Path('..') / 'CSV' / 'menuca_v2_restaurants_combo_groups_items.csv'
OUTPUT_CSV = Path('..') / 'CSV' / 'menuca_v2_combo_items_deserialized.csv'

def deserialize_v2_combo_items():
    """Main deserialization function"""
    
    print("=" * 80)
    print("V2 Combo Items Deserialization")
    print("=" * 80)
    print(f"Input:  {INPUT_CSV}")
    print(f"Output: {OUTPUT_CSV}")
    print()
    
    # Counters
    total_rows = 0
    processed_rows = 0
    skipped_no_dishes = 0
    skipped_parse_error = 0
    skipped_wrong_format = 0
    output_items = []
    
    # Read input CSV
    try:
        with open(INPUT_CSV, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                total_rows += 1
                group_id = row['group_id']
                dishes_json = row.get('dishes', '').strip()
                
                # Skip if no dishes
                if not dishes_json or dishes_json == '':
                    skipped_no_dishes += 1
                    continue
                
                # Parse JSON
                try:
                    dishes_obj = json.loads(dishes_json)
                except json.JSONDecodeError as e:
                    print(f"WARNING: Failed to parse JSON for group_id {group_id}: {e}")
                    skipped_parse_error += 1
                    continue
                
                # Validate format (must be nested object)
                if not isinstance(dishes_obj, dict):
                    print(f"WARNING: Unexpected format for group_id {group_id} (not a dict)")
                    skipped_wrong_format += 1
                    continue
                
                # Process nested object format: {"1": ["dish1", "dish2"], "2": [...]}
                display_order = 0
                for step_key, dishes_array in dishes_obj.items():
                    try:
                        step_num = int(step_key)
                    except ValueError:
                        print(f"WARNING: Invalid step key '{step_key}' for group_id {group_id}")
                        continue
                    
                    # Process each dish in the step
                    if not isinstance(dishes_array, list):
                        print(f"WARNING: Step {step_key} is not a list for group_id {group_id}")
                        continue
                    
                    for dish_entry in dishes_array:
                        dish_entry = str(dish_entry).strip()
                        
                        if not dish_entry:
                            continue
                        
                        # Parse dish ID and suffix
                        if '|' in dish_entry:
                            parts = dish_entry.split('|', 1)
                            dish_id = parts[0].strip()
                            suffix = parts[1].strip() if len(parts) > 1 else None
                        else:
                            dish_id = dish_entry
                            suffix = None
                        
                        # Add to output
                        output_items.append({
                            'combo_group_v2_id': group_id,
                            'dish_v2_id': dish_id,
                            'step': step_num,
                            'suffix': suffix if suffix else '',
                            'display_order': display_order
                        })
                        display_order += 1
                
                processed_rows += 1
    
    except FileNotFoundError:
        print(f"ERROR: Input file not found: {INPUT_CSV}")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Unexpected error reading input: {e}")
        sys.exit(1)
    
    # Write output CSV
    if output_items:
        try:
            with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
                fieldnames = ['combo_group_v2_id', 'dish_v2_id', 'step', 'suffix', 'display_order']
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(output_items)
            
            print(f"SUCCESS: Created {OUTPUT_CSV}")
            print()
        except Exception as e:
            print(f"ERROR: Failed to write output CSV: {e}")
            sys.exit(1)
    else:
        print("WARNING: No items to output!")
        sys.exit(1)
    
    # Summary
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Total input rows:           {total_rows}")
    print(f"Processed (with dishes):    {processed_rows}")
    print(f"Skipped (no dishes):        {skipped_no_dishes}")
    print(f"Skipped (parse error):      {skipped_parse_error}")
    print(f"Skipped (wrong format):     {skipped_wrong_format}")
    print(f"Output items generated:     {len(output_items)}")
    print()
    print(f"Average items per combo:    {len(output_items) / processed_rows:.1f}" if processed_rows > 0 else "")
    print()
    
    # Step distribution
    step_counts = {}
    for item in output_items:
        step = item['step']
        step_counts[step] = step_counts.get(step, 0) + 1
    
    print("Step distribution:")
    for step in sorted(step_counts.keys()):
        print(f"  Step {step}: {step_counts[step]} items")
    print()
    
    # Suffix distribution
    suffix_counts = {'No suffix': 0}
    for item in output_items:
        suffix = item['suffix']
        if suffix:
            suffix_counts[suffix] = suffix_counts.get(suffix, 0) + 1
        else:
            suffix_counts['No suffix'] += 1
    
    print("Suffix distribution:")
    for suffix, count in sorted(suffix_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {suffix}: {count} items")
    print()
    
    print("=" * 80)
    print("SUCCESS: Deserialization complete!")
    print("=" * 80)
    print()
    print("Next steps:")
    print("1. Review the output CSV")
    print("2. Create staging table: staging.v2_combo_items_parsed")
    print("3. Import CSV to staging table")
    print("4. Load to V3 (combo_items + combo_steps)")
    print()

if __name__ == '__main__':
    deserialize_v2_combo_items()



