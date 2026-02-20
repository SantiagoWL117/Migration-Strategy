"""
V1 Commission Rates Scraper

Scrapes restaurant commission rates from V1 CRM (menuadmin.menu.ca) and updates
the menuca_v3.restaurant_commission_configs table.

Target data:
- commission_rate: From <input name="commission" value="7">
- commission_base: From <input type="radio" name="commission_from" value="g|n">
  - 'g' = gross
  - 'n' = net
"""

import os
import sys
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any, Tuple

import psycopg2
from bs4 import BeautifulSoup

# Add parent directories to path to import config
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "Menu Scrapers"))
from config import (
    DB_CONNECTION_STRING,
    SCHEMA,
)

# =============================================================================
# V1 CRM Configuration (hardcoded)
# =============================================================================
CRM_V1_BASE_URL = "https://menuadmin.menu.ca"
CRM_V1_USERNAME = "santiago@worklocal.ca"
CRM_V1_PASSWORD = "542sfgsgeerg4%$"


# =============================================================================
# Logging Setup
# =============================================================================

def setup_logging(name: str, log_dir: str = None) -> logging.Logger:
    """
    Set up logging with both file and console handlers.
    Auto-flushes after each log entry.
    """
    if log_dir is None:
        log_dir = Path(__file__).parent / "logs"
    else:
        log_dir = Path(log_dir)
    
    log_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"{name}_{timestamp}.log"
    
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    
    # Clear existing handlers
    logger.handlers.clear()
    
    # File handler
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)
    file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(file_formatter)
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter('%(levelname)s: %(message)s')
    console_handler.setFormatter(console_formatter)
    
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    # Auto-flush
    for handler in logger.handlers:
        handler.flush()
    
    logger.info(f"Logging to: {log_file}")
    
    return logger


# =============================================================================
# Database Connection
# =============================================================================

class DatabaseConnection:
    """Database connection wrapper with auto-reconnect and retry logic."""
    
    def __init__(self, connection_string: str = None, logger: logging.Logger = None):
        self.connection_string = connection_string or DB_CONNECTION_STRING
        self.logger = logger or logging.getLogger(__name__)
        self.conn = None
        self.schema = SCHEMA
    
    def connect(self):
        """Establish database connection."""
        try:
            self.conn = psycopg2.connect(self.connection_string)
            self.conn.autocommit = True
            self.logger.debug("Database connected")
        except Exception as e:
            self.logger.error(f"Database connection failed: {e}")
            raise
    
    def close(self):
        """Close database connection."""
        if self.conn:
            self.conn.close()
            self.conn = None
            self.logger.debug("Database connection closed")
    
    def ensure_connected(self):
        """Ensure database is connected, reconnect if needed."""
        if self.conn is None or self.conn.closed:
            self.connect()
    
    def execute_with_retry(self, query: str, params: tuple = None, 
                           fetch: bool = False, max_retries: int = 3) -> Any:
        """Execute query with retry logic."""
        for attempt in range(max_retries):
            try:
                self.ensure_connected()
                with self.conn.cursor() as cur:
                    cur.execute(query, params)
                    if fetch:
                        return cur.fetchall()
                    return True
            except psycopg2.OperationalError as e:
                self.logger.warning(f"Database error (attempt {attempt + 1}): {e}")
                self.conn = None  # Force reconnect
                if attempt == max_retries - 1:
                    raise
            except Exception as e:
                self.logger.error(f"Query error: {e}")
                raise
        return None


# =============================================================================
# CRM Login
# =============================================================================

