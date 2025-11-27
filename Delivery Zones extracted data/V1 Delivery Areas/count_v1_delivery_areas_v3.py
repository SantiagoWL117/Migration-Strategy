import re
import json
import os

# Define file paths
V1_DUMP_PATH = "Database/Legacy Schemas/v1_restaurants_dump.sql"
OUTPUT_DIR = "Delivery Zones extracted data/V1 Delivery Areas"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "v1_delivery_area_count.txt")

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# List of V1 IDs to check (from user's request)
target_v1_ids = [161, 225, 228, 238, 246, 334, 411, 669, 695, 727, 758, 781, 782, 785, 789, 805, 807, 815, 817, 818, 824, 825, 830, 838, 840, 850, 856, 863, 865, 869, 872, 874, 879, 889, 913, 914, 937, 947, 948, 951, 952, 953, 959, 964, 965, 968, 973, 974, 983, 987, 989, 998, 1025, 1027, 1028, 1032, 1033, 1035, 1039, 1041, 1042, 1045, 1050, 1051, 1054, 1059, 1060, 1062, 1063, 1064, 1065, 1066, 1069, 1070, 1074, 1080, 1082, 1083, 1084, 1087, 1088, 1089, 1092, 1093, 1094, 694, 323, 1038, 1071, 364, 1095, 132, 231, 346, 1046, 173, 511]
target_v1_ids_set = set(target_v1_ids)

print("=" * 80)
print("V1 DELIVERY AREA ANALYSIS")
print("=" * 80)
print(f"\nTarget restaurants: {len(target_v1_ids)}")
print(f"Reading: {V1_DUMP_PATH}\n")

found_in_dump = {}  # v1_id -> has_delivery_area
restaurants_with_delivery_area = []
restaurants_without_delivery_area = []
total_restaurants_in_dump = 0

try:
    with open(V1_DUMP_PATH, 'r', encoding='utf-8', errors='ignore') as f:
        print("Parsing dump file (this may take a minute)...")
        
        for line_num, line in enumerate(f, 1):
            # Skip non-INSERT lines
            if not line.startswith('INSERT INTO `restaurants` VALUES'):
                continue
            
            total_restaurants_in_dump += 1
            
            # Extract the ID - first value after VALUES (
            id_match = re.search(r'VALUES \((\d+),', line)
            if not id_match:
                continue
            
            v1_id = int(id_match.group(1))
            
            # Check if this is a target restaurant
            if v1_id not in target_v1_ids_set:
                continue
            
            print(f"  Found target restaurant: V1 ID {v1_id}")
            
            # Now check if it has deliveryArea data
            # deliveryArea is column 52 (0-indexed: position 51)
            # It's a BLOB column that can be:
            # - NULL (no data)
            # - _binary 'a:0:{}' (empty PHP array)
            # - _binary 'a:1:{...}' or more (actual polygon data)
            
            # Strategy: Look for the deliveryArea BLOB field
            # We know from the schema that there are 5 BLOB fields before deliveryArea:
            # - delivery_schedule (column 9)
            # - restaurant_schedule (column 10)
            # - specialSchedule (column 11)
            # - fee (column 24)
            # - deliveryArea (column 52)
            
            # Find all _binary occurrences
            binary_matches = list(re.finditer(r"_binary\s+'", line))
            
            has_delivery_area = False
            
            # The 5th _binary field (index 4) should be deliveryArea
            if len(binary_matches) >= 5:
                # Get position of 5th _binary
                fifth_binary_pos = binary_matches[4].end()
                
                # Extract content after the opening quote
                # Look for the PHP serialized format
                remaining = line[fifth_binary_pos:fifth_binary_pos+200]
                
                # Check for actual serialized data
                if remaining.startswith('a:'):
                    # Extract the array count from a:N:{...}
                    count_match = re.match(r'a:(\d+):', remaining)
                    if count_match:
                        array_count = int(count_match.group(1))
                        if array_count > 0:
                            # Non-empty array - check if it has polygon data
                            # Look for JSON-like structures with coordinates
                            if '{' in remaining[:1000] and '[' in remaining[:1000]:
                                has_delivery_area = True
                                print(f"    -> HAS deliveryArea polygon data")
                            else:
                                print(f"    -> Has deliveryArea structure but no polygon coordinates")
                        else:
                            print(f"    -> Empty deliveryArea array")
                    else:
                        print(f"    -> Malformed deliveryArea serialization")
                elif remaining.startswith('N'):
                    # NULL value
                    print(f"    -> NULL deliveryArea")
                else:
                    print(f"    -> Unexpected deliveryArea format")
            elif 'NULL' in line[line.find('VALUES'):]:
                # Check if deliveryArea is NULL
                # Count commas to approximate column position
                # This is a fallback for records with fewer BLOB fields
                print(f"    -> Appears to have NULL deliveryArea (fewer than 5 BLOBs)")
            else:
                print(f"    -> Could not determine deliveryArea status")
            
            found_in_dump[v1_id] = has_delivery_area
            
            if has_delivery_area:
                restaurants_with_delivery_area.append(v1_id)
            else:
                restaurants_without_delivery_area.append(v1_id)
    
    print(f"\nProcessed {total_restaurants_in_dump} total restaurants from dump\n")

