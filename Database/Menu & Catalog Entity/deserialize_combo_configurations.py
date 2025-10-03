#!/usr/bin/env python3
"""
Load combo_groups and deserialize v1_combo_groups.options BLOB → config JSONB

Parses PHP serialized combo configuration and stores as JSONB.

Usage:
    python3 deserialize_combo_configurations.py
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

def deserialize_combo_options(blob_data):
    """
    Deserialize PHP serialized combo configuration
    
    Expected structure:
    {
        "itemcount": "1",
        "ci": {"has": "Y", "min": "1", "max": "1", "free": "1", "order": "1"},
        "sauce": {"has": "Y", "min": "1", "max": "1", "free": "1", "order": "2"}
    }
    """
    try:
        if not blob_data or blob_data.strip() == '':
            return None
        
        if isinstance(blob_data, str):
            # Fix MySQL escaping
            blob_data = blob_data.replace('\\"', '"').replace("\\'", "'")
            blob_data = blob_data.encode('utf-8')
        
        # Deserialize
        data = phpserialize.loads(blob_data)
        
        # Convert to clean dict
        if isinstance(data, dict):
            config = {}
            for key, value in data.items():
                # Decode key
                if isinstance(key, bytes):
                    key = key.decode('utf-8')
                key_str = str(key)
                
                if isinstance(value, dict):
                    # Nested dict (ingredient group config)
                    nested = {}
                    for nk, nv in value.items():
                        if isinstance(nk, bytes):
                            nk = nk.decode('utf-8')
                        if isinstance(nv, bytes):
                            nv = nv.decode('utf-8')
                        nested[str(nk)] = str(nv)
                    config[key_str] = nested
                else:
                    # Simple value
                    if isinstance(value, bytes):
                        value = value.decode('utf-8')
                    config[key_str] = str(value)
            
            return config
        
        return None
        
    except Exception as e:
        return None

def load_missing_combo_groups(conn):
    """Load missing combo_groups from staging"""
    cursor = conn.cursor()
    
    print("📥 Loading missing combo_groups...")
    print("=" * 80)
    
    # Insert missing groups
    cursor.execute("""
        INSERT INTO menu_v3.combo_groups (
            id,
            restaurant_id,
            name,
            language
        )
        SELECT 
            v1.id,
            NULLIF(v1.restaurant_id, 0) AS restaurant_id,
            COALESCE(NULLIF(v1.name, ''), 'Combo ' || v1.id) AS name,
            COALESCE(NULLIF(v1.language, ''), 'en') AS language
        FROM staging.v1_combo_groups v1
        LEFT JOIN menu_v3.combo_groups cg ON cg.id = v1.id
        WHERE cg.id IS NULL
          AND v1.id IS NOT NULL
        ON CONFLICT (id) DO NOTHING
    """)
    
    loaded = cursor.rowcount
    conn.commit()
    
    print(f"✅ Loaded {loaded:,} missing combo_groups\n")
    
    cursor.close()
    return loaded

def process_combo_configurations(conn):
    """Process all combo options BLOBs"""
    cursor = conn.cursor()
    
    print("📊 Processing v1_combo_groups.options BLOBs...")
    print("=" * 80)
    
    # Fetch all combo_groups with options
    cursor.execute("""
        SELECT 
            id,
            restaurant_id,
            name,
            options
        FROM staging.v1_combo_groups
        WHERE options IS NOT NULL
          AND options != ''
        ORDER BY id
    """)
    
    rows = cursor.fetchall()
    total = len(rows)
    
    print(f"Total combos with configurations: {total:,}\n")
    
    successful = 0
    failed = 0
    configs = []
    
    for i, (combo_id, restaurant_id, name, options) in enumerate(rows, 1):
        if i % 1000 == 0:
            print(f"  Progress: {i:,} / {total:,} ({i/total*100:.1f}%)")
        
        # Deserialize
        config = deserialize_combo_options(options)
        
        if config:
            configs.append({
                'combo_id': combo_id,
                'config': config
            })
            successful += 1
        else:
            failed += 1
    
    print(f"\n✅ Deserialization complete:")
    print(f"   Successful: {successful:,}")
    print(f"   Failed: {failed:,}")
    
    cursor.close()
    return configs

def update_combo_configs(conn, configs):
    """Update combo_groups with config JSONB"""
    cursor = conn.cursor()
    
    print(f"\n📥 Updating {len(configs):,} combo configurations...")
    print("=" * 80)
    
    updated = 0
    skipped = 0
    
    batch_size = 500
    for i in range(0, len(configs), batch_size):
        batch = configs[i:i+batch_size]
        
        try:
            for cfg in batch:
                config_json = json.dumps(cfg['config'])
                
                sql = f"""
                    UPDATE menu_v3.combo_groups
                    SET config = '{config_json}'::jsonb
                    WHERE id = {cfg['combo_id']}
                """
                
                cursor.execute(sql)
                if cursor.rowcount > 0:
                    updated += 1
                else:
                    skipped += 1
            
            conn.commit()
            
            if i % 5000 == 0 and i > 0:
                print(f"  Updated: {updated:,} / {len(configs):,}")
                
        except Exception as e:
            print(f"⚠️  Batch error: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    
    print(f"\n✅ Update complete:")
    print(f"   Updated: {updated:,} combos")
    print(f"   Skipped: {skipped:,} (not found in V3)")
    
    cursor.close()
    return updated

def verify_results(conn):
    """Verify the configurations"""
    cursor = conn.cursor()
    
    print("\n" + "=" * 80)
    print("🔍 VERIFICATION")
    print("=" * 80)
    
    # Count total combo_groups
    cursor.execute("SELECT COUNT(*) FROM menu_v3.combo_groups")
    total = cursor.fetchone()[0]
    print(f"\nTotal combo_groups: {total:,}")
    
    # Count with configurations
    cursor.execute("""
        SELECT COUNT(*) 
        FROM menu_v3.combo_groups 
        WHERE config IS NOT NULL
    """)
    with_config = cursor.fetchone()[0]
    print(f"Combos with configurations: {with_config:,}")
    
    # Sample configurations
    cursor.execute("""
        SELECT 
            id,
            name,
            config
        FROM menu_v3.combo_groups
        WHERE config IS NOT NULL
        LIMIT 5
    """)
    
    print("\nSample combo configurations:")
    for combo_id, name, config in cursor.fetchall():
        print(f"  [{combo_id}] {name}:")
        if 'itemcount' in config:
            print(f"    Items: {config['itemcount']}")
        # Show ingredient group rules
        for key, value in config.items():
            if isinstance(value, dict) and 'has' in value:
                print(f"    Group '{key}': min={value.get('min','?')}, max={value.get('max','?')}, free={value.get('free','0')}")
    
    cursor.close()

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 COMBO GROUPS & CONFIGURATIONS LOADER")
    print("=" * 80)
    
    # Connect
    password = get_db_password()
    conn = connect_to_database(password)
    
    try:
        # Step 1: Load missing combo_groups
        load_missing_combo_groups(conn)
        
        # Step 2: Process BLOBs
        configs = process_combo_configurations(conn)
        
        # Step 3: Update configs
        if configs:
            update_combo_configs(conn, configs)
            verify_results(conn)
        else:
            print("❌ No configurations to update")
            return 1
        
        print("\n" + "=" * 80)
        print("✅ SUCCESS! Combo configurations loaded")
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

