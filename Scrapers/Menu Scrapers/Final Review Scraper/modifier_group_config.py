"""Configuration settings for the Modifier Group Details scraper."""
import os
from dotenv import load_dotenv

# Find .env file - check common locations
def find_and_load_env():
    """Find .env file by checking common locations."""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Try up to 5 levels up
    for _ in range(5):
        # Check for .env in current directory
        env_path = os.path.join(current_dir, '.env')
        if os.path.exists(env_path):
            load_dotenv(env_path)
            return True
        
        # Check for .env in ".env files" subdirectory
        env_folder_path = os.path.join(current_dir, '.env files', '.env')
        if os.path.exists(env_folder_path):
            load_dotenv(env_folder_path)
            return True
        
        current_dir = os.path.dirname(current_dir)
    
    # Fall back to default behavior
    load_dotenv()
    return False

find_and_load_env()

# =============================================================================
# CRM Configuration - V1 CRM (menuadmin.menu.ca)
# =============================================================================
CRM_BASE_URL = 'https://menuadmin.menu.ca'
CRM_LOGIN_URL = f"{CRM_BASE_URL}/"
CRM_RESTAURANTS_URL = f"{CRM_BASE_URL}/?p=restaurants"
CRM_USERNAME = os.getenv('CRM_V1_USERNAME', os.getenv('CRM_USERNAME'))
CRM_PASSWORD = os.getenv('CRM_V1_PASSWORD', os.getenv('CRM_PASSWORD'))

# URL Patterns (hardcoded to avoid double-formatting issues)
MENU_URL_PATTERN = "https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=menu&showLang=en"
DISH_DETAIL_URL_PATTERN = "https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=editDish&showLang=en&menuEntry={menu_entry_id}"

# =============================================================================
# Database Configuration
# =============================================================================
DB_CONNECTION_STRING = os.getenv('DB_CONNECTION_STRING')
SCHEMA = 'menuca_v3'

# =============================================================================
# Scraping Configuration
# =============================================================================
TIMEOUT = 30000  # 30 seconds
NAVIGATION_TIMEOUT = 60000  # 60 seconds
SCRAPE_DELAY = 0.5  # seconds between requests

# =============================================================================
# Section Configuration
# =============================================================================
# Maps V1 HTML section IDs to their configuration field names
# Each section has: type name, min/max/free input names, display_order input name
SECTION_CONFIG = {
    'br_id': {
        'type': 'bread',
        'checkbox_id': 'hasBread',
        'settings_div': 'breadNo',
        'header_name': 'breadHeader',
        'min_name': None,  # Bread has no min/max/free
        'max_name': None,
        'free_name': None,
        'order_name': 'displayOrderBread',
        'radio_name': 'br_radio',
    },
    'ci_id': {
        'type': 'custom_ingredients',
        'checkbox_id': 'hasCustomisation',
        'settings_div': 'ciNo',
        'header_name': 'ciHeader',
        'min_name': 'minci',
        'max_name': 'maxci',
        'free_name': 'freeci',
        'order_name': 'displayOrderCI',
        'radio_name': 'ci_radio',
    },
    'dr_id': {
        'type': 'dressing',
        'checkbox_id': 'hasDressing',
        'settings_div': 'dressingNo',
        'header_name': 'dressingHeader',
        'min_name': 'mindressing',
        'max_name': 'maxdressing',
        'free_name': 'freeDressing',
        'order_name': 'displayOrderDressing',
        'radio_name': 'dr_radio',
    },
    'sa_id': {
        'type': 'sauce',
        'checkbox_id': 'hasSauce',
        'settings_div': 'sauceNo',
        'header_name': 'sauceHeader',
        'min_name': 'minsauce',
        'max_name': 'maxsauce',
        'free_name': 'freeSauce',
        'order_name': 'displayOrderSauce',
        'radio_name': 'sa_radio',
    },
    'sd_id': {
        'type': 'side_dish',
        'checkbox_id': 'hasSideDish',
        'settings_div': 'sdNo',
        'header_name': 'sideDishHeader',
        'min_name': 'minsd',
        'max_name': 'maxsd',
        'free_name': 'freeSD',
        'order_name': 'displayOrderSD',
        'radio_name': 'sd_radio',
    },
    'd_id': {
        'type': 'drinks',
        'checkbox_id': 'hasDrinks',
        'settings_div': 'drinksNo',
        'header_name': 'drinksHeader',
        'min_name': 'mindrink',
        'max_name': 'maxdrink',
        'free_name': 'freeDrink',
        'order_name': 'displayOrderDrink',
        'radio_name': 'd_radio',
    },
    'e_id': {
        'type': 'extras',
        'checkbox_id': 'hasExtras',
        'settings_div': 'extraNo',
        'header_name': 'extraHeader',
        'min_name': 'minextras',
        'max_name': 'maxextras',
        'free_name': 'freeExtra',
        'order_name': 'displayOrderExtras',
        'radio_name': 'e_radio',
    },
    'cm_id': {
        'type': 'cooking_method',
        'checkbox_id': 'hasCookMethod',
        'settings_div': 'cmNo',
        'header_name': 'cmHeader',
        'min_name': None,  # Cooking method has no min/max/free
        'max_name': None,
        'free_name': None,
        'order_name': 'displayOrderCM',
        'radio_name': 'cm_radio',
    },
}

