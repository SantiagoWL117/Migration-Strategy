#!/usr/bin/env python3
"""Show Mozza Pizza data after Phase 1."""

from database import DatabaseManager
from config import SCHEMA

db = DatabaseManager()
db.connect()

print('='*100)
print('MOZZA PIZZA - PHASE 1 RESULTS')
print('='*100)
print('Restaurant: Mozza Pizza (DB ID: 35, CRM ID: 132)')
print()

# Get summary
query = f"""
SELECT 
    COUNT(DISTINCT c.id) as course_count,
    COUNT(DISTINCT d.id) as dish_count
FROM {SCHEMA}.courses c
LEFT JOIN {SCHEMA}.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL
WHERE c.restaurant_id = 35 AND c.deleted_at IS NULL
"""

db.cursor.execute(query)
summary = db.cursor.fetchone()

print(f'SUMMARY:')
print(f'  Total Courses: {summary["course_count"]}')
print(f'  Total Dishes: {summary["dish_count"]}')
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

print('='*100)
print('COURSES WITH DISH COUNTS:')
print('='*100)
print(f"{'#':<4} {'Course Name':<45} {'Dishes':<10} {'Course ID':<10}")
print('-'*100)

for idx, course in enumerate(courses, 1):
    print(f"{idx:<4} {course['course_name']:<45} {course['dish_count']:<10} {course['course_id']:<10}")

print('='*100)
print()

# Show detailed dishes for each course
print('DETAILED VIEW - ALL DISHES BY COURSE:')
print('='*100)

for course in courses:
    print(f"\n[COURSE {course['display_order'] + 1}] {course['course_name']} (ID: {course['course_id']})")
    print('-'*100)
    
    # Get dishes for this course
    dish_query = f"""
    SELECT 
        d.id as dish_id,
        d.name as dish_name,
        d.source_id as menu_entry_id,
        d.display_order,
        d.description
    FROM {SCHEMA}.dishes d
    WHERE d.course_id = {course['course_id']} 
      AND d.deleted_at IS NULL
    ORDER BY d.display_order
    """
    
    db.cursor.execute(dish_query)
    dishes = db.cursor.fetchall()
    
    if dishes:
        for idx, dish in enumerate(dishes, 1):
            dish_name = dish['dish_name'][:60]  # Truncate long names
            entry_id = str(dish['menu_entry_id']) if dish['menu_entry_id'] else 'N/A'
            print(f"  {idx:>2}. {dish_name:<60} [ID: {dish['dish_id']}, Entry: {entry_id}]")
    else:
        print("  (No dishes)")

print()
print('='*100)
print('DATA STATUS:')
print('='*100)
print('[OK] Phase 1 (Courses & Dishes): COMPLETE')
print(f'     - {len(courses)} courses scraped')
print(f'     - {summary["dish_count"]} dishes scraped')
print()
print('[PENDING] Phase 2 (Prices & Modifiers): NOT YET STARTED')
print('          - Dish prices: Not scraped')
print('          - Modifiers: Not scraped')
print('          - Modifier prices: Not scraped')
print()
print('NOTE: Phase 2 will add prices and modifiers to these dishes.')
print('='*100)

db.close()

