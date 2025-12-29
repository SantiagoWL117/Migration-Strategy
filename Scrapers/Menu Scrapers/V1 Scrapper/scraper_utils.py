"""
Shared utilities for V1 CRM Scrapers
- Database connection with robust reconnect and transaction recovery
- CRM login functionality
- Logging setup with auto-flush
"""

import logging
import re
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any
import psycopg2
from psycopg2 import OperationalError, InterfaceError, DatabaseError
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
# AUTO-FLUSH LOGGING SETUP
# =============================================================================

class FlushFileHandler(logging.FileHandler):
    """File handler that flushes after every write."""
    def emit(self, record):
        super().emit(record)
        self.flush()

class FlushStreamHandler(logging.StreamHandler):
    """Stream handler that flushes after every write."""
    def emit(self, record):
        super().emit(record)
        self.flush()

def setup_logging(log_name: str, log_dir: Optional[Path] = None) -> logging.Logger:
    """Setup logging with auto-flush file and console handlers."""
    if log_dir is None:
        log_dir = Path(__file__).parent / "logs"
    log_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"{log_name}_{timestamp}.log"
    
    logger = logging.getLogger(log_name)
    logger.setLevel(logging.DEBUG)
    
    # Clear existing handlers
    logger.handlers = []
    
    # File handler with auto-flush
    file_handler = FlushFileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)
    file_format = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(file_format)
    logger.addHandler(file_handler)
    
    # Console handler with auto-flush
    console_handler = FlushStreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter('%(levelname)s - %(message)s')
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    logger.info(f"Logging to: {log_file}")
    return logger

# =============================================================================
# DATABASE CONNECTION WITH ROBUST RECONNECT & TRANSACTION RECOVERY
# =============================================================================

class DatabaseConnection:
    """
    Database connection manager with:
    - Automatic reconnect on connection loss
    - Transaction recovery after reconnection
    - Per-operation commits for data safety
    - Infinite retry for transient failures
    """
    
    def __init__(self, connection_string: str = DB_CONNECTION_STRING, 
                 max_retries: int = 10, retry_delay: int = 5,
                 logger: Optional[logging.Logger] = None):
        self.connection_string = connection_string
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.logger = logger or logging.getLogger(__name__)
        self._conn = None
        self._in_transaction = False
    
    def connect(self) -> psycopg2.extensions.connection:
        """Establish database connection with retry logic."""
        attempt = 0
        while True:
            attempt += 1
            try:
                if self._conn is not None:
                    try:
                        self._conn.close()
                    except:
                        pass
                    self._conn = None
                
                self._conn = psycopg2.connect(self.connection_string)
                self._conn.autocommit = False
                self._in_transaction = False
                self.logger.info(f"Database connected (attempt {attempt})")
                return self._conn
                
            except OperationalError as e:
                self.logger.warning(f"Connection attempt {attempt} failed: {e}")
                if attempt < self.max_retries:
                    self.logger.info(f"Retrying in {self.retry_delay} seconds...")
                    time.sleep(self.retry_delay)
                else:
                    # After max_retries, keep trying with longer delay
                    self.logger.warning(f"Max retries reached. Continuing with {self.retry_delay * 2}s delay...")
                    time.sleep(self.retry_delay * 2)
    
    def get_connection(self) -> psycopg2.extensions.connection:
        """Get active connection, reconnecting if necessary."""
        if self._conn is None:
            return self.connect()
        
        try:
            # Test connection with simple query
            with self._conn.cursor() as cur:
                cur.execute("SELECT 1")
            return self._conn
        except (OperationalError, InterfaceError, DatabaseError) as e:
            self.logger.warning(f"Connection lost ({type(e).__name__}), reconnecting...")
            self._in_transaction = False
            return self.connect()
    
    def begin_transaction(self):
        """Start a new transaction."""
        conn = self.get_connection()
        if self._in_transaction:
            try:
                conn.rollback()
            except:
                pass
        self._in_transaction = True
        self.logger.debug("Transaction started")
    
    def commit(self):
        """Commit current transaction with retry on failure."""
        if not self._in_transaction:
            return
        
        attempt = 0
        while True:
            attempt += 1
            try:
                conn = self.get_connection()
                conn.commit()
                self._in_transaction = False
                self.logger.debug("Transaction committed")
                return
            except (OperationalError, InterfaceError, DatabaseError) as e:
                self.logger.warning(f"Commit failed (attempt {attempt}): {e}")
                if attempt >= self.max_retries:
                    self.logger.error("Commit failed after max retries - transaction lost")
                    self._in_transaction = False
                    raise
                time.sleep(self.retry_delay)
                # Reconnect will happen on next get_connection call
                self._conn = None
    
    def rollback(self):
        """Rollback current transaction."""
        if not self._in_transaction:
            return
        try:
            if self._conn:
                self._conn.rollback()
        except:
            pass
        self._in_transaction = False
        self.logger.debug("Transaction rolled back")
    
    def execute_with_retry(self, query: str, params: tuple = None, 
                           fetch: bool = False, auto_commit: bool = True) -> Optional[List]:
        """
        Execute query with automatic reconnect and retry on failure.
        
        Args:
            query: SQL query to execute
            params: Query parameters
            fetch: If True, return fetched results
            auto_commit: If True, commit after successful execution (default True for safety)
        """
        attempt = 0
        last_error = None
        
        while True:
            attempt += 1
            try:
                conn = self.get_connection()
                
                # Start transaction if not already in one
                if not self._in_transaction:
                    self._in_transaction = True
                
                with conn.cursor() as cur:
                    cur.execute(query, params)
                    result = cur.fetchall() if fetch else None
                
                # Auto-commit for safety (each operation is durable)
                if auto_commit:
                    conn.commit()
                    self._in_transaction = False
                
                return result
                
            except (OperationalError, InterfaceError) as e:
                last_error = e
                self.logger.warning(f"Query failed (attempt {attempt}): {e}")
                self._in_transaction = False
                self._conn = None  # Force reconnect
                
                if attempt >= self.max_retries:
                    self.logger.error(f"Query failed after {attempt} attempts")
                    raise
                
                self.logger.info(f"Retrying in {self.retry_delay} seconds...")
                time.sleep(self.retry_delay)
                
            except DatabaseError as e:
                # Non-connection errors (constraint violations, etc.)
                self.logger.error(f"Database error: {e}")
                self.rollback()
                raise
    
    def close(self):
        """Close database connection."""
        if self._conn:
            try:
                if self._in_transaction:
                    self._conn.rollback()
                self._conn.close()
                self.logger.info("Database connection closed")
            except:
                pass
            self._conn = None
            self._in_transaction = False

