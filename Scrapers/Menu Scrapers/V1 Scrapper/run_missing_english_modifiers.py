"""
Run English Modifier Scraper for Missing Restaurants

These restaurants were not in the original ENGLISH_RESTAURANTS list.
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

# Missing English restaurants
RESTAURANTS = [
    {'v3_id': 607, 'name': 'Aroy Thai', 'v1_id': 830},
    {'v3_id': 87, 'name': 'Champa Thai Cuisine', 'v1_id': 203},
    {'v3_id': 160, 'name': 'Hong Kong Chinese Food Takeout', 'v1_id': 294},
    {'v3_id': 119, 'name': 'Hung Mein', 'v1_id': 239},
    {'v3_id': 8, 'name': 'Lucky Star Chinese Food', 'v1_id': 90},
    {'v3_id': 245, 'name': 'Orchid Sushi', 'v1_id': 387},
]


async def scrape_restaurant_modifiers(page, db, v3_id, name, v1_id, logger):
    """Scrape and insert modifier groups for a single restaurant."""
    stats = {'groups': 0, 'modifiers': 0, 'prices': 0}
    
    try:
        modifier_groups = await extract_modifier_groups(page, v1_id, "english", logger)
        
        for group_data in modifier_groups:
            try:
                group_id = insert_modifier_group(db, v3_id, group_data, "english", logger)
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
                            "english", logger
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
    logger = setup_logging("missing_english_modifiers")
    
    logger.info("=" * 60)
    logger.info("ENGLISH MODIFIER SCRAPER - Missing Restaurants")
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

