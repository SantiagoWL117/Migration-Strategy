#!/usr/bin/env python3
"""
Undelete the soft-deleted courses for the 3 problematic restaurants.
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
    """Undelete courses for the 3 restaurants."""
    safe_print("=" * 80)
    safe_print("UNDELETING COURSES")
    safe_print("=" * 80)
    
    db = DatabaseManager()
    db.connect()
    
    total_undeleted = 0
    
    for restaurant in PROBLEM_RESTAURANTS:
        db_id = restaurant['db_id']
        name = restaurant['name']
        
        safe_print(f"\n{name} (DB:{db_id})")
        safe_print("-" * 40)
        
        # Undelete courses
        query = f"""
            UPDATE {SCHEMA}.courses
            SET deleted_at = NULL, updated_at = NOW()
            WHERE restaurant_id = %s
              AND deleted_at IS NOT NULL
        """
        
        db.cursor.execute(query, (db_id,))
        rows_updated = db.cursor.rowcount
        db.conn.commit()
        
        safe_print(f"Undeleted {rows_updated} courses")
        total_undeleted += rows_updated
    
    safe_print("\n" + "=" * 80)
    safe_print(f"COMPLETE: Undeleted {total_undeleted} courses total")
    safe_print("=" * 80)
    
    db.close()


if __name__ == "__main__":
    main()

