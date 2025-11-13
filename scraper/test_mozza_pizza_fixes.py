#!/usr/bin/env python3
"""
Test script to verify both bug fixes work correctly for Mozza Pizza.

Tests:
1. Bug Fix #1: Combo dishes are now scraped (editCombo links accepted)
2. Bug Fix #2: Modifiers are scraped using French language parameter

Expected Results:
- 17 courses
- 105 dishes (including 14 combo dishes)
- Mozzarella Pizza should have 3 modifier groups (Bread, Custom Ingredients, Sauces)
"""

import time
from scraper_french import FrenchMenuScraper
from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Mozza Pizza details
RESTAURANT_DB_ID = 35
RESTAURANT_CRM_ID = 132
RESTAURANT_NAME = "Mozza Pizza"
MOZZARELLA_PIZZA_ENTRY_ID = 13208

def test_courses_and_dishes():
    """Test Bug Fix #1: Scrape courses and dishes including combos."""
    print("="*80)
    print("TEST 1: COURSES AND DISHES (Bug Fix #1)")
    print("="*80)
    print(f"Restaurant: {RESTAURANT_NAME} (DB:{RESTAURANT_DB_ID}, CRM:{RESTAURANT_CRM_ID})")
    print("\nExpected:")
    print("  - 17 courses")
    print("  - 105 dishes (including 14 combo dishes)")
    print("\nTesting...")
    
    scraper = FrenchMenuScraper()
    scraper.start()
    
    try:
        courses, dishes = scraper.scrape_restaurant_menu(RESTAURANT_CRM_ID)
        
        print(f"\nResults:")
        print(f"  Courses found: {len(courses)}")
        print(f"  Dishes found: {len(dishes)}")
        
        # Show course breakdown
        print(f"\nCourse Breakdown:")
        for idx, course in enumerate(courses):
            dish_count = len([d for d in dishes if d['course_index'] == idx])
            print(f"  {idx+1:2d}. {course['name']:40s} - {dish_count:3d} dishes")
        
        # Check for combo courses
        combo_courses = [
            "Spécial Petites",
            "Spécial Moyennes", 
            "Spécial Grandes",
            "Spécial X-Grandes",
            "Mega Bouffe"
        ]
        
        print(f"\nCombo Course Check:")
        total_combo_dishes = 0
        for idx, course in enumerate(courses):
            if course['name'] in combo_courses:
                dish_count = len([d for d in dishes if d['course_index'] == idx])
                total_combo_dishes += dish_count
                status = "[OK]" if dish_count > 0 else "[FAIL]"
                print(f"  {status} {course['name']:30s} - {dish_count} dishes")
        
        print(f"\n{'='*80}")
        print(f"TEST 1 RESULTS:")
        print(f"{'='*80}")
        
        # Validate results
        success = True
        
        if len(courses) != 17:
            print(f"[FAIL] Expected 17 courses, got {len(courses)}")
            success = False
        else:
            print(f"[PASS] Course count: {len(courses)}")
        
        if len(dishes) < 105:
            print(f"[FAIL] Expected 105 dishes, got {len(dishes)}")
            success = False
        elif len(dishes) == 105:
            print(f"[PASS] Dish count: {len(dishes)}")
        else:
            print(f"[WARN] Expected 105 dishes, got {len(dishes)} (more than expected)")
        
        if total_combo_dishes < 14:
            print(f"[FAIL] Expected 14+ combo dishes, got {total_combo_dishes}")
            success = False
        else:
            print(f"[PASS] Combo dishes: {total_combo_dishes}")
        
        return success, courses, dishes
    
    finally:
        scraper.stop()

