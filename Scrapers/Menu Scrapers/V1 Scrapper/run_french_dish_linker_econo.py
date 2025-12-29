"""
Run French dish-modifier group linker on Econo Pizza only.
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
from french_dish_modifier_group_scraper import (
    scrape_dish_modifier_groups,
    get_dishes_for_restaurant,
    get_processed_dishes,
    CATEGORY_DETAILS_MAP
)

# Target restaurant
RESTAURANT = {'v3_id': 1009, 'name': 'Econo Pizza', 'v1_id': 1095}

async def run_scraper():
    logger = setup_logging("french_dish_linker_econo")
    logger.info("=" * 60)
    logger.info("FRENCH DISH-MODIFIER GROUP LINKER - Econo Pizza")
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
        
        logger.info("-" * 40)
        logger.info(f"Processing: {RESTAURANT['name']} (V3: {RESTAURANT['v3_id']}, V1: {RESTAURANT['v1_id']})")
        
        # Get dishes for this restaurant
        dishes = get_dishes_for_restaurant(db, RESTAURANT['v3_id'], logger)
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
                page, db, RESTAURANT, dish, logger
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
        
        await browser.close()
    
    db.close()
    logger.info("=" * 60)
    logger.info("SCRAPER COMPLETED")
    logger.info("=" * 60)

if __name__ == "__main__":
    asyncio.run(run_scraper())





