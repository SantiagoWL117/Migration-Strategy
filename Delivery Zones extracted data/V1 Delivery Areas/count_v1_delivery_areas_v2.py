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

print(f"================================================================================")
print(f"V1 Delivery Area Analysis")
print(f"================================================================================\n")
print(f"Searching for {len(target_v1_ids)} target restaurants in V1 dump...")
print(f"Reading file: {V1_DUMP_PATH}\n")

found_in_dump = {}  # v1_id -> has_delivery_area
restaurants_with_delivery_area = []
restaurants_without_delivery_area = []
total_restaurants_in_dump = 0

try:
    with open(V1_DUMP_PATH, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print(f"File size: {len(content):,} characters")
    
    # Find all INSERT INTO statements
    insert_statements = re.findall(
        r'INSERT INTO `restaurants` VALUES\s+(.+?);',
        content,
        re.DOTALL
    )
    
    print(f"Found {len(insert_statements)} INSERT statements\n")
    print("Processing restaurant records...")
    
    for stmt_idx, insert_data in enumerate(insert_statements, 1):
        # Each INSERT can have multiple records in format: (record1),(record2),(record3)
        # We need to split by ),( but preserve the data inside each record
        
        # Add markers to make splitting easier
        insert_data = insert_data.strip()
        
        # Split into individual records
        # Pattern: match from opening paren to closing paren, handling nested structures
        records = []
        depth = 0
        current_record = []
        
        for char in insert_data:
            if char == '(' and depth == 0:
                # Start of a new record
                current_record = ['(']
                depth = 1
            elif char == '(' and depth > 0:
                current_record.append(char)
                depth += 1
            elif char == ')' and depth == 1:
                # End of current record
                current_record.append(')')
                records.append(''.join(current_record))
                current_record = []
                depth = 0
            elif char == ')' and depth > 1:
                current_record.append(char)
                depth -= 1
            elif depth > 0:
                current_record.append(char)
        
        print(f"  INSERT statement {stmt_idx}: {len(records)} records")
        
        # Process each record
        for record in records:
            total_restaurants_in_dump += 1
            
            # Extract the ID (first value after opening paren)
            id_match = re.match(r'\((\d+),', record)
            if not id_match:
                continue
            
            v1_id = int(id_match.group(1))
            
            # Check if this is a target restaurant
            if v1_id not in target_v1_ids_set:
                continue
            
            # Found a target restaurant!
            # Now check for deliveryArea BLOB (52nd column, 0-indexed position 51)
            # We need to parse the columns carefully
            
            # Split by commas, but be careful of commas inside strings and BLOBs
            # For now, let's just check if the record contains '_binary' which indicates BLOB data
            # and if it's not NULL
            
            # Pattern to find deliveryArea column value
            # Looking for column 52 (deliveryArea)
            # We'll use a simpler approach: look for _binary patterns in the record
            
            # Count the number of commas to approximate column positions
            # This is a simplified approach - for production, would need proper SQL parsing
            
            # Check if record contains non-NULL deliveryArea
            # Pattern: match the deliveryArea field which could be:
            # - _binary '...' (has data)
            # - NULL (no data)
            
            # Simple heuristic: if record has multiple _binary fields, 
            # we need to identify which is deliveryArea (column 52)
            
            # For now, let's split by comma and count positions
            # This is approximate due to nested structures, but should work for most cases
            
            parts = record.split(',')
            
            # Column 52 (0-indexed: 51) should be deliveryArea
            # But splitting by comma is unreliable due to nested strings
            # Let's use a different approach: check if there's substantial BLOB data
            
            # Count _binary occurrences - there should be multiple BLOBs per record
            binary_pattern = re.findall(r"_binary\s*'([^']*(?:''[^']*)*)'", record)
            
            # deliveryArea is column 52
            # delivery_schedule is column 9 (first BLOB)
            # restaurant_schedule is column 10
            # specialSchedule is column 11
            # fee is column 24
            # deliveryArea is column 52
            
            # Instead of counting, let's look at the position in the string
            # Find all _binary positions
            binary_matches = list(re.finditer(r"_binary\s*'", record))
            
            has_delivery_area = False
            
            # If there are 5+ binary fields, the 5th one is likely deliveryArea
            if len(binary_matches) >= 5:
                # Get the 5th _binary field
                fifth_binary = binary_matches[4]
                # Extract value after this position
                start_pos = fifth_binary.end()
                # Find the closing quote
                # This BLOB might have data or be empty
                remaining = record[start_pos:start_pos+100]  # Sample first 100 chars
                
                # Check if it has actual serialized data
                if remaining.startswith('a:') or remaining.startswith('s:'):
                    # PHP serialized data detected
                    # Now check if it contains actual polygon data
                    # Extract more of the BLOB to check
                    blob_end = record.find("'", start_pos)
                    if blob_end > start_pos:
                        blob_content = record[start_pos:blob_end]
                        # Check for JSON-like structure indicating polygons
                        if '{' in blob_content and '[' in blob_content:
                            has_delivery_area = True
            
            found_in_dump[v1_id] = has_delivery_area
            
            if has_delivery_area:
                restaurants_with_delivery_area.append(v1_id)
            else:
                restaurants_without_delivery_area.append(v1_id)

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
print("\n" + "=" * 80)
print("ANALYSIS COMPLETE")
print("=" * 80 + "\n")
print(f"Total restaurants in dump: {total_restaurants_in_dump:,}")
print(f"Target restaurants analyzed: {len(target_v1_ids)}\n")
print(f"Found in dump: {len(found_in_dump)}")
print(f"  -> WITH deliveryArea data: {len(restaurants_with_delivery_area)}")
print(f"  -> WITHOUT deliveryArea data: {len(restaurants_without_delivery_area)}")
print(f"Not found in dump: {len(not_found_in_dump)}\n")
print("=" * 80)
print("MIGRATION SUMMARY")
print("=" * 80)
print(f"CAN migrate from V1: {len(restaurants_with_delivery_area)} restaurants")
print(f"CANNOT migrate: {len(restaurants_without_delivery_area) + len(not_found_in_dump)} restaurants\n")
print(f"Detailed results saved to: {OUTPUT_FILE}\n")