# =============================================================================
# PROGRESS TRACKING - CHECK IF RESTAURANT ALREADY PROCESSED
# =============================================================================

def get_processed_restaurants(db: DatabaseConnection, logger: logging.Logger) -> set:
    """
    Get set of restaurant V3 IDs that already have modifier data.
    Used to skip already-processed restaurants on restart.
    """
    try:
        query = """
            SELECT DISTINCT mg.restaurant_id 
            FROM menuca_v3.modifier_groups mg
            JOIN menuca_v3.modifiers m ON mg.id = m.modifier_group_id
            WHERE m.source_id IS NOT NULL
        """
        result = db.execute_with_retry(query, fetch=True)
        processed = {row[0] for row in result} if result else set()
        logger.info(f"Found {len(processed)} restaurants already processed")
        return processed
    except Exception as e:
        logger.warning(f"Could not get processed restaurants: {e}")
        return set()

def restaurant_has_modifiers(db: DatabaseConnection, restaurant_id: int, logger: logging.Logger) -> bool:
    """Check if a restaurant already has modifier data."""
    try:
        query = """
            SELECT EXISTS(
                SELECT 1 FROM menuca_v3.modifier_groups mg
                JOIN menuca_v3.modifiers m ON mg.id = m.modifier_group_id
                WHERE mg.restaurant_id = %s AND m.source_id IS NOT NULL
                LIMIT 1
            )
        """
        result = db.execute_with_retry(query, (restaurant_id,), fetch=True)
        return result[0][0] if result else False
    except Exception as e:
        logger.warning(f"Could not check restaurant modifiers: {e}")
        return False

# =============================================================================
# CRM LOGIN
# =============================================================================

