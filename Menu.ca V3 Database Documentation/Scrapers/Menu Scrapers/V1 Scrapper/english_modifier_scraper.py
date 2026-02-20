"""
English Modifier Group Scraper

Scrapes modifier groups, modifiers, and prices from V1 CRM for English menu restaurants.
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

# English restaurants to scrape (V3_ID, Name, V1_ID)
ENGLISH_RESTAURANTS = [
    (561, "Aahar The Taste of India", 781),
    (833, "All Out Burger", 1080),
    (841, "All Out Burger", 1088),
    (735, "Amicci Pizza", 973),
    (630, "Asia Garden Ottawa", 856),
    (69, "Aylmer BBQ", 183),
    (241, "Beneci Pizza", 383),
    (45, "Bobbie's Pizza & Subs", 143),
    (124, "Carlo's Pizza", 246),
    (72, "Cathay Restaurants", 187),
    (131, "Centertown Donair & Pizza", 255),
    (943, "Charm Thai Cuisine", 323),
    (641, "China Moon", 869),
    (196, "Colonnade Pizza", 334),
    (783, "Colonnade Pizza", 1025),
    (784, "Colonnade Pizza", 1027),
    (785, "Colonnade Pizza", 1028),
    (584, "Crispy's", 805),
    (806, "Crispy's Bank Street", 1050),
    (638, "Digby's Restaurant", 865),
    (792, "Dumpling Bowl", 1035),
    (28, "Eastview Pizza", 124),
    (511, "Egg Roll Factory", 716),
    (211, "Erman Pizza", 350),
    (815, "Golden Center Pizza", 1059),
    (736, "Greber Pizza et Shawarma", 974),
    (519, "HaNoi Pho", 727),
    (22, "House of Lasagna", 117),
    (479, "iCook Pho You", 669),
    (7, "Imilio's Pizzeria", 89),
    (180, "Indian Punjabi Clay Oven", 318),
    (646, "JC Royal Thai Cuisine", 874),
    (328, "JN Pizza", 489),
    (636, "Joes Family Pizzeria", 863),
    (798, "Kabylie Pizza", 1042),
    (44, "Kiki Lebanese Pineview Pizza", 142),
    (984, "La Famiglia on the Danforth", 364),
    (721, "La Maison Pho", 959),
    (715, "La Poutinerie Ogilvie", 952),
    (1010, "Lemongrass Thai Cuisine", 219),
    (756, "Little Gyros Greek Grill", 998),
    (77, "Lorenzo's Pizzeria - Vanier", 192),
    (267, "Lucky Fortune", 413),
    (174, "Lucky King Take Out", 312),
    (12, "Mama Rosa", 94),
    (118, "Mano City Pizza", 238),
    (614, "Marina Pizza des Flandres", 838),
    (48, "Merivale Pizza & Wings", 146),
    (31, "Milano", 127),
    (55, "Milano", 161),
    (57, "Milano", 164),
    (59, "Milano", 172),
    (75, "Milano", 190),
    (88, "Milano", 204),
    (89, "Milano", 205),
    (90, "Milano", 206),
    (92, "Milano", 208),
    (93, "Milano", 209),
    (95, "Milano", 211),
    (97, "Milano", 213),
    (123, "Milano", 245),
    (126, "Milano", 248),
    (190, "Milano", 328),
    (265, "Milano", 411),
    (349, "Milano", 512),
    (350, "Milano", 513),
    (565, "Milano", 785),
    (569, "Milano", 789),
    (586, "Milano", 807),
    (593, "Milano", 815),
    (601, "Milano", 824),
    (624, "Milano", 850),
    (651, "Milano", 879),
    (660, "Milano", 889),
    (680, "Milano", 913),
    (701, "Milano", 937),
    (749, "Milano", 987),
    (751, "Milano", 989),
    (818, "Milano", 1062),
    (819, "Milano", 1063),
    (821, "Milano", 1065),
    (835, "Milano", 1082),
    (837, "Milano", 1084),
    (840, "Milano", 1087),
    (842, "Milano", 1089),
    (205, "Mont Liban Bakery & Shawarma", 344),
    (47, "Mr Mozzarella - Nepean", 145),
    (801, "Nachos Loco Gatineau", 1045),
    (790, "Nachos Loco Hull", 1033),
    (515, "Napolis", 721),
    (15, "New Mee Fung Restaurant", 101),
    (65, "Number One Chinese Take Out", 179),
    (714, "Ogilvie Pizza", 951),
    (807, "Oh My Grill", 1051),
    (681, "Oka's Hull", 914),
    (245, "Orchid Sushi", 387),
    (521, "Palermo Pizzeria", 729),
    (797, "Papa Burger", 1041),
    (822, "Papa Burger Maloney", 1066),
    (810, "Papa Grecque Cantley", 1054),
    (540, "Papa Grecque des Flandres", 758),
    (616, "Papa Grecque Maloney", 840),
    (437, "Papa Joe's Fried Chicken - Downtown", 612),
    (13, "Papa Joe's Pizza - Downtown", 95),
    (70, "Papa Pizza - Hull", 184),
    (602, "Papa Pizza Cantley", 825),
    (795, "Papa Pizza Chem. de Masson", 1039),
    (712, "Patate Lou Lou", 948),
    (199, "Pho Bo Ga King - Somerset", 337),
    (139, "Pizza Bravo", 264),
    (562, "Pizza des Hautes Plaines", 782),
    (726, "Pizza Joanna", 964),
    (507, "Pizza Lovers Hunt Club", 712),
    (696, "Pizza Maisonneuve", 930),
    (829, "Pizzalicious", 1074),
    (716, "PizzaRama", 953),
    (789, "Poutinerie Québecurds Hull", 1032),
    (824, "Prima Pizza", 1069),
    (497, "Rangoli", 701),
    (109, "Restaurant Chez Gerry", 228),
    (106, "Restaurant Le Choix", 225),
    (745, "Sala Thai", 983),
    (83, "Season's Pizza", 199),
    (836, "Souvlaki Souvlaki", 1083),
    (595, "Supreme Pizzeria", 817),
    (711, "Supreme Pizzeria", 947),
    (596, "Sushi Fleury", 818),
    (847, "Sushiyana", 1094),
    (84, "The Original Georgie's", 200),
    (941, "Ting's Kitchen", 694),
    (143, "Tony's Pizza", 275),
    (62, "Vanier Pizza & Subs", 175),
    (820, "Vieux Hull Pizza", 1064),
    (367, "Xtreme Pizza", 532),
    (985, "Yorgo's - Nepean", 547),
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


async def run_english_scraper(restaurants: List[tuple] = None, skip_processed: bool = True):
    """
    Run the English modifier group scraper.
    
    Args:
        restaurants: List of (v3_id, name, v1_id) tuples. Defaults to ENGLISH_RESTAURANTS.
        skip_processed: If True, skip restaurants that already have modifier data.
    """
    logger = setup_logging("english_modifier_scraper")
    logger.info("=" * 60)
    logger.info("ENGLISH MODIFIER GROUP SCRAPER")
    logger.info("=" * 60)
    logger.info(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    if restaurants is None:
        restaurants = ENGLISH_RESTAURANTS
    
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
                    
                    # Heartbeat every 10 restaurants
                    if idx % 10 == 0:
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
    asyncio.run(run_english_scraper())
