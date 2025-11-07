"""
Proof of Concept: Menu Scraper for Single Restaurant
Extracts menu data from CRM and loads into menuca_v3 schema.
"""
import logging
import sys
from scraper import MenuScraper
from database import DatabaseManager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('scraper.log')
    ]
)
logger = logging.getLogger(__name__)


def main():
    """Run proof of concept for Aahar restaurant."""

    # Configuration for POC
    RESTAURANT_NAME = "Aahar The Taste of India"  # Database name (no address)
    RESTAURANT_CRM_ID = 781  # From the HTML URL provided (matches legacy_v1_id)

    logger.info("="*60)
    logger.info("Menu Scraper - Proof of Concept")
    logger.info("="*60)

    try:
        # Step 1: Get restaurant from database
        logger.info("Step 1: Connecting to database...")
        with DatabaseManager() as db:
            restaurant = db.get_restaurant_by_name(RESTAURANT_NAME)

            if not restaurant:
                logger.error(f"Restaurant '{RESTAURANT_NAME}' not found in database")
                logger.info("Please ensure the restaurant exists in menuca_v3.restaurants")
                return

            restaurant_db_id = restaurant['id']
            logger.info(f"Found restaurant: {restaurant['name']} (ID: {restaurant_db_id})")

            # Check existing data
            course_count = db.get_course_count(restaurant_db_id)
            dish_count = db.get_dish_count(restaurant_db_id)
            logger.info(f"Existing data: {course_count} courses, {dish_count} dishes")

            # Step 2: Scrape menu from CRM
            logger.info("\nStep 2: Scraping menu from CRM...")
            with MenuScraper() as scraper:
                menu_data = scraper.scrape_restaurant_menu(RESTAURANT_CRM_ID)

            logger.info(f"Scraped {len(menu_data['courses'])} courses")

            # Step 3: Load data into database
            logger.info("\nStep 3: Loading data into database...")
            courses_created = 0
            dishes_created = 0

            for course_data in menu_data['courses']:
                logger.info(f"\nProcessing course: {course_data['name']}")

                # Insert course
                course_id = db.insert_course(
                    restaurant_id=restaurant_db_id,
                    name=course_data['name'],
                    description=course_data['description'],
                    display_order=course_data['display_order']
                )

                if course_id:
                    courses_created += 1
                    logger.info(f"  ✓ Course created/updated (ID: {course_id})")

                    # Insert dishes
                    for dish_data in course_data['dishes']:
                        dish_id = db.insert_dish(
                            restaurant_id=restaurant_db_id,
                            course_id=course_id,
                            name=dish_data['name'],
                            description=dish_data['description'],
                            display_order=dish_data['display_order'],
                            legacy_menu_entry_id=dish_data['menu_entry_id']
                        )

                        if dish_id:
                            dishes_created += 1
                            logger.info(f"    ✓ Dish: {dish_data['name']}")

            # Step 4: Summary
            logger.info("\n" + "="*60)
            logger.info("SUMMARY")
            logger.info("="*60)
            logger.info(f"Restaurant: {restaurant['name']}")
            logger.info(f"Courses processed: {courses_created}")
            logger.info(f"Dishes processed: {dishes_created}")

            # Check final counts
            final_course_count = db.get_course_count(restaurant_db_id)
            final_dish_count = db.get_dish_count(restaurant_db_id)
            logger.info(f"\nFinal database state:")
            logger.info(f"  Total courses: {final_course_count}")
            logger.info(f"  Total dishes: {final_dish_count}")

            logger.info("\n✅ Proof of concept completed successfully!")

    except Exception as e:
        logger.error(f"❌ Error during scraping: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
