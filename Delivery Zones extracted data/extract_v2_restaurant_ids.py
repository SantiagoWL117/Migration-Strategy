"""
Extract V2 restaurant IDs and match them with V3 restaurants.

Goal: Confirm which V3 restaurants exist in V2 dump and identify missing ones.

Mapping:
- menuca_v3.restaurants.legacy_v2_id -> v2_dump.id
- menuca_v3.restaurants.legacy_v1_id -> v2_dump.v1_id
- menuca_v3.restaurants.name -> v2_dump.name
- menuca_v3.restaurant_locations.street_address -> v2_dump.address
"""

import re
import csv
import json
from difflib import SequenceMatcher

# V2 dump file path
V2_DUMP_PATH = '../Database/Legacy Schemas/v2_restaurants_dump.sql'

# V3 mapping file with legacy IDs
V3_MAPPING_PATH = 'v1_v3_mapping.csv'

# Output files
V2_EXTRACTED_CSV = 'v2_restaurants_extracted.csv'
V2_V3_MATCH_REPORT = 'V2_V3_MATCHING_REPORT.md'

def similarity_ratio(str1, str2):
    """Calculate similarity ratio between two strings (0-1)."""
    if not str1 or not str2:
        return 0.0
    return SequenceMatcher(None, str1.lower().strip(), str2.lower().strip()).ratio()

def normalize_address(address):
    """Normalize address for comparison."""
    if not address:
        return ""
    # Remove extra spaces, convert to lowercase
    addr = ' '.join(address.lower().split())
    # Common normalizations
    addr = addr.replace(' street', ' st').replace(' avenue', ' ave').replace(' boulevard', ' blvd')
    addr = addr.replace(' road', ' rd').replace(' drive', ' dr').replace(' crescent', ' cres')
    return addr

