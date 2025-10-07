#!/usr/bin/env python3
"""
Load V1 Users from MySQL SQL Dump into PostgreSQL
Handles MySQL escaping properly
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

def parse_mysql_values(values_str):
    """Parse MySQL VALUES clause into individual rows"""
    # This is complex because of nested quotes, escaped characters, etc.
    # We'll use a simple approach: split by ),( but be careful with content
    
    # Remove the outer VALUES( ... )
    values_str = values_str.strip()
    if values_str.startswith('VALUES'):
        values_str = values_str[6:].strip()
    if values_str.startswith('('):
        values_str = values_str[1:]
    if values_str.endswith(';'):
        values_str = values_str[:-1]
    if values_str.endswith(')'):
        values_str = values_str[:-1]
    
    # Split by ),( to get individual rows
    # This is naive but works for most cases
    rows = []
    current_row = []
    in_quote = False
    escape_next = False
    depth = 0
    current_val = ""
    
    for char in values_str:
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
        
        if not in_quote:
            if char == '(':
                depth += 1
                if depth > 1:
                    current_val += char
                continue
            elif char == ')':
                depth -= 1
                if depth > 0:
                    current_val += char
                elif depth == 0:
                    # End of row
                    if current_val:
                        current_row.append(current_val.strip())
                    if current_row:
                        rows.append(current_row)
                    current_row = []
                    current_val = ""
                continue
            elif char == ',' and depth == 1:
                # Field separator
                current_row.append(current_val.strip())
                current_val = ""
                continue
        
        current_val += char
    
    # Handle last value
    if current_val:
        current_row.append(current_val.strip())
    if current_row:
        rows.append(current_row)
    
    return rows

def mysql_value_to_python(value):
    """Convert MySQL value string to Python value"""
    value = value.strip()
    
    if value.upper() == 'NULL':
        return None
    
    # String value (quoted)
    if value.startswith("'") and value.endswith("'"):
        # Remove quotes and unescape
        value = value[1:-1]
        value = value.replace("\\\\'", "'")
        value = value.replace('\\\\\\\\', '\\\\')
        value = value.replace('\\\\n', '\\n')
        value = value.replace('\\\\r', '\\r')
        value = value.replace('\\\\t', '\\t')
        return value
    
    # Numeric or other
    return value

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 load_v1_sql_dump.py <password>")
        sys.exit(1)
    
    DB_CONFIG['password'] = sys.argv[1]
    
    print("=" * 64)
    print("Loading V1 Users from MySQL SQL Dump (ALL USERS)")
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
        
        # Get column names
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
        
        # Process SQL dump
        print("Step 3: Processing SQL dump...")
        print("   (This will take a few minutes for 400k+ rows...)")
        
        total_loaded = 0
        errors = 0
        
        with open(SQL_FILE, 'r', encoding='utf-8', errors='replace') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                
                if not line.startswith('INSERT INTO'):
                    continue
                
                try:
                    # Extract VALUES clause
                    match = re.search(r'VALUES\s*(.+)', line, re.IGNORECASE | re.DOTALL)
                    if not match:
                        continue
                    
                    values_clause = match.group(1)
                    
                    # Parse into individual rows
                    rows = parse_mysql_values(values_clause)
                    
                    for row_values in rows:
                        try:
                            # Convert MySQL values to Python
                            py_values = [mysql_value_to_python(v) for v in row_values]
                            
                            # Pad or trim to match column count
                            while len(py_values) < len(columns):
                                py_values.append(None)
                            py_values = py_values[:len(columns)]
                            
                            # Insert
                            cur.execute(insert_sql, py_values)
                            total_loaded += 1
                            
                            if total_loaded % 5000 == 0:
                                conn.commit()
                                print(f"   ... {total_loaded:,} rows", end='\\r')
                        
                        except Exception as e:
                            errors += 1
                            if errors <= 5:
                                print(f"\\n   ⚠️  Row error: {e}")
                            continue
                
                except Exception as e:
                    print(f"\\n   ⚠️  Line {line_num} error: {e}")
                    continue
        
        # Final commit
        conn.commit()
        print(f"\\n   ✅ Loaded: {total_loaded:,} rows ({errors} errors)")
        print("")
        
        # Verify and stats
        print("Step 4: Statistics on loaded data...")
        cur.execute("""
            SELECT 
                COUNT(*) as total_users,
                COUNT(*) FILTER (WHERE lastLogin > '2020-01-01') as active_recent,
                COUNT(*) FILTER (WHERE lastLogin <= '2020-01-01' OR lastLogin IS NULL) as inactive_old,
                ROUND(100.0 * COUNT(*) FILTER (WHERE lastLogin > '2020-01-01') / COUNT(*), 2) as pct_active
            FROM staging.v1_users
        """)
        stats = cur.fetchone()
        print(f"   Total Users: {stats[0]:,}")
        print(f"   Active (lastLogin > 2020): {stats[1]:,} ({stats[3]}%)")
        print(f"   Inactive/Old: {stats[2]:,}")
        print("")
        
        cur.close()
        conn.close()
        
        print("=" * 64)
        print("✅ V1 USERS LOAD COMPLETE!")
        print("=" * 64)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
