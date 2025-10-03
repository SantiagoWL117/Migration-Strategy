#!/usr/bin/env python3
# ============================================================================
# Load V1 restaurant_admins Data into Staging (WITHOUT BLOB)
# ============================================================================
# Purpose: Extract V1 restaurant_admins and load into PostgreSQL staging
# Note: BLOB data (allowed_restaurants) excluded - handled in Step 5
# ============================================================================

import mysql.connector
import psycopg2
import os
import sys
from datetime import datetime

# Configuration
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', ''),
    'database': os.getenv('MYSQL_DATABASE', 'menuca_v1'),
}

POSTGRES_URL = os.getenv('SUPABASE_DB_URL')

def connect_mysql():
    """Connect to MySQL database"""
    try:
        conn = mysql.connector.connect(**MYSQL_CONFIG)
        print(f"✅ Connected to MySQL: {MYSQL_CONFIG['database']}")
        return conn
    except mysql.connector.Error as e:
        print(f"❌ MySQL connection error: {e}")
        sys.exit(1)

def connect_postgres():
    """Connect to PostgreSQL/Supabase database"""
    if not POSTGRES_URL:
        print("❌ Error: SUPABASE_DB_URL environment variable not set")
        sys.exit(1)
    
    try:
        conn = psycopg2.connect(POSTGRES_URL)
        print(f"✅ Connected to PostgreSQL/Supabase")
        return conn
    except psycopg2.Error as e:
        print(f"❌ PostgreSQL connection error: {e}")
        sys.exit(1)

def verify_source_data(mysql_cursor):
    """Verify source data exists"""
    mysql_cursor.execute("SELECT COUNT(*) FROM restaurant_admins")
    count = mysql_cursor.fetchone()[0]
    print(f"  Source records: {count}")
    return count

def clear_staging_table(pg_cursor):
    """Clear existing staging data (idempotent)"""
    pg_cursor.execute("TRUNCATE TABLE staging.v1_restaurant_admin_users")
    print("  Staging table cleared")

def load_data(mysql_cursor, pg_cursor, pg_conn):
    """Load data from MySQL to PostgreSQL staging"""
    
    # Query V1 data (WITHOUT allowed_restaurants BLOB)
    print("\n📊 Extracting V1 data...")
    mysql_cursor.execute("""
        SELECT 
            id,
            restaurant,
            fname,
            lname,
            email,
            password,
            lastlogin,
            loginCount,
            activeUser,
            sendStatement,
            NULL as created_at,
            NULL as updated_at
        FROM restaurant_admins
        ORDER BY id
    """)
    
    records = mysql_cursor.fetchall()
    print(f"✅ Extracted {len(records)} records from V1")
    
    if len(records) == 0:
        print("⚠️  No records found in source table")
        return 0
    
    # Insert into PostgreSQL staging
    print("\n📥 Loading into PostgreSQL staging...")
    
    insert_query = """
        INSERT INTO staging.v1_restaurant_admin_users (
            legacy_admin_id,
            legacy_v1_restaurant_id,
            fname,
            lname,
            email,
            password_hash,
            lastlogin,
            login_count,
            active_user,
            send_statement,
            created_at,
            updated_at
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
    """
    
    batch_size = 100
    loaded = 0
    errors = 0
    
    for i in range(0, len(records), batch_size):
        batch = records[i:i+batch_size]
        try:
            pg_cursor.executemany(insert_query, batch)
            pg_conn.commit()
            loaded += len(batch)
            print(f"  Loaded {loaded}/{len(records)} records...", end='\r')
        except psycopg2.Error as e:
            print(f"\n  ⚠️  Error in batch {i//batch_size + 1}: {e}")
            errors += 1
            pg_conn.rollback()
    
    print(f"\n✅ Loaded {loaded} records successfully")
    if errors > 0:
        print(f"⚠️  {errors} batch(es) had errors")
    
    return loaded

