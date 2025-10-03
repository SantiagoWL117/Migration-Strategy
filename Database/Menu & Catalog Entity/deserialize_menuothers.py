#!/usr/bin/env python3
"""
Deserialize v1_menuothers BLOB Data → dish_modifiers

Parses PHP serialized data to extract dish-specific modifier pricing
and populates the menu_v3.dish_modifiers junction table.

Usage:
    python3 deserialize_menuothers.py
"""

import os
import sys
import psycopg2
import json
from datetime import datetime

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

def deserialize_php_blob(blob_data):
    """
    Deserialize PHP serialized BLOB
    
    Expected structure:
    {
        'content': {ingredient_id: price, ...},
        'radio': group_id
    }
    """
    try:
        # Handle byte strings
        if isinstance(blob_data, str):
            # Fix MySQL quote escaping: \" → " and \' → '
            # The data has literal backslash-quote, not the phpserialize expected format
            blob_data = blob_data.replace('\\"', '"').replace("\\'", "'")
            blob_data = blob_data.encode('utf-8')
        
        # Deserialize
        data = phpserialize.loads(blob_data)
        
        # Convert byte strings to regular strings
        if isinstance(data, dict):
            result = {}
            for key, value in data.items():
                key_str = key.decode('utf-8') if isinstance(key, bytes) else str(key)
                
                if key_str == 'content' and isinstance(value, dict):
                    # Convert ingredient prices
                    result['content'] = {
                        int(k): v.decode('utf-8') if isinstance(v, bytes) else str(v)
                        for k, v in value.items()
                    }
                elif key_str == 'radio':
                    result['radio'] = value.decode('utf-8') if isinstance(value, bytes) else str(value)
                else:
                    result[key_str] = value
            
            return result
        
        return None
        
    except Exception as e:
        print(f"⚠️  Deserialization error: {e}")
        return None

def process_menuothers(conn):
    """Process all menuothers BLOBs"""
    cursor = conn.cursor()
    
    print("📊 Processing v1_menuothers BLOBs...")
    print("=" * 80)
    
    # Fetch all menuothers with content
    cursor.execute("""
        SELECT 
            id,
            restaurant_id,
            dish_id,
            type,
            group_id,
            content
        FROM staging.v1_menuothers
        WHERE content IS NOT NULL
          AND content != ''
        ORDER BY id
    """)
    
    rows = cursor.fetchall()
    total = len(rows)
    
    print(f"Total BLOBs to process: {total:,}\n")
    
    successful = 0
    failed = 0
    dish_modifiers = []
    
    for i, (id, restaurant_id, dish_id, type_code, group_id, content) in enumerate(rows, 1):
        if i % 5000 == 0:
            print(f"  Progress: {i:,} / {total:,} ({i/total*100:.1f}%)")
        
        # Deserialize
        parsed = deserialize_php_blob(content)
        
        if parsed and 'content' in parsed:
            # Extract ingredient prices
            ingredient_prices = parsed['content']
            
            for ingredient_id, price in ingredient_prices.items():
                # Map V1 ingredient_id to V3 ingredient_id
                # V1 IDs are stored in source_id column
                dish_modifiers.append({
                    'dish_id': dish_id,
                    'ingredient_id': ingredient_id,  # Will map using source_id
                    'ingredient_group_id': group_id,
                    'price': price,
                    'type': type_code,
                    'source_system': 'v1',
                    'source_id': id
                })
            
            successful += 1
        else:
            failed += 1
    
    print(f"\n✅ Deserialization complete:")
    print(f"   Successful: {successful:,}")
    print(f"   Failed: {failed:,}")
    print(f"   Total dish-modifier links: {len(dish_modifiers):,}")
    
    cursor.close()
    return dish_modifiers

