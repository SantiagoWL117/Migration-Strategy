"""
Count restaurants with non-empty deliveryArea BLOB data in V1 dump
Target: 101 unmigrated restaurants
"""

import re
import sys

# Target V1 IDs (unmigrated restaurants)
target_ids = {
    161, 225, 228, 238, 246, 334, 411, 669, 695, 727, 758, 781, 782, 785, 789,
    805, 807, 815, 817, 818, 824, 825, 830, 838, 840, 850, 856, 863, 865, 869,
    872, 874, 879, 889, 913, 914, 937, 947, 948, 951, 952, 953, 959, 964, 965,
    968, 973, 974, 983, 987, 989, 998, 1025, 1027, 1028, 1032, 1033, 1035, 1039,
    1041, 1042, 1045, 1050, 1051, 1054, 1059, 1060, 1062, 1063, 1064, 1065, 1066,
    1069, 1070, 1074, 1080, 1082, 1083, 1084, 1087, 1088, 1089, 1092, 1093, 1094,
    694, 323, 1038, 1071, 364, 1095, 132, 231, 346, 1046, 173, 511
}

print(f"Searching for {len(target_ids)} restaurants in V1 dump...")
print(f"Target IDs: {sorted(target_ids)}\n")

# Read the V1 dump file
dump_file = 'Database/Legacy Schemas/v1_restaurants_dump.sql'

try:
    with open(dump_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
except Exception as e:
    print(f"Error reading file: {e}")
    sys.exit(1)

# Find INSERT statements for restaurants table
# Pattern: INSERT INTO `restaurants` VALUES (id, ...);
insert_pattern = r"INSERT INTO `restaurants` VALUES \((.*?)\);"

# Find all INSERT statements
inserts = re.findall(insert_pattern, content, re.DOTALL)

if not inserts:
    print("ERROR: No INSERT statements found in dump file")
    sys.exit(1)

print(f"Found {len(inserts)} INSERT statements in dump\n")

# Process each INSERT statement
restaurants_with_data = []
restaurants_without_data = []
restaurants_not_found = set(target_ids)

for insert_stmt in inserts:
    # Split by comma, but need to handle commas within quoted strings and NULL values
    # This is a simplified parser - may need adjustment for complex data
    
    # Get the restaurant ID (first field)
    try:
        # Extract ID from the beginning of the INSERT
        id_match = re.match(r'^(\d+),', insert_stmt)
        if not id_match:
            continue
        
        resto_id = int(id_match.group(1))
        
        # Only process target restaurants
        if resto_id not in target_ids:
            continue
        
        restaurants_not_found.discard(resto_id)
        
        # Extract restaurant name (4th field after id, addedBy, addedon)
        # Pattern to find the name field
        name_match = re.search(r"^(\d+),(\d+),'[^']*','([^']*)'", insert_stmt)
        name = name_match.group(3) if name_match else "Unknown"
        
        # Check if deliveryArea BLOB has data
        # The deliveryArea column comes after many fields
        # Look for patterns like: 'a:1:{...}' (PHP serialized) or NULL or _binary ''
        
        # Search for deliveryArea content - it's a BLOB so could be:
        # - NULL
        # - _binary '' (empty)
        # - _binary 'a:...' (has data - PHP serialized)
        
        # Simple heuristic: if we find "a:1:{" or "a:2:{" etc (PHP array serialization)
        # in the INSERT statement, the deliveryArea likely has data
        has_delivery_area = False
        
        if re.search(r"_binary\s+'a:\d+:\{", insert_stmt):
            has_delivery_area = True
            
        if has_delivery_area:
            restaurants_with_data.append({
                'id': resto_id,
                'name': name
            })
        else:
            restaurants_without_data.append({
                'id': resto_id,
                'name': name
            })
            
    except Exception as e:
        print(f"Error processing INSERT: {str(e)[:100]}")
        continue

# Sort results
restaurants_with_data.sort(key=lambda x: x['id'])
restaurants_without_data.sort(key=lambda x: x['id'])

# Print results
print("=" * 80)
print("RESULTS: V1 Delivery Area Analysis")
print("=" * 80)
print()

print(f"Total target restaurants: {len(target_ids)}")
print(f"Found in dump: {len(target_ids) - len(restaurants_not_found)}")
print(f"Not found in dump: {len(restaurants_not_found)}")
print()

print(f"Restaurants WITH deliveryArea data: {len(restaurants_with_data)}")
print(f"Restaurants WITHOUT deliveryArea data: {len(restaurants_without_data)}")
print()

if restaurants_with_data:
    print("-" * 80)
    print("RESTAURANTS WITH DELIVERY AREA DATA:")
    print("-" * 80)
    for resto in restaurants_with_data:
        print(f"  V1 ID {resto['id']:4d}: {resto['name']}")
    print()

if restaurants_not_found:
    print("-" * 80)
    print("RESTAURANTS NOT FOUND IN DUMP:")
    print("-" * 80)
    print(f"  {sorted(restaurants_not_found)}")
    print()

# Summary for migration
print("=" * 80)
print("MIGRATION IMPACT:")
print("=" * 80)
print(f"Potential V1 data sources: {len(restaurants_with_data)} restaurants")
print(f"No V1 data available: {len(restaurants_without_data)} restaurants")
print(f"Missing from dump: {len(restaurants_not_found)} restaurants")
print()

# Save detailed results
output_file = 'Delivery Zones extracted data/V1 Delivery Areas/v1_delivery_area_count.txt'
with open(output_file, 'w', encoding='utf-8') as f:
    f.write("V1 Delivery Area Data Analysis\n")
    f.write("=" * 80 + "\n\n")
    f.write(f"Target restaurants: {len(target_ids)}\n")
    f.write(f"Found in dump: {len(target_ids) - len(restaurants_not_found)}\n")
    f.write(f"WITH deliveryArea: {len(restaurants_with_data)}\n")
    f.write(f"WITHOUT deliveryArea: {len(restaurants_without_data)}\n")
    f.write(f"Not in dump: {len(restaurants_not_found)}\n\n")
    
    if restaurants_with_data:
        f.write("RESTAURANTS WITH DELIVERY AREA DATA:\n")
        f.write("-" * 80 + "\n")
        for resto in restaurants_with_data:
            f.write(f"V1 ID {resto['id']:4d}: {resto['name']}\n")
        f.write("\n")
    
    if restaurants_without_data:
        f.write("RESTAURANTS WITHOUT DELIVERY AREA DATA:\n")
        f.write("-" * 80 + "\n")
        for resto in restaurants_without_data:
            f.write(f"V1 ID {resto['id']:4d}: {resto['name']}\n")
        f.write("\n")
    
    if restaurants_not_found:
        f.write("NOT FOUND IN DUMP:\n")
        f.write("-" * 80 + "\n")
        f.write(f"{sorted(restaurants_not_found)}\n")

print(f"Detailed results saved to: {output_file}")



