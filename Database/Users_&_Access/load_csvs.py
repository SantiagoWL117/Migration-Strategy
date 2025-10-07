#!/usr/bin/env python3
"""
Load Users & Access CSV files into Supabase staging tables
"""
import psycopg2
import csv
import sys
from datetime import datetime

# Configuration
PASSWORD = "Gz35CPTom1RnsmGM"
HOST = "db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE = "postgres"
USER = "postgres"
PORT = 5432
CSV_DIR = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV"

def connect():
    """Create database connection"""
    return psycopg2.connect(
        host=HOST,
        port=PORT,
        database=DATABASE,
        user=USER,
        password=PASSWORD
    )

def load_csv(conn, table, csv_file, delimiter=','):
    """Load a CSV file into a staging table"""
    print(f"📥 Loading: {csv_file} → staging.{table}")
    
    csv_path = f"{CSV_DIR}/{csv_file}"
    cursor = conn.cursor()
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            # Skip header row
            next(f)
            
            # Use COPY for fast bulk insert
            cursor.copy_expert(
                f"COPY staging.{table} FROM STDIN WITH (FORMAT CSV, DELIMITER '{delimiter}', NULL '', ENCODING 'UTF8')",
                f
            )
        
        conn.commit()
        
        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM staging.{table}")
        count = cursor.fetchone()[0]
        print(f"   ✅ Total rows in staging.{table}: {count:,}")
        return count
        
    except Exception as e:
        conn.rollback()
        print(f"   ❌ Error: {e}")
        return 0
    finally:
        cursor.close()

def execute_sql(conn, sql, description=""):
    """Execute SQL and return result"""
    if description:
        print(f"🔍 {description}")
    
    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        conn.commit()
        
        # Get row count if it's a SELECT
        if sql.strip().upper().startswith('SELECT'):
            return cursor.fetchall()
        else:
            return cursor.rowcount
    except Exception as e:
        conn.rollback()
        print(f"   ❌ Error: {e}")
        return None
    finally:
        cursor.close()

