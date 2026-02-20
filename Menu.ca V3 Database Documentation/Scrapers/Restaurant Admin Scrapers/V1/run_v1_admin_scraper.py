"""
V1 Admin Contacts Scraper Runner

Orchestrates the scraping of admin contacts from V1 CRM and stores them
in the menuca_v3 database.

Usage:
    python run_v1_admin_scraper.py                # Run all restaurants
    python run_v1_admin_scraper.py --test 781    # Test with single V1 ID
    python run_v1_admin_scraper.py --dry-run     # Preview without database changes

Features:
- Auto-resume: Tracks processed restaurants
- Edge case handling: Duplicates, missing emails, multiple contacts
- Supabase Auth integration: Creates auth.users for each admin
- Logging: Detailed logs in logs/ directory
"""

import asyncio
import argparse
import sys
from datetime import datetime
from typing import List, Dict, Optional

from playwright.async_api import async_playwright

from v1_admin_contacts_scraper import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    scrape_restaurant_contacts,
    filter_contacts_by_email,
    create_supabase_auth_user,
    get_existing_admin_by_email,
    insert_admin_user,
    update_admin_user,
    check_restaurant_link_exists,
    insert_restaurant_link,
    get_v3_restaurant_id,
    get_restaurants_to_scrape,
    RESTAURANT_ADMIN_ROLE_ID,
)

# Ensure UTF-8 output on Windows
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')


async def process_restaurant_contacts(
    page,
    db: DatabaseConnection,
    restaurant: Dict,
    logger,
    dry_run: bool = False
) -> Dict:
    """
    Process all contacts for a single restaurant.
    
    Steps:
    1. Scrape contacts from V1 CRM
    2. Filter by email (handle edge cases)
    3. For each unique contact:
       a. Check if admin exists by email
       b. Create/update Supabase Auth user
       c. Create/update admin_users record
       d. Link admin to restaurant
    
    Returns stats dict.
    """
    stats = {
        'contacts_found': 0,
        'contacts_with_email': 0,
        'admins_created': 0,
        'admins_updated': 0,
        'links_created': 0,
        'skipped': 0,
        'errors': []
    }
    
    v1_id = restaurant['v1_id']
    v3_id = restaurant['v3_id']
    name = restaurant['name']
    
    try:
        # Step 1: Scrape contacts from V1 CRM
        all_contacts = await scrape_restaurant_contacts(page, v1_id, logger)
        stats['contacts_found'] = len(all_contacts)
        
        if not all_contacts:
            logger.info(f"  No contacts found - skipping")
            stats['skipped'] = 1
            return stats
        
        # Step 2: Filter contacts by email (edge case handling)
        unique_contacts = filter_contacts_by_email(all_contacts, logger)
        stats['contacts_with_email'] = len(unique_contacts)
        
        if not unique_contacts:
            logger.info(f"  No contacts with email - skipping")
            stats['skipped'] = 1
            return stats
        
        logger.info(f"  Found {len(unique_contacts)} unique contacts with email")
        
        # Step 3: Process each contact
        for contact in unique_contacts:
            email = contact['email']
            
            try:
                if dry_run:
                    logger.info(f"    [DRY RUN] Would process: {email}")
                    continue
                
                # Check if admin already exists
                existing_admin = get_existing_admin_by_email(db, email, logger)
                
                if existing_admin:
                    # Update existing admin
                    admin_id = existing_admin['id']
                    auth_user_id = existing_admin.get('auth_user_id')
                    
                    # Create auth user if missing
                    if not auth_user_id:
                        auth_user_id = await create_supabase_auth_user(email, logger)
                    
                    # Update admin record
                    update_admin_user(db, admin_id, contact, auth_user_id, logger)
                    stats['admins_updated'] += 1
                    
                else:
                    # Create new admin
                    # First create Supabase Auth user
                    auth_user_id = await create_supabase_auth_user(email, logger)
                    
                    if not auth_user_id:
                        error_msg = f"Failed to create auth user for {email}"
                        logger.error(f"    {error_msg}")
                        stats['errors'].append(error_msg)
                        continue
                    
                    # Then create admin_users record
                    admin_id = insert_admin_user(db, contact, auth_user_id, logger)
                    
                    if not admin_id:
                        error_msg = f"Failed to create admin_user for {email}"
                        logger.error(f"    {error_msg}")
                        stats['errors'].append(error_msg)
                        continue
                    
                    stats['admins_created'] += 1
                
                # Link admin to restaurant if not already linked
                if not check_restaurant_link_exists(db, admin_id, v3_id, logger):
                    insert_restaurant_link(db, admin_id, v3_id, logger)
                    stats['links_created'] += 1
                else:
                    logger.debug(f"    Admin {admin_id} already linked to restaurant {v3_id}")
                
            except Exception as e:
                error_msg = f"Error processing contact {email}: {e}"
                logger.error(f"    {error_msg}")
                stats['errors'].append(error_msg)
                continue
        
    except Exception as e:
        error_msg = f"Error processing restaurant {name} (V1: {v1_id}): {e}"
        logger.error(error_msg)
        stats['errors'].append(error_msg)
    
    return stats