def extract_v2_restaurants():
    """Extract restaurant data from V2 dump."""
    print("Reading V2 dump file...")
    
    with open(V2_DUMP_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the INSERT statement
    insert_pattern = re.search(r'INSERT INTO `restaurants` VALUES (.+);', content, re.DOTALL)
    
    if not insert_pattern:
        print("ERROR: Could not find INSERT statement")
        return []
    
    values_content = insert_pattern.group(1)
    
    print("Parsing V2 restaurant records...")
    
    # Split by "),(" to get individual records
    # Need to be careful with commas inside quoted strings
    records = []
    current_record = ""
    in_quotes = False
    paren_depth = 0
    
    i = 0
    while i < len(values_content):
        char = values_content[i]
        
        if char == "'" and (i == 0 or values_content[i-1] != '\\'):
            in_quotes = not in_quotes
        
        if not in_quotes:
            if char == '(':
                paren_depth += 1
                if paren_depth == 1 and current_record.strip() == "":
                    # Start of new record
                    i += 1
                    continue
            elif char == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    # End of record
                    records.append(current_record)
                    current_record = ""
                    # Skip the comma if present
                    if i + 1 < len(values_content) and values_content[i + 1] == ',':
                        i += 2
                    else:
                        i += 1
                    continue
        
        current_record += char
        i += 1
    
    # If there's remaining content, add it
    if current_record.strip():
        records.append(current_record)
    
    print(f"Found {len(records)} records in V2 dump")
    
    # Parse each record to extract relevant fields
    v2_restaurants = []
    
    for idx, record in enumerate(records):
        try:
            # Split by comma, but respect quotes
            fields = []
            current_field = ""
            in_quotes = False
            
            for i, char in enumerate(record):
                if char == "'" and (i == 0 or record[i-1] != '\\'):
                    in_quotes = not in_quotes
                    current_field += char
                elif char == ',' and not in_quotes:
                    fields.append(current_field.strip())
                    current_field = ""
                else:
                    current_field += char
            
            # Don't forget the last field
            if current_field.strip():
                fields.append(current_field.strip())
            
            # V2 restaurants table has exactly 37 columns (indices 0-36)
            if len(fields) < 37:
                print(f"Warning: Record {idx} has only {len(fields)} fields, skipping")
                continue
            
            # Extract relevant fields based on V2 schema
            v2_id = fields[0].strip()  # id (column 0)
            v1_id_raw = fields[1].strip()  # v1_id (column 1)
            v1_id = v1_id_raw if v1_id_raw and v1_id_raw != 'NULL' else None
            name = fields[10].strip().strip("'")  # name (column 10)
            address = fields[11].strip().strip("'") if len(fields) > 11 else ""  # address (column 11)
            
            v2_restaurants.append({
                'v2_id': v2_id,
                'v1_id': v1_id,
                'name': name,
                'address': address
            })
            
        except Exception as e:
            print(f"Error parsing record {idx}: {e}")
            continue
    
    print(f"Successfully parsed {len(v2_restaurants)} V2 restaurants")
    
    # Save extracted V2 data
    with open(V2_EXTRACTED_CSV, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['v2_id', 'v1_id', 'name', 'address'])
        writer.writeheader()
        writer.writerows(v2_restaurants)
    
    print(f"Saved V2 extracted data to: {V2_EXTRACTED_CSV}")
    
    return v2_restaurants

def load_v3_restaurants():
    """Load V3 restaurant mapping with legacy IDs."""
    print("\nLoading V3 restaurant data...")
    
    v3_restaurants = []
    
    with open(V3_MAPPING_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            v3_restaurants.append({
                'v3_id': row['v3_id'],
                'v3_name': row['restaurant_name'],  # Column is 'restaurant_name' in CSV
                'v3_address': row['street_address'],  # Column is 'street_address' in CSV
                'legacy_v1_id': row['legacy_v1_id']
            })
    
    print(f"Loaded {len(v3_restaurants)} V3 restaurants")
    return v3_restaurants

def match_restaurants(v2_restaurants, v3_restaurants):
    """Match V3 restaurants with V2 dump data."""
    print("\nMatching V3 restaurants with V2 dump...")
    
    # Create lookup dictionaries for V2
    v2_by_v1_id = {r['v1_id']: r for r in v2_restaurants if r['v1_id']}
    
    # Create name+address composite key lookup for V2
    v2_by_name_address = {}
    for r in v2_restaurants:
        name_norm = normalize_address(r['name'])
        addr_norm = normalize_address(r['address'])
        composite_key = f"{name_norm}|{addr_norm}"
        v2_by_name_address[composite_key] = r
    
    matches = []
    missing_from_v2 = []
    fuzzy_matches = []
    
    for v3_resto in v3_restaurants:
        v3_name = v3_resto['v3_name']
        v3_address = v3_resto['v3_address']
        v3_v1_id = v3_resto['legacy_v1_id']
        
        match_found = False
        match_method = None
        v2_match = None
        
        # Method 1: Match by V1 ID (most reliable)
        if v3_v1_id and v3_v1_id in v2_by_v1_id:
            v2_match = v2_by_v1_id[v3_v1_id]
            match_method = 'v1_id'
            match_found = True
        
        # Method 2: Match by Name + Address combination
        if not match_found:
            v3_name_norm = normalize_address(v3_name)
            v3_addr_norm = normalize_address(v3_address)
            composite_key = f"{v3_name_norm}|{v3_addr_norm}"
            
            if composite_key in v2_by_name_address:
                v2_match = v2_by_name_address[composite_key]
                match_method = 'name_address'
                match_found = True
        
        # Method 3: Fuzzy name+address match (> 90% similarity on both)
        if not match_found:
            best_combined_score = 0
            best_match = None
            
            for v2_resto in v2_restaurants:
                name_similarity = similarity_ratio(v3_name, v2_resto['name'])
                addr_similarity = similarity_ratio(v3_address, v2_resto['address'])
                
                # Combined score: average of name and address similarity
                combined_score = (name_similarity + addr_similarity) / 2
                
                # Both name and address must be at least 85% similar
                if name_similarity >= 0.85 and addr_similarity >= 0.85:
                    if combined_score > best_combined_score:
                        best_combined_score = combined_score
                        best_match = v2_resto
            
            if best_combined_score >= 0.90:
                # Exclude known bad match: Mano City Pizza -> Milano City Pizza
                if not (v3_name == "Mano City Pizza" and best_match['name'] == "Milano City Pizza"):
                    v2_match = best_match
                    match_method = f'fuzzy_name_address_{int(best_combined_score * 100)}%'
                    match_found = True
                    fuzzy_matches.append({
                        'v3_id': v3_resto['v3_id'],
                        'v3_name': v3_name,
                        'v3_address': v3_address,
                        'v2_name': best_match['name'],
                        'v2_address': best_match['address'],
                        'similarity': f"{best_combined_score:.2%}"
                    })
        
        if match_found and v2_match:
            matches.append({
                'v3_id': v3_resto['v3_id'],
                'v3_name': v3_name,
                'v3_address': v3_address,
                'v3_legacy_v1_id': v3_v1_id,
                'v2_id': v2_match['v2_id'],
                'v2_v1_id': v2_match['v1_id'],
                'v2_name': v2_match['name'],
                'v2_address': v2_match['address'],
                'match_method': match_method
            })
        else:
            missing_from_v2.append({
                'v3_id': v3_resto['v3_id'],
                'v3_name': v3_name,
                'v3_address': v3_address,
                'v3_legacy_v1_id': v3_v1_id
            })
    
    return matches, missing_from_v2, fuzzy_matches

def generate_report(matches, missing, fuzzy_matches, v2_total):
    """Generate matching report."""
    print("\nGenerating matching report...")
    
    from datetime import datetime
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    with open(V2_V3_MATCH_REPORT, 'w', encoding='utf-8') as f:
        f.write("# V2 to V3 Restaurant Matching Report\n\n")
        f.write(f"**Generated:** {timestamp}\n\n")
        f.write("---\n\n")
        
        # Summary
        f.write("## Summary\n\n")
        f.write(f"- **V3 Restaurants Analyzed:** {len(matches) + len(missing)}\n")
        f.write(f"- **V2 Dump Total Records:** {v2_total}\n")
        f.write(f"- **Successfully Matched:** {len(matches)} ({len(matches) / (len(matches) + len(missing)) * 100:.1f}%)\n")
        f.write(f"- **Missing from V2:** {len(missing)} ({len(missing) / (len(matches) + len(missing)) * 100:.1f}%)\n")
        f.write(f"- **Fuzzy Matches (>90%):** {len(fuzzy_matches)}\n\n")
        
        # Match methods breakdown
        f.write("### Match Methods Breakdown\n\n")
        method_counts = {}
        for match in matches:
            method = match['match_method']
            method_counts[method] = method_counts.get(method, 0) + 1
        
        for method, count in sorted(method_counts.items(), key=lambda x: x[1], reverse=True):
            f.write(f"- **{method}:** {count} restaurants\n")
        
        f.write("\n---\n\n")
        
        # Matched restaurants
        f.write("## Matched Restaurants\n\n")
        f.write(f"Successfully matched {len(matches)} restaurants from V3 to V2 dump.\n\n")
        f.write("| V3 ID | V3 Name | V3 Address | V3 V1 ID | V2 ID | V2 V1 ID | V2 Name | V2 Address | Match Method |\n")
        f.write("|-------|---------|------------|----------|-------|----------|---------|------------|-------------|\n")
        
        for match in sorted(matches, key=lambda x: int(x['v3_id'])):
            v2_v1_display = match['v2_v1_id'] if match['v2_v1_id'] else 'NULL'
            v3_addr_short = match['v3_address'][:30] + '...' if len(match['v3_address']) > 30 else match['v3_address']
            v2_addr_short = match['v2_address'][:30] + '...' if len(match['v2_address']) > 30 else match['v2_address']
            f.write(f"| {match['v3_id']} | {match['v3_name']} | {v3_addr_short} | {match['v3_legacy_v1_id']} | "
                   f"{match['v2_id']} | {v2_v1_display} | {match['v2_name']} | "
                   f"{v2_addr_short} | {match['match_method']} |\n")
        
        f.write("\n---\n\n")
        
        # Fuzzy matches (if any)
        if fuzzy_matches:
            f.write("## Fuzzy Matches (>90% Combined Similarity)\n\n")
            f.write("These matches were made based on name+address similarity. Please verify accuracy.\n\n")
            f.write("| V3 ID | V3 Name | V3 Address | V2 Name | V2 Address | Similarity |\n")
            f.write("|-------|---------|------------|---------|------------|------------|\n")
            
            for fm in fuzzy_matches:
                v3_addr_short = fm['v3_address'][:30] + '...' if len(fm['v3_address']) > 30 else fm['v3_address']
                v2_addr_short = fm['v2_address'][:30] + '...' if len(fm['v2_address']) > 30 else fm['v2_address']
                f.write(f"| {fm['v3_id']} | {fm['v3_name']} | {v3_addr_short} | "
                       f"{fm['v2_name']} | {v2_addr_short} | {fm['similarity']} |\n")
            
            f.write("\n---\n\n")
        
        # Missing restaurants
        if missing:
            f.write("## Missing from V2 Dump\n\n")
            f.write(f"**{len(missing)} restaurants** from V3 could not be matched in the V2 dump.\n\n")
            f.write("| V3 ID | V3 Name | V3 Address | V3 Legacy V1 ID |\n")
            f.write("|-------|---------|------------|----------------|\n")
            
            for m in sorted(missing, key=lambda x: int(x['v3_id'])):
                addr_short = m['v3_address'][:40] + '...' if len(m['v3_address']) > 40 else m['v3_address']
                f.write(f"| {m['v3_id']} | {m['v3_name']} | {addr_short} | {m['v3_legacy_v1_id']} |\n")
            
            f.write("\n")
        
        f.write("\n---\n\n")
        
        # Next steps
        f.write("## Next Steps\n\n")
        f.write("1. **Review fuzzy matches** to ensure accuracy\n")
        f.write("2. **Investigate missing restaurants** - check if they:\n")
        f.write("   - Were added after V2 dump was created\n")
        f.write("   - Only exist in V1 (no V2 migration)\n")
        f.write("   - Have name/data discrepancies\n")
        f.write("3. **Use matched V2 IDs** to query `restaurants_delivery_areas` table\n")
        f.write("4. **Extract delivery area polygons** from V2 for restaurants with empty V1 data\n\n")
        
        f.write("---\n\n")
        f.write("**Report Complete**\n")
    
    print(f"Report saved to: {V2_V3_MATCH_REPORT}")

def import_datetime():
    """Import datetime for timestamp."""
    from datetime import datetime
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def main():
    print("="*60)
    print("V2 to V3 Restaurant Matching Tool")
    print("="*60)
    
    # Step 1: Extract V2 restaurant data
    v2_restaurants = extract_v2_restaurants()
    
    if not v2_restaurants:
        print("ERROR: No V2 restaurants extracted. Exiting.")
        return
    
    # Step 2: Load V3 restaurant data
    v3_restaurants = load_v3_restaurants()
    
    # Step 3: Match restaurants
    matches, missing, fuzzy_matches = match_restaurants(v2_restaurants, v3_restaurants)
    
    # Step 4: Generate report
    generate_report(matches, missing, fuzzy_matches, len(v2_restaurants))
    
    print("\n" + "="*60)
    print("MATCHING COMPLETE")
    print("="*60)
    print(f"[+] Matched: {len(matches)} restaurants")
    print(f"[-] Missing: {len(missing)} restaurants")
    print(f"[~] Fuzzy: {len(fuzzy_matches)} restaurants")
    print(f"\nFull report: {V2_V3_MATCH_REPORT}")
    print("="*60)

if __name__ == "__main__":
    main()

