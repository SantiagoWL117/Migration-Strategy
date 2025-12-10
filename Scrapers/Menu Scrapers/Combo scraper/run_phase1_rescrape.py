#!/usr/bin/env python3
"""
Phase 1 Re-Scrape: Process 124 restaurants that had 0 combo groups in Phase 1

These restaurants returned 0 combo groups in the original Phase 1 run and need re-scraping.
The script will filter against the database to only process restaurants that exist in V3.

Usage:
    python run_phase1_rescrape.py
    python run_phase1_rescrape.py --no-headless  # For debugging
"""

import argparse
import logging
import sys
import os
import csv
from datetime import datetime
from typing import List, Dict, Any

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from combo_scraper import ComboScraper
from combo_database import ComboDatabase

# The 124 restaurants with 0 combo groups from original Phase 1 log
# (Excludes 7 already successfully re-scraped: 89, 91, 93, 95, 131, 515, 819)
# Format: (V3 ID, V1 ID, Restaurant Name)
AFFECTED_RESTAURANTS = [
    (8, 90, "Lucky Star Chinese Food"),
    (15, 101, "New Mee Fung Restaurant"),
    (70, 184, "Papa Pizza - Hull"),
    (72, 187, "Cathay Restaurants"),
    (87, 203, "Champa Thai Cuisine"),
    (97, 213, "Milano"),
    (105, 224, "Ginkgo Garden"),
    (106, 225, "Restaurant Le Choix"),
    (109, 228, "Restaurant Chez Gerry"),
    (118, 238, "Mano City Pizza"),
    (119, 239, "Hung Mein"),
    (123, 245, "Milano"),
    (124, 246, "Carlo's Pizza"),
    (126, 248, "Milano"),
    (139, 264, "Pizza Bravo"),
    (143, 275, "Tony's Pizza"),
    (160, 294, "Hong Kong Chinese Food Takeout"),
    (174, 312, "Lucky King Take Out"),
    (180, 318, "Indian Punjabi Clay Oven"),
    (190, 328, "Milano"),
    (196, 334, "Colonnade Pizza"),
    (199, 337, "Pho Bo Ga King - Somerset"),
    (205, 344, "Mont Liban Bakery & Shawarma"),
    (211, 350, "Erman Pizza"),
    (234, 374, "New Mukut Restaurant Indian Cuisine"),
    (241, 383, "Beneci Pizza"),
    (245, 387, "Orchid Sushi"),
    (265, 411, "Milano"),
    (267, 413, "Lucky Fortune"),
    (269, 415, "Shaan Tandoori"),
    (328, 489, "JN Pizza"),
    (349, 512, "Milano"),
    (350, 513, "Milano"),
    (367, 532, "Xtreme Pizza"),
    (376, 542, "Sachi Sushi"),
    (437, 612, "Papa Joe's Fried Chicken - Downtown"),
    (479, 669, "iCook Pho You"),
    (491, 695, "Light of India"),
    (497, 701, "Rangoli"),
    (502, 707, "New Hong Kong"),
    (507, 712, "Pizza Lovers Hunt Club"),
    (511, 716, "Egg Roll Factory"),
    (519, 727, "HaNoi Pho"),
    (521, 729, "Palermo Pizzeria"),
    (540, 758, "Papa Grecque des Flandres"),
    (561, 781, "Aahar The Taste of India"),
    (562, 782, "Pizza des Hautes Plaines"),
    (565, 785, "Milano"),
    (569, 789, "Milano"),
    (584, 805, "Crispy's"),
    (586, 807, "Milano"),
    (593, 815, "Milano"),
    (595, 817, "Supreme Pizzeria"),
    (596, 818, "Sushi Fleury"),
    (601, 824, "Milano"),
    (602, 825, "Papa Pizza Cantley"),
    (607, 830, "Aroy Thai"),
    (614, 838, "Marina Pizza des Flandres"),
    (616, 840, "Papa Grecque Maloney"),
    (624, 850, "Milano"),
    (630, 856, "Asia Garden Ottawa"),
    (638, 865, "Digby's Restaurant"),
    (641, 869, "China Moon"),
    (644, 872, "Mozza Pizza Hull"),
    (646, 874, "JC Royal Thai Cuisine"),
    (651, 879, "Milano"),
    (660, 889, "Milano"),
    (680, 913, "Milano"),
    (681, 914, "Oka's Hull"),
    (696, 930, "Pizza Maisonneuve"),
    (701, 937, "Milano"),
    (711, 947, "Supreme Pizzeria"),
    (712, 948, "Patate Lou Lou"),
    (714, 951, "Ogilvie Pizza"),
    (715, 952, "La Poutinerie Ogilvie"),
    (716, 953, "PizzaRama"),
    (721, 959, "La Maison Pho"),
    (726, 964, "Pizza Joanna"),
    (727, 965, "La Maison du Burger"),
    (730, 968, "Friendly Restaurant and Pizzeria"),
    (735, 973, "Amicci Pizza"),
    (736, 974, "Greber Pizza et Shawarma"),
    (745, 983, "Sala Thai"),
    (749, 987, "Milano"),
    (751, 989, "Milano"),
    (756, 998, "Little Gyros Greek Grill"),
    (783, 1025, "Colonnade Pizza"),
    (784, 1027, "Colonnade Pizza"),
    (785, 1028, "Colonnade Pizza"),
    (789, 1032, "Poutinerie Quebecurds Hull"),
    (790, 1033, "Nachos Loco Hull"),
    (792, 1035, "Dumpling Bowl"),
    (795, 1039, "Papa Pizza Chem. de Masson"),
    (797, 1041, "Papa Burger"),
    (798, 1042, "Kabylie Pizza"),
    (801, 1045, "Nachos Loco Gatineau"),
    (806, 1050, "Crispy's Bank Street"),
    (807, 1051, "Oh My Grill"),
    (810, 1054, "Papa Grecque Cantley"),
    (815, 1059, "Golden Center Pizza"),
    (816, 1060, "Depanneur Genereux"),
    (818, 1062, "Milano"),
    (820, 1064, "Vieux Hull Pizza"),
    (821, 1065, "Milano"),
    (822, 1066, "Papa Burger Maloney"),
    (824, 1069, "Prima Pizza"),
    (825, 1070, "La Nawab V2"),
    (833, 1080, "All Out Burger"),
    (835, 1082, "Milano"),
    (836, 1083, "Souvlaki Souvlaki"),
    (845, 1092, "Mykonos Greek Grill"),
    (846, 1093, "Mykonos Greek Grill"),
    (847, 1094, "Sushiyana"),
    (941, 694, "Ting's Kitchen"),
    (943, 323, "Charm Thai Cuisine"),
    (1009, 1095, "Econo Pizza"),
    (1010, 219, "Lemongrass Thai Cuisine"),
    (1011, 132, "Mozza Pizza Gatineau"),
    (1012, 231, "Papa Pizza Des Flandres"),
    (1013, 346, "Papa Pizza Maloney"),
    (1014, 703, "Papa Pizza Val-Des-Monts"),
    (1016, 173, "Roulas Grecque et Pizza"),
    (1017, 511, "Sushi Express Chambly"),
]


