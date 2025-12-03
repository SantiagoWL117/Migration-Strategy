"""Configuration settings for V1 Delivery/Schedule scraper."""
import os
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables from .env files/.env
env_path = Path(__file__).parent.parent.parent.parent / '.env files' / '.env'
load_dotenv(env_path)

# V1 CRM Configuration - LOADED FROM ENVIRONMENT VARIABLES
# V1 CRM URL: https://menuadmin.menu.ca/?p=restaurants
V1_BASE_URL = os.getenv('CRM_BASE_URL', 'https://menuadmin.menu.ca')
V1_USERNAME = os.getenv('CRM_USERNAME', 'santiago@worklocal.ca')
V1_PASSWORD = os.getenv('CRM_PASSWORD')

# Validate required credentials
if not V1_PASSWORD:
    raise ValueError(
        "CRM_PASSWORD environment variable not set. "
        f"Please verify .env file exists at: {env_path}"
    )

# URL Patterns
RESTAURANTS_LIST_URL = f"{V1_BASE_URL}/?p=restaurants"
RESTAURANT_EDIT_URL = f"{V1_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={{v1_id}}"

# Scraping Configuration
SCRAPE_DELAY = float(os.getenv('SCRAPE_DELAY', '1.0'))
HEADLESS = os.getenv('HEADLESS', 'True').lower() == 'true'
TIMEOUT = int(os.getenv('TIMEOUT', '30000'))  # milliseconds

# Day mapping for V1 CRM (day abbreviation -> day number 1-7)
V1_DAY_MAP = {
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
    'sun': 7
}

# Output paths
OUTPUT_DIR = Path(__file__).parent.parent / 'output'
LOG_DIR = Path(__file__).parent / 'logs'

# Ensure directories exist
OUTPUT_DIR.mkdir(exist_ok=True)
LOG_DIR.mkdir(exist_ok=True)

