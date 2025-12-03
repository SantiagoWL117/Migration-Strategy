#!/usr/bin/env python3
"""
V1 Delivery & Schedule Scraper - Main Entry Point

Scrapes delivery time, takeout time, schedules, and service settings
from the V1 CRM (menuadmin.menu.ca) for all restaurants with legacy_v1_id.

Usage:
    python main.py                    # Scrape all V1 restaurants
    python main.py --test             # Test with first 3 restaurants
    python main.py --restaurant 781   # Scrape specific V1 ID
    python main.py --dry-run          # Scrape but don't update database
"""
import argparse
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any

import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from V1.scraper import V1DeliveryScheduleScraper
from V1.config import OUTPUT_DIR, LOG_DIR
from shared.database import DatabaseManager
from shared.models import RestaurantData

# Setup logging
def setup_logging(log_file: str = None):
    """Configure logging to file and console."""
    log_format = '%(asctime)s - %(levelname)s - %(message)s'
    
    handlers = [logging.StreamHandler()]
    
    if log_file:
        handlers.append(logging.FileHandler(log_file, encoding='utf-8'))
    
    logging.basicConfig(
        level=logging.INFO,
        format=log_format,
        handlers=handlers
    )


def scrape_restaurants(restaurants: List[Dict[str, Any]], 
                       headless: bool = True) -> List[RestaurantData]:
    """
    Scrape delivery/schedule data for a list of restaurants.
    
    Args:
        restaurants: List of dicts with 'id', 'name', 'legacy_v1_id'
        headless: Run browser in headless mode
    
    Returns:
        List of RestaurantData objects with scraped data
    """
    results = []
    
    with V1DeliveryScheduleScraper(headless=headless) as scraper:
        if not scraper.login():
            logging.error("Failed to login to V1 CRM. Aborting.")
            return results
        
        total = len(restaurants)
        for idx, restaurant in enumerate(restaurants, 1):
            v3_id = restaurant['id']
            v1_id = restaurant['legacy_v1_id']
            name = restaurant['name']
            
            logging.info(f"[{idx}/{total}] Processing {name}...")
            
            result = scraper.scrape_restaurant(v3_id, v1_id, name)
            results.append(result)
    
    return results


