#!/usr/bin/env python3
"""
Deserialize BLOB data from V1 dump using Python
Converts serialized PHP arrays to structured data for V3 insertion
"""

import json
import re

# Try to import phpserialize, if not available we'll use manual parsing
try:
    from phpserialize import loads as php_unserialize
    HAS_PHPSERIALIZE = True
except ImportError:
    HAS_PHPSERIALIZE = False
    print("WARNING: phpserialize not installed. Install with: pip install phpserialize")
    print("Attempting manual PHP deserialization...\n")

def manual_php_unserialize(data):
    """
    Manual PHP unserialize for simple arrays
    This handles the basic format used in the delivery data
    """
    # Remove PHP serialization markers and parse manually
    # Format: a:2:{s:5:"start";a:7:{...
    
    def parse_value(s, pos):
        """Parse a single PHP serialized value"""
        if pos >= len(s):
            return None, pos
        
        # String: s:len:"value"
        if s[pos:pos+2] == 's:':
            match = re.match(r's:(\d+):"(.*?)";', s[pos:], re.DOTALL)
            if match:
                length = int(match.group(1))
                value = match.group(2)
                return value, pos + match.end()
        
        # Integer: i:value;
        if s[pos:pos+2] == 'i:':
            match = re.match(r'i:(\d+);', s[pos:])
            if match:
                return int(match.group(1)), pos + match.end()
        
        # Array: a:size:{key1;value1;key2;value2;...}
        if s[pos:pos+2] == 'a:':
            match = re.match(r'a:(\d+):\{', s[pos:])
            if match:
                size = int(match.group(1))
                pos = pos + match.end()
                result = {}
                
                for _ in range(size):
                    # Parse key
                    key, pos = parse_value(s, pos)
                    # Parse value
                    value, pos = parse_value(s, pos)
                    if key is not None:
                        result[key] = value
                
                # Skip closing }
                if pos < len(s) and s[pos] == '}':
                    pos += 1
                
                return result, pos
        
        return None, pos
    
    result, _ = parse_value(data, 0)
    return result

print("=" * 60)
print("PHP BLOB Deserializer for MVP Restaurants")
print("=" * 60)
print()

# Load the JSON files
with open('all_restaurants_blob_deliveryArea.json', 'r', encoding='utf-8') as f:
    delivery_area_data = json.load(f)

with open('all_restaurants_blob_delivery_schedule.json', 'r', encoding='utf-8') as f:
    delivery_schedule_data = json.load(f)

with open('all_restaurants_blob_fee.json', 'r', encoding='utf-8') as f:
    fee_data = json.load(f)

print(f"Loaded BLOB data:")
print(f"  - Delivery Areas: {len(delivery_area_data)} restaurants")
print(f"  - Delivery Schedules: {len(delivery_schedule_data)} restaurants")
print(f"  - Fees: {len(fee_data)} restaurants")
print()

# Process Delivery Schedules
print("Processing Delivery Schedules...")
print("-" * 60)

schedule_results = {}

