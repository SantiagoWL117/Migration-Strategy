import json
from datetime import datetime

print("\n" + "="*80)
print("STEP 4: EXTRACT V1 POLYGONS TO SQL")
print("="*80)

# Target restaurants (from 3_RESTAURANTS_NEEDING_V1_POLYGONS.md)
target_v1_ids = [89, 199, 280]
target_restaurants = {
    89: {'v3_id': 7, 'name': "Imilio's Pizzeria", 'batch': 'batch_1_30'},
    199: {'v3_id': 83, 'name': "Season's Pizza", 'batch': 'batch_1_30'},
    280: {'v3_id': 147, 'name': "Pho Dau Bo Restaurant - Kitchener", 'batch': 'batch_31_60'}
}

print(f"\n[1/3] Loading V1 deserialized data for 3 target restaurants...")

v1_polygons = []

for v1_id, resto_info in target_restaurants.items():
    batch_file = f'extracted_data/phase2_all_restaurants/{resto_info["batch"]}_deserialized_areas.json'
    
    try:
        with open(batch_file, 'r', encoding='utf-8') as f:
            batch_data = json.load(f)
        
        # Get this restaurant's data
        if str(v1_id) in batch_data:
            resto_data = batch_data[str(v1_id)]
            
            if resto_data['area_entries']:
                for area_entry in resto_data['area_entries']:
                    v1_polygons.append({
                        'v1_id': v1_id,
                        'v3_id': resto_info['v3_id'],
                        'name': resto_info['name'],
                        'area_number': area_entry['area_number'],
                        'area_name': area_entry['area_name'],
                        'polygon_wkt': area_entry['polygon_wkt']
                    })
                print(f"   [OK] V1 ID {v1_id}: {len(resto_data['area_entries'])} polygon(s) found")
            else:
                print(f"   [WARNING] V1 ID {v1_id}: No polygons found in deserialized data")
        else:
            print(f"   [ERROR] V1 ID {v1_id}: Not found in {batch_file}")
    
    except FileNotFoundError:
        print(f"   [ERROR] Batch file not found: {batch_file}")
    except Exception as e:
        print(f"   [ERROR] V1 ID {v1_id}: {e}")

print(f"\n   Total V1 polygons loaded: {len(v1_polygons)}")

# Generate SQL
print("\n[2/3] Generating SQL file...")

with open('extracted_data/v1_to_v3_delivery_areas.sql', 'w', encoding='utf-8') as f:
    f.write("-- ============================================================================\n")
    f.write("-- V1 Delivery Areas Migration to V3\n")
    f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f"-- Total Restaurants: {len(target_restaurants)}\n")
    f.write(f"-- Total Delivery Areas: {len(v1_polygons)}\n")
    f.write("-- Note: These restaurants have V1 polygons but NO V2 coordinate data\n")
    f.write("-- ============================================================================\n\n")
    
    current_v3_id = None
    
    for polygon in v1_polygons:
        if polygon['v3_id'] != current_v3_id:
            current_v3_id = polygon['v3_id']
            f.write(f"\n-- Restaurant: {polygon['name']} (V3 ID: {polygon['v3_id']}, V1 ID: {polygon['v1_id']})\n")
        
        # V1 polygons already have WKT format, use directly
        f.write(f"INSERT INTO menuca_v3.restaurant_delivery_areas\n")
        f.write(f"  (restaurant_id, area_number, area_name, geometry)\n")
        f.write(f"VALUES\n")
        f.write(f"  ({polygon['v3_id']}, {polygon['area_number']}, '{polygon['area_name']}', \n")
        f.write(f"   ST_GeomFromText('{polygon['polygon_wkt']}', 4326));\n")

print(f"   SQL file generated: extracted_data/v1_to_v3_delivery_areas.sql")

# Generate summary report
print("\n[3/3] Generating summary report...")

with open('extracted_data/V1_POLYGON_EXTRACTION_SUMMARY.md', 'w', encoding='utf-8') as f:
    f.write("# V1 Polygon Extraction Summary\n\n")
    f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    f.write("---\n\n")
    f.write("## Summary\n\n")
    f.write(f"- **Target restaurants:** {len(target_restaurants)}\n")
    f.write(f"- **Polygons extracted:** {len(v1_polygons)}\n")
    f.write(f"- **Success rate:** {len(v1_polygons)/len(target_restaurants)*100:.1f}%\n\n")
    
    f.write("---\n\n")
    f.write("## Restaurant Details\n\n")
    f.write("| V3 ID | V1 ID | Restaurant Name | Polygons | Status |\n")
    f.write("|-------|-------|-----------------|----------|--------|\n")
    
    for v1_id, resto_info in target_restaurants.items():
        polygon_count = len([p for p in v1_polygons if p['v1_id'] == v1_id])
        status = "OK" if polygon_count > 0 else "MISSING"
        f.write(f"| {resto_info['v3_id']} | {v1_id} | {resto_info['name']} | {polygon_count} | {status} |\n")
    
    f.write("\n---\n\n")
    f.write("## Source Data\n\n")
    f.write("V1 polygons extracted from deserialized JSON files:\n\n")
    for v1_id, resto_info in target_restaurants.items():
        f.write(f"- V1 ID {v1_id}: `phase2_all_restaurants/{resto_info['batch']}_deserialized_areas.json`\n")
    
    f.write("\n---\n\n")
    f.write("## Next Steps\n\n")
    f.write("1. Run validation script: `python extracted_data/validate_v1_sql.py`\n")
    f.write("2. Review validation report\n")
    f.write("3. Proceed to merge V2 and V1 SQL (Step 6)\n\n")

print(f"   Summary report saved: extracted_data/V1_POLYGON_EXTRACTION_SUMMARY.md")

print("\n" + "="*80)
print(f"[COMPLETE] STEP 4 COMPLETE - Extracted {len(v1_polygons)} polygons for {len(target_restaurants)} restaurants")
print("="*80 + "\n")