def setup_logging(log_dir: str = None, existing_log_file: str = None) -> str:
    """Setup logging to both console and file.
    
    Args:
        log_dir: Directory for logs (defaults to ../logs)
        existing_log_file: Path to existing log file to append to
    """
    if log_dir is None:
        log_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            'logs'
        )
    
    os.makedirs(log_dir, exist_ok=True)
    
    if existing_log_file:
        log_file = existing_log_file
        file_mode = 'a'  # Append to existing log
    else:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        log_file = os.path.join(log_dir, f'combo_phase1_rescrape_{timestamp}.log')
        file_mode = 'w'  # New file
    
    # Configure root logger
    logging.basicConfig(
        level=logging.INFO,
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8', mode=file_mode),
            logging.StreamHandler(sys.stdout)
        ]
    )
    
    # Reduce noise from other loggers
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('playwright').setLevel(logging.WARNING)
    
    return log_file


def write_summary_csv(results: List[Dict[str, Any]], log_dir: str):
    """Write a summary CSV file."""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    csv_file = os.path.join(log_dir, f'combo_phase1_rescrape_summary_{timestamp}.csv')
    
    fieldnames = [
        'restaurant_id', 'restaurant_name', 'v1_id',
        'combo_groups', 'sections', 'modifier_groups', 'modifiers', 'prices',
        'status', 'error'
    ]
    
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    
    logging.info(f"Summary CSV written to: {csv_file}")


