"""
Shared utilities for V1 CRM Scrapers - VERSION 2
- Database connection with reconnect logic
- CRM login functionality
- Logging setup
- FIXED: Uses source_id (V1 modifier ID) for uniqueness instead of name

Changes from v1:
- insert_modifier now uses source_id for unique constraint
- Supports multiple modifiers with same name but different V1 IDs
"""

import logging
import re
import time
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any
import psycopg2
from psycopg2 import OperationalError
from playwright.async_api import Page, Browser

# =============================================================================
# CONFIGURATION
# =============================================================================

CRM_BASE_URL = "https://menuadmin.menu.ca"
CRM_USERNAME = "santiago@worklocal.ca"
CRM_PASSWORD = "542sfgsgeerg4%$"

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# Size variants for multi-price modifiers
SIZE_VARIANTS_ENGLISH = ["Small", "Medium", "Large", "XL"]
SIZE_VARIANTS_FRENCH = ["Petite", "Moyenne", "Grande", "X-Grande"]

# =============================================================================
# LOGGING SETUP
# =============================================================================

def setup_logging(log_name: str, log_dir: Optional[Path] = None) -> logging.Logger:
    """Setup logging with file and console handlers."""
    if log_dir is None:
        log_dir = Path(__file__).parent / "logs"
    log_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"{log_name}_{timestamp}.log"
    
    logger = logging.getLogger(log_name)
    logger.setLevel(logging.DEBUG)
    
    # Clear existing handlers
    logger.handlers = []
    
    # File handler
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)
    file_format = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(file_format)
    logger.addHandler(file_handler)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter('%(levelname)s - %(message)s')
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    logger.info(f"Logging to: {log_file}")
    return logger

# =============================================================================
# DATABASE CONNECTION WITH RECONNECT
# =============================================================================

class DatabaseConnection:
    """Database connection manager with automatic reconnect."""
    
    def __init__(self, connection_string: str = DB_CONNECTION_STRING, 
                 max_retries: int = 3, retry_delay: int = 5,
                 logger: Optional[logging.Logger] = None):
        self.connection_string = connection_string
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.logger = logger or logging.getLogger(__name__)
        self._conn = None
    
    def connect(self) -> psycopg2.extensions.connection:
        """Establish database connection with retry logic."""
        for attempt in range(1, self.max_retries + 1):
            try:
                if self._conn is not None:
                    try:
                        self._conn.close()
                    except:
                        pass
                
                self._conn = psycopg2.connect(self.connection_string)
                self._conn.autocommit = False
                self.logger.info(f"Database connected (attempt {attempt})")
                return self._conn
            except OperationalError as e:
                self.logger.warning(f"Connection attempt {attempt} failed: {e}")
                if attempt < self.max_retries:
                    self.logger.info(f"Retrying in {self.retry_delay} seconds...")
                    time.sleep(self.retry_delay)
                else:
                    raise
    
    def get_connection(self) -> psycopg2.extensions.connection:
        """Get active connection, reconnecting if necessary."""
        if self._conn is None:
            return self.connect()
        
        try:
            # Test connection
            with self._conn.cursor() as cur:
                cur.execute("SELECT 1")
            return self._conn
        except (OperationalError, psycopg2.InterfaceError):
            self.logger.warning("Connection lost, reconnecting...")
            return self.connect()
    
    def execute_with_retry(self, query: str, params: tuple = None, 
                           fetch: bool = False) -> Optional[List]:
        """Execute query with automatic reconnect on failure."""
        for attempt in range(1, self.max_retries + 1):
            try:
                conn = self.get_connection()
                with conn.cursor() as cur:
                    cur.execute(query, params)
                    if fetch:
                        return cur.fetchall()
                    conn.commit()
                    return None
            except (OperationalError, psycopg2.InterfaceError) as e:
                self.logger.warning(f"Query failed (attempt {attempt}): {e}")
                if attempt < self.max_retries:
                    self._conn = None  # Force reconnect
                    time.sleep(self.retry_delay)
                else:
                    raise
    
    def close(self):
        """Close database connection."""
        if self._conn:
            try:
                self._conn.close()
                self.logger.info("Database connection closed")
            except:
                pass
            self._conn = None

