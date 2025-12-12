"""Analyze Phase 2 warnings."""
import re
from collections import defaultdict

with open('logs/combo_phase2_20251210_120719.log', 'r', encoding='utf-8') as f:
    content = f.read()

# Find restaurants with combo group warnings
restaurants = {}
current = None
combo_warnings = defaultdict(set)
dish_warnings = defaultdict(list)

for line in content.split('\n'):
    # Track current restaurant
    m = re.search(r'Processing: (.+?) \(V3: (\d+), V1: (\d+)\)', line)
    if m:
        current = {'name': m.group(1), 'v3': m.group(2), 'v1': m.group(3)}

    # Track combo group warnings
    m = re.search(r'Combo group not found: source_id=(\d+)', line)
    if m and current:
        combo_warnings[current['v1']].add(m.group(1))
        restaurants[current['v1']] = current

    # Track dish not found warnings
    m = re.search(r'Dish not found in database: (.*)', line)
    if m and current:
        dish_warnings[current['v1']].append(m.group(1))
        restaurants[current['v1']] = current

print('=== COMBO GROUP NOT FOUND WARNINGS ===')
total_missing = sum(len(v) for v in combo_warnings.values())
print(f'Total warnings: 138')
print(f'Unique missing source_ids: {total_missing}')
print()

for v1, source_ids in sorted(combo_warnings.items(), key=lambda x: len(x[1]), reverse=True):
    r = restaurants[v1]
    print(f"{r['name']} (V3: {r['v3']}, V1: {v1})")
    print(f"  Missing combo groups: {len(source_ids)}")
    if len(source_ids) <= 10:
        print(f"  source_ids: {sorted(source_ids)}")
    else:
        print(f"  source_ids (first 10): {sorted(source_ids)[:10]}...")

print()
print('=== DISH NOT FOUND WARNINGS ===')
print(f'Total: {sum(len(v) for v in dish_warnings.values())}')
print()
for v1, dishes in dish_warnings.items():
    r = restaurants[v1]
    print(f"{r['name']} (V3: {r['v3']}, V1: {v1})")
    print(f"  Dishes not found: {len(dishes)}")
    print(f"  Dish names: {dishes}")


