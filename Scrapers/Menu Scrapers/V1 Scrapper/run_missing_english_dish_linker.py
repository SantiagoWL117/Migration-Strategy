"""
Run English Dish-Modifier Group Linker for Missing Restaurants

Links dishes to modifier groups for restaurants that were missing from the original scraper.
"""

import asyncio
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
)
from dish_modifier_group_scraper import (
    scrape_restaurant,
    get_processed_dishes,
)

# Restaurants that just had modifier groups scraped
RESTAURANTS = [
    {'v3_id': 607, 'name': 'Aroy Thai', 'v1_id': 830},
    {'v3_id': 87, 'name': 'Champa Thai Cuisine', 'v1_id': 203},
    {'v3_id': 160, 'name': 'Hong Kong Chinese Food Takeout', 'v1_id': 294},
    {'v3_id': 119, 'name': 'Hung Mein', 'v1_id': 239},
    {'v3_id': 8, 'name': 'Lucky Star Chinese Food', 'v1_id': 90},
    {'v3_id': 245, 'name': 'Orchid Sushi', 'v1_id': 387},
]


async def run_linker():
    logger = setup_logging("missing_english_dish_linker")
    
    logger.info("=" * 60)
    logger.info("ENGLISH DISH-MODIFIER LINKER - Missing Restaurants")
    logger.info("=" * 60)
    
    db = DatabaseConnection(logger=logger)
    
    # Get already processed dishes to skip
    processed_dishes = get_processed_dishes(db, logger)
    logger.info(f"Found {len(processed_dishes)} already processed dishes")
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to CRM")
            return
        
        total_processed = 0
        total_skipped = 0
        total_links = 0
        total_details = 0
        
        for i, restaurant in enumerate(RESTAURANTS, 1):
            logger.info("-" * 40)
            logger.info(f"[{i}/{len(RESTAURANTS)}] Processing: {restaurant['name']} (V3: {restaurant['v3_id']}, V1: {restaurant['v1_id']})")
            
            # Retry loop for network errors
            max_retries = 5
            for attempt in range(max_retries):
                try:
                    processed, skipped, links, details = await scrape_restaurant(
                        page, db, restaurant, processed_dishes, logger
                    )
                    
                    total_processed += processed
                    total_skipped += skipped
                    total_links += links
                    total_details += details
                    
                    logger.info(f"  Result: {processed} processed, {skipped} skipped, {links} links, {details} details")
                    break  # Success
                    
                except Exception as e:
                    if "net::" in str(e) or "Network" in str(e) or "timeout" in str(e).lower():
                        logger.warning(f"  Network error (attempt {attempt + 1}/{max_retries}): {e}")
                        if attempt < max_retries - 1:
                            logger.info(f"  Retrying in 5 seconds...")
                            await asyncio.sleep(5)
                            try:
                                await page.reload()
                            except:
                                pass
                        else:
                            logger.error(f"  Failed after {max_retries} attempts, skipping restaurant")
                    else:
                        logger.error(f"  Error: {e}")
                        break
        
        await browser.close()
    
    logger.info("=" * 60)
    logger.info("LINKER COMPLETED")
    logger.info(f"Dishes processed: {total_processed}")
    logger.info(f"Dishes skipped: {total_skipped}")
    logger.info(f"Links created: {total_links}")
    logger.info(f"Details created: {total_details}")
    logger.info("=" * 60)


if __name__ == "__main__":
    asyncio.run(run_linker())



