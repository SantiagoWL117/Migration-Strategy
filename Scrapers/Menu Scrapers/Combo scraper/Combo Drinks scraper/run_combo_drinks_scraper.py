#!/usr/bin/env python3
"""
Combo Drinks Modifier Group Scraper Runner

This script scrapes drinks modifier group settings (min, max, free_items) from 
combo dishes in the V1 CRM and updates the corresponding modifier_groups in menuca_v3.

Usage:
    # Test with Centertown Donair & Pizza (V3: 131, V1: 255)
    python run_combo_drinks_scraper.py --test

    # Run for all restaurants from Phase 1 log
    python run_combo_drinks_scraper.py --all

    # Run for a specific restaurant
    python run_combo_drinks_scraper.py --restaurant-id 131 --v1-id 255

    # Run with visible browser (for debugging)
    python run_combo_drinks_scraper.py --test --no-headless
"""

import argparse
import logging
import sys
import os
import csv
from datetime import datetime
from typing import List, Dict, Any

# Add parent directories to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from combo_drinks_scraper import ComboDrinksScraper
from combo_drinks_database import ComboDrinksDatabase
from combo_drinks_config import RESTAURANTS_TO_SCRAPE, TEST_RESTAURANT


def setup_logging(log_dir: str = None) -> str:
    """Setup logging to both console and file."""
    if log_dir is None:
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
            'logs'
        )
    
    os.makedirs(log_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'combo_drinks_scraper_{timestamp}.log')
    
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


def write_summary_csv(results: List[Dict[str, Any]], log_dir: str):
    """Write a summary CSV file."""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    csv_file = os.path.join(log_dir, f'combo_drinks_summary_{timestamp}.csv')
    
    fieldnames = [
        'restaurant_id', 'restaurant_name', 'v1_id',
        'combo_dishes_found', 'drinks_sections_found', 'modifier_groups_updated',
        'errors', 'status'
    ]
    
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    
    logging.info(f"Summary CSV written to: {csv_file}")


def verify_test_results(db: ComboDrinksDatabase, restaurant_id: int) -> bool:
    """
    Verify results for test restaurant.
    
    For Centertown Donair & Pizza (V3: 131), verify:
    - Dish "2 Small Halifax Donairs" (V3: 133650) has modifier_groups.name = "Drinks can"
    - min_selections = 2, max_selections = 2, free_items = 0
    """
    logger = logging.getLogger(__name__)
    
    logger.info("=" * 60)
    logger.info("VERIFICATION")
    logger.info("=" * 60)
    
    # Get drinks stats for restaurant
    stats = db.get_restaurant_drinks_stats(restaurant_id)
    logger.info(f"Restaurant drinks stats:")
    logger.info(f"  Total combo dishes: {stats['total_combo_dishes']}")
    logger.info(f"  Dishes with drinks modifier: {stats['dishes_with_drinks_modifier']}")
    logger.info(f"  Total drinks modifier groups: {stats['total_drinks_modifier_groups']}")
    
    # Specific verification for "2 Small Halifax Donairs" (dish_id should be known)
    # We'll look for it by searching for drinks modifier groups
    db.ensure_connection()
    db.cursor.execute("""
        SELECT d.id, d.name, d.source_id, mg.id as mg_id, mg.name as mg_name,
               mg.min_selections, mg.max_selections, mg.free_items, mg.updated_at
        FROM menuca_v3.dishes d
        JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
        WHERE d.restaurant_id = %s
          AND d.is_combo = TRUE
          AND d.deleted_at IS NULL
          AND mg.deleted_at IS NULL
          AND LOWER(mg.name) LIKE '%%drink%%'
        ORDER BY d.name
        LIMIT 10
    """, (restaurant_id,))
    
    results = db.cursor.fetchall()
    
    if results:
        logger.info(f"\nDrinks modifier groups found:")
        for row in results:
            logger.info(f"  Dish: {row['name']} (ID: {row['id']})")
            logger.info(f"    Modifier: {row['mg_name']} (ID: {row['mg_id']})")
            logger.info(f"    Min: {row['min_selections']}, Max: {row['max_selections']}, Free: {row['free_items']}")
            logger.info(f"    Updated: {row['updated_at']}")
        
        # Check for specific expected values for "2 Small Halifax Donairs"
        target_dish = next((r for r in results if 'Halifax Donairs' in r['name']), None)
        if target_dish:
            expected_min = 2
            expected_max = 2
            expected_free = 0
            
            if (target_dish['min_selections'] == expected_min and
                target_dish['max_selections'] == expected_max and
                target_dish['free_items'] == expected_free):
                logger.info(f"\n✓ VERIFICATION PASSED for '2 Small Halifax Donairs'")
                logger.info(f"  min_selections={expected_min}, max_selections={expected_max}, free_items={expected_free}")
                return True
            else:
                logger.warning(f"\n✗ VERIFICATION FAILED for '2 Small Halifax Donairs'")
                logger.warning(f"  Expected: min={expected_min}, max={expected_max}, free={expected_free}")
                logger.warning(f"  Got: min={target_dish['min_selections']}, max={target_dish['max_selections']}, free={target_dish['free_items']}")
                return False
    else:
        logger.warning("No drinks modifier groups found for verification")
    
    return True


