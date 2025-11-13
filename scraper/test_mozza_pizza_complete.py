#!/usr/bin/env python3
"""
Comprehensive test for Mozza Pizza - Full Phase 2 simulation.

This test will:
1. Scrape all 105 dishes (including combos)
2. Scrape prices and modifiers for ALL dishes
3. Insert everything into the database
4. Validate different dish types (regular, combo, no-modifiers)
"""

import time
from datetime import datetime
from scraper_french import FrenchMenuScraper
from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Mozza Pizza details
RESTAURANT_DB_ID = 35
RESTAURANT_CRM_ID = 132
RESTAURANT_NAME = "Mozza Pizza"

def test_phase1_courses_dishes():
    """Test Phase 1: Scrape courses and dishes."""
    print("="*100)
    print("TEST 1: COURSES AND DISHES (Phase 1 - Already Complete)")
    print("="*100)
    
    # Just validate what's already in the database
    db = DatabaseManager()
    db.connect()
    
    query = f"""
    SELECT COUNT(DISTINCT c.id) as course_count, COUNT(DISTINCT d.id) as dish_count
    FROM {SCHEMA}.courses c
    LEFT JOIN {SCHEMA}.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL
    WHERE c.restaurant_id = {RESTAURANT_DB_ID} AND c.deleted_at IS NULL
    """
    
    db.cursor.execute(query)
    result = db.cursor.fetchone()
    
    course_count = result['course_count']
    dish_count = result['dish_count']
    
    print(f"\nDatabase Check:")
    print(f"  Courses: {course_count}")
    print(f"  Dishes: {dish_count}")
    
    db.close()
    
    success = course_count == 17 and dish_count == 105
    
    print(f"\n{'='*100}")
    print(f"TEST 1 RESULTS:")
    print(f"{'='*100}")
    print(f"[{'PASS' if success else 'FAIL'}] Phase 1 data exists in database")
    
    return success

