"""
French Modifier Group Scraper

Scrapes modifier groups, modifiers, and prices from V1 CRM for French menu restaurants.
Stores data in menuca_v3 schema:
- modifier_groups
- modifiers  
- modifier_prices

Features:
- Auto-resume: Skips already-processed restaurants on restart
- Auto-commit: Each DB operation commits immediately for safety
- Connection recovery: Automatically reconnects on connection loss
- Auto-flush logging: Logs are written immediately
"""

import asyncio
from datetime import datetime
from typing import List, Dict, Optional
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    extract_modifier_groups,
    insert_modifier_group,
    insert_modifier,
    insert_modifier_prices,
    get_processed_restaurants,
    restaurant_has_modifiers,
    CRM_BASE_URL
)

# French restaurants to scrape (V3_ID, Name, V1_ID)
FRENCH_RESTAURANTS = [
    (727, "La Maison du Burger", 965),
    (1011, "Mozza Pizza Gatineau", 132),
    (644, "Mozza Pizza Hull", 872),
    (1012, "Papa Pizza Des Flandres", 231),
    (1013, "Papa Pizza Maloney", 346),
    (1014, "Papa Pizza Val-Des-Monts", 703),
    (1015, "Poutinerie Québecurds Gatineau", 1046),
    (1016, "Roulas Grecque et Pizza", 173),
    (1017, "Sushi Express Chambly", 511),
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
        modifier_groups = await extract_modifier_groups(page, v1_id, "french", logger)
        
        for group_data in modifier_groups:
            try:
                # Insert modifier group (auto-commits)
                group_id = insert_modifier_group(db, v3_id, group_data, "french", logger)
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
                            "french", logger
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


async def run_french_scraper(restaurants: List[tuple] = None, skip_processed: bool = True):
    """
    Run the French modifier group scraper.
    
    Args:
        restaurants: List of (v3_id, name, v1_id) tuples. Defaults to FRENCH_RESTAURANTS.
        skip_processed: If True, skip restaurants that already have modifier data.
    """
    logger = setup_logging("french_modifier_scraper")
    logger.info("=" * 60)
    logger.info("FRENCH MODIFIER GROUP SCRAPER")
    logger.info("=" * 60)
    logger.info(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    if restaurants is None:
        restaurants = FRENCH_RESTAURANTS
    
    logger.info(f"Total restaurants in list: {len(restaurants)}")
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    
    # Get already-processed restaurants to skip
    processed_ids = set()
    if skip_processed:
        processed_ids = get_processed_restaurants(db, logger)
        logger.info(f"Will skip {len(processed_ids)} already-processed restaurants")
    
    # Filter restaurants to process
    restaurants_to_process = [
        (v3_id, name, v1_id) for v3_id, name, v1_id in restaurants
        if v3_id not in processed_ids
    ]
    logger.info(f"Restaurants to process: {len(restaurants_to_process)}")
    
    if not restaurants_to_process:
        logger.info("No restaurants to process - all already done!")
        return
    
    total_stats = {
        'restaurants': 0,
        'skipped': len(processed_ids),
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
            total = len(restaurants_to_process)
            for idx, (v3_id, name, v1_id) in enumerate(restaurants_to_process, 1):
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
                    
                    # Heartbeat every 5 restaurants (smaller list)
                    if idx % 5 == 0:
                        logger.info(f"=== PROGRESS: {idx}/{total} restaurants completed ===")
                        
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
    logger.info(f"Restaurants skipped (already done): {total_stats['skipped']}")
    logger.info(f"Modifier groups inserted: {total_stats['groups']}")
    logger.info(f"Modifiers inserted: {total_stats['modifiers']}")
    logger.info(f"Prices inserted: {total_stats['prices']}")
    logger.info(f"Errors: {len(total_stats['errors'])}")
    
    if total_stats['errors']:
        logger.warning("Errors encountered:")
        for error in total_stats['errors'][:20]:  # Show first 20
            logger.warning(f"  - {error}")
    
    logger.info("=" * 60)
    logger.info("SCRAPER COMPLETED SUCCESSFULLY")
    logger.info("=" * 60)
    
    return total_stats


if __name__ == "__main__":
    asyncio.run(run_french_scraper())
