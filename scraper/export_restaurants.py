#!/usr/bin/env python3
"""
Export all active restaurants with CRM IDs for batch scraping.
"""

import psycopg2
import json
import csv
from config import DB_CONNECTION_STRING, SCHEMA

def export_restaurants():
    """Export all active restaurants to CSV and JSON."""

    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = conn.cursor()

    # Query all active restaurants
    query = f"""
        SELECT
            id,
            name,
            legacy_v1_id,
            legacy_v2_id,
            status,
            slug
        FROM {SCHEMA}.restaurants
        WHERE deleted_at IS NULL
        ORDER BY name
    """

    cursor.execute(query)
    restaurants = cursor.fetchall()

    print(f"Found {len(restaurants)} active restaurants")

    # Export to CSV
    csv_file = "c:\\Users\\santi\\Menu.ca\\Legacy Database\\Migration Strategy\\scraper\\restaurants_list.csv"
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['db_id', 'name', 'crm_id', 'legacy_v2_id', 'status', 'slug'])

        for row in restaurants:
            writer.writerow(row)

    print(f"Exported to CSV: {csv_file}")

    # Export to JSON
    json_file = "c:\\Users\\santi\\Menu.ca\\Legacy Database\\Migration Strategy\\scraper\\restaurants_list.json"
    restaurants_json = []

    for row in restaurants:
        restaurants_json.append({
            'db_id': row[0],
            'name': row[1],
            'crm_id': row[2],
            'legacy_v2_id': row[3],
            'status': row[4],
            'slug': row[5]
        })

    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(restaurants_json, f, indent=2, ensure_ascii=False)

    print(f"Exported to JSON: {json_file}")

    # Count restaurants with CRM IDs
    with_crm = sum(1 for r in restaurants if r[2] is not None)
    without_crm = len(restaurants) - with_crm

    print(f"\nSummary:")
    print(f"  Total restaurants: {len(restaurants)}")
    print(f"  With CRM ID (legacy_v1_id): {with_crm}")
    print(f"  Without CRM ID: {without_crm}")

    if without_crm > 0:
        print(f"\nRestaurants WITHOUT CRM ID:")
        for row in restaurants:
            if row[2] is None:
                print(f"  - {row[1]} (DB ID: {row[0]})")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    export_restaurants()
