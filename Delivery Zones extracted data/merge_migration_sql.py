from datetime import datetime

print("\n" + "="*80)
print("STEP 6: MERGE V2 AND V1 SQL INTO FINAL MIGRATION FILE")
print("="*80)

# Read V2 SQL
print("\n[1/4] Reading V2 SQL file...")
with open('extracted_data/v2_to_v3_delivery_areas.sql', 'r', encoding='utf-8') as f:
    v2_sql = f.read()

# Extract just the INSERT statements (skip header comments)
v2_inserts = v2_sql[v2_sql.find('-- Restaurant:'):]  # Start from first restaurant comment
print(f"   V2 SQL loaded (88 delivery areas)")

# Read V1 SQL
print("\n[2/4] Reading V1 SQL file...")
with open('extracted_data/v1_to_v3_delivery_areas.sql', 'r', encoding='utf-8') as f:
    v1_sql = f.read()

# Extract just the INSERT statements
v1_inserts = v1_sql[v1_sql.find('-- Restaurant:'):]
print(f"   V1 SQL loaded (3 delivery areas)")

# Collect all V3 IDs that will be migrated
print("\n[3/4] Collecting restaurant IDs for migration...")

import re

v3_ids = set()

# Extract V3 IDs from V2 SQL
v2_id_matches = re.findall(r'VALUES\s*\((\d+),', v2_inserts)
v3_ids.update(v2_id_matches)

# Extract V3 IDs from V1 SQL
v1_id_matches = re.findall(r'VALUES\s*\((\d+),', v1_inserts)
v3_ids.update(v1_id_matches)

v3_ids_list = sorted([int(id) for id in v3_ids])
print(f"   Total unique restaurants: {len(v3_ids_list)}")

# Generate final migration file
print("\n[4/4] Generating final migration file...")

with open('extracted_data/FINAL_DELIVERY_AREAS_MIGRATION.sql', 'w', encoding='utf-8') as f:
    f.write("-- ============================================================================\n")
    f.write("-- Delivery Areas Migration: V2 + V1 to V3\n")
    f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write("-- ============================================================================\n")
    f.write("--\n")
    f.write("-- OVERVIEW:\n")
    f.write("--   This migration consolidates delivery area polygon data from two sources:\n")
    f.write("--   1. V2 Export (79 restaurants, 88 delivery areas) - PRIMARY SOURCE\n")
    f.write("--   2. V1 Polygons (3 restaurants, 3 delivery areas) - FALLBACK SOURCE\n")
    f.write("--\n")
    f.write("-- TARGET TABLE:\n")
    f.write("--   menuca_v3.restaurant_delivery_areas\n")
    f.write("--\n")
    f.write("-- MIGRATION STATS:\n")
    f.write(f"--   - Total Restaurants: {len(v3_ids_list)}\n")
    f.write("--   - Total Delivery Areas: 91 (88 from V2 + 3 from V1)\n")
    f.write("--   - V2 Restaurants: 79 (with coordinate data)\n")
    f.write("--   - V1 Restaurants: 3 (no V2 data available)\n")
    f.write("--\n")
    f.write("-- EXCLUDED:\n")
    f.write("--   - 5 MVP restaurants (already migrated in Phase 1)\n")
    f.write("--\n")
    f.write("-- TRANSACTION:\n")
    f.write("--   This script runs in a transaction. If any error occurs, all changes\n")
    f.write("--   will be rolled back automatically.\n")
    f.write("--\n")
    f.write("-- ============================================================================\n\n")
    
    f.write("BEGIN;\n\n")
    
    f.write("-- ============================================================================\n")
    f.write("-- PHASE 1: V2 COORDINATE DATA (PRIORITY)\n")
    f.write("-- ============================================================================\n")
    f.write("-- Source: V2 restaurants_delivery_areas dump\n")
    f.write("-- Restaurants: 79\n")
    f.write("-- Delivery Areas: 88\n")
    f.write("-- Format: Pipe-delimited lat/lng coordinates converted to PostGIS polygons\n")
    f.write("-- ============================================================================\n\n")
    
    f.write(v2_inserts)
    
    f.write("\n\n")
    f.write("-- ============================================================================\n")
    f.write("-- PHASE 2: V1 POLYGON DATA (FALLBACK)\n")
    f.write("-- ============================================================================\n")
    f.write("-- Source: V1 deliveryArea BLOB (deserialized)\n")
    f.write("-- Restaurants: 3\n")
    f.write("-- Delivery Areas: 3\n")
    f.write("-- Note: These restaurants have V1 polygons but NO V2 coordinate data\n")
    f.write("-- ============================================================================\n\n")
    
    f.write(v1_inserts)
    
    f.write("\n\n")
    f.write("COMMIT;\n\n")
    
    f.write("-- ============================================================================\n")
    f.write("-- MIGRATION COMPLETE\n")
    f.write("-- ============================================================================\n")
    f.write(f"-- Total areas inserted: 91\n")
    f.write(f"-- Unique restaurants: {len(v3_ids_list)}\n")
    f.write("--\n")
    f.write("-- Next steps:\n")
    f.write("--   1. Run pre-migration checks: extracted_data/pre_migration_checks.sql\n")
    f.write("--   2. Execute this migration file\n")
    f.write("--   3. Run post-migration checks: extracted_data/post_migration_checks.sql\n")
    f.write("-- ============================================================================\n")

print(f"   Final migration file generated: extracted_data/FINAL_DELIVERY_AREAS_MIGRATION.sql")
print(f"   Total restaurants: {len(v3_ids_list)}")
print(f"   Total delivery areas: 91")

print("\n" + "="*80)
print("[COMPLETE] STEP 6 COMPLETE - Proceeding to Step 7")
print("="*80 + "\n")


