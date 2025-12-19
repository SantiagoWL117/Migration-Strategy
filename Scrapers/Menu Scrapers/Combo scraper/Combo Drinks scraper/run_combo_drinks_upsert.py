#!/usr/bin/env python3
"""
Combo Drinks Upsert Scraper Runner

This script scrapes drinks modifier group settings from combo dishes in V1 CRM
and updates the corresponding modifier_groups in menuca_v3 ONLY when data differs.

Key differences from original scraper:
- Looks up modifier groups by drinksHeader value (title) instead of radio button label
- Only updates when V1 data differs from V3 data
- Skips silently when no modifier group found (no warnings)
- Only processes 60 restaurants that have combo dishes

Usage:
    # Run for all 60 restaurants with combo dishes
    python run_combo_drinks_upsert.py --all

    # Run for a specific restaurant
    python run_combo_drinks_upsert.py --restaurant-id 131 --v1-id 255

    # Run with visible browser (for debugging)
    python run_combo_drinks_upsert.py --all --no-headless
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

from combo_drinks_upsert_scraper import ComboDrinksUpsertScraper, V1_IDS_WITH_COMBO_DISHES
from combo_drinks_database import ComboDrinksDatabase
from combo_drinks_config import RESTAURANTS_TO_SCRAPE


def setup_logging(log_dir: str = None) -> str:
    """Setup logging to both console and file."""
    if log_dir is None:
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
            'logs'
        )
    
    os.makedirs(log_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'combo_drinks_upsert_{timestamp}.log')
    
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
    csv_file = os.path.join(log_dir, f'combo_drinks_upsert_summary_{timestamp}.csv')
    
    fieldnames = [
        'restaurant_id', 'restaurant_name', 'v1_id',
        'combo_dishes_found', 'updated', 'skipped_no_change',
        'skipped_no_drinks', 'skipped_no_dish', 'skipped_no_mg',
        'errors', 'status'
    ]
    
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    
    logging.info(f"Summary CSV written to: {csv_file}")


def get_restaurants_with_combo_dishes() -> List[Dict[str, Any]]:
    """
    Filter RESTAURANTS_TO_SCRAPE to only include restaurants 
    that have combo dishes (based on V1_IDS_WITH_COMBO_DISHES).
    """
    filtered = []
    for r in RESTAURANTS_TO_SCRAPE:
        if r['v1_id'] in V1_IDS_WITH_COMBO_DISHES:
            filtered.append(r)
    return filtered


def run_scraper(
    restaurant_id: int = None,
    v1_id: int = None,
    all_restaurants: bool = False,
    headless: bool = True
):
    """Run the combo drinks upsert scraper."""
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
    
    if all_restaurants:
        restaurants = get_restaurants_with_combo_dishes()
        logger.info(f"=== UPSERT MODE: Processing {len(restaurants)} restaurants with combo dishes ===")
        logger.info(f"(Filtering from {len(RESTAURANTS_TO_SCRAPE)} total, {len(V1_IDS_WITH_COMBO_DISHES)} have combo dishes)")
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
        logger.error("No restaurant specified. Use --restaurant-id or --all")
        return
    
    # Start scraper
    with ComboDrinksUpsertScraper(headless=headless) as scraper:
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
            logger.info(f"[{idx}/{len(restaurants)}] {r_name} (V3: {r_id}, V1: {r_v1_id})")
            logger.info("=" * 60)
            
            try:
                stats = scraper.scrape_restaurant(r_id, r_v1_id, r_name)
                
                # Determine status
                status = 'success'
                if stats['errors'] > 0:
                    status = 'partial'
                elif stats['updated'] == 0 and stats['skipped_no_change'] > 0:
                    status = 'all_current'  # All data was already up-to-date
                elif stats['combo_dishes_found'] == 0:
                    status = 'no_combos'
                elif stats['updated'] == 0:
                    status = 'no_updates'
                
                results.append({
                    'restaurant_id': r_id,
                    'restaurant_name': r_name,
                    'v1_id': r_v1_id,
                    'combo_dishes_found': stats['combo_dishes_found'],
                    'updated': stats['updated'],
                    'skipped_no_change': stats['skipped_no_change'],
                    'skipped_no_drinks': stats['skipped_no_drinks'],
                    'skipped_no_dish': stats['skipped_no_dish'],
                    'skipped_no_mg': stats['skipped_no_mg'],
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
                    'updated': 0,
                    'skipped_no_change': 0,
                    'skipped_no_drinks': 0,
                    'skipped_no_dish': 0,
                    'skipped_no_mg': 0,
                    'errors': 1,
                    'status': 'error'
                })
    
    # Write summary CSV
    write_summary_csv(results, log_dir)
    
    # Print final summary
    logger.info("=" * 60)
    logger.info("UPSERT SCRAPING COMPLETE")
    logger.info("=" * 60)
    
    total_combos = sum(r['combo_dishes_found'] for r in results)
    total_updated = sum(r['updated'] for r in results)
    total_no_change = sum(r['skipped_no_change'] for r in results)
    total_no_drinks = sum(r['skipped_no_drinks'] for r in results)
    total_no_dish = sum(r['skipped_no_dish'] for r in results)
    total_no_mg = sum(r['skipped_no_mg'] for r in results)
    total_errors = sum(r['errors'] for r in results)
    
    success_count = len([r for r in results if r['status'] == 'success'])
    all_current_count = len([r for r in results if r['status'] == 'all_current'])
    partial_count = len([r for r in results if r['status'] == 'partial'])
    no_updates_count = len([r for r in results if r['status'] == 'no_updates'])
    error_count = len([r for r in results if r['status'] == 'error'])
    
    logger.info(f"Restaurants processed: {len(results)}")
    logger.info(f"  - Success (with updates): {success_count}")
    logger.info(f"  - All current (no updates needed): {all_current_count}")
    logger.info(f"  - Partial (with errors): {partial_count}")
    logger.info(f"  - No updates: {no_updates_count}")
    logger.info(f"  - Errors: {error_count}")
    logger.info("")
    logger.info(f"Combo Dishes Breakdown:")
    logger.info(f"  Total combo dishes found: {total_combos}")
    logger.info(f"  Updated: {total_updated}")
    logger.info(f"  Skipped (no change): {total_no_change}")
    logger.info(f"  Skipped (no drinks section): {total_no_drinks}")
    logger.info(f"  Skipped (dish not in V3): {total_no_dish}")
    logger.info(f"  Skipped (no modifier group): {total_no_mg}")
    logger.info(f"  Errors: {total_errors}")


def main():
    parser = argparse.ArgumentParser(
        description='Combo Drinks Upsert Scraper - Only updates when data differs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Run for all 60 restaurants with combo dishes
    python run_combo_drinks_upsert.py --all

    # Run for specific restaurant
    python run_combo_drinks_upsert.py --restaurant-id 131 --v1-id 255

    # Debug with visible browser
    python run_combo_drinks_upsert.py --all --no-headless
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
        help='Process all 60 restaurants that have combo dishes'
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
    if not args.all and not args.restaurant_id:
        parser.error("Must specify --restaurant-id or --all")
    
    run_scraper(
        restaurant_id=args.restaurant_id,
        v1_id=args.v1_id,
        all_restaurants=args.all,
        headless=not args.no_headless
    )


if __name__ == '__main__':
    main()





