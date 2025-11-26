import csv
import json
import sys
from datetime import datetime

print("\n" + "="*80)
print("STEP 1: V2 -> V3 ID MAPPING WITH VALIDATION GATE")
print("="*80)

# File paths
V2_CSV_PATH = 'extracted_data/v2_delivery_areas_export_FILTERED.csv'
ACTIVE_RESTAURANTS_PATH = 'reports/database/Restaurants-active.md'
OUTPUT_MAPPING_JSON = 'extracted_data/v2_v3_id_mapping.json'
OUTPUT_REPORT_MD = 'extracted_data/V2_V3_MAPPING_REPORT.md'

# Load V3 restaurants from active restaurants markdown
print("\n[1/4] Loading V3 restaurant data from Restaurants-active.md...")
v3_restaurants = []

with open(ACTIVE_RESTAURANTS_PATH, 'r', encoding='utf-8') as f:
    lines = f.readlines()
    table_started = False
    
    for line in lines:
        if "| ---" in line:
            table_started = True
            continue
        
        if table_started and line.strip() and not line.startswith('| -----'):
            parts = [p.strip() for p in line.split('|') if p.strip()]
            if len(parts) >= 4:
                # Format: | Name | Address | Version | V3 ID |
                v3_restaurants.append({
                    'v3_id': parts[3],
                    'name': parts[0],
                    'address': parts[1],
                    'version': parts[2]
                })

print(f"   Loaded {len(v3_restaurants)} V3 restaurants")

# Create lookup dictionaries
# We'll use the v2_v3_mappings_from_report.csv which has the comprehensive V2->V3 mapping
print("\n[2/4] Loading V2->V3 mapping from v2_v3_mappings_from_report.csv...")
v2_to_v3_map = {}
v1_to_v3_map = {}

