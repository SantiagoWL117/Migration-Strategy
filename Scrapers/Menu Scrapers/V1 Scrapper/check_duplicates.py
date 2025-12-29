"""Check duplicate modifiers"""
import psycopg2

conn = psycopg2.connect('postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
cur = conn.cursor()

print('=' * 60)
print('DUPLICATE MODIFIER ANALYSIS')
print('=' * 60)

# Kiki Lebanese - Pizza toppings group
cur.execute("""
    SELECT COUNT(*) FROM menuca_v3.modifiers m
    JOIN menuca_v3.modifier_groups mg ON mg.id = m.modifier_group_id
    WHERE mg.restaurant_id = 44 AND mg.name = 'Pizza toppings'
""")
count = cur.fetchone()[0]
print(f'\nKiki Lebanese - Pizza toppings:')
print(f'  Modifiers stored in DB: {count}')
print(f'  Modifiers found in HTML: 114 (from log)')
print(f'  Duplicates skipped: {114 - count}')

# Overall summary
cur.execute('SELECT COUNT(DISTINCT restaurant_id) FROM menuca_v3.modifier_groups')
restaurants = cur.fetchone()[0]
cur.execute('SELECT COUNT(*) FROM menuca_v3.modifier_groups')
groups = cur.fetchone()[0]
cur.execute('SELECT COUNT(*) FROM menuca_v3.modifiers')
modifiers = cur.fetchone()[0]
cur.execute('SELECT COUNT(*) FROM menuca_v3.modifier_prices')
prices = cur.fetchone()[0]

print(f'\nOVERALL TOTALS:')
print(f'  Restaurants: {restaurants}')
print(f'  Modifier Groups: {groups}')
print(f'  Modifiers: {modifiers}')
print(f'  Modifier Prices: {prices}')

# is_active distribution
cur.execute("""
    SELECT is_active, COUNT(*) 
    FROM menuca_v3.modifiers 
    GROUP BY is_active
    ORDER BY is_active DESC
""")
print(f'\nis_active distribution:')
for row in cur.fetchall():
    status = 'CHECKED' if row[0] else 'unchecked'
    print(f'  {status}: {row[1]} modifiers')

conn.close()

