"""Main entry point for Phase 2 Restaurants Scraper.

Scrapes all menu data for the 6 target restaurants:
- Joes Family Pizzeria (TEST FIRST)
- Milano - 2 Pembroke
- Aroy Thai
- All Out Burger Bank St.
- All Out Burger Gladstone
- All Out Burger Montreal Rd
"""
from phase2_scraper import Phase2Scraper
from phase2_config import RESTAURANTS
import os
import sys
import csv
import logging
import argparse
from datetime import datetime
from typing import List, Dict, Any

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def setup_logging(log_dir: str) -> str:
    """Set up logging to file and console."""
    os.makedirs(log_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'phase2_scraper_{timestamp}.log')

    # Configure root logger
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )

    # Reduce noise from other loggers
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('playwright').setLevel(logging.WARNING)

    return log_file


def write_summary_csv(results: List[Dict[str, Any]], log_dir: str):
    """Write a summary CSV file with scraping results."""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    csv_file = os.path.join(log_dir, f'phase2_summary_{timestamp}.csv')

    fieldnames = [
        'restaurant_id', 'v1_id', 'restaurant_name', 'status', 'error',
        'combo_groups', 'combo_sections', 'combo_modifier_groups',
        'combo_modifiers', 'combo_modifier_prices',
        'courses', 'dishes', 'combo_dishes', 'normal_dishes',
        'dish_prices', 'combo_links', 'hide_days',
        'modifier_groups', 'modifiers', 'modifier_prices', 'drinks_modifiers'
    ]

    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for result in results:
            row = {
                'restaurant_id': result['restaurant_id'],
                'v1_id': result['v1_id'],
                'restaurant_name': result.get('name', ''),
                'status': result['status'],
                'error': result.get('error', ''),
                # Phase 1
                'combo_groups': result.get('phase1', {}).get('combo_groups', 0),
                'combo_sections': result.get('phase1', {}).get('sections', 0),
                'combo_modifier_groups': result.get('phase1', {}).get('modifier_groups', 0),
                'combo_modifiers': result.get('phase1', {}).get('modifiers', 0),
                'combo_modifier_prices': result.get('phase1', {}).get('prices', 0),
                # Phase 2
                'courses': result.get('phase2', {}).get('courses', 0),
                'dishes': result.get('phase2', {}).get('dishes', 0),
                'combo_dishes': result.get('phase2', {}).get('combo_dishes', 0),
                'normal_dishes': result.get('phase2', {}).get('normal_dishes', 0),
                # Phase 3
                'dish_prices': result.get('phase3', {}).get('dish_prices', 0),
                'combo_links': result.get('phase3', {}).get('combo_links', 0),
                'hide_days': result.get('phase3', {}).get('hide_days', 0),
                'modifier_groups': result.get('phase3', {}).get('modifier_groups', 0),
                'modifiers': result.get('phase3', {}).get('modifiers', 0),
                'modifier_prices': result.get('phase3', {}).get('modifier_prices', 0),
                'drinks_modifiers': result.get('phase3', {}).get('drinks_modifiers', 0),
            }
            writer.writerow(row)

    logging.getLogger(__name__).info(f"Summary written to: {csv_file}")


