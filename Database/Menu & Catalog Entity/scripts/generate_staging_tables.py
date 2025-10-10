#!/usr/bin/env python3
"""
Generate CREATE TABLE statements for staging tables based on CSV headers.

This script reads all CSV files and generates PostgreSQL CREATE TABLE statements
with VARCHAR columns matching the CSV structure exactly.
"""

import csv
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
CSV_DIR = SCRIPT_DIR.parent / "CSV"
OUTPUT_FILE = SCRIPT_DIR.parent / "staging_tables_creation.sql"

def get_csv_headers(csv_file: Path) -> list:
    """Extract column headers from CSV file."""
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = next(reader)
    return headers

def generate_create_table_sql(table_name: str, columns: list) -> str:
    """Generate CREATE TABLE SQL statement."""
    
    sql = f"-- Create staging table for {table_name}\n"
    sql += f"DROP TABLE IF EXISTS staging.{table_name} CASCADE;\n\n"
    sql += f"CREATE TABLE staging.{table_name} (\n"
    
    # Add columns (all as VARCHAR initially for safe CSV import)
    column_definitions = []
    for col in columns:
        # Handle reserved keywords and special characters
        col_escaped = col.lower().strip()
        
        # Use TEXT for potentially long columns, VARCHAR for others
        if col_escaped in ['description', 'ingredients', 'desc', 'items']:
            column_definitions.append(f"  {col_escaped} TEXT")
        else:
            column_definitions.append(f"  {col_escaped} VARCHAR(500)")
    
    sql += ",\n".join(column_definitions)
    sql += "\n);\n\n"
    
    # Add comment
    sql += f"COMMENT ON TABLE staging.{table_name} IS 'Staging table for {table_name} - imported from CSV';\n\n"
    
    # Create index on id column if it exists
    if 'id' in [c.lower() for c in columns]:
        sql += f"CREATE INDEX idx_{table_name}_id ON staging.{table_name}(id);\n\n"
    
    sql += f"-- Expected row count from CSV: (check CSV file)\n"
    sql += "-" * 80 + "\n\n"
    
    return sql

def main():
    """Main execution function."""
    print("=== Staging Tables SQL Generator ===")
    print(f"CSV Directory: {CSV_DIR}")
    print(f"Output File: {OUTPUT_FILE}")
    print()
    
    # Get all CSV files
    csv_files = sorted(CSV_DIR.glob("*.csv"))
    
    if not csv_files:
        print(f"[X] No CSV files found in {CSV_DIR}")
        return 1
    
    print(f"Found {len(csv_files)} CSV files")
    
    # Generate SQL file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as sql_file:
        # Write header
        sql_file.write("-- =====================================================\n")
        sql_file.write("-- Staging Tables Creation Script\n")
        sql_file.write("-- Menu & Catalog Entity - Phase 2\n")
        sql_file.write("--\n")
        sql_file.write("-- Generated from CSV headers\n")
        sql_file.write("-- Date: 2025-01-08\n")
        sql_file.write("--\n")
        sql_file.write(f"-- Total Tables: {len(csv_files)}\n")
        sql_file.write("-- =====================================================\n\n")
        
        sql_file.write("-- Set search path\n")
        sql_file.write("SET search_path TO staging, public;\n\n")
        
        sql_file.write("-- Start transaction\n")
        sql_file.write("BEGIN;\n\n")
        sql_file.write("=" * 80 + "\n\n")
        
        # Process each CSV file
        for csv_file in csv_files:
            table_name = csv_file.stem
            print(f"[*] Processing: {table_name}")
            
            try:
                headers = get_csv_headers(csv_file)
                print(f"    Columns: {len(headers)}")
                
                # Generate CREATE TABLE statement
                create_sql = generate_create_table_sql(table_name, headers)
                sql_file.write(create_sql)
                
            except Exception as e:
                print(f"  [X] Error: {e}")
                continue
        
        # Write footer
        sql_file.write("=" * 80 + "\n\n")
        sql_file.write("-- Commit transaction\n")
        sql_file.write("COMMIT;\n\n")
        
        sql_file.write("-- Verify tables created\n")
        sql_file.write("SELECT \n")
        sql_file.write("    table_name,\n")
        sql_file.write("    (SELECT COUNT(*) FROM information_schema.columns \n")
        sql_file.write("     WHERE table_schema = 'staging' AND table_name = t.table_name) as column_count\n")
        sql_file.write("FROM information_schema.tables t\n")
        sql_file.write("WHERE table_schema = 'staging'\n")
        sql_file.write("  AND table_name LIKE 'menuca_%'\n")
        sql_file.write("ORDER BY table_name;\n\n")
        
        sql_file.write("-- Expected: 17 tables\n")
    
    print(f"\n[SUCCESS] SQL file generated: {OUTPUT_FILE}")
    print(f"[i] Total tables: {len(csv_files)}")
    print("\nNext steps:")
    print("1. Review the generated SQL file")
    print("2. Execute via Supabase MCP")
    print("3. Import CSV files via Supabase UI")
    
    return 0

if __name__ == "__main__":
    exit(main())



