"""Run the Special Combo Scanner to identify restaurants with special combo sections.

Usage:
    python run_scanner.py                    # Scan all restaurants with V1 IDs
    python run_scanner.py --v1-id 973        # Scan single restaurant by V1 ID
    python run_scanner.py --visible          # Run with visible browser
"""
import argparse
import logging
import os
import sys
from datetime import datetime

# Add parent directories to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from special_combo_scanner import SpecialComboScanner

# Setup logging
def setup_logging():
    """Setup logging to both file and console."""
    logs_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
        'logs'
    )
    os.makedirs(logs_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(logs_dir, f'special_combo_scan_{timestamp}.log')
    
    # Configure root logger
    logging.basicConfig(
        level=logging.INFO,
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler(sys.stdout)
        ]
    )
    
    logger = logging.getLogger(__name__)
    logger.info(f"Logging to: {log_file}")
    return logger


# List of 123 restaurants from Phase 1 Combo scrape (Combo Phase 1 successful.log)
RESTAURANTS_TO_SCAN = [
    {'v3_id': 8, 'v1_id': 90, 'name': 'Lucky Star Chinese Food'},
    {'v3_id': 15, 'v1_id': 101, 'name': 'New Mee Fung Restaurant'},
    {'v3_id': 70, 'v1_id': 184, 'name': 'Papa Pizza - Hull'},
    {'v3_id': 72, 'v1_id': 187, 'name': 'Cathay Restaurants'},
    {'v3_id': 87, 'v1_id': 203, 'name': 'Champa Thai Cuisine'},
    {'v3_id': 97, 'v1_id': 213, 'name': 'Milano'},
    {'v3_id': 105, 'v1_id': 224, 'name': 'Ginkgo Garden'},
    {'v3_id': 106, 'v1_id': 225, 'name': 'Restaurant Le Choix'},
    {'v3_id': 109, 'v1_id': 228, 'name': 'Restaurant Chez Gerry'},
    {'v3_id': 118, 'v1_id': 238, 'name': 'Mano City Pizza'},
    {'v3_id': 119, 'v1_id': 239, 'name': 'Hung Mein'},
    {'v3_id': 123, 'v1_id': 245, 'name': 'Milano'},
    {'v3_id': 124, 'v1_id': 246, 'name': "Carlo's Pizza"},
    {'v3_id': 126, 'v1_id': 248, 'name': 'Milano'},
    {'v3_id': 139, 'v1_id': 264, 'name': 'Pizza Bravo'},
    {'v3_id': 143, 'v1_id': 275, 'name': "Tony's Pizza"},
    {'v3_id': 160, 'v1_id': 294, 'name': 'Hong Kong Chinese Food Takeout'},
    {'v3_id': 174, 'v1_id': 312, 'name': 'Lucky King Take Out'},
    {'v3_id': 180, 'v1_id': 318, 'name': 'Indian Punjabi Clay Oven'},
    {'v3_id': 190, 'v1_id': 328, 'name': 'Milano'},
    {'v3_id': 196, 'v1_id': 334, 'name': 'Colonnade Pizza'},
    {'v3_id': 199, 'v1_id': 337, 'name': 'Pho Bo Ga King - Somerset'},
    {'v3_id': 205, 'v1_id': 344, 'name': 'Mont Liban Bakery & Shawarma'},
    {'v3_id': 211, 'v1_id': 350, 'name': 'Erman Pizza'},
    {'v3_id': 234, 'v1_id': 374, 'name': 'New Mukut Restaurant Indian Cuisine'},
    {'v3_id': 241, 'v1_id': 383, 'name': 'Beneci Pizza'},
    {'v3_id': 245, 'v1_id': 387, 'name': 'Orchid Sushi'},
    {'v3_id': 265, 'v1_id': 411, 'name': 'Milano'},
    {'v3_id': 267, 'v1_id': 413, 'name': 'Lucky Fortune'},
    {'v3_id': 269, 'v1_id': 415, 'name': 'Shaan Tandoori'},
    {'v3_id': 328, 'v1_id': 489, 'name': 'JN Pizza'},
    {'v3_id': 349, 'v1_id': 512, 'name': 'Milano'},
    {'v3_id': 350, 'v1_id': 513, 'name': 'Milano'},
    {'v3_id': 367, 'v1_id': 532, 'name': 'Xtreme Pizza'},
    {'v3_id': 376, 'v1_id': 542, 'name': 'Sachi Sushi'},
    {'v3_id': 437, 'v1_id': 612, 'name': "Papa Joe's Fried Chicken - Downtown"},
    {'v3_id': 479, 'v1_id': 669, 'name': 'iCook Pho You'},
    {'v3_id': 491, 'v1_id': 695, 'name': 'Light of India'},
    {'v3_id': 497, 'v1_id': 701, 'name': 'Rangoli'},
    {'v3_id': 502, 'v1_id': 707, 'name': 'New Hong Kong'},
    {'v3_id': 507, 'v1_id': 712, 'name': 'Pizza Lovers Hunt Club'},
    {'v3_id': 511, 'v1_id': 716, 'name': 'Egg Roll Factory'},
    {'v3_id': 519, 'v1_id': 727, 'name': 'HaNoi Pho'},
    {'v3_id': 521, 'v1_id': 729, 'name': 'Palermo Pizzeria'},
    {'v3_id': 540, 'v1_id': 758, 'name': 'Papa Grecque des Flandres'},
    {'v3_id': 561, 'v1_id': 781, 'name': 'Aahar The Taste of India'},
    {'v3_id': 562, 'v1_id': 782, 'name': 'Pizza des Hautes Plaines'},
    {'v3_id': 565, 'v1_id': 785, 'name': 'Milano'},
    {'v3_id': 569, 'v1_id': 789, 'name': 'Milano'},
    {'v3_id': 584, 'v1_id': 805, 'name': "Crispy's"},
    {'v3_id': 586, 'v1_id': 807, 'name': 'Milano'},
    {'v3_id': 593, 'v1_id': 815, 'name': 'Milano'},
    {'v3_id': 595, 'v1_id': 817, 'name': 'Supreme Pizzeria'},
    {'v3_id': 596, 'v1_id': 818, 'name': 'Sushi Fleury'},
    {'v3_id': 601, 'v1_id': 824, 'name': 'Milano'},
    {'v3_id': 602, 'v1_id': 825, 'name': 'Papa Pizza Cantley'},
    {'v3_id': 607, 'v1_id': 830, 'name': 'Aroy Thai'},
    {'v3_id': 614, 'v1_id': 838, 'name': 'Marina Pizza des Flandres'},
    {'v3_id': 616, 'v1_id': 840, 'name': 'Papa Grecque Maloney'},
    {'v3_id': 624, 'v1_id': 850, 'name': 'Milano'},
    {'v3_id': 630, 'v1_id': 856, 'name': 'Asia Garden Ottawa'},
    {'v3_id': 638, 'v1_id': 865, 'name': "Digby's Restaurant"},
    {'v3_id': 641, 'v1_id': 869, 'name': 'China Moon'},
    {'v3_id': 644, 'v1_id': 872, 'name': 'Mozza Pizza Hull'},
    {'v3_id': 646, 'v1_id': 874, 'name': 'JC Royal Thai Cuisine'},
    {'v3_id': 651, 'v1_id': 879, 'name': 'Milano'},
    {'v3_id': 660, 'v1_id': 889, 'name': 'Milano'},
    {'v3_id': 680, 'v1_id': 913, 'name': 'Milano'},
    {'v3_id': 681, 'v1_id': 914, 'name': "Oka's Hull"},
    {'v3_id': 696, 'v1_id': 930, 'name': 'Pizza Maisonneuve'},
    {'v3_id': 701, 'v1_id': 937, 'name': 'Milano'},
    {'v3_id': 711, 'v1_id': 947, 'name': 'Supreme Pizzeria'},
    {'v3_id': 712, 'v1_id': 948, 'name': 'Patate Lou Lou'},
    {'v3_id': 714, 'v1_id': 951, 'name': 'Ogilvie Pizza'},
    {'v3_id': 715, 'v1_id': 952, 'name': 'La Poutinerie Ogilvie'},
    {'v3_id': 716, 'v1_id': 953, 'name': 'PizzaRama'},
    {'v3_id': 721, 'v1_id': 959, 'name': 'La Maison Pho'},
    {'v3_id': 726, 'v1_id': 964, 'name': 'Pizza Joanna'},
    {'v3_id': 727, 'v1_id': 965, 'name': 'La Maison du Burger'},
    {'v3_id': 730, 'v1_id': 968, 'name': 'Friendly Restaurant and Pizzeria'},
    {'v3_id': 735, 'v1_id': 973, 'name': 'Amicci Pizza'},
    {'v3_id': 736, 'v1_id': 974, 'name': 'Greber Pizza et Shawarma'},
    {'v3_id': 745, 'v1_id': 983, 'name': 'Sala Thai'},
    {'v3_id': 749, 'v1_id': 987, 'name': 'Milano'},
    {'v3_id': 751, 'v1_id': 989, 'name': 'Milano'},
    {'v3_id': 756, 'v1_id': 998, 'name': 'Little Gyros Greek Grill'},
    {'v3_id': 783, 'v1_id': 1025, 'name': 'Colonnade Pizza'},
    {'v3_id': 784, 'v1_id': 1027, 'name': 'Colonnade Pizza'},
    {'v3_id': 785, 'v1_id': 1028, 'name': 'Colonnade Pizza'},
    {'v3_id': 789, 'v1_id': 1032, 'name': 'Poutinerie Quebecurds Hull'},
    {'v3_id': 790, 'v1_id': 1033, 'name': 'Nachos Loco Hull'},
    {'v3_id': 792, 'v1_id': 1035, 'name': 'Dumpling Bowl'},
    {'v3_id': 795, 'v1_id': 1039, 'name': 'Papa Pizza Chem. de Masson'},
    {'v3_id': 797, 'v1_id': 1041, 'name': 'Papa Burger'},
    {'v3_id': 798, 'v1_id': 1042, 'name': 'Kabylie Pizza'},
    {'v3_id': 801, 'v1_id': 1045, 'name': 'Nachos Loco Gatineau'},
    {'v3_id': 806, 'v1_id': 1050, 'name': "Crispy's Bank Street"},
    {'v3_id': 807, 'v1_id': 1051, 'name': 'Oh My Grill'},
    {'v3_id': 810, 'v1_id': 1054, 'name': 'Papa Grecque Cantley'},
    {'v3_id': 815, 'v1_id': 1059, 'name': 'Golden Center Pizza'},
    {'v3_id': 816, 'v1_id': 1060, 'name': 'Depanneur Genereux'},
    {'v3_id': 818, 'v1_id': 1062, 'name': 'Milano'},
    {'v3_id': 820, 'v1_id': 1064, 'name': 'Vieux Hull Pizza'},
    {'v3_id': 821, 'v1_id': 1065, 'name': 'Milano'},
    {'v3_id': 822, 'v1_id': 1066, 'name': 'Papa Burger Maloney'},
    {'v3_id': 824, 'v1_id': 1069, 'name': 'Prima Pizza'},
    {'v3_id': 825, 'v1_id': 1070, 'name': 'La Nawab V2'},
    {'v3_id': 833, 'v1_id': 1080, 'name': 'All Out Burger'},
    {'v3_id': 835, 'v1_id': 1082, 'name': 'Milano'},
    {'v3_id': 836, 'v1_id': 1083, 'name': 'Souvlaki Souvlaki'},
    {'v3_id': 845, 'v1_id': 1092, 'name': 'Mykonos Greek Grill'},
    {'v3_id': 846, 'v1_id': 1093, 'name': 'Mykonos Greek Grill'},
    {'v3_id': 847, 'v1_id': 1094, 'name': 'Sushiyana'},
    {'v3_id': 941, 'v1_id': 694, 'name': "Ting's Kitchen"},
    {'v3_id': 943, 'v1_id': 323, 'name': 'Charm Thai Cuisine'},
    {'v3_id': 1009, 'v1_id': 1095, 'name': 'Econo Pizza'},
    {'v3_id': 1010, 'v1_id': 219, 'name': 'Lemongrass Thai Cuisine'},
    {'v3_id': 1011, 'v1_id': 132, 'name': 'Mozza Pizza Gatineau'},
    {'v3_id': 1012, 'v1_id': 231, 'name': 'Papa Pizza Des Flandres'},
    {'v3_id': 1013, 'v1_id': 346, 'name': 'Papa Pizza Maloney'},
    {'v3_id': 1014, 'v1_id': 703, 'name': 'Papa Pizza Val-Des-Monts'},
    {'v3_id': 1016, 'v1_id': 173, 'name': 'Roulas Grecque et Pizza'},
    {'v3_id': 1017, 'v1_id': 511, 'name': 'Sushi Express Chambly'},
]


