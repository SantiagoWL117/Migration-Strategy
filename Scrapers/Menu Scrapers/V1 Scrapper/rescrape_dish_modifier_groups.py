"""
Re-Scrape Dish Modifier Groups

Targets specific dishes that were not properly linked to their modifier groups.
Clears existing links and re-scrapes from V1 CRM.

Usage:
    python rescrape_dish_modifier_groups.py
"""

import asyncio
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from playwright.async_api import async_playwright, Page

from scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    CRM_BASE_URL,
    DB_CONNECTION_STRING
)

# Import category mapping from the original scraper
from dish_modifier_group_scraper import (
    CATEGORY_DETAILS_MAP,
    get_modifier_group_by_source_id,
    insert_dish_modifier_group,
    insert_modifier_group_details,
    get_input_value,
    extract_active_modifier_groups,
    extract_category_details
)


# =============================================================================
# DISHES TO RE-SCRAPE
# =============================================================================

# Format: (v3_dish_id, legacy_dish_id, dish_name, restaurant_v3_id, restaurant_v1_id, restaurant_name)
DISHES_TO_RESCRAPE = [
    # Lorenzo's Pizzeria - Vanier (V3 ID: 77, V1 ID: 192)
    (157456, 124271, "2 Lasagna with 2 Drinks and Garlic Bread", 77, 192, "Lorenzo's Pizzeria - Vanier"),
    (157455, 141256, "2 Shawarma Meal", 77, 192, "Lorenzo's Pizzeria - Vanier"),
    (157457, 124272, "2 Spaghetti with 2 Drinks and Garlic Bread", 77, 192, "Lorenzo's Pizzeria - Vanier"),
    
    # Mano City Pizza (V3 ID: 118, V1 ID: 238)
    (138176, 75740, "Combo Platter", 118, 238, "Mano City Pizza"),
    (138105, 91883, "Catering No6- Five Gyo and Five Pops", 118, 238, "Mano City Pizza"),
    (138106, 91884, "Catering No7- Five Regular Shawarma and Five Pops", 118, 238, "Mano City Pizza"),
    (138284, 18327, "Donair Plate", 118, 238, "Mano City Pizza"),
    (138283, 18326, "Donair Sandwich Platter", 118, 238, "Mano City Pizza"),
    (138268, 77391, "Fish & Chips", 118, 238, "Mano City Pizza"),
    (138267, 77390, "Shrimp In A Basket", 118, 238, "Mano City Pizza"),
    (138280, 18330, "Shawarma Plate", 118, 238, "Mano City Pizza"),
    (138279, 18329, "Shawarma Sandwich Platter", 118, 238, "Mano City Pizza"),
    
    # Nachos Loco Gatineau (V3 ID: 801, V1 ID: 1045)
    (145241, 122582, "2 Small Supreme Fries with Drinks", 801, 1045, "Nachos Loco Gatineau"),
    
    # Nachos Loco Hull (V3 ID: 790, V1 ID: 1033)
    (145288, 122590, "2 Small Supreme Fries with Drinks", 790, 1033, "Nachos Loco Hull"),
    
    # Papa Joe's Pizza - Downtown (V3 ID: 13, V1 ID: 95)
    (160018, 76355, "Combo 1", 13, 95, "Papa Joe's Pizza - Downtown"),
    (160019, 76356, "Combo 2", 13, 95, "Papa Joe's Pizza - Downtown"),
    (160020, 76357, "Combo 3", 13, 95, "Papa Joe's Pizza - Downtown"),
    (160121, 51933, "6 Cans", 13, 95, "Papa Joe's Pizza - Downtown"),
    
    # Prima Pizza (V3 ID: 824, V1 ID: 1069)
    (149286, 123220, "Aloo Tiki Burger COMBO", 824, 1069, "Prima Pizza"),
    (149280, 123217, "Bacon Cheeseburger COMBO", 824, 1069, "Prima Pizza"),
    (149288, 123221, "Beyond Meat Burger COMBO", 824, 1069, "Prima Pizza"),
    (149278, 123216, "Cheeseburger COMBO", 824, 1069, "Prima Pizza"),
    (149282, 123218, "Chicken Burger COMBO", 824, 1069, "Prima Pizza"),
    (149276, 123215, "Double Ham Burger COMBO", 824, 1069, "Prima Pizza"),
    (149274, 123214, "Hamburger COMBO", 824, 1069, "Prima Pizza"),
    (149284, 123219, "Veggie Burger COMBO", 824, 1069, "Prima Pizza"),
    (149259, 123211, "Chicken Fingers COMBO", 824, 1069, "Prima Pizza"),
    (149298, 123226, "Aloo Tiki Sub COMBO", 824, 1069, "Prima Pizza"),
    (149292, 123223, "Club Sub COMBO", 824, 1069, "Prima Pizza"),
    (149294, 123224, "Crispy Chicken Sub COMBO", 824, 1069, "Prima Pizza"),
    (149304, 123229, "Ham Sub COMBO", 824, 1069, "Prima Pizza"),
    (149308, 123232, "Meatball Marinara Sub COMBO", 824, 1069, "Prima Pizza"),
    (149290, 123222, "Pepperoni Pizza Sub COMBO", 824, 1069, "Prima Pizza"),
    (149300, 123227, "Philly Steak Sub COMBO", 824, 1069, "Prima Pizza"),
    (149306, 123230, "Turkey and Ham Sub COMBO", 824, 1069, "Prima Pizza"),
    (149302, 123228, "Turkey Sub COMBO", 824, 1069, "Prima Pizza"),
    (149296, 123225, "Veggie Sub COMBO", 824, 1069, "Prima Pizza"),
]


