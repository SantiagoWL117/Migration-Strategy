import psycopg2

conn = psycopg2.connect('postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
cur = conn.cursor()

print("modifier_groups columns:")
cur.execute("SELECT column_name FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND table_name = 'modifier_groups'")
for row in cur.fetchall():
    print(f"  - {row[0]}")

print("\nmodifiers columns:")
cur.execute("SELECT column_name FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND table_name = 'modifiers'")
for row in cur.fetchall():
    print(f"  - {row[0]}")

print("\nmodifier_prices columns:")
cur.execute("SELECT column_name FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND table_name = 'modifier_prices'")
for row in cur.fetchall():
    print(f"  - {row[0]}")

cur.close()
conn.close()

