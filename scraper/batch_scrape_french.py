"""Batch scraper for French menu restaurants."""
import json
import logging
import time
from datetime import datetime
from pathlib import Path

from scraper_french import FrenchMenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_scrape_french.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def load_progress():
    """Load scraping progress from file."""
    progress_file = Path('french_scrape_progress.json')
    if progress_file.exists():
        with open(progress_file, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': []}


def save_progress(progress):
    """Save scraping progress to file."""
    with open('french_scrape_progress.json', 'w') as f:
        json.dump(progress, f, indent=2)


def load_results():
    """Load detailed results from file."""
    results_file = Path('french_scrape_results.json')
    if results_file.exists():
        with open(results_file, 'r') as f:
            return json.load(f)
    return {}


def save_results(results):
    """Save detailed results to file."""
    with open('french_scrape_results.json', 'w') as f:
        json.dump(results, f, indent=2)


def main():
    """Main batch scraping function."""
    start_time = datetime.now()

    logger.info("=" * 60)
    logger.info("Batch French Menu Scraper")
    logger.info("=" * 60)

    # Load French restaurants
    with open('french_restaurants.json', 'r', encoding='utf-8') as f:
        french_restaurants = json.load(f)

    logger.info(f"Loaded {len(french_restaurants)} French restaurants")

    # Load progress
    progress = load_progress()
    results = load_results()

    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))

    # Filter restaurants to process
    to_process = [r for r in french_restaurants if r['crm_id'] not in completed]

    logger.info(f"Already completed: {len(completed)}")
    logger.info(f"Previously failed: {len(failed)}")
    logger.info(f"Remaining to process: {len(to_process)}")

    if not to_process:
        logger.info("All restaurants already processed!")
        return

    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connection established")

    # Initialize scraper
    scraper = FrenchMenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")

    # Track statistics
    total_courses = 0
    total_dishes = 0
    successful = 0
    errors = 0

    try:
        for idx, restaurant in enumerate(to_process, 1):
            crm_id = restaurant['crm_id']
            db_id = restaurant['db_id']
            name = restaurant['name']

            logger.info("")
            logger.info(f"[{idx}/{len(to_process)}] Processing: {name}")
            logger.info(f"Scraping: {name} (DB:{db_id}, CRM:{crm_id})")

            try:
                # Scrape menu
                courses, dishes = scraper.scrape_restaurant_menu(crm_id)

                if not courses and not dishes:
                    logger.error(f"  CRITICAL: No menu data found for {name} (CRM ID: {crm_id})")
                    logger.error(f"  This restaurant may still not have accessible menu data")
                    failed.add(crm_id)
                    progress['failed'] = list(failed)
                    save_progress(progress)
                    errors += 1
                    results[str(crm_id)] = {
                        'name': name,
                        'status': 'failed',
                        'error': 'No menu data found',
                        'courses': 0,
                        'dishes': 0
                    }
                    save_results(results)
                    continue

                # Insert courses and dishes into database
                course_ids = []
                dish_ids = []

                for course in courses:
                    course_id = db.insert_course(
                        restaurant_id=db_id,
                        name=course['name'],
                        description=course['description'],
                        display_order=course['display_order']
                    )
                    if course_id:
                        course_ids.append(course_id)

                for dish in dishes:
                    # Get the course_id for this dish
                    course_idx = dish['course_index']
                    if course_idx < len(course_ids):
                        course_id = course_ids[course_idx]
                        dish_id = db.insert_dish(
                            restaurant_id=db_id,
                            course_id=course_id,
                            name=dish['name'],
                            description=dish['description'],
                            display_order=dish['display_order'],
                            legacy_menu_entry_id=dish['source_id']
                        )
                        if dish_id:
                            dish_ids.append(dish_id)

                logger.info(f"  Success: {len(courses)} courses, {len(dishes)} dishes")

                total_courses += len(courses)
                total_dishes += len(dishes)
                successful += 1

                # Mark as completed
                completed.add(crm_id)
                progress['completed'] = list(completed)
                save_progress(progress)

                # Save detailed results
                results[str(crm_id)] = {
                    'name': name,
                    'status': 'success',
                    'courses': len(courses),
                    'dishes': len(dishes),
                    'course_ids': course_ids,
                    'dish_ids': dish_ids
                }
                save_results(results)

                # Small delay between restaurants
                time.sleep(2)

            except Exception as e:
                logger.error(f"  Failed: {e}")
                errors += 1
                failed.add(crm_id)
                progress['failed'] = list(failed)
                save_progress(progress)

                results[str(crm_id)] = {
                    'name': name,
                    'status': 'error',
                    'error': str(e),
                    'courses': 0,
                    'dishes': 0
                }
                save_results(results)

    except KeyboardInterrupt:
        logger.info("\nScraping interrupted by user")

    finally:
        scraper.stop()
        db.close()

    # Print summary
    duration = datetime.now() - start_time

    logger.info("")
    logger.info("=" * 60)
    logger.info("BATCH SCRAPING SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total restaurants: {len(french_restaurants)}")
    logger.info(f"Already completed: {len(completed) - successful}")
    logger.info(f"Processed this run: {len(to_process)}")
    logger.info(f"  Successful: {successful}")
    logger.info(f"  Failed: {errors}")
    logger.info("")
    logger.info(f"Total courses inserted: {total_courses}")
    logger.info(f"Total dishes inserted: {total_dishes}")
    logger.info("")
    logger.info("Results saved to: french_scrape_results.json")
    logger.info("Progress saved to: french_scrape_progress.json")
    logger.info("Log saved to: batch_scrape_french.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()

