#!/usr/bin/env python3
"""
Batch scraper for all active restaurants.
Processes all restaurants from restaurants_list.csv that are active and have CRM IDs.
"""

import csv
import json
import time
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from database import DatabaseManager
from scraper import MenuScraper
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_scrape.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Configuration
PROGRESS_FILE = 'scrape_progress.json'
RESULTS_FILE = 'scrape_results.json'
DELAY_BETWEEN_RESTAURANTS = 2  # seconds
V2_ONLY_FILE = 'v2_only_restaurants.csv'  # Restaurants not in CRM


def load_progress() -> Dict:
    """Load progress from previous run."""
    if Path(PROGRESS_FILE).exists():
        with open(PROGRESS_FILE, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}


def save_progress(progress: Dict):
    """Save progress to file."""
    with open(PROGRESS_FILE, 'w') as f:
        json.dump(progress, f, indent=2)


def load_v2_only_restaurants() -> set:
    """Load list of V2-only restaurants (not in CRM)."""
    v2_only = set()
    try:
        with open(V2_ONLY_FILE, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                v2_only.add(row['restaurant_name'])
    except FileNotFoundError:
        logger.warning(f"V2-only restaurants file not found: {V2_ONLY_FILE}")
    return v2_only


def load_restaurant_list() -> List[Dict]:
    """Load active restaurants with CRM IDs from CSV, excluding V2-only restaurants."""
    v2_only = load_v2_only_restaurants()
    logger.info(f"Loaded {len(v2_only)} V2-only restaurants to exclude")

    restaurants = []
    with open('restaurants_list.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Only process active restaurants with CRM IDs
            if row['status'] == 'active' and row['crm_id']:
                # Skip V2-only restaurants
                if row['name'] in v2_only:
                    logger.info(f"Skipping V2-only restaurant: {row['name']}")
                    continue

                restaurants.append({
                    'db_id': int(row['db_id']),
                    'name': row['name'],
                    'crm_id': int(row['crm_id']),
                    'status': row['status']
                })
    return restaurants


def scrape_restaurant(db: DatabaseManager, scraper: MenuScraper,
                      restaurant: Dict) -> Dict:
    """
    Scrape a single restaurant and return results.

    Returns:
        Dict with 'success', 'courses', 'dishes', 'error' keys

    Raises:
        Exception: If restaurant not found or no menu data (stops the process)
    """
    result = {
        'db_id': restaurant['db_id'],
        'name': restaurant['name'],
        'crm_id': restaurant['crm_id'],
        'success': False,
        'courses': 0,
        'dishes': 0,
        'error': None
    }

    try:
        logger.info(f"Scraping: {restaurant['name']} (DB:{restaurant['db_id']}, CRM:{restaurant['crm_id']})")

        # Scrape menu data
        menu_data = scraper.scrape_restaurant_menu(restaurant['crm_id'])

        if not menu_data or not menu_data.get('courses'):
            # STOP THE PROCESS - Restaurant not found or no menu data
            error_msg = f"CRITICAL: No menu data found for {restaurant['name']} (CRM ID: {restaurant['crm_id']})"
            logger.error(f"  {error_msg}")
            logger.error(f"  This restaurant may not exist in menuadmin.menu.ca")
            logger.error(f"  STOPPING BATCH PROCESS")
            raise Exception(error_msg)

        # Insert courses and dishes
        courses_inserted = 0
        dishes_inserted = 0

        for course_data in menu_data['courses']:
            # Insert course
            course_id = db.insert_course(
                restaurant_id=restaurant['db_id'],
                name=course_data['name'],
                description=course_data.get('description', ''),
                display_order=course_data['display_order']
            )

            if course_id:
                courses_inserted += 1

                # Insert dishes for this course
                for dish_data in course_data.get('dishes', []):
                    dish_id = db.insert_dish(
                        restaurant_id=restaurant['db_id'],
                        course_id=course_id,
                        name=dish_data['name'],
                        description=dish_data.get('description', ''),
                        display_order=dish_data['display_order'],
                        legacy_menu_entry_id=dish_data.get('menu_entry_id')
                    )

                    if dish_id:
                        dishes_inserted += 1

        result['success'] = True
        result['courses'] = courses_inserted
        result['dishes'] = dishes_inserted

        logger.info(f"  Success: {courses_inserted} courses, {dishes_inserted} dishes")

    except Exception as e:
        result['error'] = str(e)
        logger.error(f"  Failed: {e}")

    return result


def main():
    """Main batch scraping function."""
    start_time = datetime.now()
    logger.info("=" * 60)
    logger.info("Batch Menu Scraper - All Active Restaurants")
    logger.info("=" * 60)

    # Load restaurant list
    restaurants = load_restaurant_list()
    logger.info(f"Loaded {len(restaurants)} active restaurants with CRM IDs")

    # Load progress
    progress = load_progress()
    completed_ids = set(progress.get('completed', []))

    # Filter out already completed
    remaining = [r for r in restaurants if r['db_id'] not in completed_ids]
    logger.info(f"Already completed: {len(completed_ids)}")
    logger.info(f"Remaining to process: {len(remaining)}")

    if not remaining:
        logger.info("All restaurants already processed!")
        return

    # Connect to database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connected")

    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")

    # Process restaurants SEQUENTIALLY (one at a time)
    results = []
    success_count = 0
    failed_count = 0
    skipped_count = 0

    try:
        for i, restaurant in enumerate(remaining, 1):
            logger.info(f"\n[{i}/{len(remaining)}] Processing: {restaurant['name']}")

            try:
                result = scrape_restaurant(db, scraper, restaurant)
                results.append(result)

                if result['success']:
                    success_count += 1
                    progress['completed'].append(restaurant['db_id'])

                # Save progress after each restaurant
                save_progress(progress)

                # Delay between restaurants (rate limiting)
                if i < len(remaining):
                    time.sleep(DELAY_BETWEEN_RESTAURANTS)

            except Exception as restaurant_error:
                # CRITICAL ERROR - Restaurant not found or no menu data
                # STOP THE ENTIRE PROCESS
                logger.error(f"\n\n{'='*60}")
                logger.error(f"PROCESS STOPPED DUE TO CRITICAL ERROR")
                logger.error(f"{'='*60}")
                logger.error(f"Restaurant: {restaurant['name']}")
                logger.error(f"Error: {restaurant_error}")
                logger.error(f"\nPlease review this restaurant manually before continuing.")
                logger.error(f"It may need to be added to v2_only_restaurants.csv")
                logger.error(f"{'='*60}\n")

                # Save error result
                result = {
                    'db_id': restaurant['db_id'],
                    'name': restaurant['name'],
                    'crm_id': restaurant['crm_id'],
                    'success': False,
                    'courses': 0,
                    'dishes': 0,
                    'error': str(restaurant_error)
                }
                results.append(result)
                progress['failed'].append(restaurant['db_id'])
                save_progress(progress)

                # Re-raise to stop the process
                raise

    except KeyboardInterrupt:
        logger.info("\n\nScraping interrupted by user")
    except Exception as e:
        logger.error(f"\n\nProcess stopped due to error (see above)")
    finally:
        # Cleanup
        scraper.stop()
        db.close()
        logger.info("\nBrowser stopped")
        logger.info("Database connection closed")

    # Save final results
    with open(RESULTS_FILE, 'w') as f:
        json.dump(results, f, indent=2)

    # Summary
    end_time = datetime.now()
    duration = end_time - start_time

    logger.info("\n" + "=" * 60)
    logger.info("BATCH SCRAPING SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total restaurants: {len(restaurants)}")
    logger.info(f"Already completed: {len(completed_ids)}")
    logger.info(f"Processed this run: {len(results)}")
    logger.info(f"  Successful: {success_count}")
    logger.info(f"  Skipped (no data): {skipped_count}")
    logger.info(f"  Failed: {failed_count}")
    logger.info(f"\nTotal courses inserted: {sum(r['courses'] for r in results)}")
    logger.info(f"Total dishes inserted: {sum(r['dishes'] for r in results)}")
    logger.info(f"\nResults saved to: {RESULTS_FILE}")
    logger.info(f"Progress saved to: {PROGRESS_FILE}")
    logger.info(f"Log saved to: batch_scrape.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()
