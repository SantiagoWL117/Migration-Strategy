"""Verify V2 dish availability migration completeness."""
import re
import json
import sys
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# Read the SQL dump
with open('../../Database/Legacy Dumps/restaurants_dishes_customization.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# The SQL dump has records in format: (id, dish_id, 'dish_info_json', ...)
# Need to find all records and extract dish_id and the dish_info JSON

all_days = {'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'}
restricted_dishes = []
total_records = 0

# Find all value tuples - each starts with (number,number,'
# Pattern to match: (id,dish_id,'{json}',
tuple_pattern = r"\((\d+),(\d+),'(\{.*?\})'"

for match in re.finditer(tuple_pattern, content):
    total_records += 1
    customization_id = match.group(1)
    dish_id = match.group(2)
    dish_info_str = match.group(3)
    
    # Check if this record has show_on
    if 'show_on' not in dish_info_str:
        continue
        
    try:
        # Parse the JSON (unescape quotes)
        dish_info_str = dish_info_str.replace('\\"', '"')
        dish_info = json.loads(dish_info_str)
        show_on = dish_info.get('show_on', {})
        
        # Find missing days
        present_days = set(show_on.keys())
        missing_days = all_days - present_days
        
        if missing_days:
            restricted_dishes.append({
                'dish_id': int(dish_id),
                'missing_days': sorted(missing_days),
                'present_days': sorted(present_days)
            })
    except json.JSONDecodeError as e:
        print(f"JSON error for dish {dish_id}: {e}")

# Deduplicate - keep unique dish_id with their restrictions
unique_dishes = {}
for dish in restricted_dishes:
    dish_id = dish['dish_id']
    missing = tuple(dish['missing_days'])
    if dish_id not in unique_dishes:
        unique_dishes[dish_id] = set()
    unique_dishes[dish_id].add(missing)

print(f"Total records parsed: {total_records}")
print(f"Unique dishes with day restrictions: {len(unique_dishes)}")
print()

# Group by missing days pattern
patterns = {}
for dish_id, missing_sets in sorted(unique_dishes.items()):
    for missing in missing_sets:
        key = missing
        if key not in patterns:
            patterns[key] = []
        patterns[key].append(dish_id)

print("=" * 70)
print("GROUPED BY RESTRICTION PATTERN")
print("=" * 70)
for missing_days, dish_ids in sorted(patterns.items(), key=lambda x: len(x[1]), reverse=True):
    days_str = ", ".join(missing_days)
    print(f"\nHidden on: {days_str}")
    print(f"  Count: {len(dish_ids)} dishes")
    print(f"  V2 Dish IDs: {dish_ids[:10]}{'...' if len(dish_ids) > 10 else ''}")

print()
print("=" * 70)
print("FULL LIST OF RESTRICTED DISHES")
print("=" * 70)
print("V2 Dish ID | Missing Days (hidden on)")
print("-" * 60)
for dish_id in sorted(unique_dishes.keys()):
    for missing in unique_dishes[dish_id]:
        days_str = ", ".join(missing)
        print(f"{dish_id:>10} | {days_str}")

# Now compare with V3
print()
print("=" * 70)
print("COMPARING WITH V3 DATABASE")
print("=" * 70)

import subprocess
import tempfile
import os
from config import DB_CONNECTION_STRING, PSQL_PATH

# Get all V2 dish IDs that have restrictions
v2_dish_ids = list(unique_dishes.keys())

# Query V3 to find matching dishes by source_id
sql = f"""
SELECT 
    d.id as v3_dish_id,
    d.source_id as v2_dish_id,
    d.name as dish_name,
    r.name as restaurant_name,
    r.id as restaurant_id,
    EXISTS(SELECT 1 FROM menuca_v3.dish_availability da WHERE da.dish_id = d.id) as has_availability
FROM menuca_v3.dishes d
JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id
WHERE d.source_id IN ({','.join(str(x) for x in v2_dish_ids)})
ORDER BY d.source_id;
"""

with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
    f.write(sql)
    sql_file = f.name

env = os.environ.copy()
env['PGCLIENTENCODING'] = 'UTF8'
result = subprocess.run(
    [PSQL_PATH, DB_CONNECTION_STRING, '-f', sql_file, '-t', '-A', '-F', '|'],
    capture_output=True, text=True, encoding='utf-8', errors='replace', env=env
)

# Parse results
v3_matches = []
for line in result.stdout.strip().split('\n'):
    if line and '|' in line:
        parts = line.split('|')
        if len(parts) >= 6:
            v3_matches.append({
                'v3_dish_id': int(parts[0]),
                'v2_dish_id': int(parts[1]),
                'dish_name': parts[2],
                'restaurant_name': parts[3],
                'restaurant_id': int(parts[4]),
                'has_availability': parts[5] == 't'
            })

print(f"\nV2 dishes with restrictions: {len(unique_dishes)}")
print(f"V2 dishes found in V3: {len(v3_matches)}")
print(f"V2 dishes NOT in V3: {len(unique_dishes) - len(set(m['v2_dish_id'] for m in v3_matches))}")

# Check migration status
migrated = [m for m in v3_matches if m['has_availability']]
not_migrated = [m for m in v3_matches if not m['has_availability']]

print(f"\nV3 dishes WITH availability records: {len(migrated)}")
print(f"V3 dishes WITHOUT availability records: {len(not_migrated)}")

if not_migrated:
    print()
    print("=" * 70)
    print("DISHES IN V3 BUT NOT MIGRATED (missing availability records)")
    print("=" * 70)
    for m in not_migrated:
        v2_id = m['v2_dish_id']
        missing_days = list(unique_dishes[v2_id])[0] if v2_id in unique_dishes else []
        days_str = ", ".join(missing_days) if missing_days else "?"
        print(f"V2: {m['v2_dish_id']:>6} | V3: {m['v3_dish_id']:>6} | {m['restaurant_name'][:25]:<25} | {m['dish_name'][:30]:<30} | Hidden: {days_str}")

# Check which V2 dishes don't exist in V3
v3_v2_ids = set(m['v2_dish_id'] for m in v3_matches)
missing_from_v3 = [dish_id for dish_id in unique_dishes.keys() if dish_id not in v3_v2_ids]

if missing_from_v3:
    print()
    print("=" * 70)
    print(f"V2 DISHES NOT FOUND IN V3 ({len(missing_from_v3)} dishes)")
    print("=" * 70)
    print("These V2 dishes have restrictions but don't exist in V3:")
    for dish_id in sorted(missing_from_v3):
        print(f"  V2 Dish ID: {dish_id}")

os.unlink(sql_file)

