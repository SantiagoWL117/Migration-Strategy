#!/usr/bin/env python3
"""
Distance-Based Delivery Fees Scraper - Main Entry Point

Scrapes distance-based delivery fee data from the V1 CRM for all V1 restaurants.

Usage:
    python main.py                    # Scrape all V1 restaurants
    python main.py --test             # Test with first 3 restaurants
    python main.py --restaurant 203   # Scrape specific V1 ID
    python main.py --dry-run          # Scrape but don't update database
"""
import argparse
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any

from scraper import DistanceBasedFeesScraper
from database import DistanceBasedFeesDB
from models import DistanceBasedFeeData
from config import OUTPUT_DIR, LOG_DIR


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
                       headless: bool = True) -> List[DistanceBasedFeeData]:
    """
    Scrape distance-based delivery fee data for a list of restaurants.
    
    Args:
        restaurants: List of dicts with 'id', 'name', 'legacy_v1_id'
        headless: Run browser in headless mode
    
    Returns:
        List of DistanceBasedFeeData objects with scraped data
    """
    results = []
    
    with DistanceBasedFeesScraper(headless=headless) as scraper:
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


def save_results(results: List[DistanceBasedFeeData], output_file: Path):
    """Save scraped results to JSON file."""
    data = {
        'scraped_at': datetime.now().isoformat(),
        'total_restaurants': len(results),
        'successful': sum(1 for r in results if r.scrape_success),
        'failed': sum(1 for r in results if not r.scrape_success),
        'uses_distance_based': sum(1 for r in results if r.uses_distance_based),
        'restaurants': [r.to_dict() for r in results]
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    logging.info(f"Results saved to {output_file}")


def update_database(results: List[DistanceBasedFeeData], dry_run: bool = False):
    """
    Update database with scraped data.
    
    Args:
        results: List of DistanceBasedFeeData objects
        dry_run: If True, don't actually update the database
    """
    if dry_run:
        logging.info("DRY RUN - No database updates will be made")
        return
    
    updated_flags = 0
    created_emails = 0
    created_companies = 0
    inserted_tiers = 0
    
    with DistanceBasedFeesDB() as db:
        for result in results:
            if not result.scrape_success:
                continue
            
            v3_id = result.v3_id
            
            # Set distance_based_delivery_fee flag
            if db.set_distance_based_flag(v3_id, result.uses_distance_based):
                updated_flags += 1
            
            if not result.uses_distance_based:
                continue
            
            # Get or create company emails
            email_ids = []
            for email in result.delivery_emails:
                try:
                    email_id = db.get_or_create_company_email(email)
                    email_ids.append(email_id)
                    created_emails += 1
                except Exception as e:
                    logging.error(f"Error with email {email}: {e}")
            
            # Create restaurant_delivery_companies links
            for email_id in email_ids:
                if db.upsert_delivery_company(
                    v3_id, email_id,
                    result.commission,
                    result.restaurant_pays_difference
                ):
                    created_companies += 1
            
            # Delete existing fee tiers and insert new ones
            deleted = db.delete_existing_fees(v3_id)
            if deleted > 0:
                logging.info(f"  Deleted {deleted} existing fee tiers for {result.name}")
            
            # Use first email ID for fee tiers (or None if no emails)
            primary_email_id = email_ids[0] if email_ids else None
            
            for tier in result.fee_tiers:
                if tier.is_valid():
                    if db.insert_fee_tier(
                        v3_id, primary_email_id, tier.distance_km,
                        tier.driver_earning, tier.restaurant_pays,
                        tier.vendor_pays, tier.total_delivery_fee
                    ):
                        inserted_tiers += 1
    
    logging.info(f"Database updates complete:")
    logging.info(f"  - Flags updated: {updated_flags}")
    logging.info(f"  - Emails processed: {created_emails}")
    logging.info(f"  - Company links created: {created_companies}")
    logging.info(f"  - Fee tiers inserted: {inserted_tiers}")


def main():
    parser = argparse.ArgumentParser(description='Distance-Based Delivery Fees Scraper')
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
    log_file = LOG_DIR / f'distance_fees_scraper_{timestamp}.log'
    setup_logging(str(log_file))
    
    logging.info("=" * 60)
    logging.info("Distance-Based Delivery Fees Scraper")
    logging.info("=" * 60)
    
    # Get restaurants to scrape
    with DistanceBasedFeesDB() as db:
        if args.restaurant:
            # Scrape specific restaurant
            all_restaurants = db.get_v1_restaurants()
            restaurants = [r for r in all_restaurants 
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
    output_file = OUTPUT_DIR / f'distance_fees_scraped_{timestamp}.json'
    save_results(results, output_file)
    
    # Also save to standard filename for easy access
    latest_file = OUTPUT_DIR / 'distance_fees_scraped.json'
    save_results(results, latest_file)
    
    # Summary
    successful = sum(1 for r in results if r.scrape_success)
    failed = sum(1 for r in results if not r.scrape_success)
    uses_distance = sum(1 for r in results if r.uses_distance_based)
    
    logging.info("=" * 60)
    logging.info("Scraping Summary:")
    logging.info(f"  Total: {len(results)}")
    logging.info(f"  Successful: {successful}")
    logging.info(f"  Failed: {failed}")
    logging.info(f"  Uses distance-based fees: {uses_distance}")
    logging.info("=" * 60)
    
    # Update database
    if successful > 0:
        update_database(results, dry_run=args.dry_run)
    
    logging.info("Done!")


if __name__ == '__main__':
    main()

