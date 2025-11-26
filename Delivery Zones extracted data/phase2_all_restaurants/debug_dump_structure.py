import re

content = open('../../Database/v1_structure/restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore').read()
inserts = re.findall(r'INSERT INTO `restaurants` VALUES \((.*?)\);', content, re.DOTALL)

print(f'Total INSERT statements: {len(inserts)}')
for i, insert in enumerate(inserts):
    # Count records by looking for ),( patterns
    # But need to be careful about ),( inside strings
    record_count = insert.count('),(') + 1  # +1 for the last record
    print(f'INSERT {i+1}: ~{record_count} records (approx), {len(insert)} chars')

total = sum(insert.count('),(') + 1 for insert in inserts)
print(f'\nTotal approximate records: {total}')

