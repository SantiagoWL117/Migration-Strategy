import psycopg2

conn = psycopg2.connect('postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
cur = conn.cursor()

print("Checking constraints on modifiers table:")
cur.execute("""
    SELECT constraint_name, constraint_type
    FROM information_schema.table_constraints
    WHERE table_schema = 'menuca_v3' AND table_name = 'modifiers'
""")
for row in cur.fetchall():
    print(f"  - {row[0]}: {row[1]}")

print("\nChecking indexes on modifiers table:")
cur.execute("""
    SELECT indexname, indexdef
    FROM pg_indexes
    WHERE schemaname = 'menuca_v3' AND tablename = 'modifiers'
""")
for row in cur.fetchall():
    print(f"  - {row[0]}")

# Count modifiers with null source_id
cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NULL")
null_count = cur.fetchone()[0]
print(f"\nModifiers with NULL source_id: {null_count}")

cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NOT NULL")
not_null_count = cur.fetchone()[0]
print(f"Modifiers with source_id: {not_null_count}")

cur.close()
conn.close()






