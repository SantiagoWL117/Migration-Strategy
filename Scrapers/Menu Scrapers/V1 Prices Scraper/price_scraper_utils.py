"""
Utilities for V1 Price Scraper.

Provides:
- Logging setup
- Database operations for dish prices
- Price parsing with size variant mapping
- Dish size variant ID lookup
"""

import os
import sys
import logging
import re
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Tuple, Any

import psycopg2
from psycopg2.extras import RealDictCursor

# Add parent directory to path to import config
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import (
    DB_CONNECTION_STRING,
    SCHEMA
)

# V1 CRM Configuration - MUST use menuadmin.menu.ca, not aggregator-admin
# Override any config that might point to V2
CRM_BASE_URL = "https://menuadmin.menu.ca"
CRM_USERNAME = "santiago@worklocal.ca"
CRM_PASSWORD = "542sfgsgeerg4%$"

__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_crm',
    'get_dishes_without_prices',
    'insert_dish_price',
    'parse_price_quantity_strings',
    'get_dish_size_variant_id',
    'CRM_BASE_URL',
    'CRM_USERNAME',
    'CRM_PASSWORD',
]


# =============================================================================
# Logging Setup
# =============================================================================

def setup_logging(name: str, log_dir: str = None) -> logging.Logger:
    """Set up logging with both file and console handlers."""
    if log_dir is None:
        log_dir = Path(__file__).parent / "logs"
    else:
        log_dir = Path(log_dir)
    
    log_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"{name}_{timestamp}.log"
    
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
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
        self._size_variant_cache = {}  # Cache for dish_size_variant lookups
    
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
                self.conn = None
                if attempt == max_retries - 1:
                    raise
            except Exception as e:
                self.logger.error(f"Query error: {e}")
                raise
        return None
    
    def fetch_dict(self, query: str, params: tuple = None) -> List[Dict]:
        """Execute query and return list of dicts."""
        try:
            self.ensure_connected()
            with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, params)
                return [dict(row) for row in cur.fetchall()]
        except Exception as e:
            self.logger.error(f"Query error: {e}")
            return []


# =============================================================================
# CRM Functions
# =============================================================================

