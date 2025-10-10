#!/usr/bin/env python3
"""
Phase 4.4 Step 1: Export combo_groups from MySQL with hex-encoded BLOBs
Exports all 3 BLOBs: dish, options, group
"""
import pymysql
import binascii
import sys

# MySQL Connection Config
MYSQL_HOST = "localhost"
MYSQL_USER = "root"
MYSQL_PASSWORD = "root"  # UPDATE THIS
MYSQL_DB = "menuca_v1"

OUTPUT_FILE = r"Database\Menu & Catalog Entity\dumps\menuca_v1_combo_groups_HEX.sql"

def main():
    print("=" * 70)
    print("Phase 4.4 Step 1: Export combo_groups with 3 hex BLOBs")
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
        
        # Export with hex BLOBs
        print("Exporting combo_groups with hex-encoded BLOBs...")
        cursor.execute("""
            SELECT id, name, restaurant, dish, options, `group`
            FROM combo_groups
            ORDER BY id
        """)
        
        rows_exported = 0
        
        # Open output file
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            # Write CREATE TABLE statement
            f.write("-- Phase 4.4: combo_groups with hex-encoded BLOBs\n")
            f.write(f"-- Exported: {total_rows:,} rows\n")
            f.write(f"-- BLOBs: dish, options, group\n\n")
            
            f.write("DROP TABLE IF EXISTS combo_groups_hex;\n\n")
            
            f.write("CREATE TABLE combo_groups_hex (\n")
            f.write("  id INT PRIMARY KEY,\n")
            f.write("  name VARCHAR(255),\n")
            f.write("  restaurant INT,\n")
            f.write("  dish_hex LONGTEXT,\n")
            f.write("  options_hex LONGTEXT,\n")
            f.write("  group_hex LONGTEXT\n")
            f.write(");\n\n")
            
            f.write("INSERT INTO combo_groups_hex (id, name, restaurant, dish_hex, options_hex, group_hex) VALUES\n")
            
            first_row = True
            
            for row in cursor:
                row_id, name, restaurant, dish_blob, options_blob, group_blob = row
                
                # Convert BLOBs to hex
                if dish_blob:
                    if isinstance(dish_blob, bytes):
                        dish_hex = "0x" + binascii.hexlify(dish_blob).decode('utf-8')
                    elif isinstance(dish_blob, str):
                        dish_hex = "0x" + binascii.hexlify(dish_blob.encode('latin-1')).decode('utf-8')
                    else:
                        dish_hex = "NULL"
                else:
                    dish_hex = "NULL"
                
                if options_blob:
                    if isinstance(options_blob, bytes):
                        options_hex = "0x" + binascii.hexlify(options_blob).decode('utf-8')
                    elif isinstance(options_blob, str):
                        options_hex = "0x" + binascii.hexlify(options_blob.encode('latin-1')).decode('utf-8')
                    else:
                        options_hex = "NULL"
                else:
                    options_hex = "NULL"
                
                if group_blob:
                    if isinstance(group_blob, bytes):
                        group_hex = "0x" + binascii.hexlify(group_blob).decode('utf-8')
                    elif isinstance(group_blob, str):
                        group_hex = "0x" + binascii.hexlify(group_blob.encode('latin-1')).decode('utf-8')
                    else:
                        group_hex = "NULL"
                else:
                    group_hex = "NULL"
                
                # Escape name
                if name:
                    name_escaped = f"'{name.replace(chr(39), chr(39)+chr(39))}'"
                else:
                    name_escaped = "NULL"
                
                # Write row
                if not first_row:
                    f.write(",\n")
                else:
                    first_row = False
                
                f.write(f"({row_id}, {name_escaped}, {restaurant}, {dish_hex}, {options_hex}, {group_hex})")
                
                rows_exported += 1
                
                if rows_exported % 1000 == 0:
                    print(f"  Exported {rows_exported:,} / {total_rows:,} rows...")
            
            f.write(";\n")
        
        print(f"\nExported {rows_exported:,} rows")
        
        # Get file size
        import os
        file_size = os.path.getsize(OUTPUT_FILE)
        file_size_mb = file_size / (1024 * 1024)
        
        print()
        print("=" * 70)
        print("Success!")
        print("=" * 70)
        print(f"  Output: {OUTPUT_FILE}")
        print(f"  Rows: {rows_exported:,}")
        print(f"  Size: {file_size_mb:.2f} MB")
        print()
        print("Next step: Run phase4_4_extract_combo_groups_hex.py")
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

