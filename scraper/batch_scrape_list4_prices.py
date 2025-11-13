#!/usr/bin/env python3
"""
Batch scraper for List 4 restaurants (V1 Restaurants NOT Scraped).
Phase 2: Scrapes prices and modifiers for each dish.
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
        logging.FileHandler('batch_scrape_list4_prices.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def load_progress():
    """Load scraping progress from file."""
    progress_file = Path('list4_prices_progress.json')
    if progress_file.exists():
        with open(progress_file, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}


def save_progress(progress):
    """Save scraping progress to file."""
    with open('list4_prices_progress.json', 'w') as f:
        json.dump(progress, f, indent=2)


def load_results():
    """Load detailed results from file."""
    results_file = Path('list4_prices_results.json')
    if results_file.exists():
        with open(results_file, 'r') as f:
            return json.load(f)
    return []


def save_results(results):
    """Save detailed results to file."""
    with open('list4_prices_results.json', 'w') as f:
        json.dump(results, f, indent=2)


def determine_language(restaurant_id, db):
    """
    Determine which language to use for scraping based on Phase 1 results.
    Returns 'en' or 'fr'.
    """
    # Try to load language from Phase 1 results
    results_file = Path('list4_scrape_results.json')
    if results_file.exists():
        with open(results_file, 'r') as f:
            phase1_results = json.load(f)
            for result in phase1_results:
                if result.get('restaurant_id') == restaurant_id:
                    return result.get('language', 'en')
    
    # Default to English if not found
    return 'en'


def main():
    """Main batch scraping function for prices and modifiers."""
    start_time = datetime.now()

    logger.info("=" * 60)
    logger.info("Batch Scraper - List 4 Restaurants (Phase 2)")
    logger.info("=" * 60)

    # Load List 4 restaurants from Phase 1 results
    with open('list4_scrape_results.json', 'r', encoding='utf-8') as f:
        phase1_results = json.load(f)
    
    # Filter to only successful restaurants from Phase 1
    list4_restaurants = [r for r in phase1_results if r['status'] == 'success']
    
    logger.info(f"Loaded {len(list4_restaurants)} restaurants from Phase 1")

    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connection established")

    # Get all dishes that need prices/modifiers
    restaurant_ids = [r['db_id'] for r in list4_restaurants]
    db_ids_str = ','.join(map(str, restaurant_ids))

    query = f"""
        SELECT 
            d.id AS dish_id,
            d.name AS dish_name,
            d.source_id AS menu_entry_id,
            d.restaurant_id AS db_restaurant_id,
            r.name AS restaurant_name,
            r.legacy_v1_id AS crm_restaurant_id
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        WHERE d.restaurant_id IN ({db_ids_str})
          AND d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
          AND r.deleted_at IS NULL
        ORDER BY d.restaurant_id, d.id
    """

    db.cursor.execute(query)
    dishes = db.cursor.fetchall()

    logger.info(f"Found {len(dishes):,} dishes to process")

    # Load progress
    progress = load_progress()
    results = load_results()

    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))
    skipped = set(progress.get('skipped', []))

    # Filter dishes to process
    to_process = [d for d in dishes if d['dish_id'] not in completed]

    logger.info(f"Already completed: {len(completed)}")
    logger.info(f"Previously failed: {len(failed)}")
    logger.info(f"Previously skipped: {len(skipped)}")
    logger.info(f"Remaining to process: {len(to_process)}")

    if not to_process:
        logger.info("All dishes already processed!")
        db.close()
        return

    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")

    # Track statistics
    total_prices = 0
    total_modifier_groups = 0
    total_modifier_items = 0
    total_modifier_prices = 0
    successful = 0
    errors = 0
    skipped_no_data = 0

    # Group dishes by restaurant for language determination
    restaurant_languages = {}

    try:
        for idx, dish in enumerate(to_process, 1):
            dish_id = dish['dish_id']
            dish_name = dish['dish_name']
            menu_entry_id = dish['menu_entry_id']
            crm_restaurant_id = dish['crm_restaurant_id']
            db_restaurant_id = dish['db_restaurant_id']
            restaurant_name = dish['restaurant_name']

            # Determine language for this restaurant
            if crm_restaurant_id not in restaurant_languages:
                restaurant_languages[crm_restaurant_id] = determine_language(crm_restaurant_id, db)
            
            language = restaurant_languages[crm_restaurant_id]

            logger.info("")
            logger.info(f"[{idx}/{len(to_process)}] Processing dish {dish_id}: {dish_name}")
            logger.info(f"Scraping dish: {dish_name} (Dish ID: {dish_id}, Entry: {menu_entry_id})")

            try:
                # Scrape dish details with appropriate language
                details = scraper.scrape_dish_details(
                    crm_restaurant_id, 
                    menu_entry_id,
                    language=language
                )

                if not details:
                    logger.warning(f"  No details found for dish {dish_id}")
                    skipped.add(dish_id)
                    progress['skipped'] = list(skipped)
                    save_progress(progress)
                    skipped_no_data += 1
                    results.append({
                        'dish_id': dish_id,
                        'dish_name': dish_name,
                        'restaurant_name': restaurant_name,
                        'status': 'skipped',
                        'reason': 'No details found',
                        'language': language
                    })
                    save_results(results)
                    continue

                logger.info(f"Scraped details for menu entry {menu_entry_id}: "
                           f"{len(details.get('prices', []))} prices, "
                           f"{len(details.get('modifiers', []))} modifier groups")

                # Insert prices
                prices_inserted = 0
                for price in details.get('prices', []):
                    price_id = db.insert_dish_price(
                        dish_id=dish_id,
                        size=price['size'],
                        amount=price['amount']
                    )
                    if price_id:
                        prices_inserted += 1

                # Insert modifiers
                modifiers_inserted = 0
                modifier_items_inserted = 0
                modifier_prices_inserted = 0

                for modifier in details.get('modifiers', []):
                    # Insert modifier group
                    group_id = db.insert_modifier_group(
                        dish_id=dish_id,
                        name=modifier['name'],
                        min_selections=modifier.get('min_selections', 0),
                        max_selections=modifier.get('max_selections', 0),
                        display_order=modifier.get('display_order', 0)
                    )

                    if group_id:
                        modifiers_inserted += 1

                        # Insert modifier items
                        for item in modifier.get('items', []):
                            item_id = db.insert_modifier_item(
                                modifier_group_id=group_id,
                                name=item['name'],
                                display_order=item.get('display_order', 0)
                            )

                            if item_id:
                                modifier_items_inserted += 1

                                # Insert modifier prices
                                for price in item.get('prices', []):
                                    price_id = db.insert_modifier_price(
                                        modifier_item_id=item_id,
                                        size=price['size'],
                                        amount=price['amount']
                                    )

                                    if price_id:
                                        modifier_prices_inserted += 1

                logger.info(f"Success: {prices_inserted} prices, {modifiers_inserted} groups, "
                           f"{modifier_items_inserted} items, {modifier_prices_inserted} modifier prices")

                total_prices += prices_inserted
                total_modifier_groups += modifiers_inserted
                total_modifier_items += modifier_items_inserted
                total_modifier_prices += modifier_prices_inserted
                successful += 1

                # Mark as completed
                completed.add(dish_id)
                progress['completed'] = list(completed)
                save_progress(progress)

                # Save detailed results
                results.append({
                    'dish_id': dish_id,
                    'dish_name': dish_name,
                    'restaurant_name': restaurant_name,
                    'status': 'success',
                    'prices_count': prices_inserted,
                    'modifier_groups_count': modifiers_inserted,
                    'modifier_items_count': modifier_items_inserted,
                    'modifier_prices_count': modifier_prices_inserted,
                    'language': language
                })
                save_results(results)

                # Small delay between dishes
                time.sleep(0.5)

            except Exception as e:
                logger.error(f"  Failed: {e}")
                errors += 1
                failed.add(dish_id)
                progress['failed'] = list(failed)
                save_progress(progress)

                results.append({
                    'dish_id': dish_id,
                    'dish_name': dish_name,
                    'restaurant_name': restaurant_name,
                    'status': 'error',
                    'error': str(e)
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
    logger.info("BATCH SCRAPING SUMMARY - LIST 4 PHASE 2")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total dishes: {len(dishes):,}")
    logger.info(f"Already completed: {len(completed) - successful}")
    logger.info(f"Processed this run: {len(to_process)}")
    logger.info(f"  Successful: {successful}")
    logger.info(f"  Skipped (no data): {skipped_no_data}")
    logger.info(f"  Failed: {errors}")
    logger.info("")
    logger.info(f"Total prices inserted: {total_prices:,}")
    logger.info(f"Total modifier groups inserted: {total_modifier_groups:,}")
    logger.info(f"Total modifier items inserted: {total_modifier_items:,}")
    logger.info(f"Total modifier prices inserted: {total_modifier_prices:,}")
    logger.info("")
    logger.info("Results saved to: list4_prices_results.json")
    logger.info("Progress saved to: list4_prices_progress.json")
    logger.info("Log saved to: batch_scrape_list4_prices.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()



