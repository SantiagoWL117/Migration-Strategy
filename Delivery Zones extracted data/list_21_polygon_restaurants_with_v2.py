"""
List all 21 restaurants with V1 delivery area polygons and their V2 IDs.
"""

# 21 restaurants with V1 polygons and their V2 matching status
polygon_restaurants = [
    # Phase 1 MVP
    {'v1_id': 90, 'v3_id': 8, 'name': 'Lucky Star Chinese Food', 'address': '1615 Orleans Blvd.', 'v2_id': 1032},
    {'v1_id': 203, 'v3_id': 87, 'name': 'Champa Thai Cuisine', 'address': '193 King Edward Ave', 'v2_id': 1111},
    {'v1_id': 224, 'v3_id': 105, 'name': 'Ginkgo Garden', 'address': '2225 St Laurent Blvd', 'v2_id': 1129},
    {'v1_id': 239, 'v3_id': 119, 'name': 'Hung Mein', 'address': '2567 Baseline Rd', 'v2_id': 1143},
    {'v1_id': 387, 'v3_id': 245, 'name': 'Orchid Sushi', 'address': '445 Laurier Ave W', 'v2_id': 1270},
    # Phase 2 Batch 1
    {'v1_id': 89, 'v3_id': 7, 'name': "Imilio's Pizzeria", 'address': '110 Bearbrook Rd', 'v2_id': 1031},
    {'v1_id': 95, 'v3_id': 13, 'name': "Papa Joe's Pizza - Downtown", 'address': '527 Bronson Ave', 'v2_id': 1037},
    {'v1_id': 175, 'v3_id': 62, 'name': 'Vanier Pizza & Subs', 'address': '201 Marier Ave', 'v2_id': 1086},
    {'v1_id': 187, 'v3_id': 72, 'name': 'Cathay Restaurants', 'address': '1423 Woodroffe Ave', 'v2_id': 1096},
    {'v1_id': 199, 'v3_id': 83, 'name': "Season's Pizza", 'address': '725 Somerset Street West', 'v2_id': None},
    {'v1_id': 206, 'v3_id': 90, 'name': 'Milano', 'address': '3796 Champlain Rd', 'v2_id': 1114},
    # Phase 2 Batch 2
    {'v1_id': 219, 'v3_id': 1010, 'name': 'Lemongrass Thai Cuisine', 'address': '331 Elgin St', 'v2_id': 1126},
    {'v1_id': 246, 'v3_id': 124, 'name': "Carlo's Pizza", 'address': '60 Harmer Ave', 'v2_id': 1148},
    {'v1_id': 255, 'v3_id': 131, 'name': 'Centertown Donair & Pizza', 'address': '422 Bronson Ave', 'v2_id': 1155},
    {'v1_id': 264, 'v3_id': 139, 'name': 'Pizza Bravo', 'address': '108 boul Lorrain', 'v2_id': 1163},
    {'v1_id': 280, 'v3_id': 147, 'name': 'Pho Dau Bo Restaurant - Kitchener', 'address': '685 Fischer Hallman Rd Unit G', 'v2_id': 1171},
    {'v1_id': 374, 'v3_id': 234, 'name': 'New Mukut Restaurant Indian Cuisine', 'address': '1968 Portobello Blvd', 'v2_id': 1259},
    {'v1_id': 383, 'v3_id': 241, 'name': 'Beneci Pizza', 'address': '4 Lorry Greenberg Dr', 'v2_id': 1266},
    {'v1_id': 413, 'v3_id': 267, 'name': 'Lucky Fortune', 'address': '1970 Trim Rd', 'v2_id': 1292},
    # Phase 2 Batch 3
    {'v1_id': 612, 'v3_id': 437, 'name': "Papa Joe's Fried Chicken - Downtown", 'address': '527 Bronson Ave', 'v2_id': 1462},
]

# Print all 21 restaurants
print('\n' + '='*120)
print('ALL 21 RESTAURANTS WITH V1 DELIVERY AREA POLYGONS')
print('='*120)
print(f'\n{"V3 ID":<7} | {"V1 ID":<7} | {"V2 ID":<7} | {"Restaurant Name":<40} | {"Address":<45}')
print('-'*120)

for resto in polygon_restaurants:
    v2_display = str(resto['v2_id']) if resto['v2_id'] else 'N/A'
    print(f"{resto['v3_id']:<7} | {resto['v1_id']:<7} | {v2_display:<7} | {resto['name']:<40} | {resto['address']:<45}")

# Print V2 IDs in requested format
print('\n' + '='*120)
print('V2 IDS OF THE 20 MATCHED RESTAURANTS (for SQL queries)')
print('='*120)
v2_ids = [r['v2_id'] for r in polygon_restaurants if r['v2_id']]
v2_ids_str = '(' + ', '.join(map(str, v2_ids)) + ')'
print(f'\n{v2_ids_str}')
print(f'\nTotal: {len(v2_ids)} V2 IDs')
print(f'\nMissing from V2: Season\'s Pizza (V3 ID: 83, V1 ID: 199, Address: 725 Somerset Street West)')
print('\n' + '='*120)
print()