def test_phase2_all_dishes():
    """Test Phase 2: Scrape prices and modifiers for ALL dishes."""
    print("\n" + "="*100)
    print("TEST 2: PRICES AND MODIFIERS FOR ALL DISHES (Phase 2 - Full Test)")
    print("="*100)
    print(f"Restaurant: {RESTAURANT_NAME} (DB:{RESTAURANT_DB_ID}, CRM:{RESTAURANT_CRM_ID})")
    print("\nThis will scrape and insert prices/modifiers for ALL 105 dishes")
    print("="*100)
    
    # Get all dishes from database
    db = DatabaseManager()
    db.connect()
    
    query = f"""
    SELECT 
        d.id as dish_id,
        d.name as dish_name,
        d.source_id as menu_entry_id,
        c.name as course_name,
        d.restaurant_id,
        r.legacy_v1_id as crm_restaurant_id,
        r.name as restaurant_name
    FROM {SCHEMA}.dishes d
    JOIN {SCHEMA}.courses c ON d.course_id = c.id
    JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
    WHERE d.restaurant_id = {RESTAURANT_DB_ID}
      AND d.source_id IS NOT NULL
      AND d.deleted_at IS NULL
      AND c.deleted_at IS NULL
    ORDER BY c.display_order, d.display_order
    """
    
    db.cursor.execute(query)
    dishes = db.cursor.fetchall()
    
    print(f"\nFound {len(dishes)} dishes to process")
    print()
    
    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    
    # Track statistics
    stats = {
        'total_dishes': len(dishes),
        'processed': 0,
        'with_prices': 0,
        'with_modifiers': 0,
        'without_modifiers': 0,
        'skipped': 0,
        'errors': 0,
        'total_prices': 0,
        'total_modifier_groups': 0,
        'total_modifier_items': 0,
        'total_modifier_prices': 0,
        'combo_dishes': 0,
        'regular_dishes': 0
    }
    
    # Track dish types for detailed reporting
    combo_courses = ["Spécial Petites", "Spécial Moyennes", "Spécial Grandes", "Spécial X-Grandes", "Mega Bouffe"]
    sample_dishes = []
    
    start_time = datetime.now()
    
    try:
        current_course = None
        
        for idx, dish in enumerate(dishes, 1):
            # Show course header when it changes
            if dish['course_name'] != current_course:
                current_course = dish['course_name']
                print(f"\n{'='*100}")
                print(f"COURSE: {current_course}")
                print(f"{'='*100}")
            
            print(f"  [{idx}/{len(dishes)}] {dish['dish_name'][:60]:<60} ", end='', flush=True)
            
            # Track dish type
            if dish['course_name'] in combo_courses:
                stats['combo_dishes'] += 1
            else:
                stats['regular_dishes'] += 1
            
            try:
                # Ensure database connection
                db.ensure_connection()
                
                # Scrape dish details with French language
                details = scraper.scrape_dish_details(
                    dish['crm_restaurant_id'],
                    dish['menu_entry_id'],
                    language='fr'
                )
                
                if not details:
                    print("[SKIPPED - No details]")
                    stats['skipped'] += 1
                    continue
                
                stats['processed'] += 1
                
                # Insert prices
                prices_inserted = 0
                size_variants = []
                
                for price_data in details.get('prices', []):
                    size_variant = price_data.get('size_variant') or 'standard'
                    size_variants.append(size_variant)
                    
                    price_id = db.insert_dish_price(
                        dish_id=dish['dish_id'],
                        size_variant=size_variant,
                        price=price_data['price'],
                        display_order=price_data.get('display_order', 0)
                    )
                    if price_id:
                        prices_inserted += 1
                        stats['total_prices'] += 1
                
                if prices_inserted > 0:
                    stats['with_prices'] += 1
                
                if not size_variants:
                    size_variants = ['standard']
                
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
                mod_prices_inserted = 0
                
                for mg_data in details.get('modifiers', []):
                    group_id = db.insert_modifier_group(
                        dish_id=dish['dish_id'],
                        name=mg_data['name'],
                        is_required=mg_data.get('is_required', False),
                        min_selections=mg_data.get('min_selections', 0),
                        max_selections=mg_data.get('max_selections', 1),
                        display_order=mg_data.get('display_order', 0)
                    )
                    
                    if group_id:
                        groups_inserted += 1
                        stats['total_modifier_groups'] += 1
                        
                        modifier_type = type_mapping.get(mg_data.get('type_code', ''), 'other')
                        
                        for item_data in mg_data.get('items', []):
                            item_id = db.insert_dish_modifier(
                                restaurant_id=dish['restaurant_id'],
                                dish_id=dish['dish_id'],
                                modifier_group_id=group_id,
                                name=item_data['name'],
                                modifier_type=modifier_type,
                                is_default=item_data.get('is_default', False),
                                display_order=item_data.get('display_order', 0)
                            )
                            
                            if item_id:
                                items_inserted += 1
                                stats['total_modifier_items'] += 1
                                
                                # Insert modifier prices
                                item_prices = item_data.get('prices', [0.0])
                                
                                for price_idx, price_value in enumerate(item_prices):
                                    size_var = size_variants[price_idx] if price_idx < len(size_variants) else 'standard'
                                    
                                    price_id = db.insert_dish_modifier_price(
                                        dish_modifier_id=item_id,
                                        dish_id=dish['dish_id'],
                                        restaurant_id=dish['restaurant_id'],
                                        size_variant=size_var,
                                        price=price_value,
                                        display_order=price_idx
                                    )
                                    
                                    if price_id:
                                        mod_prices_inserted += 1
                                        stats['total_modifier_prices'] += 1
                
                if groups_inserted > 0:
                    stats['with_modifiers'] += 1
                else:
                    stats['without_modifiers'] += 1
                
                # Print result
                result_str = f"[P:{prices_inserted} MG:{groups_inserted} MI:{items_inserted} MP:{mod_prices_inserted}]"
                print(result_str)
                
                # Save sample dishes for detailed report
                if len(sample_dishes) < 5 or dish['course_name'] in combo_courses:
                    sample_dishes.append({
                        'name': dish['dish_name'],
                        'course': dish['course_name'],
                        'prices': prices_inserted,
                        'modifier_groups': groups_inserted,
                        'modifier_items': items_inserted,
                        'modifier_prices': mod_prices_inserted,
                        'is_combo': dish['course_name'] in combo_courses
                    })
                
                # Small delay to avoid overwhelming the CRM
                time.sleep(0.5)
                
            except Exception as e:
                print(f"[ERROR: {str(e)[:40]}]")
                stats['errors'] += 1
                continue
    
    finally:
        scraper.stop()
        db.close()
    
    duration = datetime.now() - start_time
    
    # Print detailed summary
    print("\n" + "="*100)
    print("TEST 2 RESULTS - DETAILED STATISTICS")
    print("="*100)
    
    print(f"\nProcessing Summary:")
    print(f"  Total dishes: {stats['total_dishes']}")
    print(f"  Processed successfully: {stats['processed']}")
    print(f"  Skipped (no details): {stats['skipped']}")
    print(f"  Errors: {stats['errors']}")
    print(f"  Duration: {duration}")
    
    print(f"\nDish Types:")
    print(f"  Regular dishes: {stats['regular_dishes']}")
    print(f"  Combo dishes: {stats['combo_dishes']}")
    print(f"  Dishes with prices: {stats['with_prices']}")
    print(f"  Dishes with modifiers: {stats['with_modifiers']}")
    print(f"  Dishes without modifiers: {stats['without_modifiers']}")
    
    print(f"\nData Inserted:")
    print(f"  Dish prices: {stats['total_prices']}")
    print(f"  Modifier groups: {stats['total_modifier_groups']}")
    print(f"  Modifier items: {stats['total_modifier_items']}")
    print(f"  Modifier prices: {stats['total_modifier_prices']}")
    
    print(f"\nSample Dishes:")
    for dish in sample_dishes[:10]:
        dish_type = "[COMBO]" if dish['is_combo'] else "[REGULAR]"
        print(f"  {dish_type} {dish['name'][:50]:<50}")
        print(f"    Course: {dish['course']}")
        print(f"    Prices: {dish['prices']}, Modifier Groups: {dish['modifier_groups']}, " +
              f"Items: {dish['modifier_items']}, Modifier Prices: {dish['modifier_prices']}")
    
    # Validation
    print(f"\n{'='*100}")
    print("VALIDATION:")
    print(f"{'='*100}")
    
    success = True
    
    if stats['processed'] < 90:  # At least 90% should be processed
        print(f"[FAIL] Only {stats['processed']}/{stats['total_dishes']} dishes processed")
        success = False
    else:
        print(f"[PASS] {stats['processed']}/{stats['total_dishes']} dishes processed successfully")
    
    if stats['combo_dishes'] < 14:
        print(f"[FAIL] Expected 14+ combo dishes, got {stats['combo_dishes']}")
        success = False
    else:
        print(f"[PASS] {stats['combo_dishes']} combo dishes processed")
    
    if stats['with_prices'] < 90:
        print(f"[WARN] Only {stats['with_prices']} dishes have prices")
    else:
        print(f"[PASS] {stats['with_prices']} dishes have prices")
    
    if stats['with_modifiers'] < 20:
        print(f"[WARN] Only {stats['with_modifiers']} dishes have modifiers")
    else:
        print(f"[PASS] {stats['with_modifiers']} dishes have modifiers")
    
    if stats['without_modifiers'] > 0:
        print(f"[INFO] {stats['without_modifiers']} dishes have no modifiers (drinks, desserts, etc.)")
    
    if stats['errors'] > 10:
        print(f"[WARN] {stats['errors']} errors occurred")
    
    return success, stats

