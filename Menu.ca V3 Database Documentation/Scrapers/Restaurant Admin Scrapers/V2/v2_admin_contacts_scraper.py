"""
V2 Admin Contacts Scraper

Scrapes restaurant admin contacts from V2 CRM (aggregator-admin.menu.ca) and stores them
in the menuca_v3.admin_users table with Supabase Auth integration.

Features:
- Login to V2 CRM using Playwright (email/password)
- Extract contacts from "Owner info" table widget
- Parse contact names into first_name/last_name
- Filter out test contacts (name or email containing "test")
- Handle edge cases (no contacts, duplicate emails, multiple contacts)
- Create Supabase Auth users and admin_users records
- Link admins to restaurants via admin_user_restaurants
"""

import os
import sys
import re
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor
from bs4 import BeautifulSoup

# Add parent directories to path to import config
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "Menu Scrapers"))
from config import (
    DB_CONNECTION_STRING,
    SCHEMA,
    SUPABASE_URL,
    SUPABASE_KEY
)

# =============================================================================
# V2 CRM Configuration (hardcoded)
# =============================================================================
CRM_V2_BASE_URL = "https://aggregator-admin.menu.ca/index.php"
CRM_V2_USERNAME = "santiago@worklocal.ca"
CRM_V2_PASSWORD = "WL2129925*"

# =============================================================================
# Constants
# =============================================================================
RESTAURANT_ADMIN_ROLE_ID = 2  # "Restaurant Admin" role


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
    
    def execute_returning(self, query: str, params: tuple = None) -> Any:
        """Execute query that returns a value (INSERT RETURNING, etc.)."""
        self.ensure_connected()
        with self.conn.cursor() as cur:
            cur.execute(query, params)
            result = cur.fetchone()
            return result[0] if result else None


# =============================================================================
# V2 CRM Login
# =============================================================================

async def login_to_v2_crm(page, logger) -> bool:
    """
    Login to V2 CRM (aggregator-admin.menu.ca).
    Uses email/password fields instead of username/password.
    Returns True if successful, False otherwise.
    """
    try:
        login_url = f"{CRM_V2_BASE_URL}/auth/index"
        logger.info(f"Navigating to V2 CRM: {login_url}")
        await page.goto(login_url, wait_until='networkidle', timeout=30000)
        
        # Check if already logged in
        content = await page.content()
        if "logout" in content.lower() or "/restaurants" in page.url.lower():
            logger.info("Already logged in to V2 CRM")
            return True
        
        # Fill email field
        email_elem = await page.query_selector('input[name="email"]')
        if email_elem:
            await email_elem.fill(CRM_V2_USERNAME)
            logger.debug("Filled email field")
        else:
            logger.error("Could not find email field")
            return False
        
        # Fill password field
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
        
        if "logout" in content.lower() or "/restaurants" in current_url.lower() or "/dashboard" in current_url.lower():
            logger.info("V2 CRM login successful")
            return True
        
        logger.warning(f"Login status unclear. Current URL: {current_url}")
        return True  # Assume success and continue
        
    except Exception as e:
        logger.error(f"V2 CRM login error: {e}")
        return False


# =============================================================================
# Contact Scraping
# =============================================================================

async def scrape_restaurant_contacts(page, v2_id: int, logger) -> List[Dict]:
    """
    Scrape contacts from a V2 restaurant's info page.
    
    V2 URL pattern: /restaurants/edit/{v2_id}/info
    
    Returns list of contact dicts with:
    - v2_user_id: User ID from edit link (e.g., /useredit/77)
    - email: Contact email (required for creating admin)
    - full_name: Original contact name
    - first_name: Parsed first name
    - last_name: Parsed last name  
    - phone: Contact phone
    """
    contacts = []
    
    try:
        # Navigate to restaurant info page
        url = f"{CRM_V2_BASE_URL}/restaurants/edit/{v2_id}/info"
        logger.debug(f"Navigating to: {url}")
        
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Get page HTML
        content = await page.content()
        soup = BeautifulSoup(content, 'html5lib')
        
        # Find the Owner info widget
        owner_widget = soup.find('div', id='owner-info')
        
        if not owner_widget:
            logger.warning(f"No Owner info widget found for V2 ID {v2_id}")
            return []
        
        # Find the table inside the widget
        table = owner_widget.find('table')
        
        if not table:
            logger.debug(f"No table in Owner info widget for V2 ID {v2_id}")
            return []
        
        # Find all rows in tfoot (existing contacts)
        tfoot = table.find('tfoot')
        
        if not tfoot:
            logger.debug(f"No tfoot in Owner info table for V2 ID {v2_id}")
            return []
        
        rows = tfoot.find_all('tr')
        
        if not rows:
            logger.debug(f"No contact rows for V2 ID {v2_id}")
            return []
        
        for row in rows:
            try:
                contact = parse_owner_row(row, logger)
                if contact:
                    # Filter out test contacts
                    if is_test_contact(contact, logger):
                        logger.debug(f"Skipping test contact: {contact.get('full_name', '')} / {contact.get('email', '')}")
                        continue
                    
                    if contact.get('email'):  # Only include contacts with email
                        contacts.append(contact)
            except Exception as e:
                logger.warning(f"Error parsing contact row: {e}")
                continue
        
        logger.debug(f"Found {len(contacts)} valid contacts for V2 ID {v2_id}")
        
    except Exception as e:
        logger.error(f"Error scraping contacts for V2 ID {v2_id}: {e}")
    
    return contacts


