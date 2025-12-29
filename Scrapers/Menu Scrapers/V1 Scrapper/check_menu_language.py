"""
V1 CRM Menu Language Checker

This script checks each restaurant in the V1 CRM to determine if it has:
- English menu (has actual dish names in the menu)
- French menu (empty menu or "No Course" with empty dish names)

Results are logged to: Scrapers/Menu Scrapers/V1 Scrapper/logs/menu_language_check.log
"""

import asyncio
import logging
import os
import re
from datetime import datetime
from pathlib import Path
from playwright.async_api import async_playwright

# Configuration
CRM_BASE_URL = "https://menuadmin.menu.ca"
CRM_USERNAME = "santiago@worklocal.ca"
CRM_PASSWORD = "542sfgsgeerg4%$"

# Restaurants to check (V3_ID, Name, Legacy_V1_ID)
RESTAURANTS = [
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
    (1009, "Econo Pizza", 1095),
    (511, "Egg Roll Factory", 716),
    (211, "Erman Pizza", 350),
    (730, "Friendly Restaurant and Pizzeria", 968),
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
    (727, "La Maison du Burger", 965),
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
    (91, "Milano", 207),
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
    (1011, "Mozza Pizza Gatineau", 132),
    (644, "Mozza Pizza Hull", 872),
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
    (1012, "Papa Pizza Des Flandres", 231),
    (1013, "Papa Pizza Maloney", 346),
    (1014, "Papa Pizza Val-Des-Monts", 703),
    (712, "Patate Lou Lou", 948),
    (199, "Pho Bo Ga King - Somerset", 337),
    (139, "Pizza Bravo", 264),
    (562, "Pizza des Hautes Plaines", 782),
    (726, "Pizza Joanna", 964),
    (507, "Pizza Lovers Hunt Club", 712),
    (696, "Pizza Maisonneuve", 930),
    (829, "Pizzalicious", 1074),
    (716, "PizzaRama", 953),
    (1015, "Poutinerie Québecurds Gatineau", 1046),
    (789, "Poutinerie Québecurds Hull", 1032),
    (824, "Prima Pizza", 1069),
    (497, "Rangoli", 701),
    (109, "Restaurant Chez Gerry", 228),
    (106, "Restaurant Le Choix", 225),
    (1016, "Roulas Grecque et Pizza", 173),
    (745, "Sala Thai", 983),
    (83, "Season's Pizza", 199),
    (836, "Souvlaki Souvlaki", 1083),
    (595, "Supreme Pizzeria", 817),
    (711, "Supreme Pizzeria", 947),
    (1017, "Sushi Express Chambly", 511),
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

# Setup logging
script_dir = Path(__file__).parent
log_dir = script_dir / "logs"
log_dir.mkdir(exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"menu_language_check_{timestamp}.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


async def check_menu_language(page, v3_id: int, name: str, v1_id: int) -> str:
    """
    Check if a restaurant has an English or French menu.
    
    Returns: 'ENGLISH', 'FRENCH', or 'ERROR'
    """
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=menu&showLang=en"
    
    try:
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)  # Small delay for content to load
        
        # Get the menu div content
        menu_div = await page.query_selector('div[style*="width:500px"][style*="float: left"]')
        
        if not menu_div:
            logger.warning(f"[{v3_id}] {name} (V1:{v1_id}) - No menu div found")
            return 'ERROR'
        
        # Get the inner HTML
        inner_html = await menu_div.inner_html()
        
        # Check for indicators of a valid English menu:
        # 1. Has actual course names (h3 tags with text)
        # 2. Has dish names in links (not empty <a></a>)
        
        # Check if it's empty
        if inner_html.strip() == '':
            logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (empty menu div)")
            return 'FRENCH'
        
        # Check for "No Course" indicator (French menu indicator)
        if 'No Course' in inner_html:
            # Further check if dish names are empty
            # Pattern: <a href="..."></a> - (empty link text)
            empty_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*></a>', inner_html)
            total_dish_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*>[^<]*</a>', inner_html)
            
            # If most links are empty, it's a French menu
            if len(empty_links) > len(total_dish_links) / 2:
                logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (No Course with empty dishes)")
                return 'FRENCH'
        
        # Check for actual course names (not "No Course")
        course_names = re.findall(r'<h3>([^<]+)</h3>', inner_html)
        valid_courses = [c for c in course_names if c != 'No Course' and c.strip()]
        
        if valid_courses:
            # Check if there are actual dish names
            dish_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*>([^<]+)</a>', inner_html)
            actual_dishes = [d for d in dish_links if d.strip()]
            
            if actual_dishes:
                logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - ENGLISH ({len(valid_courses)} courses, {len(actual_dishes)} dishes)")
                return 'ENGLISH'
        
        # Default to French if we can't determine
        logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (no valid courses/dishes found)")
        return 'FRENCH'
        
    except Exception as e:
        logger.error(f"[{v3_id}] {name} (V1:{v1_id}) - ERROR: {str(e)}")
        return 'ERROR'


async def main():
    """Main function to check all restaurants."""
    logger.info("=" * 80)
    logger.info("V1 CRM Menu Language Checker")
    logger.info(f"Checking {len(RESTAURANTS)} restaurants")
    logger.info("=" * 80)
    
    english_restaurants = []
    french_restaurants = []
    error_restaurants = []
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        # Login
        logger.info("Logging into V1 CRM...")
        await page.goto(f"{CRM_BASE_URL}/?p=restaurants")
        await page.fill('#username', CRM_USERNAME)
        await page.fill('#password', CRM_PASSWORD)
        await page.click('input[type="submit"]')
        await page.wait_for_load_state('networkidle')
        logger.info("Login successful!")
        
        # Check each restaurant
        for i, (v3_id, name, v1_id) in enumerate(RESTAURANTS, 1):
            logger.info(f"[{i}/{len(RESTAURANTS)}] Checking {name} (V3:{v3_id}, V1:{v1_id})...")
            
            result = await check_menu_language(page, v3_id, name, v1_id)
            
            if result == 'ENGLISH':
                english_restaurants.append((v3_id, name, v1_id))
            elif result == 'FRENCH':
                french_restaurants.append((v3_id, name, v1_id))
            else:
                error_restaurants.append((v3_id, name, v1_id))
            
            # Small delay between requests
            await page.wait_for_timeout(500)
        
        await browser.close()
    
    # Summary
    logger.info("")
    logger.info("=" * 80)
    logger.info("SUMMARY")
    logger.info("=" * 80)
    logger.info(f"Total restaurants: {len(RESTAURANTS)}")
    logger.info(f"English menus: {len(english_restaurants)}")
    logger.info(f"French menus: {len(french_restaurants)}")
    logger.info(f"Errors: {len(error_restaurants)}")
    
    # Log English restaurants
    logger.info("")
    logger.info("=" * 80)
    logger.info("ENGLISH MENU RESTAURANTS")
    logger.info("=" * 80)
    for v3_id, name, v1_id in english_restaurants:
        logger.info(f"| {v3_id} | {name} | {v1_id} |")
    
    # Log French restaurants
    logger.info("")
    logger.info("=" * 80)
    logger.info("FRENCH MENU RESTAURANTS")
    logger.info("=" * 80)
    for v3_id, name, v1_id in french_restaurants:
        logger.info(f"| {v3_id} | {name} | {v1_id} |")
    
    # Log errors
    if error_restaurants:
        logger.info("")
        logger.info("=" * 80)
        logger.info("ERROR RESTAURANTS")
        logger.info("=" * 80)
        for v3_id, name, v1_id in error_restaurants:
            logger.info(f"| {v3_id} | {name} | {v1_id} |")
    
    logger.info("")
    logger.info(f"Log saved to: {log_file}")


if __name__ == "__main__":
    asyncio.run(main())

