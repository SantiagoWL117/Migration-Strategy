#!/usr/bin/env python3
"""
Generate SQL INSERT statements for BLOB data (schedules, areas, fees)
Reads deserialized JSON files and creates V3-compatible SQL
"""

import json
import os

def generate_schedules_sql():
    """Generate SQL for restaurant_schedules"""
    with open('deserialized_schedules.json', 'r', encoding='utf-8') as f:
        schedules_data = json.load(f)
    
    sql_lines = []
    sql_lines.append("-- Insert delivery schedules for MVP restaurants")
    sql_lines.append("-- Based on V1 delivery_schedule BLOB deserialization")
    sql_lines.append("-- Target table: menuca_v3.restaurant_schedules\n")
    
    for v1_id, restaurant_data in schedules_data.items():
        restaurant_name = restaurant_data['restaurant_name']
        v3_id = restaurant_data['v3_id']
        schedule_entries = restaurant_data['schedule_entries']
        
        if not schedule_entries:
            sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
            sql_lines.append(f"-- No schedule entries found\n")
            continue
        
        sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
        sql_lines.append(f"-- {len(schedule_entries)} schedule entries\n")
        
        for entry in schedule_entries:
            restaurant_id = entry['restaurant_id']
            schedule_type = entry['type']
            day_start = entry['day_start']
            day_stop = entry['day_stop']
            time_start = entry['time_start']
            time_stop = entry['time_stop']
            
            # Generate INSERT with ON CONFLICT to avoid duplicates
            sql_lines.append(
                f"INSERT INTO menuca_v3.restaurant_schedules "
                f"(restaurant_id, type, day_start, day_stop, time_start, time_stop) "
                f"VALUES ({restaurant_id}, '{schedule_type}', {day_start}, {day_stop}, '{time_start}', '{time_stop}') "
                f"ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) "
                f"DO NOTHING;"
            )
        
        sql_lines.append("")  # Empty line between restaurants
    
    return '\n'.join(sql_lines)


def generate_areas_sql():
    """Generate SQL for restaurant_delivery_areas"""
    with open('deserialized_areas.json', 'r', encoding='utf-8') as f:
        areas_data = json.load(f)
    
    sql_lines = []
    sql_lines.append("-- Insert delivery areas for MVP restaurants")
    sql_lines.append("-- Based on V1 deliveryArea BLOB deserialization")
    sql_lines.append("-- Target table: menuca_v3.restaurant_delivery_areas\n")
    
    for v1_id, restaurant_data in areas_data.items():
        restaurant_name = restaurant_data['restaurant_name']
        v3_id = restaurant_data['v3_id']
        area_entries = restaurant_data['area_entries']
        
        if not area_entries:
            sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
            sql_lines.append(f"-- No delivery area entries found\n")
            continue
        
        sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
        sql_lines.append(f"-- {len(area_entries)} delivery area(s)\n")
        
        for entry in area_entries:
            restaurant_id = entry['restaurant_id']
            area_number = entry['area_number']
            area_name = entry['area_name']
            polygon_wkt = entry['polygon_wkt']
            
            # Generate INSERT with PostGIS ST_GeomFromText
            # Use ON CONFLICT to avoid duplicates
            sql_lines.append(
                f"INSERT INTO menuca_v3.restaurant_delivery_areas "
                f"(restaurant_id, area_number, area_name, geometry) "
                f"VALUES ({restaurant_id}, {area_number}, '{area_name}', ST_GeomFromText('{polygon_wkt}', 4326)) "
                f"ON CONFLICT (restaurant_id, area_number) "
                f"DO UPDATE SET area_name = '{area_name}', geometry = ST_GeomFromText('{polygon_wkt}', 4326);"
            )
        
        sql_lines.append("")  # Empty line between restaurants
    
    return '\n'.join(sql_lines)


def generate_fees_sql():
    """Generate SQL for restaurant_delivery_fees"""
    with open('deserialized_fees.json', 'r', encoding='utf-8') as f:
        fees_data = json.load(f)
    
    sql_lines = []
    sql_lines.append("-- Insert delivery fees for MVP restaurants")
    sql_lines.append("-- Based on V1 fee BLOB deserialization")
    sql_lines.append("-- Target table: menuca_v3.restaurant_delivery_fees\n")
    
    for v1_id, restaurant_data in fees_data.items():
        restaurant_name = restaurant_data['restaurant_name']
        v3_id = restaurant_data['v3_id']
        fee_entries = restaurant_data['fee_entries']
        
        if not fee_entries:
            sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
            sql_lines.append(f"-- No fee entries found\n")
            continue
        
        sql_lines.append(f"-- {restaurant_name} (V1 ID: {v1_id}, V3 ID: {v3_id})")
        sql_lines.append(f"-- {len(fee_entries)} fee tier(s)\n")
        
        for entry in fee_entries:
            restaurant_id = entry['restaurant_id']
            fee_tier = entry['fee_tier']
            fee_value = entry['fee_value']
            v1_fee_type = entry['fee_type']
            
            # Determine V3 fee_type based on V1 data
            # If fee_tier is 0, it's a flat fee (distance-based, tier 1)
            # Otherwise, it's distance-based with multiple tiers
            v3_fee_type = 'distance'
            tier_value = fee_tier if fee_tier > 0 else 1  # tier_value must be > 0
            
            # Generate INSERT with ON CONFLICT
            sql_lines.append(
                f"INSERT INTO menuca_v3.restaurant_delivery_fees "
                f"(restaurant_id, fee_type, tier_value, total_delivery_fee, company_email_id) "
                f"VALUES ({restaurant_id}, '{v3_fee_type}', {tier_value}, {fee_value}, NULL) "
                f"ON CONFLICT (restaurant_id, company_email_id, fee_type, tier_value) "
                f"DO UPDATE SET total_delivery_fee = {fee_value};"
            )
        
        sql_lines.append("")  # Empty line between restaurants
    
    return '\n'.join(sql_lines)


def main():
    """Generate all SQL files"""
    print("Generating SQL for BLOB data...")
    
    # Generate schedules SQL
    print("  [1/3] Generating schedules SQL...")
    schedules_sql = generate_schedules_sql()
    with open('03_insert_schedules.sql', 'w', encoding='utf-8') as f:
        f.write(schedules_sql)
    print(f"        -> 03_insert_schedules.sql created ({len(schedules_sql)} bytes)")
    
    # Generate areas SQL
    print("  [2/3] Generating delivery areas SQL...")
    areas_sql = generate_areas_sql()
    with open('04_insert_delivery_areas.sql', 'w', encoding='utf-8') as f:
        f.write(areas_sql)
    print(f"        -> 04_insert_delivery_areas.sql created ({len(areas_sql)} bytes)")
    
    # Generate fees SQL
    print("  [3/3] Generating delivery fees SQL...")
    fees_sql = generate_fees_sql()
    with open('05_insert_delivery_fees.sql', 'w', encoding='utf-8') as f:
        f.write(fees_sql)
    print(f"        -> 05_insert_delivery_fees.sql created ({len(fees_sql)} bytes)")
    
    print("\n=== SQL Generation Complete ===")
    print("\nGenerated files:")
    print("  1. 03_insert_schedules.sql")
    print("  2. 04_insert_delivery_areas.sql")
    print("  3. 05_insert_delivery_fees.sql")
    print("\nThese files are ready to be executed with psql or Supabase SQL Editor.")


if __name__ == '__main__':
    main()