def parse_owner_row(row, logger) -> Optional[Dict]:
    """
    Parse a single table row from the Owner info table.
    
    HTML structure:
    <tr>
        <td><a href=".../useredit/77">...</a></td>  <!-- Edit link with user ID -->
        <td>Mohammed Amer</td>                      <!-- Name -->
        <td>callamer@gmail.com</td>                 <!-- Email -->
        <td><a href="tel:(613) 612-1478">...</a></td>  <!-- Phone -->
        <td>Yes</td>                                <!-- Statements -->
    </tr>
    """
    try:
        cells = row.find_all('td')
        
        if len(cells) < 4:
            return None
        
        # Get V2 user ID from edit link (first cell)
        v2_user_id = None
        edit_link = cells[0].find('a', href=lambda x: x and 'useredit' in x)
        if edit_link:
            href = edit_link.get('href', '')
            match = re.search(r'useredit/(\d+)', href)
            if match:
                v2_user_id = match.group(1)
        
        # Get name (second cell)
        full_name = cells[1].get_text(strip=True) if len(cells) > 1 else ''
        
        # Get email (third cell)
        email = cells[2].get_text(strip=True) if len(cells) > 2 else ''
        
        # Get phone (fourth cell) - may be in an <a> tag
        phone = ''
        if len(cells) > 3:
            phone_cell = cells[3]
            phone_link = phone_cell.find('a', href=lambda x: x and 'tel:' in x if x else False)
            if phone_link:
                phone = phone_link.get_text(strip=True)
            else:
                phone = phone_cell.get_text(strip=True)
        
        # Parse first and last name
        first_name, last_name = split_name(full_name)
        
        return {
            'v2_user_id': v2_user_id,
            'email': email,
            'full_name': full_name,
            'first_name': first_name,
            'last_name': last_name,
            'phone': phone
        }
        
    except Exception as e:
        logger.warning(f"Error parsing owner row: {e}")
        return None


def is_test_contact(contact: Dict, logger) -> bool:
    """
    Check if contact should be skipped because it's a test contact.
    Returns True if "test" is in the name or email (case-insensitive).
    """
    full_name = contact.get('full_name', '').lower()
    email = contact.get('email', '').lower()
    
    if 'test' in full_name or 'test' in email:
        return True
    
    return False


def split_name(full_name: str) -> Tuple[str, str]:
    """
    Split a full name into first_name and last_name.
    
    Rules:
    - First word is first_name
    - Remaining words are last_name
    - If only one word, use it as first_name, leave last_name empty
    """
    if not full_name:
        return ('', '')
    
    # Clean up whitespace
    parts = full_name.strip().split()
    
    if len(parts) == 0:
        return ('', '')
    elif len(parts) == 1:
        return (parts[0], '')
    else:
        first_name = parts[0]
        last_name = ' '.join(parts[1:])
        return (first_name, last_name)


def filter_contacts_by_email(contacts: List[Dict], logger) -> List[Dict]:
    """
    Filter contacts to handle edge cases:
    
    1. Multiple contacts with same email -> take first one only
    2. Multiple contacts with different emails -> keep all
    3. Contacts without email -> skip
    
    Returns list of unique contacts by email.
    """
    seen_emails = set()
    unique_contacts = []
    
    for contact in contacts:
        email = contact.get('email', '').strip().lower()
        
        # Skip contacts without email
        if not email:
            logger.debug(f"Skipping contact without email: {contact.get('full_name', 'unknown')}")
            continue
        
        # Skip duplicate emails (take first one only)
        if email in seen_emails:
            logger.debug(f"Skipping duplicate email: {email}")
            continue
        
        seen_emails.add(email)
        unique_contacts.append(contact)
    
    return unique_contacts


