"""
V2 Commission Rates Scraper

Scrapes restaurant commission rates from V2 CRM (aggregator-admin.menu.ca) and updates
the menuca_v3.restaurant_commission_configs table.

Target data:
- commission_enabled: From radio buttons name="commission" value="y/n"
- commission_rate: From <input name="commissionValue" value="10.00">
- commission_base: From radio buttons name="commissionFrom" value="g/n"
  - 'g' = gross
  - 'n' = net
"""

import os
import sys
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any

import psycopg2
from bs4 import BeautifulSoup

# Add parent directories to path to import config
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "Menu Scrapers"))
from config import (
    DB_CONNECTION_STRING,
    SCHEMA,
)

# =============================================================================
# V2 CRM Configuration (hardcoded)
# =============================================================================
CRM_V2_BASE_URL = "https://aggregator-admin.menu.ca/index.php"
CRM_V2_USERNAME = "santiago@worklocal.ca"
CRM_V2_PASSWORD = "WL2129925*"

# V2 Restaurants to scrape (V3 ID -> V2 ID mapping)
V2_RESTAURANTS = [
    {"v3_id": 147, "v2_id": 1171, "name": "Pho Dau Bo Restaurant - Kitchener"},
    {"v3_id": 1020, "v2_id": 1285, "name": "Sushi Presse"},
    {"v3_id": 950, "v2_id": 1637, "name": "Kirkwood Pizza"},
    {"v3_id": 952, "v2_id": 1639, "name": "River Pizza"},
    {"v3_id": 954, "v2_id": 1641, "name": "Wandee Thai"},
    {"v3_id": 825, "v2_id": 1642, "name": "La Nawab"},
    {"v3_id": 957, "v2_id": 1654, "name": "Cosenza"},
    {"v3_id": 960, "v2_id": 1657, "name": "Cuisine Bombay Indienne"},
    {"v3_id": 961, "v2_id": 1658, "name": "Chicco Shawarma Cantley"},
    {"v3_id": 963, "v2_id": 1660, "name": "Chicco Pizza Shawarma Anger"},
    {"v3_id": 964, "v2_id": 1661, "name": "Chicco Pizza Maloney"},
    {"v3_id": 965, "v2_id": 1662, "name": "Chicco Shawarma Maloney"},
    {"v3_id": 966, "v2_id": 1663, "name": "Chicco Pizza de l'Hopital"},
    {"v3_id": 967, "v2_id": 1664, "name": "Chicco Pizza St-Louis"},
    {"v3_id": 971, "v2_id": 1668, "name": "Little Gyros Greek Grill"},
    {"v3_id": 973, "v2_id": 1670, "name": "Capital Bites"},
    {"v3_id": 974, "v2_id": 1671, "name": "Pachino Pizza"},
    {"v3_id": 976, "v2_id": 1673, "name": "Pizza Marie"},
    {"v3_id": 977, "v2_id": 1674, "name": "Capri Pizza"},
    {"v3_id": 981, "v2_id": 1678, "name": "Al-s Drive In"},
]


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

