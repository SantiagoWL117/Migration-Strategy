#!/usr/bin/env python3
"""
Convert Menu & Catalog SQL dumps to CSV files, excluding BLOB columns.

Author: Migration Team
Date: 2025-01-08
Phase: Pre-Phase 2 (Data Extraction)

BLOB Columns Excluded:
- menuca_v1_menu: hideOnDays (BLOB Case #1)
- menuca_v1_menuothers: content (BLOB Case #2)  
- menuca_v1_ingredient_groups: item, price (BLOB Case #3)
- menuca_v1_combo_groups: dish, options, group (BLOB Case #4)
"""

import re
import csv
import os
from pathlib import Path
from typing import List, Dict, Optional, Tuple

# Configuration
SCRIPT_DIR = Path(__file__).parent
DUMPS_DIR = SCRIPT_DIR.parent / "dumps"
CSV_DIR = SCRIPT_DIR.parent / "CSV"
LOG_FILE = SCRIPT_DIR / "conversion_log.txt"

# BLOB columns to exclude per table
EXCLUDE_COLUMNS = {
    'menuca_v1_menu': ['hideOnDays'],
    'menuca_v1_menuothers': ['content'],
    'menuca_v1_ingredient_groups': ['item', 'price'],
    'menuca_v1_combo_groups': ['dish', 'options', 'group']
}


def extract_column_names(create_table_sql: str, exclude_list: List[str]) -> Tuple[List[str], Dict[int, str]]:
    """
    Extract column names from CREATE TABLE statement.
    
    Returns:
        Tuple of (included_columns, all_columns_dict)
        all_columns_dict maps index -> column_name for skip tracking
    """
    included_columns = []
    all_columns = {}
    
    # Find the column definitions block
    match = re.search(r'CREATE TABLE.*?\((.*?)\)(?:\s+ENGINE|\s*;)', create_table_sql, re.DOTALL | re.IGNORECASE)
    if not match:
        return [], {}
    
    column_block = match.group(1)
    lines = column_block.split('\n')
    
    col_index = 0
    for line in lines:
        line = line.strip()
        
        # Skip constraints and keys
        if any(keyword in line.upper() for keyword in ['PRIMARY KEY', 'UNIQUE KEY', 'KEY ', 'CONSTRAINT', 'FOREIGN KEY']):
            continue
        
        # Match column definition: `column_name` type ...
        col_match = re.match(r'`([^`]+)`\s+', line)
        if col_match:
            col_name = col_match.group(1)
            all_columns[col_index] = col_name
            
            if col_name not in exclude_list:
                included_columns.append(col_name)
                print(f"    [+] Column: {col_name}")
            else:
                print(f"    [-] Skipping BLOB column: {col_name}")
            
            col_index += 1
    
    return included_columns, all_columns


def parse_insert_values(insert_statement: str) -> List[List[str]]:
    """
    Parse INSERT INTO ... VALUES (...), (...), ... statement.
    Returns list of rows, each row is a list of values.
    """
    # Extract VALUES portion
    values_match = re.search(r'VALUES\s+(.*);?\s*$', insert_statement, re.DOTALL | re.IGNORECASE)
    if not values_match:
        return []
    
    values_str = values_match.group(1).strip()
    if values_str.endswith(';'):
        values_str = values_str[:-1]
    
    rows = []
    current_row = []
    current_value = ""
    in_quotes = False
    escaped = False
    paren_depth = 0
    
    i = 0
    while i < len(values_str):
        char = values_str[i]
        
        # Handle escape sequences
        if escaped:
            if char == 'n':
                current_value += '\n'
            elif char == 'r':
                current_value += '\r'
            elif char == 't':
                current_value += '\t'
            elif char == '0':
                current_value += '\0'
            elif char == '\\':
                current_value += '\\'
            elif char == "'":
                current_value += "'"
            else:
                current_value += char
            escaped = False
            i += 1
            continue
        
        if char == '\\':
            escaped = True
            i += 1
            continue
        
        # Handle quotes
        if char == "'":
            in_quotes = not in_quotes
            i += 1
            continue
        
        # Only process delimiters outside of quotes
        if not in_quotes:
            if char == '(':
                paren_depth += 1
                if paren_depth == 1:
                    # Start of new row
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    # End of row
                    current_row.append(current_value.strip())
                    rows.append(current_row)
                    current_row = []
                    current_value = ""
                    i += 1
                    continue
            elif char == ',' and paren_depth == 1:
                # Column separator
                current_row.append(current_value.strip())
                current_value = ""
                i += 1
                # Skip whitespace after comma
                while i < len(values_str) and values_str[i] in ' \t\n\r':
                    i += 1
                continue
        
        current_value += char
        i += 1
    
    return rows


def clean_value(value: str) -> str:
    """Clean and prepare value for CSV output."""
    if value.upper() == 'NULL' or value == '':
        return ''
    
    # Remove leading/trailing quotes if present
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
    
    # Unescape MySQL escapes
    value = value.replace("\\'", "'")
    value = value.replace('\\\\', '\\')
    value = value.replace('\\n', '\n')
    value = value.replace('\\r', '\r')
    value = value.replace('\\t', '\t')
    
    return value