# =============================================================================
# Supabase Auth User Creation
# =============================================================================

async def create_supabase_auth_user(email: str, logger) -> Optional[str]:
    """
    Create a Supabase Auth user for the given email.
    Returns the auth user's UUID if successful, or 'EXISTS' if user already exists
    but couldn't get their ID.
    """
    import aiohttp
    
    try:
        url = f"{SUPABASE_URL}/auth/v1/admin/users"
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'email': email,
            'email_confirm': True,
            'user_metadata': {
                'created_by': 'v2_admin_scraper',
                'created_at': datetime.now().isoformat()
            }
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=payload, headers=headers) as response:
                if response.status == 200 or response.status == 201:
                    data = await response.json()
                    auth_user_id = data.get('id')
                    logger.info(f"Created Supabase Auth user: {email} (ID: {auth_user_id})")
                    return auth_user_id
                elif response.status == 422:
                    # User already exists - try to get existing user
                    error_data = await response.json()
                    logger.debug(f"Auth user already exists: {error_data}")
                    
                    # Try to get existing user ID
                    existing_id = await get_existing_auth_user(email, logger)
                    if existing_id:
                        logger.info(f"Found existing Supabase Auth user: {email} (ID: {existing_id})")
                        return existing_id
                    else:
                        # User exists but we can't find their ID - return special marker
                        # so we can still create admin_user without auth_user_id
                        logger.info(f"Auth user exists for {email}, will create admin without auth link")
                        return 'EXISTS'
                else:
                    error_text = await response.text()
                    logger.error(f"Failed to create auth user for {email}: {response.status} - {error_text}")
                    return None
                    
    except Exception as e:
        logger.error(f"Error creating Supabase Auth user for {email}: {e}")
        return None


async def get_existing_auth_user(email: str, logger) -> Optional[str]:
    """
    Get existing Supabase Auth user by email.
    Returns the auth user's UUID if found.
    
    Uses email filter parameter for efficient lookup.
    """
    import aiohttp
    import urllib.parse
    
    try:
        # Use email filter for efficient lookup
        encoded_email = urllib.parse.quote(email)
        url = f"{SUPABASE_URL}/auth/v1/admin/users?filter=email%20eq%20{encoded_email}"
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        async with aiohttp.ClientSession() as session:
            # First try with filter
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    data = await response.json()
                    users = data.get('users', [])
                    
                    for user in users:
                        if user.get('email', '').lower() == email.lower():
                            logger.debug(f"Found existing auth user for {email}")
                            return user.get('id')
            
            # Fallback: paginated search through all users
            page = 1
            per_page = 100
            while True:
                list_url = f"{SUPABASE_URL}/auth/v1/admin/users?page={page}&per_page={per_page}"
                async with session.get(list_url, headers=headers) as response:
                    if response.status != 200:
                        break
                    
                    data = await response.json()
                    users = data.get('users', [])
                    
                    if not users:
                        break
                    
                    for user in users:
                        if user.get('email', '').lower() == email.lower():
                            logger.debug(f"Found existing auth user for {email}")
                            return user.get('id')
                    
                    # Check if we've fetched all users
                    if len(users) < per_page:
                        break
                    
                    page += 1
                    
                    # Safety limit
                    if page > 50:
                        break
        
        logger.debug(f"No existing auth user found for {email}")
        return None
                    
    except Exception as e:
        logger.error(f"Error getting existing auth user for {email}: {e}")
        return None


# =============================================================================
# Database Operations
# =============================================================================

def get_existing_admin_by_email(db: DatabaseConnection, email: str, logger) -> Optional[Dict]:
    """
    Check if an admin_user already exists with this email.
    Returns admin record if found, None otherwise.
    """
    try:
        query = f"""
            SELECT id, auth_user_id, email, first_name, last_name, phone, role_id, status
            FROM {db.schema}.admin_users 
            WHERE LOWER(email) = LOWER(%s) AND deleted_at IS NULL
        """
        result = db.execute_with_retry(query, (email,), fetch=True)
        
        if result:
            row = result[0]
            return {
                'id': row[0],
                'auth_user_id': row[1],
                'email': row[2],
                'first_name': row[3],
                'last_name': row[4],
                'phone': row[5],
                'role_id': row[6],
                'status': row[7]
            }
        return None
        
    except Exception as e:
        logger.error(f"Error checking existing admin for {email}: {e}")
        return None