async def login_to_crm(page: Page, logger: logging.Logger) -> bool:
    """Login to V1 CRM with retry logic."""
    max_attempts = 3
    
    for attempt in range(1, max_attempts + 1):
        try:
            logger.info(f"Navigating to CRM login page (attempt {attempt})...")
            await page.goto(f"{CRM_BASE_URL}/?p=login", wait_until="networkidle", timeout=60000)
            
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
            await page.wait_for_load_state("networkidle", timeout=60000)
            
            # Verify login success
            content = await page.content()
            if "logout" in content.lower() or "restaurants" in content.lower():
                logger.info("Login successful")
                return True
            else:
                logger.warning(f"Login attempt {attempt} failed - unexpected page content")
                
        except Exception as e:
            logger.warning(f"Login attempt {attempt} error: {e}")
        
        if attempt < max_attempts:
            logger.info(f"Retrying login in 5 seconds...")
            await page.wait_for_timeout(5000)
    
    logger.error("All login attempts failed")
    return False

# =============================================================================
# MODIFIER GROUP EXTRACTION
# =============================================================================

async def extract_modifier_groups(page: Page, restaurant_v1_id: int, 
                                   lang: str, logger: logging.Logger) -> List[Dict]:
    """
    Extract all modifier groups from the ingredient groups page.
    Returns list of modifier group data dictionaries.
    """
    show_lang = "en" if lang == "english" else "fr"
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={restaurant_v1_id}&load=ingredientGroups&showLang={show_lang}"
    
    logger.info(f"Navigating to modifier groups page: {url}")
    
    # Navigate with retry
    max_attempts = 3
    for attempt in range(1, max_attempts + 1):
        try:
            await page.goto(url, wait_until="networkidle", timeout=60000)
            break
        except Exception as e:
            logger.warning(f"Navigation attempt {attempt} failed: {e}")
            if attempt >= max_attempts:
                raise
            await page.wait_for_timeout(5000)
    
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
                modifier_id = await checkbox.get_attribute('value')
                
                # Check if this modifier is active (checked in V1 CRM)
                is_active = modifier_id in group_active_ids
                
                # Get modifier name from label
                label = await page.query_selector(f'label[for$="_{group_id}_{modifier_id}"]')
                modifier_name = ""
                if label:
                    modifier_name = (await label.text_content()).strip()
                
                # Get price from objPrice first, then fall back to HTML input
                price_str = group_prices.get(modifier_id)
                if price_str is None:
                    # Read price from HTML input element
                    price_input = await page.query_selector(f'#price__{group_id}_{modifier_id}')
                    if price_input:
                        price_str = await price_input.get_attribute('value')
                    if not price_str:
                        price_str = "0.00"
                
                modifiers_data.append({
                    'v1_id': modifier_id,
                    'name': modifier_name,
                    'price_string': price_str,
                    'display_order': display_order,
                    'is_active': is_active  # True for checked, False for unchecked
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
# DATABASE OPERATIONS - ALL WITH AUTO-COMMIT FOR SAFETY
# =============================================================================

def insert_modifier_group(db: DatabaseConnection, restaurant_id: int, 
                          group_data: Dict, lang: str, 
                          logger: logging.Logger) -> Optional[int]:
    """Insert a modifier group and return its ID. Auto-commits for safety."""
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
    """Insert a modifier and return its ID. Uses source_id (V1 ID) for uniqueness. Auto-commits."""
    try:
        # Use source_id for uniqueness - this handles duplicate modifier names correctly
        insert_query = """
            INSERT INTO menuca_v3.modifiers 
            (modifier_group_id, name, source_id, display_order, is_active, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, NOW(), NOW())
            ON CONFLICT (modifier_group_id, source_id) DO UPDATE SET
                name = EXCLUDED.name,
                display_order = EXCLUDED.display_order,
                is_active = EXCLUDED.is_active,
                updated_at = NOW()
            RETURNING id
        """
        result = db.execute_with_retry(
            insert_query,
            (modifier_group_id, modifier_data['name'], modifier_data['v1_id'],
             modifier_data['display_order'], modifier_data['is_active']),
            fetch=True
        )
        
        if result:
            modifier_id = result[0][0]
            logger.debug(f"Upserted modifier: {modifier_data['name']} (V1 ID: {modifier_data['v1_id']}, DB ID: {modifier_id})")
            return modifier_id
        
        return None
        
    except Exception as e:
        logger.error(f"Error upserting modifier: {e}")
        raise

def insert_modifier_prices(db: DatabaseConnection, modifier_id: int, 
                           price_string: str, lang: str, 
                           logger: logging.Logger) -> int:
    """Insert modifier prices and return count inserted. Auto-commits each price."""
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
