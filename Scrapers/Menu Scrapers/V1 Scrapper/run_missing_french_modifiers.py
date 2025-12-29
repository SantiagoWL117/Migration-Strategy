"""
Run French Modifier Scraper for Missing Restaurants

These restaurants were not in the original FRENCH_RESTAURANTS list.
Includes restaurants that were in English list but returned 0 groups (likely French).
"""

import asyncio
from datetime import datetime
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    extract_modifier_groups,
    insert_modifier_group,
    insert_modifier,
    insert_modifier_prices,
    CRM_BASE_URL
)

# Missing French restaurants + ones that returned 0 from English scraper
RESTAURANTS = [
    # Were in English list but returned 0 groups (likely French)
    {'v3_id': 211, 'name': 'Erman Pizza', 'v1_id': 350},
    {'v3_id': 736, 'name': 'Greber Pizza et Shawarma', 'v1_id': 974},
    {'v3_id': 798, 'name': 'Kabylie Pizza', 'v1_id': 1042},
    # Missing from French list
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


async def scrape_restaurant_modifiers(page, db, v3_id, name, v1_id, logger):
    """Scrape and insert modifier groups for a single restaurant."""
    stats = {'groups': 0, 'modifiers': 0, 'prices': 0}
    
    try:
        modifier_groups = await extract_modifier_groups(page, v1_id, "french", logger)
        
        for group_data in modifier_groups:
            try:
                group_id = insert_modifier_group(db, v3_id, group_data, "french", logger)
                if not group_id:
                    continue
                
                stats['groups'] += 1
                
                for modifier_data in group_data['modifiers']:
                    try:
                        modifier_id = insert_modifier(db, group_id, modifier_data, logger)
                        if not modifier_id:
                            continue
                        
                        stats['modifiers'] += 1
                        
                        prices_inserted = insert_modifier_prices(
                            db, modifier_id, modifier_data['price_string'], 
                            "french", logger
                        )
                        stats['prices'] += prices_inserted
                    except Exception as e:
                        logger.error(f"Error inserting modifier: {e}")
            except Exception as e:
                logger.error(f"Error inserting group: {e}")
                
    except Exception as e:
        logger.error(f"Error scraping restaurant: {e}")
    
    return stats['groups'], stats['modifiers'], stats['prices']


async def run_scraper():
    logger = setup_logging("missing_french_modifiers")
    
    logger.info("=" * 60)
    logger.info("FRENCH MODIFIER SCRAPER - Missing Restaurants")
    logger.info("=" * 60)
    
    db = DatabaseConnection(logger=logger)
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to CRM")
            return
        
        total_groups = 0
        total_modifiers = 0
        total_prices = 0
        
        for i, restaurant in enumerate(RESTAURANTS, 1):
            logger.info("-" * 40)
            logger.info(f"[{i}/{len(RESTAURANTS)}] Processing: {restaurant['name']}")
            
            # Retry loop for network errors
            max_retries = 5
            for attempt in range(max_retries):
                try:
                    groups, modifiers, prices = await scrape_restaurant_modifiers(
                        page, db,
                        restaurant['v3_id'], restaurant['name'], restaurant['v1_id'],
                        logger
                    )
                    
                    total_groups += groups
                    total_modifiers += modifiers
                    total_prices += prices
                    
                    logger.info(f"  Done: {groups} groups, {modifiers} modifiers, {prices} prices")
                    break  # Success, exit retry loop
                    
                except Exception as e:
                    if "net::" in str(e) or "Network" in str(e) or "timeout" in str(e).lower():
                        logger.warning(f"  Network error (attempt {attempt + 1}/{max_retries}): {e}")
                        if attempt < max_retries - 1:
                            logger.info(f"  Retrying in 5 seconds...")
                            await asyncio.sleep(5)
                            # Try to recover the page
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
    logger.info("SCRAPER COMPLETED")
    logger.info(f"Total: {total_groups} groups, {total_modifiers} modifiers, {total_prices} prices")
    logger.info("=" * 60)


if __name__ == "__main__":
    asyncio.run(run_scraper())

