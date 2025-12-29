"""
Run French modifier scraper on Econo Pizza only.
"""
import asyncio
from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    CRM_BASE_URL,
    DB_CONNECTION_STRING
)
from french_modifier_scraper import scrape_restaurant_modifiers

# Target restaurant
RESTAURANTS = [
    {'v3_id': 1009, 'name': 'Econo Pizza', 'v1_id': 1095},
]

async def run_scraper():
    logger = setup_logging("french_modifiers_econo")
    logger.info("=" * 60)
    logger.info("FRENCH MODIFIER SCRAPER - Econo Pizza")
    logger.info("=" * 60)
    
    db = DatabaseConnection(DB_CONNECTION_STRING, logger)
    
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to CRM")
            return
        
        for i, restaurant in enumerate(RESTAURANTS):
            logger.info("-" * 40)
            logger.info(f"[{i+1}/{len(RESTAURANTS)}] Processing: {restaurant['name']}")
            
            result = await scrape_restaurant_modifiers(
                page, db, 
                restaurant['v3_id'], restaurant['name'], restaurant['v1_id'],
                logger
            )
            logger.info(f"  Done: {result['groups']} groups, {result['modifiers']} modifiers, {result['prices']} prices")
        
        await browser.close()
    
    db.close()
    logger.info("=" * 60)
    logger.info("SCRAPER COMPLETED")
    logger.info("=" * 60)

if __name__ == "__main__":
    asyncio.run(run_scraper())

