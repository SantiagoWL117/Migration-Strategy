import csv
import json
from datetime import datetime

print("\n" + "="*80)
print("STEP 2: PARSE V2 COORDINATES AND GENERATE SQL")
print("="*80)

# Load V2->V3 mapping
print("\n[1/5] Loading V2->V3 mapping...")
with open('extracted_data/v2_v3_id_mapping.json', 'r', encoding='utf-8') as f:
    v2_v3_mapping = {m['v2_id']: m for m in json.load(f)}

print(f"   Loaded {len(v2_v3_mapping)} V2->V3 mappings")

# Load V2 delivery areas CSV
print("\n[2/5] Loading V2 delivery areas CSV...")
v2_areas = []

with open('extracted_data/v2_delivery_areas_export_FILTERED.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v2_areas.append(row)

print(f"   Loaded {len(v2_areas)} V2 delivery area records")

# Group areas by restaurant (some have multiple zones)
print("\n[3/5] Grouping areas by restaurant...")
restaurant_areas = {}

for area in v2_areas:
    v2_id = area['v2_id']
    
    if v2_id not in restaurant_areas:
        restaurant_areas[v2_id] = []
    
    restaurant_areas[v2_id].append(area)

print(f"   Grouped into {len(restaurant_areas)} unique restaurants")

# Parse coordinates and generate SQL
print("\n[4/5] Parsing coordinates and building SQL...")

sql_statements = []
restaurant_count = 0
total_areas = 0
errors = []

for v2_id, areas in restaurant_areas.items():
    # Get V3 ID from mapping
    if v2_id not in v2_v3_mapping:
        errors.append(f"ERROR: V2 ID {v2_id} not found in mapping!")
        continue
    
    v3_id = v2_v3_mapping[v2_id]['v3_id']
    v3_name = v2_v3_mapping[v2_id]['name']
    
    restaurant_count += 1
    area_number = 1
    
    for area in areas:
        coords_string = area['coords']
        
        # Check if coordinates exist
        if not coords_string or coords_string == '\\N':
            continue
        
        # Parse pipe-delimited coordinates: "lat1,lng1|lat2,lng2|..."
        try:
            coord_pairs = coords_string.split('|')
            points = []
            
            for coord_pair in coord_pairs:
                lat, lng = coord_pair.split(',')
                lat = lat.strip()
                lng = lng.strip()
                
                # PostGIS uses lng,lat order (longitude first)
                points.append(f"{lng} {lat}")
            
            # Close the polygon (first point = last point)
            if points:
                points.append(points[0])
            
            # Build PostGIS WKT polygon
            polygon_wkt = f"POLYGON(({','.join(points)}))"
            
            # Extract delivery fee and min order value
            # Handle malformed data (e.g., "2.00 < 50.00;0.00 > 50.00")
            delivery_fee_raw = area['delivery_fee']
            if delivery_fee_raw and delivery_fee_raw != '\\N':
                # Check if it contains conditional logic or special characters
                if any(char in delivery_fee_raw for char in ['<', '>', ';']):
                    # Extract the first numeric value
                    import re
                    match = re.search(r'(\d+\.?\d*)', delivery_fee_raw)
                    delivery_fee = match.group(1) if match else '0'
                else:
                    delivery_fee = delivery_fee_raw
            else:
                delivery_fee = '0'
            
            min_order = area['min_order_value'] if area['min_order_value'] and area['min_order_value'] != '\\N' else 'NULL'
            
            # Generate SQL INSERT statement
            sql_statements.append({
                'v3_id': v3_id,
                'v3_name': v3_name,
                'v2_id': v2_id,
                'area_number': area_number,
                'area_name': f'Delivery Zone {area_number}',
                'polygon_wkt': polygon_wkt,
                'coords_string': coords_string,
                'delivery_fee': delivery_fee,
                'min_order': min_order,
                'point_count': len(coord_pairs)
            })
            
            area_number += 1
            total_areas += 1
            
        except Exception as e:
            errors.append(f"ERROR parsing V2 ID {v2_id} area {area_number}: {e}")
            continue

print(f"   Parsed {total_areas} delivery areas for {restaurant_count} restaurants")
if errors:
    print(f"   Errors encountered: {len(errors)}")
    for error in errors[:5]:  # Show first 5 errors
        print(f"     - {error}")

# Generate SQL file
print("\n[5/5] Generating SQL file...")

with open('extracted_data/v2_to_v3_delivery_areas.sql', 'w', encoding='utf-8') as f:
    f.write("-- ============================================================================\n")
    f.write("-- V2 Delivery Areas Migration to V3\n")
    f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f"-- Total Restaurants: {restaurant_count}\n")
    f.write(f"-- Total Delivery Areas: {total_areas}\n")
    f.write("-- ============================================================================\n\n")
    
    # Group by restaurant for better readability
    current_v3_id = None
    
    for stmt in sql_statements:
        if stmt['v3_id'] != current_v3_id:
            current_v3_id = stmt['v3_id']
            f.write(f"\n-- Restaurant: {stmt['v3_name']} (V3 ID: {stmt['v3_id']}, V2 ID: {stmt['v2_id']})\n")
        
        # Build INSERT statement
        f.write(f"INSERT INTO menuca_v3.restaurant_delivery_areas\n")
        f.write(f"  (restaurant_id, area_number, area_name, geometry, coordinates, delivery_fee, min_order_value)\n")
        f.write(f"VALUES\n")
        f.write(f"  ({stmt['v3_id']}, {stmt['area_number']}, '{stmt['area_name']}', \n")
        f.write(f"   ST_GeomFromText('{stmt['polygon_wkt']}', 4326),\n")
        f.write(f"   '{stmt['coords_string']}',\n")
        f.write(f"   {stmt['delivery_fee']}, {stmt['min_order']});\n")