def run_scraper(
    restaurant_id: int = None,
    v1_id: int = None,
    all_restaurants: bool = False,
    test_mode: bool = False,
    headless: bool = True
):
    """Run the combo drinks scraper."""
    logger = logging.getLogger(__name__)
    
    log_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
        'logs'
    )
    log_file = setup_logging(log_dir)
    logger.info(f"Logging to: {log_file}")
    
    results = []
    
    # Determine restaurants to process
    restaurants = []
    
    if test_mode:
        restaurants = [TEST_RESTAURANT]
        logger.info("=== TEST MODE ===")
        logger.info(f"Testing with: {TEST_RESTAURANT['name']} (V3: {TEST_RESTAURANT['v3_id']}, V1: {TEST_RESTAURANT['v1_id']})")
    elif all_restaurants:
        restaurants = RESTAURANTS_TO_SCRAPE
        logger.info(f"Processing all {len(restaurants)} restaurants")
    elif restaurant_id and v1_id:
        # Find restaurant in list or create entry
        restaurant = next(
            (r for r in RESTAURANTS_TO_SCRAPE if r['v3_id'] == restaurant_id),
            {'v3_id': restaurant_id, 'v1_id': v1_id, 'name': f'Restaurant {restaurant_id}'}
        )
        restaurants = [restaurant]
    elif restaurant_id:
        restaurant = next(
            (r for r in RESTAURANTS_TO_SCRAPE if r['v3_id'] == restaurant_id),
            None
        )
        if restaurant:
            restaurants = [restaurant]
        else:
            logger.error(f"Restaurant {restaurant_id} not found in list. Use --v1-id to specify V1 ID.")
            return
    else:
        logger.error("No restaurant specified. Use --restaurant-id, --test, or --all")
        return
    
    # Start scraper
    with ComboDrinksScraper(headless=headless) as scraper:
        # Login once
        if not scraper.login():
            logger.error("Login failed. Aborting.")
            return
        
        # Process each restaurant
        for idx, restaurant in enumerate(restaurants, 1):
            r_id = restaurant['v3_id']
            r_v1_id = restaurant['v1_id']
            r_name = restaurant['name']
            
            logger.info("=" * 60)
            logger.info(f"[{idx}/{len(restaurants)}] Processing: {r_name} (V3: {r_id}, V1: {r_v1_id})")
            logger.info("=" * 60)
            
            try:
                stats = scraper.scrape_restaurant(r_id, r_v1_id, r_name)
                
                status = 'success'
                if stats['errors'] > 0:
                    status = 'partial'
                if stats['modifier_groups_updated'] == 0:
                    status = 'no_drinks'
                
                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': r_v1_id,
                    'combo_dishes_found': stats['combo_dishes_found'],
                    'drinks_sections_found': stats['drinks_sections_found'],
                    'modifier_groups_updated': stats['modifier_groups_updated'],
                    'errors': stats['errors'],
                    'status': status
                })
                
            except Exception as e:
                logger.error(f"Error processing {r_name}: {e}", exc_info=True)
                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': r_v1_id,
                    'combo_dishes_found': 0,
                    'drinks_sections_found': 0,
                    'modifier_groups_updated': 0,
                    'errors': 1,
                    'status': 'error'
                })
        
        # Verification for test mode
        if test_mode and results:
            db = scraper.db
            verify_test_results(db, TEST_RESTAURANT['v3_id'])
    
    # Write summary CSV
    write_summary_csv(results, log_dir)
    
    # Print final summary
    logger.info("=" * 60)
    logger.info("SCRAPING COMPLETE")
    logger.info("=" * 60)
    
    total_combos = sum(r['combo_dishes_found'] for r in results)
    total_drinks = sum(r['drinks_sections_found'] for r in results)
    total_updated = sum(r['modifier_groups_updated'] for r in results)
    total_errors = sum(r['errors'] for r in results)
    
    success_count = len([r for r in results if r['status'] == 'success'])
    partial_count = len([r for r in results if r['status'] == 'partial'])
    no_drinks_count = len([r for r in results if r['status'] == 'no_drinks'])
    error_count = len([r for r in results if r['status'] == 'error'])
    
    logger.info(f"Restaurants processed: {len(results)}")
    logger.info(f"  - Success: {success_count}")
    logger.info(f"  - Partial (with errors): {partial_count}")
    logger.info(f"  - No drinks sections: {no_drinks_count}")
    logger.info(f"  - Errors: {error_count}")
    logger.info("")
    logger.info(f"Total combo dishes found: {total_combos}")
    logger.info(f"Total drinks sections found: {total_drinks}")
    logger.info(f"Total modifier groups updated: {total_updated}")
    logger.info(f"Total errors: {total_errors}")


def main():
    parser = argparse.ArgumentParser(
        description='Combo Drinks Modifier Group Scraper',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Test with Centertown Donair & Pizza
    python run_combo_drinks_scraper.py --test

    # Run for all restaurants
    python run_combo_drinks_scraper.py --all

    # Run for specific restaurant
    python run_combo_drinks_scraper.py --restaurant-id 131 --v1-id 255

    # Debug with visible browser
    python run_combo_drinks_scraper.py --test --no-headless
        """
    )
    
    parser.add_argument(
        '--restaurant-id', '-r',
        type=int,
        help='V3 restaurant ID to process'
    )
    
    parser.add_argument(
        '--v1-id', '-v',
        type=int,
        help='V1 restaurant ID (legacy_v1_id)'
    )
    
    parser.add_argument(
        '--all', '-a',
        action='store_true',
        help='Process all restaurants from Phase 1 log'
    )
    
    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help='Run test with Centertown Donair & Pizza (V3: 131, V1: 255)'
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
    
    # Enable debug logging if requested
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Validate arguments
    if not args.all and not args.test and not args.restaurant_id:
        parser.error("Must specify --restaurant-id, --test, or --all")
    
    run_scraper(
        restaurant_id=args.restaurant_id,
        v1_id=args.v1_id,
        all_restaurants=args.all,
        test_mode=args.test,
        headless=not args.no_headless
    )


if __name__ == '__main__':
    main()