def verify_staging_data(pg_cursor):
    """Verify loaded data"""
    print("\n🔍 Verifying loaded data...")
    
    # Total count
    pg_cursor.execute("SELECT COUNT(*) FROM staging.v1_restaurant_admin_users")
    total = pg_cursor.fetchone()[0]
    print(f"  Total records: {total}")
    
    # Records with restaurant > 0
    pg_cursor.execute("""
        SELECT COUNT(*) 
        FROM staging.v1_restaurant_admin_users 
        WHERE legacy_v1_restaurant_id > 0
    """)
    valid = pg_cursor.fetchone()[0]
    print(f"  Restaurant admins (restaurant>0): {valid}")
    
    # Global admins (restaurant = 0)
    pg_cursor.execute("""
        SELECT COUNT(*) 
        FROM staging.v1_restaurant_admin_users 
        WHERE legacy_v1_restaurant_id = 0
    """)
    global_admins = pg_cursor.fetchone()[0]
    print(f"  Global admins (restaurant=0): {global_admins} (will be excluded)")
    
    # Active/Inactive distribution
    pg_cursor.execute("""
        SELECT 
            COUNT(CASE WHEN active_user = '1' THEN 1 END) AS active,
            COUNT(CASE WHEN active_user = '0' THEN 1 END) AS inactive
        FROM staging.v1_restaurant_admin_users
    """)
    active, inactive = pg_cursor.fetchone()
    print(f"  Active users: {active}")
    print(f"  Inactive users: {inactive}")
    
    # Check for NULL emails
    pg_cursor.execute("""
        SELECT COUNT(*) 
        FROM staging.v1_restaurant_admin_users 
        WHERE email IS NULL OR email = ''
    """)
    null_emails = pg_cursor.fetchone()[0]
    if null_emails > 0:
        print(f"  ⚠️  Records with NULL/empty email: {null_emails}")
    
    # Sample records
    print("\n📋 Sample records (first 5):")
    pg_cursor.execute("""
        SELECT 
            legacy_admin_id,
            legacy_v1_restaurant_id,
            fname,
            lname,
            email,
            active_user,
            login_count
        FROM staging.v1_restaurant_admin_users
        ORDER BY legacy_admin_id
        LIMIT 5
    """)
    
    for row in pg_cursor.fetchall():
        admin_id, rest_id, fname, lname, email, active, logins = row
        print(f"  ID {admin_id}: {fname} {lname} ({email}) - Restaurant: {rest_id}, Active: {active}, Logins: {logins}")

def main():
    print("=" * 80)
    print("  Step 1b: Load V1 restaurant_admins Data into Staging")
    print("=" * 80)
    print()
    print("⚠️  Note: BLOB data (allowed_restaurants) excluded - handled in Step 5")
    print()
    
    # Connect to databases
    print("📡 Connecting to databases...")
    mysql_conn = connect_mysql()
    mysql_cursor = mysql_conn.cursor()
    
    pg_conn = connect_postgres()
    pg_cursor = pg_conn.cursor()
    print()
    
    try:
        # Verify source
        print("🔍 Verifying source data...")
        source_count = verify_source_data(mysql_cursor)
        if source_count == 0:
            print("❌ No source data found")
            return
        print()
        
        # Clear staging (idempotent)
        print("🧹 Clearing staging table...")
        clear_staging_table(pg_cursor)
        pg_conn.commit()
        print()
        
        # Load data
        loaded_count = load_data(mysql_cursor, pg_cursor, pg_conn)
        
        # Verify staging
        verify_staging_data(pg_cursor)
        
        print()
        print("=" * 80)
        print("  SUMMARY")
        print("=" * 80)
        print(f"  Source records (V1):     {source_count}")
        print(f"  Loaded to staging:       {loaded_count}")
        print(f"  Success rate:            {(loaded_count/source_count)*100:.1f}%")
        print("=" * 80)
        print()
        print("✅ Step 1b complete!")
        print()
        print("📝 Next steps:")
        print("   - Run step1b_cleanup_staging.sql (optional normalization)")
        print("   - Run Step 2: transform_and_upsert.sql")
        print()
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        pg_conn.rollback()
        raise
    finally:
        mysql_cursor.close()
        mysql_conn.close()
        pg_cursor.close()
        pg_conn.close()
        print("📡 Database connections closed")

if __name__ == '__main__':
    # Check environment
    if not POSTGRES_URL:
        print("❌ Error: SUPABASE_DB_URL not set")
        print("\nUsage:")
        print("  export SUPABASE_DB_URL='postgresql://postgres:[password]@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres'")
        print("  export MYSQL_HOST='localhost'")
        print("  export MYSQL_USER='root'")
        print("  export MYSQL_PASSWORD='yourpass'")
        print("  export MYSQL_DATABASE='menuca_v1'")
        print("  python load_v1_data_to_staging.py")
        sys.exit(1)
    
    main()

