"""Query Amicci Pizza modifier data from database."""
import psycopg2
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = psycopg2.connect('postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
cur = conn.cursor()

print('=' * 100)
print('AMICCI PIZZA (V3: 735, V1: 973)')
print('=' * 100)

# Get all modifier groups with their modifiers and prices
cur.execute('''
    SELECT 
        mg.name AS group_name,
        mg.id AS group_id,
        mg.category,
        m.name AS modifier_name,
        m.source_id,
        m.is_active,
        mp.price
    FROM menuca_v3.modifier_groups mg
    JOIN menuca_v3.modifiers m ON mg.id = m.modifier_group_id
    LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
    WHERE mg.restaurant_id = 735
    ORDER BY mg.name, m.is_active DESC, m.name
''')

results = cur.fetchall()

current_group = None
active_count = 0
inactive_count = 0

for row in results:
    group_name, group_id, category, mod_name, source_id, is_active, price = row
    
    if group_name != current_group:
        if current_group is not None:
            print(f'  Summary: {active_count} active, {inactive_count} inactive')
            print()
        current_group = group_name
        active_count = 0
        inactive_count = 0
        print('=' * 100)
        print(f'MODIFIER GROUP: {group_name}')
        print(f'  V3 ID: {group_id} | Category: {category}')
        print('-' * 100)
    
    status = '[ACTIVE]  ' if is_active else '[inactive]'
    price_str = f'${price:.2f}' if price is not None else 'N/A'
    print(f'  {status} {mod_name}')
    print(f'             source_id: {source_id} | Price: {price_str}')
    
    if is_active:
        active_count += 1
    else:
        inactive_count += 1

if current_group is not None:
    print(f'  Summary: {active_count} active, {inactive_count} inactive')

# Get totals
cur.execute('''
    SELECT COUNT(DISTINCT mg.id), COUNT(m.id)
    FROM menuca_v3.modifier_groups mg
    LEFT JOIN menuca_v3.modifiers m ON mg.id = m.modifier_group_id
    WHERE mg.restaurant_id = 735
''')
totals = cur.fetchone()
print()
print('=' * 100)
print(f'TOTAL: {totals[0]} modifier groups, {totals[1]} modifiers')
print('=' * 100)

cur.close()
conn.close()






