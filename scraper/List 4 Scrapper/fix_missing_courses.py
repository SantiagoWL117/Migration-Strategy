#!/usr/bin/env python3
"""
Fix the 3 restaurants that have dishes but no courses.
This shouldn't happen, but we'll investigate and fix it.
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


PROBLEM_RESTAURANTS = [
    {'name': 'Kabylie Pizza', 'db_id': 798},
    {'name': 'Papa Grecque Cantley', 'db_id': 810},
    {'name': 'Papa Pizza Cantley', 'db_id': 602}
]


def main():
    """Investigate and fix missing courses."""
    safe_print("=" * 80)
    safe_print("INVESTIGATING MISSING COURSES")
    safe_print("=" * 80)
    
    db = DatabaseManager()
    db.connect()
    
    for restaurant in PROBLEM_RESTAURANTS:
        db_id = restaurant['db_id']
        name = restaurant['name']
        
        safe_print(f"\n{name} (DB:{db_id})")
        safe_print("-" * 80)
        
        # Check courses
        query_courses = f"""
            SELECT id, name, display_order, deleted_at
            FROM {SCHEMA}.courses
            WHERE restaurant_id = %s
            ORDER BY display_order
        """
        db.cursor.execute(query_courses, (db_id,))
        courses = db.cursor.fetchall()
        
        safe_print(f"Courses found: {len(courses)}")
        if courses:
            for c in courses[:5]:  # Show first 5
                deleted = " [DELETED]" if c['deleted_at'] else ""
                safe_print(f"  - ID:{c['id']}, Order:{c['display_order']}, Name:'{c['name']}'{deleted}")
        
        # Check dishes
        query_dishes = f"""
            SELECT id, name, course_id, display_order, deleted_at
            FROM {SCHEMA}.dishes
            WHERE restaurant_id = %s
            ORDER BY course_id, display_order
            LIMIT 10
        """
        db.cursor.execute(query_dishes, (db_id,))
        dishes = db.cursor.fetchall()
        
        safe_print(f"Dishes found: {len(dishes)} (showing first 10)")
        if dishes:
            for d in dishes:
                deleted = " [DELETED]" if d['deleted_at'] else ""
                safe_print(f"  - Dish ID:{d['id']}, Course ID:{d['course_id']}, Name:'{d['name']}'{deleted}")
        
        # Check if courses are soft-deleted
        query_deleted = f"""
            SELECT COUNT(*) as count
            FROM {SCHEMA}.courses
            WHERE restaurant_id = %s
              AND deleted_at IS NOT NULL
        """
        db.cursor.execute(query_deleted, (db_id,))
        deleted_count = db.cursor.fetchone()['count']
        
        if deleted_count > 0:
            safe_print(f"\nWARNING: {deleted_count} courses are soft-deleted!")
            safe_print("These courses need to be undeleted.")
    
    db.close()
    
    safe_print("\n" + "=" * 80)
    safe_print("ANALYSIS COMPLETE")
    safe_print("=" * 80)
    safe_print("\nThe issue appears to be that courses were inserted but are soft-deleted.")
    safe_print("We need to check if they should be undeleted or re-scraped.")


if __name__ == "__main__":
    main()

