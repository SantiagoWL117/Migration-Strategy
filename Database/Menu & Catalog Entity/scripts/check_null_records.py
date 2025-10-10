import pymysql

conn = pymysql.connect(
    host='localhost',
    user='root',
    password='root',
    database='menuca_v1',
    charset='utf8mb4'
)

cur = conn.cursor()

# Check specific problematic IDs
cur.execute("""
    SELECT id, name, type, restaurant, lang 
    FROM ingredient_groups 
    WHERE id IN (1854, 1855, 2959, 2960, 4608, 7648, 11558)
    ORDER BY id
""")

print("MySQL Source Data for Problematic IDs:")
print(f"{'ID':<8}| {'name':<20}| {'type':<6}| {'rest':<6}| {'lang':<6}")
print("-" * 60)

for row in cur.fetchall():
    id_val, name, type_val, rest, lang = row
    name_repr = repr(name) if name else "None"
    type_repr = repr(type_val) if type_val else "None"
    lang_repr = repr(lang) if lang else "None"
    print(f"{id_val:<8}| {name_repr:<20}| {type_repr:<6}| {rest:<6}| {lang_repr:<6}")

print()

# Count empty strings vs NULLs
cur.execute("""
    SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN name = '' THEN 1 ELSE 0 END) as empty_name,
        SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) as null_name,
        SUM(CASE WHEN type = '' THEN 1 ELSE 0 END) as empty_type,
        SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) as null_type
    FROM ingredient_groups
""")

stats = cur.fetchone()
print(f"MySQL Statistics:")
print(f"Total records: {stats[0]}")
print(f"Empty string name: {stats[1]}")
print(f"NULL name: {stats[2]}")
print(f"Empty string type: {stats[3]}")
print(f"NULL type: {stats[4]}")

conn.close()


