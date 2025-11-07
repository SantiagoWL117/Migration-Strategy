#!/usr/bin/env python3
"""
Analyze Source Data Availability for Audited Restaurants

Purpose: Determine which restaurants have V1/V2 source data available in staging
vs. which need to be scraped from live menu URLs.

Output: CSV file with restaurant ID, name, source data availability, and recommendation
"""

import csv
import re
from pathlib import Path

# Read the audit progress file
audit_file = Path("reports/database/Course-Fix-Progress.md")

# Extract restaurant IDs and names from audit file
restaurants = []

with open(audit_file, 'r', encoding='utf-8') as f:
    content = f.read()
    
    # Find all restaurant entries
    pattern = r'#### (.+?) \(Restaurant ID: (\d+)\)'
    matches = re.findall(pattern, content)
    
    for name, restaurant_id in matches:
        restaurants.append({
            'restaurant_id': int(restaurant_id),
            'name': name.strip(),
            'has_source_data': None,  # Will be checked via SQL
            'recommendation': None
        })

print(f"Found {len(restaurants)} restaurants in audit file")

# Output SQL query to check source data availability
sql_query = """
-- Check which audited restaurants have V1/V2 source data
WITH audited_restaurants AS (
    SELECT DISTINCT restaurant_id
    FROM (VALUES 
        -- Add restaurant IDs from audit
        {}
    ) AS t(restaurant_id)
),
v1_data AS (
    SELECT DISTINCT CAST(restaurant AS INTEGER) as v1_restaurant_id
    FROM staging.menuca_v1_menu
),
v2_data AS (
    SELECT DISTINCT restaurant_id as v2_restaurant_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
),
mapping AS (
    SELECT 
        arm.new_restaurant_id as v3_restaurant_id,
        arm.old_restaurant_id as v1_restaurant_id,
        'v1' as source
    FROM archive.restaurant_id_mapping arm
    WHERE arm.old_restaurant_id IS NOT NULL
    UNION ALL
    SELECT 
        r.id as v3_restaurant_id,
        r.legacy_v2_id as v2_restaurant_id,
        'v2' as source
    FROM menuca_v3.restaurants r
    WHERE r.legacy_v2_id IS NOT NULL
)
SELECT 
    ar.restaurant_id,
    r.name,
    CASE 
        WHEN m.source = 'v1' AND v1.v1_restaurant_id IS NOT NULL THEN 'v1'
        WHEN m.source = 'v2' AND v2.v2_restaurant_id IS NOT NULL THEN 'v2'
        ELSE 'none'
    END as source_data_available,
    CASE 
        WHEN m.source = 'v1' AND v1.v1_restaurant_id IS NOT NULL THEN 'Re-import from staging.menuca_v1_menu'
        WHEN m.source = 'v2' AND v2.v2_restaurant_id IS NOT NULL THEN 'Re-import from V2 (check staging)'
        ELSE 'Scrape from live menu URL'
    END as recommendation
FROM audited_restaurants ar
LEFT JOIN menuca_v3.restaurants r ON ar.restaurant_id = r.id
LEFT JOIN mapping m ON ar.restaurant_id = m.v3_restaurant_id
LEFT JOIN v1_data v1 ON m.v1_restaurant_id = v1.v1_restaurant_id AND m.source = 'v1'
LEFT JOIN v2_data v2 ON m.v2_restaurant_id = v2.v2_restaurant_id AND m.source = 'v2'
ORDER BY ar.restaurant_id;
"""

# Generate VALUES clause for restaurant IDs
restaurant_ids = [str(r['restaurant_id']) for r in restaurants]
values_clause = ',\n        '.join([f"({id})" for id in restaurant_ids])
final_query = sql_query.format(values_clause)

# Write SQL query to file
output_file = Path("scripts/check-source-data-availability.sql")
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(final_query)

print(f"\n✅ Generated SQL query: {output_file}")
print(f"\nRun this query in Supabase to check source data availability for {len(restaurants)} restaurants")
print("\nNext steps:")
print("1. Run the SQL query in Supabase")
print("2. Export results to CSV")
print("3. Analyze which restaurants can be re-imported vs. scraped")