for restaurant in delivery_schedule_data:
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['restaurant_name']
    blob_data = restaurant['blob_data']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    # The blob data has escaped quotes that need to be unescaped
    # Replace \" with " to get proper PHP serialized format
    unescaped = blob_data.replace('\\"', '"')
    
    # Convert to bytes
    blob_bytes = unescaped.encode('utf-8')
    
    try:
        if HAS_PHPSERIALIZE:
            schedule = php_unserialize(blob_bytes)
        else:
            schedule = manual_php_unserialize(blob_data)
        
        if not schedule:
            print(f"  ERROR: Could not deserialize schedule data")
            continue
        
        print(f"  Successfully deserialized schedule data")
        
        # Convert bytes keys to strings if needed
        if isinstance(list(schedule.keys())[0], bytes):
            schedule = {k.decode('utf-8') if isinstance(k, bytes) else k: v for k, v in schedule.items()}
        
        # V1 format: dict with 'start' and 'stop' keys (as bytes)
        schedule_entries = []
        
        # Check if keys are bytes
        start_key = b'start' if b'start' in schedule else 'start'
        stop_key = b'stop' if b'stop' in schedule else 'stop'
        
        if start_key in schedule and stop_key in schedule:
            days = [b'mon', b'tue', b'wed', b'thu', b'fri', b'sat', b'sun']
            day_names = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
            
            for day_index, (day, day_name) in enumerate(zip(days, day_names)):
                if day in schedule[start_key] and day in schedule[stop_key]:
                    start_times = schedule[start_key][day]
                    stop_times = schedule[stop_key][day]
                    
                    # Process each time period (i1, i2, i3) - keys are bytes
                    for period_index, period in enumerate([b'i1', b'i2', b'i3']):
                        start_time = start_times.get(period, b'')
                        stop_time = stop_times.get(period, b'')
                        
                        # Convert bytes to string
                        if isinstance(start_time, bytes):
                            start_time = start_time.decode('utf-8')
                        if isinstance(stop_time, bytes):
                            stop_time = stop_time.decode('utf-8')
                        
                        # Skip if no start time
                        if not start_time or start_time == '0':
                            continue
                        
                        # V3 uses day_start/day_stop with values 1-7 (Mon=1, Sun=7)
                        # day_index is already 0-6, so we add 1
                        day_number = day_index + 1
                        schedule_entries.append({
                            'restaurant_id': v3_id,
                            'type': 'delivery',
                            'day_start': day_number,
                            'day_stop': day_number,  # Same day
                            'day_name': day_name.capitalize(),
                            'period': period_index + 1,
                            'time_start': start_time,
                            'time_stop': stop_time if stop_time else '23:59'
                        })
            
            print(f"  Extracted {len(schedule_entries)} schedule entries")
            if schedule_entries:
                for entry in schedule_entries[:5]:  # Show first 5
                    print(f"    - {entry['day_name']}: {entry['time_start']} - {entry['time_stop']}")
                if len(schedule_entries) > 5:
                    print(f"    ... and {len(schedule_entries) - 5} more")
        
        schedule_results[v1_id] = {
            'v1_id': v1_id,
            'v3_id': v3_id,
            'restaurant_name': name,
            'schedule_entries': schedule_entries
        }
    
    except Exception as e:
        print(f"  ERROR: {str(e)}")
        print(f"  Raw data (first 100 chars): {blob_data[:100]}")

# Process Delivery Areas
print("\n" + "=" * 60)
print("Processing Delivery Areas...")
print("-" * 60)

area_results = {}

for restaurant in delivery_area_data:
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['restaurant_name']
    blob_data = restaurant['blob_data']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    # The deliveryArea BLOB is a JSON string stored in serialized format
    # Format: s:123:"{"1":[...],"2":[...],...}"
    
    # First unescape the data
    unescaped = blob_data.replace('\\"', '"')
    
    # Extract JSON string from serialized format
    # The format is s:LENGTH:"JSON_STRING" but after unescaping quotes are literal
    # Match: s:NUMBER:"{...}"
    match = re.search(r's:(\d+):"(\{.+?\})";?\s*(?:<br>)?', unescaped, re.DOTALL)
    if match:
        json_string = match.group(2)  # Group 2 is the JSON content
        
        try:
            # Decode the JSON
            areas = json.loads(json_string)
            
            print(f"  Successfully decoded area data")
            
            # V1 format: {"1":[polygon points],"2":[...],...}
            area_entries = []
            
            for area_num, coordinates in areas.items():
                if not coordinates or not isinstance(coordinates, list):
                    continue
                
                # Convert coordinates to PostGIS format
                points = []
                for point in coordinates:
                    lat = None
                    lng = None
                    
                    # Points can have various key names
                    for key in ['lat', 'ob', 'Ya', 'k', 'nb', 'lb']:
                        if key in point:
                            lat = point[key]
                            break
                    
                    for key in ['lng', 'pb', 'Za', 'A', 'mb']:
                        if key in point:
                            lng = point[key]
                            break
                    
                    if lat is not None and lng is not None:
                        points.append(f"{lng} {lat}")  # PostGIS uses lng,lat order
                
                if points:
                    # Close the polygon by repeating the first point
                    points.append(points[0])
                    
                    polygon_wkt = f"POLYGON(({','.join(points)}))"
                    
                    area_entries.append({
                        'restaurant_id': v3_id,
                        'area_number': area_num,
                        'area_name': f"Delivery Zone {area_num}",
                        'coordinates_count': len(coordinates),
                        'polygon_wkt': polygon_wkt
                    })
                    
                    print(f"  Zone {area_num}: {len(coordinates)} coordinates")
            
            area_results[v1_id] = {
                'v1_id': v1_id,
                'v3_id': v3_id,
                'restaurant_name': name,
                'area_entries': area_entries
            }
        
        except json.JSONDecodeError as e:
            print(f"  ERROR: Could not decode JSON - {str(e)}")
    else:
        print(f"  ERROR: Could not extract JSON from serialized format")

