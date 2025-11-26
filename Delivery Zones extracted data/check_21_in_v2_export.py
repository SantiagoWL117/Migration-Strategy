import csv

# List of 21 restaurants with V1 polygons (from previous analysis)
polygon_restaurants = [
    # Phase 1 MVP (5)
    {'v3_id': 8, 'v1_id': 90, 'name': 'Lucky Star Chinese Food', 'address': '1615 Orleans Blvd.'},
    {'v3_id': 87, 'v1_id': 203, 'name': 'Champa Thai Cuisine', 'address': '193 King Edward Ave'},
    {'v3_id': 105, 'v1_id': 224, 'name': 'Ginkgo Garden', 'address': '2225 St Laurent Blvd'},
    {'v3_id': 119, 'v1_id': 239, 'name': 'Hung Mein', 'address': '2567 Baseline Rd'},
    {'v3_id': 245, 'v1_id': 387, 'name': 'Orchid Sushi', 'address': '445 Laurier Ave W'},
    # Phase 2 Batch 1 (6)
    {'v3_id': 7, 'v1_id': 89, 'name': "Imilio's Pizzeria", 'address': '110 Bearbrook Rd'},
    {'v3_id': 13, 'v1_id': 95, 'name': "Papa Joe's Pizza - Downtown", 'address': '527 Bronson Ave'},
    {'v3_id': 62, 'v1_id': 175, 'name': 'Vanier Pizza & Subs', 'address': '201 Marier Ave'},
    {'v3_id': 72, 'v1_id': 187, 'name': 'Cathay Restaurants', 'address': '1423 Woodroffe Ave'},
    {'v3_id': 83, 'v1_id': 199, 'name': "Season's Pizza", 'address': '725 Somerset Street West'},
    {'v3_id': 90, 'v1_id': 206, 'name': 'Milano', 'address': '3796 Champlain Rd'},
    # Phase 2 Batch 2 (8)
    {'v3_id': 1010, 'v1_id': 219, 'name': 'Lemongrass Thai Cuisine', 'address': '331 Elgin St'},
    {'v3_id': 124, 'v1_id': 246, 'name': "Carlo's Pizza", 'address': '60 Harmer Ave'},
    {'v3_id': 131, 'v1_id': 255, 'name': 'Centertown Donair & Pizza', 'address': '422 Bronson Ave'},
    {'v3_id': 139, 'v1_id': 264, 'name': 'Pizza Bravo', 'address': '108 boul Lorrain'},
    {'v3_id': 147, 'v1_id': 280, 'name': 'Pho Dau Bo Restaurant - Kitchener', 'address': '685 Fischer Hallman Rd Unit G'},
    {'v3_id': 234, 'v1_id': 374, 'name': 'New Mukut Restaurant Indian Cuisine', 'address': '1968 Portobello Blvd'},
    {'v3_id': 241, 'v1_id': 383, 'name': 'Beneci Pizza', 'address': '4 Lorry Greenberg Dr'},
    {'v3_id': 267, 'v1_id': 413, 'name': 'Lucky Fortune', 'address': '1970 Trim Rd'},
    # Phase 2 Batch 3 (1)
    {'v3_id': 437, 'v1_id': 612, 'name': "Papa Joe's Fried Chicken - Downtown", 'address': '527 Bronson Ave'},
]

# Read V2 delivery areas export and collect unique restaurants
v2_restaurants = {}
with open('extracted_data/v2_delivery_areas_export.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v2_id = row['v2_id']
        v1_id = row['v1_id']
        name = row['name']
        address = row['address']
        
        key = (v2_id, v1_id, name)
        if key not in v2_restaurants:
            v2_restaurants[key] = {
                'v2_id': v2_id,
                'v1_id': v1_id,
                'name': name,
                'address': address
            }

print("="*80)
print("CHECKING: 21 V1 Polygon Restaurants in V2 Delivery Areas Export")
print("="*80)
print()

found_in_v2 = []
not_found_in_v2 = []

for resto in polygon_restaurants:
    v3_id = resto['v3_id']
    v1_id = resto['v1_id']
    name = resto['name']
    address = resto['address']
    
    # Check if this V1 ID exists in the V2 export
    found = False
    matched_v2_id = None
    
    for v2_key, v2_resto in v2_restaurants.items():
        if v2_resto['v1_id'] == str(v1_id):
            found = True
            matched_v2_id = v2_resto['v2_id']
            break
    
    if found:
        found_in_v2.append({
            'v3_id': v3_id,
            'v1_id': v1_id,
            'v2_id': matched_v2_id,
            'name': name,
            'address': address
        })
        print(f"[+] V3 ID {v3_id:4} | V1 ID {v1_id:3} | V2 ID {matched_v2_id:4} | {name}")
    else:
        not_found_in_v2.append({
            'v3_id': v3_id,
            'v1_id': v1_id,
            'name': name,
            'address': address
        })
        print(f"[-] V3 ID {v3_id:4} | V1 ID {v1_id:3} | V2 ID N/A  | {name}")

print()
print("="*80)
print("SUMMARY")
print("="*80)
print(f"Total restaurants with V1 polygons: {len(polygon_restaurants)}")
print(f"Found in V2 delivery areas export: {len(found_in_v2)} ({len(found_in_v2)/len(polygon_restaurants)*100:.1f}%)")
print(f"NOT found in V2 delivery areas export: {len(not_found_in_v2)} ({len(not_found_in_v2)/len(polygon_restaurants)*100:.1f}%)")
print()

if not_found_in_v2:
    print("RESTAURANTS NOT IN V2 EXPORT:")
    print("-" * 80)
    for resto in not_found_in_v2:
        print(f"  V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']}")
    print()

print("="*80)

