import csv

# Load the 83 matched restaurants from v2_delivery_areas_matches.csv
matched_v2_ids = set()
with open('extracted_data/v2_delivery_areas_matches.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        matched_v2_ids.add(row['v2_id'])

print(f"Loaded {len(matched_v2_ids)} matched restaurant V2 IDs")

# V1 IDs of the 21 restaurants with polygons (actually 20, one is missing from list)
polygon_v1_ids = {
    90, 203, 224, 239, 387,  # Phase 1 MVP (5)
    89, 95, 175, 187, 199, 206,  # Phase 2 Batch 1 (6)
    219, 246, 255, 264, 280, 374, 383, 413,  # Phase 2 Batch 2 (8)
    612  # Phase 2 Batch 3 (1)
}

print(f"Loaded {len(polygon_v1_ids)} V1 polygon restaurant IDs")

# Read original V2 delivery areas export and filter
original_rows = []
with open('extracted_data/v2_delivery_areas_export.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    for row in reader:
        original_rows.append(row)

print(f"Loaded {len(original_rows)} total rows from V2 export")

# Filter rows: keep if v2_id matches OR v1_id matches
filtered_rows = []
for row in original_rows:
    v2_id = row['v2_id']
    v1_id = row['v1_id']
    
    # Check if this row belongs to the 83 matched restaurants
    if v2_id in matched_v2_ids:
        filtered_rows.append(row)
        continue
    
    # Check if this row belongs to the 21 polygon restaurants (by V1 ID)
    try:
        if v1_id and int(v1_id) in polygon_v1_ids:
            filtered_rows.append(row)
            continue
    except ValueError:
        pass

print(f"Filtered to {len(filtered_rows)} rows")
print(f"Removed {len(original_rows) - len(filtered_rows)} rows")

# Write filtered CSV
with open('extracted_data/v2_delivery_areas_export_FILTERED.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(filtered_rows)

print()
print("="*80)
print("FILTERING COMPLETE")
print("="*80)
print(f"Original file: v2_delivery_areas_export.csv ({len(original_rows)} rows)")
print(f"Filtered file: v2_delivery_areas_export_FILTERED.csv ({len(filtered_rows)} rows)")
print()
print("Filtering criteria:")
print(f"  - 83 matched restaurants (from V2_V3 matching)")
print(f"  - 21 restaurants with V1 polygons (by V1 ID)")
print("="*80)

# Get unique restaurants in filtered file
unique_v2_ids = set()
unique_v1_ids = set()
for row in filtered_rows:
    unique_v2_ids.add(row['v2_id'])
    if row['v1_id']:
        try:
            unique_v1_ids.add(int(row['v1_id']))
        except ValueError:
            pass

print()
print(f"Unique V2 IDs in filtered file: {len(unique_v2_ids)}")
print(f"Unique V1 IDs in filtered file: {len(unique_v1_ids)}")
print()
print("="*80)

