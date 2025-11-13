#!/usr/bin/env python3
"""Check the actual schema of restaurants table."""
from database import DatabaseManager
from config import SCHEMA

db = DatabaseManager()
db.connect()

query = f"""
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_schema = '{SCHEMA}'
      AND table_name = 'restaurants'
    ORDER BY ordinal_position
"""

db.cursor.execute(query)
columns = db.cursor.fetchall()

print("=" * 100)
print("RESTAURANTS TABLE SCHEMA")
print("=" * 100)

for col in columns:
    print(f"{col['column_name']:30} | {col['data_type']:20} | Nullable: {col['is_nullable']:3} | Default: {col['column_default']}")

db.close()



