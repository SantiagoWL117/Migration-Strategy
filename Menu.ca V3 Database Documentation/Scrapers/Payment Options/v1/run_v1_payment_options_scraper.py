"""
V1 Payment Options Scraper - Runner Script

Scrapes payment options from V1 CRM for all V1 restaurants and updates
the menuca_v3.restaurant_payment_options table.

Usage:
    python run_v1_payment_options_scraper.py           # Scrape all V1 restaurants
    python run_v1_payment_options_scraper.py --test    # Test with first 5 restaurants
    python run_v1_payment_options_scraper.py --dry-run # Show what would be updated without making changes
"""

import asyncio
import argparse
from datetime import datetime
from playwright.async_api import async_playwright

from v1_payment_options_scraper import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    scrape_restaurant_payment_options,
    get_v1_restaurants,
    sync_payment_options,
)


async def main():
    """Main entry point for the V1 payment options scraper."""
    
    # Parse arguments
    parser = argparse.ArgumentParser(description='Scrape V1 restaurant payment options')
    parser.add_argument('--test', action='store_true', help='Test mode - only process first 5 restaurants')
    parser.add_argument('--dry-run', action='store_true', help='Dry run - show changes without updating database')
    parser.add_argument('--limit', type=int, help='Limit number of restaurants to process')
    parser.add_argument('--restaurant-id', type=int, help='Process only a specific restaurant (V3 ID)')
    args = parser.parse_args()
    
    # Setup logging
    logger = setup_logging('v1_payment_options_scraper')
    
    logger.info("=" * 60)
    logger.info("V1 Payment Options Scraper")
    logger.info("=" * 60)
    
    if args.dry_run:
        logger.info("DRY RUN MODE - No database changes will be made")
    if args.test:
        logger.info("TEST MODE - Processing first 5 restaurants only")
    
    # Statistics
    stats = {
        'total': 0,
        'processed': 0,
        'scraped': 0,
        'inserted': 0,
        'updated': 0,
        'unchanged': 0,
        'errors': 0
    }
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    db.connect()
    
    try:
        # Get V1 restaurants
        restaurants = get_v1_restaurants(db, logger)
        stats['total'] = len(restaurants)
        
        # Filter by specific restaurant if requested
        if args.restaurant_id:
            restaurants = [r for r in restaurants if r['v3_id'] == args.restaurant_id]
            if not restaurants:
                logger.error(f"Restaurant with V3 ID {args.restaurant_id} not found or is not a V1 restaurant")
                return
            logger.info(f"Processing single restaurant: {restaurants[0]['name']} (V3 ID: {args.restaurant_id})")
        
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
                    # Scrape payment options
                    scraped = await scrape_restaurant_payment_options(page, v1_id, logger)
                    
                    if scraped is None:
                        # Check if session expired
                        if not await login_to_crm(page, logger):
                            logger.error("Session expired and re-login failed. Aborting.")
                            break
                        # Retry scrape after re-login
                        scraped = await scrape_restaurant_payment_options(page, v1_id, logger)
                    
                    if scraped is None:
                        logger.warning(f"  Could not scrape payment options")
                        stats['errors'] += 1
                        continue
                    
                    if not scraped:
                        logger.warning(f"  No payment options found")
                        stats['errors'] += 1
                        continue
                    
                    stats['scraped'] += 1
                    stats['processed'] += 1
                    
                    # Log what was scraped
                    enabled_count = sum(1 for opt in scraped if opt['is_enabled'])
                    logger.info(f"  Found {len(scraped)} payment options ({enabled_count} enabled)")
                    
                    if args.dry_run:
                        # Just show what would be synced
                        for opt in scraped:
                            status = "✓" if opt['is_enabled'] else "✗"
                            logger.info(f"    [{status}] {opt['payment_method']}: {opt['english_label']} / {opt['french_label']}")
                        logger.info(f"  [DRY RUN] Would sync {len(scraped)} payment options")
                    else:
                        # Sync to database
                        sync_stats = sync_payment_options(db, v3_id, scraped, logger)
                        stats['inserted'] += sync_stats['inserted']
                        stats['updated'] += sync_stats['updated']
                        stats['unchanged'] += sync_stats['unchanged']
                        
                        if sync_stats['inserted'] > 0 or sync_stats['updated'] > 0:
                            logger.info(f"  Synced: {sync_stats['inserted']} inserted, {sync_stats['updated']} updated, {sync_stats['unchanged']} unchanged")
                        else:
                            logger.info(f"  No changes needed ({sync_stats['unchanged']} options already up-to-date)")
                    
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
        logger.info(f"Processed: {stats['processed']}")
        logger.info(f"Successfully scraped: {stats['scraped']}")
        
        if not args.dry_run:
            logger.info(f"Database operations:")
            logger.info(f"  - Inserted: {stats['inserted']}")
            logger.info(f"  - Updated: {stats['updated']}")
            logger.info(f"  - Unchanged: {stats['unchanged']}")
        
        logger.info(f"Errors: {stats['errors']}")
        
        if args.dry_run:
            logger.info("")
            logger.info("This was a DRY RUN - no database changes were made")
            logger.info("Run without --dry-run to apply changes")
        
    finally:
        db.close()


if __name__ == '__main__':
    asyncio.run(main())
