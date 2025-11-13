#!/usr/bin/env python3
"""
Retry script for Riverside Pizzeria (DB:133, CRM:257).
The scraper successfully extracted 16 courses and 119 dishes, but failed due to database connection closure.
This script will re-scrape and insert the data with proper connection handling.
"""
import sys
import os
import logging

# Add parent directory to path so we can import scraper and database modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))


def main():
    """Retry Riverside Pizzeria."""
    restaurant_name = "Riverside Pizzeria"
    db_id = 133
    crm_id = 257
    
    safe_print("=" * 80)
    safe_print(f"RETRY: {restaurant_name} (DB:{db_id}, CRM:{crm_id})")
    safe_print("=" * 80)
    
    # Initialize database
    db = DatabaseManager()
    try:
        db.connect()
        logger.info("Database connection established")
    except Exception as e:
        logger.error(f"Failed to connect to database: {e}")
        return False
    
    # Initialize scraper
    scraper = MenuScraper()
    try:
        scraper.start()
        logger.info("Scraper initialized and logged in")
    except Exception as e:
        logger.error(f"Failed to initialize scraper: {e}")
        db.close()
        return False
    
    try:
        # Scrape menu
        logger.info(f"\nScraping menu for {restaurant_name} (CRM:{crm_id})...")
        menu_data = scraper.scrape_restaurant_menu(crm_id)
        
        if not menu_data or not menu_data.get('courses'):
            logger.error(f"No menu data found for {restaurant_name}")
            return False
        
        courses_count = len(menu_data['courses'])
        total_dishes = sum(len(c.get('dishes', [])) for c in menu_data['courses'])
        logger.info(f"Found: {courses_count} courses, {total_dishes} dishes")
        
        # Insert courses and dishes
        logger.info("\nInserting into database...")
        courses_inserted = 0
        dishes_inserted = 0
        
        for course_data in menu_data['courses']:
            # Check database connection before each course
            if not db.conn or db.conn.closed:
                logger.warning("Database connection lost, reconnecting...")
                db.connect()
                logger.info("Database reconnection successful")
            
            # Insert course
            course_id = db.insert_course(
                restaurant_id=db_id,
                name=course_data['name'],
                description=course_data.get('description', ''),
                display_order=course_data['display_order']
            )
            
            if course_id:
                courses_inserted += 1
                
                # Insert dishes for this course
                for dish_data in course_data.get('dishes', []):
                    # Check connection before each dish batch
                    if not db.conn or db.conn.closed:
                        logger.warning("Database connection lost, reconnecting...")
                        db.connect()
                        logger.info("Database reconnection successful")
                    
                    dish_id = db.insert_dish(
                        restaurant_id=db_id,
                        course_id=course_id,
                        name=dish_data['name'],
                        description=dish_data.get('description', ''),
                        display_order=dish_data['display_order'],
                        legacy_menu_entry_id=dish_data.get('menu_entry_id')
                    )
                    
                    if dish_id:
                        dishes_inserted += 1
        
        safe_print(f"\n{'='*80}")
        safe_print(f"SUCCESS! {restaurant_name}")
        safe_print(f"  Courses inserted: {courses_inserted}/{courses_count}")
        safe_print(f"  Dishes inserted: {dishes_inserted}/{total_dishes}")
        safe_print(f"{'='*80}")
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to process {restaurant_name}: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        scraper.stop()
        db.close()
        logger.info("Cleanup completed")


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

