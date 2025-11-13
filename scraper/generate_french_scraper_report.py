"""
Generate comprehensive report of French scraper results for both Phase 1 and Phase 2.
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA
from datetime import datetime

# French restaurant database IDs
FRENCH_RESTAURANT_IDS = [
    816, 743, 736, 798, 727, 825, 614, 615, 35, 644,
    681, 797, 822, 810, 540, 616, 602, 795, 712, 570,
    562, 726, 696, 716, 777, 820
]

def main():
    db = DatabaseManager()
    db.connect()
    
    try:
        print("\n" + "="*100)
        print("FRENCH MENU SCRAPER - COMPREHENSIVE REPORT")
        print("="*100)
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Total French Restaurants: {len(FRENCH_RESTAURANT_IDS)}")
        print("="*100)
        
        ids_str = ','.join(map(str, FRENCH_RESTAURANT_IDS))
        
        # Query for all restaurant data
        query = f"""
            SELECT 
                r.id as restaurant_id,
                r.name as restaurant_name,
                r.legacy_v1_id as crm_id,
                (SELECT COUNT(*) FROM {SCHEMA}.courses WHERE restaurant_id = r.id AND deleted_at IS NULL) as courses_count,
                (SELECT COUNT(*) FROM {SCHEMA}.dishes WHERE restaurant_id = r.id AND deleted_at IS NULL AND source_id IS NOT NULL) as dishes_count,
                (SELECT COUNT(*) 
                 FROM {SCHEMA}.dish_prices dp
                 JOIN {SCHEMA}.dishes d ON dp.dish_id = d.id
                 WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL AND d.source_id IS NOT NULL) as dish_prices_count,
                (SELECT COUNT(*) 
                 FROM {SCHEMA}.modifier_groups mg
                 JOIN {SCHEMA}.dishes d ON mg.dish_id = d.id
                 WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL AND d.source_id IS NOT NULL) as modifier_groups_count,
                (SELECT COUNT(*) 
                 FROM {SCHEMA}.dish_modifiers dm
                 WHERE dm.restaurant_id = r.id) as modifier_items_count,
                (SELECT COUNT(*) 
                 FROM {SCHEMA}.dish_modifier_prices dmp
                 WHERE dmp.restaurant_id = r.id) as modifier_prices_count
            FROM {SCHEMA}.restaurants r
            WHERE r.id IN ({ids_str})
              AND r.deleted_at IS NULL
            ORDER BY r.id
        """
        
        db.cursor.execute(query)
        results = db.cursor.fetchall()
        
        # Print header
        print(f"\n{'Restaurant Name':<35} {'DB':<5} {'CRM':<6} {'Courses':<8} {'Dishes':<8} {'Prices':<8} {'MG':<6} {'MI':<8} {'MP':<8} {'Status':<10}")
        print("-"*100)
        
        total_courses = 0
        total_dishes = 0
        total_prices = 0
        total_modifier_groups = 0
        total_modifier_items = 0
        total_modifier_prices = 0
        successful_count = 0
        
        for row in results:
            restaurant_id = row['restaurant_id']
            restaurant_name = row['restaurant_name']
            crm_id = row['crm_id'] or 'N/A'
            courses = row['courses_count']
            dishes = row['dishes_count']
            prices = row['dish_prices_count']
            mod_groups = row['modifier_groups_count']
            mod_items = row['modifier_items_count']
            mod_prices = row['modifier_prices_count']
            
            # Determine status
            if dishes > 0:
                status = "SUCCESS"
                successful_count += 1
            else:
                status = "NO DATA"
            
            # Truncate long names
            display_name = restaurant_name[:34] if len(restaurant_name) <= 34 else restaurant_name[:31] + "..."
            
            print(f"{display_name:<35} {restaurant_id:<5} {crm_id:<6} {courses:<8} {dishes:<8} {prices:<8} {mod_groups:<6} {mod_items:<8} {mod_prices:<8} {status:<10}")
            
            total_courses += courses
            total_dishes += dishes
            total_prices += prices
            total_modifier_groups += mod_groups
            total_modifier_items += mod_items
            total_modifier_prices += mod_prices
        
        # Print totals
        print("="*100)
        print(f"{'TOTALS':<35} {'':5} {'':6} {total_courses:<8} {total_dishes:<8} {total_prices:<8} {total_modifier_groups:<6} {total_modifier_items:<8} {total_modifier_prices:<8} {successful_count}/{len(results)}")
        print("="*100)
        
        # Summary statistics
        print("\n" + "="*100)
        print("SUMMARY STATISTICS")
        print("="*100)
        print(f"Total Restaurants Processed: {len(results)}")
        print(f"Successfully Scraped: {successful_count}")
        print(f"Failed/No Data: {len(results) - successful_count}")
        print(f"\nPhase 1 Results (Courses & Dishes):")
        print(f"  Total Courses: {total_courses:,}")
        print(f"  Total Dishes: {total_dishes:,}")
        print(f"\nPhase 2 Results (Prices & Modifiers):")
        print(f"  Total Dish Prices: {total_prices:,}")
        print(f"  Total Modifier Groups: {total_modifier_groups:,}")
        print(f"  Total Modifier Items: {total_modifier_items:,}")
        print(f"  Total Modifier Prices: {total_modifier_prices:,}")
        
        # Calculate averages
        if successful_count > 0:
            print(f"\nAverages per Restaurant (for successful scrapes):")
            print(f"  Average Courses: {total_courses / successful_count:.1f}")
            print(f"  Average Dishes: {total_dishes / successful_count:.1f}")
            print(f"  Average Dish Prices: {total_prices / successful_count:.1f}")
            print(f"  Average Modifier Groups: {total_modifier_groups / successful_count:.1f}")
            print(f"  Average Modifier Items: {total_modifier_items / successful_count:.1f}")
            print(f"  Average Modifier Prices: {total_modifier_prices / successful_count:.1f}")
        
        # Dishes with modifiers
        query_modifier_dishes = f"""
            SELECT COUNT(DISTINCT d.id) as dishes_with_modifiers
            FROM {SCHEMA}.dishes d
            JOIN {SCHEMA}.modifier_groups mg ON mg.dish_id = d.id
            WHERE d.restaurant_id IN ({ids_str})
              AND d.deleted_at IS NULL
              AND d.source_id IS NOT NULL
        """
        db.cursor.execute(query_modifier_dishes)
        dishes_with_mods = db.cursor.fetchone()['dishes_with_modifiers']
        
        print(f"\nDishes with Modifiers: {dishes_with_mods:,} ({dishes_with_mods/total_dishes*100:.1f}% of total dishes)" if total_dishes > 0 else "\nDishes with Modifiers: 0")
        
        print("\n" + "="*100)
        
    finally:
        db.close()

if __name__ == "__main__":
    main()


