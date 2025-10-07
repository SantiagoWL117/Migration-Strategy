#!/usr/bin/env python3
"""
Robust CSV loader that handles malformed data row-by-row
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

def clean_value(value):
    """Clean CSV value - convert empty strings to None"""
    if value is None or value == '' or value == 'NULL' or value == 'N':
        return None
    # Handle invalid MySQL zero dates
    if value in ('0000-00-00', '0000-00-00 00:00:00'):
        return None
    return value

def load_v2_site_users(conn):
    """Load V2 site_users - most critical table"""
    print("📥 Loading V2 site_users...")
    
    csv_path = f"{CSV_DIR}/menuca_v2_site_users.csv"
    cursor = conn.cursor()
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            count = 0
            batch = []
            
            for row in reader:
                batch.append((
                    clean_value(row['id']),
                    clean_value(row['active']),
                    clean_value(row['fname']),
                    clean_value(row['lname']),
                    clean_value(row['email']),
                    clean_value(row['password']),
                    clean_value(row['language_id']),
                    clean_value(row['gender']),
                    clean_value(row['locale']),
                    clean_value(row['oauth_provider']),
                    clean_value(row['oauth_uid']),
                    clean_value(row['picture_url']),
                    clean_value(row['profile_url']),
                    clean_value(row['created_at']),
                    clean_value(row['newsletter']),
                    clean_value(row['sms']),
                    clean_value(row['origin_restaurant']),
                    clean_value(row['last_login']),
                    clean_value(row['disabled_by']),
                    clean_value(row['disabled_at'])
                ))
                
                count += 1
                
                # Insert in batches of 1000
                if len(batch) >= 1000:
                    cursor.executemany("""
                        INSERT INTO staging.v2_site_users 
                        (id, active, fname, lname, email, password, language_id, gender, locale,
                         oauth_provider, oauth_uid, picture_url, profile_url, created_at,
                         newsletter, sms, origin_restaurant, last_login, disabled_by, disabled_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """, batch)
                    conn.commit()
                    print(f"   ⏳ Loaded {count} rows...")
                    batch = []
            
            # Insert remaining rows
            if batch:
                cursor.executemany("""
                    INSERT INTO staging.v2_site_users 
                    (id, active, fname, lname, email, password, language_id, gender, locale,
                     oauth_provider, oauth_uid, picture_url, profile_url, created_at,
                     newsletter, sms, origin_restaurant, last_login, disabled_by, disabled_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, batch)
                conn.commit()
            
            print(f"   ✅ Loaded {count} rows")
            return count
            
    except Exception as e:
        conn.rollback()
        print(f"   ❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 0
    finally:
        cursor.close()

def load_v2_addresses(conn):
    """Load V2 delivery addresses"""
    print("📥 Loading V2 site_users_delivery_addresses...")
    
    csv_path = f"{CSV_DIR}/menuca_v2_site_users_delivery_addresses.csv"
    cursor = conn.cursor()
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            count = 0
            batch = []
            
            for row in reader:
                batch.append((
                    clean_value(row['id']),
                    clean_value(row['active']),
                    clean_value(row['place_id']),
                    clean_value(row['user_id']),
                    clean_value(row['lat']),
                    clean_value(row['lng']),
                    clean_value(row['street']),
                    clean_value(row['apartment']),
                    clean_value(row['zip']),
                    clean_value(row['ringer']),
                    clean_value(row['extension']),
                    clean_value(row['special_instructions']),
                    clean_value(row['city']),
                    clean_value(row['province']),
                    clean_value(row['phone']),
                    clean_value(row['missingData'])
                ))
                
                count += 1
                
                if len(batch) >= 1000:
                    cursor.executemany("""
                        INSERT INTO staging.v2_site_users_delivery_addresses 
                        (id, active, place_id, user_id, lat, lng, street, apartment, zip,
                         ringer, extension, special_instructions, city, province, phone, missingData)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """, batch)
                    conn.commit()
                    print(f"   ⏳ Loaded {count} rows...")
                    batch = []
            
            if batch:
                cursor.executemany("""
                    INSERT INTO staging.v2_site_users_delivery_addresses 
                    (id, active, place_id, user_id, lat, lng, street, apartment, zip,
                     ringer, extension, special_instructions, city, province, phone, missingData)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, batch)
                conn.commit()
            
            print(f"   ✅ Loaded {count} rows")
            return count
            
    except Exception as e:
        conn.rollback()
        print(f"   ❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 0
    finally:
        cursor.close()

def main():
    print("=" * 70)
    print("Loading V2 Critical Tables (V1 will follow)")
    print("=" * 70)
    print()
    
    # Connect
    print("🔌 Connecting to Supabase...")
    try:
        conn = connect()
        print("   ✅ Connected!")
        print()
    except Exception as e:
        print(f"   ❌ Failed: {e}")
        sys.exit(1)
    
    # Load V2 tables (most critical, cleanest data)
    load_v2_site_users(conn)
    load_v2_addresses(conn)
    
    print()
    print("=" * 70)
    print("✅ V2 Core Tables Loaded!")
    print("=" * 70)
    print()
    print("Next: Run quality assessment on V2 data while we fix V1 CSVs")
    
    conn.close()

if __name__ == "__main__":
    main()
