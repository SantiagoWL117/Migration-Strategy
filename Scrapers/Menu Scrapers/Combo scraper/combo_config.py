"""Configuration settings for the Combo Modifiers Scraper."""
import os
import sys

# Add parent directory to path to import shared config
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# config.py now finds .env automatically by walking up directories
from config import (
    CRM_BASE_URL, CRM_USERNAME, CRM_PASSWORD,
    DB_CONNECTION_STRING, SCHEMA, SCRAPE_DELAY, MAX_RETRIES
)

# Re-export for convenience
__all__ = [
    'CRM_BASE_URL', 'CRM_USERNAME', 'CRM_PASSWORD',
    'DB_CONNECTION_STRING', 'SCHEMA', 'SCRAPE_DELAY', 'MAX_RETRIES',
    'CRM_LOGIN_URL', 'CRM_RESTAURANTS_URL', 'COMBO_GROUPS_URL_PATTERN',
    'MENU_URL_PATTERN', 'COMBO_DISH_URL_PATTERN',
    'SECTION_TYPE_MAPPING', 'DAY_OF_WEEK_MAPPING', 'SIZE_VARIANTS',
    'TIMEOUT', 'NAVIGATION_TIMEOUT'
]

# URL Patterns
CRM_LOGIN_URL = "https://menuadmin.menu.ca/"
CRM_RESTAURANTS_URL = "https://menuadmin.menu.ca/?p=restaurants"

COMBO_GROUPS_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=comboGroups&showLang=en"
)

MENU_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=menu&showLang=en"
)

COMBO_DISH_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=editCombo&showLang=en&combo={combo_id}"
)

# AJAX endpoint for fetching combo group details
COMBO_AJAX_URL = "https://menuadmin.menu.ca/ajax/comboGroups.php"

# Section Type Mapping (V1 HTML ID → section_type)
SECTION_TYPE_MAPPING = {
    'br_id': 'bread',
    'ci_id': 'custom_ingredients',
    'dr_id': 'dressing',
    'sa_id': 'sauce',
    'sd_id': 'side_dish',
    'e_id': 'extras',
    'cm_id': 'cooking_method'
}

# V1 Checkbox Names to Section Config
SECTION_CHECKBOX_MAPPING = {
    'hasBread': {
        'section_type': 'bread',
        'div_id': 'br_id',
        'ul_id': 'ulbr',
        'header_input': 'breadHeader',
        'display_order_input': 'displayOrderBread',
        'min_input': None,
        'max_input': None,
        'free_input': None
    },
    'hasCustomisation': {
        'section_type': 'custom_ingredients',
        'div_id': 'ci_id',
        'ul_id': 'ulci',
        'header_input': 'ciHeader',
        'display_order_input': 'displayOrderCI',
        'min_input': 'minci',
        'max_input': 'maxci',
        'free_input': 'freeCI'
    },
    'hasDressing': {
        'section_type': 'dressing',
        'div_id': 'dr_id',
        'ul_id': 'uldr',
        'header_input': 'dressingHeader',
        'display_order_input': 'displayOrderDressing',
        'min_input': 'minDressing',
        'max_input': 'maxDressing',
        'free_input': 'freeDressing'
    },
    'hasSauce': {
        'section_type': 'sauce',
        'div_id': 'sa_id',
        'ul_id': 'ulsa',
        'header_input': 'sauceHeader',
        'display_order_input': 'displayOrderSauce',
        'min_input': 'minSauce',
        'max_input': 'maxSauce',
        'free_input': 'freeSauce'
    },
    'hasSideDish': {
        'section_type': 'side_dish',
        'div_id': 'sd_id',
        'ul_id': 'ulsd',
        'header_input': 'sdHeader',
        'display_order_input': 'displayOrderSD',
        'min_input': 'minSD',
        'max_input': 'maxSD',
        'free_input': 'freeSD'
    },
    'hasExtras': {
        'section_type': 'extras',
        'div_id': 'e_id',
        'ul_id': 'ule',
        'header_input': 'extraHeader',
        'display_order_input': 'displayOrderExtras',
        'min_input': 'minExtra',
        'max_input': 'maxExtra',
        'free_input': 'freeExtra'
    },
    'hasCM': {
        'section_type': 'cooking_method',
        'div_id': 'cm_id',
        'ul_id': 'ulcm',
        'header_input': 'cmHeader',
        'display_order_input': 'displayOrderCm',
        'min_input': 'minCm',
        'max_input': 'maxCm',
        'free_input': 'freeCm'
    }
}

# Day of Week Mapping (V1 value → PostgreSQL day_of_week)
DAY_OF_WEEK_MAPPING = {
    'sun': 0,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6
}

# Size Variants for price parsing
SIZE_VARIANTS = ['Small', 'Medium', 'Large', 'X-Large']

# Timeouts (milliseconds)
TIMEOUT = 30000
NAVIGATION_TIMEOUT = 60000

# CSS Selectors
SELECTORS = {
    # Login page
    'username_input': 'input[name="user"]',
    'password_input': 'input[name="password"]',
    'login_button': 'input[type="submit"]',
    
    # Combo groups page
    'combo_group_link': 'p[style*="background-color: #ccc"] a[onclick*="editGroupJS"]',
    'combo_group_form': '#editGroupForm',
    'combo_group_name': 'input#name',
    'combo_group_item_count': 'input#itemcount',
    'combo_group_display_header': 'input#displayHeader',
    
    # Section checkboxes
    'section_checkbox': 'input[type="checkbox"][id^="has"]',
    
    # Modifier groups (radio buttons)
    'modifier_group_radio': 'input[type="radio"][class]',
    
    # Combo dish page
    'combo_group_checkbox': 'input[type="checkbox"][name="group[]"]',
    'hide_on_checkbox': 'input[type="checkbox"][name="hideOnDays[]"]',
    'drinks_section': 'p:contains("Drinks")'
}