def main():
    parser = argparse.ArgumentParser(
        description='Scan restaurants for special combo sections (combo groups with checked items)'
    )
    parser.add_argument('--v1-id', type=int, help='Scan single restaurant by V1 ID')
    parser.add_argument('--visible', action='store_true', help='Run with visible browser')
    args = parser.parse_args()

    logger = setup_logging()
    
    logger.info("=" * 70)
    logger.info("SPECIAL COMBO SECTION SCANNER")
    logger.info("Identifying combo groups with pre-selected dish items")
    logger.info("=" * 70)

    # Determine which restaurants to scan
    if args.v1_id:
        restaurants = [r for r in RESTAURANTS_TO_SCAN if r['v1_id'] == args.v1_id]
        if not restaurants:
            logger.error(f"No restaurant found with V1 ID {args.v1_id}")
            return
        logger.info(f"Scanning single restaurant: {restaurants[0]['name']} (V1: {args.v1_id})")
    else:
        restaurants = RESTAURANTS_TO_SCAN
        logger.info(f"Scanning {len(restaurants)} restaurants")

    # Run scanner
    headless = not args.visible
    
    with SpecialComboScanner(headless=headless) as scanner:
        # Login
        if not scanner.login():
            logger.error("Login failed. Aborting.")
            return

        # Scan restaurants
        results = scanner.scan_restaurants(restaurants)

        # Get summary
        summary = scanner.get_summary()

        # Print final summary
        logger.info("\n" + "=" * 70)
        logger.info("SCAN COMPLETE - SUMMARY")
        logger.info("=" * 70)
        logger.info(f"Total restaurants scanned: {len(results)}")
        logger.info(f"Restaurants with special combo sections: {summary['total_restaurants_with_specials']}")
        logger.info(f"Total special combo groups found: {summary['total_special_combo_groups']}")

        if summary['special_combo_groups']:
            logger.info("\n" + "-" * 70)
            logger.info("RESTAURANTS WITH SPECIAL COMBO SECTIONS:")
            logger.info("-" * 70)
            
            # Group by restaurant
            by_restaurant = {}
            for scg in summary['special_combo_groups']:
                rest_key = (scg['restaurant']['v3_id'], scg['restaurant']['name'])
                if rest_key not in by_restaurant:
                    by_restaurant[rest_key] = []
                by_restaurant[rest_key].append(scg)

            for (v3_id, name), groups in by_restaurant.items():
                logger.info(f"\n{name} (V3 ID: {v3_id}):")
                for g in groups:
                    logger.info(f"  - {g['combo_group']['name']} (source_id={g['combo_group']['source_id']})")
                    logger.info(f"    Checked items ({len(g['checked_items'])}):")
                    for item in g['checked_items'][:5]:  # Show first 5
                        logger.info(f"      * [{item['category']}] {item['name']} (value={item['value']})")
                    if len(g['checked_items']) > 5:
                        logger.info(f"      ... and {len(g['checked_items']) - 5} more")

        logger.info("\n" + "=" * 70)
        logger.info("SCAN FINISHED")
        logger.info("=" * 70)


if __name__ == '__main__':
    main()

