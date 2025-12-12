#!/usr/bin/env python3
"""
Special Combo Sections Scraper - Entry Point

Scrapes special combo sections that reference actual dishes from the menu
and stores them in the combo_group_dish_selections table.

Usage:
    # Test with Amicci Pizza (V3: 735, V1: 973)
    python run_special_combo_scraper.py --test

    # Run for all 12 restaurants with special combos
    python run_special_combo_scraper.py --all

    # Run for a specific restaurant
    python run_special_combo_scraper.py --restaurant-id 735

    # Run with visible browser (for debugging)
    python run_special_combo_scraper.py --test --no-headless
"""

import argparse
import logging
import sys
import os
from datetime import datetime
from typing import List, Dict, Any

# Add parent directories to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from special_combo_scraper import SpecialComboScraper
from special_combo_database import SpecialComboDatabase

# Hardcoded list of restaurants with special combo sections
SPECIAL_COMBO_RESTAURANTS = [
    {'v3_id': 118, 'v1_id': 238, 'name': 'Mano City Pizza'},
    {'v3_id': 123, 'v1_id': 245, 'name': 'Milano'},
    {'v3_id': 245, 'v1_id': 387, 'name': 'Orchid Sushi'},
    {'v3_id': 350, 'v1_id': 513, 'name': 'Milano'},
    {'v3_id': 607, 'v1_id': 830, 'name': 'Aroy Thai'},
    {'v3_id': 680, 'v1_id': 913, 'name': 'Milano'},
    {'v3_id': 735, 'v1_id': 973, 'name': 'Amicci Pizza'},  # TEST RESTAURANT
    {'v3_id': 756, 'v1_id': 998, 'name': 'Little Gyros Greek Grill'},
    {'v3_id': 790, 'v1_id': 1033, 'name': 'Nachos Loco Hull'},
    {'v3_id': 792, 'v1_id': 1035, 'name': 'Dumpling Bowl'},
    {'v3_id': 801, 'v1_id': 1045, 'name': 'Nachos Loco Gatineau'},
    {'v3_id': 833, 'v1_id': 1080, 'name': 'All Out Burger'},
]

# Test restaurant
TEST_RESTAURANT = {'v3_id': 735, 'v1_id': 973, 'name': 'Amicci Pizza'}


def setup_logging(log_dir: str = None) -> str:
    """Setup logging to both console and file."""
    if log_dir is None:
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
            'logs'
        )

    os.makedirs(log_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'special_combo_scraper_{timestamp}.log')

    # Configure root logger
    logging.basicConfig(
        level=logging.INFO,
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler(sys.stdout)
        ]
    )

    # Reduce noise from other loggers
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('playwright').setLevel(logging.WARNING)

    return log_file


def get_restaurants_to_process(args) -> List[Dict[str, Any]]:
    """Get list of restaurants to process based on arguments."""
    if args.test:
        return [TEST_RESTAURANT]
    elif args.all:
        return SPECIAL_COMBO_RESTAURANTS
    elif args.restaurant_id:
        # Find restaurant by V3 ID
        for r in SPECIAL_COMBO_RESTAURANTS:
            if r['v3_id'] == args.restaurant_id:
                return [r]
        # Not in list - try to get from database
        return [{'v3_id': args.restaurant_id, 'v1_id': None, 'name': 'Unknown'}]
    else:
        return []


