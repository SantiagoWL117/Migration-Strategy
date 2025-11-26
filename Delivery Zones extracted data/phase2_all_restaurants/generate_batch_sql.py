#!/usr/bin/env python3
"""
Generate SQL for a specific batch
Usage: python generate_batch_sql.py batch_1_30
"""

import json
import sys

if len(sys.argv) < 2:
    print("Usage: python generate_batch_sql.py <batch_name>")
    sys.exit(1)

batch_name = sys.argv[1]

print(f"Generating SQL for {batch_name}...")
print("="*60)

# Load deserialized data
with open(f'{batch_name}_deserialized_schedules.json', 'r', encoding='utf-8') as f:
    schedules = json.load(f)

with open(f'{batch_name}_deserialized_areas.json', 'r', encoding='utf-8') as f:
    areas = json.load(f)

with open(f'{batch_name}_deserialized_fees.json', 'r', encoding='utf-8') as f:
    fees = json.load(f)

# Generate schedules SQL
with open(f'{batch_name}_schedules.sql', 'w', encoding='utf-8') as f:
    f.write(f"-- Insert delivery schedules for {batch_name}\n")
    f.write(f"-- WARNING: This will DELETE existing delivery schedules and replace with V1 data\n\n")
    
    # Get unique restaurant IDs in this batch
    restaurant_ids = set(data['v3_id'] for data in schedules.values() if data['schedule_entries'])
    
    # First, delete existing delivery schedules for these restaurants
    if restaurant_ids:
        ids_str = ','.join(map(str, restaurant_ids))
        f.write(f"-- Delete existing delivery schedules for batch restaurants\n")
        f.write(f"DELETE FROM menuca_v3.restaurant_schedules WHERE restaurant_id IN ({ids_str}) AND type = 'delivery';\n\n")
    
    # Then insert new schedules
    for v1_id, data in schedules.items():
        if data['schedule_entries']:
            f.write(f"-- {data['restaurant_name']} (V1: {v1_id}, V3: {data['v3_id']})\n")
            for entry in data['schedule_entries']:
                f.write(
                    f"INSERT INTO menuca_v3.restaurant_schedules "
                    f"(restaurant_id, type, day_start, day_stop, time_start, time_stop) "
                    f"VALUES ({entry['restaurant_id']}, '{entry['type']}', {entry['day_start']}, {entry['day_stop']}, '{entry['time_start']}', '{entry['time_stop']}');\n"
                )
            f.write("\n")

# Generate areas SQL
with open(f'{batch_name}_areas.sql', 'w', encoding='utf-8') as f:
    f.write(f"-- Insert delivery areas for {batch_name}\n\n")
    for v1_id, data in areas.items():
        if data['area_entries']:
            f.write(f"-- {data['restaurant_name']} (V1: {v1_id}, V3: {data['v3_id']})\n")
            for entry in data['area_entries']:
                f.write(
                    f"INSERT INTO menuca_v3.restaurant_delivery_areas "
                    f"(restaurant_id, area_number, area_name, geometry) "
                    f"VALUES ({entry['restaurant_id']}, {entry['area_number']}, '{entry['area_name']}', ST_GeomFromText('{entry['polygon_wkt']}', 4326)) "
                    f"ON CONFLICT (restaurant_id, area_number) DO UPDATE SET geometry = ST_GeomFromText('{entry['polygon_wkt']}', 4326);\n"
                )
            f.write("\n")

# Generate fees SQL
with open(f'{batch_name}_fees.sql', 'w', encoding='utf-8') as f:
    f.write(f"-- Insert delivery fees for {batch_name}\n\n")
    for v1_id, data in fees.items():
        if data['fee_entries']:
            f.write(f"-- {data['restaurant_name']} (V1: {v1_id}, V3: {data['v3_id']})\n")
            for entry in data['fee_entries']:
                tier_value = entry['fee_tier'] if entry['fee_tier'] > 0 else 1
                f.write(
                    f"INSERT INTO menuca_v3.restaurant_delivery_fees "
                    f"(restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) "
                    f"VALUES ({entry['restaurant_id']}, 'distance', {tier_value}, {entry['fee_value']}, NULL) "
                    f"ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) DO UPDATE SET total_delivery_fee = {entry['fee_value']};\n"
                )
            f.write("\n")

print(f"\n[OK] Generated SQL files:")
print(f"  - {batch_name}_schedules.sql")
print(f"  - {batch_name}_areas.sql")
print(f"  - {batch_name}_fees.sql")

