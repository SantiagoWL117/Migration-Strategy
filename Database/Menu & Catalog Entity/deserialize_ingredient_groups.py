#!/usr/bin/env python3
"""
Deserialize v1_ingredient_groups.item BLOB → Update ingredients with correct groups

Parses PHP serialized array of ingredient IDs and updates menu_v3.ingredients
to link them to their proper ingredient_groups.

Usage:
    python3 deserialize_ingredient_groups.py
"""

import os
import sys
import psycopg2

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

def deserialize_ingredient_list(blob_data):
    """
    Deserialize PHP serialized array of ingredient IDs
    
    Expected: a:N:{i:0;s:X:"ID1";i:1;s:Y:"ID2";...}
    Returns: [ID1, ID2, ...]
    """
    try:
        if isinstance(blob_data, str):
            # Fix MySQL escaping
            blob_data = blob_data.replace('\\"', '"').replace("\\'", "'")
            blob_data = blob_data.encode('utf-8')
        
        # Deserialize
        data = phpserialize.loads(blob_data)
        
        # Convert to list of integers
        if isinstance(data, dict):
            ingredient_ids = []
            for value in data.values():
                if isinstance(value, bytes):
                    value = value.decode('utf-8')
                try:
                    ingredient_ids.append(int(value))
                except (ValueError, TypeError):
                    continue
            return ingredient_ids
        
        return []
        
    except Exception as e:
        return []

def process_ingredient_groups(conn):
    """Process all ingredient_groups BLOBs"""
    cursor = conn.cursor()
    
    print("📊 Processing v1_ingredient_groups BLOBs...")
    print("=" * 80)
    
    # Fetch all groups with item data
    cursor.execute("""
        SELECT 
            id,
            restaurant_id,
            name,
            item
        FROM staging.v1_ingredient_groups
        WHERE item IS NOT NULL
          AND item != ''
        ORDER BY id
    """)
    
    rows = cursor.fetchall()
    total = len(rows)
    
    print(f"Total groups to process: {total:,}\n")
    
    successful = 0
    failed = 0
    group_mappings = {}  # {v1_group_id: [ingredient_ids]}
    total_ingredients = 0
    
    for i, (group_id, restaurant_id, name, item) in enumerate(rows, 1):
        if i % 500 == 0:
            print(f"  Progress: {i:,} / {total:,} ({i/total*100:.1f}%)")
        
        # Deserialize
        ingredient_ids = deserialize_ingredient_list(item)
        
        if ingredient_ids:
            group_mappings[group_id] = {
                'restaurant_id': restaurant_id,
                'name': name,
                'ingredient_ids': ingredient_ids
            }
            total_ingredients += len(ingredient_ids)
            successful += 1
        else:
            failed += 1
    
    print(f"\n✅ Deserialization complete:")
    print(f"   Successful: {successful:,}")
    print(f"   Failed: {failed:,}")
    print(f"   Total ingredient-group links: {total_ingredients:,}")
    
    cursor.close()
    return group_mappings

def update_ingredient_groups(conn, group_mappings):
    """Update ingredients with correct ingredient_group_id"""
    cursor = conn.cursor()
    
    print(f"\n📥 Updating ingredient groups...")
    print("=" * 80)
    
    updated = 0
    skipped = 0
    
    for v1_group_id, group_data in group_mappings.items():
        ingredient_ids = group_data['ingredient_ids']
        
        try:
            # Update ingredients to point to this group
            # Use source_id to map V1 ingredient IDs to V3
            sql = f"""
                UPDATE menu_v3.ingredients
                SET ingredient_group_id = {v1_group_id}
                WHERE source_system = 'v1'
                  AND source_id = ANY(ARRAY[{','.join(map(str, ingredient_ids))}])
            """
            
            cursor.execute(sql)
            batch_updated = cursor.rowcount
            updated += batch_updated
            
            if batch_updated < len(ingredient_ids):
                skipped += (len(ingredient_ids) - batch_updated)
            
        except Exception as e:
            print(f"⚠️  Error updating group {v1_group_id}: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    
    print(f"\n✅ Update complete:")
    print(f"   Updated: {updated:,} ingredients")
    print(f"   Skipped: {skipped:,} (not found in V3)")
    
    cursor.close()
    return updated

def verify_results(conn):
    """Verify the grouped ingredients"""
    cursor = conn.cursor()
    
    print("\n" + "=" * 80)
    print("🔍 VERIFICATION")
    print("=" * 80)
    
    # Group distribution
    cursor.execute("""
        SELECT 
            ingredient_group_id,
            COUNT(*) as ingredient_count
        FROM menu_v3.ingredients
        GROUP BY ingredient_group_id
        ORDER BY ingredient_count DESC
        LIMIT 10
    """)
    
    print("\nTop ingredient groups:")
    for group_id, count in cursor.fetchall():
        print(f"  Group {group_id}: {count:,} ingredients")
    
    # Ungrouped count
    cursor.execute("SELECT COUNT(*) FROM menu_v3.ingredients WHERE ingredient_group_id = 1")
    ungrouped = cursor.fetchone()[0]
    print(f"\nUngrouped ingredients: {ungrouped:,}")
    
    # Sample grouped ingredients
    cursor.execute("""
        SELECT 
            ig.id as group_id,
            ig.name as group_name,
            i.name as ingredient_name
        FROM menu_v3.ingredients i
        JOIN menu_v3.ingredient_groups ig ON ig.id = i.ingredient_group_id
        WHERE ig.id != 1
        LIMIT 10
    """)
    
    print("\nSample grouped ingredients:")
    for group_id, group_name, ingredient_name in cursor.fetchall():
        print(f"  [{group_id}] {group_name}: {ingredient_name}")
    
    cursor.close()

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 V1_INGREDIENT_GROUPS BLOB DESERIALIZATION")
    print("=" * 80)
    
    # Connect
    password = get_db_password()
    conn = connect_to_database(password)
    
    try:
        # Process BLOBs
        group_mappings = process_ingredient_groups(conn)
        
        # Update ingredients
        if group_mappings:
            update_ingredient_groups(conn, group_mappings)
            verify_results(conn)
        else:
            print("❌ No group mappings to apply")
            return 1
        
        print("\n" + "=" * 80)
        print("✅ SUCCESS! Ingredient groups updated")
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