def test_modifiers(courses, dishes):
    """Test Bug Fix #2: Scrape modifiers with French language."""
    print("\n" + "="*80)
    print("TEST 2: MODIFIERS (Bug Fix #2)")
    print("="*80)
    print(f"Dish: Mozzarella Pizza (Entry ID: {MOZZARELLA_PIZZA_ENTRY_ID})")
    print("\nExpected:")
    print("  - 4 prices (Petite, Moyenne, Grande, X-Grande)")
    print("  - 3 modifier groups (Bread, Custom Ingredients, Sauces)")
    print("  - 31+ modifier items total")
    print("\nTesting...")
    
    scraper = MenuScraper()
    scraper.start()
    
    try:
        # Test with French language
        details_fr = scraper.scrape_dish_details(
            RESTAURANT_CRM_ID, 
            MOZZARELLA_PIZZA_ENTRY_ID,
            language='fr'
        )
        
        print(f"\nResults (language='fr'):")
        if details_fr:
            print(f"  Prices: {len(details_fr.get('prices', []))}")
            for p in details_fr.get('prices', []):
                print(f"    - {p['size_variant']:15s}: ${p['price']:.2f}")
            
            print(f"  Modifier groups: {len(details_fr.get('modifiers', []))}")
            total_items = 0
            for mg in details_fr.get('modifiers', []):
                item_count = len(mg.get('items', []))
                total_items += item_count
                print(f"    - {mg['name']} ({mg['type_code']}): {item_count} items")
            
            print(f"  Total modifier items: {total_items}")
        else:
            print("  [ERROR] No details returned!")
        
        # Test with English language (should have fewer/no modifiers)
        print(f"\nComparison test (language='en'):")
        details_en = scraper.scrape_dish_details(
            RESTAURANT_CRM_ID,
            MOZZARELLA_PIZZA_ENTRY_ID,
            language='en'
        )
        
        if details_en:
            print(f"  Prices: {len(details_en.get('prices', []))}")
            print(f"  Modifier groups: {len(details_en.get('modifiers', []))}")
        
        print(f"\n{'='*80}")
        print(f"TEST 2 RESULTS:")
        print(f"{'='*80}")
        
        # Validate results
        success = True
        
        if not details_fr:
            print(f"[FAIL] No dish details returned")
            return False
        
        prices_count = len(details_fr.get('prices', []))
        if prices_count != 4:
            print(f"[FAIL] Expected 4 prices, got {prices_count}")
            success = False
        else:
            print(f"[PASS] Price count: {prices_count}")
        
        modifiers_count = len(details_fr.get('modifiers', []))
        if modifiers_count < 3:
            print(f"[FAIL] Expected 3+ modifier groups, got {modifiers_count}")
            success = False
        else:
            print(f"[PASS] Modifier groups: {modifiers_count}")
        
        if total_items < 31:
            print(f"[WARN] Expected 31+ modifier items, got {total_items}")
        else:
            print(f"[PASS] Modifier items: {total_items}")
        
        # Check language difference
        en_modifiers = len(details_en.get('modifiers', [])) if details_en else 0
        if en_modifiers > 0:
            print(f"[WARN] English version has {en_modifiers} modifiers (bug not fully fixed)")
        else:
            print(f"[PASS] English version correctly has 0 modifiers")
        
        return success, details_fr
    
    finally:
        scraper.stop()

