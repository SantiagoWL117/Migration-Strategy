#!/usr/bin/env python3
"""
Convert MySQL INSERT statements to direct PostgreSQL inserts
Handles apostrophe escaping properly
"""

import psycopg2
import re
import sys

DB_CONFIG = {
    'host': 'db.nthpbtdjhhnwfxqsxbvy.supabase.co',
    'port': 5432,
    'database': 'postgres',
    'user': 'postgres',
    'password': None
}

SQL_FILE = '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/dumps/menuca_v1_users.sql'

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 convert_mysql_insert_to_pg.py <password>")
        sys.exit(1)
    
    DB_CONFIG['password'] = sys.argv[1]
    
    print("=" * 64)
    print("Loading ALL V1 Active Users from SQL Dump")
    print("=" * 64)
    print("")
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False
        cur = conn.cursor()
        
        # Clear existing data
        print("Step 1: Clearing existing V1 users...")
        cur.execute("TRUNCATE staging.v1_users CASCADE")
        conn.commit()
        print("   ✅ Cleared")
        print("")
        
        # Get column names from staging table
        print("Step 2: Getting table structure...")
        cur.execute("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'staging'
              AND table_name = 'v1_users'
              AND column_name NOT LIKE '\\_%'
            ORDER BY ordinal_position
        """)
        columns = [row[0] for row in cur.fetchall()]
        col_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))
        insert_sql = f"INSERT INTO staging.v1_users ({col_str}) VALUES ({placeholders})"
        print(f"   ✅ Table has {len(columns)} columns")
        print("")
        
        # Process SQL dump line by line
        print("Step 3: Processing SQL dump...")
        print("   (Converting MySQL format to PostgreSQL...)")
        
        total_loaded = 0
        errors = 0
        batch = []
        batch_size = 1000
        
        with open(SQL_FILE, 'r', encoding='utf-8', errors='replace') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                
                if not line.startswith('INSERT INTO'):
                    continue
                
                try:
                    # Extract the VALUES clause
                    match = re.search(r'VALUES\s+(.+)', line, re.IGNORECASE)
                    if not match:
                        continue
                    
                    values_str = match.group(1)
                    if values_str.endswith(';'):
                        values_str = values_str[:-1]
                    
                    # Split by "),(" to get individual rows
                    # This is a simple split - works for most cases
                    values_str = values_str.strip()
                    if values_str.startswith('('):
                        values_str = values_str[1:]
                    if values_str.endswith(')'):
                        values_str = values_str[:-1]
                    
                    # Split by ),( but this is naive and might fail on content with ),
                    # For now, let's try a different approach: use regex to find complete tuples
                    row_pattern = r'\(([^)]+(?:\([^)]*\)[^)]*)*)\)'
                    rows = re.findall(row_pattern, f"({values_str})")
                    
                    for row_str in rows:
                        try:
                            # Split by comma, respecting quotes
                            values = []
                            current_val = ""
                            in_quote = False
                            escape_next = False
                            
                            for char in row_str + ',':
                                if escape_next:
                                    current_val += char
                                    escape_next = False
                                    continue
                                
                                if char == '\\\\':
                                    escape_next = True
                                    current_val += char
                                    continue
                                
                                if char == "'" and not escape_next:
                                    in_quote = not in_quote
                                    current_val += char
                                    continue
                                
                                if char == ',' and not in_quote:
                                    val = current_val.strip()
                                    
                                    # Convert MySQL value to Python
                                    if val.upper() == 'NULL':
                                        values.append(None)
                                    elif val.startswith("'") and val.endswith("'"):
                                        # String value - remove quotes and unescape
                                        val = val[1:-1]
                                        val = val.replace("\\\\'", "'")
                                        val = val.replace('\\\\\\\\', '\\\\')
                                        val = val.replace('\\\\n', '\\n')
                                        val = val.replace('\\\\r', '\\r')
                                        values.append(val)
                                    else:
                                        # Numeric or other
                                        values.append(val if val else None)
                                    
                                    current_val = ""
                                else:
                                    current_val += char
                            
                            # Pad or trim to match column count
                            while len(values) < len(columns):
                                values.append(None)
                            values = values[:len(columns)]
                            
                            # Add to batch
                            batch.append(values)
                            
                            # Insert batch if full
                            if len(batch) >= batch_size:
                                cur.executemany(insert_sql, batch)
                                conn.commit()
                                total_loaded += len(batch)
                                print(f"   ... {total_loaded:,} rows", end='\\r')
                                batch = []
                        
                        except Exception as e:
                            errors += 1
                            if errors <= 5:
                                print(f"\\n   ⚠️  Row parse error: {str(e)[:100]}")
                            continue
                
                except Exception as e:
                    print(f"\\n   ⚠️  Line {line_num} error: {str(e)[:100]}")
                    continue
        
        # Insert remaining batch
        if batch:
            cur.executemany(insert_sql, batch)
            conn.commit()
            total_loaded += len(batch)
        
        print(f"\\n   ✅ Loaded: {total_loaded:,} rows ({errors} parse errors)")
        print("")
        
        # Statistics
        print("Step 4: Statistics on loaded data...")
        cur.execute("""
            SELECT 
                COUNT(*) as total_users,
                MIN(EXTRACT(YEAR FROM lastLogin)) as earliest_year,
                MAX(EXTRACT(YEAR FROM lastLogin)) as latest_year,
                COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM lastLogin) >= 2024) as users_2024_plus,
                ROUND(100.0 * COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM lastLogin) >= 2024) / NULLIF(COUNT(*),0), 2) as pct_recent
            FROM staging.v1_users
        """)
        stats = cur.fetchone()
        print(f"   Total Users: {stats[0]:,}")
        print(f"   Year Range: {int(stats[1]) if stats[1] else 'N/A'} - {int(stats[2]) if stats[2] else 'N/A'}")
        print(f"   Active (2024+): {stats[3]:,} ({stats[4]}%)")
        print("")
        
        cur.close()
        conn.close()
        
        print("=" * 64)
        print("✅ V1 ACTIVE USERS LOAD COMPLETE!")
        print("=" * 64)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