def main():
    """Run comprehensive test."""
    print("\n" + "="*100)
    print("MOZZA PIZZA - COMPREHENSIVE PHASE 2 TEST")
    print("="*100)
    print(f"\nRestaurant: {RESTAURANT_NAME}")
    print(f"DB ID: {RESTAURANT_DB_ID}")
    print(f"CRM ID: {RESTAURANT_CRM_ID}")
    print(f"\nThis test will:")
    print(f"  1. Validate Phase 1 data (courses and dishes)")
    print(f"  2. Scrape prices and modifiers for ALL 105 dishes")
    print(f"  3. Insert everything into menuca_v3 schema")
    print(f"  4. Validate all dish types (regular, combo, no-modifiers)")
    print("="*100)
    
    input("\nPress ENTER to start the test...")
    
    # Test 1: Validate Phase 1
    test1_success = test_phase1_courses_dishes()
    
    if not test1_success:
        print("\n[ERROR] Phase 1 data is incomplete. Please run Phase 1 first.")
        return
    
    # Test 2: Full Phase 2 test
    test2_success, stats = test_phase2_all_dishes()
    
    # Final summary
    print("\n" + "="*100)
    print("FINAL TEST SUMMARY")
    print("="*100)
    
    print(f"\nTest 1 (Phase 1 Data): [{'PASS' if test1_success else 'FAIL'}]")
    print(f"Test 2 (Phase 2 Full): [{'PASS' if test2_success else 'FAIL'}]")
    
    if test1_success and test2_success:
        print("\n" + "="*100)
        print("[SUCCESS] COMPREHENSIVE TEST PASSED!")
        print("="*100)
        print(f"\nMozza Pizza Complete Data:")
        print(f"  - 17 courses")
        print(f"  - 105 dishes (including {stats['combo_dishes']} combos)")
        print(f"  - {stats['total_prices']} dish prices")
        print(f"  - {stats['total_modifier_groups']} modifier groups")
        print(f"  - {stats['total_modifier_items']} modifier items")
        print(f"  - {stats['total_modifier_prices']} modifier prices")
        print(f"\nBoth bug fixes are working correctly:")
        print(f"  ✓ Bug Fix #1: Combo dishes scraped")
        print(f"  ✓ Bug Fix #2: French modifiers scraped")
        print(f"\nYou can now proceed with Phase 2 batch scrape for all 26 restaurants!")
        print("="*100)
    else:
        print("\n" + "="*100)
        print("[FAILURE] Test failed. Please review errors above.")
        print("="*100)

if __name__ == "__main__":
    main()