try:
    with open('extracted_data/v2_v3_mappings_from_report.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # This CSV has: v2_id,v2_v1_id,v2_name,v3_id,v3_name
            v2_id = row['v2_id']
            v3_id = row['v3_id']
            v2_to_v3_map[v2_id] = {
                'v3_id': v3_id,
                'v3_name': row['v3_name']
            }
            
            # Also create V1 mapping if available
            if row['v2_v1_id'] and row['v2_v1_id'] != 'NULL':
                v1_id = row['v2_v1_id']
                v1_to_v3_map[v1_id] = {
                    'v3_id': v3_id,
                    'v3_name': row['v3_name']
                }
    
    print(f"   Loaded {len(v2_to_v3_map)} V2->V3 mappings")
    print(f"   Loaded {len(v1_to_v3_map)} V1->V3 mappings")
except FileNotFoundError:
    print("   ERROR: v2_v3_mappings_from_report.csv not found!")
    print("   Please run: python extracted_data/extract_v2_v3_from_report.py")
    sys.exit(1)

# Load V2 CSV
print("\n[3/4] Loading V2 delivery areas CSV...")
v2_restaurants = []

with open(V2_CSV_PATH, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v2_restaurants.append({
            'v2_id': row['v2_id'],
            'v1_id': row['v1_id'] if row['v1_id'] and row['v1_id'] != '\\N' else None,
            'name': row['name'],
            'address': row['address'],
            'delivery_fee': row['delivery_fee'],
            'is_complex': row['is_complex'],
            'coords': row['coords'],
            'min_order_value': row['min_order_value']
        })

print(f"   Loaded {len(v2_restaurants)} V2 restaurant area records")

# Get unique V2 restaurants
unique_v2 = {}
for resto in v2_restaurants:
    key = resto['v2_id']
    if key not in unique_v2:
        unique_v2[key] = resto

print(f"   Unique V2 restaurants: {len(unique_v2)}")

# CRITICAL: Map each V2 restaurant to V3 ID
print("\n[4/4] Mapping V2 restaurants to V3 IDs...")
print("   Method priority: V2 ID > V1 ID > Name+Address match")

mapping_results = []
unmapped_restaurants = []

for v2_id, v2_resto in unique_v2.items():
    v3_id = None
    match_method = None
    
    # Method 1: Match by V2 ID (most reliable if available)
    if v2_id in v2_to_v3_map:
        v3_id = v2_to_v3_map[v2_id]['v3_id']
        match_method = 'v2_id'
    
    # Method 2: Match by V1 ID (reliable fallback)
    if not v3_id and v2_resto['v1_id'] and v2_resto['v1_id'] in v1_to_v3_map:
        v3_id = v1_to_v3_map[v2_resto['v1_id']]['v3_id']
        match_method = 'v1_id'
    
    # Method 3: Match by name + address (from active restaurants)
    if not v3_id:
        v2_name_lower = v2_resto['name'].lower().strip()
        v2_address_lower = v2_resto['address'].lower().strip()
        
        for v3_resto in v3_restaurants:
            v3_name_lower = v3_resto['name'].lower().strip()
            v3_address_lower = v3_resto['address'].lower().strip()
            
            if v3_name_lower == v2_name_lower and v3_address_lower == v2_address_lower:
                v3_id = v3_resto['v3_id']
                match_method = 'name_address_exact'
                break
    
    if v3_id:
        mapping_results.append({
            'v2_id': v2_id,
            'v1_id': v2_resto['v1_id'],
            'v3_id': v3_id,
            'name': v2_resto['name'],
            'address': v2_resto['address'],
            'match_method': match_method
        })
    else:
        unmapped_restaurants.append({
            'v2_id': v2_id,
            'v1_id': v2_resto['v1_id'],
            'name': v2_resto['name'],
            'address': v2_resto['address']
        })

print(f"   Successfully mapped: {len(mapping_results)}")
print(f"   Unmapped: {len(unmapped_restaurants)}")

# VALIDATION GATE: STOP if any restaurants are unmapped
if unmapped_restaurants:
    print("\n" + "="*80)
    print("[ERROR] CRITICAL ERROR: UNMAPPED RESTAURANTS FOUND")
    print("="*80)
    print(f"\nTotal unmapped: {len(unmapped_restaurants)}\n")
    print("Unmapped restaurants:")
    print("-" * 80)
    
    for resto in unmapped_restaurants:
        print(f"V2 ID: {resto['v2_id']:4} | V1 ID: {resto['v1_id'] or 'N/A':4} | {resto['name']:<40} | {resto['address']}")
    
    print("\n" + "="*80)
    print("[STOP] STOPPING EXECUTION - Cannot proceed without complete mapping")
    print("="*80)
    print("\nPlease resolve the unmapped restaurants before continuing:")
    print("  1. Check if these restaurants exist in menuca_v3.restaurants")
    print("  2. Verify legacy_v2_id or legacy_v1_id are correctly set")
    print("  3. Update v1_v3_mapping.csv if needed")
    print("  4. Re-run this script\n")
    
    sys.exit(1)

# SUCCESS: All restaurants mapped
print("\n" + "="*80)
print("[SUCCESS] ALL RESTAURANTS MAPPED")
print("="*80)

# Save mapping to JSON
with open(OUTPUT_MAPPING_JSON, 'w', encoding='utf-8') as f:
    json.dump(mapping_results, f, indent=2)

print(f"\n[+] Mapping saved to: {OUTPUT_MAPPING_JSON}")

# Generate detailed report
print(f"[+] Generating mapping report...")

with open(OUTPUT_REPORT_MD, 'w', encoding='utf-8') as f:
    f.write("# V2 to V3 ID Mapping Report\n\n")
    f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    f.write("---\n\n")
    f.write("## Summary\n\n")
    f.write(f"- **Total V2 restaurants:** {len(unique_v2)}\n")
    f.write(f"- **Successfully mapped:** {len(mapping_results)} (100.0%)\n")
    f.write(f"- **Unmapped:** {len(unmapped_restaurants)} (0.0%)\n")
    f.write(f"- **Status:** [PASS] All restaurants mapped\n\n")
    
    f.write("---\n\n")
    f.write("## Mapping Methods\n\n")
    
    method_counts = {}
    for result in mapping_results:
        method = result['match_method']
        method_counts[method] = method_counts.get(method, 0) + 1
    
    f.write("| Method | Count | Percentage |\n")
    f.write("|--------|-------|------------|\n")
    for method, count in sorted(method_counts.items(), key=lambda x: x[1], reverse=True):
        pct = (count / len(mapping_results)) * 100
        f.write(f"| {method} | {count} | {pct:.1f}% |\n")
    
    f.write("\n---\n\n")
    f.write("## Complete Mapping Table\n\n")
    f.write("| V3 ID | V2 ID | V1 ID | Restaurant Name | Address | Match Method |\n")
    f.write("|-------|-------|-------|-----------------|---------|---------------|\n")
    
    for result in sorted(mapping_results, key=lambda x: int(x['v3_id'])):
        v1_id_display = result['v1_id'] if result['v1_id'] else 'N/A'
        f.write(f"| {result['v3_id']} | {result['v2_id']} | {v1_id_display} | {result['name']} | {result['address']} | {result['match_method']} |\n")
    
    f.write("\n---\n\n")
    f.write("## Validation Status\n\n")
    f.write("**All validation checks passed**\n\n")
    f.write("- All V2 restaurants successfully mapped to V3 IDs\n")
    f.write("- No unmapped restaurants found\n")
    f.write("- Ready to proceed to SQL generation\n\n")

print(f"[+] Report saved to: {OUTPUT_REPORT_MD}")

print("\n" + "="*80)
print("[COMPLETE] STEP 1 COMPLETE - Proceeding to Step 2")
print("="*80 + "\n")

