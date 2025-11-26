#!/usr/bin/env python3
"""
Filter out the 5 MVP restaurants that were already processed in Phase 1
MVP V3 IDs: 8, 87, 105, 119, 245
"""

import csv
import json

# MVP restaurant V3 IDs (already processed in Phase 1)
MVP_V3_IDS = ['8', '87', '105', '119', '245']

print("Filtering out 5 MVP restaurants from Phase 2 data...")
print(f"MVP V3 IDs to exclude: {MVP_V3_IDS}")
print("="*60)

# Filter CSV data
with open('all_restaurants_extracted_data.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    all_data = list(reader)

filtered_data = [r for r in all_data if r['v3_id'] not in MVP_V3_IDS]

with open('phase2_only_extracted_data.csv', 'w', encoding='utf-8', newline='') as f:
    if filtered_data:
        writer = csv.DictWriter(f, fieldnames=filtered_data[0].keys())
        writer.writeheader()
        writer.writerows(filtered_data)

print(f"CSV: {len(all_data)} total -> {len(filtered_data)} after filtering ({len(all_data) - len(filtered_data)} MVP excluded)")

# Filter JSON BLOB data
for blob_type in ['delivery_schedule', 'deliveryArea', 'fee']:
    with open(f'all_restaurants_blob_{blob_type}.json', 'r', encoding='utf-8') as f:
        all_blobs = json.load(f)
    
    filtered_blobs = [b for b in all_blobs if b['v3_id'] not in MVP_V3_IDS]
    
    with open(f'phase2_only_blob_{blob_type}.json', 'w', encoding='utf-8') as f:
        json.dump(filtered_blobs, f, indent=2)
    
    print(f"{blob_type}: {len(all_blobs)} total -> {len(filtered_blobs)} after filtering")

print(f"\n[OK] Filtered data saved to phase2_only_* files")
print(f"Phase 2 will process: {len(filtered_data)} restaurants (159 = 164 - 5 MVP)")