def run_rescrape(headless: bool = True, start_from_index: int = 0, log_file_path: str = None):
    """Run Phase 1 re-scraping for affected restaurants.
    
    Args:
        headless: Run browser in headless mode
        start_from_index: 0-based index in the restaurant list to start from (for resuming)
        log_file_path: Path to existing log file to append to (for resuming)
    """
    logger = logging.getLogger(__name__)
    
    log_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'logs'
    )
    log_file = setup_logging(log_dir, existing_log_file=log_file_path)
    
    if start_from_index > 0:
        logger.info("")
        logger.info("=" * 70)
        logger.info(f"RESUMING PHASE 1 RE-SCRAPE from restaurant #{start_from_index + 1}")
        logger.info("=" * 70)
    else:
        logger.info("=" * 70)
        logger.info("PHASE 1 RE-SCRAPE: Processing restaurants with previously empty pages")
        logger.info("=" * 70)
    logger.info(f"Logging to: {log_file}")
    
    # Filter the hardcoded list against actual restaurants in the database
    db = ComboDatabase()
    db.connect()
    
    # Get restaurants that exist in V3 AND are in our affected list
    affected_v3_ids = [r[0] for r in AFFECTED_RESTAURANTS]
    query = f"""
        SELECT id, name, legacy_v1_id 
        FROM {db.schema}.restaurants 
        WHERE id = ANY(%s) AND legacy_v1_id IS NOT NULL
        ORDER BY id
    """
    db.cursor.execute(query, (affected_v3_ids,))
    valid_restaurants = db.cursor.fetchall()
    db.close()
    
    # Build filtered list - only include restaurants that exist in V3
    valid_v3_ids = {r['id'] for r in valid_restaurants}
    filtered_restaurants = [(r[0], r[1], r[2]) for r in AFFECTED_RESTAURANTS if r[0] in valid_v3_ids]
    skipped_restaurants = [(r[0], r[1], r[2]) for r in AFFECTED_RESTAURANTS if r[0] not in valid_v3_ids]
    
    if skipped_restaurants and start_from_index == 0:
        logger.warning(f"Skipping {len(skipped_restaurants)} restaurants NOT in menuca_v3.restaurants:")
        for v3_id, v1_id, name in skipped_restaurants:
            logger.warning(f"  - {name} (V3: {v3_id}, V1: {v1_id})")
    
    logger.info(f"Total in affected list: {len(AFFECTED_RESTAURANTS)}")
    logger.info(f"Valid restaurants in V3: {len(filtered_restaurants)}")
    
    if not filtered_restaurants:
        logger.error("No valid restaurants to process!")
        return
    
    # Apply start_from_index
    if start_from_index > 0:
        if start_from_index >= len(filtered_restaurants):
            logger.error(f"start_from_index ({start_from_index}) exceeds restaurant count ({len(filtered_restaurants)})")
            return
        logger.info(f"Skipping first {start_from_index} restaurants (already processed)")
        restaurants_to_process = filtered_restaurants[start_from_index:]
    else:
        restaurants_to_process = filtered_restaurants
    
    logger.info(f"Total restaurants to process: {len(restaurants_to_process)}")
    logger.info("")
    
    results = []
    
    # Start scraper
    with ComboScraper(headless=headless) as scraper:
        # Login once
        logger.info("Logging in to V1 CRM...")
        if not scraper.login():
            logger.error("Login failed. Aborting.")
            return
        logger.info("Login successful")
        logger.info("")
        
        # Process each restaurant (only those that exist in V3)
        total_original = len(filtered_restaurants)
        for i, (v3_id, v1_id, name) in enumerate(restaurants_to_process, 1):
            actual_index = start_from_index + i
            logger.info("=" * 60)
            logger.info(f"[{actual_index}/{total_original}] Processing: {name} (V3: {v3_id}, V1: {v1_id})")
            logger.info("=" * 60)
            
            try:
                stats = scraper.scrape_combo_groups(v3_id, v1_id)
                
                logger.info(f"Results for {name}:")
                logger.info(f"  - Combo Groups: {stats['combo_groups']}")
                logger.info(f"  - Sections: {stats['sections']}")
                logger.info(f"  - Modifier Groups: {stats['modifier_groups']}")
                logger.info(f"  - Modifiers: {stats['modifiers']}")
                logger.info(f"  - Prices: {stats['prices']}")
                
                results.append({
                    'restaurant_id': v3_id,
                    'restaurant_name': name,
                    'v1_id': v1_id,
                    'combo_groups': stats['combo_groups'],
                    'sections': stats['sections'],
                    'modifier_groups': stats['modifier_groups'],
                    'modifiers': stats['modifiers'],
                    'prices': stats['prices'],
                    'status': 'success' if stats['combo_groups'] > 0 else 'no_combos',
                    'error': ''
                })
                
            except Exception as e:
                logger.error(f"Error processing {name}: {e}", exc_info=True)
                results.append({
                    'restaurant_id': v3_id,
                    'restaurant_name': name,
                    'v1_id': v1_id,
                    'combo_groups': 0,
                    'sections': 0,
                    'modifier_groups': 0,
                    'modifiers': 0,
                    'prices': 0,
                    'status': 'error',
                    'error': str(e)
                })
    
    # Write summary
    write_summary_csv(results, log_dir)
    
    # Print final summary
    logger.info("")
    logger.info("=" * 70)
    logger.info("PHASE 1 RE-SCRAPE COMPLETE")
    logger.info("=" * 70)
    
    total_groups = sum(r['combo_groups'] for r in results)
    total_sections = sum(r['sections'] for r in results)
    total_mod_groups = sum(r['modifier_groups'] for r in results)
    total_modifiers = sum(r['modifiers'] for r in results)
    total_prices = sum(r['prices'] for r in results)
    
    success_count = len([r for r in results if r['status'] == 'success'])
    no_combos_count = len([r for r in results if r['status'] == 'no_combos'])
    error_count = len([r for r in results if r['status'] == 'error'])
    
    logger.info(f"Restaurants processed: {len(results)}")
    logger.info(f"  - With combo groups: {success_count}")
    logger.info(f"  - No combos (truly empty): {no_combos_count}")
    logger.info(f"  - Errors: {error_count}")
    logger.info("")
    logger.info(f"Total combo groups scraped: {total_groups}")
    logger.info(f"Total sections: {total_sections}")
    logger.info(f"Total modifier groups: {total_mod_groups}")
    logger.info(f"Total modifiers: {total_modifiers}")
    logger.info(f"Total prices: {total_prices}")
    logger.info("")
    logger.info(f"Log file: {log_file}")


