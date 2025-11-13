"""Test French menu scraper with a single restaurant."""
import logging
from scraper_french import FrenchMenuScraper
from database import DatabaseManager

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def test_single_french_restaurant():
    """Test scraping a single French restaurant."""
    
    # Test with Dépanneur Généreux
    test_restaurant = {
        'name': 'Dépanneur Généreux',
        'db_id': 816,
        'crm_id': 1060
    }
    
    logger.info("=" * 60)
    logger.info("Testing French Menu Scraper")
    logger.info("=" * 60)
    logger.info(f"Restaurant: {test_restaurant['name']}")
    logger.info(f"Database ID: {test_restaurant['db_id']}")
    logger.info(f"CRM ID: {test_restaurant['crm_id']}")
    logger.info("")
    
    # Initialize scraper
    scraper = FrenchMenuScraper()
    scraper.start()
    
    try:
        # Scrape menu
        logger.info("Scraping French menu...")
        courses, dishes = scraper.scrape_restaurant_menu(test_restaurant['crm_id'])
        
        logger.info(f"✅ Found {len(courses)} courses and {len(dishes)} dishes")
        logger.info("")
        
        # Display sample data
        if courses:
            logger.info("📚 SAMPLE COURSES:")
            for i, course in enumerate(courses[:3], 1):
                logger.info(f"  {i}. {course['name']}")
                if course['description']:
                    logger.info(f"     Description: {course['description'][:100]}...")
            logger.info("")
        
        if dishes:
            logger.info("🍽️ SAMPLE DISHES:")
            for i, dish in enumerate(dishes[:5], 1):
                logger.info(f"  {i}. {dish['name']}")
                if dish['description']:
                    logger.info(f"     Description: {dish['description'][:80]}...")
                logger.info(f"     Source ID: {dish['source_id']}")
            logger.info("")
        
        if not courses and not dishes:
            logger.error("❌ No menu data found!")
            logger.error("This restaurant may still not have accessible menu data")
            logger.error("Try checking the CRM manually:")
            logger.error(f"https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant={test_restaurant['crm_id']}&load=menu&showLang=fr")
            return False
        
        # Test database insertion (optional - comment out if you don't want to insert)
        logger.info("Testing database insertion...")
        db = DatabaseManager()
        db.connect()
        
        try:
            # Insert first course as a test
            if courses:
                course_id = db.insert_course(
                    restaurant_id=test_restaurant['db_id'],
                    name=f"[TEST] {courses[0]['name']}",
                    description=courses[0]['description'],
                    display_order=courses[0]['display_order']
                )
                logger.info(f"✅ Test course inserted with ID: {course_id}")
                
                # Clean up test data
                logger.info("Cleaning up test data...")
                db.cursor.execute(f"DELETE FROM menuca_v3.courses WHERE id = {course_id}")
                db.conn.commit()
                logger.info("✅ Test data cleaned up")
        
        finally:
            db.close()
        
        logger.info("")
        logger.info("=" * 60)
        logger.info("✅ TEST PASSED!")
        logger.info("=" * 60)
        logger.info("The French scraper is working correctly.")
        logger.info("You can now run: python batch_scrape_french.py")
        logger.info("=" * 60)
        
        return True
        
    except Exception as e:
        logger.error(f"❌ TEST FAILED: {e}")
        logger.exception(e)
        return False
        
    finally:
        scraper.stop()


if __name__ == "__main__":
    test_single_french_restaurant()