def save_results(results: List[RestaurantData], output_file: Path):
    """Save scraped results to JSON file."""
    data = {
        'scraped_at': datetime.now().isoformat(),
        'total_restaurants': len(results),
        'successful': sum(1 for r in results if r.scrape_success),
        'failed': sum(1 for r in results if not r.scrape_success),
        'restaurants': [r.to_dict() for r in results]
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    logging.info(f"Results saved to {output_file}")


def update_database(results: List[RestaurantData], dry_run: bool = False, overwrite: bool = True):
    """
    Update database with scraped data.
    Uses DELETE and RE-INSERT strategy for schedules to avoid overlap conflicts.
    
    Args:
        results: List of RestaurantData objects with scraped data
        dry_run: If True, don't actually update the database
        overwrite: If True, overwrite existing values. If False, only update NULL values.
    """
    if dry_run:
        logging.info("DRY RUN - No database updates will be made")
        return
    
    updated_service_configs = 0
    updated_delivery_areas = 0
    inserted_schedules = 0
    deleted_schedules = 0
    
    with DatabaseManager() as db:
        for result in results:
            if not result.scrape_success:
                continue
            
            v3_id = result.v3_id
            
            # Update service config
            if db.update_service_config(
                restaurant_id=v3_id,
                takeout_time_minutes=result.takeout_time_minutes,
                has_delivery_enabled=result.has_delivery_enabled,
                pickup_enabled=result.pickup_enabled,
                closing_warning_minutes=result.closing_warning_minutes,
                overwrite=overwrite
            ):
                updated_service_configs += 1
                logging.info(f"  ✓ Updated service config for {result.name} (V3 ID: {v3_id})")
            
            # Update delivery area estimated time
            if result.delivery_time_minutes:
                if db.update_delivery_area_time(v3_id, result.delivery_time_minutes, overwrite=overwrite):
                    updated_delivery_areas += 1
                    logging.info(f"  ✓ Updated delivery area for {result.name} (V3 ID: {v3_id})")
            
            # DELETE and RE-INSERT schedules strategy
            # Step 1: Delete existing delivery schedules
            if result.delivery_schedule:
                deleted = db.delete_schedules(v3_id, 'delivery')
                deleted_schedules += deleted
                if deleted > 0:
                    logging.info(f"  ✓ Deleted {deleted} existing delivery schedules for {result.name}")
            
            # Step 2: Delete existing takeout schedules  
            if result.takeout_schedule:
                deleted = db.delete_schedules(v3_id, 'takeout')
                deleted_schedules += deleted
                if deleted > 0:
                    logging.info(f"  ✓ Deleted {deleted} existing takeout schedules for {result.name}")
            
            # Step 3: Insert new delivery schedules
            for schedule in result.delivery_schedule:
                if schedule.is_valid():
                    if db.insert_schedule(
                        restaurant_id=v3_id,
                        schedule_type='delivery',
                        day_start=schedule.day,
                        time_start=schedule.time_start,
                        time_stop=schedule.time_stop
                    ):
                        inserted_schedules += 1
            
            # Step 4: Insert new takeout schedules
            for schedule in result.takeout_schedule:
                if schedule.is_valid():
                    if db.insert_schedule(
                        restaurant_id=v3_id,
                        schedule_type='takeout',
                        day_start=schedule.day,
                        time_start=schedule.time_start,
                        time_stop=schedule.time_stop
                    ):
                        inserted_schedules += 1
    
    logging.info(f"Database updates complete:")
    logging.info(f"  - Service configs updated: {updated_service_configs}")
    logging.info(f"  - Delivery areas updated: {updated_delivery_areas}")
    logging.info(f"  - Schedules deleted: {deleted_schedules}")
    logging.info(f"  - Schedules inserted: {inserted_schedules}")


def main():
    parser = argparse.ArgumentParser(description='V1 Delivery & Schedule Scraper')
    parser.add_argument('--test', action='store_true', 
                        help='Test mode: scrape only first 3 restaurants')
    parser.add_argument('--restaurant', type=int, 
                        help='Scrape specific V1 restaurant ID')
    parser.add_argument('--dry-run', action='store_true',
                        help='Scrape but do not update database')
    parser.add_argument('--no-headless', action='store_true',
                        help='Run browser with visible window')
    
    args = parser.parse_args()
    
    # Setup logging
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = LOG_DIR / f'v1_scraper_{timestamp}.log'
    setup_logging(str(log_file))
    
    logging.info("=" * 60)
    logging.info("V1 Delivery & Schedule Scraper")
    logging.info("=" * 60)
    
    # Get restaurants to scrape
    with DatabaseManager() as db:
        if args.restaurant:
            # Scrape specific restaurant
            restaurants = [r for r in db.get_v1_restaurants() 
                          if r['legacy_v1_id'] == args.restaurant]
            if not restaurants:
                logging.error(f"Restaurant with V1 ID {args.restaurant} not found")
                return
        else:
            restaurants = db.get_v1_restaurants()
            if args.test:
                restaurants = restaurants[:3]
    
    logging.info(f"Found {len(restaurants)} restaurants to scrape")
    
    if not restaurants:
        logging.warning("No restaurants to scrape")
        return
    
    # Scrape restaurants
    headless = not args.no_headless
    results = scrape_restaurants(restaurants, headless=headless)
    
    # Save results to JSON
    output_file = OUTPUT_DIR / f'v1_scraped_data_{timestamp}.json'
    save_results(results, output_file)
    
    # Also save to standard filename for easy access
    latest_file = OUTPUT_DIR / 'v1_scraped_data.json'
    save_results(results, latest_file)
    
    # Summary
    successful = sum(1 for r in results if r.scrape_success)
    failed = sum(1 for r in results if not r.scrape_success)
    
    logging.info("=" * 60)
    logging.info("Scraping Summary:")
    logging.info(f"  Total: {len(results)}")
    logging.info(f"  Successful: {successful}")
    logging.info(f"  Failed: {failed}")
    logging.info("=" * 60)
    
    # Update database
    if successful > 0:
        update_database(results, dry_run=args.dry_run)
    
    logging.info("Done!")


if __name__ == '__main__':
    main()

