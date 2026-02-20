"""
French Dish to Modifier Group Linker Scraper

Links French dishes to their modifier groups and extracts modifier group details.
Stores data in menuca_v3 schema:
- dish_modifier_groups (junction table: dish_id → modifier_group_id)
- modifier_group_details (per-dish modifier group configuration)

Key difference from English scraper:
- Uses showLang=fr in URL instead of showLang=en
- Targets French restaurants

Features:
- Auto-resume: Skips already-processed dishes on restart
- Auto-commit: Each DB operation commits immediately for safety
- Connection recovery: Automatically reconnects on connection loss
- Auto-flush logging: Logs are written immediately
- Skips dishes without active modifier groups
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


# =============================================================================
# CATEGORY DETAILS MAPPING
# =============================================================================
# Maps category codes to their corresponding form field IDs for extracting details

CATEGORY_DETAILS_MAP = {
    'ci': {  # Custom Ingredients
        'header_id': 'ciHeader',
        'min_id': 'minci',
        'max_id': 'maxci',
        'free_id': 'freeCI',
        'order_id': 'displayOrderCI'
    },
    'sa': {  # Sauce
        'header_id': 'sauceHeader',
        'min_id': 'minSauce',
        'max_id': 'maxSauce',
        'free_id': 'freeSauce',
        'order_id': 'displayOrderSauce'
    },
    'sd': {  # Side Dish
        'header_id': 'sideDishHeader',
        'min_id': 'minSD',
        'max_id': 'maxSD',
        'free_id': 'freeSD',
        'order_id': 'displayOrderSD'
    },
    'd': {  # Drinks
        'header_id': 'drinksHeader',
        'min_id': 'minDrink',
        'max_id': 'maxDrink',
        'free_id': 'freeDrink',
        'order_id': 'displayOrderDrink'
    },
    'e': {  # Extras
        'header_id': 'extraHeader',
        'min_id': 'minExtra',
        'max_id': 'maxExtra',
        'free_id': 'freeExtra',
        'order_id': 'displayOrderExtras'
    },
    'br': {  # Bread
        'header_id': 'breadHeader',
        'min_id': None,  # Bread doesn't have min/max/free
        'max_id': None,
        'free_id': None,
        'order_id': 'displayOrderBread'
    },
    'dr': {  # Dressing
        'header_id': 'dressingHeader',
        'min_id': 'minDressing',
        'max_id': 'maxDressing',
        'free_id': 'freeDressing',
        'order_id': 'displayOrderDressing'
    },
    'cm': {  # Cooking Method
        'header_id': 'cmHeader',
        'min_id': None,  # Cooking method doesn't have min/max/free
        'max_id': None,
        'free_id': None,
        'order_id': 'displayOrderCM'
    }
}


# =============================================================================
# FRENCH RESTAURANTS LIST
# =============================================================================

FRENCH_RESTAURANTS = [
    {'v3_id': 727, 'name': 'La Maison du Burger', 'v1_id': 965},
    {'v3_id': 1009, 'name': 'Econo Pizza', 'v1_id': 1095},
    {'v3_id': 1011, 'name': 'Mozza Pizza Gatineau', 'v1_id': 132},
    {'v3_id': 644, 'name': 'Mozza Pizza Hull', 'v1_id': 872},
    {'v3_id': 1012, 'name': 'Papa Pizza Des Flandres', 'v1_id': 231},
    {'v3_id': 1013, 'name': 'Papa Pizza Maloney', 'v1_id': 346},
    {'v3_id': 1014, 'name': 'Papa Pizza Val-Des-Monts', 'v1_id': 703},
    {'v3_id': 1015, 'name': 'Poutinerie Québecurds Gatineau', 'v1_id': 1046},
    {'v3_id': 1016, 'name': 'Roulas Grecque et Pizza', 'v1_id': 173},
    {'v3_id': 1017, 'name': 'Sushi Express Chambly', 'v1_id': 511},
]


# =============================================================================
# DATABASE FUNCTIONS
# =============================================================================

def get_french_restaurants(db: DatabaseConnection, logger) -> List[Dict]:
    """Get all French restaurants with V1 IDs and their dish counts."""
    # Get V3 IDs from the FRENCH_RESTAURANTS list
    french_v3_ids = [r['v3_id'] for r in FRENCH_RESTAURANTS]
    placeholders = ','.join(['%s'] * len(french_v3_ids))
    
    query = f"""
        SELECT r.id as v3_id, r.name, r.legacy_v1_id as v1_id,
               COUNT(d.id) as dish_count
        FROM menuca_v3.restaurants r
        JOIN menuca_v3.dishes d ON r.id = d.restaurant_id
        WHERE r.legacy_v1_id IS NOT NULL
          AND d.source_id IS NOT NULL
          AND d.is_combo = false
          AND r.id IN ({placeholders})
        GROUP BY r.id, r.name, r.legacy_v1_id
        ORDER BY r.name
    """
    results = db.execute_with_retry(query, tuple(french_v3_ids), fetch=True)
    restaurants = []
    for row in results:
        restaurants.append({
            'v3_id': row[0],
            'name': row[1],
            'v1_id': row[2],
            'dish_count': row[3]
        })
    logger.info(f"Found {len(restaurants)} French restaurants with {sum(r['dish_count'] for r in restaurants)} dishes")
    return restaurants


def get_dishes_for_restaurant(db: DatabaseConnection, restaurant_v3_id: int, logger) -> List[Dict]:
    """Get all non-combo dishes with source_id for a restaurant."""
    query = """
        SELECT d.id as v3_id, d.name, d.source_id
        FROM menuca_v3.dishes d
        WHERE d.restaurant_id = %s
          AND d.source_id IS NOT NULL
          AND d.is_combo = false
        ORDER BY d.name
    """
    results = db.execute_with_retry(query, (restaurant_v3_id,), fetch=True)
    dishes = []
    for row in results:
        dishes.append({
            'v3_id': row[0],
            'name': row[1],
            'source_id': row[2]
        })
    return dishes


def get_modifier_group_by_source_id(db: DatabaseConnection, restaurant_v3_id: int, 
                                     source_id: str, logger) -> Optional[Dict]:
    """Find a modifier group by its V1 source_id for a restaurant."""
    query = """
        SELECT id, name, category
        FROM menuca_v3.modifier_groups
        WHERE restaurant_id = %s AND source_system = %s
    """
    results = db.execute_with_retry(query, (restaurant_v3_id, source_id), fetch=True)
    if results:
        return {
            'v3_id': results[0][0],
            'name': results[0][1],
            'category': results[0][2]
        }
    return None


def get_processed_dishes(db: DatabaseConnection, logger) -> set:
    """Get set of dish IDs that already have modifier group links."""
    query = """
        SELECT DISTINCT dish_id FROM menuca_v3.dish_modifier_groups
    """
    results = db.execute_with_retry(query, fetch=True)
    processed = set()
    if results:
        for row in results:
            processed.add(row[0])
    logger.info(f"Found {len(processed)} dishes already processed")
    return processed


def insert_dish_modifier_group(db: DatabaseConnection, dish_id: int, 
                                modifier_group_id: int, logger) -> Optional[int]:
    """Insert a dish-modifier group link and return its ID."""
    try:
        query = """
            INSERT INTO menuca_v3.dish_modifier_groups (dish_id, modifier_group_id, created_at, updated_at)
            VALUES (%s, %s, NOW(), NOW())
            ON CONFLICT (dish_id, modifier_group_id) DO UPDATE SET updated_at = NOW()
            RETURNING id
        """
        result = db.execute_with_retry(query, (dish_id, modifier_group_id), fetch=True)
        if result:
            return result[0][0]
        return None
    except Exception as e:
        logger.error(f"Error inserting dish_modifier_group: {e}")
        return None


def insert_modifier_group_details(db: DatabaseConnection, dish_id: int, name: str,
                                   min_selections: int, max_selections: int,
                                   free_items: int, display_order: int,
                                   dish_modifier_group_id: int, logger) -> Optional[int]:
    """Insert modifier group details for a dish and return its ID."""
    try:
        query = """
            INSERT INTO menuca_v3.modifier_group_details 
            (dish_id, name, min_selections, max_selections, free_items, 
             display_order, dish_modifier_group_id, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
            ON CONFLICT (dish_modifier_group_id) DO UPDATE SET
                name = EXCLUDED.name,
                min_selections = EXCLUDED.min_selections,
                max_selections = EXCLUDED.max_selections,
                free_items = EXCLUDED.free_items,
                display_order = EXCLUDED.display_order,
                updated_at = NOW()
            RETURNING id
        """
        result = db.execute_with_retry(
            query, 
            (dish_id, name, min_selections, max_selections, free_items, 
             display_order, dish_modifier_group_id),
            fetch=True
        )
        if result:
            return result[0][0]
        return None
    except Exception as e:
        logger.error(f"Error inserting modifier_group_details: {e}")
        return None


# =============================================================================
# SCRAPING FUNCTIONS
# =============================================================================

async def get_input_value(page: Page, selector: str, default: str = "0") -> str:
    """Get the value of an input element, returning default if not found."""
    try:
        element = await page.query_selector(selector)
        if element:
            value = await element.get_attribute('value')
            return value if value else default
        return default
    except:
        return default


async def extract_active_modifier_groups(page: Page, logger) -> List[Dict]:
    """
    Extract all active modifier groups from a dish page.
    
    Active modifier groups are identified by:
    - Radio button with checked="" attribute within each category's div
    
    Returns list of dicts with:
    - v1_id: The V1 modifier group ID
    - name: The modifier group name
    - category: The category code (ci, sa, sd, d, e, br, dr, cm)
    """
    active_groups = []
    
    # Check all categories
    for category_code, details in CATEGORY_DETAILS_MAP.items():
        div_id = f"{category_code}_id"
        
        # Find all checked radio buttons in this category
        selector = f"#{div_id} input[type='radio'][checked]"
        checked_radios = await page.query_selector_all(selector)
        
        for radio in checked_radios:
            try:
                v1_id = await radio.get_attribute('value')
                # Get the label text (modifier group name)
                radio_id = await radio.get_attribute('id')
                if radio_id:
                    label = await page.query_selector(f"label[for='{radio_id}']")
                    name = await label.inner_text() if label else f"Unknown_{v1_id}"
                else:
                    name = f"Unknown_{v1_id}"
                
                active_groups.append({
                    'v1_id': v1_id,
                    'name': name.strip(),
                    'category': category_code
                })
                logger.debug(f"  Found active group: {name} (V1 ID: {v1_id}, Category: {category_code})")
            except Exception as e:
                logger.warning(f"  Error extracting checked radio: {e}")
    
    return active_groups


async def extract_category_details(page: Page, category_code: str, logger) -> Dict:
    """
    Extract the modifier group details for a category.
    
    Returns dict with:
    - header_name: The display name/title
    - min_selections: Minimum selections required
    - max_selections: Maximum selections allowed
    - free_items: Number of free items
    - display_order: Display order position
    """
    details_config = CATEGORY_DETAILS_MAP.get(category_code, {})
    
    # Get header/title
    header_id = details_config.get('header_id')
    header_name = await get_input_value(page, f"#{header_id}") if header_id else ""
    
    # Get min selections
    min_id = details_config.get('min_id')
    min_selections = int(await get_input_value(page, f"#{min_id}")) if min_id else 0
    
    # Get max selections
    max_id = details_config.get('max_id')
    max_selections = int(await get_input_value(page, f"#{max_id}")) if max_id else 0
    
    # Get free items
    free_id = details_config.get('free_id')
    free_items = int(await get_input_value(page, f"#{free_id}")) if free_id else 0
    
    # Get display order
    order_id = details_config.get('order_id')
    display_order = int(await get_input_value(page, f"#{order_id}", "0")) if order_id else 0
    
    return {
        'header_name': header_name,
        'min_selections': min_selections,
        'max_selections': max_selections,
        'free_items': free_items,
        'display_order': display_order
    }


async def scrape_dish_modifier_groups(page: Page, db: DatabaseConnection,
                                       restaurant: Dict, dish: Dict, logger,
                                       max_retries: int = 10, retry_delay: int = 5) -> Tuple[int, int]:
    """
    Scrape modifier groups for a single dish.
    
    Returns (links_created, details_created)
    
    Includes retry logic for network errors (ERR_NAME_NOT_RESOLVED, ERR_CONNECTION_TIMED_OUT, etc.)
    """
    links_created = 0
    details_created = 0
    
    # Navigate to dish edit page - USE showLang=fr for French
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={restaurant['v1_id']}&load=editDish&showLang=fr&menuEntry={dish['source_id']}"
    
    # Retry logic for network errors
    import asyncio
    for attempt in range(1, max_retries + 1):
        try:
            await page.goto(url, wait_until='networkidle', timeout=30000)
            await page.wait_for_timeout(1000)  # Wait for JS to fully execute
            break  # Success - exit retry loop
        except Exception as e:
            error_str = str(e)
            # Check if it's a network error that should be retried
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
                logger.warning(f"  Failed to load dish page after {attempt} attempts: {e}")
                return 0, 0
    
    # Check if dish has any active modifier groups
    groups_div = await page.query_selector('#groups')
    if not groups_div:
        logger.debug(f"  No #groups div found for dish {dish['name']}")
        return 0, 0
    
    # Extract active modifier groups
    active_groups = await extract_active_modifier_groups(page, logger)
    
    if not active_groups:
        logger.debug(f"  No active modifier groups for dish {dish['name']}")
        return 0, 0
    
    logger.info(f"  {dish['name']}: {len(active_groups)} active modifier groups")
    
    # Process each active group
    categories_processed = set()
    
    for group in active_groups:
        # Find the V3 modifier group
        v3_group = get_modifier_group_by_source_id(
            db, restaurant['v3_id'], group['v1_id'], logger
        )
        
        if not v3_group:
            logger.warning(f"    Modifier group not found in V3: {group['name']} (V1 ID: {group['v1_id']})")
            continue
        
        # Insert dish_modifier_group link
        dmg_id = insert_dish_modifier_group(db, dish['v3_id'], v3_group['v3_id'], logger)
        if dmg_id:
            links_created += 1
            logger.debug(f"    Linked: {dish['name']} -> {v3_group['name']}")
        
        # Extract and insert category details (once per category per dish)
        if group['category'] not in categories_processed:
            categories_processed.add(group['category'])
            
            details = await extract_category_details(page, group['category'], logger)
            
            # Use header name if available, otherwise use group name
            detail_name = details['header_name'] if details['header_name'] else group['name']
            
            detail_id = insert_modifier_group_details(
                db=db,
                dish_id=dish['v3_id'],
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


async def scrape_restaurant(page: Page, db: DatabaseConnection, 
                            restaurant: Dict, processed_dishes: set, logger) -> Tuple[int, int, int, int]:
    """
    Scrape all dishes for a restaurant.
    
    Returns (dishes_processed, dishes_skipped, links_created, details_created)
    """
    dishes = get_dishes_for_restaurant(db, restaurant['v3_id'], logger)
    
    dishes_processed = 0
    dishes_skipped = 0
    total_links = 0
    total_details = 0
    
    for i, dish in enumerate(dishes):
        # Skip already processed dishes
        if dish['v3_id'] in processed_dishes:
            dishes_skipped += 1
            continue
        
        # Log progress every 10 dishes
        if (i + 1) % 10 == 0:
            logger.info(f"  Progress: {i + 1}/{len(dishes)} dishes")
        
        logger.info(f"  [{i + 1}/{len(dishes)}] {dish['name']} (V3: {dish['v3_id']}, source_id: {dish['source_id']})")
        
        links, details = await scrape_dish_modifier_groups(page, db, restaurant, dish, logger)
        
        total_links += links
        total_details += details
        dishes_processed += 1
        
        logger.info(f"    -> {links} links, {details} details")
    
    return dishes_processed, dishes_skipped, total_links, total_details


async def run_french_dish_linker():
    """Main entry point for French dish-modifier-group linker scraper."""
    logger = setup_logging("french_dish_modifier_group_scraper")
    
    logger.info("=" * 60)
    logger.info("FRENCH DISH-MODIFIER GROUP LINKER SCRAPER")
    logger.info("=" * 60)
    
    # Initialize database
    db = DatabaseConnection(logger=logger)
    db.connect()
    
    # Get processed dishes for auto-resume
    processed_dishes = get_processed_dishes(db, logger)
    
    # Get French restaurants
    restaurants = get_french_restaurants(db, logger)
    
    total_stats = {
        'restaurants': 0,
        'dishes_processed': 0,
        'dishes_skipped': 0,
        'links_created': 0,
        'details_created': 0
    }
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        # Login to CRM
        if not await login_to_crm(page, logger):
            logger.error("Failed to login to CRM")
            return
        
        for i, restaurant in enumerate(restaurants):
            logger.info("-" * 40)
            logger.info(f"[{i + 1}/{len(restaurants)}] Restaurant: {restaurant['name']} (V3: {restaurant['v3_id']}, V1: {restaurant['v1_id']})")
            logger.info(f"  Dishes to process: {restaurant['dish_count']}")
            
            dishes_processed, dishes_skipped, links, details = await scrape_restaurant(
                page, db, restaurant, processed_dishes, logger
            )
            
            total_stats['restaurants'] += 1
            total_stats['dishes_processed'] += dishes_processed
            total_stats['dishes_skipped'] += dishes_skipped
            total_stats['links_created'] += links
            total_stats['details_created'] += details
            
            logger.info(f"  Restaurant complete: {dishes_processed} processed, {dishes_skipped} skipped, {links} links, {details} details")
        
        await browser.close()
    
    logger.info("=" * 60)
    logger.info("SCRAPER COMPLETE")
    logger.info("=" * 60)
    logger.info(f"Restaurants processed: {total_stats['restaurants']}")
    logger.info(f"Dishes processed: {total_stats['dishes_processed']}")
    logger.info(f"Dishes skipped: {total_stats['dishes_skipped']}")
    logger.info(f"Links created: {total_stats['links_created']}")
    logger.info(f"Details created: {total_stats['details_created']}")


if __name__ == "__main__":
    asyncio.run(run_french_dish_linker())

