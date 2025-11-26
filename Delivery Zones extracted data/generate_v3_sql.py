#!/usr/bin/env python3
"""
Generate V3-ready SQL UPDATE statements for non-BLOB data
Based on V1_DELIVERY_ZONES_COLUMN_MAPPING.md
"""

import csv

print("Generating V3-ready SQL statements for MVP restaurants...")
print("="*60)

# Read the extracted data
with open('extracted_data/phase1_mvp/mvp_extracted_data.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    restaurants = list(reader)

print(f"\nProcessing {len(restaurants)} MVP restaurants\n")

# Generate SQL for restaurant_service_configs
service_config_sql = []
service_config_sql.append("-- Update restaurant_service_configs for MVP restaurants")
service_config_sql.append("-- Based on V1 data extraction from restaurants_dump.sql")
service_config_sql.append("")

for resto in restaurants:
    v3_id = resto['v3_id']
    v1_id = resto['v1_id']
    name = resto['restaurant_name']
    
    # Convert V1 values to V3 format
    # delivery_enabled: '1'/'0' -> boolean true/false
    has_delivery = resto['delivery_enabled'] == '1'
    
    # min_order: string dollar amount -> numeric
    try:
        min_order = float(resto['min_order']) if resto['min_order'] and resto['min_order'] != 'NULL' else 0
    except ValueError:
        min_order = 0
    
    # delivery_time: string minutes -> integer
    try:
        delivery_time = int(resto['delivery_time']) if resto['delivery_time'] and resto['delivery_time'] != 'NULL' else 0
    except ValueError:
        delivery_time = 0
    
    service_config_sql.append(f"-- {name} (V1 ID: {v1_id})")
    service_config_sql.append(
        f"UPDATE menuca_v3.restaurant_service_configs "
        f"SET "
        f"has_delivery_enabled = {str(has_delivery).lower()}, "
        f"delivery_min_order = {min_order}, "
        f"delivery_time_minutes = {delivery_time} "
        f"WHERE restaurant_id = {v3_id};"
    )
    service_config_sql.append("")

# Generate SQL for restaurant_delivery_config
delivery_config_sql = []
delivery_config_sql.append("-- Update restaurant_delivery_config for MVP restaurants")
delivery_config_sql.append("-- Based on V1 data extraction from restaurants_dump.sql")
delivery_config_sql.append("")

for resto in restaurants:
    v3_id = resto['v3_id']
    v1_id = resto['v1_id']
    name = resto['restaurant_name']
    
    # multipleDeliveryArea: 'Y'/'N' -> boolean
    use_multiple_areas = resto['multipleDeliveryArea'] == 'Y'
    
    # use_delivery_areas: 'y'/'n'/'' -> determine delivery_method
    # If use_delivery_areas is 'y', method is 'areas', otherwise 'distance'
    use_areas = resto['use_delivery_areas'].lower() if resto['use_delivery_areas'] and resto['use_delivery_areas'] != 'NULL' else ''
    delivery_method = 'areas' if use_areas == 'y' else 'distance'
    
    delivery_config_sql.append(f"-- {name} (V1 ID: {v1_id})")
    
    # Check if record exists, if not INSERT, else UPDATE
    delivery_config_sql.append(
        f"INSERT INTO menuca_v3.restaurant_delivery_config "
        f"(restaurant_id, use_multiple_areas, delivery_method) "
        f"VALUES ({v3_id}, {str(use_multiple_areas).lower()}, '{delivery_method}') "
        f"ON CONFLICT (restaurant_id) DO UPDATE SET "
        f"use_multiple_areas = {str(use_multiple_areas).lower()}, "
        f"delivery_method = '{delivery_method}';"
    )
    delivery_config_sql.append("")

# Save SQL files
service_config_file = 'extracted_data/phase1_mvp/01_update_service_configs.sql'
with open(service_config_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(service_config_sql))

delivery_config_file = 'extracted_data/phase1_mvp/02_upsert_delivery_config.sql'
with open(delivery_config_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(delivery_config_sql))

print("[OK] Generated SQL files:")
print(f"  1. {service_config_file}")
print(f"     - Updates restaurant_service_configs table")
print(f"     - Sets: has_delivery_enabled, delivery_min_order, delivery_time_minutes")
print()
print(f"  2. {delivery_config_file}")
print(f"     - Inserts/Updates restaurant_delivery_config table")
print(f"     - Sets: use_multiple_areas, delivery_method")
print()
print("="*60)
print("[OK] Step 3 complete: V3-ready SQL generated for non-BLOB data")
print()
print("These SQL files can be executed directly in Supabase, psql, or Supabase CLI")
print("Example: psql -h <host> -U <user> -d menuca_v3 -f 01_update_service_configs.sql")
print()

