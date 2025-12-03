"""V2 CRM Scraper for Delivery and Schedule data."""
import logging
import time
from typing import Optional, Dict, List
from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from shared.models import RestaurantData, ScheduleEntry, parse_time_12h_to_24h
from V2.config import (
    V2_BASE_URL, V2_USERNAME, V2_PASSWORD,
    LOGIN_URL, RESTAURANTS_LIST_URL, RESTAURANT_INFO_URL, RESTAURANT_SCHEDULE_URL,
    V2_DAY_MAP, HEADLESS, TIMEOUT, SCRAPE_DELAY
)

logger = logging.getLogger(__name__)


class V2DeliveryScheduleScraper:
    """Scraper for V2 CRM (aggregator-admin.menu.ca) delivery and schedule data."""
    
    def __init__(self, headless: bool = HEADLESS):
        self.base_url = V2_BASE_URL
        self.username = V2_USERNAME
        self.password = V2_PASSWORD
        self.headless = headless
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.logged_in = False
    
    def start(self):
        """Initialize Playwright browser."""
        logger.info("Starting browser...")
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        logger.info("Browser started successfully")
    
    def stop(self):
        """Close browser and cleanup."""
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        logger.info("Browser stopped")
    
    def login(self) -> bool:
        """Login to V2 CRM system."""
        try:
            logger.info("Logging in to V2 CRM...")
            logger.info(f"  URL: {LOGIN_URL}")
            self.page.goto(LOGIN_URL, timeout=TIMEOUT)
            
            # Fill login form
            email_input = self.page.query_selector('input[name="email"]')
            password_input = self.page.query_selector('input[name="password"]')
            
            if email_input and password_input:
                email_input.fill(self.username)
                password_input.fill(self.password)
                
                # Click submit
                submit_btn = self.page.query_selector('button[type="submit"]')
                if submit_btn:
                    submit_btn.click()
                
                self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            
            # Check if login successful
            page_content = self.page.content().lower()
            current_url = self.page.url.lower()
            
            if 'restaurants' in current_url or 'dashboard' in current_url or 'logout' in page_content:
                self.logged_in = True
                logger.info("✓ Login successful")
                return True
            else:
                # Try navigating to restaurants list
                self.page.goto(RESTAURANTS_LIST_URL, timeout=TIMEOUT)
                if self.page.query_selector('table#restaurantList'):
                    self.logged_in = True
                    logger.info("✓ Login successful")
                    return True
                
                logger.error("✗ Login failed - check credentials")
                return False
                
        except Exception as e:
            logger.error(f"✗ Login error: {e}")
            return False
    
    def scrape_restaurant(self, v3_id: int, v2_id: int, name: str) -> RestaurantData:
        """
        Scrape delivery and schedule data for a single restaurant.
        
        Args:
            v3_id: menuca_v3 restaurant ID
            v2_id: V2 CRM restaurant ID (legacy_v2_id)
            name: Restaurant name for logging
        
        Returns:
            RestaurantData object with scraped data
        """
        result = RestaurantData(v3_id=v3_id, legacy_id=v2_id, name=name)
        
        if not self.logged_in:
            result.error_message = "Not logged in"
            return result
        
        try:
            logger.info(f"Scraping {name} (V2 ID: {v2_id})...")
            
            # Step 1: Scrape info page for times and service settings
            info_url = RESTAURANT_INFO_URL.format(v2_id=v2_id)
            self.page.goto(info_url, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            time.sleep(SCRAPE_DELAY)
            
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract delivery and takeout times
            result.delivery_time_minutes = self._extract_int_value(soup, '#delivery_time')
            result.takeout_time_minutes = self._extract_int_value(soup, '#takeout_time')
            
            # Extract delivery/pickup enabled status
            result.has_delivery_enabled = self._extract_radio_bool(soup, 'delivery')
            result.pickup_enabled = self._extract_radio_bool(soup, 'takeout')
            
            # V2 doesn't have warning before close
            result.closing_warning_minutes = None
            
            # Step 2: Scrape schedule page
            schedule_url = RESTAURANT_SCHEDULE_URL.format(v2_id=v2_id)
            self.page.goto(schedule_url, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            time.sleep(SCRAPE_DELAY)
            
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract schedules
            result.takeout_schedule = self._extract_schedule(soup, 'table_takeout', 't')
            result.delivery_schedule = self._extract_schedule(soup, 'table_delivery', 'd')
            
            result.scrape_success = True
            logger.info(f"  ✓ Scraped successfully: delivery={result.delivery_time_minutes}min, "
                       f"takeout={result.takeout_time_minutes}min, "
                       f"delivery_enabled={result.has_delivery_enabled}, "
                       f"pickup_enabled={result.pickup_enabled}")
            
        except PlaywrightTimeout as e:
            result.error_message = f"Timeout: {e}"
            logger.error(f"  ✗ Timeout scraping {name}: {e}")
        except Exception as e:
            result.error_message = str(e)
            logger.error(f"  ✗ Error scraping {name}: {e}")
        
        return result
    
    def _extract_int_value(self, soup: BeautifulSoup, selector: str) -> Optional[int]:
        """Extract integer value from an input field."""
        element = soup.select_one(selector)
        if element:
            value = element.get('value', '').strip()
            if value and value.isdigit():
                return int(value)
        return None
    
    def _extract_radio_bool(self, soup: BeautifulSoup, name: str) -> Optional[bool]:
        """Extract boolean value from radio button group (V2 uses y/n values)."""
        # Find checked radio button
        checked = soup.select_one(f'input[name="{name}"]:checked')
        if checked:
            value = checked.get('value', '').lower()
            return value == 'y' or value == 'yes' or value == '1'
        
        # Fallback: check for checked attribute
        yes_radio = soup.select_one(f'input[name="{name}"][value="y"]')
        if yes_radio and yes_radio.has_attr('checked'):
            return True
        
        no_radio = soup.select_one(f'input[name="{name}"][value="n"]')
        if no_radio and no_radio.has_attr('checked'):
            return False
        
        return None
    
    def _extract_schedule(self, soup: BeautifulSoup, table_id: str, 
                          data_type: str) -> List[ScheduleEntry]:
        """
        Extract schedule entries from a V2 schedule table.
        
        Args:
            soup: BeautifulSoup object
            table_id: ID of the schedule table (e.g., 'table_takeout', 'table_delivery')
            data_type: Type attribute value ('t' for takeout, 'd' for delivery)
        
        Returns:
            List of ScheduleEntry objects
        """
        entries = []
        
        # Find schedule table
        table = soup.select_one(f'table#{table_id}')
        if not table:
            logger.debug(f"Schedule table #{table_id} not found")
            return entries
        
        # Extract schedule for each day (1-7) and interval (1-3)
        for day_str, day_num in V2_DAY_MAP.items():
            for interval in [1, 2, 3]:
                # Find start input: data-day="1" data-start="true" data-interval="1" data-type="t"
                start_input = table.select_one(
                    f'input[data-day="{day_str}"][data-start="true"][data-interval="{interval}"][data-type="{data_type}"]'
                )
                # Find stop input
                stop_input = table.select_one(
                    f'input[data-day="{day_str}"][data-stop="true"][data-interval="{interval}"][data-type="{data_type}"]'
                )
                
                if start_input and stop_input:
                    start_value = start_input.get('value', '').strip()
                    stop_value = stop_input.get('value', '').strip()
                    
                    # Parse times (V2 uses 12-hour format like "11:30 AM")
                    time_start = parse_time_12h_to_24h(start_value)
                    time_stop = parse_time_12h_to_24h(stop_value)
                    
                    entry = ScheduleEntry(
                        day=day_num,
                        interval=interval,
                        time_start=time_start,
                        time_stop=time_stop
                    )
                    
                    if entry.is_valid():
                        entries.append(entry)
        
        return entries
    
    def __enter__(self):
        self.start()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

