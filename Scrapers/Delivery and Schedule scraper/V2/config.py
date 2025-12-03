"""Configuration settings for V2 Delivery/Schedule scraper."""
import os
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables from .env files/.env
env_path = Path(__file__).parent.parent.parent.parent / '.env files' / '.env'
load_dotenv(env_path)

# V2 CRM Configuration - LOADED FROM ENVIRONMENT VARIABLES
# V2 CRM URL: https://aggregator-admin.menu.ca/index.php/welcome/index
V2_BASE_URL = os.getenv('CRM_BASE_URL', 'https://aggregator-admin.menu.ca')
V2_USERNAME = os.getenv('CRM_USERNAME', 'santiago@worklocal.ca')
V2_PASSWORD = os.getenv('CRM_PASSWORD')

# Validate required credentials
if not V2_PASSWORD:
    raise ValueError(
        "CRM_PASSWORD environment variable not set. "
        f"Please verify .env file exists at: {env_path}"
    )

# URL Patterns
LOGIN_URL = f"{V2_BASE_URL}/index.php/welcome/index"
RESTAURANTS_LIST_URL = f"{V2_BASE_URL}/index.php/restaurants/show/active"
RESTAURANT_INFO_URL = f"{V2_BASE_URL}/index.php/restaurants/edit/{{v2_id}}/info"
RESTAURANT_SCHEDULE_URL = f"{V2_BASE_URL}/index.php/restaurants/edit/{{v2_id}}/schedule"

# Scraping Configuration
SCRAPE_DELAY = float(os.getenv('SCRAPE_DELAY', '1.5'))
HEADLESS = os.getenv('HEADLESS', 'True').lower() == 'true'
TIMEOUT = int(os.getenv('TIMEOUT', '30000'))  # milliseconds

# Day mapping for V2 CRM (data-day attribute -> day number 1-7)
# V2 uses 1=Monday through 7=Sunday
V2_DAY_MAP = {
    '1': 1,  # Monday
    '2': 2,  # Tuesday
    '3': 3,  # Wednesday
    '4': 4,  # Thursday
    '5': 5,  # Friday
    '6': 6,  # Saturday
    '7': 7   # Sunday
}

# Output paths
OUTPUT_DIR = Path(__file__).parent.parent / 'output'
LOG_DIR = Path(__file__).parent / 'logs'

# Ensure directories exist
OUTPUT_DIR.mkdir(exist_ok=True)
LOG_DIR.mkdir(exist_ok=True)

