#!/usr/bin/env python3
"""
Load V1 Users SQL Dump - Final Version
Handles MySQL escaping, filters for recent users (2024+)
"""

import psycopg2
import re
import sys

DB_CONFIG = {
    'host': 'db.nthpbtdjhhnwfxqsxbvy.supabase.co',
    'port': 5432,
    'database': 'postgres',
    'user': 'postgres',
    'password': 'Gz35CPTom1RnsmGM'
}

SQL_FILE = '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/dumps/menuca_v1_users.sql'

def parse_mysql_value(val):
    """Convert MySQL value to Python"""
    val = val.strip()
    if val.upper() == 'NULL':
        return None
    if val.startswith("'") and val.endswith("'"):
        # Unescape MySQL string
        val = val[1:-1]
        val = val.replace("\\'", "'")
        val = val.replace("\\\\", "\\")
        return val
    return val if val else None

print("=" * 70)
print("Loading V1 Users from SQL Dump (ALL ACTIVE USERS)")
print("=" * 70)
print()

try:
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    # Clear table
    print("Step 1: Clearing staging.v1_users...")
    cur.execute("TRUNCATE staging.v1_users CASCADE")
    conn.commit()
    print("   ✅ Done")
    print()
    
    # Get columns
    print("Step 2: Getting table schema...")
    cur.execute("""
        SELECT column_name FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='v1_users' 
        AND column_name NOT LIKE '\\_%%'
        ORDER BY ordinal_position
    """)
    columns = [row[0] for row in cur.fetchall()]
    print(f"   ✅ {len(columns)} columns")
    print()
    
    # Prepare insert statement
    placeholders = ','.join(['%s'] * len(columns))
    insert_sql = f"INSERT INTO staging.v1_users ({','.join(columns)}) VALUES ({placeholders})"
    
    # Process SQL dump
    print("Step 3: Loading data from SQL dump...")
    print("   (This may take 2-3 minutes for 400k+ rows...)")
    print()
    
    total_loaded = 0
    total_skipped = 0
    batch = []
    batch_size = 1000
    
    with open(SQL_FILE, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            if not line.startswith('INSERT INTO'):
                continue
            
            # Extract VALUES clause
            match = re.search(r'VALUES\s+(.+)', line, re.IGNORECASE)
            if not match:
                continue
            
            values_part = match.group(1).rstrip(';')
            
            # Split into individual row tuples
            # Pattern: find content between ()
            row_matches = re.finditer(r'\(([^)]*(?:\([^)]*\)[^)]*)*)\)', values_part)
            
            for row_match in row_matches:
                row_str = row_match.group(1)
                
                # Split by comma, respecting quotes
                values = []
                current = ""
                in_quote = False
                escaped = False
                
                for char in row_str + ',':
                    if escaped:
                        current += char
                        escaped = False
                        continue
                    
                    if char == '\\':
                        escaped = True
                        current += char
                        continue
                    
                    if char == "'" and not escaped:
                        in_quote = not in_quote
                        current += char
                        continue
                    
                    if char == ',' and not in_quote:
                        values.append(parse_mysql_value(current))
                        current = ""
                    else:
                        current += char
                
                # Pad/trim to column count
                while len(values) < len(columns):
                    values.append(None)
                values = values[:len(columns)]
                
                # Check lastLogin filter (column index 11 based on schema)
                lastlogin = values[11] if len(values) > 11 else None
                if lastlogin and str(lastlogin) >= '2024-01-01':
                    batch.append(values)
                else:
                    total_skipped += 1
                
                # Insert batch
                if len(batch) >= batch_size:
                    try:
                        cur.executemany(insert_sql, batch)
                        conn.commit()
                        total_loaded += len(batch)
                        print(f"   ✓ Loaded: {total_loaded:,} | Skipped: {total_skipped:,}", end='\r')
                        batch = []
                    except Exception as e:
                        print(f"\n   ⚠️  Batch error: {e}")
                        conn.rollback()
                        batch = []
    
    # Insert remaining
    if batch:
        try:
            cur.executemany(insert_sql, batch)
            conn.commit()
            total_loaded += len(batch)
        except Exception as e:
            print(f"\n   ⚠️  Final batch error: {e}")
    
    print(f"\n   ✅ Loaded: {total_loaded:,} users (2024+)")
    print(f"   ⏭️  Skipped: {total_skipped:,} users (pre-2024)")
    print()
    
    # Statistics
    print("Step 4: Verification...")
    cur.execute("""
        SELECT 
            COUNT(*) as total,
            MIN(lastLogin) as earliest,
            MAX(lastLogin) as latest,
            COUNT(DISTINCT email) as unique_emails
        FROM staging.v1_users
    """)
    stats = cur.fetchone()
    print(f"   Total Users: {stats[0]:,}")
    print(f"   Date Range: {stats[1]} to {stats[2]}")
    print(f"   Unique Emails: {stats[3]:,}")
    print()
    
    cur.close()
    conn.close()
    
    print("=" * 70)
    print("✅ SUCCESS! V1 Users Loaded")
    print("=" * 70)
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
