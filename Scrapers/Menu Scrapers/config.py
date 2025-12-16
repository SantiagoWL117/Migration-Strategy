"""Configuration settings for the menu scraper."""
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

# CRM Configuration - V1 CRM (menuadmin.menu.ca)
# Try V1-specific variables first, fall back to generic
CRM_BASE_URL = os.getenv('CRM_V1_BASE_URL', os.getenv('CRM_BASE_URL', 'https://menuadmin.menu.ca'))
CRM_USERNAME = os.getenv('CRM_V1_USERNAME', os.getenv('CRM_USERNAME'))
CRM_PASSWORD = os.getenv('CRM_V1_PASSWORD', os.getenv('CRM_PASSWORD'))

# Supabase Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')
DB_CONNECTION_STRING = os.getenv('DB_CONNECTION_STRING')

# Scraping Configuration
SCRAPE_DELAY = float(os.getenv('SCRAPE_DELAY', '0.5'))
MAX_RETRIES = int(os.getenv('MAX_RETRIES', '3'))
BATCH_SIZE = int(os.getenv('BATCH_SIZE', '10'))

# Menu URL Pattern
MENU_URL_PATTERN = "{base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=menu&showLang=en"
DISH_DETAIL_URL_PATTERN = "{base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=editDish&showLang=en&menuEntry={menu_entry_id}"

# Database Schema
SCHEMA = 'menuca_v3'
