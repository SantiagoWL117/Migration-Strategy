"""
Run English dish-modifier group linker on All Out Burger restaurants (V1).
These are V1 restaurants that need modifier group scraping.
"""
import asyncio
from typing import Dict, List, Set, Tuple
from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    CRM_BASE_URL,
    DB_CONNECTION_STRING
)
from dish_modifier_group_scraper import (
    scrape_dish_modifier_groups,
    get_dishes_for_restaurant,
    get_processed_dishes,
    CATEGORY_DETAILS_MAP
)

# Target restaurants - All Out Burger (V1)
RESTAURANTS = [
    {'v3_id': 924, 'name': 'All Out Burger Bank St.', 'v1_id': 1013},
    {'v3_id': 948, 'name': 'All Out Burger Gladstone', 'v1_id': 1038},
    {'v3_id': 949, 'name': 'All Out Burger Montreal Rd', 'v1_id': 1071},
]

async def run_scraper():
    logger = setup_logging("all_out_burger_dish_linker")
    logger.info("=" * 60)
    logger.info("ENGLISH DISH-MODIFIER GROUP LINKER - All Out Burger (V1)")
    logger.info("=" * 60)
    
    db = DatabaseConnection(DB_CONNECTION_STRING, logger)
    
    # Get already processed dishes
    processed_dishes = get_processed_dishes(db, logger)
    
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to CRM")
            return
        
        grand_total_processed = 0
        grand_total_skipped = 0
        grand_total_links = 0
        grand_total_details = 0
        
        for r_idx, restaurant in enumerate(RESTAURANTS):
            logger.info("-" * 40)
            logger.info(f"[{r_idx+1}/{len(RESTAURANTS)}] Processing: {restaurant['name']} (V3: {restaurant['v3_id']}, V1: {restaurant['v1_id']})")
            
            # Get dishes for this restaurant
            dishes = get_dishes_for_restaurant(db, restaurant['v3_id'], logger)
            logger.info(f"  {len(dishes)} dishes to process")
            
            total_processed = 0
            total_skipped = 0
            total_links = 0
            total_details = 0
            
            for i, dish in enumerate(dishes):
                # Skip already processed
                if dish['v3_id'] in processed_dishes:
                    total_skipped += 1
                    continue
                
                links, details = await scrape_dish_modifier_groups(
                    page, db, restaurant, dish, logger
                )
                
                total_links += links
                total_details += details
                
                if links > 0:
                    total_processed += 1
                else:
                    total_skipped += 1
                
                # Progress every 10 dishes
                if (i + 1) % 10 == 0:
                    logger.info(f"  Progress: {i+1}/{len(dishes)} dishes")
            
            logger.info(f"  Result: {total_processed} processed, {total_skipped} skipped, {total_links} links, {total_details} details")
            
            grand_total_processed += total_processed
            grand_total_skipped += total_skipped
            grand_total_links += total_links
            grand_total_details += total_details
        
        await browser.close()
    
    db.close()
    logger.info("=" * 60)
    logger.info("SCRAPER SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total processed: {grand_total_processed}")
    logger.info(f"Total skipped: {grand_total_skipped}")
    logger.info(f"Total links created: {grand_total_links}")
    logger.info(f"Total details created: {grand_total_details}")
    logger.info("=" * 60)
    logger.info("SCRAPER COMPLETED")
    logger.info("=" * 60)

if __name__ == "__main__":
    asyncio.run(run_scraper())





