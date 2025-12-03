"""V1 CRM Scraper for Distance-Based Delivery Fees."""
import logging
import time
from typing import Optional, List
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup

from models import DistanceBasedFeeData, FeeTier, parse_float
from config import (
    V1_BASE_URL, V1_USERNAME, V1_PASSWORD,
    RESTAURANTS_LIST_URL, RESTAURANT_DELIVERY_URL,
    DISTANCE_TIERS, HEADLESS, TIMEOUT, SCRAPE_DELAY
)

logger = logging.getLogger(__name__)


class DistanceBasedFeesScraper:
    """Scraper for V1 CRM distance-based delivery fees."""
    
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
            username_input = self.page.query_selector('input[type="text"]')
            password_input = self.page.query_selector('input[type="password"]')
            
            if not username_input or not password_input:
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
                    password_input.press('Enter')
                
                self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
                time.sleep(2)
            
            # Verify login success
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
                return False
                
        except Exception as e:
            logger.error(f"✗ Login error: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return False
    
    def scrape_restaurant(self, v3_id: int, v1_id: int, name: str) -> DistanceBasedFeeData:
        """
        Scrape distance-based delivery fee data for a single restaurant.
        
        Args:
            v3_id: menuca_v3 restaurant ID
            v1_id: V1 CRM restaurant ID (legacy_v1_id)
            name: Restaurant name for logging
        
        Returns:
            DistanceBasedFeeData object with scraped data
        """
        result = DistanceBasedFeeData(v3_id=v3_id, legacy_v1_id=v1_id, name=name)
        
        if not self.logged_in:
            result.error_message = "Not logged in"
            return result
        
        try:
            # Navigate to restaurant delivery page
            url = RESTAURANT_DELIVERY_URL.format(v1_id=v1_id)
            logger.info(f"Scraping {name} (V1 ID: {v1_id})...")
            
            self.page.goto(url, timeout=TIMEOUT)
            self.page.wait_for_load_state('networkidle', timeout=TIMEOUT)
            time.sleep(SCRAPE_DELAY)
            
            # Get page HTML
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Check if driver_earning[5] has a value (indicates distance-based fees are configured)
            driver_earning_5 = self._extract_tier_value(soup, 'driver_earning', 5)
            result.uses_distance_based = (driver_earning_5 is not None and driver_earning_5 > 0)
            
            if not result.uses_distance_based:
                logger.info(f"  ⊘ {name}: No distance-based fees configured (driver_earning[5] empty), skipping")
                result.scrape_success = True
                return result
            
            # Extract delivery emails
            result.delivery_emails = self._extract_emails(soup)
            
            # Extract commission and restaurant pays difference
            result.commission = self._extract_float_value(soup, '#commission')
            result.restaurant_pays_difference = self._extract_float_value(soup, '#rpd')
            
            # Extract fee tiers for each distance
            result.fee_tiers = self._extract_fee_tiers(soup)
            
            result.scrape_success = True
            
            tier_count = len([t for t in result.fee_tiers if t.is_valid()])
            logger.info(f"  ✓ {name}: {len(result.delivery_emails)} emails, "
                       f"commission={result.commission}, rpd={result.restaurant_pays_difference}, "
                       f"{tier_count} fee tiers")
            
        except PlaywrightTimeout as e:
            result.error_message = f"Timeout: {e}"
            logger.error(f"  ✗ Timeout scraping {name}: {e}")
        except Exception as e:
            result.error_message = str(e)
            logger.error(f"  ✗ Error scraping {name}: {e}")
            import traceback
            logger.error(traceback.format_exc())
        
        return result
    
    def _extract_radio_value(self, soup: BeautifulSoup, name: str) -> Optional[str]:
        """Extract the value of a checked radio button."""
        checked = soup.select_one(f'input[name="{name}"]:checked')
        if checked:
            return checked.get('value', '')
        
        # Fallback: check for checked attribute
        for radio in soup.select(f'input[name="{name}"]'):
            if radio.has_attr('checked'):
                return radio.get('value', '')
        
        return None
    
    def _extract_float_value(self, soup: BeautifulSoup, selector: str) -> Optional[float]:
        """Extract float value from an input field."""
        element = soup.select_one(selector)
        if element:
            value = element.get('value', '').strip()
            return parse_float(value)
        return None
    
    def _extract_emails(self, soup: BeautifulSoup) -> List[str]:
        """Extract delivery company emails from the sendToDelivery_email input."""
        emails = []
        processed_inputs = set()
        
        # Try the main email input first
        email_input = soup.select_one('#sendToDelivery_email')
        if email_input:
            processed_inputs.add(id(email_input))
            value = email_input.get('value', '').strip()
            if value:
                # Split by comma and clean up (CRM stores multiple emails comma-separated)
                for email in value.split(','):
                    email = email.strip().lower()
                    if email and '@' in email and email not in emails:
                        emails.append(email)
        
        # Also check for any other email inputs in the delivery section
        for input_elem in soup.select('input[type="email"], input[name*="email"]'):
            # Skip already processed inputs
            if id(input_elem) in processed_inputs:
                continue
            processed_inputs.add(id(input_elem))
            
            value = input_elem.get('value', '').strip()
            if not value:
                continue
            
            # Split by comma in case this input also has multiple emails
            for email in value.split(','):
                email = email.strip().lower()
                if email and '@' in email and email not in emails:
                    emails.append(email)
        
        return emails
    
    def _extract_fee_tiers(self, soup: BeautifulSoup) -> List[FeeTier]:
        """Extract fee tiers for distances 5-10 km."""
        tiers = []
        
        for distance in DISTANCE_TIERS:
            tier = FeeTier(distance_km=distance)
            
            # Look for inputs with pattern: name="driver_earning[5]", etc.
            tier.driver_earning = self._extract_tier_value(soup, 'driver_earning', distance)
            tier.restaurant_pays = self._extract_tier_value(soup, 'restaurant_pays', distance)
            tier.vendor_pays = self._extract_tier_value(soup, 'vendor_pays', distance)
            tier.total_delivery_fee = self._extract_tier_value(soup, 'delivery_fee', distance)
            
            # Alternative naming patterns
            if tier.total_delivery_fee is None:
                tier.total_delivery_fee = self._extract_tier_value(soup, 'total_delivery_fee', distance)
            
            tiers.append(tier)
        
        return tiers
    
    def _extract_tier_value(self, soup: BeautifulSoup, field_name: str, distance: int) -> Optional[float]:
        """Extract a fee value for a specific distance tier."""
        # Try pattern: name="field_name[distance]"
        selector = f'input[name="{field_name}[{distance}]"]'
        element = soup.select_one(selector)
        if element:
            value = element.get('value', '').strip()
            return parse_float(value)
        
        # Try pattern: id="field_name_distance"
        selector = f'#{field_name}_{distance}'
        element = soup.select_one(selector)
        if element:
            value = element.get('value', '').strip()
            return parse_float(value)
        
        return None
    
    def __enter__(self):
        self.start()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

