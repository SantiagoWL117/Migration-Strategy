"""
Run French Dish-Modifier Group Linker for Missing Restaurants

Links dishes to modifier groups for French restaurants that were missing from the original scraper.
"""

import asyncio
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
)
from french_dish_modifier_group_scraper import (
    scrape_restaurant,
    get_processed_dishes,
)

# French restaurants that just had modifier groups scraped
RESTAURANTS = [
    {'v3_id': 211, 'name': 'Erman Pizza', 'v1_id': 350},
    {'v3_id': 736, 'name': 'Greber Pizza et Shawarma', 'v1_id': 974},
    {'v3_id': 798, 'name': 'Kabylie Pizza', 'v1_id': 1042},
    {'v3_id': 614, 'name': 'Marina Pizza des Flandres', 'v1_id': 838},
    {'v3_id': 681, 'name': "Oka's Hull", 'v1_id': 914},
    {'v3_id': 797, 'name': 'Papa Burger', 'v1_id': 1041},
    {'v3_id': 822, 'name': 'Papa Burger Maloney', 'v1_id': 1066},
    {'v3_id': 810, 'name': 'Papa Grecque Cantley', 'v1_id': 1054},
    {'v3_id': 540, 'name': 'Papa Grecque des Flandres', 'v1_id': 758},
    {'v3_id': 616, 'name': 'Papa Grecque Maloney', 'v1_id': 840},
    {'v3_id': 70, 'name': 'Papa Pizza - Hull', 'v1_id': 184},
    {'v3_id': 602, 'name': 'Papa Pizza Cantley', 'v1_id': 825},
    {'v3_id': 795, 'name': 'Papa Pizza Chem. de Masson', 'v1_id': 1039},
    {'v3_id': 712, 'name': 'Patate Lou Lou', 'v1_id': 948},
    {'v3_id': 139, 'name': 'Pizza Bravo', 'v1_id': 264},
    {'v3_id': 562, 'name': 'Pizza des Hautes Plaines', 'v1_id': 782},
    {'v3_id': 726, 'name': 'Pizza Joanna', 'v1_id': 964},
    {'v3_id': 696, 'name': 'Pizza Maisonneuve', 'v1_id': 930},
    {'v3_id': 716, 'name': 'PizzaRama', 'v1_id': 953},
    {'v3_id': 820, 'name': 'Vieux Hull Pizza', 'v1_id': 1064},
]


async def run_linker():
    logger = setup_logging("missing_french_dish_linker")
    
    logger.info("=" * 60)
    logger.info("FRENCH DISH-MODIFIER LINKER - Missing Restaurants")
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