except FileNotFoundError:
    print(f"ERROR: File not found: {V1_DUMP_PATH}")
    exit(1)
except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
    exit(1)

# Sort lists
restaurants_with_delivery_area.sort()
restaurants_without_delivery_area.sort()

# Find target restaurants not in dump
not_found_in_dump = sorted([v_id for v_id in target_v1_ids if v_id not in found_in_dump])

# Output results to file
with open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:
    outfile.write("=" * 80 + "\n")
    outfile.write("V1 DELIVERY AREA ANALYSIS - RESULTS\n")
    outfile.write("=" * 80 + "\n\n")
    outfile.write(f"Total restaurants in dump: {total_restaurants_in_dump:,}\n")
    outfile.write(f"Target restaurants to analyze: {len(target_v1_ids)}\n\n")
    
    outfile.write(f"Found in dump: {len(found_in_dump)}\n")
    outfile.write(f"Not found in dump: {len(not_found_in_dump)}\n\n")
    
    outfile.write(f"Restaurants WITH deliveryArea data: {len(restaurants_with_delivery_area)}\n")
    outfile.write(f"Restaurants WITHOUT deliveryArea data: {len(restaurants_without_delivery_area)}\n\n")
    
    outfile.write("-" * 80 + "\n")
    outfile.write("BREAKDOWN\n")
    outfile.write("-" * 80 + "\n\n")
    
    if restaurants_with_delivery_area:
        outfile.write(f"RESTAURANTS WITH deliveryArea DATA ({len(restaurants_with_delivery_area)}):\n")
        for v1_id in restaurants_with_delivery_area:
            outfile.write(f"  - V1 ID: {v1_id}\n")
        outfile.write("\n")
    
    if restaurants_without_delivery_area:
        outfile.write(f"RESTAURANTS WITHOUT deliveryArea DATA ({len(restaurants_without_delivery_area)}):\n")
        for v1_id in restaurants_without_delivery_area:
            outfile.write(f"  - V1 ID: {v1_id}\n")
        outfile.write("\n")
    
    if not_found_in_dump:
        outfile.write(f"RESTAURANTS NOT FOUND IN DUMP ({len(not_found_in_dump)}):\n")
        for v1_id in not_found_in_dump:
            outfile.write(f"  - V1 ID: {v1_id}\n")
        outfile.write("\n")
    
    outfile.write("=" * 80 + "\n")
    outfile.write("MIGRATION IMPLICATIONS\n")
    outfile.write("=" * 80 + "\n\n")
    outfile.write(f"Can migrate from V1: {len(restaurants_with_delivery_area)} restaurants\n")
    outfile.write(f"Cannot migrate (no V1 data): {len(restaurants_without_delivery_area)} restaurants\n")
    outfile.write(f"Missing from dump: {len(not_found_in_dump)} restaurants\n\n")
    
    total_cannot_migrate = len(restaurants_without_delivery_area) + len(not_found_in_dump)
    outfile.write(f"TOTAL UNABLE TO MIGRATE: {total_cannot_migrate} restaurants\n\n")

# Print summary to console
print("=" * 80)
print("ANALYSIS COMPLETE")
print("=" * 80)
print(f"\nTotal restaurants in dump: {total_restaurants_in_dump:,}")
print(f"Target restaurants: {len(target_v1_ids)}\n")
print(f"Found in dump: {len(found_in_dump)}")
print(f"  -> WITH deliveryArea data: {len(restaurants_with_delivery_area)}")
print(f"  -> WITHOUT deliveryArea data: {len(restaurants_without_delivery_area)}")
print(f"Not found in dump: {len(not_found_in_dump)}\n")
print("=" * 80)
print("MIGRATION SUMMARY")
print("=" * 80)
print(f"CAN migrate from V1: {len(restaurants_with_delivery_area)} restaurants")
print(f"CANNOT migrate: {len(restaurants_without_delivery_area) + len(not_found_in_dump)} restaurants")
print(f"\nDetailed results: {OUTPUT_FILE}\n")

# Also save a CSV for easy reference
csv_file = os.path.join(OUTPUT_DIR, "v1_delivery_area_analysis.csv")
with open(csv_file, 'w', encoding='utf-8') as csvfile:
    csvfile.write("v1_id,has_delivery_area,status\n")
    for v1_id in restaurants_with_delivery_area:
        csvfile.write(f"{v1_id},YES,found\n")
    for v1_id in restaurants_without_delivery_area:
        csvfile.write(f"{v1_id},NO,found\n")
    for v1_id in not_found_in_dump:
        csvfile.write(f"{v1_id},UNKNOWN,not_in_dump\n")

print(f"CSV export: {csv_file}\n")