def main():
    parser = argparse.ArgumentParser(
        description='Phase 1 Re-Scrape: Process restaurants that had empty pages',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
This script re-scrapes the 124 restaurants that showed 22192/22210 bytes
(empty pages) in the original Phase 1 run.

After fixing the wait logic to properly wait for combo group elements,
these restaurants should now return their actual combo groups.

Examples:
    python run_phase1_rescrape.py                # Run headless
    python run_phase1_rescrape.py --no-headless  # Debug with visible browser
    python run_phase1_rescrape.py --start-from 12 --log-file path/to/log.log  # Resume from #12
        """
    )
    
    parser.add_argument(
        '--no-headless',
        action='store_true',
        help='Run browser in visible mode (for debugging)'
    )
    
    parser.add_argument(
        '--start-from',
        type=int,
        default=0,
        help='1-based index to start from (for resuming). E.g., --start-from 12 starts from the 12th restaurant'
    )
    
    parser.add_argument(
        '--log-file',
        type=str,
        default=None,
        help='Path to existing log file to append to (for resuming)'
    )
    
    args = parser.parse_args()
    
    # Convert from 1-based to 0-based index
    start_index = max(0, args.start_from - 1) if args.start_from > 0 else 0
    
    run_rescrape(
        headless=not args.no_headless,
        start_from_index=start_index,
        log_file_path=args.log_file
    )


if __name__ == '__main__':
    main()

