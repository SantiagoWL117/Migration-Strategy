import csv

# 16 Non-MVP restaurants with V1 polygons
NON_MVP_POLYGON_RESTAURANTS = [
    # Phase 2 Batch 1
    {'v3_id': 7, 'v1_id': 89, 'v2_id': None, 'name': "Imilio's Pizzeria", 'address': '110 Bearbrook Rd'},
    {'v3_id': 13, 'v1_id': 95, 'v2_id': 1037, 'name': "Papa Joe's Pizza - Downtown", 'address': '527 Bronson Ave'},
    {'v3_id': 62, 'v1_id': 175, 'v2_id': 1086, 'name': "Vanier Pizza & Subs", 'address': '201 Marier Ave'},
    {'v3_id': 72, 'v1_id': 187, 'v2_id': 1096, 'name': "Cathay Restaurants", 'address': '1423 Woodroffe Ave'},
    {'v3_id': 83, 'v1_id': 199, 'v2_id': None, 'name': "Season's Pizza", 'address': '725 Somerset Street West'},
    {'v3_id': 90, 'v1_id': 206, 'v2_id': 1114, 'name': "Milano", 'address': '3796 Champlain Rd'},
    # Phase 2 Batch 2
    {'v3_id': 1010, 'v1_id': 219, 'v2_id': 1126, 'name': "Lemongrass Thai Cuisine", 'address': '331 Elgin St'},
    {'v3_id': 124, 'v1_id': 246, 'v2_id': 1148, 'name': "Carlo's Pizza", 'address': '60 Harmer Ave'},
    {'v3_id': 131, 'v1_id': 255, 'v2_id': 1155, 'name': "Centertown Donair & Pizza", 'address': '422 Bronson Ave'},
    {'v3_id': 139, 'v1_id': 264, 'v2_id': 1163, 'name': "Pizza Bravo", 'address': '108 boul Lorrain'},
    {'v3_id': 147, 'v1_id': 280, 'v2_id': None, 'name': "Pho Dau Bo Restaurant - Kitchener", 'address': '685 Fischer Hallman Rd Unit G'},
    {'v3_id': 234, 'v1_id': 374, 'v2_id': 1259, 'name': "New Mukut Restaurant Indian Cuisine", 'address': '1968 Portobello Blvd'},
    {'v3_id': 241, 'v1_id': 383, 'v2_id': 1266, 'name': "Beneci Pizza", 'address': '4 Lorry Greenberg Dr'},
    {'v3_id': 267, 'v1_id': 413, 'v2_id': 1292, 'name': "Lucky Fortune", 'address': '1970 Trim Rd'},
    # Phase 2 Batch 3
    {'v3_id': 437, 'v1_id': 612, 'v2_id': 1462, 'name': "Papa Joe's Fried Chicken - Downtown", 'address': '527 Bronson Ave'},
]

print("\n" + "="*80)
print("VERIFYING V2 COORDINATES FOR 16 NON-MVP POLYGON RESTAURANTS")
print("="*80)

# Load V2 export and check for coordinates
v2_data = {}
with open('extracted_data/v2_delivery_areas_export_FILTERED.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v2_id = row['v2_id']
        coords = row['coords']
        
        # Check if coords exist and are not empty
        has_coords = coords and coords.strip() and coords != '\\N'
        
        v2_data[v2_id] = {
            'v1_id': row['v1_id'],
            'name': row['name'],
            'coords': coords,
            'has_coords': has_coords
        }

print(f"\nLoaded V2 export: {len(v2_data)} unique V2 IDs")

# Check each non-MVP restaurant
restaurants_with_v2_coords = []
restaurants_without_v2_coords = []

for resto in NON_MVP_POLYGON_RESTAURANTS:
    v2_id = str(resto['v2_id']) if resto['v2_id'] else None
    
    if v2_id and v2_id in v2_data:
        if v2_data[v2_id]['has_coords']:
            restaurants_with_v2_coords.append({
                **resto,
                'coords_preview': v2_data[v2_id]['coords'][:50] + '...' if len(v2_data[v2_id]['coords']) > 50 else v2_data[v2_id]['coords']
            })
        else:
            restaurants_without_v2_coords.append(resto)
    else:
        restaurants_without_v2_coords.append(resto)

print("\n" + "="*80)
print(f"RESTAURANTS WITH V2 COORDINATES: {len(restaurants_with_v2_coords)}")
print("="*80)
print("\nThese restaurants HAVE V2 coordinates and should be REMOVED from the list:")
print("(They don't need V1 polygon data since V2 has better/newer data)\n")

for resto in restaurants_with_v2_coords:
    print(f"[REMOVE] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | V2 ID {resto['v2_id']:4} | {resto['name']:<40}")
    print(f"         Coords preview: {resto['coords_preview']}\n")

print("\n" + "="*80)
print(f"RESTAURANTS WITHOUT V2 COORDINATES: {len(restaurants_without_v2_coords)}")
print("="*80)
print("\nThese restaurants NEED V1 polygon data (keep in the list):\n")

for resto in restaurants_without_v2_coords:
    v2_status = f"V2 ID {resto['v2_id']}" if resto['v2_id'] else "No V2 ID"
    print(f"[KEEP]   V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {v2_status:<12} | {resto['name']:<40}")

print("\n" + "="*80)
print("SUMMARY")
print("="*80)
print(f"Original non-MVP restaurants with V1 polygons: 16")
print(f"Restaurants WITH V2 coordinates (to remove): {len(restaurants_with_v2_coords)}")
print(f"Restaurants WITHOUT V2 coordinates (to keep): {len(restaurants_without_v2_coords)}")
print(f"\nFinal list should have: {len(restaurants_without_v2_coords)} restaurants")
print("="*80 + "\n")

# Save results for the updated document
import json
with open('extracted_data/v2_coord_verification_results.json', 'w', encoding='utf-8') as f:
    json.dump({
        'with_v2_coords': restaurants_with_v2_coords,
        'without_v2_coords': restaurants_without_v2_coords
    }, f, indent=2)

print("[+] Results saved to: v2_coord_verification_results.json")

