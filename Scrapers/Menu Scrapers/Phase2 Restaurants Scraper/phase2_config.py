

import os
import sys

# Add parent directory to path to import shared config - MUST be before config import
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config import (  # pylint: disable=import-error,wrong-import-position
    CRM_BASE_URL, CRM_USERNAME, CRM_PASSWORD,
    DB_CONNECTION_STRING, SCHEMA, SCRAPE_DELAY, MAX_RETRIES
)

# Now we can import from the parent directory
"""Configuration for Phase 2 Restaurants Scraper."""

# Re-export for convenience
__all__ = [
    'CRM_BASE_URL', 'CRM_USERNAME', 'CRM_PASSWORD',
    'DB_CONNECTION_STRING', 'SCHEMA', 'SCRAPE_DELAY', 'MAX_RETRIES',
    'RESTAURANTS', 'CRM_LOGIN_URL', 'MENU_URL_PATTERN', 'COMBO_GROUPS_URL_PATTERN',
    'DISH_URL_PATTERN', 'COMBO_DISH_URL_PATTERN',
    'SECTION_TYPE_MAPPING', 'SECTION_CHECKBOX_MAPPING', 'SIZE_VARIANTS',
    'DAY_OF_WEEK_MAPPING', 'TIMEOUT', 'NAVIGATION_TIMEOUT'
]

# Target restaurants for Phase 2 scraping
# Order: Test restaurant first, then remaining 5
RESTAURANTS = [
    {'v3_id': 636, 'v1_id': 863, 'name': 'Joes Family Pizzeria'},      # TEST FIRST
    {'v3_id': 265, 'v1_id': 411, 'name': 'Milano - 2 Pembroke'},
    {'v3_id': 607, 'v1_id': 830, 'name': 'Aroy Thai'},
    {'v3_id': 924, 'v1_id': 1013, 'name': 'All Out Burger Bank St.'},
    {'v3_id': 948, 'v1_id': 1038, 'name': 'All Out Burger Gladstone'},
    {'v3_id': 949, 'v1_id': 1071, 'name': 'All Out Burger Montreal Rd'},
]

# URL Patterns
CRM_LOGIN_URL = "https://menuadmin.menu.ca/"

MENU_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=menu&showLang=en"
)

COMBO_GROUPS_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=comboGroups&showLang=en"
)

DISH_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=editDish&showLang=en&menuEntry={menu_entry_id}"
)

COMBO_DISH_URL_PATTERN = (
    "https://menuadmin.menu.ca/?p=restaurants"
    "&display=editRestaurant&restaurant={v1_id}"
    "&load=editCombo&showLang=en&combo={combo_id}"
)

# Section Type Mapping (V1 HTML ID → section_type)
SECTION_TYPE_MAPPING = {
    'br_id': 'bread',
    'ci_id': 'custom_ingredients',
    'dr_id': 'dressing',
    'sa_id': 'sauces',
    'sd_id': 'side_dishes',
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
        'section_type': 'sauces',
        'div_id': 'sa_id',
        'ul_id': 'ulsa',
        'header_input': 'sauceHeader',
        'display_order_input': 'displayOrderSauce',
        'min_input': 'minSauce',
        'max_input': 'maxSauce',
        'free_input': 'freeSauce'
    },
    'hasSideDish': {
        'section_type': 'side_dishes',
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

# Modifier type mapping for dish modifiers
MODIFIER_TYPE_MAPPING = {
    'ci': 'custom_ingredients',
    'br': 'bread',
    'dr': 'dressing',
    'sa': 'sauces',
    'sd': 'side_dishes',
    'e': 'extras',
    'cm': 'cooking_method',
    'd': 'drinks'
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
# When a price has multiple comma-separated values, map to these sizes in order
SIZE_VARIANTS = ['Small', 'Medium', 'Large', 'X-Large']

# Single price size label
DEFAULT_SIZE = 'Standard'

# Timeouts (milliseconds)
TIMEOUT = 30000
NAVIGATION_TIMEOUT = 60000

# CSS Selectors
SELECTORS = {
    # Login page
    'username_input': 'input[name="user"]',
    'password_input': 'input[name="password"]',
    'login_button': 'input[type="submit"]',

    # Menu page - courses and dishes
    'course_list': 'ul[id^="course_"]',
    'course_header': 'li h3',
    'dish_link': 'li a[href*="editDish"], li a[href*="editCombo"]',

    # Combo groups page
    'combo_group_link': 'p[style*="background-color: #ccc"] a[onclick*="editGroupJS"]',
    'combo_group_form': '#editGroupForm',
    'combo_group_name': 'input#name',
    'combo_group_item_count': 'input#itemcount',
    'combo_group_display_header': 'input#displayHeader',

    # Section checkboxes
    'section_checkbox': 'input[type="checkbox"][id^="has"]',

    # Combo dish page
    'combo_group_checkbox': 'input[type="checkbox"][name="group[]"]',
    'hide_on_checkbox': 'input[type="checkbox"][name="hideOnDays[]"]',
    'price_input': 'input#price',
    'drinks_section': 'p:has-text("Drinks")',

    # Normal dish page
    'dish_price_inputs': 'input[name^="price"]',
    'modifier_groups_div': '#groups',
}
