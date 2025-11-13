#!/usr/bin/env python3
"""
Add missing restaurants from List 4 to the database.
Inserts into menuca_v3.restaurants and menuca_v3.restaurant_locations.
"""
from database import DatabaseManager
from config import SCHEMA
import sys

def safe_print(text):
    """Print text safely handling Unicode encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        safe_text = text.encode('ascii', 'replace').decode('ascii')
        print(safe_text)

# Restaurants to add (excluding Dépanneur Généreux which already exists as ID 816)
restaurants_to_add = [
    {
        "name": "Econo Pizza",
        "address": "425, boul La Vérendrye E",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Lemongrass Thai Cuisine",
        "address": "331 Elgin St",
        "city": "Ottawa",
        "province": "ON"
    },
    {
        "name": "Mozza Pizza Gatineau",
        "address": "425, boul La Vérendrye E",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Papa Pizza Des Flandres",
        "address": "22, rue des Flandres",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Papa Pizza Maloney",
        "address": "253, boul Maloney",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Papa Pizza Val-Des-Monts",
        "address": "1797, rte du Carrefour",
        "city": "Val-des-Monts",
        "province": "QC"
    },
    {
        "name": "Poutinerie Québecurds Gatineau",
        "address": "643 Boulevard Saint-René O",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Roulas Grecque et Pizza",
        "address": "245, rue de Cannes",
        "city": "Gatineau",
        "province": "QC"
    },
    {
        "name": "Sushi Express Chambly",
        "address": "886 ch de Chambly",
        "city": "Chambly",
        "province": "QC"
    }
]

def main():
    safe_print("=" * 100)
    safe_print("ADDING MISSING RESTAURANTS TO DATABASE")
    safe_print("=" * 100)
    
    db = DatabaseManager()
    db.connect()
    
    inserted_restaurants = []
    
    try:
        for idx, restaurant in enumerate(restaurants_to_add, 1):
            safe_print(f"\n[{idx}/{len(restaurants_to_add)}] Processing: {restaurant['name']}")
            
            # Check if restaurant already exists
            check_query = f"""
                SELECT id, name 
                FROM {SCHEMA}.restaurants 
                WHERE LOWER(name) = LOWER(%s)
            """
            db.cursor.execute(check_query, (restaurant['name'],))
            existing = db.cursor.fetchone()
            
            if existing:
                safe_print(f"  [SKIP] Restaurant already exists (ID: {existing['id']})")
                inserted_restaurants.append({
                    'name': restaurant['name'],
                    'db_id': existing['id'],
                    'status': 'existing'
                })
                continue
            
            # Insert restaurant
            insert_restaurant_query = f"""
                INSERT INTO {SCHEMA}.restaurants (
                    name,
                    status,
                    created_at,
                    updated_at
                )
                VALUES (%s, 'pending', NOW(), NOW())
                RETURNING id
            """
            
            db.cursor.execute(insert_restaurant_query, (restaurant['name'],))
            result = db.cursor.fetchone()
            restaurant_id = result['id']
            
            safe_print(f"  [OK] Inserted restaurant (ID: {restaurant_id})")
            
            # Insert restaurant location
            insert_location_query = f"""
                INSERT INTO {SCHEMA}.restaurant_locations (
                    restaurant_id,
                    street_address,
                    created_at,
                    updated_at
                )
                VALUES (%s, %s, NOW(), NOW())
                RETURNING id
            """
            
            db.cursor.execute(insert_location_query, (restaurant_id, restaurant['address']))
            location_result = db.cursor.fetchone()
            location_id = location_result['id']
            
            safe_print(f"  [OK] Inserted location (ID: {location_id})")
            safe_print(f"  Address: {restaurant['address']}")
            
            # Commit after each restaurant
            db.conn.commit()
            
            inserted_restaurants.append({
                'name': restaurant['name'],
                'db_id': restaurant_id,
                'address': restaurant['address'],
                'status': 'inserted'
            })
        
        # Summary
        safe_print("\n" + "=" * 100)
        safe_print("SUMMARY")
        safe_print("=" * 100)
        
        new_count = sum(1 for r in inserted_restaurants if r['status'] == 'inserted')
        existing_count = sum(1 for r in inserted_restaurants if r['status'] == 'existing')
        
        safe_print(f"\nTotal restaurants processed: {len(restaurants_to_add)}")
        safe_print(f"  Newly inserted: {new_count}")
        safe_print(f"  Already existing: {existing_count}")
        
        safe_print("\n" + "-" * 100)
        safe_print("INSERTED RESTAURANTS:")
        safe_print("-" * 100)
        
        for r in inserted_restaurants:
            if r['status'] == 'inserted':
                safe_print(f"  [{r['db_id']:>4}] {r['name']}")
                safe_print(f"         {r['address']}")
        
        if existing_count > 0:
            safe_print("\n" + "-" * 100)
            safe_print("EXISTING RESTAURANTS (SKIPPED):")
            safe_print("-" * 100)
            
            for r in inserted_restaurants:
                if r['status'] == 'existing':
                    safe_print(f"  [{r['db_id']:>4}] {r['name']}")
        
        safe_print("\n" + "=" * 100)
        safe_print("[SUCCESS] All restaurants processed")
        safe_print("=" * 100)
        
        safe_print("\nNOTE: These restaurants still need CRM IDs (legacy_v1_id) to be scraped.")
        safe_print("You will need to manually find them in menuadmin.menu.ca and update the database.")
        
    except Exception as e:
        db.conn.rollback()
        safe_print(f"\n[ERROR] Failed to insert restaurants: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    finally:
        db.close()

if __name__ == "__main__":
    main()

