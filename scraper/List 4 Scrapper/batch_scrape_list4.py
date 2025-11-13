#!/usr/bin/env python3
"""
Batch scraper for List 4 restaurants (V1 Restaurants NOT Scraped).
Phase 1: Scrapes courses and dishes for each restaurant.
"""
import json
import logging
import time
from datetime import datetime
from pathlib import Path

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_scrape_list4.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def load_progress():
    """Load scraping progress from file."""
    progress_file = Path('list4_scrape_progress.json')
    if progress_file.exists():
        with open(progress_file, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}


def save_progress(progress):
    """Save scraping progress to file."""
    with open('list4_scrape_progress.json', 'w') as f:
        json.dump(progress, f, indent=2)


def load_results():
    """Load detailed results from file."""
    results_file = Path('list4_scrape_results.json')
    if results_file.exists():
        with open(results_file, 'r') as f:
            return json.load(f)
    return []


def save_results(results):
    """Save detailed results to file."""
    with open('list4_scrape_results.json', 'w') as f:
        json.dump(results, f, indent=2)


def check_french_language(scraper, restaurant_id):
    """
    Check if the restaurant has menu data in French.
    Returns True if French menu should be used, False for English.
    """
    try:
        # Try English first
        url_en = f"{scraper.base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=menu&showLang=en"
        scraper.page.goto(url_en, wait_until='networkidle')
        time.sleep(scraper.delay)
        
        html_en = scraper.page.content()
        
        # Check if English menu has courses
        if 'list-style-type: none' in html_en and '<h3>' in html_en:
            return False  # English menu has data
        
        # Try French
        url_fr = f"{scraper.base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=menu&showLang=fr"
        scraper.page.goto(url_fr, wait_until='networkidle')
        time.sleep(scraper.delay)
        
        html_fr = scraper.page.content()
        
        # Check if French menu has courses
        if 'list-style-type: none' in html_fr and '<h3>' in html_fr:
            return True  # French menu has data
        
        return False  # Default to English
        
    except Exception as e:
        logger.warning(f"Error checking language for restaurant {restaurant_id}: {e}")
        return False


def main():
    """Main batch scraping function."""
    start_time = datetime.now()

    logger.info("=" * 60)
    logger.info("Batch Scraper - List 4 Restaurants (Phase 1)")
    logger.info("=" * 60)

    # Load List 4 restaurants
    with open('list4_restaurants.json', 'r', encoding='utf-8') as f:
        list4_restaurants = json.load(f)

    logger.info(f"Loaded {len(list4_restaurants)} List 4 restaurants")

    # Load progress
    progress = load_progress()
    results = load_results()

    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))
    skipped = set(progress.get('skipped', []))

    # Filter restaurants to process
    to_process = [r for r in list4_restaurants if r['crm_id'] not in completed]

    logger.info(f"Already completed: {len(completed)}")
    logger.info(f"Previously failed: {len(failed)}")
    logger.info(f"Previously skipped: {len(skipped)}")
    logger.info(f"Remaining to process: {len(to_process)}")

    if not to_process:
        logger.info("All restaurants already processed!")
        return

    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connection established")

    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")

    # Track statistics
    total_courses = 0
    total_dishes = 0
    successful = 0
    errors = 0
    skipped_no_data = 0

    try:
        for idx, restaurant in enumerate(to_process, 1):
            crm_id = restaurant['crm_id']
            db_id = restaurant['db_id']
            name = restaurant['name']

            logger.info("")
            logger.info(f"[{idx}/{len(to_process)}] Processing: {name}")
            logger.info(f"Scraping: {name} (DB:{db_id}, CRM:{crm_id})")

            try:
                # Check which language has menu data
                use_french = check_french_language(scraper, crm_id)
                lang = 'fr' if use_french else 'en'
                logger.info(f"  Using language: {lang.upper()}")

                # Scrape menu (will automatically use the correct language based on the check above)
                menu_data = scraper.scrape_restaurant_menu(crm_id)

                if not menu_data or not menu_data.get('courses'):
                    logger.warning(f"  No menu data found for {name} (CRM ID: {crm_id})")
                    skipped.add(crm_id)
                    progress['skipped'] = list(skipped)
                    save_progress(progress)
                    skipped_no_data += 1
                    results.append({
                        'restaurant_id': crm_id,
                        'db_id': db_id,
                        'name': name,
                        'status': 'skipped',
                        'reason': 'No menu data found',
                        'courses': 0,
                        'dishes': 0,
                        'language': lang
                    })
                    save_results(results)
                    continue

                # Insert courses and dishes into database
                courses_inserted = 0
                dishes_inserted = 0

                for course_data in menu_data['courses']:
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

                logger.info(f"  Success: {courses_inserted} courses, {dishes_inserted} dishes")

                total_courses += courses_inserted
                total_dishes += dishes_inserted
                successful += 1

                # Mark as completed
                completed.add(crm_id)
                progress['completed'] = list(completed)
                save_progress(progress)

                # Save detailed results
                results.append({
                    'restaurant_id': crm_id,
                    'db_id': db_id,
                    'name': name,
                    'status': 'success',
                    'courses': courses_inserted,
                    'dishes': dishes_inserted,
                    'language': lang
                })
                save_results(results)

                # Small delay between restaurants
                time.sleep(2)

            except Exception as e:
                logger.error(f"  Failed: {e}")
                errors += 1
                failed.add(crm_id)
                progress['failed'] = list(failed)
                save_progress(progress)

                results.append({
                    'restaurant_id': crm_id,
                    'db_id': db_id,
                    'name': name,
                    'status': 'error',
                    'error': str(e),
                    'courses': 0,
                    'dishes': 0
                })
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
    logger.info("BATCH SCRAPING SUMMARY - LIST 4 PHASE 1")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total restaurants: {len(list4_restaurants)}")
    logger.info(f"Already completed: {len(completed) - successful}")
    logger.info(f"Processed this run: {len(to_process)}")
    logger.info(f"  Successful: {successful}")
    logger.info(f"  Skipped (no data): {skipped_no_data}")
    logger.info(f"  Failed: {errors}")
    logger.info("")
    logger.info(f"Total courses inserted: {total_courses}")
    logger.info(f"Total dishes inserted: {total_dishes}")
    logger.info("")
    logger.info("Results saved to: list4_scrape_results.json")
    logger.info("Progress saved to: list4_scrape_progress.json")
    logger.info("Log saved to: batch_scrape_list4.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()



