#!/usr/bin/env python3
"""
Deserialize BLOB data for a specific batch
Usage: python deserialize_batch.py batch_1_30
"""

import json
import sys
import phpserialize
import re

def is_valid_time(time_str):
    """Check if time string is in valid HH:MM format"""
    if not time_str or not isinstance(time_str, str):
        return False
    
    match = re.match(r'^(\d{1,2}):(\d{2})$', time_str)
    if not match:
        return False
    
    hour, minute = map(int, match.groups())
    return 0 <= hour <= 23 and 0 <= minute <= 59

def fix_invalid_time(time_str):
    """Fix common invalid time formats"""
    if not time_str or not isinstance(time_str, str):
        return None
    
    # Try to parse HH:MM format
    match = re.match(r'^(\d{1,2}):(\d{2})$', time_str)
    if match:
        hour, minute = map(int, match.groups())
        
        # Fix invalid minutes (e.g., 15:90 -> skip this entry)
        if minute > 59:
            print(f"  WARNING: Invalid time {time_str} - minutes > 59, skipping entry")
            return None
        
        # Fix invalid hours
        if hour > 23:
            hour = 23
            print(f"  WARNING: Invalid time {time_str} - hour > 23, capped to 23:{minute:02d}")
        
        return f"{hour:02d}:{minute:02d}"
    
    return None

if len(sys.argv) < 2:
    print("Usage: python deserialize_batch.py <batch_name>")
    print("Example: python deserialize_batch.py batch_1_30")
    sys.exit(1)

batch_name = sys.argv[1]

print(f"Deserializing {batch_name}...")
print("="*60)

# Day mapping
day_map = {'mon': 0, 'tue': 1, 'wed': 2, 'thu': 3, 'fri': 4, 'sat': 5, 'sun': 6}

def unescape_blob(blob_data):
    """Unescape the BLOB data"""
    if blob_data.startswith("_binary '") and blob_data.endswith("'"):
        blob_data = blob_data[9:-1]
    blob_data = blob_data.replace("\\'", "'")
    blob_data = blob_data.replace('\\"', '"')
    blob_data = blob_data.replace('\\\\', '\\')
    return blob_data

def deserialize_schedule(blob_entry):
    """Deserialize delivery schedule BLOB"""
    try:
        blob_data = unescape_blob(blob_entry['blob_data'])
        data = phpserialize.loads(blob_data.encode('utf-8'), decode_strings=True)
        
        schedule_entries = []
        if isinstance(data, dict):
            start_times = data.get('start', {}) or data.get(b'start', {})
            stop_times = data.get('stop', {}) or data.get(b'stop', {})
            
            for day_key in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']:
                day_byte = day_key.encode('utf-8')
                day_start = start_times.get(day_key, {}) or start_times.get(day_byte, {})
                day_stop = stop_times.get(day_key, {}) or stop_times.get(day_byte, {})
                
                for i in range(1, 4):
                    key_str = f'i{i}'
                    key_byte = key_str.encode('utf-8')
                    start_time = day_start.get(key_str, '') or day_start.get(key_byte, '')
                    stop_time = day_stop.get(key_str, '') or day_stop.get(key_byte, '')
                    
                    if isinstance(start_time, bytes):
                        start_time = start_time.decode('utf-8')
                    if isinstance(stop_time, bytes):
                        stop_time = stop_time.decode('utf-8')
                    
                    if start_time and start_time != '0' and stop_time:
                        # Validate and fix time format (HH:MM)
                        if not is_valid_time(start_time):
                            start_time = fix_invalid_time(start_time)
                        if not is_valid_time(stop_time):
                            stop_time = fix_invalid_time(stop_time)
                        
                        # Only add if both times are valid after fixing
                        if start_time and stop_time:
                            day_number = day_map[day_key] + 1  # Convert to 1-7
                            schedule_entries.append({
                                'restaurant_id': blob_entry['v3_id'],
                                'type': 'delivery',
                                'day_start': day_number,
                                'day_stop': day_number,
                                'time_start': start_time,
                                'time_stop': stop_time
                            })
        
        return {"status": "success", "schedule_entries": schedule_entries}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def deserialize_area(blob_entry):
    """Deserialize delivery area BLOB - FIXED VERSION using Phase 1 approach"""
    try:
        blob_data = blob_entry['blob_data']
        v1_id = blob_entry['v1_id']
        v3_id = blob_entry['v3_id']
        name = blob_entry['restaurant_name']
        
        # Unescape the data
        unescaped = blob_data.replace('\\"', '"')
        
        # Extract JSON string from serialized format using REGEX
        # Format: s:LENGTH:"JSON_STRING"
        match = re.search(r's:(\d+):"(\{.+?\})";?\s*(?:<br>)?', unescaped, re.DOTALL)
        
        if not match:
            return {"status": "error", "message": "Could not extract JSON from BLOB"}
        
        json_string = match.group(2)
        
        # Decode the JSON directly
        areas = json.loads(json_string)
        
        area_entries = []
        
        # V1 format: {"1":[polygon points],"2":[...],...}
        for area_num, coordinates in areas.items():
            if not coordinates or not isinstance(coordinates, list):
                continue
            
            # Convert coordinates to PostGIS format
            points = []
            for point in coordinates:
                lat = None
                lng = None
                
                # Points can have various key names in V1
                # Common patterns: Ya/Za, ob/pb, hb/ib, lat/lng, k/A, nb/mb, lb
                for key in ['lat', 'ob', 'Ya', 'k', 'nb', 'lb', 'hb']:
                    if key in point:
                        lat = point[key]
                        break
                
                for key in ['lng', 'pb', 'Za', 'A', 'mb', 'ib']:
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
                    'polygon_wkt': polygon_wkt
                })
        
        return {"status": "success", "area_entries": area_entries}
    
    except Exception as e:
        return {"status": "error", "message": str(e)}

