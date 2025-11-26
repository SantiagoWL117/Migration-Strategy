import csv
import re
from difflib import SequenceMatcher

def normalize_text(text):
    """Normalize text for comparison"""
    if not text:
        return ""
    # Remove extra spaces, convert to lowercase
    text = text.lower().strip()
    # Remove special characters but keep letters, numbers, spaces
    text = re.sub(r'[^\w\s-]', '', text)
    # Collapse multiple spaces
    text = re.sub(r'\s+', ' ', text)
    return text

def similarity_ratio(a, b):
    """Calculate similarity ratio between two strings"""
    return SequenceMatcher(None, normalize_text(a), normalize_text(b)).ratio()

# Read active restaurants
active_restaurants = []
with open('reports/database/Restaurants-active.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    # Skip header lines
    for line in lines[7:]:  # Data starts at line 8 (0-indexed line 7)
        if line.strip() and line.startswith('|'):
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 5 and parts[1] and parts[2]:
                # Extract: name, address, version, v3_id
                name = parts[1]
                address = parts[2]
                version = parts[3]
                v3_id = parts[4]
                
                # Skip TBD entries, header row, and separator row
                if (v3_id and v3_id != 'TBD' and name != 'Restaurant Name' 
                    and not name.startswith('---') and not v3_id.startswith('---')):
                    active_restaurants.append({
                        'name': name,
                        'address': address,
                        'version': version,
                        'v3_id': v3_id
                    })

print(f"Loaded {len(active_restaurants)} active restaurants from Restaurants-active.md")

# Read V2 delivery areas
v2_delivery_areas = {}  # Group by restaurant (v2_id + name + address)
with open('extracted_data/v2_delivery_areas_export.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v2_id = row['v2_id']
        name = row['name']
        address = row['address']
        
        # Create a unique key for each restaurant
        key = (v2_id, name, address)
        if key not in v2_delivery_areas:
            v2_delivery_areas[key] = {
                'v2_id': v2_id,
                'v1_id': row['v1_id'],
                'name': name,
                'address': address,
                'area_count': 0
            }
        v2_delivery_areas[key]['area_count'] += 1

print(f"Loaded {len(v2_delivery_areas)} unique restaurants from v2_delivery_areas_export.csv")

# Match restaurants
matches = []
missing_from_v2_delivery_areas = []

for active_resto in active_restaurants:
    active_name = active_resto['name']
    active_address = active_resto['address']
    active_v3_id = active_resto['v3_id']
    
    best_match = None
    highest_similarity = 0
    
    # Try to find a match in V2 delivery areas
    for v2_key, v2_resto in v2_delivery_areas.items():
        v2_name = v2_resto['name']
        v2_address = v2_resto['address']
        
        # Calculate similarity for name and address
        name_sim = similarity_ratio(active_name, v2_name)
        address_sim = similarity_ratio(active_address, v2_address)
        
        # Combined similarity (weighted more towards address for unique identification)
        combined_sim = (name_sim * 0.4 + address_sim * 0.6)
        
        # Consider it a match if combined similarity is >= 85% and both name and address are >= 75%
        if combined_sim >= 0.85 and name_sim >= 0.75 and address_sim >= 0.75:
            if combined_sim > highest_similarity:
                highest_similarity = combined_sim
                best_match = v2_resto
    
    if best_match:
        matches.append({
            'v3_id': active_v3_id,
            'v3_name': active_name,
            'v3_address': active_address,
            'v3_version': active_resto['version'],
            'v2_id': best_match['v2_id'],
            'v2_v1_id': best_match['v1_id'],
            'v2_name': best_match['name'],
            'v2_address': best_match['address'],
            'v2_area_count': best_match['area_count'],
            'similarity': f"{highest_similarity*100:.1f}%"
        })
    else:
        missing_from_v2_delivery_areas.append({
            'v3_id': active_v3_id,
            'v3_name': active_name,
            'v3_address': active_address,
            'v3_version': active_resto['version']
        })

# Sort matches by V3 ID (numeric)
matches.sort(key=lambda x: int(x['v3_id']))
missing_from_v2_delivery_areas.sort(key=lambda x: int(x['v3_id']))

# Generate report
with open('extracted_data/V2_DELIVERY_AREAS_MATCHING_REPORT.md', 'w', encoding='utf-8') as f:
    f.write("# V2 Delivery Areas Matching Report\n\n")
    f.write(f"**Generated:** {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    
    f.write("## Summary\n\n")
    f.write(f"- **Total Active Restaurants:** {len(active_restaurants)}\n")
    f.write(f"- **Restaurants with V2 Delivery Areas:** {len(matches)} ({len(matches)/len(active_restaurants)*100:.1f}%)\n")
    f.write(f"- **Restaurants WITHOUT V2 Delivery Areas:** {len(missing_from_v2_delivery_areas)} ({len(missing_from_v2_delivery_areas)/len(active_restaurants)*100:.1f}%)\n\n")
    
    # Count by version
    v1_with_areas = sum(1 for m in matches if m['v3_version'] == 'V1')
    v2_with_areas = sum(1 for m in matches if m['v3_version'] == 'V2')
    v1_without_areas = sum(1 for m in missing_from_v2_delivery_areas if m['v3_version'] == 'V1')
    v2_without_areas = sum(1 for m in missing_from_v2_delivery_areas if m['v3_version'] == 'V2')
    
    f.write("### Breakdown by Version\n\n")
    f.write("| Version | With V2 Delivery Areas | Without V2 Delivery Areas | Total |\n")
    f.write("| ------- | ---------------------- | ------------------------- | ----- |\n")
    f.write(f"| V1      | {v1_with_areas}                     | {v1_without_areas}                        | {v1_with_areas + v1_without_areas}    |\n")
    f.write(f"| V2      | {v2_with_areas}                     | {v2_without_areas}                        | {v2_with_areas + v2_without_areas}    |\n\n")
    
    f.write("---\n\n")
    
    f.write(f"## Restaurants WITH V2 Delivery Areas ({len(matches)} restaurants)\n\n")
    f.write("| V3 ID | Restaurant Name | V3 Address | V2 ID | V2 Address | Area Count | Similarity |\n")
    f.write("| ----- | --------------- | ---------- | ----- | ---------- | ---------- | ---------- |\n")
    for match in matches:
        f.write(f"| {match['v3_id']} | {match['v3_name']} | {match['v3_address']} | {match['v2_id']} | {match['v2_address']} | {match['v2_area_count']} | {match['similarity']} |\n")
    
    f.write("\n---\n\n")
    
    f.write(f"## Restaurants WITHOUT V2 Delivery Areas ({len(missing_from_v2_delivery_areas)} restaurants)\n\n")
    f.write("| V3 ID | Restaurant Name | V3 Address | Version |\n")
    f.write("| ----- | --------------- | ---------- | ------- |\n")
    for resto in missing_from_v2_delivery_areas:
        f.write(f"| {resto['v3_id']} | {resto['v3_name']} | {resto['v3_address']} | {resto['v3_version']} |\n")

# Save matches to CSV for further processing
with open('extracted_data/v2_delivery_areas_matches.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['v3_id', 'v3_name', 'v3_address', 'v3_version', 'v2_id', 'v2_v1_id', 'v2_name', 'v2_address', 'v2_area_count', 'similarity'])
    writer.writeheader()
    writer.writerows(matches)

print(f"\n[+] Matching complete!")
print(f"    - {len(matches)} restaurants WITH V2 delivery areas")
print(f"    - {len(missing_from_v2_delivery_areas)} restaurants WITHOUT V2 delivery areas")
print(f"\n[+] Files created:")
print(f"    - extracted_data/V2_DELIVERY_AREAS_MATCHING_REPORT.md")
print(f"    - extracted_data/v2_delivery_areas_matches.csv")

