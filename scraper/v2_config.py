#!/usr/bin/env python3
"""
V2 Admin System Configuration
Configuration for scraping aggregator-admin.menu.ca
"""
import os
from dotenv import load_dotenv

load_dotenv()

# V2 Admin System Configuration
V2_BASE_URL = 'https://aggregator-admin.menu.ca'
V2_USERNAME = os.getenv('V2_USERNAME', '')
V2_PASSWORD = os.getenv('V2_PASSWORD', '')

# V2 URL Patterns
V2_LOGIN_URL = f'{V2_BASE_URL}/index.php/auth/login'
V2_RESTAURANT_MENU_URL = f'{V2_BASE_URL}/index.php/restaurants/edit/{{restaurant_id}}/menu/restaurant'
V2_RESTAURANT_MENU_FRENCH_URL = f'{V2_BASE_URL}/index.php/restaurants/edit/{{restaurant_id}}/menu/2/restaurant'
V2_DISH_MODAL_ENDPOINT = f'{V2_BASE_URL}/index.php/ajax/restaurant_menu/get_dish'

# Scraping Configuration
SCRAPE_DELAY = 2  # seconds between requests
HEADLESS = True   # run browser in headless mode
TIMEOUT = 30000   # milliseconds (30 seconds)

# Output Configuration
OUTPUT_DIR = 'V2 Scrapper'
RESTAURANTS_FILE = f'{OUTPUT_DIR}/v2_restaurants.json'
PHASE1_OUTPUT_DIR = f'{OUTPUT_DIR}/phase1_output'
PHASE1_PROGRESS_FILE = f'{OUTPUT_DIR}/v2_phase1_progress.json'
PHASE2_OUTPUT_DIR = f'{OUTPUT_DIR}/phase2_output'
PHASE2_PROGRESS_FILE = f'{OUTPUT_DIR}/v2_phase2_progress.json'

# Create output directories
import os
os.makedirs(PHASE1_OUTPUT_DIR, exist_ok=True)
os.makedirs(PHASE2_OUTPUT_DIR, exist_ok=True)