# =============================================================================
# Day of Week Mapping (V1 → V3)
# =============================================================================
# V1 uses string values, V3 uses integers (0=Sunday, 1=Monday, etc.)
DAY_MAPPING = {
    'sun': 0,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
}

# =============================================================================
# Restaurant List (168 restaurants from prompt)
# =============================================================================
RESTAURANTS = [
    {'v3_id': 7, 'v1_id': 89, 'name': "Imilio's Pizzeria"},  # TEST RESTAURANT
    {'v3_id': 8, 'v1_id': 90, 'name': 'Lucky Star Chinese Food'},
    {'v3_id': 12, 'v1_id': 94, 'name': 'Mama Rosa'},
    {'v3_id': 13, 'v1_id': 95, 'name': "Papa Joe's Pizza - Downtown"},
    {'v3_id': 15, 'v1_id': 101, 'name': 'New Mee Fung Restaurant'},
    {'v3_id': 22, 'v1_id': 117, 'name': 'House of Lasagna'},
    {'v3_id': 28, 'v1_id': 124, 'name': 'Eastview Pizza'},
    {'v3_id': 31, 'v1_id': 127, 'name': 'Milano'},
    {'v3_id': 44, 'v1_id': 142, 'name': 'Kiki Lebanese Pineview Pizza'},
    {'v3_id': 45, 'v1_id': 143, 'name': "Bobbie's Pizza & Subs"},
    {'v3_id': 47, 'v1_id': 145, 'name': 'Mr Mozzarella - Nepean'},
    {'v3_id': 48, 'v1_id': 146, 'name': 'Merivale Pizza & Wings'},
    {'v3_id': 55, 'v1_id': 161, 'name': 'Milano'},
    {'v3_id': 57, 'v1_id': 164, 'name': 'Milano'},
    {'v3_id': 59, 'v1_id': 172, 'name': 'Milano'},
    {'v3_id': 62, 'v1_id': 175, 'name': 'Vanier Pizza & Subs'},
    {'v3_id': 65, 'v1_id': 179, 'name': 'Number One Chinese Take Out'},
    {'v3_id': 69, 'v1_id': 183, 'name': 'Aylmer BBQ'},
    {'v3_id': 70, 'v1_id': 184, 'name': 'Papa Pizza - Hull'},
    {'v3_id': 72, 'v1_id': 187, 'name': 'Cathay Restaurants'},
    {'v3_id': 75, 'v1_id': 190, 'name': 'Milano'},
    {'v3_id': 77, 'v1_id': 192, 'name': "Lorenzo's Pizzeria - Vanier"},
    {'v3_id': 83, 'v1_id': 199, 'name': "Season's Pizza"},
    {'v3_id': 84, 'v1_id': 200, 'name': "The Original Georgie's"},
    {'v3_id': 87, 'v1_id': 203, 'name': 'Champa Thai Cuisine'},
    {'v3_id': 88, 'v1_id': 204, 'name': 'Milano'},
    {'v3_id': 89, 'v1_id': 205, 'name': 'Milano'},
    {'v3_id': 90, 'v1_id': 206, 'name': 'Milano'},
    {'v3_id': 91, 'v1_id': 207, 'name': 'Milano'},
    {'v3_id': 92, 'v1_id': 208, 'name': 'Milano'},
    {'v3_id': 93, 'v1_id': 209, 'name': 'Milano'},
    {'v3_id': 95, 'v1_id': 211, 'name': 'Milano'},
    {'v3_id': 97, 'v1_id': 213, 'name': 'Milano'},
    {'v3_id': 105, 'v1_id': 224, 'name': 'Ginkgo Garden'},
    {'v3_id': 106, 'v1_id': 225, 'name': 'Restaurant Le Choix'},
    {'v3_id': 109, 'v1_id': 228, 'name': 'Restaurant Chez Gerry'},
    {'v3_id': 118, 'v1_id': 238, 'name': 'Mano City Pizza'},
    {'v3_id': 119, 'v1_id': 239, 'name': 'Hung Mein'},
    {'v3_id': 123, 'v1_id': 245, 'name': 'Milano'},
    {'v3_id': 124, 'v1_id': 246, 'name': "Carlo's Pizza"},
    {'v3_id': 126, 'v1_id': 248, 'name': 'Milano'},
    {'v3_id': 131, 'v1_id': 255, 'name': 'Centertown Donair & Pizza'},
    {'v3_id': 133, 'v1_id': 257, 'name': 'Riverside Pizzeria'},
    {'v3_id': 139, 'v1_id': 264, 'name': 'Pizza Bravo'},
    {'v3_id': 143, 'v1_id': 275, 'name': "Tony's Pizza"},
    {'v3_id': 147, 'v1_id': 280, 'name': 'Pho Dau Bo Restaurant - Kitchener'},
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
    {'v3_id': 515, 'v1_id': 721, 'name': 'Napolis'},
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
    {'v3_id': 789, 'v1_id': 1032, 'name': 'Poutinerie Québecurds Hull'},
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
    {'v3_id': 816, 'v1_id': 1060, 'name': 'Dépanneur Généreux'},
    {'v3_id': 818, 'v1_id': 1062, 'name': 'Milano'},
    {'v3_id': 819, 'v1_id': 1063, 'name': 'Milano'},
    {'v3_id': 820, 'v1_id': 1064, 'name': 'Vieux Hull Pizza'},
    {'v3_id': 821, 'v1_id': 1065, 'name': 'Milano'},
    {'v3_id': 822, 'v1_id': 1066, 'name': 'Papa Burger Maloney'},
    {'v3_id': 824, 'v1_id': 1069, 'name': 'Prima Pizza'},
    {'v3_id': 825, 'v1_id': 1070, 'name': 'La Nawab V2'},
    {'v3_id': 829, 'v1_id': 1074, 'name': 'Pizzalicious'},
    {'v3_id': 833, 'v1_id': 1080, 'name': 'All Out Burger'},
    {'v3_id': 835, 'v1_id': 1082, 'name': 'Milano'},
    {'v3_id': 836, 'v1_id': 1083, 'name': 'Souvlaki Souvlaki'},
    {'v3_id': 837, 'v1_id': 1084, 'name': 'Milano'},
    {'v3_id': 840, 'v1_id': 1087, 'name': 'Milano'},
    {'v3_id': 841, 'v1_id': 1088, 'name': 'All Out Burger'},
    {'v3_id': 842, 'v1_id': 1089, 'name': 'Milano'},
    {'v3_id': 845, 'v1_id': 1092, 'name': 'Mykonos Greek Grill'},
    {'v3_id': 846, 'v1_id': 1093, 'name': 'Mykonos Greek Grill'},
    {'v3_id': 847, 'v1_id': 1094, 'name': 'Sushiyana'},
    {'v3_id': 941, 'v1_id': 694, 'name': "Ting's Kitchen"},
    {'v3_id': 943, 'v1_id': 323, 'name': 'Charm Thai Cuisine'},
    {'v3_id': 954, 'v1_id': 686, 'name': 'Wandee Thai'},
    {'v3_id': 971, 'v1_id': 998, 'name': 'Little Gyros Greek Grill'},
    {'v3_id': 984, 'v1_id': 364, 'name': 'La Famiglia on the Danforth'},
    {'v3_id': 985, 'v1_id': 547, 'name': "Yorgo's - Nepean"},
    {'v3_id': 1009, 'v1_id': 1095, 'name': 'Econo Pizza'},
    {'v3_id': 1010, 'v1_id': 219, 'name': 'Lemongrass Thai Cuisine'},
    {'v3_id': 1011, 'v1_id': 132, 'name': 'Mozza Pizza Gatineau'},
    {'v3_id': 1012, 'v1_id': 231, 'name': 'Papa Pizza Des Flandres'},
    {'v3_id': 1013, 'v1_id': 346, 'name': 'Papa Pizza Maloney'},
    {'v3_id': 1014, 'v1_id': 703, 'name': 'Papa Pizza Val-Des-Monts'},
    {'v3_id': 1015, 'v1_id': 1046, 'name': 'Poutinerie Québecurds Gatineau'},
    {'v3_id': 1016, 'v1_id': 173, 'name': 'Roulas Grecque et Pizza'},
    {'v3_id': 1017, 'v1_id': 511, 'name': 'Sushi Express Chambly'},
]

# Test restaurant
TEST_RESTAURANT = {'v3_id': 7, 'v1_id': 89, 'name': "Imilio's Pizzeria"}

