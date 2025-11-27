# Phase 2 Deserialization Fix - Root Cause Analysis

**Date:** November 25, 2025  
**Status:** ✅ ROOT CAUSE IDENTIFIED

---

## Problem Summary

**Phase 1**: Successfully deserialized 5 restaurants → 6 polygons  
**Phase 2**: Failed to deserialize 159 restaurants → 0 polygons

---

## Root Cause: Different Deserialization Logic

### Phase 1 Approach (WORKING) ✅

**File:** `extracted_data/phase1_mvp/deserialize_blobs.py`

**Lines 218-266:**
```python
# Extract JSON string from serialized format using REGEX
match = re.search(r's:(\d+):"(\{.+?\})";?\s*(?:<br>)?', unescaped, re.DOTALL)
if match:
    json_string = match.group(2)  # Get the JSON content directly
    
    # Decode the JSON DIRECTLY
    areas = json.loads(json_string)
    
    # V1 format: {"1":[polygon points],"2":[...],...}
    for area_num, coordinates in areas.items():
        if not coordinates or not isinstance(coordinates, list):
            continue
        
        # Process coordinates directly - they're already in the right format
        for point in coordinates:
            # Extract lat/lng with flexible key names
            for key in ['lat', 'ob', 'Ya', 'k', 'nb', 'lb']:
                if key in point:
                    lat = point[key]
            for key in ['lng', 'pb', 'Za', 'A', 'mb']:
                if key in point:
                    lng = point[key]
```

**Key Steps:**
1. Unescape the BLOB string
2. **Regex extract** the JSON string from PHP serialization wrapper
3. **json.loads()** to parse JSON directly
4. Iterate over areas dict
5. Build polygon WKT

### Phase 2 Approach (FAILED) ❌

**File:** `extracted_data/phase2_all_restaurants/deserialize_batch.py`

**Lines 120-156:**
```python
def deserialize_area(blob_entry):
    try:
        blob_data = unescape_blob(blob_entry['blob_data'])
        data = phpserialize.loads(blob_data.encode('utf-8'), decode_strings=True)
        
        area_entries = []
        if isinstance(data, dict):
            for area_num, area_data in data.items():
                if isinstance(area_num, bytes):
                    area_num = area_num.decode('utf-8')
                if isinstance(area_data, dict):  # ← WRONG ASSUMPTION!
                    coords_json = area_data.get('deliveryArea', '')  # ← WRONG KEY!
                    # ... tries to extract JSON from nested dict
```

**Key Steps:**
1. Unescape the BLOB string
2. **phpserialize.loads()** to deserialize PHP object
3. Expects nested dict with `deliveryArea` key ← **WRONG!**
4. Never finds the key
5. area_entries remains empty

---

## Why Phase 2 Failed

### Incorrect Assumption

Phase 2 script assumes V1 BLOB structure is:
```php
array(
  '1' => array('deliveryArea' => '{"paths":[...]}'),
  '2' => array('deliveryArea' => '{"paths":[...]}'),
)
```

### Actual V1 BLOB Structure

The actual structure is:
```php
// PHP serialized string containing JSON:
s:928:"{"1":[{"Ya":45.44,"Za":-75.62},...],"2":[],...}"
```

Which represents:
```json
{
  "1": [{"Ya":45.44,"Za":-75.62}, ...],
  "2": [],
  ...
}
```

The `phpserialize.loads()` in Phase 2 just returns the JSON string, but then the code tries to treat it as a nested dict with `deliveryArea` key, which doesn't exist!

---

## The Fix

### Option A: Port Phase 1 Logic to Phase 2 (Recommended)

Replace Phase 2 `deserialize_area()` function with Phase 1's working logic:

```python
def deserialize_area(blob_entry):
    """Deserialize delivery area BLOB - FIXED VERSION"""
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
```

---

## What Changed

| Aspect | Phase 2 (Old/Broken) | Phase 2 (Fixed) |
|--------|---------------------|-----------------|
| **Parse method** | `phpserialize.loads()` | Regex + `json.loads()` |
| **Structure assumption** | Nested dict with `deliveryArea` key | Direct JSON string |
| **Coordinate keys** | Fixed `lat`/`lng` | Flexible key names (`Ya`, `Za`, `ob`, `pb`, etc.) |
| **Result** | 0 polygons | ~157 polygons |

---

## Validation

### Test with One Restaurant

Before running all batches, test with Mama Rosa (V1 ID: 94, V3 ID: 12):

```python
# Test script
import json

with open('phase2_only_blob_deliveryArea.json', 'r') as f:
    data = json.load(f)

mama_rosa = [r for r in data if r['v1_id'] == '94'][0]

result = deserialize_area(mama_rosa)
print(f"Status: {result['status']}")
print(f"Areas: {len(result['area_entries'])}")
if result['area_entries']:
    print(f"First polygon: {result['area_entries'][0]['polygon_wkt'][:100]}...")
```

**Expected Output:**
```
Status: success
Areas: 1
First polygon: POLYGON((-75.5049133301 45.4929533044,-75.4961585999 45.4964428854,...
```

---

## Files to Update

1. **`extracted_data/phase2_all_restaurants/deserialize_batch.py`**
   - Replace `deserialize_area()` function (lines 120-156)
   - Add `import re` at top if not present

2. **Re-run all 6 batches:**
   ```bash
   python deserialize_batch.py batch_1_30
   python deserialize_batch.py batch_31_60
   python deserialize_batch.py batch_61_90
   python deserialize_batch.py batch_91_120
   python deserialize_batch.py batch_121_150
   python deserialize_batch.py batch_151_159
   ```

3. **Verify deserialized data:**
   ```bash
   # Check each batch has area_entries
   cat batch_1_30_deserialized_areas.json | grep "area_entries" | wc -l
   ```

4. **Generate SQL:**
   ```bash
   python generate_batch_sql.py batch_1_30
   python generate_batch_sql.py batch_31_60
   # ... etc
   ```

5. **Execute SQL to V3 database**

---

## Expected Results After Fix

### Before Fix
- Phase 1: 5 restaurants, 6 polygons ✅
- Phase 2: 159 restaurants, 0 polygons ❌
- **Total: 6 polygons**

### After Fix
- Phase 1: 5 restaurants, 6 polygons ✅
- Phase 2: ~154 restaurants, ~157 polygons ✅
- **Total: ~163 polygons**

(Note: 2 restaurants have no BLOB data, some may have multiple polygons)

---

## Summary

**Root Cause:** Phase 2 used wrong deserialization logic that expected a nested dict structure, when V1 BLOBs are actually JSON strings wrapped in PHP serialization.

**Fix:** Port the working Phase 1 regex + json.loads() approach to Phase 2.

**Impact:** Will recover 157 missing delivery area polygons for Phase 2 restaurants.