print(f"   SQL file generated: extracted_data/v2_to_v3_delivery_areas.sql")

# Generate summary report
with open('extracted_data/V2_COORDINATE_PARSING_SUMMARY.md', 'w', encoding='utf-8') as f:
    f.write("# V2 Coordinate Parsing Summary\n\n")
    f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    f.write("---\n\n")
    f.write("## Summary Statistics\n\n")
    f.write(f"- **Total V2 restaurants processed:** {restaurant_count}\n")
    f.write(f"- **Total delivery areas generated:** {total_areas}\n")
    f.write(f"- **Average areas per restaurant:** {total_areas/restaurant_count if restaurant_count > 0 else 0:.2f}\n")
    f.write(f"- **Parsing errors:** {len(errors)}\n\n")
    
    # Count restaurants by number of areas
    areas_distribution = {}
    for v2_id, areas in restaurant_areas.items():
        area_count = len([a for a in areas if a['coords'] and a['coords'] != '\\N'])
        areas_distribution[area_count] = areas_distribution.get(area_count, 0) + 1
    
    f.write("## Distribution by Number of Areas\n\n")
    f.write("| Areas per Restaurant | Count | Percentage |\n")
    f.write("|---------------------|-------|------------|\n")
    for area_count in sorted(areas_distribution.keys()):
        resto_count = areas_distribution[area_count]
        pct = (resto_count / restaurant_count) * 100 if restaurant_count > 0 else 0
        f.write(f"| {area_count} | {resto_count} | {pct:.1f}% |\n")
    
    f.write("\n---\n\n")
    
    if errors:
        f.write("## Errors Encountered\n\n")
        for error in errors:
            f.write(f"- {error}\n")
        f.write("\n---\n\n")
    
    f.write("## Next Steps\n\n")
    f.write("1. Run validation script: `python extracted_data/validate_v2_sql.py`\n")
    f.write("2. Review validation report\n")
    f.write("3. Proceed to V1 polygon extraction (Step 4)\n\n")

print(f"   Summary report: extracted_data/V2_COORDINATE_PARSING_SUMMARY.md")

print("\n" + "="*80)
print("[COMPLETE] STEP 2 COMPLETE - Proceeding to Step 3")
print("="*80 + "\n")

