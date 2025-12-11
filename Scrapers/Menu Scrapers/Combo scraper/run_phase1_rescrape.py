#!/usr/bin/env python3
"""
Re-run Phase 1 for specific restaurants that were missed.

This script scrapes combo groups for the 8 restaurants that were not
processed in the original Phase 1 run and appends to the existing log.
"""

from combo_database import ComboDatabase
from combo_scraper import ComboScraper
import logging
import sys
import os
import csv
from datetime import datetime
from typing import List, Dict, Any

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


# Restaurants to re-scrape (V3 ID, V1 ID pairs)
RESTAURANTS_TO_SCRAPE = [
    (88, 204),   # Milano
    (89, 205),   # Milano
    (91, 207),   # Milano
    (93, 209),   # Milano
    (95, 211),   # Milano
    (515, 721),  # Napolis
    (819, 1063),  # Milano
    (840, 1087),  # Milano
]


def setup_logging(log_file: str):
    """Setup logging to append to existing file and console."""
    # Configure root logger
    logging.basicConfig(
        level=logging.INFO,
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(log_file, mode='a', encoding='utf-8'),
            logging.StreamHandler(sys.stdout)
        ]
    )

    # Reduce noise from other loggers
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('playwright').setLevel(logging.WARNING)


def write_summary_csv(results: List[Dict[str, Any]], log_dir: str):
    """Write a summary CSV file."""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    csv_file = os.path.join(
        log_dir, f'combo_phase1_rescrape_summary_{timestamp}.csv')

    fieldnames = [
        'restaurant_id', 'restaurant_name', 'v1_id',
        'combo_groups', 'sections', 'modifier_groups', 'modifiers', 'prices',
        'status', 'error'
    ]

    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    logging.info(f"Summary CSV written to: {csv_file}")


def run_phase1_rescrape(headless: bool = True):
    """Run Phase 1 scraping for missed restaurants."""
    logger = logging.getLogger(__name__)

    log_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'logs'
    )

    # Append to existing successful log
    log_file = os.path.join(log_dir, 'Combo Phase 1 successful.log')
    setup_logging(log_file)

    logger.info("")
    logger.info("=" * 60)
    logger.info("PHASE 1 RE-SCRAPE - 8 MISSED RESTAURANTS")
    logger.info("=" * 60)
    logger.info(f"Appending to: {log_file}")
    logger.info("")

    results = []

    # Get restaurant info from database
    db = ComboDatabase()
    db.connect()

    restaurants = []
    for v3_id, v1_id in RESTAURANTS_TO_SCRAPE:
        restaurant = db.get_restaurant_by_id(v3_id)
        if restaurant:
            # Ensure V1 ID matches
            if restaurant.get('legacy_v1_id') == v1_id:
                restaurants.append(restaurant)
            else:
                logger.warning(
                    f"V1 ID mismatch for V3:{v3_id} - expected {v1_id}, got {restaurant.get('legacy_v1_id')}")
                restaurants.append(restaurant)  # Still include it
        else:
            logger.error(f"Restaurant not found: V3={v3_id}, V1={v1_id}")

    db.close()

    logger.info(f"Found {len(restaurants)} restaurants to process")

    # Start scraper
    with ComboScraper(headless=headless) as scraper:
        # Login once
        if not scraper.login():
            logger.error("Login failed. Aborting.")
            return

        # Process each restaurant
        for restaurant in restaurants:
            r_id = restaurant['id']
            r_name = restaurant['name']
            r_v1_id = restaurant.get('legacy_v1_id')

            if not r_v1_id:
                logger.warning(f"Skipping {r_name} (ID: {r_id}) - no V1 ID")
                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': None,
                    'combo_groups': 0,
                    'sections': 0,
                    'modifier_groups': 0,
                    'modifiers': 0,
                    'prices': 0,
                    'status': 'skipped',
                    'error': 'No V1 ID'
                })
                continue

            logger.info("=" * 60)
            logger.info(f"Processing: {r_name} (V3: {r_id}, V1: {r_v1_id})")
            logger.info("=" * 60)

            try:
                stats = scraper.scrape_combo_groups(r_id, r_v1_id)

                logger.info(f"Results for {r_name}:")
                logger.info(f"  - Combo Groups: {stats['combo_groups']}")
                logger.info(f"  - Sections: {stats['sections']}")
                logger.info(f"  - Modifier Groups: {stats['modifier_groups']}")
                logger.info(f"  - Modifiers: {stats['modifiers']}")
                logger.info(f"  - Prices: {stats['prices']}")

                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': r_v1_id,
                    'combo_groups': stats['combo_groups'],
                    'sections': stats['sections'],
                    'modifier_groups': stats['modifier_groups'],
                    'modifiers': stats['modifiers'],
                    'prices': stats['prices'],
                    'status': 'success' if stats['combo_groups'] > 0 else 'no_combos',
                    'error': ''
                })

            except Exception as e:
                logger.error(f"Error processing {r_name}: {e}", exc_info=True)
                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': r_v1_id,
                    'combo_groups': 0,
                    'sections': 0,
                    'modifier_groups': 0,
                    'modifiers': 0,
                    'prices': 0,
                    'status': 'error',
                    'error': str(e)
                })

    # Write summary
    write_summary_csv(results, log_dir)

    # Print final summary
    logger.info("=" * 60)
    logger.info("PHASE 1 RE-SCRAPE COMPLETE")
    logger.info("=" * 60)

    total_groups = sum(r['combo_groups'] for r in results)
    total_sections = sum(r['sections'] for r in results)
    total_mod_groups = sum(r['modifier_groups'] for r in results)
    total_modifiers = sum(r['modifiers'] for r in results)
    total_prices = sum(r['prices'] for r in results)

    success_count = len([r for r in results if r['status'] == 'success'])
    no_combos_count = len([r for r in results if r['status'] == 'no_combos'])
    error_count = len([r for r in results if r['status'] == 'error'])
    skipped_count = len([r for r in results if r['status'] == 'skipped'])

    logger.info(f"Restaurants processed: {len(results)}")
    logger.info(f"  - Success: {success_count}")
    logger.info(f"  - No combos: {no_combos_count}")
    logger.info(f"  - Errors: {error_count}")
    logger.info(f"  - Skipped: {skipped_count}")
    logger.info("")
    logger.info(f"Total combo groups: {total_groups}")
    logger.info(f"Total sections: {total_sections}")
    logger.info(f"Total modifier groups: {total_mod_groups}")
    logger.info(f"Total modifiers: {total_modifiers}")
    logger.info(f"Total prices: {total_prices}")


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Re-run Phase 1 for missed restaurants')
    parser.add_argument('--no-headless', action='store_true',
                        help='Run browser in visible mode')

    args = parser.parse_args()

    run_phase1_rescrape(headless=not args.no_headless)