# Process Fees
print("\n" + "=" * 60)
print("Processing Delivery Fees...")
print("-" * 60)

fee_results = {}

for restaurant in fee_data:
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['restaurant_name']
    blob_data = restaurant['blob_data']
    
    print(f"\n[{v1_id}] {name} (V3 ID: {v3_id})")
    
    # The blob data has escaped quotes that need to be unescaped
    unescaped = blob_data.replace('\\"', '"')
    
    # Convert to bytes
    blob_bytes = unescaped.encode('utf-8')
    
    try:
        if HAS_PHPSERIALIZE:
            fees = php_unserialize(blob_bytes)
        else:
            fees = manual_php_unserialize(blob_data)
        
        if not fees:
            # Try to handle as simple value
            if blob_data and blob_data.replace('.', '').isdigit():
                fees = [blob_data]
                print(f"  Using simple numeric value: {blob_data}")
            else:
                print(f"  ERROR: Could not deserialize fee data")
                continue
        
        print(f"  Successfully deserialized fee data")
        
        # V1 format: array with indices 0-9 for different fee tiers
        fee_entries = []
        
        if isinstance(fees, dict):
            for index, fee_value in fees.items():
                if fee_value and fee_value != '0' and fee_value != '' and fee_value != b'0' and fee_value != b'':
                    # Convert index to int if it's a string
                    tier_index = int(index) if isinstance(index, str) and index.isdigit() else index
                    
                    # Convert bytes to string if needed
                    if isinstance(fee_value, bytes):
                        fee_value = fee_value.decode('utf-8')
                    
                    fee_entries.append({
                        'restaurant_id': v3_id,
                        'fee_tier': tier_index,
                        'fee_value': fee_value,
                        'fee_type': 'flat' if tier_index == 0 else 'tiered'
                    })
                    
                    print(f"  Tier {tier_index}: ${fee_value}")
        elif isinstance(fees, list):
            for index, fee_value in enumerate(fees):
                if fee_value and fee_value != '0' and fee_value != '' and fee_value != b'0' and fee_value != b'':
                    # Convert bytes to string if needed
                    if isinstance(fee_value, bytes):
                        fee_value = fee_value.decode('utf-8')
                    
                    fee_entries.append({
                        'restaurant_id': v3_id,
                        'fee_tier': index,
                        'fee_value': fee_value,
                        'fee_type': 'flat' if index == 0 else 'tiered'
                    })
                    
                    print(f"  Tier {index}: ${fee_value}")
        
        fee_results[v1_id] = {
            'v1_id': v1_id,
            'v3_id': v3_id,
            'restaurant_name': name,
            'fee_entries': fee_entries
        }
    
    except Exception as e:
        print(f"  ERROR: {str(e)}")

# Save results
print("\n" + "=" * 60)
print("Saving deserialized data...")
print("-" * 60)

with open('deserialized_schedules.json', 'w', encoding='utf-8') as f:
    json.dump(schedule_results, f, indent=2, ensure_ascii=False)
print("  Saved: deserialized_schedules.json")

with open('deserialized_areas.json', 'w', encoding='utf-8') as f:
    json.dump(area_results, f, indent=2, ensure_ascii=False)
print("  Saved: deserialized_areas.json")

with open('deserialized_fees.json', 'w', encoding='utf-8') as f:
    json.dump(fee_results, f, indent=2, ensure_ascii=False)
print("  Saved: deserialized_fees.json")

print("\n" + "=" * 60)
print("BLOB Deserialization Complete!")
print("=" * 60)
print(f"\nSummary:")
print(f"  - Processed {len(schedule_results)} schedule records")
print(f"  - Processed {len(area_results)} delivery area records")
print(f"  - Processed {len(fee_results)} fee records")
print(f"\nNext: These files will be used to generate SQL INSERT statements")
print()