def convert_sql_to_csv(sql_file: Path, csv_file: Path, filename_base: str) -> bool:
    """
    Convert a single SQL dump file to CSV.
    
    Returns:
        True if successful, False otherwise
    """
    print(f"\n[*] Processing: {filename_base}")
    
    try:
        # Read SQL file
        with open(sql_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Extract actual table name from CREATE TABLE statement
        table_name_match = re.search(
            r'CREATE TABLE\s+`?([^`\s]+)`?\s*\(',
            content,
            re.IGNORECASE
        )
        
        if not table_name_match:
            print(f"  [X] Could not find table name in dump")
            return False
        
        table_name = table_name_match.group(1)
        print(f"  [i] Table name: {table_name}")
        
        # Get exclude list for this filename (not table name)
        exclude_list = EXCLUDE_COLUMNS.get(filename_base, [])
        if exclude_list:
            print(f"  [!] Excluding BLOB columns: {', '.join(exclude_list)}")
        
        # Extract CREATE TABLE statement
        create_match = re.search(
            rf'CREATE TABLE\s+`?{re.escape(table_name)}`?\s*\((.*?)\)(?:\s+ENGINE|\s*;)',
            content,
            re.DOTALL | re.IGNORECASE
        )
        
        if not create_match:
            print(f"  [X] Could not find CREATE TABLE for {table_name}")
            return False
        
        create_block = create_match.group(0)
        
        # Extract column names
        columns, all_columns_dict = extract_column_names(create_block, exclude_list)
        
        if not columns:
            print(f"  [X] No columns found")
            return False
        
        print(f"  [i] Columns: {len(columns)} (after excluding BLOBs)")
        
        # Determine which indices to skip
        skip_indices = set()
        for idx, col_name in all_columns_dict.items():
            if col_name in exclude_list:
                skip_indices.add(idx)
        
        # Extract INSERT statements
        insert_pattern = rf'INSERT INTO\s+(?:`{re.escape(table_name)}`|{re.escape(table_name)})\s+VALUES\s+(.*?);'
        insert_matches = list(re.finditer(insert_pattern, content, re.DOTALL | re.IGNORECASE))
        
        # Create CSV file
        with open(csv_file, 'w', newline='', encoding='utf-8') as csvf:
            writer = csv.writer(csvf, quoting=csv.QUOTE_MINIMAL)
            
            # Write header (lowercase to match PostgreSQL column names)
            writer.writerow([col.lower() for col in columns])
            
            # Process INSERT statements
            row_count = 0
            for insert_match in insert_matches:
                insert_stmt = insert_match.group(0)
                rows = parse_insert_values(insert_stmt)
                
                for row in rows:
                    # Filter out excluded columns
                    filtered_row = []
                    for idx, value in enumerate(row):
                        if idx not in skip_indices:
                            filtered_row.append(clean_value(value))
                    
                    # Validate column count
                    if len(filtered_row) == len(columns):
                        writer.writerow(filtered_row)
                        row_count += 1
                        
                        if row_count % 1000 == 0:
                            print(f"    -> Processed {row_count} rows...")
                    else:
                        print(f"  [!] Row has {len(filtered_row)} values, expected {len(columns)} (skipped)")
        
        if row_count == 0:
            print(f"  [!] No data rows found (empty table)")
        else:
            print(f"  [+] Converted {row_count} rows to CSV")
        
        return True
        
    except Exception as e:
        print(f"  [X] Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Main execution function."""
    print("=== Menu & Catalog SQL to CSV Conversion ===")
    print(f"Dumps Directory: {DUMPS_DIR}")
    print(f"CSV Directory: {CSV_DIR}")
    print()
    
    # Create CSV directory
    CSV_DIR.mkdir(exist_ok=True)
    
    # Get all SQL dump files
    dump_files = sorted(DUMPS_DIR.glob("*.sql"))
    
    if not dump_files:
        print(f"[X] No SQL dump files found in {DUMPS_DIR}")
        return 1
    
    print(f"Found {len(dump_files)} dump files")
    
    # Process each dump
    success_count = 0
    fail_count = 0
    
    for sql_file in dump_files:
        table_name = sql_file.stem
        csv_file = CSV_DIR / f"{table_name}.csv"
        
        if convert_sql_to_csv(sql_file, csv_file, table_name):
            success_count += 1
        else:
            fail_count += 1
    
    # Summary
    print("\n=== Conversion Summary ===")
    print(f"Total Files: {len(dump_files)}")
    print(f"[+] Successful: {success_count}")
    print(f"[X] Failed: {fail_count}")
    print(f"\nCSV files: {CSV_DIR}")
    
    if success_count == len(dump_files):
        print("\n[SUCCESS] All dumps converted successfully!")
        return 0
    else:
        print("\n[WARNING] Some conversions failed.")
        return 1


if __name__ == "__main__":
    exit(main())

