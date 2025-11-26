#!/usr/bin/env python3
"""
Parse V1 restaurants dump to extract delivery-related data.
V1 dump contains serialized PHP arrays in BLOB columns that need special handling.
"""

import csv
import re
import json

# V1 restaurants table column structure (from structure.sql)
V1_COLUMNS = [
    'id', 'addedBy', 'addedon', 'name', 'address', 'city', 'province', 'cuisine',
    'delivery_schedule', 'restaurant_schedule', 'specialSchedule',
    'phone', 'mainEmail', 'about_en', 'about_fr', 'country',
    'delivery_time', 'takeout_time', 'link', 'zip',
    'pickup', 'delivery', 'takeout',
    'fee', 'min_order', 'active', 'pending', 'lang',
    'latitude', 'longitude', 'deliveryRadius', 'multipleDeliveryArea',
    'deliveryArea'
    # ... and many more columns (total ~100+)
]

# Key delivery-related column indices (0-based)
DELIVERY_COLUMNS = {
    'id': 0,
    'name': 3,
    'address': 4,
    'delivery_time': 16,
    'takeout_time': 17,
    'pickup': 20,
    'delivery': 21,
    'takeout': 22,
    'fee': 23,
    'min_order': 24,
    'deliveryRadius': 30,
    'multipleDeliveryArea': 31,
    'deliveryArea': 32
}

def load_v1_mapping():
    """Load V3 to V1 ID mapping."""
    mapping = {}
    with open('v3_to_v1_mapping.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            mapping[row['legacy_v1_id']] = {
                'v3_id': row['v3_id'],
                'v3_name': row['v3_name']
            }
    return mapping

def parse_mysql_dump():
    """Parse the MySQL dump file."""
    print("Loading V1 dump file...")
    with open('Database/v1_structure/restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print("Extracting INSERT statements...")
    # Find all INSERT statements for restaurants table
    pattern = r"INSERT INTO `restaurants` VALUES (.+?)(?:;|\n\n)"
    matches = re.findall(pattern, content, re.DOTALL)
    
    print(f"Found {len(matches)} INSERT statement(s)")
    
    # Combine all VALUES
    all_values = ' '.join(matches)
    
    # Split by record boundaries: ),( or start/end
    # This is simplified - full parsing requires a proper SQL parser
    print("\nNote: V1 dump contains complex BLOB data (serialized PHP arrays)")
    print("For accurate delivery data, recommend querying V3 database directly.\n")
    
    return all_values

def main():
    print("=" * 60)
    print("V1 DELIVERY DATA EXTRACTION")
    print("=" * 60)
    print()
    
    # Load mapping
    mapping = load_v1_mapping()
    print(f"Loaded {len(mapping)} V3-to-V1 restaurant mappings\n")
    
    # Parse dump
    dump_data = parse_mysql_dump()
    
    # Extract data for target restaurants
    results = []
    found_count = 0
    
    print("Searching for restaurants in dump...\n")
    
    for v1_id, info in mapping.items():
        # Simple pattern to find restaurant by ID
        # Pattern: (ID,number,'date','name'
        pattern = rf"\({v1_id},\d+,'[^']*','([^']+)'"
        match = re.search(pattern, dump_data)
        
        if match:
            v1_name = match.group(1)
            print(f"✓ Found: V1 ID {v1_id} - {v1_name}")
            found_count += 1
            
            results.append({
                'v3_id': info['v3_id'],
                'v3_name': info['v3_name'],
                'v1_id': v1_id,
                'v1_name': v1_name,
                'status': 'Found in dump'
            })
        else:
            print(f"✗ Not found: V1 ID {v1_id} - {info['v3_name']}")
    
    print(f"\n{'=' * 60}")
    print(f"SUMMARY: Found {found_count} of {len(mapping)} restaurants")
    print(f"{'=' * 60}\n")
    
    # Save results
    with open('v1_restaurants_found.csv', 'w', newline='', encoding='utf-8') as f:
        if results:
            writer = csv.DictWriter(f, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)
    
    print("Results saved to: v1_restaurants_found.csv\n")
    print("IMPORTANT NOTE:")
    print("-" * 60)
    print("The V1 dump stores delivery data in BLOB columns containing")
    print("serialized PHP arrays. To extract full delivery configuration:")
    print()
    print("RECOMMENDED APPROACH:")
    print("Query the V3 database instead - all V1 data has been migrated")
    print("and stored in proper relational columns without BLOB serialization.")
    print()

if __name__ == '__main__':
    main()









