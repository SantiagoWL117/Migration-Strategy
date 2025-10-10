#!/usr/bin/env python3
"""
Direct MySQL export of V1 ingredient_groups to CSV (bypassing SQL dump parsing).

Connects to MySQL and exports non-BLOB columns directly to CSV.
BLOB columns (item, price) are already deserialized in Phase 4.3.

Output: menuca_v1_ingredient_groups.csv (13,252 records expected)
"""

import pymysql
import csv
from pathlib import Path

# MySQL connection settings
MYSQL_HOST = "localhost"
MYSQL_USER = "root"
MYSQL_PASSWORD = "root"  # UPDATE THIS IF DIFFERENT
MYSQL_DATABASE = "menuca_v1"
MYSQL_PORT = 3306

# Output CSV
OUTPUT_CSV = Path("Database/Menu & Catalog Entity/CSV/menuca_v1_ingredient_groups.csv")

# CSV headers (non-BLOB columns only)
HEADERS = ['id', 'name', 'type', 'course', 'dish', 'restaurant', 'lang', 'useInCombo', 'isGlobal']

def main():
    print("=" * 70)
    print("V1 ingredient_groups Direct MySQL Export")
    print("=" * 70)
    print(f"Database: {MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}")
    print(f"Output: {OUTPUT_CSV}")
    print()
    
    # Connect to MySQL
    print("Connecting to MySQL...")
    try:
        connection = pymysql.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DATABASE,
            port=MYSQL_PORT,
            charset='utf8mb4'
        )
        print("Connected successfully!")
    except Exception as e:
        print(f"ERROR: Could not connect to MySQL: {e}")
        return
    
    try:
        cursor = connection.cursor()
        
        # Query non-BLOB columns
        print()
        print("Executing query...")
        cursor.execute("""
            SELECT id, name, type, course, dish, restaurant, lang, useInCombo, isGlobal
            FROM ingredient_groups
            ORDER BY id
        """)
        
        # Fetch all rows
        print("Fetching rows...")
        rows = cursor.fetchall()
        print(f"Fetched {len(rows)} rows from MySQL")
        
        # Prepare CSV data
        print()
        print("Preparing CSV data...")
        csv_records = []
        for row in rows:
            record = {
                'id': row[0],
                'name': row[1] if row[1] else None,
                'type': row[2] if row[2] else None,
                'course': row[3] if row[3] is not None else 0,
                'dish': row[4] if row[4] is not None else 0,
                'restaurant': row[5],
                'lang': row[6] if row[6] else None,
                'useInCombo': row[7] if row[7] else None,
                'isGlobal': row[8] if row[8] else None
            }
            csv_records.append(record)
        
        # Write to CSV
        print(f"Writing to {OUTPUT_CSV}...")
        OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)
        
        with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=HEADERS)
            writer.writeheader()
            writer.writerows(csv_records)
        
        print(f"SUCCESS! CSV created with {len(csv_records)} records")
        
        # Summary
        print()
        print("=" * 70)
        print("SUMMARY")
        print("=" * 70)
        print(f"Total records exported: {len(csv_records)}")
        print(f"Expected: 13,252")
        print(f"Match: {'YES (within range)' if len(csv_records) >= 13250 else 'NO - CHECK DATA'}")
        print()
        print("Next Steps:")
        print("1. Upload CSV to Supabase: staging.menuca_v1_ingredient_groups")
        print("2. Verify row count matches")
        print("3. Resume Phase 5")
        print("=" * 70)
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        cursor.close()
        connection.close()
        print()
        print("MySQL connection closed.")

if __name__ == "__main__":
    main()