# =============================================================================
# DATABASE FUNCTIONS
# =============================================================================

def clear_dish_modifier_groups(db: DatabaseConnection, dish_ids: List[int], logger) -> Tuple[int, int]:
    """
    Clear existing dish_modifier_groups and modifier_group_details for specific dishes.
    
    Returns (dmg_deleted, details_deleted)
    """
    if not dish_ids:
        return 0, 0
    
    ids_str = ",".join(str(id) for id in dish_ids)
    
    # First delete modifier_group_details
    details_query = f"""
        DELETE FROM menuca_v3.modifier_group_details 
        WHERE dish_id IN ({ids_str})
    """
    db.execute_with_retry(details_query)
    
    # Get the count of deleted details
    count_query = f"""
        SELECT COUNT(*) FROM menuca_v3.modifier_group_details 
        WHERE dish_id IN ({ids_str})
    """
    
    # Then delete dish_modifier_groups
    dmg_query = f"""
        DELETE FROM menuca_v3.dish_modifier_groups 
        WHERE dish_id IN ({ids_str})
        RETURNING id
    """
    deleted_dmg = db.execute_with_retry(dmg_query, fetch=True)
    dmg_count = len(deleted_dmg) if deleted_dmg else 0
    
    # Since we already deleted, count details before
    # Actually run in sequence and count
    return dmg_count, 0  # Details already deleted before DMG


def get_dish_source_id(db: DatabaseConnection, dish_v3_id: int, logger) -> Optional[int]:
    """Get the source_id for a dish."""
    query = """
        SELECT source_id FROM menuca_v3.dishes WHERE id = %s
    """
    result = db.execute_with_retry(query, (dish_v3_id,), fetch=True)
    return result[0][0] if result else None


# =============================================================================
# SCRAPING FUNCTIONS
# =============================================================================