# =============================================================================
# CRM LOGIN
# =============================================================================

async def login_to_crm(page: Page, logger: logging.Logger) -> bool:
    """Login to V1 CRM."""
    try:
        logger.info("Navigating to CRM login page...")
        await page.goto(f"{CRM_BASE_URL}/?p=login", wait_until="networkidle", timeout=30000)
        
        # Check if already logged in
        if "logout" in (await page.content()).lower():
            logger.info("Already logged in")
            return True
        
        # Fill login form
        logger.info("Filling login credentials...")
        await page.fill('#username', CRM_USERNAME)
        await page.fill('#password', CRM_PASSWORD)
        
        # Submit form
        await page.click('input[type="submit"]')
        await page.wait_for_load_state("networkidle", timeout=30000)
        
        # Verify login success
        content = await page.content()
        if "logout" in content.lower() or "restaurants" in content.lower():
            logger.info("Login successful")
            return True
        else:
            logger.error("Login failed - unexpected page content")
            return False
            
    except Exception as e:
        logger.error(f"Login error: {e}")
        return False

# =============================================================================
# MODIFIER GROUP EXTRACTION - V2
# =============================================================================

async def extract_modifier_groups(page: Page, restaurant_v1_id: int, 
                                   lang: str, logger: logging.Logger) -> List[Dict]:
    """
    Extract all modifier groups from the ingredient groups page.
    Returns list of modifier group data dictionaries.
    
    V2 CHANGE: Now extracts V1 modifier ID (source_id) from checkbox value attribute
    """
    show_lang = "en" if lang == "english" else "fr"
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={restaurant_v1_id}&load=ingredientGroups&showLang={show_lang}"
    
    logger.info(f"Navigating to modifier groups page: {url}")
    await page.goto(url, wait_until="networkidle", timeout=60000)
    
    # Force expand all modifier group divs
    logger.debug("Expanding all modifier group divs...")
    await page.evaluate('''
        document.querySelectorAll('div[id^="div_"]').forEach(div => {
            div.style.display = 'block';
        });
    ''')
    await page.wait_for_timeout(500)
    
    # Get page content for JavaScript extraction
    page_content = await page.content()
    
    # Extract objItem and objPrice arrays from JavaScript
    obj_item_pattern = r'var objItem(\d+) = \[(.*?)\];'
    obj_price_pattern = r'var objPrice(\d+) = \{(.*?)\};'
    
    active_modifiers = {}  # group_id -> list of active modifier IDs
    modifier_prices = {}   # group_id -> {modifier_id: price_string}
    
    for match in re.finditer(obj_item_pattern, page_content):
        group_id = match.group(1)
        items_str = match.group(2)
        # Parse array items: ["id1","id2",...]
        active_ids = [id.strip('"\'') for id in items_str.split(',') if id.strip().strip('"\'')]
        active_modifiers[group_id] = active_ids
        logger.debug(f"Group {group_id}: {len(active_ids)} active modifiers")
    
    for match in re.finditer(obj_price_pattern, page_content):
        group_id = match.group(1)
        prices_str = match.group(2)
        # Parse object: "id1":"price1","id2":"price2",...
        prices = {}
        for price_match in re.finditer(r'"(\d+)":"([^"]*)"', prices_str):
            mod_id = price_match.group(1)
            price_val = price_match.group(2)
            prices[mod_id] = price_val
        modifier_prices[group_id] = prices
    
    # Extract modifier groups from HTML
    modifier_groups = []
    
    # Find all modifier group headers
    group_headers = await page.query_selector_all('p > a[onclick*="toggle"]')
    
    for header in group_headers:
        try:
            # Get group name from header text
            group_name = (await header.text_content()).strip()
            
            # Extract group ID from onclick attribute
            onclick = await header.get_attribute('onclick')
            group_id_match = re.search(r"div_(\d+)", onclick)
            if not group_id_match:
                continue
            group_id = group_id_match.group(1)
            
            logger.info(f"Processing modifier group: {group_name} (ID: {group_id})")
            
            # Get category from select dropdown
            type_select = await page.query_selector(f'#type_{group_id}')
            category = None
            if type_select:
                category = await page.evaluate('''(select) => {
                    const selected = select.querySelector('option[selected]');
                    return selected ? selected.value : null;
                }''', type_select)
            
            # Get active modifier IDs for this group
            group_active_ids = active_modifiers.get(group_id, [])
            group_prices = modifier_prices.get(group_id, {})
            
            # Extract modifiers from the form
            modifiers_data = []
            checkboxes = await page.query_selector_all(f'#fillme_{group_id} input[type="checkbox"]')
            
            display_order = 0
            for checkbox in checkboxes:
                # V2 CHANGE: Extract V1 modifier ID from checkbox value
                v1_modifier_id = await checkbox.get_attribute('value')
                
                # Check if this modifier is active (checked in V1 CRM)
                is_active = v1_modifier_id in group_active_ids
                
                # Get modifier name from label
                label = await page.query_selector(f'label[for$="_{group_id}_{v1_modifier_id}"]')
                modifier_name = ""
                if label:
                    modifier_name = (await label.text_content()).strip()
                
                # Get price(s) - use price from objPrice if available, else from HTML input
                price_str = group_prices.get(v1_modifier_id, "0.00")
                
                # If not in objPrice, try to get from HTML input field
                if v1_modifier_id not in group_prices:
                    price_input = await page.query_selector(f'#price__{group_id}_{v1_modifier_id}')
                    if price_input:
                        price_str = await price_input.get_attribute('value') or "0.00"
                
                modifiers_data.append({
                    'source_id': v1_modifier_id,  # V2 CHANGE: Store V1 ID as source_id
                    'name': modifier_name,
                    'price_string': price_str,
                    'display_order': display_order,
                    'is_active': is_active
                })
                display_order += 1
            
            modifier_groups.append({
                'v1_id': group_id,
                'name': group_name,
                'category': category,
                'modifiers': modifiers_data
            })
            
            active_count = sum(1 for m in modifiers_data if m['is_active'])
            logger.info(f"  Found {len(modifiers_data)} modifiers ({active_count} active, {len(modifiers_data) - active_count} inactive)")
            
        except Exception as e:
            logger.error(f"Error processing group header: {e}")
            continue
    
    logger.info(f"Total modifier groups extracted: {len(modifier_groups)}")
    return modifier_groups