def run_scraper(restaurants: List[Dict[str, Any]], headless: bool = True):
    """Run the special combo scraper for given restaurants."""
    logger = logging.getLogger(__name__)

    log_file = setup_logging()
    logger.info(f"Logging to: {log_file}")

    all_results = []

    with SpecialComboScraper(headless=headless) as scraper:
        # Login once
        if not scraper.login():
            logger.error("Login failed. Aborting.")
            return

        # Process each restaurant
        for restaurant in restaurants:
            v3_id = restaurant['v3_id']
            v1_id = restaurant['v1_id']
            name = restaurant['name']

            if not v1_id:
                # Try to get V1 ID from database
                db = SpecialComboDatabase()
                db.connect()
                r = db.get_restaurant_by_id(v3_id)
                db.close()
                if r and r.get('legacy_v1_id'):
                    v1_id = r['legacy_v1_id']
                else:
                    logger.warning(f"Skipping {name} (V3: {v3_id}) - no V1 ID")
                    continue

            logger.info("=" * 60)
            logger.info(f"Processing: {name} (V3: {v3_id}, V1: {v1_id})")
            logger.info("=" * 60)

            try:
                stats = scraper.scrape_special_combos(v3_id, v1_id)

                logger.info(f"Results for {name}:")
                logger.info(f"  - Combo groups processed: {stats['combo_groups_processed']}")
                logger.info(f"  - Special combos found: {stats['special_combos_found']}")
                logger.info(f"  - Dish selections inserted: {stats['dish_selections_inserted']}")
                logger.info(f"  - Dish lookups failed: {stats['dish_lookups_failed']}")

                all_results.append({
                    'restaurant': name,
                    'v3_id': v3_id,
                    'v1_id': v1_id,
                    **stats
                })

            except Exception as e:
                logger.error(f"Error processing {name}: {e}", exc_info=True)
                all_results.append({
                    'restaurant': name,
                    'v3_id': v3_id,
                    'v1_id': v1_id,
                    'error': str(e)
                })

    # Print final summary
    logger.info("=" * 60)
    logger.info("SPECIAL COMBO SCRAPER COMPLETE")
    logger.info("=" * 60)

    total_special = sum(r.get('special_combos_found', 0) for r in all_results)
    total_selections = sum(r.get('dish_selections_inserted', 0) for r in all_results)
    total_failed = sum(r.get('dish_lookups_failed', 0) for r in all_results)

    logger.info(f"Restaurants processed: {len(all_results)}")
    logger.info(f"Total special combos found: {total_special}")
    logger.info(f"Total dish selections inserted: {total_selections}")
    logger.info(f"Total dish lookups failed: {total_failed}")

    # Verify with database stats for test mode
    if len(restaurants) == 1 and restaurants[0]['v3_id'] == TEST_RESTAURANT['v3_id']:
        logger.info("")
        logger.info("=== TEST VERIFICATION ===")
        db = SpecialComboDatabase()
        db.connect()
        stats = db.get_special_combo_stats(TEST_RESTAURANT['v3_id'])
        db.close()
        logger.info(f"Database verification for Amicci Pizza (V3: 735):")
        logger.info(f"  - Special combo groups: {stats['special_combo_groups']}")
        logger.info(f"  - Dish selections in DB: {stats['dish_selections']}")
        logger.info(f"  - Expected: ~5 special combos, ~60 dish selections")


def main():
    parser = argparse.ArgumentParser(
        description='Special Combo Sections Scraper',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Test with Amicci Pizza
    python run_special_combo_scraper.py --test

    # Run for all restaurants
    python run_special_combo_scraper.py --all

    # Debug with visible browser
    python run_special_combo_scraper.py --test --no-headless
        """
    )

    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help='Test mode: Run only for Amicci Pizza (V3: 735, V1: 973)'
    )

    parser.add_argument(
        '--all', '-a',
        action='store_true',
        help='Process all 12 restaurants with special combo sections'
    )

    parser.add_argument(
        '--restaurant-id', '-r',
        type=int,
        help='V3 restaurant ID to process'
    )

    parser.add_argument(
        '--no-headless',
        action='store_true',
        help='Run browser in visible mode (for debugging)'
    )

    parser.add_argument(
        '--debug', '-d',
        action='store_true',
        help='Enable debug logging'
    )

    args = parser.parse_args()

    # Validate arguments
    if not args.test and not args.all and not args.restaurant_id:
        parser.error("Must specify --test, --all, or --restaurant-id")

    # Get restaurants to process
    restaurants = get_restaurants_to_process(args)

    if not restaurants:
        print("No restaurants to process")
        return

    # Set debug logging if requested
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    # Run scraper
    run_scraper(restaurants, headless=not args.no_headless)


if __name__ == '__main__':
    main()