async def scrape_dish_modifier_groups(page: Page, db: DatabaseConnection,
                                       dish_data: tuple, logger,
                                       max_retries: int = 10, retry_delay: int = 5) -> Tuple[int, int]:
    """
    Scrape modifier groups for a single dish.
    
    dish_data: (v3_dish_id, legacy_dish_id, dish_name, restaurant_v3_id, restaurant_v1_id, restaurant_name)
    
    Returns (links_created, details_created)
    """
    v3_dish_id, legacy_dish_id, dish_name, restaurant_v3_id, restaurant_v1_id, restaurant_name = dish_data
    
    links_created = 0
    details_created = 0
    
    # Navigate to dish edit page
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={restaurant_v1_id}&load=editDish&showLang=en&menuEntry={legacy_dish_id}"
    
    logger.debug(f"  URL: {url}")
    
    # Retry logic for network errors
    for attempt in range(1, max_retries + 1):
        try:
            await page.goto(url, wait_until='networkidle', timeout=30000)
            await page.wait_for_timeout(1000)  # Wait for JS to fully execute
            break  # Success - exit retry loop
        except Exception as e:
            error_str = str(e)
            network_errors = ['ERR_NAME_NOT_RESOLVED', 'ERR_CONNECTION_TIMED_OUT', 
                            'ERR_CONNECTION_RESET', 'ERR_NETWORK_CHANGED',
                            'ERR_INTERNET_DISCONNECTED', 'ERR_CONNECTION_REFUSED',
                            'ERR_CONNECTION_ABORTED', 'interrupted by another navigation']
            
            is_network_error = any(err in error_str for err in network_errors)
            
            if is_network_error and attempt < max_retries:
                logger.warning(f"  Network error (attempt {attempt}/{max_retries}): {error_str[:100]}")
                logger.info(f"  Retrying in {retry_delay} seconds...")
                await asyncio.sleep(retry_delay)
                continue
            else:
                logger.error(f"  Failed to load dish page after {attempt} attempts: {e}")
                return 0, 0
    
    # Check if dish has any active modifier groups
    groups_div = await page.query_selector('#groups')
    if not groups_div:
        logger.warning(f"  No #groups div found for dish {dish_name}")
        return 0, 0
    
    # Extract active modifier groups (checked radio buttons)
    active_groups = await extract_active_modifier_groups(page, logger)
    
    if not active_groups:
        logger.info(f"  No active modifier groups for dish {dish_name}")
        return 0, 0
    
    logger.info(f"  {dish_name}: {len(active_groups)} active modifier groups found")
    
    # Process each active group
    categories_processed = set()
    
    for group in active_groups:
        # Find the V3 modifier group by source_id
        v3_group = get_modifier_group_by_source_id(
            db, restaurant_v3_id, group['v1_id'], logger
        )
        
        if not v3_group:
            logger.warning(f"    Modifier group not found in V3: {group['name']} (V1 ID: {group['v1_id']})")
            continue
        
        # Insert dish_modifier_group link
        dmg_id = insert_dish_modifier_group(db, v3_dish_id, v3_group['v3_id'], logger)
        if dmg_id:
            links_created += 1
            logger.info(f"    ✓ Linked: {dish_name} -> {v3_group['name']} (MG ID: {v3_group['v3_id']})")
        
        # Extract and insert category details (once per category per dish)
        if group['category'] not in categories_processed:
            categories_processed.add(group['category'])
            
            details = await extract_category_details(page, group['category'], logger)
            
            # Use header name if available, otherwise use group name
            detail_name = details['header_name'] if details['header_name'] else group['name']
            
            detail_id = insert_modifier_group_details(
                db=db,
                dish_id=v3_dish_id,
                name=detail_name,
                min_selections=details['min_selections'],
                max_selections=details['max_selections'],
                free_items=details['free_items'],
                display_order=details['display_order'],
                dish_modifier_group_id=dmg_id,
                logger=logger
            )
            
            if detail_id:
                details_created += 1
                logger.debug(f"    Details: {detail_name} (min:{details['min_selections']}, max:{details['max_selections']}, free:{details['free_items']}, order:{details['display_order']})")
    
    return links_created, details_created