def run_scraper(
    restaurant_id: int = None,
    v1_id: int = None,
    all_restaurants: bool = False,
    exclude_ids: list = None,
    test_mode: bool = False,
    headless: bool = True
):
    """Run the Phase 2 Restaurants Scraper."""
    logger = logging.getLogger(__name__)

    # Set up logging
    log_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'logs'
    )
    log_file = setup_logging(log_dir)
    logger.info(f"Logging to: {log_file}")

    # Determine which restaurants to process
    restaurants_to_process = []

    if all_restaurants:
        restaurants_to_process = RESTAURANTS.copy()

        # Apply exclusions if specified
        if exclude_ids:
            restaurants_to_process = [
                r for r in restaurants_to_process
                if r['v3_id'] not in exclude_ids
            ]
            logger.info(f"Excluding V3 IDs: {exclude_ids}")

        logger.info(
            f"Processing {len(restaurants_to_process)} restaurants")
    elif restaurant_id:
        # Find restaurant by V3 ID
        for r in RESTAURANTS:
            if r['v3_id'] == restaurant_id:
                restaurants_to_process = [r]
                break
        if not restaurants_to_process:
            logger.error(
                f"Restaurant with V3 ID {restaurant_id} not found in target list")
            return
    elif v1_id:
        # Find restaurant by V1 ID
        for r in RESTAURANTS:
            if r['v1_id'] == v1_id:
                restaurants_to_process = [r]
                break
        if not restaurants_to_process:
            logger.error(
                f"Restaurant with V1 ID {v1_id} not found in target list")
            return
    else:
        # Default: process test restaurant (Joes Family Pizzeria)
        restaurants_to_process = [RESTAURANTS[0]]
        logger.info("No restaurant specified, using test restaurant")

    if test_mode:
        logger.info("=== TEST MODE ===")
        logger.info(
            f"Would process {len(restaurants_to_process)} restaurant(s):")
        for r in restaurants_to_process:
            logger.info(
                f"  - {r['name']} (V3: {r['v3_id']}, V1: {r['v1_id']})")
        return

    results = []

    # Start scraper
    with Phase2Scraper(headless=headless) as scraper:
        # Login once
        if not scraper.login():
            logger.error("Login failed. Aborting.")
            return

        # Process each restaurant
        for restaurant in restaurants_to_process:
            r_id = restaurant['v3_id']
            r_v1_id = restaurant['v1_id']
            r_name = restaurant['name']

            logger.info("=" * 70)
            logger.info(f"SCRAPING: {r_name} (V3: {r_id}, V1: {r_v1_id})")
            logger.info("=" * 70)

            try:
                result = scraper.scrape_restaurant(r_id, r_v1_id)
                result['name'] = r_name
                results.append(result)

                # Log summary
                logger.info(f"Completed: {r_name}")
                logger.info(
                    f"  Phase 1 - Combo Groups: {result['phase1'].get('combo_groups', 0)}")
                logger.info(
                    f"  Phase 2 - Courses: {result['phase2'].get('courses', 0)}, Dishes: {result['phase2'].get('dishes', 0)}")
                logger.info(
                    f"  Phase 3 - Prices: {result['phase3'].get('dish_prices', 0)}, Modifiers: {result['phase3'].get('modifiers', 0)}")

            except Exception as e:
                logger.error(f"Error scraping {r_name}: {e}", exc_info=True)
                results.append({
                    'restaurant_id': r_id,
                    'v1_id': r_v1_id,
                    'name': r_name,
                    'phase1': {},
                    'phase2': {},
                    'phase3': {},
                    'status': 'error',
                    'error': str(e)
                })

    # Write summary
    write_summary_csv(results, log_dir)

    # Print final summary
    logger.info("=" * 70)
    logger.info("SCRAPING COMPLETE")
    logger.info("=" * 70)

    success_count = len([r for r in results if r['status'] == 'success'])
    error_count = len([r for r in results if r['status'] == 'error'])

    # Totals
    total_combo_groups = sum(r.get('phase1', {}).get(
        'combo_groups', 0) for r in results)
    total_courses = sum(r.get('phase2', {}).get('courses', 0) for r in results)
    total_dishes = sum(r.get('phase2', {}).get('dishes', 0) for r in results)
    total_prices = sum(r.get('phase3', {}).get('dish_prices', 0)
                       for r in results)
    total_modifiers = sum(r.get('phase3', {}).get('modifiers', 0)
                          for r in results)

    logger.info(f"Restaurants processed: {len(results)}")
    logger.info(f"  - Success: {success_count}")
    logger.info(f"  - Errors: {error_count}")
    logger.info("")
    logger.info("TOTALS:")
    logger.info(f"  - Combo Groups: {total_combo_groups}")
    logger.info(f"  - Courses: {total_courses}")
    logger.info(f"  - Dishes: {total_dishes}")
    logger.info(f"  - Dish Prices: {total_prices}")
    logger.info(f"  - Modifiers: {total_modifiers}")


def main():
    parser = argparse.ArgumentParser(
        description='Phase 2 Restaurants Scraper - Scrape menu data for 6 target restaurants'
    )

    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '--restaurant-id', '-r',
        type=int,
        help='V3 restaurant ID to scrape'
    )
    group.add_argument(
        '--v1-id', '-v',
        type=int,
        help='V1 legacy ID to scrape'
    )
    group.add_argument(
        '--all', '-a',
        action='store_true',
        help='Scrape all 6 target restaurants'
    )

    parser.add_argument(
        '--exclude', '-e',
        type=int,
        nargs='+',
        help='V3 restaurant IDs to exclude (use with --all)'
    )

    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help='Test mode - show what would be scraped without running'
    )

    parser.add_argument(
        '--visible', '-V',
        action='store_true',
        help='Run browser in visible mode (not headless)'
    )

    args = parser.parse_args()

    run_scraper(
        restaurant_id=args.restaurant_id,
        v1_id=args.v1_id,
        all_restaurants=args.all,
        exclude_ids=args.exclude,
        test_mode=args.test,
        headless=not args.visible
    )


if __name__ == '__main__':
    main()