async def login_to_crm(page, logger) -> bool:
    """Login to V1 CRM (menuadmin.menu.ca)."""
    try:
        login_url = f"{CRM_BASE_URL}/?p=login"
        logger.info(f"Navigating to V1 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in
        content = await page.content()
        if "logout" in content.lower() or "p=restaurants" in content.lower():
            logger.info("Already logged in to V1 CRM")
            return True
        
        # Fill username
        username_selectors = [
            'input[name="username"]',
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
        
        # Fill password
        password_elem = await page.query_selector('input[name="password"], input[type="password"]')
        if password_elem:
            await password_elem.fill(CRM_PASSWORD)
            logger.debug("Filled password")
        else:
            logger.error("Could not find password field")
            return False
        
        # Click login button
        submit_elem = await page.query_selector('input[type="submit"], button[type="submit"]')
        if submit_elem:
            await submit_elem.click()
            logger.debug("Clicked submit button")
        
        await page.wait_for_load_state('networkidle', timeout=15000)
        await page.wait_for_timeout(2000)
        
        # Verify login
        content = await page.content()
        if "error" in content.lower() and "invalid" in content.lower():
            logger.error("Login failed - invalid credentials")
            return False
        
        logger.info("V1 CRM login successful")
        return True
        
    except Exception as e:
        logger.error(f"V1 CRM login error: {e}")
        return False


# =============================================================================
# Database Query Functions
# =============================================================================

def get_dishes_without_prices(db: DatabaseConnection, restaurant_ids: List[int] = None, 
                               logger: logging.Logger = None) -> List[Dict]:
    """
    Get all dishes that have no prices assigned.
    
    Returns list of dicts with:
    - dish_id, dish_name, source_id, is_combo, is_active
    - restaurant_id, restaurant_name, legacy_v1_id
    - course_name
    """
    restaurant_filter = ""
    if restaurant_ids:
        ids_str = ",".join(str(id) for id in restaurant_ids)
        restaurant_filter = f"AND d.restaurant_id IN ({ids_str})"
    
    query = f"""
        SELECT 
            d.id as dish_id,
            d.name as dish_name,
            d.source_id,
            d.is_combo,
            d.is_active,
            r.id as restaurant_id,
            r.name as restaurant_name,
            r.legacy_v1_id,
            c.name as course_name
        FROM {db.schema}.dishes d
        JOIN {db.schema}.restaurants r ON r.id = d.restaurant_id
        JOIN {db.schema}.courses c ON c.id = d.course_id
        LEFT JOIN {db.schema}.dish_prices dp ON dp.dish_id = d.id AND dp.deleted_at IS NULL
        WHERE d.deleted_at IS NULL
          AND r.legacy_v1_id IS NOT NULL
          AND d.source_id IS NOT NULL
          AND dp.id IS NULL
          {restaurant_filter}
        ORDER BY r.id, c.display_order, d.display_order
    """
    
    return db.fetch_dict(query)


def get_dish_size_variant_id(db: DatabaseConnection, size_name: str, 
                              logger: logging.Logger = None) -> Optional[int]:
    """
    Look up dish_size_variant_id by size name.
    Returns None if not found.
    
    Matches on code, name_en, or name_fr (case-insensitive).
    """
    # Check cache first
    cache_key = size_name.lower().strip()
    if cache_key in db._size_variant_cache:
        return db._size_variant_cache[cache_key]
    
    # Normalize common variations
    size_mappings = {
        # English sizes
        'small': 'small',
        'sm': 'small',
        's': 'small',
        'medium': 'medium',
        'med': 'medium',
        'm': 'medium',
        'large': 'large',
        'lg': 'large',
        'l': 'large',
        'x-large': 'x-large',
        'xlarge': 'x-large',
        'xl': 'x-large',
        'extra large': 'x-large',
        'extra-large': 'x-large',
        # French sizes
        'petit': 'small',
        'petite': 'small',
        'moyen': 'medium',
        'moyenne': 'medium',
        'grand': 'large',
        'grande': 'large',
        'très grand': 'x-large',
        'x-grande': 'x-large',
        # Standard
        'standard': 'standard',
        '': 'standard',
        'regular': 'standard',
        'one size': 'standard',
    }
    
    normalized = size_mappings.get(cache_key, cache_key)
    
    query = f"""
        SELECT id FROM {db.schema}.dish_size_variants
        WHERE LOWER(code) = %s 
           OR LOWER(name_en) = %s 
           OR LOWER(name_fr) = %s
        LIMIT 1
    """
    
    try:
        result = db.execute_with_retry(query, (normalized, cache_key, cache_key), fetch=True)
        variant_id = result[0][0] if result else None
        
        # Cache the result
        db._size_variant_cache[cache_key] = variant_id
        
        return variant_id
    except Exception as e:
        if logger:
            logger.warning(f"Error looking up dish_size_variant for '{size_name}': {e}")
        return None


def insert_dish_price(db: DatabaseConnection, dish_id: int, 
                      size_variant: str, price: float, display_order: int,
                      dish_size_variant_id: int = None,
                      logger: logging.Logger = None) -> Optional[int]:
    """
    Insert a dish price record.
    
    Returns the inserted price ID, or None on failure.
    """
    try:
        # Check if price already exists for this dish and size
        check_query = f"""
            SELECT id FROM {db.schema}.dish_prices 
            WHERE dish_id = %s AND size_variant = %s AND deleted_at IS NULL
        """
        existing = db.execute_with_retry(check_query, (dish_id, size_variant), fetch=True)
        
        if existing:
            # Update existing price
            price_id = existing[0][0]
            update_query = f"""
                UPDATE {db.schema}.dish_prices 
                SET price = %s, 
                    display_order = %s,
                    dish_size_variant_id = %s,
                    updated_at = NOW()
                WHERE id = %s
            """
            db.execute_with_retry(update_query, (price, display_order, dish_size_variant_id, price_id))
            if logger:
                logger.debug(f"Updated dish_price ID {price_id}: {size_variant} = ${price}")
            return price_id
        else:
            # Insert new price
            insert_query = f"""
                INSERT INTO {db.schema}.dish_prices 
                (dish_id, size_variant, price, display_order, dish_size_variant_id, 
                 is_active, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, true, NOW(), NOW())
                RETURNING id
            """
            result = db.execute_with_retry(
                insert_query, 
                (dish_id, size_variant, price, display_order, dish_size_variant_id),
                fetch=True
            )
            
            if result:
                price_id = result[0][0]
                if logger:
                    logger.debug(f"Inserted dish_price ID {price_id}: {size_variant} = ${price}")
                return price_id
        
        return None
        
    except Exception as e:
        if logger:
            logger.error(f"Error inserting dish price for dish {dish_id}: {e}")
        return None


# =============================================================================
# Price Parsing Functions
# =============================================================================

def parse_price_quantity_strings(price_str: str, quantity_str: str, 
                                  language: str = 'english') -> List[Dict]:
    """
    Parse price and quantity strings from V1 CRM.
    
    Args:
        price_str: Comma-separated prices, e.g. "15.95" or "16.50,22.50,27.50"
        quantity_str: Comma-separated sizes, e.g. "" or "2 x Small,2 x Medium,2 x Large"
        language: 'english' or 'french'
    
    Returns:
        List of dicts with 'size_variant', 'price', 'display_order'
    """
    results = []
    
    # Clean and split prices
    price_str = (price_str or '').strip()
    quantity_str = (quantity_str or '').strip()
    
    if not price_str:
        return results
    
    # Parse prices
    prices = []
    for p in price_str.split(','):
        p = p.strip()
        if p:
            try:
                # Handle formats like "$15.95" or "15.95"
                p = p.replace('$', '').replace(' ', '')
                prices.append(float(p))
            except ValueError:
                continue
    
    if not prices:
        return results
    
    # Parse quantities/sizes
    sizes = []
    if quantity_str:
        for q in quantity_str.split(','):
            q = q.strip()
            if q:
                # Clean up size names like "2 x Small" -> "Small"
                # or "Small (10")" -> "Small (10")"
                q = re.sub(r'^\d+\s*x\s*', '', q, flags=re.IGNORECASE)
                sizes.append(q)
    
    # Default size names if not specified
    default_sizes_en = ['Small', 'Medium', 'Large', 'X-Large', 'Size 5', 'Size 6', 'Size 7']
    default_sizes_fr = ['Petite', 'Moyenne', 'Grande', 'X-Grande', 'Taille 5', 'Taille 6', 'Taille 7']
    default_sizes = default_sizes_fr if language == 'french' else default_sizes_en
    
    # Match prices with sizes
    for i, price in enumerate(prices):
        if i < len(sizes):
            size_variant = sizes[i]
        elif len(prices) == 1:
            # Single price with no size = Standard
            size_variant = 'Standard'
        else:
            # Multiple prices but not enough size names
            size_variant = default_sizes[i] if i < len(default_sizes) else f'Size {i+1}'
        
        results.append({
            'size_variant': size_variant,
            'price': price,
            'display_order': i
        })
    
    return results


def normalize_size_variant(size_name: str) -> str:
    """
    Normalize a size variant name for consistency.
    
    Handles:
    - "2 x Small" -> "Small"
    - "small" -> "Small"
    - "Petit" -> "Small" (for French)
    """
    if not size_name:
        return 'Standard'
    
    # Remove quantity prefix
    size_name = re.sub(r'^\d+\s*x\s*', '', size_name, flags=re.IGNORECASE).strip()
    
    # Title case
    size_name = size_name.title()
    
    return size_name