def insert_dish_modifiers(conn, dish_modifiers):
    """Insert dish modifiers into menu_v3.dish_modifiers"""
    cursor = conn.cursor()
    
    print(f"\n📥 Inserting {len(dish_modifiers):,} dish modifiers...")
    print("=" * 80)
    
    # Batch insert
    batch_size = 1000
    inserted = 0
    errors = 0
    skipped_fk = 0
    
    for i in range(0, len(dish_modifiers), batch_size):
        batch = dish_modifiers[i:i+batch_size]
        
        try:
            # Build VALUES clause
            values = []
            for dm in batch:
                # Parse price - handle comma-separated multi-size prices
                price_str = str(dm['price'])
                
                if ',' in price_str:
                    # Multi-size prices: "1.00,2.00,3.00"
                    price_parts = [p.strip() for p in price_str.split(',') if p.strip() and p.strip() != '']
                    try:
                        price_array = [float(p) for p in price_parts]
                        price_json = json.dumps({'sizes': price_array})
                    except ValueError:
                        # Invalid format, skip
                        continue
                else:
                    # Single price
                    try:
                        price_json = json.dumps({'default': float(price_str)})
                    except ValueError:
                        # Invalid format, skip
                        continue
                
                # Map V1 ingredient_id to V3 id using source_id
                values.append(
                    f"({dm['dish_id']}, "
                    f"(SELECT id FROM menu_v3.ingredients WHERE source_system='v1' AND source_id={dm['ingredient_id']} LIMIT 1), "
                    f"{dm['ingredient_group_id']}, "
                    f"'{price_json}'::jsonb)"
                )
            
            # Skip empty batches
            if not values:
                continue
            
            # Insert batch with FK validation
            sql = f"""
                INSERT INTO menu_v3.dish_modifiers 
                    (dish_id, ingredient_id, ingredient_group_id, prices)
                SELECT * FROM (VALUES {','.join(values)}) AS t(dish_id, ingredient_id, ingredient_group_id, prices)
                WHERE ingredient_id IS NOT NULL
                  AND EXISTS (SELECT 1 FROM menu_v3.ingredient_groups WHERE id = t.ingredient_group_id)
                ON CONFLICT (dish_id, ingredient_id) DO UPDATE
                SET prices = EXCLUDED.prices
            """
            
            cursor.execute(sql)
            batch_inserted = cursor.rowcount
            inserted += batch_inserted
            skipped_fk += (len(values) - batch_inserted)
            
            if i % 10000 == 0 and i > 0:
                print(f"  Inserted: {inserted:,} / {len(dish_modifiers):,} (skipped {skipped_fk:,} FK violations)")
                
        except Exception as e:
            print(f"⚠️  Batch error: {e}")
            errors += len(batch)
            conn.rollback()
    
    conn.commit()
    
    print(f"\n✅ Insert complete:")
    print(f"   Inserted: {inserted:,}")
    print(f"   Skipped (FK violations): {skipped_fk:,}")
    print(f"   Errors: {errors:,}")
    
    cursor.close()
    return inserted

def verify_results(conn):
    """Verify the loaded data"""
    cursor = conn.cursor()
    
    print("\n" + "=" * 80)
    print("🔍 VERIFICATION")
    print("=" * 80)
    
    # Total count
    cursor.execute("SELECT COUNT(*) FROM menu_v3.dish_modifiers")
    total = cursor.fetchone()[0]
    print(f"Total dish_modifiers: {total:,}")
    
    # Unique dishes
    cursor.execute("SELECT COUNT(DISTINCT dish_id) FROM menu_v3.dish_modifiers")
    dishes = cursor.fetchone()[0]
    print(f"Unique dishes with modifiers: {dishes:,}")
    
    # Unique ingredients
    cursor.execute("SELECT COUNT(DISTINCT ingredient_id) FROM menu_v3.dish_modifiers")
    ingredients = cursor.fetchone()[0]
    print(f"Unique ingredients used: {ingredients:,}")
    
    # Sample data
    cursor.execute("""
        SELECT 
            dm.dish_id,
            d.name as dish_name,
            i.name as ingredient_name,
            dm.prices
        FROM menu_v3.dish_modifiers dm
        JOIN menu_v3.dishes d ON d.id = dm.dish_id
        JOIN menu_v3.ingredients i ON i.id = dm.ingredient_id
        LIMIT 5
    """)
    
    print("\nSample dish modifiers:")
    for row in cursor.fetchall():
        print(f"  Dish: {row[1]} → Ingredient: {row[2]} (${row[3]})")
    
    cursor.close()

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 V1_MENUOTHERS BLOB DESERIALIZATION")
    print("=" * 80)
    
    # Connect
    password = get_db_password()
    conn = connect_to_database(password)
    
    try:
        # Process BLOBs
        dish_modifiers = process_menuothers(conn)
        
        # Insert into database
        if dish_modifiers:
            insert_dish_modifiers(conn, dish_modifiers)
            verify_results(conn)
        else:
            print("❌ No dish modifiers to insert")
            return 1
        
        print("\n" + "=" * 80)
        print("✅ SUCCESS! Dish modifiers loaded")
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

