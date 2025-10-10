#!/usr/bin/env python3
"""
Phase 4.4 Alternative: Direct MySQL to CSV export (skipping SQL dump)
Exports combo_groups directly from MySQL to CSV with hex BLOBs
"""
import pymysql
import binascii
import csv
import sys

# MySQL Connection Config
MYSQL_HOST = "localhost"
MYSQL_USER = "root"
MYSQL_PASSWORD = "root"
MYSQL_DB = "menuca_v1"

OUTPUT_CSV = r"Database\Menu & Catalog Entity\CSV\menuca_v1_combo_groups_hex.csv"

def main():
    print("=" * 70)
    print("Phase 4.4 Step 1+2 Combined: Direct MySQL to CSV export")
    print("=" * 70)
    print()
    
    try:
        # Connect to MySQL
        print(f"Connecting to MySQL: {MYSQL_HOST}/{MYSQL_DB}")
        connection = pymysql.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DB
        )
        cursor = connection.cursor()
        
        # Get row count
        cursor.execute("SELECT COUNT(*) FROM combo_groups")
        total_rows = cursor.fetchone()[0]
        print(f"Total rows in combo_groups: {total_rows:,}")
        print()
        
        # Export directly to CSV
        print("Exporting combo_groups to CSV with hex-encoded BLOBs...")
        cursor.execute("""
            SELECT id, name, restaurant, dish, options, `group`
            FROM combo_groups
            ORDER BY id
        """)
        
        rows_exported = 0
        
        # Open CSV for writing
        with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            
            # Write header
            writer.writerow(['id', 'name', 'restaurant', 'dish_hex', 'options_hex', 'group_hex'])
            
            for row in cursor:
                row_id, name, restaurant, dish_blob, options_blob, group_blob = row
                
                # Convert BLOBs to hex
                def blob_to_hex(blob):
                    if not blob:
                        return ''
                    if isinstance(blob, bytes):
                        return "0x" + binascii.hexlify(blob).decode('utf-8')
                    elif isinstance(blob, str):
                        return "0x" + binascii.hexlify(blob.encode('latin-1')).decode('utf-8')
                    return ''
                
                dish_hex = blob_to_hex(dish_blob)
                options_hex = blob_to_hex(options_blob)
                group_hex = blob_to_hex(group_blob)
                
                # Write row
                writer.writerow([row_id, name or '', restaurant, dish_hex, options_hex, group_hex])
                
                rows_exported += 1
                
                if rows_exported % 5000 == 0:
                    print(f"  Exported {rows_exported:,} / {total_rows:,} rows...")
        
        print(f"\nExported {rows_exported:,} rows")
        
        # Get file size
        import os
        file_size = os.path.getsize(OUTPUT_CSV)
        file_size_mb = file_size / (1024 * 1024)
        
        print()
        print("=" * 70)
        print("Success!")
        print("=" * 70)
        print(f"  Output: {OUTPUT_CSV}")
        print(f"  Rows: {rows_exported:,}")
        print(f"  Size: {file_size_mb:.2f} MB")
        print()
        print("Next step: Deserialize each BLOB separately")
        print("  1. phase4_4_deserialize_dish_blob.py")
        print("  2. phase4_4_deserialize_options_blob.py")
        print("  3. phase4_4_deserialize_group_blob.py")
        print()
        
        cursor.close()
        connection.close()
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()


