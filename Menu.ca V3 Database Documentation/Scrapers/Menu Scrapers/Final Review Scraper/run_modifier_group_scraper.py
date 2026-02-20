#!/usr/bin/env python3
"""
Modifier Group Details Scraper - Entry Point

Scrapes modifier group details (min_selections, max_selections, free_items, display_order)
and dish availability (hide-on-days) for V1 restaurants.

Usage:
    # Test with Imilio's Pizzeria (V3: 7, V1: 89)
    python run_modifier_group_scraper.py --test

    # Run for all 168 restaurants
    python run_modifier_group_scraper.py --all

    # Run for a specific restaurant
    python run_modifier_group_scraper.py --restaurant-id 7

    # Run with visible browser (for debugging)
    python run_modifier_group_scraper.py --test --no-headless
"""

import argparse
import logging
import sys
import os
from datetime import datetime
from typing import List, Dict, Any

from modifier_group_config import RESTAURANTS, TEST_RESTAURANT
from modifier_group_scraper import ModifierGroupScraper
from modifier_group_database import ModifierGroupDatabase


def setup_logging(log_dir: str = None) -> str:
    """Setup logging to both console and file."""
    if log_dir is None:
        # Use logs directory in Menu Scrapers
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            'logs'
        )

    os.makedirs(log_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'modifier_group_scraper_{timestamp}.log')

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
        return RESTAURANTS
    elif args.restaurant_id:
        # Find restaurant by V3 ID
        for r in RESTAURANTS:
            if r['v3_id'] == args.restaurant_id:
                return [r]
        # Not in list - create entry
        return [{'v3_id': args.restaurant_id, 'v1_id': None, 'name': 'Unknown'}]
    else:
        return []


def run_scraper(restaurants: List[Dict[str, Any]], headless: bool = True):
    """Run the modifier group scraper for given restaurants."""
    logger = logging.getLogger(__name__)

    log_file = setup_logging()
    logger.info(f"Logging to: {log_file}")

    all_results = []

    with ModifierGroupScraper(headless=headless) as scraper:
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
                db = ModifierGroupDatabase()
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
                stats = scraper.scrape_restaurant(v3_id, v1_id)

                logger.info(f"Results for {name}:")
                logger.info(f"  - Dishes processed: {stats['dishes_processed']}")
                logger.info(f"  - Modifier groups updated: {stats['modifier_groups_updated']}")
                logger.info(f"  - Dish availability records: {stats['dish_availability_updated']}")
                logger.info(f"  - Errors: {stats['errors']}")

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
    logger.info("MODIFIER GROUP DETAILS SCRAPER COMPLETE")
    logger.info("=" * 60)

    total_dishes = sum(r.get('dishes_processed', 0) for r in all_results)
    total_mg_updated = sum(r.get('modifier_groups_updated', 0) for r in all_results)
    total_avail = sum(r.get('dish_availability_updated', 0) for r in all_results)
    total_errors = sum(r.get('errors', 0) for r in all_results)

    logger.info(f"Restaurants processed: {len(all_results)}")
    logger.info(f"Total dishes processed: {total_dishes}")
    logger.info(f"Total modifier groups updated: {total_mg_updated}")
    logger.info(f"Total dish availability records: {total_avail}")
    logger.info(f"Total errors: {total_errors}")

    # Verify with database stats for test mode
    if len(restaurants) == 1 and restaurants[0]['v3_id'] == TEST_RESTAURANT['v3_id']:
        logger.info("")
        logger.info("=== TEST VERIFICATION ===")
        db = ModifierGroupDatabase()
        db.connect()
        stats = db.get_restaurant_stats(TEST_RESTAURANT['v3_id'])
        db.close()
        logger.info(f"Database verification for {TEST_RESTAURANT['name']} (V3: {TEST_RESTAURANT['v3_id']}):")
        logger.info(f"  - Modifier groups in DB: {stats['modifier_groups']}")
        logger.info(f"  - Dish availability records in DB: {stats['dish_availability_records']}")


def main():
    parser = argparse.ArgumentParser(
        description='Modifier Group Details Scraper',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Test with Imilio's Pizzeria
    python run_modifier_group_scraper.py --test

    # Run for all restaurants
    python run_modifier_group_scraper.py --all

    # Run for specific restaurant
    python run_modifier_group_scraper.py --restaurant-id 7

    # Debug with visible browser
    python run_modifier_group_scraper.py --test --no-headless
        """
    )

    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help=f"Test mode: Run only for {TEST_RESTAURANT['name']} (V3: {TEST_RESTAURANT['v3_id']}, V1: {TEST_RESTAURANT['v1_id']})"
    )

    parser.add_argument(
        '--all', '-a',
        action='store_true',
        help=f'Process all {len(RESTAURANTS)} restaurants'
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