def main():
    print("=" * 70)
    print("Loading CSVs into Supabase staging tables...")
    print("=" * 70)
    print()
    
    # Connect to database
    print("🔌 Connecting to Supabase...")
    try:
        conn = connect()
        print("   ✅ Connected successfully!")
        print()
    except Exception as e:
        print(f"   ❌ Connection failed: {e}")
        sys.exit(1)
    
    # ================================================================
    # Load V1 Tables
    # ================================================================
    print("Loading V1 Tables (delimiter: semicolon)")
    print("-" * 70)
    
    # V1 Users (4 parts)
    print("📦 Loading V1 users (4 CSV files)...")
    v1_total = 0
    v1_total += load_csv(conn, "v1_users", "menuca_v1_users.csv", ";")
    v1_total += load_csv(conn, "v1_users", "menuca_v1_users_part1.csv", ";")
    v1_total += load_csv(conn, "v1_users", "menuca_v1_users_part2.csv", ";")
    v1_total += load_csv(conn, "v1_users", "menuca_v1_users_part3.csv", ";")
    print(f"   📊 Total V1 users loaded: {v1_total:,}")
    print()
    
    # V1 Callcenter
    load_csv(conn, "v1_callcenter_users", "menuca_v1_callcenter_users.csv", ";")
    print()
    
    # ================================================================
    # Apply Active User Filter to V1
    # ================================================================
    print("🔍 Filtering V1 users (active only: lastLogin > 2020-01-01)...")
    
    # Create backup
    execute_sql(conn, """
        DROP TABLE IF EXISTS staging.v1_users_excluded CASCADE;
        CREATE TABLE staging.v1_users_excluded AS
        SELECT *, 'inactive_old_login'::TEXT as exclusion_reason, NOW() as excluded_at
        FROM staging.v1_users
        WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';
    """)
    
    # Delete inactive users
    excluded = execute_sql(conn, """
        DELETE FROM staging.v1_users 
        WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';
    """)
    
    # Get counts
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM staging.v1_users")
    active = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM staging.v1_users_excluded")
    excluded_count = cursor.fetchone()[0]
    cursor.close()
    
    print(f"   ✅ Active users kept: {active:,}")
    print(f"   📦 Inactive users excluded: {excluded_count:,} (backed up)")
    print()
    
    # ================================================================
    # Load V2 Tables
    # ================================================================
    print("Loading V2 Tables (delimiter: comma)")
    print("-" * 70)
    
    load_csv(conn, "v2_site_users", "menuca_v2_site_users.csv")
    load_csv(conn, "v2_admin_users", "menuca_v2_admin_users.csv")
    load_csv(conn, "v2_admin_users_restaurants", "menuca_v2_admin_users_restaurants.csv")
    load_csv(conn, "v2_site_users_delivery_addresses", "menuca_v2_site_users_delivery_addresses.csv")
    print()
    
    # V2 reset codes with filtering
    print("📥 Loading: menuca_v2_reset_codes.csv → staging.v2_reset_codes")
    load_csv(conn, "v2_reset_codes", "menuca_v2_reset_codes.csv")
    
    print("🔍 Filtering reset codes (active only: expires_at > NOW())...")
    execute_sql(conn, """
        DROP TABLE IF EXISTS staging.v2_reset_codes_excluded CASCADE;
        CREATE TABLE staging.v2_reset_codes_excluded AS
        SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
        FROM staging.v2_reset_codes
        WHERE expires_at IS NULL OR expires_at <= NOW();
    """)
    
    execute_sql(conn, """
        DELETE FROM staging.v2_reset_codes
        WHERE expires_at IS NULL OR expires_at <= NOW();
    """)
    
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM staging.v2_reset_codes")
    active_tokens = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM staging.v2_reset_codes_excluded")
    expired_tokens = cursor.fetchone()[0]
    cursor.close()
    
    print(f"   ✅ Active tokens: {active_tokens:,}")
    print(f"   📦 Expired tokens excluded: {expired_tokens:,}")
    print()
    
    # V2 autologin tokens with filtering
    print("📥 Loading: menuca_v2_site_users_autologins.csv → staging.v2_site_users_autologins")
    load_csv(conn, "v2_site_users_autologins", "menuca_v2_site_users_autologins.csv")
    
    print("🔍 Filtering autologin tokens (active only: expire > NOW())...")
    execute_sql(conn, """
        DROP TABLE IF EXISTS staging.v2_site_users_autologins_excluded CASCADE;
        CREATE TABLE staging.v2_site_users_autologins_excluded AS
        SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
        FROM staging.v2_site_users_autologins
        WHERE expire IS NULL OR expire <= NOW();
    """)
    
    execute_sql(conn, """
        DELETE FROM staging.v2_site_users_autologins
        WHERE expire IS NULL OR expire <= NOW();
    """)
    
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM staging.v2_site_users_autologins")
    active_auto = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM staging.v2_site_users_autologins_excluded")
    expired_auto = cursor.fetchone()[0]
    cursor.close()
    
    print(f"   ✅ Active autologin tokens: {active_auto:,}")
    print(f"   📦 Expired tokens excluded: {expired_auto:,}")
    print()
    
    # Load remaining V2 tables
    load_csv(conn, "v2_site_users_favorite_restaurants", "menuca_v2_site_users_favorite_restaurants.csv")
    load_csv(conn, "v2_site_users_fb", "menuca_v2_site_users_fb.csv")
    print()
    
    # ================================================================
    # Final Summary
    # ================================================================
    print("=" * 70)
    print("✅ CSV LOADING COMPLETE!")
    print("=" * 70)
    print()
    print("Summary of loaded data:")
    print()
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            'V1 users (active only)' as table_name, 
            COUNT(*) as row_count,
            'FILTERED: lastLogin > 2020-01-01' as notes
        FROM staging.v1_users
        UNION ALL
        SELECT 'V1 users (excluded)', COUNT(*), 'Backup of inactive users'
        FROM staging.v1_users_excluded
        UNION ALL
        SELECT 'V1 callcenter_users', COUNT(*), 'All staff accounts'
        FROM staging.v1_callcenter_users
        UNION ALL
        SELECT 'V2 site_users', COUNT(*), 'All V2 users (all active)'
        FROM staging.v2_site_users
        UNION ALL
        SELECT 'V2 admin_users', COUNT(*), 'Platform admins'
        FROM staging.v2_admin_users
        UNION ALL
        SELECT 'V2 admin_users_restaurants', COUNT(*), 'Admin-restaurant junction'
        FROM staging.v2_admin_users_restaurants
        UNION ALL
        SELECT 'V2 delivery_addresses', COUNT(*), 'User saved addresses'
        FROM staging.v2_site_users_delivery_addresses
        UNION ALL
        SELECT 'V2 reset_codes (active)', COUNT(*), 'FILTERED: expires_at > NOW()'
        FROM staging.v2_reset_codes
        UNION ALL
        SELECT 'V2 reset_codes (excluded)', COUNT(*), 'Backup of expired tokens'
        FROM staging.v2_reset_codes_excluded
        UNION ALL
        SELECT 'V2 autologins (active)', COUNT(*), 'FILTERED: expire > NOW()'
        FROM staging.v2_site_users_autologins
        UNION ALL
        SELECT 'V2 autologins (excluded)', COUNT(*), 'Backup of expired tokens'
        FROM staging.v2_site_users_autologins_excluded
        UNION ALL
        SELECT 'V2 favorite_restaurants', COUNT(*), 'User favorites'
        FROM staging.v2_site_users_favorite_restaurants
        UNION ALL
        SELECT 'V2 fb_profiles', COUNT(*), 'Facebook OAuth'
        FROM staging.v2_site_users_fb
        ORDER BY table_name;
    """)
    
    results = cursor.fetchall()
    for row in results:
        print(f"{row[0]:40} {row[1]:>10,} rows    {row[2]}")
    
    cursor.close()
    conn.close()
    
    print()
    print("=" * 70)
    print("Next step: Run data quality assessment via MCP")
    print("=" * 70)

if __name__ == "__main__":
    main()