async def run_scraper(
    restaurants: List[Dict] = None,
    dry_run: bool = False,
    test_v1_id: int = None
):
    """
    Main scraper entry point.
    
    Args:
        restaurants: List of restaurant dicts to process. If None, fetches all.
        dry_run: If True, don't make database changes.
        test_v1_id: If set, only process this V1 restaurant ID.
    """
    logger = setup_logging("v1_admin_contacts")
    logger.info("=" * 60)
    logger.info("V1 ADMIN CONTACTS SCRAPER")
    logger.info("=" * 60)
    logger.info(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    if dry_run:
        logger.info("DRY RUN MODE - No database changes will be made")
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    db.connect()
    
    # Get restaurants to scrape
    if test_v1_id:
        # Test mode - single restaurant
        v3_id = get_v3_restaurant_id(db, test_v1_id, logger)
        if not v3_id:
            logger.error(f"No V3 restaurant found for V1 ID {test_v1_id}")
            db.close()
            return
        
        restaurants = [{
            'v1_id': test_v1_id,
            'v3_id': v3_id,
            'name': f'Test Restaurant (V1: {test_v1_id})'
        }]
        logger.info(f"TEST MODE: Processing single restaurant V1 ID {test_v1_id}")
    elif restaurants is None:
        restaurants = get_restaurants_to_scrape(db, logger)
    
    if not restaurants:
        logger.error("No restaurants to process")
        db.close()
        return
    
    logger.info(f"Total restaurants to process: {len(restaurants)}")
    
    # Initialize totals
    totals = {
        'restaurants': 0,
        'contacts_found': 0,
        'contacts_with_email': 0,
        'admins_created': 0,
        'admins_updated': 0,
        'links_created': 0,
        'skipped': 0,
        'errors': []
    }
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        try:
            # Login to CRM
            if not await login_to_crm(page, logger):
                logger.error("Failed to login to CRM - aborting")
                await browser.close()
                db.close()
                return
            
            # Process each restaurant
            total = len(restaurants)
            for idx, restaurant in enumerate(restaurants, 1):
                logger.info("-" * 40)
                logger.info(f"[{idx}/{total}] {restaurant['name']} (V3: {restaurant['v3_id']}, V1: {restaurant['v1_id']})")
                
                try:
                    stats = await process_restaurant_contacts(
                        page, db, restaurant, logger, dry_run
                    )
                    
                    totals['restaurants'] += 1
                    totals['contacts_found'] += stats['contacts_found']
                    totals['contacts_with_email'] += stats['contacts_with_email']
                    totals['admins_created'] += stats['admins_created']
                    totals['admins_updated'] += stats['admins_updated']
                    totals['links_created'] += stats['links_created']
                    totals['skipped'] += stats['skipped']
                    totals['errors'].extend(stats['errors'])
                    
                    # Summary for this restaurant
                    if stats['admins_created'] or stats['admins_updated'] or stats['links_created']:
                        logger.info(f"  Result: {stats['admins_created']} created, {stats['admins_updated']} updated, {stats['links_created']} links")
                    
                    # Progress heartbeat every 20 restaurants
                    if idx % 20 == 0:
                        logger.info(f"=== PROGRESS: {idx}/{total} restaurants processed ===")
                    
                except Exception as e:
                    logger.error(f"CRITICAL ERROR processing {restaurant['name']}: {e}")
                    totals['errors'].append(f"Restaurant {restaurant['name']}: {e}")
                    continue
        
        except Exception as e:
            logger.error(f"FATAL ERROR in scraper: {e}")
            raise
        
        finally:
            await browser.close()
            db.close()
    
    # Log summary
    logger.info("=" * 60)
    logger.info("SCRAPER SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info(f"Restaurants processed: {totals['restaurants']}")
    logger.info(f"Contacts found: {totals['contacts_found']}")
    logger.info(f"Contacts with email: {totals['contacts_with_email']}")
    logger.info(f"Admins created: {totals['admins_created']}")
    logger.info(f"Admins updated: {totals['admins_updated']}")
    logger.info(f"Restaurant links created: {totals['links_created']}")
    logger.info(f"Restaurants skipped (no contacts): {totals['skipped']}")
    logger.info(f"Errors: {len(totals['errors'])}")
    
    if totals['errors']:
        logger.warning("Errors encountered:")
        for error in totals['errors'][:20]:  # Show first 20
            logger.warning(f"  - {error}")
    
    logger.info("=" * 60)
    if dry_run:
        logger.info("DRY RUN COMPLETED - No changes were made")
    else:
        logger.info("SCRAPER COMPLETED SUCCESSFULLY")
    logger.info("=" * 60)
    
    return totals


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(description='V1 Admin Contacts Scraper')
    parser.add_argument('--test', type=int, metavar='V1_ID',
                        help='Test with a single V1 restaurant ID')
    parser.add_argument('--dry-run', action='store_true',
                        help='Preview changes without modifying database')
    
    args = parser.parse_args()
    
    asyncio.run(run_scraper(
        test_v1_id=args.test,
        dry_run=args.dry_run
    ))


if __name__ == "__main__":
    main()
