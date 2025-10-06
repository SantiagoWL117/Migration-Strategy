#!/usr/bin/env python3
"""
SQL Dump to CSV Converter
Converts SQL INSERT statements to CSV format
"""

import re
import os
import sys

# Define paths
dump_dir = r"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Service Configuration & Schedules\dumps"
csv_dir = r"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Service Configuration & Schedules\CSV"

# Files to convert (BLOB file excluded)
files_to_convert = [
    "menuca_v2_restaurants_schedule",
    "menuca_v2_restaurants_special_schedule",
    "menuca_v2_restaurants_time_periods",
    "migration_db_menuca_v1_restaurants_service_flags",
    "migration_db_menuca_v2_restaurants_service_flags"
]

print("=" * 80)
print("SQL Dump to CSV Conversion Utility")
print("=" * 80)
print()

# Ensure CSV directory exists
os.makedirs(csv_dir, exist_ok=True)

# Process each file
success_count = 0
failed_count = 0
skipped_count = 0

for file_name in files_to_convert:
    sql_file = f"{file_name}.sql"
    csv_file = f"{file_name}.csv"
    
    print(f"Processing: {file_name}")
    print(f"  Source: {sql_file}")
    print(f"  Target: {csv_file}")
    
    sql_path = os.path.join(dump_dir, sql_file)
    csv_path = os.path.join(csv_dir, csv_file)
    
    # Check if source file exists
    if not os.path.exists(sql_path):
        print(f"  [X] Source file not found!")
        failed_count += 1
        continue
    
    # Check if CSV already exists
    if os.path.exists(csv_path):
        print(f"  [!] CSV already exists - skipping")
        skipped_count += 1
        continue
    
    try:
        # Read SQL dump file
        with open(sql_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract column names from CREATE TABLE
        create_match = re.search(r'CREATE TABLE `([^`]+)` \((.*?)\n\)', content, re.DOTALL)
        if not create_match:
            print(f"  [X] Could not find CREATE TABLE")
            failed_count += 1
            continue
        
        table_def = create_match.group(2)
        columns = []
        for line in table_def.split('\n'):
            col_match = re.match(r'\s*`([^`]+)`\s+', line)
            if col_match:
                columns.append(col_match.group(1))
        
        if not columns:
            print(f"  [X] Could not extract columns")
            failed_count += 1
            continue
        
        # Extract INSERT data
        insert_match = re.search(r'INSERT INTO `[^`]+` VALUES\s*(.+);', content, re.DOTALL)
        if not insert_match:
            print(f"  [X] Could not find INSERT statement")
            failed_count += 1
            continue
        
        insert_data = insert_match.group(1)
        
        # Parse rows - find all (...) groups
        rows = []
        depth = 0
        current_row = ""
        in_quote = False
        prev_char = ""
        
        for char in insert_data:
            if char == "'" and prev_char != '\\':
                in_quote = not in_quote
            
            if not in_quote:
                if char == '(':
                    depth += 1
                    if depth == 1:
                        current_row = ""
                        prev_char = char
                        continue
                elif char == ')':
                    depth -= 1
                    if depth == 0:
                        rows.append(current_row)
                        current_row = ""
                        prev_char = char
                        continue
            
            if depth > 0:
                current_row += char
            
            prev_char = char
        
        # Write CSV
        with open(csv_path, 'w', encoding='utf-8', newline='') as f:
            # Write header
            f.write(",".join(columns) + "\n")
            
            # Write rows
            for row in rows:
                # Split by commas (respecting quotes)
                fields = []
                current_field = ""
                in_quote = False
                prev_char = ""
                
                for i, char in enumerate(row):
                    if char == "'" and (i == 0 or row[i-1] != '\\'):
                        in_quote = not in_quote
                        continue  # Skip quotes
                    
                    if char == ',' and not in_quote:
                        field = current_field.strip()
                        # Handle NULL
                        if field.upper() == 'NULL':
                            field = ''
                        # Remove escaping
                        field = field.replace("\\'", "'")
                        field = field.replace('\\"', '"')
                        field = field.replace('\\n', ' ')
                        field = field.replace('\\r', '')
                        field = field.replace('\\t', ' ')
                        # Escape CSV quotes
                        if '"' in field or ',' in field:
                            field = '"' + field.replace('"', '""') + '"'
                        fields.append(field)
                        current_field = ""
                        continue
                    
                    current_field += char
                
                # Add last field
                if current_field:
                    field = current_field.strip()
                    if field.upper() == 'NULL':
                        field = ''
                    field = field.replace("\\'", "'")
                    field = field.replace('\\"', '"')
                    field = field.replace('\\n', ' ')
                    field = field.replace('\\r', '')
                    field = field.replace('\\t', ' ')
                    if '"' in field or ',' in field:
                        field = '"' + field.replace('"', '""') + '"'
                    fields.append(field)
                
                f.write(",".join(fields) + "\n")
        
        print(f"  [OK] Success! Converted {len(rows)} rows")
        success_count += 1
        
    except Exception as e:
        print(f"  [X] Error: {e}")
        failed_count += 1
    
    print()

# Summary
print("=" * 80)
print("Conversion Summary")
print("=" * 80)
print(f"  Success:  {success_count} file(s)")
print(f"  Skipped:  {skipped_count} file(s) (already exist)")
print(f"  Failed:   {failed_count} file(s)")
print()
print("Note: menuca_v2_restaurants_configs.sql excluded due to BLOB column")
print("=" * 80)

