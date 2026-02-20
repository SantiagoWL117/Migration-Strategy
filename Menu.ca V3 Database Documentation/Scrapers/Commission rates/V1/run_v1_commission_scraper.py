"""
V1 Commission Rates Scraper - Runner Script

Scrapes commission rates from V1 CRM for all V1 restaurants and updates
the menuca_v3.restaurant_commission_configs table.

Usage:
    python run_v1_commission_scraper.py           # Scrape all V1 restaurants
    python run_v1_commission_scraper.py --test    # Test with first 5 restaurants
    python run_v1_commission_scraper.py --dry-run # Show what would be updated without making changes
"""

import asyncio
import argparse
from datetime import datetime
from playwright.async_api import async_playwright

from v1_commission_scraper import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    scrape_restaurant_commission,
    get_v1_restaurants,
    get_current_commission,
    update_commission_config,
    needs_update,
)


async def main():
    """Main entry point for the V1 commission scraper."""
    
    # Parse arguments
    parser = argparse.ArgumentParser(description='Scrape V1 restaurant commission rates')
    parser.add_argument('--test', action='store_true', help='Test mode - only process first 5 restaurants')
    parser.add_argument('--dry-run', action='store_true', help='Dry run - show changes without updating database')
    parser.add_argument('--limit', type=int, help='Limit number of restaurants to process')
    args = parser.parse_args()
    
    # Setup logging
    logger = setup_logging('v1_commission_scraper')
    
    logger.info("=" * 60)
    logger.info("V1 Commission Rates Scraper")
    logger.info("=" * 60)
    
    if args.dry_run:
        logger.info("DRY RUN MODE - No database changes will be made")
    if args.test:
        logger.info("TEST MODE - Processing first 5 restaurants only")
    
    # Statistics
    stats = {
        'total': 0,
        'scraped': 0,
        'updated': 0,
        'skipped_no_change': 0,
        'errors': 0
    }
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    db.connect()
    
    try:
        # Get V1 restaurants
        restaurants = get_v1_restaurants(db, logger)
        stats['total'] = len(restaurants)
        
        # Apply limits
        if args.test:
            restaurants = restaurants[:5]
            logger.info(f"Test mode: limited to {len(restaurants)} restaurants")
        elif args.limit:
            restaurants = restaurants[:args.limit]
            logger.info(f"Limited to {len(restaurants)} restaurants")
        
        logger.info(f"Processing {len(restaurants)} restaurants")
        logger.info("-" * 60)
        
        # Start Playwright browser
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context()
            page = await context.new_page()
            
            # Login to V1 CRM
            logger.info("Logging in to V1 CRM...")
            if not await login_to_crm(page, logger):
                logger.error("Failed to login to V1 CRM. Aborting.")
                return
            
            logger.info("Login successful. Starting scrape...")
            logger.info("-" * 60)
            
            # Process each restaurant
            for i, restaurant in enumerate(restaurants, 1):
                v3_id = restaurant['v3_id']
                v1_id = restaurant['v1_id']
                name = restaurant['name']
                
                logger.info(f"[{i}/{len(restaurants)}] {name} (V3 ID: {v3_id}, V1 ID: {v1_id})")
                
                try:
                    # Scrape commission data
                    scraped = await scrape_restaurant_commission(page, v1_id, logger)
                    
                    if scraped is None:
                        # Check if session expired
                        if not await login_to_crm(page, logger):
                            logger.error("Session expired and re-login failed. Aborting.")
                            break
                        # Retry scrape after re-login
                        scraped = await scrape_restaurant_commission(page, v1_id, logger)
                    
                    if scraped is None:
                        logger.warning(f"  Could not scrape commission data")
                        stats['errors'] += 1
                        continue
                    
                    stats['scraped'] += 1
                    
                    # Get current commission config
                    current = get_current_commission(db, v3_id, logger)
                    
                    # Check if update needed
                    if needs_update(current, scraped):
                        if args.dry_run:
                            old_rate = current['commission_rate'] if current else 0
                            old_base = current['commission_base'] if current else 'gross'
                            logger.info(f"  [DRY RUN] Would update: rate {old_rate}% -> {scraped['commission_rate']}%, base {old_base} -> {scraped['commission_base']}")
                            stats['updated'] += 1
                        else:
                            # Update database
                            if update_commission_config(db, v3_id, scraped['commission_rate'], scraped['commission_base'], logger):
                                stats['updated'] += 1
                            else:
                                stats['errors'] += 1
                    else:
                        logger.debug(f"  No change needed (rate={scraped['commission_rate']}%, base={scraped['commission_base']})")
                        stats['skipped_no_change'] += 1
                    
                    # Small delay between requests to be gentle on the server
                    await asyncio.sleep(0.5)
                    
                except Exception as e:
                    logger.error(f"  Error processing restaurant: {e}")
                    stats['errors'] += 1
                    continue
            
            await browser.close()
        
        # Print summary
        logger.info("=" * 60)
        logger.info("SCRAPE COMPLETE")
        logger.info("=" * 60)
        logger.info(f"Total V1 restaurants: {stats['total']}")
        logger.info(f"Processed: {len(restaurants)}")
        logger.info(f"Successfully scraped: {stats['scraped']}")
        logger.info(f"Updated: {stats['updated']}")
        logger.info(f"Skipped (no change): {stats['skipped_no_change']}")
        logger.info(f"Errors: {stats['errors']}")
        
        if args.dry_run:
            logger.info("")
            logger.info("This was a DRY RUN - no database changes were made")
            logger.info("Run without --dry-run to apply changes")
        
    finally:
        db.close()


if __name__ == '__main__':
    asyncio.run(main())
