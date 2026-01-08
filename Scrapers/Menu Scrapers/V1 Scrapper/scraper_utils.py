"""
Shared utilities for V1 CRM scrapers.

Provides:
- Logging setup
- Database connection and operations
- CRM login and navigation
- Modifier group extraction and insertion
"""

import os
import sys
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any

import psycopg2
from psycopg2.extras import RealDictCursor

# Add parent directory to path to import config
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import (
    DB_CONNECTION_STRING,
    SCHEMA
)

# V1 CRM Configuration (different from V2 CRM in main config)
CRM_BASE_URL = "https://menuadmin.menu.ca"
CRM_USERNAME = "santiago@worklocal.ca"
CRM_PASSWORD = "542sfgsgeerg4%$"

# Re-export for convenience
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_crm',
    'extract_modifier_groups',
    'insert_modifier_group',
    'insert_modifier',
    'insert_modifier_prices',
    'get_processed_restaurants',
    'restaurant_has_modifiers',
    'CRM_BASE_URL',
    'DB_CONNECTION_STRING',
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
    
    log_dir.mkdir(exist_ok=True)
    
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
# CRM Functions
# =============================================================================

async def login_to_crm(page, logger) -> bool:
    """
    Login to V1 CRM (menuadmin.menu.ca).
    Returns True if successful, False otherwise.
    """
    try:
        login_url = f"{CRM_BASE_URL}/?p=login"
        logger.info(f"Navigating to V1 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in (look for logout link or dashboard elements)
        content = await page.content()
        if "logout" in content.lower() or "p=restaurants" in content.lower():
            logger.info("Already logged in to V1 CRM")
            return True
        
        # Try different username field selectors for V1 CRM
        username_selectors = [
            'input[name="username"]',
            'input[name="user"]', 
            'input[name="email"]',
            'input[id="username"]',
            'input[type="text"]:first-of-type'
        ]
        
        username_filled = False
        for selector in username_selectors:
            try:
                elem = await page.query_selector(selector)
                if elem:
                    await elem.fill(CRM_USERNAME)
                    username_filled = True
                    logger.debug(f"Filled username using: {selector}")
                    break
            except:
                continue
        
        if not username_filled:
            logger.error("Could not find username field")
            return False
        
        # Try different password field selectors
        password_selectors = [
            'input[name="password"]',
            'input[name="pass"]',
            'input[type="password"]'
        ]
        
        password_filled = False
        for selector in password_selectors:
            try:
                elem = await page.query_selector(selector)
                if elem:
                    await elem.fill(CRM_PASSWORD)
                    password_filled = True
                    logger.debug(f"Filled password using: {selector}")
                    break
            except:
                continue
        
        if not password_filled:
            logger.error("Could not find password field")
            return False
        
        # Click login button
        submit_selectors = [
            'button[type="submit"]',
            'input[type="submit"]',
            'button:has-text("Login")',
            'button:has-text("Sign in")',
            '.btn-login',
            '#login-btn'
        ]
        
        for selector in submit_selectors:
            try:
                elem = await page.query_selector(selector)
                if elem:
                    await elem.click()
                    logger.debug(f"Clicked submit using: {selector}")
                    break
            except:
                continue
        
        # Wait for navigation
        await page.wait_for_load_state('networkidle', timeout=15000)
        await page.wait_for_timeout(2000)  # Extra wait for JS
        
        # Verify login success - check if we're on a logged-in page
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


async def extract_modifier_groups(page, restaurant_v1_id: int, 
                                   language: str, logger) -> List[Dict]:
    """
    Extract all modifier groups from a restaurant's modifier groups page.
    
    V1 CRM Structure:
    - Modifier groups are listed as links inside paragraphs
    - Clicking a link expands a form below with:
      - Group name textbox
      - Category dropdown
      - List of modifiers (checkbox + name text + price textbox)
      - Delete link containing group ID (&group=XXXX)
    
    Args:
        page: Playwright page object
        restaurant_v1_id: V1 restaurant ID
        language: 'english' or 'french'
        logger: Logger instance
    
    Returns:
        List of modifier group dicts with 'name', 'v1_id', 'category', 'modifiers'
    """
    modifier_groups = []
    
    try:
        # Navigate to modifier groups page
        lang_param = "en" if language == "english" else "fr"
        url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={restaurant_v1_id}&load=ingredientGroups&showLang={lang_param}"
        
        logger.debug(f"Navigating to: {url}")
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Find all modifier group links (they're inside paragraphs, excluding "Add a group")
        group_links = await page.query_selector_all('p > a[href="#"]')
        
        logger.debug(f"Found {len(group_links)} modifier group links")
        
        for i, link in enumerate(group_links):
            try:
                group_name = await link.inner_text()
                group_name = group_name.strip()
                
                # Skip "Add a group" link
                if "add" in group_name.lower() and "group" in group_name.lower():
                    continue
                
                logger.debug(f"  [{i+1}] Processing group: {group_name}")
                
                # Click the link to expand the group details
                await link.click()
                await page.wait_for_timeout(500)  # Wait for expansion
                
                # Extract group data from the form that appears AFTER this link
                # The form is the next sibling of the link's parent paragraph
                group_data = await extract_group_after_link(page, link, group_name, logger)
                
                if group_data:
                    modifier_groups.append(group_data)
                    logger.debug(f"    Extracted: {len(group_data.get('modifiers', []))} modifiers")
                
            except Exception as e:
                logger.warning(f"Error extracting group '{group_name}': {e}")
                continue
        
        logger.info(f"Extracted {len(modifier_groups)} modifier groups")
        
    except Exception as e:
        logger.error(f"Error extracting modifier groups: {e}")
    
    return modifier_groups


async def extract_group_after_link(page, link_element, expected_name: str, logger) -> Optional[Dict]:
    """
    Extract modifier group data from the form that appears RIGHT AFTER the clicked link.
    
    The page structure after clicking a group link:
    - paragraph > link (the clicked group name)
    - generic/form (the expanded form containing modifiers)
    
    Multiple forms can be expanded at once, so we need to find the one
    that belongs to THIS link, not just any form on the page.
    """
    try:
        import re
        
        # Use JavaScript to find the form that is the next sibling of this link's parent
        group_data = await page.evaluate('''(linkElement) => {
            // Get the parent paragraph of the link
            const paragraph = linkElement.closest('p');
            if (!paragraph) return null;
            
            // Find the next sibling that is the form container
            let nextSibling = paragraph.nextElementSibling;
            
            // The form should be right after the paragraph
            // It could be a div, form, or other element containing the modifier list
            if (!nextSibling) return null;
            
            // Check if this is a form container (has delete link, list of modifiers)
            const deleteLink = nextSibling.querySelector('a[href*="action=delete&group="]');
            if (!deleteLink) return null;
            
            // Extract V1 group ID from delete link
            const href = deleteLink.getAttribute('href') || '';
            const match = href.match(/group=(\\d+)/);
            const v1_id = match ? match[1] : null;
            
            // Get category from select dropdown
            const select = nextSibling.querySelector('select');
            let category = null;
            if (select && select.selectedIndex > 0) {
                category = select.options[select.selectedIndex].text;
            }
            
            // Extract modifiers from the list
            const list = nextSibling.querySelector('ul, ol');
            const modifiers = [];
            
            if (list) {
                const items = list.querySelectorAll('li');
                for (const item of items) {
                    const checkbox = item.querySelector('input[type="checkbox"]');
                    if (!checkbox) continue;
                    
                    // Get modifier name from label
                    const label = item.querySelector('label');
                    let name = label ? label.textContent.trim() : '';
                    
                    // Fallback: get from text nodes
                    if (!name) {
                        for (const child of item.childNodes) {
                            if (child.nodeType === Node.TEXT_NODE) {
                                name += child.textContent;
                            }
                        }
                        name = name.trim();
                    }
                    
                    // Get price from textbox
                    const priceInput = item.querySelector('input[type="text"]');
                    const price = priceInput ? priceInput.value : '0';
                    
                    if (name) {
                        modifiers.push({
                            name: name,
                            price_string: price,
                            v1_id: checkbox.id || checkbox.value || null
                        });
                    }
                }
            }
            
            return {
                v1_id: v1_id,
                category: category,
                modifiers: modifiers
            };
        }''', link_element)
        
        if group_data:
            group_data['name'] = expected_name
            return group_data
        else:
            logger.debug(f"Could not extract data for group: {expected_name}")
            return None
        
    except Exception as e:
        logger.debug(f"Error in extract_group_after_link: {e}")
        return None


async def extract_expanded_group(page, expected_name: str, logger) -> Optional[Dict]:
    """
    Extract data from an expanded modifier group form.
    
    The expanded form structure (after clicking a group link):
    - paragraph > link (the clicked group name)
    - generic (the expanded form container) containing:
      - textbox with group name
      - combobox for category
      - combobox for course
      - link "Check All"
      - list with modifier items (checkbox + text + price textbox)
      - button "Submit"
      - link "Delete" with V1 group ID
    """
    try:
        import re
        
        # Find the Delete link to get the V1 group ID
        delete_link = await page.query_selector('a[href*="action=delete&group="]')
        
        v1_id = None
        if delete_link:
            href = await delete_link.get_attribute('href')
            if href:
                match = re.search(r'group=(\d+)', href)
                if match:
                    v1_id = match.group(1)
        
        if not v1_id:
            logger.debug(f"Could not find V1 group ID for: {expected_name}")
        
        # Find category from the visible select dropdown
        # The expanded form has a select with category options
        category = None
        category_options = [
            "Custom Ingredients", "Drinks", "Dressings", "Extras", 
            "Bread / Crust", "Sauces", "Side Dishes"
        ]
        
        # Use JavaScript to find the category from the parent container of Delete link
        category = await page.evaluate('''() => {
            const deleteLink = document.querySelector('a[href*="action=delete&group="]');
            if (!deleteLink) return null;
            const container = deleteLink.parentElement;
            if (!container) return null;
            const select = container.querySelector('select');
            if (!select) return null;
            const selected = select.options[select.selectedIndex];
            return selected ? selected.text : null;
        }''')
        
        if category and category.strip() not in category_options:
            category = None
        
        # Extract modifiers using JavaScript to navigate the DOM correctly
        modifiers_data = await page.evaluate('''() => {
            const deleteLink = document.querySelector('a[href*="action=delete&group="]');
            if (!deleteLink) return [];
            
            const container = deleteLink.parentElement;
            if (!container) return [];
            
            const list = container.querySelector('ul, ol');
            if (!list) return [];
            
            const modifiers = [];
            const items = list.querySelectorAll('li');
            
            for (const item of items) {
                const checkbox = item.querySelector('input[type="checkbox"]');
                if (!checkbox) continue;
                
                // Get modifier name from label element (not text node)
                const label = item.querySelector('label');
                let name = label ? label.textContent.trim() : "";
                
                // Fallback: try text nodes if no label
                if (!name) {
                    for (const child of item.childNodes) {
                        if (child.nodeType === Node.TEXT_NODE) {
                            name += child.textContent;
                        }
                    }
                    name = name.trim();
                }
                
                // Get price from textbox
                const priceInput = item.querySelector('input[type="text"]');
                const price = priceInput ? priceInput.value : "0";
                
                if (name) {
                    modifiers.push({
                        name: name,
                        price_string: price,
                        v1_id: checkbox.id || checkbox.value || null
                    });
                }
            }
            
            return modifiers;
        }''')
        
        modifiers = modifiers_data if modifiers_data else []
        
        if not modifiers:
            logger.debug(f"No modifiers found in expanded form for: {expected_name}")
        
        return {
            'v1_id': v1_id,
            'name': expected_name,
            'category': category.strip() if category else None,
            'modifiers': modifiers
        }
        
    except Exception as e:
        logger.debug(f"Error in extract_expanded_group: {e}")
        return None


async def extract_single_group(page, elem, logger) -> Optional[Dict]:
    """Extract data from a single modifier group element (legacy fallback)."""
    try:
        # Get group ID
        group_id = await elem.get_attribute('data-group-id') or await elem.get_attribute('id')
        if group_id and group_id.startswith('group_'):
            group_id = group_id.replace('group_', '')
        
        # Get group name
        name_elem = await elem.query_selector('.group-name, .name, h3, h4')
        name = await name_elem.inner_text() if name_elem else f"Group_{group_id}"
        
        # Get category
        category_elem = await elem.query_selector('.category, [data-category]')
        category = await category_elem.inner_text() if category_elem else None
        
        # Extract modifiers within this group
        modifiers = await extract_modifiers_from_group(page, elem, logger)
        
        return {
            'v1_id': group_id,
            'name': name.strip(),
            'category': category.strip() if category else None,
            'modifiers': modifiers
        }
    except Exception as e:
        logger.debug(f"Error in extract_single_group: {e}")
        return None


async def extract_groups_from_table(page, logger) -> List[Dict]:
    """Extract modifier groups from a table structure (legacy fallback)."""
    groups = []
    
    try:
        # Look for table rows with modifier group data
        rows = await page.query_selector_all('table tr[data-id], table tbody tr')
        
        for row in rows:
            try:
                cells = await row.query_selector_all('td')
                if len(cells) >= 2:
                    v1_id = await row.get_attribute('data-id')
                    name = await cells[0].inner_text()
                    
                    if v1_id and name:
                        groups.append({
                            'v1_id': v1_id,
                            'name': name.strip(),
                            'category': None,
                            'modifiers': []  # Will be populated separately
                        })
            except:
                continue
    
    except Exception as e:
        logger.debug(f"Error extracting from table: {e}")
    
    return groups


async def extract_modifiers_from_group(page, group_elem, logger) -> List[Dict]:
    """Extract individual modifiers from a group element (legacy fallback)."""
    modifiers = []
    
    try:
        modifier_elems = await group_elem.query_selector_all('.modifier, .ingredient, tr[data-modifier-id]')
        
        for mod_elem in modifier_elems:
            try:
                mod_id = await mod_elem.get_attribute('data-modifier-id') or await mod_elem.get_attribute('data-id')
                name_elem = await mod_elem.query_selector('.name, td:first-child')
                name = await name_elem.inner_text() if name_elem else f"Modifier_{mod_id}"
                
                price_elem = await mod_elem.query_selector('.price, td.price, input[name*="price"]')
                price_string = await price_elem.get_attribute('value') if price_elem else "0"
                if not price_string:
                    price_string = await price_elem.inner_text() if price_elem else "0"
                
                modifiers.append({
                    'v1_id': mod_id,
                    'name': name.strip(),
                    'price_string': price_string.strip() if price_string else "0"
                })
            except:
                continue
    
    except Exception as e:
        logger.debug(f"Error extracting modifiers: {e}")
    
    return modifiers


# =============================================================================
# Database Insert Functions
# =============================================================================

def insert_modifier_group(db: DatabaseConnection, restaurant_v3_id: int,
                          group_data: Dict, language: str, logger) -> Optional[int]:
    """
    Insert or update a modifier group and return its ID.
    First checks if group exists, then inserts or updates.
    """
    try:
        group_name = group_data['name']
        category = group_data.get('category')
        v1_id = str(group_data.get('v1_id', '')) if group_data.get('v1_id') else None
        
        # Check if group already exists
        check_query = f"""
            SELECT id FROM {db.schema}.modifier_groups 
            WHERE restaurant_id = %s AND name = %s AND deleted_at IS NULL
        """
        result = db.execute_with_retry(check_query, (restaurant_v3_id, group_name), fetch=True)
        
        if result:
            # Update existing group
            group_id = result[0][0]
            update_query = f"""
                UPDATE {db.schema}.modifier_groups 
                SET category = %s, source_system = %s, updated_at = NOW()
                WHERE id = %s
            """
            db.execute_with_retry(update_query, (category, v1_id, group_id))
            logger.debug(f"Updated modifier group: {group_name} (ID: {group_id})")
            return group_id
        else:
            # Insert new group
            insert_query = f"""
                INSERT INTO {db.schema}.modifier_groups 
                (restaurant_id, name, category, source_system, created_at, updated_at)
                VALUES (%s, %s, %s, %s, NOW(), NOW())
                RETURNING id
            """
            result = db.execute_with_retry(
                insert_query, 
                (restaurant_v3_id, group_name, category, v1_id),
                fetch=True
            )
            
            if result:
                group_id = result[0][0]
                logger.debug(f"Inserted modifier group: {group_name} (ID: {group_id})")
                return group_id
        
        return None
        
    except Exception as e:
        logger.error(f"Error inserting modifier group: {e}")
        return None


def insert_modifier(db: DatabaseConnection, modifier_group_id: int,
                    modifier_data: Dict, logger) -> Optional[int]:
    """
    Insert or update a modifier and return its ID.
    First checks if modifier exists, then inserts or updates.
    """
    try:
        modifier_name = modifier_data['name']
        display_order = modifier_data.get('display_order', 0)
        
        # Check if modifier already exists
        check_query = f"""
            SELECT id FROM {db.schema}.modifiers 
            WHERE modifier_group_id = %s AND name = %s AND deleted_at IS NULL
        """
        result = db.execute_with_retry(check_query, (modifier_group_id, modifier_name), fetch=True)
        
        if result:
            # Update existing modifier
            modifier_id = result[0][0]
            update_query = f"""
                UPDATE {db.schema}.modifiers 
                SET display_order = %s, updated_at = NOW()
                WHERE id = %s
            """
            db.execute_with_retry(update_query, (display_order, modifier_id))
            logger.debug(f"Updated modifier: {modifier_name} (ID: {modifier_id})")
            return modifier_id
        else:
            # Insert new modifier
            insert_query = f"""
                INSERT INTO {db.schema}.modifiers 
                (modifier_group_id, name, display_order, created_at, updated_at)
                VALUES (%s, %s, %s, NOW(), NOW())
                RETURNING id
            """
            result = db.execute_with_retry(
                insert_query,
                (modifier_group_id, modifier_name, display_order),
                fetch=True
            )
            
            if result:
                modifier_id = result[0][0]
                logger.debug(f"Inserted modifier: {modifier_name} (ID: {modifier_id})")
                return modifier_id
        
        return None
        
    except Exception as e:
        logger.error(f"Error inserting modifier: {e}")
        return None


def insert_modifier_prices(db: DatabaseConnection, modifier_id: int,
                           price_string: str, language: str, logger) -> int:
    """
    Insert modifier prices from a price string.
    Returns count of prices inserted.
    
    Price string can be:
    - Single price: "5.99"
    - Multiple sizes: "5.99,7.99,9.99"
    - Size-labeled: "Small:5.99,Medium:7.99,Large:9.99"
    """
    prices_inserted = 0
    
    try:
        # Parse price string
        prices = parse_price_string(price_string, language)
        
        for i, (size_variant, price) in enumerate(prices):
            try:
                # Check if price already exists
                check_query = f"""
                    SELECT id FROM {db.schema}.modifier_prices 
                    WHERE modifier_id = %s AND size_variant = %s
                """
                result = db.execute_with_retry(check_query, (modifier_id, size_variant), fetch=True)
                
                if result:
                    # Update existing price
                    update_query = f"""
                        UPDATE {db.schema}.modifier_prices 
                        SET price = %s, updated_at = NOW()
                        WHERE id = %s
                    """
                    db.execute_with_retry(update_query, (price, result[0][0]))
                else:
                    # Insert new price
                    insert_query = f"""
                        INSERT INTO {db.schema}.modifier_prices 
                        (modifier_id, size_variant, price, display_order, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, NOW(), NOW())
                    """
                    db.execute_with_retry(insert_query, (modifier_id, size_variant, price, i))
                
                prices_inserted += 1
            except Exception as e:
                logger.warning(f"Error inserting price {size_variant}={price}: {e}")
        
    except Exception as e:
        logger.error(f"Error parsing/inserting prices: {e}")
    
    return prices_inserted


def parse_price_string(price_string: str, language: str) -> List[tuple]:
    """
    Parse price string into list of (size_variant, price) tuples.
    """
    if not price_string or price_string.strip() in ('', '0', 'NULL'):
        return [('Standard', 0.0)]
    
    # Size names based on language
    size_names = {
        'english': ['Small', 'Medium', 'Large', 'X-Large'],
        'french': ['Petit', 'Moyen', 'Grand', 'Très Grand']
    }
    sizes = size_names.get(language, size_names['english'])
    
    prices = []
    parts = price_string.replace(' ', '').split(',')
    
    for i, part in enumerate(parts):
        try:
            if ':' in part:
                # Size:Price format
                size, price = part.split(':', 1)
                prices.append((size.strip(), float(price)))
            else:
                # Just price, use default size names
                size = sizes[i] if i < len(sizes) else f"Size_{i+1}"
                price = float(part) if part else 0.0
                prices.append((size, price))
        except (ValueError, IndexError):
            continue
    
    if not prices:
        prices = [('Standard', 0.0)]
    
    return prices


# =============================================================================
# Query Functions
# =============================================================================

def get_processed_restaurants(db: DatabaseConnection, logger) -> set:
    """Get set of V3 restaurant IDs that already have modifier groups."""
    try:
        query = f"""
            SELECT DISTINCT restaurant_id 
            FROM {db.schema}.modifier_groups 
            WHERE deleted_at IS NULL
        """
        results = db.execute_with_retry(query, fetch=True)
        processed = set(row[0] for row in results) if results else set()
        logger.debug(f"Found {len(processed)} restaurants with existing modifiers")
        return processed
    except Exception as e:
        logger.error(f"Error getting processed restaurants: {e}")
        return set()


def restaurant_has_modifiers(db: DatabaseConnection, restaurant_v3_id: int, logger) -> bool:
    """Check if a restaurant already has modifier groups."""
    try:
        query = f"""
            SELECT COUNT(*) FROM {db.schema}.modifier_groups 
            WHERE restaurant_id = %s AND deleted_at IS NULL
        """
        results = db.execute_with_retry(query, (restaurant_v3_id,), fetch=True)
        return results[0][0] > 0 if results else False
    except Exception as e:
        logger.error(f"Error checking restaurant modifiers: {e}")
        return False

