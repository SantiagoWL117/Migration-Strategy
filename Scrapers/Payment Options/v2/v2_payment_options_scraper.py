"""
V2 Payment Options Scraper

Scrapes restaurant payment options from V2 CRM (aggregator-admin.menu.ca) and updates
the menuca_v3.restaurant_payment_options table.

Target data from URL: https://aggregator-admin.menu.ca/index.php/restaurants/edit/{v2_id}/info
- payment_method: Mapped from V2 ID (1=cash, 2=credit_card, 3=interac, 4=credit_or_debit_at_door, 904=credit_at_door, 905=debit_at_door)
- is_enabled: From checkbox checked attribute
- english_label: From override input or default span text
- french_label: From override input or hardcoded translations
- display_order: From checkbox order (1, 2, 3, 4, 904, 905)
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
    CRM_V2_BASE_URL,
    CRM_V2_USERNAME,
    CRM_V2_PASSWORD,
)

# Payment method ID mapping (V2 CRM ID -> V3 enum value)
PAYMENT_METHOD_MAPPING = {
    1: 'cash',
    2: 'credit_card',
    3: 'interac',
    4: 'credit_or_debit_at_door',
    904: 'credit_at_door',
    905: 'debit_at_door'
}

# Default labels from V2 CRM (used when override is empty)
DEFAULT_LABELS = {
    1: {
        'en': 'Cash',
        'fr': 'Comptant'
    },
    2: {
        'en': 'Credit card',
        'fr': 'Carte de crédit'
    },
    3: {
        'en': 'Interac',
        'fr': 'Interac'
    },
    4: {
        'en': 'Credit or debit at door',
        'fr': "Carte de crédit ou de débit à l'entrée"
    },
    904: {
        'en': 'Credit at door',
        'fr': "Carte de crédit à l'entrée"
    },
    905: {
        'en': 'Debit at door',
        'fr': "Débit à l'entrée"
    }
}


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
    Login to V2 CRM (aggregator-admin.menu.ca).
    Returns True if successful, False otherwise.
    """
    try:
        login_url = f"{CRM_V2_BASE_URL}/auth/index"
        logger.info(f"Navigating to V2 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in
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
        current_url = page.url
        
        if "auth" in current_url.lower() and "index" in current_url.lower():
            logger.error("Login failed - still on login page")
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
# Payment Options Scraping
# =============================================================================

async def scrape_restaurant_payment_options(page, v2_id: int, logger) -> Optional[List[Dict]]:
    """
    Scrape payment options from a restaurant's info page.
    
    Returns list of dicts with:
    - payment_method: V3 enum value (e.g., 'cash', 'credit_card')
    - is_enabled: Boolean (whether checkbox is checked)
    - english_label: English display name (from override or default)
    - french_label: French display name (from override or default)
    - display_order: Integer (from V2 CRM order)
    
    Returns None if data couldn't be scraped.
    """
    try:
        # Navigate to restaurant info page
        url = f"{CRM_V2_BASE_URL}/restaurants/edit/{v2_id}/info"
        logger.debug(f"Navigating to: {url}")
        
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Get page HTML
        content = await page.content()
        soup = BeautifulSoup(content, 'html5lib')
        
        # Check if we're still on login page (session expired)
        if soup.find('input', {'name': 'email', 'type': 'email'}):
            logger.warning(f"Session expired, need to re-login")
            return None
        
        # Find the payment options widget
        payment_widget = soup.find('div', {'id': 'payment-info'})
        
        if not payment_widget:
            logger.warning(f"Payment options widget not found for V2 ID {v2_id}")
            return None
        
        # Find the form
        payment_form = payment_widget.find('form', {'id': 'form-payment'})
        
        if not payment_form:
            logger.warning(f"Payment form not found for V2 ID {v2_id}")
            return None
        
        payment_options = []
        
        # Process each payment method ID
        for v2_payment_id, v3_payment_method in PAYMENT_METHOD_MAPPING.items():
            # Find checkbox
            checkbox = payment_form.find('input', {
                'type': 'checkbox',
                'name': f'payment[options][{v2_payment_id}]',
                'value': str(v2_payment_id)
            })
            
            if not checkbox:
                logger.debug(f"Payment option {v3_payment_method} (V2 ID: {v2_payment_id}) not found for restaurant {v2_id}")
                continue
            
            # Check if enabled (checkbox has 'checked' attribute)
            is_enabled = checkbox.has_attr('checked')
            
            # Get English override label
            en_override_input = payment_form.find('input', {
                'type': 'text',
                'name': f'payment[name][1][{v2_payment_id}]'
            })
            
            # Get French override label
            fr_override_input = payment_form.find('input', {
                'type': 'text',
                'name': f'payment[name][2][{v2_payment_id}]'
            })
            
            # Determine labels (use override if present, otherwise use defaults)
            en_override = en_override_input.get('value', '').strip() if en_override_input else ''
            fr_override = fr_override_input.get('value', '').strip() if fr_override_input else ''
            
            english_label = en_override if en_override else DEFAULT_LABELS[v2_payment_id]['en']
            french_label = fr_override if fr_override else DEFAULT_LABELS[v2_payment_id]['fr']
            
            payment_option = {
                'payment_method': v3_payment_method,
                'is_enabled': is_enabled,
                'english_label': english_label,
                'french_label': french_label,
                'display_order': list(PAYMENT_METHOD_MAPPING.keys()).index(v2_payment_id)
            }
            
            payment_options.append(payment_option)
            logger.debug(f"Scraped: {v3_payment_method} (enabled={is_enabled}, en='{english_label}', fr='{french_label}')")
        
        if not payment_options:
            logger.warning(f"No payment options found for V2 ID {v2_id}")
            return None
        
        logger.debug(f"Scraped {len(payment_options)} payment options for V2 ID {v2_id}")
        return payment_options
        
    except Exception as e:
        logger.error(f"Error scraping payment options for V2 ID {v2_id}: {e}")
        return None


# =============================================================================
# Database Operations
# =============================================================================

def get_v2_restaurants(db: DatabaseConnection, logger) -> List[Dict]:
    """
    Get all V2 restaurants (have legacy_v2_id).
    Returns list of dicts with id, name, legacy_v2_id.
    """
    try:
        query = f"""
            SELECT r.id, r.name, r.legacy_v2_id 
            FROM {db.schema}.restaurants r
            WHERE r.legacy_v2_id IS NOT NULL
              AND r.deleted_at IS NULL
            ORDER BY r.legacy_v2_id
        """
        result = db.execute_with_retry(query, fetch=True)
        
        restaurants = []
        for row in result:
            restaurants.append({
                'v3_id': row[0],
                'name': row[1],
                'v2_id': row[2]
            })
        
        logger.info(f"Found {len(restaurants)} V2 restaurants to scrape")
        return restaurants
        
    except Exception as e:
        logger.error(f"Error getting V2 restaurants: {e}")
        return []


def get_current_payment_options(db: DatabaseConnection, restaurant_id: int, logger) -> List[Dict]:
    """
    Get current payment options for a restaurant.
    Returns list of dicts with payment_method, is_enabled, labels, display_order.
    """
    try:
        query = f"""
            SELECT 
                payment_method,
                is_enabled,
                english_label,
                french_label,
                display_order
            FROM {db.schema}.restaurant_payment_options 
            WHERE restaurant_id = %s
            ORDER BY display_order
        """
        result = db.execute_with_retry(query, (restaurant_id,), fetch=True)
        
        options = []
        for row in result:
            options.append({
                'payment_method': row[0],
                'is_enabled': row[1],
                'english_label': row[2],
                'french_label': row[3],
                'display_order': row[4]
            })
        
        return options
        
    except Exception as e:
        logger.error(f"Error getting current payment options for restaurant {restaurant_id}: {e}")
        return []


def upsert_payment_option(db: DatabaseConnection, restaurant_id: int, 
                          payment_data: Dict, logger) -> bool:
    """
    Insert or update a payment option for a restaurant.
    
    Uses INSERT ... ON CONFLICT to handle existing records.
    """
    try:
        query = f"""
            INSERT INTO {db.schema}.restaurant_payment_options 
                (restaurant_id, payment_method, is_enabled, english_label, french_label, display_order, created_at, updated_at)
            VALUES 
                (%s, %s, %s, %s, %s, %s, NOW(), NOW())
            ON CONFLICT (restaurant_id, payment_method) 
            DO UPDATE SET
                is_enabled = EXCLUDED.is_enabled,
                english_label = EXCLUDED.english_label,
                french_label = EXCLUDED.french_label,
                display_order = EXCLUDED.display_order,
                updated_at = NOW()
        """
        
        params = (
            restaurant_id,
            payment_data['payment_method'],
            payment_data['is_enabled'],
            payment_data['english_label'],
            payment_data['french_label'],
            payment_data['display_order']
        )
        
        db.execute_with_retry(query, params)
        return True
        
    except Exception as e:
        logger.error(f"Error upserting payment option for restaurant {restaurant_id}: {e}")
        return False


def sync_payment_options(db: DatabaseConnection, restaurant_id: int, 
                         scraped_options: List[Dict], logger) -> Dict[str, int]:
    """
    Sync all payment options for a restaurant.
    
    Returns dict with counts:
    - inserted: New records created
    - updated: Existing records updated
    - unchanged: Records that didn't need updates
    """
    stats = {'inserted': 0, 'updated': 0, 'unchanged': 0}
    
    # Get current options
    current_options = {opt['payment_method']: opt for opt in get_current_payment_options(db, restaurant_id, logger)}
    
    for scraped in scraped_options:
        payment_method = scraped['payment_method']
        current = current_options.get(payment_method)
        
        # Check if update needed
        if current:
            # Compare all fields
            needs_update = (
                current['is_enabled'] != scraped['is_enabled'] or
                current['english_label'] != scraped['english_label'] or
                current['french_label'] != scraped['french_label'] or
                current['display_order'] != scraped['display_order']
            )
            
            if needs_update:
                if upsert_payment_option(db, restaurant_id, scraped, logger):
                    stats['updated'] += 1
                    logger.debug(f"  Updated: {payment_method}")
            else:
                stats['unchanged'] += 1
        else:
            # Insert new
            if upsert_payment_option(db, restaurant_id, scraped, logger):
                stats['inserted'] += 1
                logger.debug(f"  Inserted: {payment_method}")
    
    return stats


# =============================================================================
# Exports
# =============================================================================
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_crm',
    'scrape_restaurant_payment_options',
    'get_v2_restaurants',
    'get_current_payment_options',
    'sync_payment_options',
    'PAYMENT_METHOD_MAPPING',
    'DEFAULT_LABELS',
    'CRM_V2_BASE_URL',
    'CRM_V2_USERNAME',
    'CRM_V2_PASSWORD',
]