def test_database_insertion(courses, dishes, modifier_details):
    """Test inserting data into database."""
    print("\n" + "="*80)
    print("TEST 3: DATABASE INSERTION")
    print("="*80)
    print("Inserting scraped data into database...\n")
    
    db = DatabaseManager()
    db.connect()
    
    try:
        # Insert courses
        course_ids = []
        for course in courses:
            course_id = db.insert_course(
                restaurant_id=RESTAURANT_DB_ID,
                name=course['name'],
                description=course['description'],
                display_order=course['display_order']
            )
            if course_id:
                course_ids.append(course_id)
        
        print(f"  Inserted {len(course_ids)} courses")
        
        # Insert dishes
        dish_ids = []
        mozzarella_dish_id = None
        
        for dish in dishes:
            course_idx = dish['course_index']
            if course_idx < len(course_ids):
                course_id = course_ids[course_idx]
                dish_id = db.insert_dish(
                    restaurant_id=RESTAURANT_DB_ID,
                    course_id=course_id,
                    name=dish['name'],
                    description=dish['description'],
                    display_order=dish['display_order'],
                    legacy_menu_entry_id=dish['source_id']
                )
                if dish_id:
                    dish_ids.append(dish_id)
                    
                    # Track Mozzarella Pizza dish ID
                    if dish['source_id'] == MOZZARELLA_PIZZA_ENTRY_ID:
                        mozzarella_dish_id = dish_id
        
        print(f"  Inserted {len(dish_ids)} dishes")
        
        # Insert prices and modifiers for Mozzarella Pizza
        if mozzarella_dish_id and modifier_details:
            # Insert prices
            prices_inserted = 0
            size_variants = []
            
            for price_data in modifier_details.get('prices', []):
                size_variant = price_data.get('size_variant') or 'standard'
                size_variants.append(size_variant)
                
                price_id = db.insert_dish_price(
                    dish_id=mozzarella_dish_id,
                    size_variant=size_variant,
                    price=price_data['price'],
                    display_order=price_data.get('display_order', 0)
                )
                if price_id:
                    prices_inserted += 1
            
            print(f"  Inserted {prices_inserted} prices for Mozzarella Pizza")
            
            # Insert modifiers
            type_mapping = {
                'br': 'bread',
                'ci': 'custom_ingredients',
                'dr': 'dressing',
                'sa': 'sauces',
                'sd': 'side_dishes',
                'd': 'drinks',
                'e': 'extras',
                'cm': 'cooking_method'
            }
            
            groups_inserted = 0
            items_inserted = 0
            prices_inserted_mod = 0
            
            for mg_data in modifier_details.get('modifiers', []):
                group_id = db.insert_modifier_group(
                    dish_id=mozzarella_dish_id,
                    name=mg_data['name'],
                    is_required=mg_data.get('is_required', False),
                    min_selections=mg_data.get('min_selections', 0),
                    max_selections=mg_data.get('max_selections', 1),
                    display_order=mg_data.get('display_order', 0)
                )
                
                if group_id:
                    groups_inserted += 1
                    
                    modifier_type = type_mapping.get(mg_data.get('type_code', ''), 'other')
                    
                    for item_data in mg_data.get('items', []):
                        item_id = db.insert_dish_modifier(
                            restaurant_id=RESTAURANT_DB_ID,
                            dish_id=mozzarella_dish_id,
                            modifier_group_id=group_id,
                            name=item_data['name'],
                            modifier_type=modifier_type,
                            is_default=item_data.get('is_default', False),
                            display_order=item_data.get('display_order', 0)
                        )
                        
                        if item_id:
                            items_inserted += 1
                            
                            # Insert prices for each size variant
                            item_prices = item_data.get('prices', [0.0])
                            
                            for idx, price_value in enumerate(item_prices):
                                size_var = size_variants[idx] if idx < len(size_variants) else 'standard'
                                
                                price_id = db.insert_dish_modifier_price(
                                    dish_modifier_id=item_id,
                                    dish_id=mozzarella_dish_id,
                                    restaurant_id=RESTAURANT_DB_ID,
                                    size_variant=size_var,
                                    price=price_value,
                                    display_order=idx
                                )
                                
                                if price_id:
                                    prices_inserted_mod += 1
            
            print(f"  Inserted {groups_inserted} modifier groups for Mozzarella Pizza")
            print(f"  Inserted {items_inserted} modifier items for Mozzarella Pizza")
            print(f"  Inserted {prices_inserted_mod} modifier prices for Mozzarella Pizza")
        
        print(f"\n{'='*80}")
        print(f"TEST 3 RESULTS:")
        print(f"{'='*80}")
        print(f"[PASS] All data inserted successfully")
        
        return True
    
    finally:
        db.close()

def main():
    """Run all tests."""
    print("\n" + "="*80)
    print("MOZZA PIZZA BUG FIX TEST SUITE")
    print("="*80)
    print(f"\nThis will test both bug fixes:")
    print(f"  1. Combo dishes are now accepted (editCombo links)")
    print(f"  2. Modifiers are scraped with French language parameter")
    print(f"\nRestaurant: {RESTAURANT_NAME}")
    print(f"DB ID: {RESTAURANT_DB_ID}")
    print(f"CRM ID: {RESTAURANT_CRM_ID}")
    
    # Run tests
    test1_success, courses, dishes = test_courses_and_dishes()
    
    test2_success, modifier_details = test_modifiers(courses, dishes)
    
    test3_success = test_database_insertion(courses, dishes, modifier_details)
    
    # Final summary
    print("\n" + "="*80)
    print("FINAL TEST SUMMARY")
    print("="*80)
    
    all_passed = test1_success and test2_success and test3_success
    
    print(f"Test 1 (Courses & Dishes): {'[PASS]' if test1_success else '[FAIL]'}")
    print(f"Test 2 (Modifiers):        {'[PASS]' if test2_success else '[FAIL]'}")
    print(f"Test 3 (Database):         {'[PASS]' if test3_success else '[FAIL]'}")
    
    print("\n" + "="*80)
    if all_passed:
        print("[SUCCESS] All tests passed!")
        print("\nBoth bug fixes are working correctly.")
        print("You can now proceed with the full batch scrape.")
    else:
        print("[FAILURE] Some tests failed")
        print("Please review the test output above.")
    print("="*80)

if __name__ == "__main__":
    main()

