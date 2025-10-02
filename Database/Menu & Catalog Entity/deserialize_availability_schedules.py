#!/usr/bin/env python3
"""
Deserialize v1_menu.hideondays BLOB → Update dishes with availability schedules

Parses PHP serialized array of hidden days and creates JSONB availability schedules.

Usage:
    python3 deserialize_availability_schedules.py
"""

import os
import sys
import psycopg2
import json

try:
    import phpserialize
except ImportError:
    print("❌ phpserialize not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--break-system-packages", "phpserialize"])
    import phpserialize

# Configuration
CONNECTION_STRING = "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:[YOUR-PASSWORD]@aws-1-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"

DAY_MAP = {
    'sun': 'sunday',
    'mon': 'monday',
    'tue': 'tuesday',
    'wed': 'wednesday',
    'thu': 'thursday',
    'fri': 'friday',
    'sat': 'saturday'
}

def get_db_password():
    """Get database password from environment"""
    password = os.environ.get('SUPABASE_DB_PASSWORD')
    if not password:
        print("❌ Error: SUPABASE_DB_PASSWORD environment variable not set")
        sys.exit(1)
    return password

def connect_to_database(password):
    """Connect to Supabase"""
    connection_string = CONNECTION_STRING.replace('[YOUR-PASSWORD]', password)
    
    try:
        print("🔌 Connecting to Supabase...")
        conn = psycopg2.connect(connection_string)
        conn.autocommit = False
        print("✅ Connected!\n")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)

def deserialize_hidden_days(blob_data):
    """
    Deserialize PHP serialized array of hidden day codes
    
    Expected: a:N:{i:0;s:3:"sun";i:1;s:3:"mon";...}
    Returns: ['sunday', 'monday', ...]
    """
    try:
        if not blob_data or blob_data == 'N;' or blob_data.strip() == '':
            return []
        
        if isinstance(blob_data, str):
            # Fix MySQL escaping
            blob_data = blob_data.replace('\\"', '"').replace("\\'", "'")
            blob_data = blob_data.encode('utf-8')
        
        # Deserialize
        data = phpserialize.loads(blob_data)
        
        # Convert to list of full day names
        if isinstance(data, dict):
            hidden_days = []
            for value in data.values():
                if isinstance(value, bytes):
                    value = value.decode('utf-8')
                day_code = str(value).lower()[:3]
                if day_code in DAY_MAP:
                    hidden_days.append(DAY_MAP[day_code])
            return hidden_days
        
        return []
        
    except Exception as e:
        return []

def create_availability_schedule(hidden_days):
    """
    Create JSONB availability schedule from hidden days
    
    Format: {
        "sunday": false,    // Hidden
        "monday": true,     // Available
        ...
    }
    """
    all_days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
    schedule = {}
    
    for day in all_days:
        schedule[day] = day not in hidden_days
    
    return schedule

def process_availability_schedules(conn):
    """Process all hideondays BLOBs"""
    cursor = conn.cursor()
    
    print("📊 Processing v1_menu.hideondays BLOBs...")
    print("=" * 80)
    
    # Fetch all dishes with hideondays data
    cursor.execute("""
        SELECT 
            id,
            restaurant,
            name,
            hideondays
        FROM staging.v1_menu
        WHERE hideondays IS NOT NULL
          AND hideondays != ''
          AND hideondays != 'N;'
        ORDER BY id
    """)
    
    rows = cursor.fetchall()
    total = len(rows)
    
    print(f"Total dishes with schedules: {total:,}\n")
    
    successful = 0
    failed = 0
    schedules = []
    
    for i, (dish_id, restaurant, name, hideondays) in enumerate(rows, 1):
        if i % 200 == 0:
            print(f"  Progress: {i:,} / {total:,} ({i/total*100:.1f}%)")
        
        # Deserialize
        hidden_days = deserialize_hidden_days(hideondays)
        
        if hidden_days or hidden_days == []:  # Even empty is valid (always available)
            schedule = create_availability_schedule(hidden_days)
            schedules.append({
                'dish_id': dish_id,
                'schedule': schedule,
                'hidden_days': hidden_days
            })
            successful += 1
        else:
            failed += 1
    
    print(f"\n✅ Deserialization complete:")
    print(f"   Successful: {successful:,}")
    print(f"   Failed: {failed:,}")
    
    cursor.close()
    return schedules

def update_dish_schedules(conn, schedules):
    """Update dishes with availability schedules"""
    cursor = conn.cursor()
    
    print(f"\n📥 Updating {len(schedules):,} dish schedules...")
    print("=" * 80)
    
    updated = 0
    skipped = 0
    
    for i, sched in enumerate(schedules, 1):
        try:
            schedule_json = json.dumps(sched['schedule'])
            
            # Update dish using V1 ID mapping
            sql = f"""
                UPDATE menu_v3.dishes
                SET availability_schedule = '{schedule_json}'::jsonb
                WHERE id = {sched['dish_id']}
            """
            
            cursor.execute(sql)
            if cursor.rowcount > 0:
                updated += 1
            else:
                skipped += 1
            
            if i % 200 == 0:
                conn.commit()
                print(f"  Updated: {updated:,} / {len(schedules):,}")
            
        except Exception as e:
            print(f"⚠️  Error updating dish {sched['dish_id']}: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    
    print(f"\n✅ Update complete:")
    print(f"   Updated: {updated:,} dishes")
    print(f"   Skipped: {skipped:,} (not found in V3)")
    
    cursor.close()
    return updated

def verify_results(conn):
    """Verify the schedules"""
    cursor = conn.cursor()
    
    print("\n" + "=" * 80)
    print("🔍 VERIFICATION")
    print("=" * 80)
    
    # Count dishes with schedules
    cursor.execute("""
        SELECT COUNT(*) 
        FROM menu_v3.dishes 
        WHERE availability_schedule IS NOT NULL
    """)
    total = cursor.fetchone()[0]
    print(f"\nDishes with availability schedules: {total:,}")
    
    # Sample schedules
    cursor.execute("""
        SELECT 
            id,
            name,
            availability_schedule
        FROM menu_v3.dishes
        WHERE availability_schedule IS NOT NULL
        LIMIT 5
    """)
    
    print("\nSample schedules:")
    for dish_id, name, schedule in cursor.fetchall():
        hidden = [day for day, available in schedule.items() if not available]
        if hidden:
            print(f"  [{dish_id}] {name}: Hidden on {', '.join(hidden)}")
        else:
            print(f"  [{dish_id}] {name}: Always available")
    
    cursor.close()

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 V1_MENU.HIDEONDAYS BLOB DESERIALIZATION")
    print("=" * 80)
    
    # Connect
    password = get_db_password()
    conn = connect_to_database(password)
    
    try:
        # Process BLOBs
        schedules = process_availability_schedules(conn)
        
        # Update dishes
        if schedules:
            update_dish_schedules(conn, schedules)
            verify_results(conn)
        else:
            print("❌ No schedules to update")
            return 1
        
        print("\n" + "=" * 80)
        print("✅ SUCCESS! Availability schedules loaded")
        print("=" * 80)
        
        return 0
        
    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    finally:
        conn.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    sys.exit(main())