async def login_to_crm(page, logger) -> bool:
    """
    Login to V1 CRM (menuadmin.menu.ca).
    Returns True if successful, False otherwise.
    """
    try:
        login_url = f"{CRM_V1_BASE_URL}/?p=login"
        logger.info(f"Navigating to V1 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in
        content = await page.content()
        if "logout" in content.lower() or "p=restaurants" in content.lower():
            logger.info("Already logged in to V1 CRM")
            return True
        
        # Fill username
        username_elem = await page.query_selector('input[name="username"]')
        if username_elem:
            await username_elem.fill(CRM_V1_USERNAME)
            logger.debug("Filled username field")
        else:
            logger.error("Could not find username field")
            return False
        
        # Fill password
        password_elem = await page.query_selector('input[name="password"]')
        if password_elem:
            await password_elem.fill(CRM_V1_PASSWORD)
            logger.debug("Filled password field")
        else:
            logger.error("Could not find password field")
            return False
        
        # Click login button
        submit_elem = await page.query_selector('input[type="submit"]')
        if submit_elem:
            await submit_elem.click()
            logger.debug("Clicked submit button")
        else:
            logger.error("Could not find submit button")
            return False
        
        # Wait for navigation
        await page.wait_for_load_state('networkidle', timeout=15000)
        await page.wait_for_timeout(2000)
        
        # Verify login success
        content = await page.content()
        current_url = page.url
        
        if "error" in content.lower() and ("invalid" in content.lower() or "incorrect" in content.lower()):
            logger.error("Login failed - invalid credentials")
            return False
        
        if "logout" in content.lower() or "restaurants" in current_url.lower():
            logger.info("V1 CRM login successful")
            return True
        
        logger.warning(f"Login status unclear. Current URL: {current_url}")
        return True  # Assume success and continue
        
    except Exception as e:
        logger.error(f"V1 CRM login error: {e}")
        return False


# =============================================================================
# Commission Scraping
# =============================================================================

async def scrape_restaurant_commission(page, v1_id: int, logger) -> Optional[Dict]:
    """
    Scrape commission data from a restaurant's cfg (configuration) page.
    
    Returns dict with:
    - commission_rate: Numeric value (e.g., 7 for 7%)
    - commission_base: 'gross' or 'net'
    
    Returns None if data couldn't be scraped.
    """
    try:
        # Navigate to configuration page
        url = f"{CRM_V1_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=cfg&showLang=en"
        logger.debug(f"Navigating to: {url}")
        
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Get page HTML
        content = await page.content()
        soup = BeautifulSoup(content, 'html5lib')
        
        # Check if we're still on login page (session expired)
        if soup.find('input', {'name': 'username'}):
            logger.warning(f"Session expired, need to re-login")
            return None
        
        # Find commission rate input
        commission_input = soup.find('input', {'name': 'commission', 'id': 'commission'})
        commission_rate = None
        if commission_input:
            value = commission_input.get('value', '').strip()
            try:
                commission_rate = float(value) if value else 0.0
            except ValueError:
                commission_rate = 0.0
                logger.warning(f"Could not parse commission rate '{value}' for V1 ID {v1_id}")
        else:
            logger.warning(f"Commission input not found for V1 ID {v1_id}")
            # Check the raw HTML for debugging
            if 'commission' in content.lower():
                logger.debug("'commission' found in page content but input not parsed")
        
        # Find commission_from radio buttons
        commission_base = 'gross'  # Default to gross
        
        # Look for the checked radio button
        gross_radio = soup.find('input', {'name': 'commission_from', 'value': 'g'})
        net_radio = soup.find('input', {'name': 'commission_from', 'value': 'n'})
        
        if gross_radio and gross_radio.has_attr('checked'):
            commission_base = 'gross'
            logger.debug(f"Commission base: gross (V1 ID {v1_id})")
        elif net_radio and net_radio.has_attr('checked'):
            commission_base = 'net'
            logger.debug(f"Commission base: net (V1 ID {v1_id})")
        else:
            # If no radio is explicitly checked, try to infer from HTML
            # BeautifulSoup may not always capture 'checked' correctly
            if 'commission_n" checked' in content or 'value="n" checked' in content:
                commission_base = 'net'
            elif 'commission_g" checked' in content or 'value="g" checked' in content:
                commission_base = 'gross'
            logger.debug(f"Commission base inferred: {commission_base} (V1 ID {v1_id})")
        
        result = {
            'commission_rate': commission_rate,
            'commission_base': commission_base
        }
        
        logger.debug(f"Scraped commission for V1 ID {v1_id}: rate={commission_rate}%, base={commission_base}")
        
        return result
        
    except Exception as e:
        logger.error(f"Error scraping commission for V1 ID {v1_id}: {e}")
        return None


# =============================================================================
# Database Operations
# =============================================================================

def get_v1_restaurants(db: DatabaseConnection, logger) -> List[Dict]:
    """
    Get all V1 restaurants (have legacy_v1_id, no legacy_v2_id).
    Returns list of dicts with id, name, legacy_v1_id.
    """
    try:
        query = f"""
            SELECT r.id, r.name, r.legacy_v1_id 
            FROM {db.schema}.restaurants r
            WHERE r.legacy_v1_id IS NOT NULL 
              AND r.legacy_v2_id IS NULL
              AND r.deleted_at IS NULL
            ORDER BY r.legacy_v1_id
        """
        result = db.execute_with_retry(query, fetch=True)
        
        restaurants = []
        for row in result:
            restaurants.append({
                'v3_id': row[0],
                'name': row[1],
                'v1_id': row[2]
            })
        
        logger.info(f"Found {len(restaurants)} V1 restaurants to scrape")
        return restaurants
        
    except Exception as e:
        logger.error(f"Error getting V1 restaurants: {e}")
        return []


def get_current_commission(db: DatabaseConnection, restaurant_id: int, logger) -> Optional[Dict]:
    """
    Get current commission config for a restaurant.
    """
    try:
        query = f"""
            SELECT id, commission_rate, commission_base, commission_enabled
            FROM {db.schema}.restaurant_commission_configs 
            WHERE restaurant_id = %s
        """
        result = db.execute_with_retry(query, (restaurant_id,), fetch=True)
        
        if result:
            row = result[0]
            return {
                'id': row[0],
                'commission_rate': float(row[1]),
                'commission_base': row[2],
                'commission_enabled': row[3]
            }
        return None
        
    except Exception as e:
        logger.error(f"Error getting current commission for restaurant {restaurant_id}: {e}")
        return None


def update_commission_config(db: DatabaseConnection, restaurant_id: int, 
                              commission_rate: float, commission_base: str,
                              logger) -> bool:
    """
    Update restaurant_commission_configs with scraped data.
    
    Sets:
    - commission_rate: The scraped rate
    - commission_base: 'gross' or 'net'
    - commission_enabled: True if rate > 0, False otherwise
    - updated_at: Current timestamp
    """
    try:
        # Determine if commission should be enabled (rate > 0)
        commission_enabled = commission_rate > 0
        
        query = f"""
            UPDATE {db.schema}.restaurant_commission_configs 
            SET commission_rate = %s,
                commission_base = %s,
                commission_enabled = %s,
                updated_at = NOW()
            WHERE restaurant_id = %s
        """
        
        params = (commission_rate, commission_base, commission_enabled, restaurant_id)
        db.execute_with_retry(query, params)
        
        logger.info(f"Updated commission for restaurant {restaurant_id}: rate={commission_rate}%, base={commission_base}, enabled={commission_enabled}")
        return True
        
    except Exception as e:
        logger.error(f"Error updating commission for restaurant {restaurant_id}: {e}")
        return False


def needs_update(current: Dict, scraped: Dict) -> bool:
    """
    Check if the scraped data differs from current data.
    Returns True if update is needed.
    """
    if current is None:
        return True
    
    # Compare rate (with tolerance for float comparison)
    rate_diff = abs(current['commission_rate'] - scraped['commission_rate']) > 0.001
    
    # Compare base
    base_diff = current['commission_base'] != scraped['commission_base']
    
    return rate_diff or base_diff


# =============================================================================
# Exports
# =============================================================================
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_crm',
    'scrape_restaurant_commission',
    'get_v1_restaurants',
    'get_current_commission',
    'update_commission_config',
    'needs_update',
    'CRM_V1_BASE_URL',
    'CRM_V1_USERNAME',
    'CRM_V1_PASSWORD',
]
