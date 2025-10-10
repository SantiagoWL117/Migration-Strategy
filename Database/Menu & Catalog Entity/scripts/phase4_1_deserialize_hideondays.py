"""
Phase 4.1: Deserialize hideOnDays BLOB to JSONB
================================================

Convert hex-encoded PHP serialized hideOnDays data to JSONB format.

Input:  menuca_v1_menu_hideondays_hex.csv
Output: menuca_v1_menu_hideondays_jsonb.csv

Author: AI Assistant
Date: 2025-01-09
"""

import csv
import json
import binascii
from phpserialize import loads as php_unserialize

INPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menu_hideondays_hex.csv"
OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_menu_hideondays_jsonb.csv"

# Day name mapping from PHP 3-letter codes to full names
DAY_MAPPING = {
    b'mon': 'monday',
    b'tue': 'tuesday',
    b'wed': 'wednesday',
    b'thu': 'thursday',
    b'fri': 'friday',
    b'sat': 'saturday',
    b'sun': 'sunday'
}

def hex_to_php_string(hex_value):
    """
    Convert hex string (0x...) to PHP serialized string.
    
    Args:
        hex_value: String like "0x613A32..."
    
    Returns:
        bytes: PHP serialized data
    """
    # Remove 0x prefix
    if hex_value.startswith('0x'):
        hex_value = hex_value[2:]
    
    # Convert hex to bytes
    return binascii.unhexlify(hex_value)

def deserialize_hideondays(hex_value):
    """
    Deserialize hideOnDays BLOB to JSONB availability schedule.
    
    Args:
        hex_value: Hex string like "0x613A32..."
    
    Returns:
        dict: JSONB structure with available_days array
    """
    try:
        # Convert hex to PHP serialized bytes
        php_bytes = hex_to_php_string(hex_value)
        
        # Deserialize PHP array
        php_data = php_unserialize(php_bytes)
        
        # php_data is typically a dict or OrderedDict like:
        # {0: b'mon', 1: b'tue', 2: b'wed', ...}
        # or an array of day codes
        
        available_days = []
        
        if isinstance(php_data, (dict, type({}.values()))):
            # It's a dict-like structure
            for key, value in php_data.items():
                # value is bytes like b'mon', b'tue', etc.
                if isinstance(value, bytes):
                    day_name = DAY_MAPPING.get(value, None)
                    if day_name:
                        available_days.append(day_name)
                elif isinstance(value, str):
                    # Sometimes it might be a string
                    day_name = DAY_MAPPING.get(value.encode(), None)
                    if day_name:
                        available_days.append(day_name)
        elif isinstance(php_data, (list, tuple)):
            # It's an array
            for value in php_data:
                if isinstance(value, bytes):
                    day_name = DAY_MAPPING.get(value, None)
                    if day_name:
                        available_days.append(day_name)
        
        # Return JSONB structure
        return {
            "available_days": available_days,
            "source": "v1_hideOnDays"
        }
        
    except Exception as e:
        print(f"ERROR deserializing {hex_value}: {e}")
        return {
            "available_days": [],
            "source": "v1_hideOnDays",
            "error": str(e)
        }

def main():
    print("=" * 70)
    print("Phase 4.1: Deserialize hideOnDays BLOB to JSONB")
    print("=" * 70)
    print()
    
    print(f"Reading: {INPUT_CSV}")
    
    results = []
    errors = 0
    
    with open(INPUT_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for i, row in enumerate(reader, 1):
            dish_id = row['id']
            hex_value = row['hideondays_hex']
            
            # Deserialize
            jsonb_data = deserialize_hideondays(hex_value)
            
            if 'error' in jsonb_data:
                errors += 1
            
            # Convert to JSON string for CSV
            jsonb_str = json.dumps(jsonb_data)
            
            results.append({
                'id': dish_id,
                'availability_schedule': jsonb_str
            })
            
            if i % 100 == 0:
                print(f"Processed {i} records...")
    
    print(f"\nDeserialized {len(results)} records")
    if errors > 0:
        print(f"WARNING: {errors} records had deserialization errors")
    
    # Write output CSV
    print(f"Writing to: {OUTPUT_CSV}")
    
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['id', 'availability_schedule'])
        writer.writeheader()
        writer.writerows(results)
    
    print(f"CSV created with {len(results)} rows")
    
    # Show sample
    print("\n" + "=" * 70)
    print("Sample Output (first 3 records):")
    print("=" * 70)
    for i, record in enumerate(results[:3], 1):
        print(f"\nRecord {i}:")
        print(f"  ID: {record['id']}")
        data = json.loads(record['availability_schedule'])
        print(f"  Days: {', '.join(data['available_days'])}")
    
    print("\n" + "=" * 70)
    print("SUCCESS!")
    print("=" * 70)
    print(f"Output: {OUTPUT_CSV}")
    print(f"Records: {len(results)}")
    print(f"Errors: {errors}")
    
    return 0

if __name__ == "__main__":
    try:
        exit(main())
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()
        exit(1)
