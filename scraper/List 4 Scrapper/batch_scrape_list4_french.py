#!/usr/bin/env python3
"""
Batch scraper for List 4 French restaurants.
These 12 restaurants have French menus that weren't detected by the standard scraper.
Phase 1: Scrapes courses and dishes for each restaurant using French menu URL pattern.
"""
import sys
import os
import json
import logging
import time
from datetime import datetime
from pathlib import Path

# Add parent directory to path so we can import scraper and database modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scraper_french import FrenchMenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_scrape_list4_french.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# List 4 French restaurants that were skipped
LIST4_FRENCH_RESTAURANTS = [
    {'name': 'Erman Pizza', 'db_id': 211, 'crm_id': 350},
    {'name': 'Kabylie Pizza', 'db_id': 798, 'crm_id': 1042},
    {'name': 'Mozza Pizza Gatineau', 'db_id': 1011, 'crm_id': 132},
    {'name': 'Papa Grecque Cantley', 'db_id': 810, 'crm_id': 1054},
    {'name': 'Papa Pizza - Hull', 'db_id': 70, 'crm_id': 184},
    {'name': 'Papa Pizza Cantley', 'db_id': 602, 'crm_id': 825},
    {'name': 'Papa Pizza Des Flandres', 'db_id': 1012, 'crm_id': 231},
    {'name': 'Papa Pizza Maloney', 'db_id': 1013, 'crm_id': 346},
    {'name': 'Papa Pizza Val-Des-Monts', 'db_id': 1014, 'crm_id': 703},
    {'name': 'Pizza Bravo', 'db_id': 139, 'crm_id': 264},
    {'name': 'Roulas Grecque et Pizza', 'db_id': 1016, 'crm_id': 173},
    {'name': 'Sushi Express Chambly', 'db_id': 1017, 'crm_id': 511}
]


def load_progress():
    """Load scraping progress from file."""
    progress_file = Path('list4_french_progress.json')
    if progress_file.exists():
        with open(progress_file, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}


def save_progress(progress):
    """Save scraping progress to file."""
    with open('list4_french_progress.json', 'w') as f:
        json.dump(progress, f, indent=2)


def load_results():
    """Load detailed results from file."""
    results_file = Path('list4_french_results.json')
    if results_file.exists():
        with open(results_file, 'r') as f:
            return json.load(f)
    return []


def save_results(results):
    """Save detailed results to file."""
    with open('list4_french_results.json', 'w') as f:
        json.dump(results, f, indent=2)


def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))


def main():
    """Main batch scraping function for List 4 French restaurants."""
    start_time = datetime.now()

    logger.info("=" * 60)
    logger.info("Batch Scraper - List 4 French Restaurants (Phase 1)")
    logger.info("=" * 60)
    logger.info(f"Loaded {len(LIST4_FRENCH_RESTAURANTS)} French restaurants")

    # Load progress
    progress = load_progress()
    results = load_results()

    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))
    skipped = set(progress.get('skipped', []))

    # Filter restaurants to process
    to_process = [r for r in LIST4_FRENCH_RESTAURANTS if r['crm_id'] not in completed]

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

    # Initialize French scraper
    scraper = FrenchMenuScraper()
    scraper.start()
    logger.info("French scraper initialized and logged in")

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
                # Scrape French menu
                courses, dishes = scraper.scrape_restaurant_menu(crm_id)

                if not courses and not dishes:
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
                        'dishes': 0
                    })
                    save_results(results)
                    continue

                # Insert courses and dishes into database
                courses_inserted = 0
                dishes_inserted = 0
                course_ids = []

                # Check database connection before inserting
                if not db.conn or db.conn.closed:
                    logger.warning("Database connection lost, reconnecting...")
                    db.connect()
                    logger.info("Database reconnection successful")

                # Insert courses
                for course in courses:
                    course_id = db.insert_course(
                        restaurant_id=db_id,
                        name=course['name'],
                        description=course.get('description', ''),
                        display_order=course['display_order']
                    )
                    if course_id:
                        courses_inserted += 1
                        course_ids.append(course_id)

                # Insert dishes
                for dish in dishes:
                    # Check connection periodically
                    if not db.conn or db.conn.closed:
                        logger.warning("Database connection lost, reconnecting...")
                        db.connect()
                        logger.info("Database reconnection successful")

                    # Get the course_id for this dish
                    course_idx = dish.get('course_index', 0)
                    if course_idx < len(course_ids) and course_ids[course_idx]:
                        dish_id = db.insert_dish(
                            restaurant_id=db_id,
                            course_id=course_ids[course_idx],
                            name=dish['name'],
                            description=dish.get('description', ''),
                            display_order=dish['display_order'],
                            legacy_menu_entry_id=dish.get('source_id') or dish.get('menu_entry_id')
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
                    'language': 'fr'
                })
                save_results(results)

                # Small delay between restaurants
                time.sleep(2)

            except Exception as e:
                logger.error(f"  Failed: {e}")
                import traceback
                traceback.print_exc()
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
    logger.info("BATCH SCRAPING SUMMARY - LIST 4 FRENCH RESTAURANTS")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total restaurants: {len(LIST4_FRENCH_RESTAURANTS)}")
    logger.info(f"Already completed: {len(completed) - successful}")
    logger.info(f"Processed this run: {len(to_process)}")
    logger.info(f"  Successful: {successful}")
    logger.info(f"  Skipped (no data): {skipped_no_data}")
    logger.info(f"  Failed: {errors}")
    logger.info("")
    logger.info(f"Total courses inserted: {total_courses}")
    logger.info(f"Total dishes inserted: {total_dishes}")
    logger.info("")
    logger.info("Results saved to: list4_french_results.json")
    logger.info("Progress saved to: list4_french_progress.json")
    logger.info("Log saved to: batch_scrape_list4_french.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()

