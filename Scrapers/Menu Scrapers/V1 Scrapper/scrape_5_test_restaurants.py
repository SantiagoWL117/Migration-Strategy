"""
Scrape the 5 test restaurants with all bug fixes applied.

Features:
- Auto-commit: Each DB operation commits immediately for safety
- Connection recovery: Automatically reconnects on connection loss
- Auto-flush logging: Logs are written immediately
"""
import asyncio
from datetime import datetime
from typing import List, Dict
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    extract_modifier_groups,
    insert_modifier_group,
    insert_modifier,
    insert_modifier_prices
)

# 5 Test restaurants (V3_ID, Name, V1_ID)
TEST_RESTAURANTS = [
    (69, "Aylmer BBQ", 183),
    (630, "Asia Garden Ottawa", 856),
    (756, "Little Gyros Greek Grill", 998),
    (735, "Amicci Pizza", 973),
    (328, "JN Pizza", 489),
]


async def scrape_restaurant_modifiers(page, db: DatabaseConnection, 
                                       v3_id: int, name: str, v1_id: int,
                                       logger) -> Dict:
    """
    Scrape and insert modifier groups for a single restaurant.
    Each DB operation auto-commits for safety.
    """
    stats = {
        'groups': 0,
        'modifiers': 0,
        'prices': 0,
        'errors': []
    }
    
    try:
        # Extract modifier groups from CRM
        modifier_groups = await extract_modifier_groups(page, v1_id, "english", logger)
        
        for group_data in modifier_groups:
            try:
                # Insert modifier group (auto-commits)
                group_id = insert_modifier_group(db, v3_id, group_data, "english", logger)
                if not group_id:
                    continue
                
                stats['groups'] += 1
                
                # Insert modifiers and their prices (each auto-commits)
                for modifier_data in group_data['modifiers']:
                    try:
                        modifier_id = insert_modifier(db, group_id, modifier_data, logger)
                        if not modifier_id:
                            continue
                        
                        stats['modifiers'] += 1
                        
                        # Insert prices (auto-commits)
                        price_count = insert_modifier_prices(
                            db, modifier_id, modifier_data['price_string'], 
                            "english", logger
                        )
                        stats['prices'] += price_count
                        
                    except Exception as e:
                        error_msg = f"Error with modifier {modifier_data.get('name', 'unknown')}: {e}"
                        logger.error(error_msg)
                        stats['errors'].append(error_msg)
                        # Continue with next modifier
                
            except Exception as e:
                error_msg = f"Error processing group {group_data.get('name', 'unknown')}: {e}"
                logger.error(error_msg)
                stats['errors'].append(error_msg)
                # Continue with next group
        
    except Exception as e:
        error_msg = f"Error scraping restaurant: {e}"
        logger.error(error_msg)
        stats['errors'].append(error_msg)
    
    return stats


async def run_test_scraper():
    """Run the scraper for 5 test restaurants."""
    logger = setup_logging("scrape_5_test_restaurants")
    logger.info("=" * 60)
    logger.info("SCRAPING 5 TEST RESTAURANTS")
    logger.info("=" * 60)
    logger.info(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    restaurants = TEST_RESTAURANTS
    logger.info(f"Restaurants to process: {len(restaurants)}")
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    
    total_stats = {
        'restaurants': 0,
        'groups': 0,
        'modifiers': 0,
        'prices': 0,
        'errors': []
    }
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        try:
            # Login to CRM
            if not await login_to_crm(page, logger):
                logger.error("Failed to login to CRM")
                return
            
            # Process each restaurant
            total = len(restaurants)
            for idx, (v3_id, name, v1_id) in enumerate(restaurants, 1):
                logger.info("-" * 40)
                logger.info(f"[{idx}/{total}] Processing: {name} (V3: {v3_id}, V1: {v1_id})")
                
                try:
                    stats = await scrape_restaurant_modifiers(
                        page, db, v3_id, name, v1_id, logger
                    )
                    
                    total_stats['restaurants'] += 1
                    total_stats['groups'] += stats['groups']
                    total_stats['modifiers'] += stats['modifiers']
                    total_stats['prices'] += stats['prices']
                    total_stats['errors'].extend(stats['errors'])
                    
                    logger.info(f"  Done: {stats['groups']} groups, {stats['modifiers']} modifiers, {stats['prices']} prices")
                    
                except Exception as e:
                    logger.error(f"CRITICAL ERROR processing {name}: {e}")
                    total_stats['errors'].append(f"Restaurant {name}: {e}")
                    # Continue with next restaurant - don't crash!
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
    logger.info(f"Restaurants processed: {total_stats['restaurants']}")
    logger.info(f"Modifier groups inserted: {total_stats['groups']}")
    logger.info(f"Modifiers inserted: {total_stats['modifiers']}")
    logger.info(f"Prices inserted: {total_stats['prices']}")
    logger.info(f"Errors: {len(total_stats['errors'])}")
    
    if total_stats['errors']:
        logger.warning("Errors encountered:")
        for error in total_stats['errors'][:10]:
            logger.warning(f"  - {error}")
    
    logger.info("=" * 60)
    logger.info("TEST SCRAPER COMPLETED SUCCESSFULLY")
    logger.info("=" * 60)
    
    return total_stats


if __name__ == "__main__":
    asyncio.run(run_test_scraper())