async def login_to_v2_crm(page, logger) -> bool:
    """
    Login to V2 CRM (aggregator-admin.menu.ca).
    Returns True if successful, False otherwise.
    """
    try:
        login_url = f"{CRM_V2_BASE_URL}/auth/index"
        logger.info(f"Navigating to V2 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in (redirected to dashboard)
        content = await page.content()
        current_url = page.url
        if "dashboard" in current_url.lower() or "restaurants" in current_url.lower():
            logger.info("Already logged in to V2 CRM")
            return True
        
        # Fill email
        email_elem = await page.query_selector('input[name="email"]')
        if email_elem:
            await email_elem.fill(CRM_V2_USERNAME)
            logger.debug("Filled email field")
        else:
            logger.error("Could not find email field")
            return False
        
        # Fill password
        password_elem = await page.query_selector('input[name="password"]')
        if password_elem:
            await password_elem.fill(CRM_V2_PASSWORD)
            logger.debug("Filled password field")
        else:
            logger.error("Could not find password field")
            return False
        
        # Click login button
        submit_elem = await page.query_selector('button[type="submit"]')
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
        
        if "dashboard" in current_url.lower() or "restaurants" in current_url.lower():
            logger.info("V2 CRM login successful")
            return True
        
        logger.warning(f"Login status unclear. Current URL: {current_url}")
        return True  # Assume success and continue
        
    except Exception as e:
        logger.error(f"V2 CRM login error: {e}")
        return False


# =============================================================================
# Commission Scraping
# =============================================================================

async def scrape_restaurant_commission(page, v2_id: int, logger) -> Optional[Dict]:
    """
    Scrape commission data from a restaurant's configs page in V2 CRM.
    
    Returns dict with:
    - commission_enabled: True if commission is enabled (value="y")
    - commission_rate: Numeric value (e.g., 10.00 for 10%)
    - commission_base: 'gross' or 'net'
    
    Returns None if data couldn't be scraped.
    """
    try:
        # Navigate to configuration page
        url = f"{CRM_V2_BASE_URL}/restaurants/edit/{v2_id}/configs"
        logger.debug(f"Navigating to: {url}")
        
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Get page HTML
        content = await page.content()
        soup = BeautifulSoup(content, 'html5lib')
        
        # Check if we're on login page (session expired)
        if soup.find('input', {'name': 'email'}) and soup.find('input', {'name': 'password'}):
            logger.warning(f"Session expired, need to re-login")
            return None
        
        # Check for "restaurant not found" or similar errors
        if "not found" in content.lower() or "error" in content.lower():
            page_title = soup.find('title')
            if page_title and "error" in page_title.get_text().lower():
                logger.warning(f"Restaurant V2 ID {v2_id} not found or error page")
                return None
        
        # 1. Find commission_enabled (radio buttons name="commission")
        commission_enabled = False
        commission_yes = soup.find('input', {'name': 'commission', 'value': 'y'})
        commission_no = soup.find('input', {'name': 'commission', 'value': 'n'})
        
        if commission_yes and commission_yes.has_attr('checked'):
            commission_enabled = True
            logger.debug(f"Commission enabled: Yes (V2 ID {v2_id})")
        elif commission_no and commission_no.has_attr('checked'):
            commission_enabled = False
            logger.debug(f"Commission enabled: No (V2 ID {v2_id})")
        else:
            # Try to infer from raw HTML (BeautifulSoup may miss 'checked')
            if 'value="y" checked' in content or 'commission_y" class="" value="y" checked' in content:
                commission_enabled = True
            elif 'value="n" checked' in content:
                commission_enabled = False
            logger.debug(f"Commission enabled inferred: {commission_enabled} (V2 ID {v2_id})")
        
        # 2. Find commission_rate (input name="commissionValue")
        commission_rate = 0.0
        rate_input = soup.find('input', {'name': 'commissionValue', 'id': 'commissionValue'})
        if rate_input:
            value = rate_input.get('value', '').strip()
            try:
                commission_rate = float(value) if value else 0.0
            except ValueError:
                commission_rate = 0.0
                logger.warning(f"Could not parse commission rate '{value}' for V2 ID {v2_id}")
        else:
            logger.warning(f"Commission rate input not found for V2 ID {v2_id}")
        
        # 3. Find commission_base (radio buttons name="commissionFrom")
        commission_base = 'gross'  # Default to gross
        
        gross_radio = soup.find('input', {'name': 'commissionFrom', 'value': 'g'})
        net_radio = soup.find('input', {'name': 'commissionFrom', 'value': 'n'})
        
        if gross_radio and gross_radio.has_attr('checked'):
            commission_base = 'gross'
            logger.debug(f"Commission base: gross (V2 ID {v2_id})")
        elif net_radio and net_radio.has_attr('checked'):
            commission_base = 'net'
            logger.debug(f"Commission base: net (V2 ID {v2_id})")
        else:
            # Try to infer from raw HTML
            if 'commissionFrom" id="commission_n"' in content and 'checked' in content:
                # Check which one has checked attribute near it
                if 'value="n" checked' in content or 'commission_n" class="" value="n" checked' in content:
                    commission_base = 'net'
                elif 'value="g" checked' in content or 'commission_g" class="" value="g" checked' in content:
                    commission_base = 'gross'
            logger.debug(f"Commission base inferred: {commission_base} (V2 ID {v2_id})")
        
        result = {
            'commission_enabled': commission_enabled,
            'commission_rate': commission_rate,
            'commission_base': commission_base
        }
        
        logger.debug(f"Scraped commission for V2 ID {v2_id}: enabled={commission_enabled}, rate={commission_rate}%, base={commission_base}")
        
        return result
        
    except Exception as e:
        logger.error(f"Error scraping commission for V2 ID {v2_id}: {e}")
        return None


# =============================================================================
# Database Operations
# =============================================================================

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
                              commission_enabled: bool, commission_rate: float, 
                              commission_base: str, logger) -> bool:
    """
    Update restaurant_commission_configs with scraped data.
    
    Sets:
    - commission_enabled: From V2 CRM (explicit yes/no)
    - commission_rate: The scraped rate
    - commission_base: 'gross' or 'net'
    - updated_at: Current timestamp
    """
    try:
        query = f"""
            UPDATE {db.schema}.restaurant_commission_configs 
            SET commission_enabled = %s,
                commission_rate = %s,
                commission_base = %s,
                updated_at = NOW()
            WHERE restaurant_id = %s
        """
        
        params = (commission_enabled, commission_rate, commission_base, restaurant_id)
        db.execute_with_retry(query, params)
        
        logger.info(f"Updated commission for restaurant {restaurant_id}: enabled={commission_enabled}, rate={commission_rate}%, base={commission_base}")
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
    
    # Compare enabled status
    enabled_diff = current['commission_enabled'] != scraped['commission_enabled']
    
    # Compare rate (with tolerance for float comparison)
    rate_diff = abs(current['commission_rate'] - scraped['commission_rate']) > 0.001
    
    # Compare base
    base_diff = current['commission_base'] != scraped['commission_base']
    
    return enabled_diff or rate_diff or base_diff


# =============================================================================
# Exports
# =============================================================================
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_v2_crm',
    'scrape_restaurant_commission',
    'get_current_commission',
    'update_commission_config',
    'needs_update',
    'V2_RESTAURANTS',
    'CRM_V2_BASE_URL',
    'CRM_V2_USERNAME',
    'CRM_V2_PASSWORD',
]
