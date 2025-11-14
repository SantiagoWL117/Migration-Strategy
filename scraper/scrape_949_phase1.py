#!/usr/bin/env python3
"""
Phase 1 scraper for Restaurant 949 (All Out Burger - 585 Montreal Road).
Scrapes courses and dishes from the V1 CRM.
"""
import logging
import sys
from pathlib import Path

# Import from parent scraper directory
sys.path.insert(0, str(Path(__file__).parent))

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def main():
    """Scrape Phase 1 data for restaurant 949."""
    
    # Restaurant details
    DB_ID = 949  # Database ID
    CRM_ID = 1071  # CRM/V1 ID (legacy_v1_id)
    RESTAURANT_NAME = "All Out Burger - 585 Montreal Road"
    
    logger.info("=" * 60)
    logger.info(f"Phase 1 Scraper: {RESTAURANT_NAME}")
    logger.info(f"Database ID: {DB_ID}")
    logger.info(f"CRM ID: {CRM_ID}")
    logger.info("=" * 60)
    
    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connection established")
    
    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")
    
    try:
        # Scrape menu data
        logger.info(f"Scraping menu for CRM ID {CRM_ID}...")
        menu_data = scraper.scrape_restaurant_menu(CRM_ID)
        
        if not menu_data or not menu_data.get('courses'):
            logger.error("No menu data found!")
            return
        
        logger.info(f"Found {len(menu_data['courses'])} courses")
        
        # Insert courses and dishes into database
        total_courses = 0
        total_dishes = 0
        
        for course_data in menu_data['courses']:
            logger.info(f"Processing course: {course_data['name']}")
            
            # Insert course
            course_id = db.insert_course(
                restaurant_id=DB_ID,
                name=course_data['name'],
                description=course_data.get('description', ''),
                display_order=course_data['display_order']
            )
            
            if course_id:
                total_courses += 1
                logger.info(f"  Course inserted with ID: {course_id}")
                
                # Insert dishes for this course
                dishes_count = 0
                for dish_data in course_data.get('dishes', []):
                    dish_id = db.insert_dish(
                        restaurant_id=DB_ID,
                        course_id=course_id,
                        name=dish_data['name'],
                        description=dish_data.get('description', ''),
                        display_order=dish_data['display_order'],
                        legacy_menu_entry_id=dish_data.get('menu_entry_id')
                    )
                    
                    if dish_id:
                        dishes_count += 1
                        total_dishes += 1
                        logger.debug(f"    Dish: {dish_data['name']} (ID: {dish_id}, menu_entry_id: {dish_data.get('menu_entry_id')})")
                
                logger.info(f"  Inserted {dishes_count} dishes")
            else:
                logger.error(f"  Failed to insert course: {course_data['name']}")
        
        logger.info("")
        logger.info("=" * 60)
        logger.info("PHASE 1 COMPLETE")
        logger.info("=" * 60)
        logger.info(f"Total courses inserted: {total_courses}")
        logger.info(f"Total dishes inserted: {total_dishes}")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"Error during scraping: {e}", exc_info=True)
        raise
    
    finally:
        scraper.stop()
        db.close()
        logger.info("Resources cleaned up")


if __name__ == "__main__":
    main()

