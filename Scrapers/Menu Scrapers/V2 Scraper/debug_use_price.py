"""Debug script to analyze use_price field structure"""
import re
import json
import os

dump_path = os.path.join(os.path.dirname(__file__), 'dumps', 'combo_group_items_dump.sql')

with open(dump_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Find the INSERT statement
insert_match = re.search(r'INSERT INTO.*?VALUES\s*(.*?);', content, re.DOTALL)
values_str = insert_match.group(1)

# Find record for group 261
start_idx = values_str.find('(251,261,')
if start_idx != -1:
    depth = 0
    end_idx = start_idx
    for i, char in enumerate(values_str[start_idx:]):
        if char == '(':
            depth += 1
        elif char == ')':
            depth -= 1
            if depth == 0:
                end_idx = start_idx + i + 1
                break
    
    record = values_str[start_idx:end_idx]
    
    print("Raw record for combo group 261:")
    print("=" * 80)
    print(record)
    print()
    print("=" * 80)
    
    # Find all single-quoted strings (JSON fields) and unescape them
    json_pattern = r"'(\{[^']+\})'"
    json_matches = re.findall(json_pattern, record)
    
    print(f"\nFound {len(json_matches)} JSON fields:")
    print("=" * 80)
    for i, j in enumerate(json_matches):
        print(f"\nJSON Field {i+1}:")
        # Unescape the JSON - replace \" with "
        unescaped = j.replace('\\"', '"')
        try:
            parsed = json.loads(unescaped)
            print(json.dumps(parsed, indent=2))
        except Exception as e:
            print(f"  Parse error: {e}")
            print(f"  Raw: {j[:200]}...")

# Now let's look at all records with non-empty use_price values
print("\n" + "=" * 80)
print("SEARCHING ALL RECORDS FOR use_price WITH TIER VALUES")
print("=" * 80)

# Extract all records
records = []
depth = 0
current_record = ''
for char in values_str:
    if char == '(':
        if depth == 0:
            current_record = ''
        depth += 1
    elif char == ')':
        depth -= 1
        if depth == 0:
            records.append(current_record)
            current_record = ''
    if depth > 0:
        current_record += char

print(f"\nTotal records: {len(records)}")

# Look for pattern like \"571\": \"2\" which indicates a price tier (escaped quotes in SQL dump)
tier_pattern = r'\\"(\d+)\\":\s*\\"([1-4])\\"'
records_with_tiers = []

for record in records:
    record = record.lstrip('(')
    parts = record.split(',', 2)
    if len(parts) < 2:
        continue
    record_id = parts[0].strip()
    group_id = parts[1].strip()
    
    matches = re.findall(tier_pattern, record)
    if matches:
        records_with_tiers.append({
            'record_id': record_id,
            'group_id': group_id,
            'tiers': matches
        })

print(f"\nRecords with price tier values (1-4): {len(records_with_tiers)}")
for r in records_with_tiers:
    print(f"\n  Record {r['record_id']}, Combo Group {r['group_id']}:")
    for mg_id, tier in r['tiers']:
        print(f"    Modifier Group {mg_id} -> Tier {tier}")

