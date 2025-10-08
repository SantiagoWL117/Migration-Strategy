#!/usr/bin/env python3
"""
Marketing & Promotions - BLOB Deserialization Script
Deserialize PHP serialized BLOBs from staging.v1_deals:
  - exceptions: Array of excluded course/dish IDs
  - active_days: Day-of-week array (1-7 for Mon-Sun)
  - items: Dish ID array

Based on successful Menu & Catalog deserialization patterns (98.6% success rate)
"""

import phpserialize
import json
import sys

def deserialize_php_blob(blob_hex):
    """
    Deserialize a PHP serialized BLOB from hex encoding
    Returns: Python dict/list or None if failed
    """
    if not blob_hex or blob_hex == '':
        return None
    
    try:
        # Convert hex string to bytes
        blob_bytes = bytes.fromhex(blob_hex)
        
        # Deserialize PHP data
        deserialized = phpserialize.loads(blob_bytes, decode_strings=True)
        
        # Convert to Python native types
        return convert_php_to_python(deserialized)
    except Exception as e:
        print(f"  ❌ Deserialization failed: {e}", file=sys.stderr)
        return None

def convert_php_to_python(obj):
    """Convert PHP data structures to Python native types"""
    if isinstance(obj, bytes):
        return obj.decode('utf-8', errors='replace')
    elif isinstance(obj, dict):
        return {convert_php_to_python(k): convert_php_to_python(v) for k, v in obj.items()}
    elif isinstance(obj, (list, tuple)):
        return [convert_php_to_python(item) for item in obj]
    else:
        return obj

def deserialize_exceptions(blob_hex):
    """
    Deserialize 'exceptions' BLOB: array of course/dish IDs to exclude
    Example: a:1:{i:0;s:3:"884";} -> ["884"]
    """
    result = deserialize_php_blob(blob_hex)
    if result is None:
        return None
    
    # PHP serialized arrays are dicts with numeric keys
    if isinstance(result, dict):
        # Extract values (the IDs), ignore keys
        return [str(v) for v in result.values() if v]
    elif isinstance(result, list):
        return [str(v) for v in result if v]
    else:
        return [str(result)] if result else None

def deserialize_active_days(blob_text):
    """
    Deserialize 'active_days': PHP serialized day array
    Example: a:7:{i:0;s:1:"1";i:1;s:1:"2";...i:6;s:1:"7";}
    Returns: ["mon", "tue", "wed", ...] in V3 format
    """
    if not blob_text or blob_text == '':
        return None
    
    try:
        # Active_days is stored as TEXT, not BLOB, so it's already a string
        deserialized = phpserialize.loads(blob_text.encode('utf-8'), decode_strings=True)
        result = convert_php_to_python(deserialized)
        
        # Convert numeric days (1-7) to day names
        day_map = {
            '1': 'mon',
            '2': 'tue',
            '3': 'wed',
            '4': 'thu',
            '5': 'fri',
            '6': 'sat',
            '7': 'sun'
        }
        
        if isinstance(result, dict):
            day_numbers = [str(v) for v in result.values() if v]
        elif isinstance(result, list):
            day_numbers = [str(v) for v in result if v]
        else:
            day_numbers = [str(result)] if result else []
        
        return [day_map.get(day, day) for day in day_numbers if day in day_map]
    except Exception as e:
        print(f"  ❌ active_days deserialization failed: {e}", file=sys.stderr)
        return None

def deserialize_items(blob_text):
    """
    Deserialize 'items': PHP serialized item/dish ID array
    Example: a:1:{i:0;s:4:"5728";} -> ["5728"]
    """
    if not blob_text or blob_text == '':
        return None
    
    try:
        # Items is stored as TEXT
        deserialized = phpserialize.loads(blob_text.encode('utf-8'), decode_strings=True)
        result = convert_php_to_python(deserialized)
        
        if isinstance(result, dict):
            return [str(v) for v in result.values() if v]
        elif isinstance(result, list):
            return [str(v) for v in result if v]
        else:
            return [str(result)] if result else None
    except Exception as e:
        print(f"  ❌ items deserialization failed: {e}", file=sys.stderr)
        return None

def parse_active_dates(date_string):
    """
    Parse V1 active_dates format: "10/17,10/19,10/25"
    Returns: ["10/17", "10/19", "10/25"] or None
    
    Note: V1 dates don't include year - this is a known limitation
    We'll preserve the format and let Phase 4 handle year inference
    """
    if not date_string or date_string == '':
        return None
    
    try:
        dates = [d.strip() for d in date_string.split(',') if d.strip()]
        return dates if dates else None
    except Exception as e:
        print(f"  ❌ active_dates parsing failed: {e}", file=sys.stderr)
        return None

# Test function
if __name__ == "__main__":
    print("🧪 Testing BLOB deserialization functions...")
    
    # Test 1: exceptions (single ID)
    test_exceptions_1 = "613a313a7b693a303b733a333a22383834223b7d"  # a:1:{i:0;s:3:"884";}
    result = deserialize_exceptions(test_exceptions_1)
    print(f"  Test 1 (single exception): {result}")
    assert result == ["884"], f"Expected ['884'], got {result}"
    
    # Test 2: exceptions (multiple IDs)
    test_exceptions_2 = "613a323a7b693a303b733a333a22393736223b693a313b733a333a22393735223b7d"  # a:2:{i:0;s:3:"976";i:1;s:3:"975";}
    result = deserialize_exceptions(test_exceptions_2)
    print(f"  Test 2 (multiple exceptions): {result}")
    assert result == ["976", "975"], f"Expected ['976', '975'], got {result}"
    
    # Test 3: active_days (all 7 days)
    test_active_days = 'a:7:{i:0;s:1:"1";i:1;s:1:"2";i:2;s:1:"3";i:3;s:1:"4";i:4;s:1:"5";i:5;s:1:"6";i:6;s:1:"7";}'
    result = deserialize_active_days(test_active_days)
    print(f"  Test 3 (all 7 days): {result}")
    assert result == ["mon", "tue", "wed", "thu", "fri", "sat", "sun"], f"Expected all days, got {result}"
    
    # Test 4: items (single dish ID)
    test_items = 'a:1:{i:0;s:4:"5728";}'
    result = deserialize_items(test_items)
    print(f"  Test 4 (single item): {result}")
    assert result == ["5728"], f"Expected ['5728'], got {result}"
    
    # Test 5: active_dates parsing
    test_dates = "10/17,10/19,10/25,10/27"
    result = parse_active_dates(test_dates)
    print(f"  Test 5 (active_dates): {result}")
    assert result == ["10/17", "10/19", "10/25", "10/27"], f"Expected date array, got {result}"
    
    print("✅ All deserialization tests passed!")
    print("\n💡 Usage:")
    print("  This module provides functions for deserializing V1 deals BLOBs.")
    print("  Import and use in migration scripts:")
    print("  - deserialize_exceptions(blob_hex)")
    print("  - deserialize_active_days(blob_text)")
    print("  - deserialize_items(blob_text)")
    print("  - parse_active_dates(date_string)")

