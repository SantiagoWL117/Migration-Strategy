"""
Check if the 21 restaurants with V1 delivery area polygons exist in the V2 matched list.
"""

# 5 MVP restaurants with polygons (Phase 1)
mvp_restaurants = [
    {"v1_id": 90, "v3_id": 8, "name": "Lucky Star Chinese Food"},
    {"v1_id": 203, "v3_id": 87, "name": "Champa Thai Cuisine"},
    {"v1_id": 224, "v3_id": 105, "name": "Ginkgo Garden"},
    {"v1_id": 239, "v3_id": 119, "name": "Hung Mein"},
    {"v1_id": 387, "v3_id": 245, "name": "Orchid Sushi"},
]

# 15 Phase 2 restaurants with polygons (from PHASE2_FIX_RESULTS.md)
# Batch 1 (6 restaurants)
phase2_batch1 = [
    {"v1_id": 89, "v3_id": 7, "name": "Imilio's Pizzeria"},
    {"v1_id": 95, "v3_id": 13, "name": "Papa Joe's Pizza - Downtown"},
    {"v1_id": 175, "v3_id": 62, "name": "Vanier Pizza & Subs"},
    {"v1_id": 187, "v3_id": 72, "name": "Cathay Restaurants"},
    {"v1_id": 199, "v3_id": 83, "name": "Season's Pizza"},
    {"v1_id": 206, "v3_id": 90, "name": "Milano"},
]

# Batch 2 (8 restaurants)
phase2_batch2 = [
    {"v1_id": 219, "v3_id": 1010, "name": "Lemongrass Thai Cuisine"},
    {"v1_id": 246, "v3_id": 124, "name": "Carlo's Pizza"},
    {"v1_id": 255, "v3_id": 131, "name": "Centertown Donair & Pizza"},
    {"v1_id": 264, "v3_id": 139, "name": "Pizza Bravo"},
    {"v1_id": 280, "v3_id": 147, "name": "Pho Dau Bo Restaurant - Kitchener"},
    {"v1_id": 374, "v3_id": 234, "name": "New Mukut Restaurant Indian Cuisine"},
    {"v1_id": 383, "v3_id": 241, "name": "Beneci Pizza"},
    {"v1_id": 413, "v3_id": 267, "name": "Lucky Fortune"},
]

# Batch 3 (1 restaurant)
phase2_batch3 = [
    {"v1_id": 612, "v3_id": 437, "name": "Papa Joe's Fried Chicken - Downtown"},
]

# All 21 restaurants (11 so far, need 10 more from batches 2 and 3)
all_polygon_restaurants = mvp_restaurants + phase2_batch1 + phase2_batch2 + phase2_batch3

# 90 matched V2 restaurants (from V2_V3_MATCHING_REPORT.md)
v2_matched_v3_ids = [
    7, 8, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 55, 57, 59, 62, 65, 69, 70, 72,
    75, 77, 84, 87, 88, 89, 90, 91, 92, 93, 95, 97, 105, 106, 109, 119, 123, 124,
    126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 196, 199, 205, 211, 234, 241,
    245, 265, 267, 269, 328, 349, 350, 367, 376, 437, 479, 491, 497, 502, 507, 511,
    515, 519, 521, 540, 651, 696, 721, 924, 941, 943, 948, 949, 985, 1010, 1011,
    1012, 1013, 1014, 1016, 1017
]

print("="*70)
print("CHECKING: 21 V1 Polygon Restaurants vs 90 V2 Matched Restaurants")
print("="*70)
print()

# Check Phase 1 MVP
print("PHASE 1 MVP (5 restaurants with polygons):")
print("-" * 70)
mvp_in_v2 = []
mvp_not_in_v2 = []

for resto in mvp_restaurants:
    if resto["v3_id"] in v2_matched_v3_ids:
        mvp_in_v2.append(resto)
        print(f"[+] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | IN V2")
    else:
        mvp_not_in_v2.append(resto)
        print(f"[-] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | NOT IN V2")

print()
print(f"MVP Summary: {len(mvp_in_v2)}/5 in V2 matched list")
print()

# Check Phase 2 Batch 1
print("PHASE 2 BATCH 1 (6 restaurants with polygons):")
print("-" * 70)
batch1_in_v2 = []
batch1_not_in_v2 = []

for resto in phase2_batch1:
    if resto["v3_id"] in v2_matched_v3_ids:
        batch1_in_v2.append(resto)
        print(f"[+] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | IN V2")
    else:
        batch1_not_in_v2.append(resto)
        print(f"[-] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | NOT IN V2")

print()
print(f"Batch 1 Summary: {len(batch1_in_v2)}/6 in V2 matched list")
print()

# Check Phase 2 Batch 2
print("PHASE 2 BATCH 2 (8 restaurants with polygons):")
print("-" * 70)
batch2_in_v2 = []
batch2_not_in_v2 = []

for resto in phase2_batch2:
    if resto["v3_id"] in v2_matched_v3_ids:
        batch2_in_v2.append(resto)
        print(f"[+] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | IN V2")
    else:
        batch2_not_in_v2.append(resto)
        print(f"[-] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | NOT IN V2")

print()
print(f"Batch 2 Summary: {len(batch2_in_v2)}/8 in V2 matched list")
print()

# Check Phase 2 Batch 3
print("PHASE 2 BATCH 3 (1 restaurant with polygons):")
print("-" * 70)
batch3_in_v2 = []
batch3_not_in_v2 = []

for resto in phase2_batch3:
    if resto["v3_id"] in v2_matched_v3_ids:
        batch3_in_v2.append(resto)
        print(f"[+] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | IN V2")
    else:
        batch3_not_in_v2.append(resto)
        print(f"[-] V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']:<35} | NOT IN V2")

print()
print(f"Batch 3 Summary: {len(batch3_in_v2)}/1 in V2 matched list")
print()

# Overall summary
print("="*70)
print("FINAL SUMMARY - ALL 21 RESTAURANTS WITH V1 POLYGONS")
print("="*70)
total_in_v2 = len(mvp_in_v2) + len(batch1_in_v2) + len(batch2_in_v2) + len(batch3_in_v2)
total_not_in_v2 = len(mvp_not_in_v2) + len(batch1_not_in_v2) + len(batch2_not_in_v2) + len(batch3_not_in_v2)

print(f"Restaurants with polygons IN V2 matched list: {total_in_v2}/21 ({total_in_v2/21*100:.1f}%)")
print(f"Restaurants with polygons NOT in V2 matched list: {total_not_in_v2}/21 ({total_not_in_v2/21*100:.1f}%)")
print()

if total_not_in_v2 > 0:
    print("RESTAURANTS WITH POLYGONS NOT IN V2:")
    print("-" * 70)
    for resto in mvp_not_in_v2 + batch1_not_in_v2 + batch2_not_in_v2 + batch3_not_in_v2:
        print(f"  V3 ID {resto['v3_id']:4} | V1 ID {resto['v1_id']:3} | {resto['name']}")
    print()

print("="*70)