# =============================================================================
# DATABASE OPERATIONS - V2
# =============================================================================

def insert_modifier_group(db: DatabaseConnection, restaurant_id: int, 
                          group_data: Dict, lang: str, 
                          logger: logging.Logger) -> Optional[int]:
    """Insert a modifier group and return its ID."""
    try:
        # Check if modifier group already exists
        check_query = """
            SELECT id FROM menuca_v3.modifier_groups 
            WHERE restaurant_id = %s AND source_system = %s
        """
        result = db.execute_with_retry(check_query, (restaurant_id, group_data['v1_id']), fetch=True)
        
        if result:
            group_id = result[0][0]
            logger.debug(f"Modifier group already exists: {group_data['name']} (ID: {group_id})")
            # Update existing
            update_query = """
                UPDATE menuca_v3.modifier_groups 
                SET name = %s, category = %s, updated_at = NOW()
                WHERE id = %s
            """
            db.execute_with_retry(update_query, (group_data['name'], group_data['category'], group_id))
            return group_id
        
        # Insert new modifier group
        insert_query = """
            INSERT INTO menuca_v3.modifier_groups 
            (restaurant_id, name, category, source_system, created_at, updated_at)
            VALUES (%s, %s, %s, %s, NOW(), NOW())
            RETURNING id
        """
        result = db.execute_with_retry(
            insert_query, 
            (restaurant_id, group_data['name'], group_data['category'], group_data['v1_id']),
            fetch=True
        )
        
        if result:
            group_id = result[0][0]
            logger.info(f"Inserted modifier group: {group_data['name']} (ID: {group_id})")
            return group_id
        
        return None
        
    except Exception as e:
        logger.error(f"Error inserting modifier group: {e}")
        raise

