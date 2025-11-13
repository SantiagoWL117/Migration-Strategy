#!/usr/bin/env python3
"""Quick verification of cleanup status."""

import psycopg2
from config import DB_CONNECTION_STRING, SCHEMA

conn = psycopg2.connect(DB_CONNECTION_STRING)
cursor = conn.cursor()

print("=" * 60)
print("Cleanup Verification")
print("=" * 60)

# Check row counts
tables = ['courses', 'dishes', 'dish_prices', 'modifier_groups']
print("\nRow counts in core tables:")
for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {SCHEMA}.{table}")
    count = cursor.fetchone()[0]
    status = "[OK] EMPTY" if count == 0 else f"[!] HAS {count} ROWS"
    print(f"  {table}: {status}")

# Check if dropped tables exist
print("\nChecking dropped tables:")
dropped_tables = [
    'dish_modifier_groups', 'dish_modifier_items',
    'ingredients', 'ingredient_groups', 'ingredient_group_items',
    'dish_ingredients', 'combo_groups', 'combo_items'
]

for table in dropped_tables:
    cursor.execute(f"""
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = '{SCHEMA}'
            AND table_name = '{table}'
        )
    """)
    exists = cursor.fetchone()[0]
    status = "[!] STILL EXISTS" if exists else "[OK] DROPPED"
    print(f"  {table}: {status}")

cursor.close()
conn.close()

print("\n" + "=" * 60)
print("Verification Complete!")
print("=" * 60)
