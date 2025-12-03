"""V1 CRM Scraper for Delivery and Schedule data."""
import logging
import time
import re
from typing import Optional, Dict, List
from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from shared.models import RestaurantData, ScheduleEntry, parse_time_v1
from V1.config import (
    V1_BASE_URL, V1_USERNAME, V1_PASSWORD,
    RESTAURANTS_LIST_URL, RESTAURANT_EDIT_URL,
    V1_DAY_MAP, HEADLESS, TIMEOUT, SCRAPE_DELAY
)

logger = logging.getLogger(__name__)


class V1DeliveryScheduleScraper:
    """Scraper for V1 CRM (menuadmin.menu.ca) delivery and schedule data."""
    
    def __init__(self, headless: bool = HEADLESS):
        self.base_url = V1_BASE_URL
        self.username = V1_USERNAME
        self.password = V1_PASSWORD
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
        """Login to V1 CRM system."""
        try:
            logger.info("Logging in to V1 CRM...")
            logger.info(f"  URL: {RESTAURANTS_LIST_URL}")
            self.page.goto(RESTAURANTS_LIST_URL, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            
            # Check if already logged in (restaurants list visible)
            if self.page.query_selector('ul#active'):
                self.logged_in = True
                logger.info("✓ Already logged in (session active)")
                return True
            
            # V1 CRM uses textbox inputs for Username and Password
            # The form has: textbox "Username" and textbox "Password"
            username_input = self.page.query_selector('input[type="text"]')
            password_input = self.page.query_selector('input[type="password"]')
            
            if not username_input or not password_input:
                # Try alternative selectors
                username_input = self.page.get_by_label("Username")
                password_input = self.page.get_by_label("Password")
            
            if username_input and password_input:
                logger.info(f"  Filling credentials for user: {self.username}")
                username_input.fill(self.username)
                password_input.fill(self.password)
                
                # Find and click Login button
                login_btn = self.page.query_selector('button:has-text("Login")')
                if not login_btn:
                    login_btn = self.page.query_selector('input[type="submit"]')
                if not login_btn:
                    login_btn = self.page.get_by_role("button", name="Login")
                
                if login_btn:
                    login_btn.click()
                else:
                    # Try pressing Enter
                    password_input.press('Enter')
                
                self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
                time.sleep(2)  # Extra wait for redirect
            
            # Verify login success - check for restaurants list
            if self.page.query_selector('ul#active'):
                self.logged_in = True
                logger.info("✓ Login successful")
                return True
            
            # Try navigating to restaurants page again
            self.page.goto(RESTAURANTS_LIST_URL, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            
            if self.page.query_selector('ul#active'):
                self.logged_in = True
                logger.info("✓ Login successful")
                return True
            else:
                logger.error("✗ Login failed - restaurants list not found")
                logger.error(f"  Current URL: {self.page.url}")
                return False
                
        except Exception as e:
            logger.error(f"✗ Login error: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return False
    
    def scrape_restaurant(self, v3_id: int, v1_id: int, name: str) -> RestaurantData:
        """
        Scrape delivery and schedule data for a single restaurant.
        
        Args:
            v3_id: menuca_v3 restaurant ID
            v1_id: V1 CRM restaurant ID (legacy_v1_id)
            name: Restaurant name for logging
        
        Returns:
            RestaurantData object with scraped data
        """
        result = RestaurantData(v3_id=v3_id, legacy_id=v1_id, name=name)
        
        if not self.logged_in:
            result.error_message = "Not logged in"
            return result
        
        try:
            # Navigate to restaurant edit page
            url = RESTAURANT_EDIT_URL.format(v1_id=v1_id)
            logger.info(f"Scraping {name} (V1 ID: {v1_id})...")
            
            self.page.goto(url, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            time.sleep(SCRAPE_DELAY)
            
            # Get page HTML
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract delivery and takeout times
            result.delivery_time_minutes = self._extract_int_value(soup, '#delivery_time')
            result.takeout_time_minutes = self._extract_int_value(soup, '#takeout_time')
            
            # Extract delivery/pickup enabled status
            result.has_delivery_enabled = self._extract_radio_bool(soup, 'delivery')
            result.pickup_enabled = self._extract_radio_bool(soup, 'pickup')
            
            # Extract warning before close
            result.closing_warning_minutes = self._extract_int_value(soup, '#warnBeforeClose')
            
            # Extract schedules
            result.delivery_schedule = self._extract_schedule(soup, 'delivery_schedule', 'ds')
            result.takeout_schedule = self._extract_schedule(soup, 'restaurant_schedule', 'rs')
            
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
        """Extract boolean value from radio button group."""
        # Find checked radio button
        checked = soup.select_one(f'input[name="{name}"]:checked')
        if checked:
            value = checked.get('value', '')
            return value == '1' or value.lower() == 'y' or value.lower() == 'yes'
        
        # Fallback: check if "yes" radio is checked via attribute
        yes_radio = soup.select_one(f'input[name="{name}"][value="1"]')
        if yes_radio and yes_radio.has_attr('checked'):
            return True
        
        no_radio = soup.select_one(f'input[name="{name}"][value="0"]')
        if no_radio and no_radio.has_attr('checked'):
            return False
        
        return None
    
    def _extract_schedule(self, soup: BeautifulSoup, schedule_name: str, 
                          table_id: str) -> List[ScheduleEntry]:
        """
        Extract schedule entries from a schedule table.
        
        Args:
            soup: BeautifulSoup object
            schedule_name: Name prefix in input names (e.g., 'delivery_schedule', 'restaurant_schedule')
            table_id: ID of the schedule table (e.g., 'ds', 'rs')
        
        Returns:
            List of ScheduleEntry objects
        """
        entries = []
        
        # Find schedule table
        table = soup.select_one(f'table#{table_id}')
        if not table:
            logger.debug(f"Schedule table #{table_id} not found")
            return entries
        
        # Extract schedule for each day and interval
        for day_abbrev, day_num in V1_DAY_MAP.items():
            for interval in [1, 2, 3]:
                interval_suffix = f'i{interval}'
                
                # Find start and stop inputs
                # Pattern: name="delivery_schedule[start][mon][i1]"
                start_input = table.select_one(
                    f'input[name="{schedule_name}[start][{day_abbrev}][{interval_suffix}]"]'
                )
                stop_input = table.select_one(
                    f'input[name="{schedule_name}[stop][{day_abbrev}][{interval_suffix}]"]'
                )
                
                if start_input and stop_input:
                    start_value = start_input.get('value', '').strip()
                    stop_value = stop_input.get('value', '').strip()
                    
                    # Parse times
                    time_start = parse_time_v1(start_value)
                    time_stop = parse_time_v1(stop_value)
                    
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

