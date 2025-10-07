#!/usr/bin/env python3
"""
Robust CSV to PostgreSQL Loader
Handles MySQL CSV exports with proper escaping
"""

import psycopg2
import csv
import sys
from pathlib import Path

# Configuration
DB_CONFIG = {
    'host': 'db.nthpbtdjhhnwfxqsxbvy.supabase.co',
    'port': 5432,
    'database': 'postgres',
    'user': 'postgres',
    'password': None  # Will be set from command line
}

CSV_DIR = Path('/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV')

# Table mappings: (csv_file, table_name, delimiter)
TABLES = [
    # V2 tables to reload with proper ID mapping
    ('menuca_v2_site_users.csv', 'v2_site_users', ','),
    ('menuca_v2_site_users_delivery_addresses.csv', 'v2_site_users_delivery_addresses', ','),
    ('menuca_v2_site_users_autologins.csv', 'v2_site_users_autologins', ','),
]

def get_table_columns(cur, table_name):
    """Get column names for a table (excluding metadata columns)"""
    cur.execute(f"""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'staging'
          AND table_name = '{table_name}'
          AND column_name NOT LIKE '\\_%'
        ORDER BY ordinal_position
    """)
    return [row[0] for row in cur.fetchall()]

def load_csv(conn, csv_file, table_name, delimiter):
    """Load a CSV file into PostgreSQL table"""
    csv_path = CSV_DIR / csv_file
    
    if not csv_path.exists():
        print(f"❌ File not found: {csv_path}")
        return 0
    
    print(f"📥 Loading: {csv_file} → staging.{table_name}")
    
    cur = conn.cursor()
    
    # Get table columns
    columns = get_table_columns(cur, table_name)
    col_str = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))
    
    # Prepare INSERT statement
    insert_sql = f"INSERT INTO staging.{table_name} ({col_str}) VALUES ({placeholders})"
    
    # Read and insert CSV data
    loaded = 0
    errors = 0
    
    with open(csv_path, 'r', encoding='utf-8', errors='replace') as f:
        # Try to detect if file uses standard CSV quoting
        reader = csv.DictReader(f, delimiter=delimiter)
        
        # Clean header names (strip whitespace)
        reader.fieldnames = [name.strip() if name else name for name in reader.fieldnames]
        
        for i, row in enumerate(reader, start=2):  # start=2 because line 1 is header
            try:
                # Extract values in column order
                values = []
                for col in columns:
                    val = row.get(col, '')
                    # Convert empty strings to None for SQL NULL
                    if val == '' or val is None:
                        values.append(None)
                    # Handle "0000-00-00" MySQL dates
                    elif val in ('0000-00-00 00:00:00', '0000-00-00'):
                        values.append(None)
                    else:
                        values.append(val)
                
                cur.execute(insert_sql, values)
                loaded += 1
                
                # Commit every 1000 rows
                if loaded % 1000 == 0:
                    conn.commit()
                    print(f"   ... {loaded} rows", end='\r')
                    
            except Exception as e:
                errors += 1
                if errors <= 5:  # Only print first 5 errors
                    print(f"\n   ⚠️  Error on line {i}: {e}")
                if errors == 5:
                    print(f"   ... suppressing further errors")
                continue
    
    # Final commit
    conn.commit()
    cur.close()
    
    print(f"   ✅ Loaded: {loaded} rows ({errors} errors)")
    return loaded

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 load_all_data.py <supabase_password>")
        sys.exit(1)
    
    DB_CONFIG['password'] = sys.argv[1]
    
    print("================================================================")
    print("CSV → PostgreSQL Loader (with proper escaping)")
    print("================================================================")
    print("")
    
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False  # Use transactions
        
        total_loaded = 0
        
        # Load each table
        for csv_file, table_name, delimiter in TABLES:
            loaded = load_csv(conn, csv_file, table_name, delimiter)
            total_loaded += loaded
            print("")
        
        conn.close()
        
        print("================================================================")
        print(f"✅ COMPLETE! Total rows loaded: {total_loaded}")
        print("================================================================")
        
    except Exception as e:
        print(f"❌ Database error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
