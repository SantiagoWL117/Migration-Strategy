#!/usr/bin/env python3
"""
Phase 1: Scrape Combo Groups from V1 CRM

This script scrapes combo groups, sections, modifier groups, modifiers, and prices
from the V1 CRM and stores them in the menuca_v3 database.

Usage:
    # Test with a single restaurant (Centertown Donair & Pizza)
    python run_phase1.py --restaurant-id 131 --v1-id 255 --test

    # Run for all restaurants with V1 IDs
    python run_phase1.py --all

    # Run for a specific restaurant
    python run_phase1.py --restaurant-id 131

    # Run with visible browser (for debugging)
    python run_phase1.py --restaurant-id 131 --no-headless
"""

import argparse
import logging
import sys
import os
import csv
from datetime import datetime
from typing import List, Dict, Any

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from combo_scraper import ComboScraper
from combo_database import ComboDatabase


def setup_logging(log_dir: str = None) -> str:
    """Setup logging to both console and file."""
    if log_dir is None:
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            'logs'
        )
    
    os.makedirs(log_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'combo_phase1_{timestamp}.log')
    
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
    csv_file = os.path.join(log_dir, f'combo_phase1_summary_{timestamp}.csv')
    
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


def run_phase1(
    restaurant_id: int = None,
    v1_id: int = None,
    all_restaurants: bool = False,
    test_mode: bool = False,
    headless: bool = True
):
    """Run Phase 1 scraping."""
    logger = logging.getLogger(__name__)
    
    log_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'logs'
    )
    log_file = setup_logging(log_dir)
    logger.info(f"Logging to: {log_file}")
    
    results = []
    
    # Get restaurants to process
    db = ComboDatabase()
    db.connect()
    
    restaurants = []
    
    if all_restaurants:
        restaurants = db.get_restaurants_with_v1_id()
        logger.info(f"Found {len(restaurants)} restaurants with V1 IDs")
    elif restaurant_id:
        restaurant = db.get_restaurant_by_id(restaurant_id)
        if restaurant:
            restaurants = [restaurant]
        else:
            logger.error(f"Restaurant not found: {restaurant_id}")
            db.close()
            return
    elif v1_id:
        restaurant = db.get_restaurant_by_v1_id(v1_id)
        if restaurant:
            restaurants = [restaurant]
        else:
            logger.error(f"Restaurant with V1 ID not found: {v1_id}")
            db.close()
            return
    else:
        logger.error("No restaurant specified. Use --restaurant-id, --v1-id, or --all")
        db.close()
        return
    
    db.close()
    
    if test_mode:
        logger.info("=== TEST MODE ===")
        logger.info(f"Will process {len(restaurants)} restaurant(s)")
    
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
    logger.info("PHASE 1 COMPLETE")
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


def main():
    parser = argparse.ArgumentParser(
        description='Phase 1: Scrape Combo Groups from V1 CRM',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Test with Centertown Donair & Pizza
    python run_phase1.py --restaurant-id 131 --v1-id 255 --test

    # Run for all restaurants
    python run_phase1.py --all

    # Debug with visible browser
    python run_phase1.py --restaurant-id 131 --no-headless
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
        help='Process all restaurants with V1 IDs'
    )
    
    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help='Run in test mode (same behavior, just labeled)'
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
    
    # Reconfigure logging if debug is enabled
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
        for handler in logging.getLogger().handlers:
            handler.setLevel(logging.DEBUG)
    
    # Validate arguments
    if not args.all and not args.restaurant_id and not args.v1_id:
        parser.error("Must specify --restaurant-id, --v1-id, or --all")
    
    run_phase1(
        restaurant_id=args.restaurant_id,
        v1_id=args.v1_id,
        all_restaurants=args.all,
        test_mode=args.test,
        headless=not args.no_headless
    )


if __name__ == '__main__':
    main()

