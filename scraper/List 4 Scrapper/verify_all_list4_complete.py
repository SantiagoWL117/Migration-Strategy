#!/usr/bin/env python3
"""
Verify that all List 4 restaurants have courses and dishes in menuca_v3.
"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA

def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))


# All List 4 restaurants from ACTIVE_V1_RESTAURANTS_SCRAPPED.md
LIST4_RESTAURANTS = [
    {'name': 'All Out Burger', 'address': '2560 Bank Street', 'db_id': 924},
    {'name': 'All Out Burger', 'address': '585 Montreal Road', 'db_id': 833},
    {'name': 'All Out Burger', 'address': '714 Gladstone Ave', 'db_id': 948},
    {'name': 'Aroy Thai', 'address': '1 Rideaucrest Drive', 'db_id': 607},
    {'name': "Bobbie's Pizza & Subs", 'address': '1443 Ogilvie Rd', 'db_id': 45},
    {'name': 'Charm Thai Cuisine', 'address': '121 Preston St', 'db_id': 943},
    {'name': 'Colonnade Pizza', 'address': '280 Metcalfe', 'db_id': 196},
    {'name': 'Dumpling Bowl', 'address': '730 Somerset', 'db_id': 792},
    {'name': 'Eastview Pizza', 'address': '251 Montreal Rd', 'db_id': 28},
    {'name': 'Econo Pizza', 'address': '425, boul La Vérendrye E', 'db_id': 1009},
    {'name': 'Erman Pizza', 'address': '3628, av des Églises', 'db_id': 211},
    {'name': 'Ginkgo Garden', 'address': '2225 St Laurent Blvd', 'db_id': 105},
    {'name': 'HaNoi Pho', 'address': '4312 Innes Road', 'db_id': 519},
    {'name': 'Hong Kong Chinese Food Takeout', 'address': '800 Hunt Club Rd', 'db_id': 160},
    {'name': 'House of Lasagna', 'address': '984 Merivale Rd', 'db_id': 22},
    {'name': 'iCook Pho You', 'address': '2006 Robertson Rd', 'db_id': 479},
    {'name': 'JN Pizza', 'address': '1663 Cyrville Rd', 'db_id': 328},
    {'name': 'Kabylie Pizza', 'address': '355 Bd Gréber', 'db_id': 798},
    {'name': 'Kiki Lebanese Pineview Pizza', 'address': '2045 Meadowbrook Rd', 'db_id': 44},
    {'name': 'La Famiglia on the Danforth', 'address': '2318 Danforth Ave', 'db_id': 984},
    {'name': 'Lemongrass Thai Cuisine', 'address': '331 Elgin St', 'db_id': 1010},
    {'name': 'Little Gyros Greek Grill', 'address': '10 Townsend Drive', 'db_id': 756},
    {'name': 'Lorenzo\'s Pizzeria - Vanier', 'address': '94 Montreal Rd', 'db_id': 77},
    {'name': 'Lucky Fortune', 'address': '1970 Trim Rd', 'db_id': 267},
    {'name': 'Mama Rosa', 'address': '375 Des Epinettes Ave', 'db_id': 12},
    {'name': 'Merivale Pizza & Wings', 'address': '1610 Merivale Rd', 'db_id': 48},
    {'name': 'Milano', 'address': '1234 Merivale Rd Unit 3', 'db_id': 55},
    {'name': 'Milano', 'address': '14 Main St E', 'db_id': 88},
    {'name': 'Milano', 'address': '1589 Main St', 'db_id': 601},
    {'name': 'Milano', 'address': '1824 Beachburg', 'db_id': 593},
    {'name': 'Milano', 'address': '2 Pembroke St ( Highway 17 )', 'db_id': 265},
    {'name': 'Milano', 'address': '2241 St Laurent Blvd', 'db_id': 92},
    {'name': 'Milano', 'address': '2430 Bank St', 'db_id': 75},
    {'name': 'Milano', 'address': '26 Bridge St', 'db_id': 123},
    {'name': 'Milano', 'address': '2600 County Rd 43', 'db_id': 97},
    {'name': 'Milano', 'address': '777 Principale St', 'db_id': 89},
    {'name': 'Mozza Pizza Gatineau', 'address': '425, boul La Vérendrye E', 'db_id': 1011},
    {'name': 'New Hong Kong', 'address': '1433 Woodroffe Ave', 'db_id': 502},
    {'name': 'New Mee Fung Restaurant', 'address': '350 Booth St', 'db_id': 15},
    {'name': 'New Mukut Restaurant Indian Cuisine', 'address': '1968 Portobello Blvd', 'db_id': 234},
    {'name': 'Palermo Pizzeria', 'address': '25 Tapiola Cres', 'db_id': 521},
    {'name': 'Papa Grecque Cantley', 'address': '393 Montée de la Source', 'db_id': 810},
    {'name': "Papa Joe's Fried Chicken - Downtown", 'address': '527 Bronson Ave', 'db_id': 437},
    {'name': "Papa Joe's Pizza - Downtown", 'address': '527 Bronson Ave', 'db_id': 13},
    {'name': 'Papa Pizza - Hull', 'address': '574, boul Saint-Joseph', 'db_id': 70},
    {'name': 'Papa Pizza Cantley', 'address': '393 Montée de la Source', 'db_id': 602},
    {'name': 'Papa Pizza Des Flandres', 'address': '22, rue des Flandres', 'db_id': 1012},
    {'name': 'Papa Pizza Maloney', 'address': '253, boul Maloney', 'db_id': 1013},
    {'name': 'Papa Pizza Val-Des-Monts', 'address': '1797, rte du Carrefour', 'db_id': 1014},
    {'name': 'Pho Bo Ga King - Somerset', 'address': '778 Somerset St W', 'db_id': 199},
    {'name': 'Pizza Bravo', 'address': '108, boul Lorrain', 'db_id': 139},
    {'name': 'Pizza Lovers Hunt Club', 'address': '800 Hunt Club Road', 'db_id': 507},
    {'name': 'Poutinerie Québecurds Gatineau', 'address': '643 Boulevard Saint-René O', 'db_id': 1015},
    {'name': 'Rangoli', 'address': '2491 St-Joseph Blvd', 'db_id': 497},
    {'name': 'Restaurant Chez Gerry', 'address': '9, rue Therien', 'db_id': 109},
    {'name': 'Restaurant Le Choix', 'address': '139, rue Principale', 'db_id': 106},
    {'name': 'Riverside Pizzeria', 'address': '3679 Riverside Dr', 'db_id': 133},
    {'name': 'Roulas Grecque et Pizza', 'address': '245, rue de Cannes', 'db_id': 1016},
    {'name': 'Sachi Sushi', 'address': '4931, rue Beaubien E', 'db_id': 376},
    {'name': 'Sushi Express Chambly', 'address': '886 ch de Chambly', 'db_id': 1017},
    {'name': "The Original Georgie's", 'address': '1661 Carling Ave', 'db_id': 84},
    {'name': "Ting's Kitchen", 'address': '3-701 Eagleson Rd', 'db_id': 941},
    {'name': "Tony's Pizza", 'address': '7772 Jeanne d\'Arc Blvd', 'db_id': 143},
    {'name': 'Xtreme Pizza', 'address': '125 Preston St', 'db_id': 367},
    {'name': "Yorgo's - Nepean", 'address': '1356 Clyde Ave', 'db_id': 985},
]


def main():
    """Verify all List 4 restaurants have courses and dishes."""
    safe_print("=" * 80)
    safe_print("LIST 4 VERIFICATION - Courses & Dishes in menuca_v3")
    safe_print("=" * 80)
    safe_print(f"Total restaurants to verify: {len(LIST4_RESTAURANTS)}")
    safe_print("")
    
    # Connect to database
    db = DatabaseManager()
    db.connect()
    
    # Query for all List 4 restaurant IDs
    db_ids = [r['db_id'] for r in LIST4_RESTAURANTS]
    db_ids_str = ','.join(map(str, db_ids))
    
    query = f"""
        SELECT 
            r.id,
            r.name,
            COUNT(DISTINCT c.id) as course_count,
            COUNT(DISTINCT d.id) as dish_count
        FROM {SCHEMA}.restaurants r
        LEFT JOIN {SCHEMA}.courses c ON r.id = c.restaurant_id AND c.deleted_at IS NULL
        LEFT JOIN {SCHEMA}.dishes d ON r.id = d.restaurant_id AND d.deleted_at IS NULL
        WHERE r.id IN ({db_ids_str})
          AND r.deleted_at IS NULL
        GROUP BY r.id, r.name
        ORDER BY r.id
    """
    
    db.cursor.execute(query)
    results = db.cursor.fetchall()
    
    # Create lookup dictionary
    results_dict = {r['id']: r for r in results}
    
    # Check each restaurant
    complete = []
    incomplete = []
    missing = []
    
    for restaurant in LIST4_RESTAURANTS:
        db_id = restaurant['db_id']
        name = restaurant['name']
        address = restaurant['address']
        
        if db_id not in results_dict:
            missing.append(restaurant)
            continue
        
        result = results_dict[db_id]
        courses = result['course_count']
        dishes = result['dish_count']
        
        if courses > 0 and dishes > 0:
            complete.append({
                'db_id': db_id,
                'name': name,
                'address': address,
                'courses': courses,
                'dishes': dishes
            })
        else:
            incomplete.append({
                'db_id': db_id,
                'name': name,
                'address': address,
                'courses': courses,
                'dishes': dishes
            })
    
    # Print results
    safe_print("")
    safe_print("=" * 80)
    safe_print("VERIFICATION RESULTS")
    safe_print("=" * 80)
    safe_print(f"Total: {len(LIST4_RESTAURANTS)}")
    safe_print(f"Complete (with courses & dishes): {len(complete)}")
    safe_print(f"Incomplete (missing data): {len(incomplete)}")
    safe_print(f"Missing from database: {len(missing)}")
    safe_print("")
    
    if incomplete:
        safe_print("=" * 80)
        safe_print("INCOMPLETE RESTAURANTS (No courses/dishes)")
        safe_print("=" * 80)
        for r in incomplete:
            safe_print(f"DB:{r['db_id']:<4} | Courses:{r['courses']:<3} | Dishes:{r['dishes']:<4} | {r['name']}")
        safe_print("")
    
    if missing:
        safe_print("=" * 80)
        safe_print("MISSING FROM DATABASE")
        safe_print("=" * 80)
        for r in missing:
            safe_print(f"DB:{r['db_id']:<4} | {r['name']} - {r['address']}")
        safe_print("")
    
    if len(complete) == len(LIST4_RESTAURANTS):
        safe_print("=" * 80)
        safe_print("SUCCESS! ALL RESTAURANTS VERIFIED")
        safe_print("=" * 80)
        safe_print(f"All {len(LIST4_RESTAURANTS)} List 4 restaurants have courses and dishes in menuca_v3")
        safe_print("")
        
        # Summary statistics
        total_courses = sum(r['courses'] for r in complete)
        total_dishes = sum(r['dishes'] for r in complete)
        safe_print("TOTAL DATA:")
        safe_print(f"  Courses: {total_courses:,}")
        safe_print(f"  Dishes: {total_dishes:,}")
        safe_print("")
        safe_print("All restaurants are ready for Phase 2 (Prices & Modifiers)")
    
    safe_print("=" * 80)
    
    db.close()


if __name__ == "__main__":
    main()

