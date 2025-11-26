"""Configuration settings for V2 menu scraper."""
import os
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

# V2 Admin System Configuration
V2_BASE_URL = os.getenv('V2_BASE_URL', 'https://aggregator-admin.menu.ca')
V2_USERNAME = os.getenv('V2_USERNAME', '')
V2_PASSWORD = os.getenv('V2_PASSWORD', '')

# Scraping Configuration
SCRAPE_DELAY = float(os.getenv('SCRAPE_DELAY', '2.0'))
HEADLESS = os.getenv('HEADLESS', 'True').lower() == 'true'
TIMEOUT = int(os.getenv('TIMEOUT', '30000'))  # milliseconds

# Output Directory
OUTPUT_DIR = Path(__file__).parent / 'V2 Scrapper'

# Database Schema (reuse from main config)
SCHEMA = 'menuca_v3'








