"""Configuration settings for the menu scraper."""
import os
from dotenv import load_dotenv

load_dotenv()

# CRM Configuration
CRM_BASE_URL = os.getenv('CRM_BASE_URL', 'https://menuadmin.menu.ca')
CRM_USERNAME = os.getenv('CRM_USERNAME')
CRM_PASSWORD = os.getenv('CRM_PASSWORD')

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
