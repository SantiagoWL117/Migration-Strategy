import csv

# 5 MVP restaurants V1 IDs
MVP_V1_IDS = {90, 203, 224, 239, 387}

print("Removing 5 MVP restaurants from filtered V2 export...")

# Read filtered CSV
filtered_rows = []
mvp_rows_removed = []

with open('extracted_data/v2_delivery_areas_export_FILTERED.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    
    for row in reader:
        v1_id = row['v1_id']
        
        # Check if this is an MVP restaurant
        if v1_id and v1_id != '\\N':
            try:
                if int(v1_id) in MVP_V1_IDS:
                    mvp_rows_removed.append(row)
                    continue
            except ValueError:
                pass
        
        filtered_rows.append(row)

print(f"Original rows: {len(filtered_rows) + len(mvp_rows_removed)}")
print(f"MVP rows removed: {len(mvp_rows_removed)}")
print(f"Remaining rows: {len(filtered_rows)}")

# Write updated CSV
with open('extracted_data/v2_delivery_areas_export_FILTERED.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(filtered_rows)

# Also update the main export file
with open('extracted_data/v2_delivery_areas_export.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(filtered_rows)

print("\nMVP restaurants removed:")
for row in mvp_rows_removed:
    print(f"  V1 ID {row['v1_id']:3} | V2 ID {row['v2_id']:4} | {row['name']}")

print("\n[+] Files updated:")
print("    - v2_delivery_areas_export_FILTERED.csv")
print("    - v2_delivery_areas_export.csv")