def insert_modifier(db: DatabaseConnection, modifier_group_id: int, 
                    modifier_data: Dict, logger: logging.Logger) -> Optional[int]:
    """
    Insert a modifier and return its ID.
    
    V2 CHANGE: Uses source_id (V1 modifier ID) for uniqueness instead of name.
    This allows multiple modifiers with same name but different V1 IDs.
    """
    try:
        source_id = modifier_data.get('source_id', '')
        
        # V2: Check if modifier already exists by source_id within same group
        check_query = """
            SELECT id FROM menuca_v3.modifiers 
            WHERE modifier_group_id = %s AND source_id = %s
        """
        result = db.execute_with_retry(
            check_query, 
            (modifier_group_id, source_id), 
            fetch=True
        )
        
        if result:
            modifier_id = result[0][0]
            logger.debug(f"Updating modifier: {modifier_data['name']} (source_id: {source_id})")
            # Update existing - update all fields including name, price data will be updated separately
            update_query = """
                UPDATE menuca_v3.modifiers 
                SET name = %s, display_order = %s, is_active = %s, updated_at = NOW()
                WHERE id = %s
            """
            db.execute_with_retry(
                update_query, 
                (modifier_data['name'], modifier_data['display_order'], 
                 modifier_data['is_active'], modifier_id)
            )
            return modifier_id
        
        # Insert new modifier with source_id
        insert_query = """
            INSERT INTO menuca_v3.modifiers 
            (modifier_group_id, name, source_id, display_order, is_active, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, NOW(), NOW())
            RETURNING id
        """
        result = db.execute_with_retry(
            insert_query,
            (modifier_group_id, modifier_data['name'], source_id,
             modifier_data['display_order'], modifier_data['is_active']),
            fetch=True
        )
        
        if result:
            modifier_id = result[0][0]
            status = "ACTIVE" if modifier_data['is_active'] else "inactive"
            logger.debug(f"Inserted modifier: {modifier_data['name']} [{status}] (source_id: {source_id}, ID: {modifier_id})")
            return modifier_id
        
        return None
        
    except Exception as e:
        logger.error(f"Error inserting modifier: {e}")
        raise

def insert_modifier_prices(db: DatabaseConnection, modifier_id: int, 
                           price_string: str, lang: str, 
                           logger: logging.Logger) -> int:
    """Insert modifier prices and return count inserted."""
    try:
        size_variants = SIZE_VARIANTS_FRENCH if lang == "french" else SIZE_VARIANTS_ENGLISH
        
        # Delete existing prices for this modifier
        delete_query = "DELETE FROM menuca_v3.modifier_prices WHERE modifier_id = %s"
        db.execute_with_retry(delete_query, (modifier_id,))
        
        # Parse price string
        prices = price_string.split(',') if ',' in price_string else [price_string]
        
        inserted = 0
        for idx, price in enumerate(prices):
            price = price.strip()
            if not price:
                price = "0.00"
            
            try:
                price_value = float(price)
            except ValueError:
                price_value = 0.00
            
            # Determine size variant
            if len(prices) == 1:
                size_variant = None  # Single price, no size
            else:
                size_variant = size_variants[idx] if idx < len(size_variants) else f"Size {idx + 1}"
            
            insert_query = """
                INSERT INTO menuca_v3.modifier_prices 
                (modifier_id, size_variant, price, display_order, created_at, updated_at)
                VALUES (%s, %s, %s, %s, NOW(), NOW())
            """
            db.execute_with_retry(
                insert_query, 
                (modifier_id, size_variant, price_value, idx)
            )
            inserted += 1
        
        return inserted
        
    except Exception as e:
        logger.error(f"Error inserting modifier prices: {e}")
        raise