def deserialize_fee(blob_entry):
    """Deserialize fee BLOB"""
    try:
        blob_data = unescape_blob(blob_entry['blob_data'])
        if len(blob_data) < 5:
            return {"status": "error", "message": "BLOB too short"}
        
        data = phpserialize.loads(blob_data.encode('utf-8'), decode_strings=True)
        
        fee_entries = []
        if isinstance(data, dict):
            for tier, value in data.items():
                if isinstance(tier, bytes):
                    tier = tier.decode('utf-8')
                if isinstance(value, bytes):
                    value = value.decode('utf-8')
                
                # Skip empty values
                if not value or value == '':
                    continue
                
                # Ensure we have a valid numeric value
                try:
                    fee_value = float(value)
                except (ValueError, TypeError):
                    continue
                
                fee_entries.append({
                    'restaurant_id': blob_entry['v3_id'],
                    'fee_tier': int(tier) if str(tier).isdigit() else 0,
                    'fee_value': fee_value,  # Store as float, not string
                    'fee_type': 'flat'
                })
        
        return {"status": "success", "fee_entries": fee_entries}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# Load batch data
with open(f'{batch_name}_blob_delivery_schedule.json', 'r', encoding='utf-8') as f:
    schedules = json.load(f)

with open(f'{batch_name}_blob_deliveryArea.json', 'r', encoding='utf-8') as f:
    areas = json.load(f)

with open(f'{batch_name}_blob_fee.json', 'r', encoding='utf-8') as f:
    fees = json.load(f)

# Process schedules
print(f"\nProcessing {len(schedules)} schedule BLOBs...")
deserialized_schedules = {}
for entry in schedules:
    result = deserialize_schedule(entry)
    deserialized_schedules[entry['v1_id']] = {
        'v1_id': entry['v1_id'],
        'v3_id': entry['v3_id'],
        'restaurant_name': entry['restaurant_name'],
        'schedule_entries': result.get('schedule_entries', [])
    }

# Process areas
print(f"Processing {len(areas)} area BLOBs...")
deserialized_areas = {}
for entry in areas:
    result = deserialize_area(entry)
    deserialized_areas[entry['v1_id']] = {
        'v1_id': entry['v1_id'],
        'v3_id': entry['v3_id'],
        'restaurant_name': entry['restaurant_name'],
        'area_entries': result.get('area_entries', [])
    }

# Process fees
print(f"Processing {len(fees)} fee BLOBs...")
deserialized_fees = {}
for entry in fees:
    result = deserialize_fee(entry)
    deserialized_fees[entry['v1_id']] = {
        'v1_id': entry['v1_id'],
        'v3_id': entry['v3_id'],
        'restaurant_name': entry['restaurant_name'],
        'fee_entries': result.get('fee_entries', [])
    }

# Save deserialized data
with open(f'{batch_name}_deserialized_schedules.json', 'w', encoding='utf-8') as f:
    json.dump(deserialized_schedules, f, indent=2)

with open(f'{batch_name}_deserialized_areas.json', 'w', encoding='utf-8') as f:
    json.dump(deserialized_areas, f, indent=2)

with open(f'{batch_name}_deserialized_fees.json', 'w', encoding='utf-8') as f:
    json.dump(deserialized_fees, f, indent=2)

print(f"\n[OK] Saved deserialized data:")
print(f"  - {batch_name}_deserialized_schedules.json")
print(f"  - {batch_name}_deserialized_areas.json")
print(f"  - {batch_name}_deserialized_fees.json")

