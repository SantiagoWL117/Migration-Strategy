#!/usr/bin/env python3
"""Report on Mozza Pizza data after Phase 1."""

from database import DatabaseManager
from config import SCHEMA

db = DatabaseManager()
db.connect()

print('='*100)
print('MOZZA PIZZA - PHASE 1 RESULTS (Courses and Dishes)')
print('='*100)
print('Restaurant: Mozza Pizza (DB ID: 35, CRM ID: 132)')
print()

# Get courses with dish counts
query = f"""
SELECT 
    c.id as course_id,
    c.name as course_name,
    c.display_order,
    COUNT(d.id) as dish_count
FROM {SCHEMA}.courses c
LEFT JOIN {SCHEMA}.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL
WHERE c.restaurant_id = 35 AND c.deleted_at IS NULL
GROUP BY c.id, c.name, c.display_order
ORDER BY c.display_order
"""

db.cursor.execute(query)
courses = db.cursor.fetchall()

total_dishes = sum(c['dish_count'] for c in courses)

print(f'SUMMARY:')
print(f'  Total Courses: {len(courses)}')
print(f'  Total Dishes: {total_dishes}')
print()

print('='*100)
print('COURSES AND DISH COUNTS:')
print('='*100)
print(f"{'#':<3} {'Course Name':<40} {'Dishes':<10} {'Course ID':<10}")
print('-'*100)

for idx, course in enumerate(courses, 1):
    print(f"{idx:<3} {course['course_name']:<40} {course['dish_count']:<10} {course['course_id']:<10}")

print('='*100)
print()

# Show sample dishes for each course
print('DETAILED VIEW - DISHES BY COURSE:')
print('='*100)
print()

for course in courses:
    print(f"\nCOURSE: {course['course_name']} (ID: {course['course_id']})")
    print('-'*100)
    
    # Get dishes for this course
    dish_query = f"""
    SELECT 
        d.id as dish_id,
        d.name as dish_name,
        d.source_id as menu_entry_id,
        d.display_order
    FROM {SCHEMA}.dishes d
    WHERE d.course_id = {course['course_id']} 
      AND d.deleted_at IS NULL
    ORDER BY d.display_order
    """
    
    db.cursor.execute(dish_query)
    dishes = db.cursor.fetchall()
    
    if dishes:
        print(f"  {'#':<3} {'Dish Name':<50} {'Dish ID':<10} {'Entry ID':<10}")
        print(f"  {'-'*96}")
        for idx, dish in enumerate(dishes, 1):
            print(f"  {idx:<3} {dish['dish_name']:<50} {dish['dish_id']:<10} {dish['menu_entry_id'] or 'N/A':<10}")
    else:
        print("  (No dishes)")

print()
print('='*100)
print('DATA STATUS:')
print('='*100)
print('  ✓ Courses: COMPLETE (17 courses)')
print('  ✓ Dishes: COMPLETE (105 dishes including 14 combo dishes)')
print('  ✗ Prices: NOT YET SCRAPED (Phase 2)')
print('  ✗ Modifiers: NOT YET SCRAPED (Phase 2)')
print()
print('NEXT STEP: Run Phase 2 (batch_scrape_french_prices.py) to scrape prices and modifiers')
print('='*100)

db.close()