async def run_rescraper():
    """
    Main entry point for the dish modifier group re-scraper.
    """
    logger = setup_logging("rescrape_dish_modifier_groups")
    
    logger.info("=" * 70)
    logger.info("DISH MODIFIER GROUP RE-SCRAPER")
    logger.info("=" * 70)
    logger.info(f"Target: {len(DISHES_TO_RESCRAPE)} dishes across 6 restaurants")
    logger.info("")
    
    # Initialize database connection
    db = DatabaseConnection(logger=logger)
    db.connect()
    
    # Get list of unique dish IDs
    dish_ids = [d[0] for d in DISHES_TO_RESCRAPE]
    
    # Step 1: Clear existing modifier group links for these dishes
    logger.info("-" * 70)
    logger.info("STEP 1: Clearing existing modifier group links...")
    logger.info("-" * 70)
    
    # Count existing before clearing
    count_query = f"""
        SELECT 
            (SELECT COUNT(*) FROM menuca_v3.dish_modifier_groups WHERE dish_id IN ({','.join(str(id) for id in dish_ids)})) as dmg_count,
            (SELECT COUNT(*) FROM menuca_v3.modifier_group_details WHERE dish_id IN ({','.join(str(id) for id in dish_ids)})) as details_count
    """
    counts = db.execute_with_retry(count_query, fetch=True)
    existing_dmg = counts[0][0] if counts else 0
    existing_details = counts[0][1] if counts else 0
    
    logger.info(f"  Existing dish_modifier_groups to delete: {existing_dmg}")
    logger.info(f"  Existing modifier_group_details to delete: {existing_details}")
    
    # Delete modifier_group_details first (FK constraint)
    if existing_details > 0:
        delete_details = f"""
            DELETE FROM menuca_v3.modifier_group_details 
            WHERE dish_id IN ({','.join(str(id) for id in dish_ids)})
        """
        db.execute_with_retry(delete_details)
        logger.info(f"  ✓ Deleted {existing_details} modifier_group_details")
    
    # Delete dish_modifier_groups
    if existing_dmg > 0:
        delete_dmg = f"""
            DELETE FROM menuca_v3.dish_modifier_groups 
            WHERE dish_id IN ({','.join(str(id) for id in dish_ids)})
        """
        db.execute_with_retry(delete_dmg)
        logger.info(f"  ✓ Deleted {existing_dmg} dish_modifier_groups")
    
    logger.info("")
    
    # Step 2: Re-scrape from V1 CRM
    logger.info("-" * 70)
    logger.info("STEP 2: Re-scraping from V1 CRM...")
    logger.info("-" * 70)
    
    total_links_created = 0
    total_details_created = 0
    dishes_with_modifiers = 0
    dishes_without_modifiers = 0
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        # Login to CRM
        logger.info("Logging in to V1 CRM...")
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to V1 CRM")
            return
        
        logger.info("")
        
        # Group dishes by restaurant for cleaner logging
        current_restaurant = None
        
        for i, dish_data in enumerate(DISHES_TO_RESCRAPE):
            v3_dish_id, legacy_dish_id, dish_name, restaurant_v3_id, restaurant_v1_id, restaurant_name = dish_data
            
            # Print restaurant header when it changes
            if current_restaurant != restaurant_name:
                current_restaurant = restaurant_name
                logger.info("")
                logger.info(f"📍 {restaurant_name} (V3: {restaurant_v3_id}, V1: {restaurant_v1_id})")
                logger.info("-" * 50)
            
            logger.info(f"[{i+1}/{len(DISHES_TO_RESCRAPE)}] {dish_name} (V3: {v3_dish_id}, V1: {legacy_dish_id})")
            
            try:
                links, details = await scrape_dish_modifier_groups(page, db, dish_data, logger)
                
                if links > 0:
                    dishes_with_modifiers += 1
                    total_links_created += links
                    total_details_created += details
                else:
                    dishes_without_modifiers += 1
                    
            except Exception as e:
                logger.error(f"  Error scraping dish: {e}")
                continue
            
            # Small delay between requests
            await asyncio.sleep(0.5)
        
        await browser.close()
    
    # Final summary
    logger.info("")
    logger.info("=" * 70)
    logger.info("RE-SCRAPER COMPLETED")
    logger.info("=" * 70)
    logger.info(f"Dishes processed: {len(DISHES_TO_RESCRAPE)}")
    logger.info(f"  - With modifier groups: {dishes_with_modifiers}")
    logger.info(f"  - Without modifier groups: {dishes_without_modifiers}")
    logger.info(f"Links created: {total_links_created}")
    logger.info(f"Details created: {total_details_created}")
    logger.info("")
    logger.info(f"Previous records deleted:")
    logger.info(f"  - dish_modifier_groups: {existing_dmg}")
    logger.info(f"  - modifier_group_details: {existing_details}")
    
    db.close()


if __name__ == "__main__":
    asyncio.run(run_rescraper())



