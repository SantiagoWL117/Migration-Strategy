#!/usr/bin/env python3
"""Load v1_courses directly from MySQL dump"""
import os, sys, re, psycopg2

CONNECTION_STRING = "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:Gz35CPTom1RnsmGM@aws-1-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"

print("🔌 Connecting...")
conn = psycopg2.connect(CONNECTION_STRING)
conn.autocommit = False

print("📖 Reading dump file...")
with open('dumps/menuca_v1_courses.sql', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Extract INSERT statement (stop at semicolon before UNLOCK)
match = re.search(r'INSERT INTO `courses` VALUES (.+?);(?:\s*UNLOCK|\s*$)', content, re.DOTALL)
if not match:
    print("❌ No INSERT found")
    sys.exit(1)

values_str = match.group(1).strip()

print("🔄 Converting to PostgreSQL format...")
# Fix escapes
values_str = values_str.replace("\\'", "''").replace('\\"', '""')

# Build INSERT with correct column mapping from MySQL (unlisted → xth_promo, fee → xth_item, percent → remove_value, image → remove_from, combo → time_period, combodetail → ci_header, restaurant → restaurant_id)
sql = f"INSERT INTO staging.v1_courses (id, name, description, xth_promo, xth_item, remove_value, remove_from, time_period, ci_header, restaurant_id, language, display_order) VALUES {values_str}"

print("📥 Loading data...")
cursor = conn.cursor()
try:
    cursor.execute(sql)
    conn.commit()
    print(f"✅ Loaded {cursor.rowcount:,} rows!")
except Exception as e:
    print(f"❌ Error: {e}")
    conn.rollback()
finally:
    cursor.close()
    conn.close()