def insert_admin_user(db: DatabaseConnection, contact: Dict, auth_user_id: str, 
                      logger) -> Optional[int]:
    """
    Insert a new admin_user record.
    Returns the new admin_user ID.
    
    Note: auth_user_id can be:
    - A valid UUID - link to Supabase Auth user
    - 'EXISTS' - Auth user exists but we don't have their ID (set to NULL)
    - None - No auth user (set to NULL)
    """
    try:
        # Handle 'EXISTS' marker - set to NULL
        actual_auth_id = None if auth_user_id in (None, 'EXISTS') else auth_user_id
        
        query = f"""
            INSERT INTO {db.schema}.admin_users 
            (auth_user_id, email, first_name, last_name, phone, role_id, status, 
             v2_admin_id, is_active, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, 'active', %s, true, NOW(), NOW())
            RETURNING id
        """
        
        params = (
            actual_auth_id,
            contact['email'].lower(),
            contact['first_name'],
            contact['last_name'],
            contact.get('phone', ''),
            RESTAURANT_ADMIN_ROLE_ID,
            contact.get('v2_user_id')
        )
        
        admin_id = db.execute_returning(query, params)
        logger.info(f"Created admin_user: {contact['email']} (ID: {admin_id})")
        return admin_id
        
    except Exception as e:
        logger.error(f"Error inserting admin_user for {contact['email']}: {e}")
        return None


def update_admin_user(db: DatabaseConnection, admin_id: int, contact: Dict, 
                      auth_user_id: str, logger) -> bool:
    """
    Update existing admin_user with new contact info.
    
    Note: auth_user_id can be 'EXISTS' which means we should not update the auth_user_id field.
    """
    try:
        # Handle 'EXISTS' marker - don't update auth_user_id in this case
        actual_auth_id = None if auth_user_id in (None, 'EXISTS') else auth_user_id
        
        query = f"""
            UPDATE {db.schema}.admin_users 
            SET first_name = %s,
                last_name = %s,
                phone = %s,
                auth_user_id = COALESCE(auth_user_id, %s),
                v2_admin_id = COALESCE(v2_admin_id, %s),
                status = 'active',
                updated_at = NOW()
            WHERE id = %s
        """
        
        params = (
            contact['first_name'],
            contact['last_name'],
            contact.get('phone', ''),
            actual_auth_id,
            contact.get('v2_user_id'),
            admin_id
        )
        
        db.execute_with_retry(query, params)
        logger.info(f"Updated admin_user ID {admin_id}: {contact['email']}")
        return True
        
    except Exception as e:
        logger.error(f"Error updating admin_user {admin_id}: {e}")
        return False


def check_restaurant_link_exists(db: DatabaseConnection, admin_id: int, 
                                  restaurant_id: int, logger) -> bool:
    """
    Check if admin_user_restaurants link already exists.
    """
    try:
        query = f"""
            SELECT 1 FROM {db.schema}.admin_user_restaurants 
            WHERE admin_user_id = %s AND restaurant_id = %s
        """
        result = db.execute_with_retry(query, (admin_id, restaurant_id), fetch=True)
        return bool(result)
        
    except Exception as e:
        logger.error(f"Error checking restaurant link: {e}")
        return False


def insert_restaurant_link(db: DatabaseConnection, admin_id: int, 
                           restaurant_id: int, logger) -> bool:
    """
    Create admin_user_restaurants link.
    """
    try:
        query = f"""
            INSERT INTO {db.schema}.admin_user_restaurants 
            (admin_user_id, restaurant_id, role, created_at)
            VALUES (%s, %s, 'staff', NOW())
            ON CONFLICT DO NOTHING
        """
        
        db.execute_with_retry(query, (admin_id, restaurant_id))
        logger.info(f"Linked admin {admin_id} to restaurant {restaurant_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error linking admin {admin_id} to restaurant {restaurant_id}: {e}")
        return False


# =============================================================================
# Exports
# =============================================================================
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_v2_crm',
    'scrape_restaurant_contacts',
    'parse_owner_row',
    'is_test_contact',
    'split_name',
    'filter_contacts_by_email',
    'create_supabase_auth_user',
    'get_existing_auth_user',
    'get_existing_admin_by_email',
    'insert_admin_user',
    'update_admin_user',
    'check_restaurant_link_exists',
    'insert_restaurant_link',
    'RESTAURANT_ADMIN_ROLE_ID',
]
