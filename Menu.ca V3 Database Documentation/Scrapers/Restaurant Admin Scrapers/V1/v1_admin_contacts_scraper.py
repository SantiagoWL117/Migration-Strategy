"""
V1 Admin Contacts Scraper

Scrapes restaurant admin contacts from V1 CRM (menuadmin.menu.ca) and stores them
in the menuca_v3.admin_users table with Supabase Auth integration.

Features:
- Login to V1 CRM using Playwright
- Extract contacts from Restaurant Contacts fieldset
- Parse contact names into first_name/last_name
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
# V1 CRM Configuration (hardcoded - different from V2 CRM)
# =============================================================================
CRM_V1_BASE_URL = "https://menuadmin.menu.ca"
CRM_V1_USERNAME = "santiago@worklocal.ca"
CRM_V1_PASSWORD = "542sfgsgeerg4%$"

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
    
    # Console handler - ensure UTF-8 encoding on Windows
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
# Contact Scraping
# =============================================================================

async def scrape_restaurant_contacts(page, v1_id: int, logger) -> List[Dict]:
    """
    Scrape contacts from a restaurant's account information page.
    
    Returns list of contact dicts with:
    - v1_contact_id: The contact ID from V1 (from hidden input)
    - email: Contact email (required for creating admin)
    - full_name: Original contact name
    - first_name: Parsed first name
    - last_name: Parsed last name  
    - phone: Contact phone
    - title: Owner/Manager
    """
    contacts = []
    
    try:
        # Navigate to account information page
        url = f"{CRM_V1_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=account_information&showLang=en"
        logger.debug(f"Navigating to: {url}")
        
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Get page HTML
        content = await page.content()
        soup = BeautifulSoup(content, 'html5lib')
        
        # Find the Restaurant Contacts fieldset
        fieldset = None
        for fs in soup.find_all('fieldset'):
            legend = fs.find('legend')
            if legend and 'Restaurant Contacts' in legend.get_text():
                fieldset = fs
                break
        
        if not fieldset:
            logger.warning(f"No Restaurant Contacts fieldset found for V1 ID {v1_id}")
            return []
        
        # Find all update contact forms (existing contacts)
        # These have action containing "action=updateContact"
        update_forms = fieldset.find_all('form', action=lambda x: x and 'action=updateContact' in x)
        
        if not update_forms:
            logger.debug(f"No existing contacts for V1 ID {v1_id}")
            return []
        
        for form in update_forms:
            try:
                contact = parse_contact_form(form, logger)
                if contact and contact.get('email'):  # Only include contacts with email
                    contacts.append(contact)
            except Exception as e:
                logger.warning(f"Error parsing contact form: {e}")
                continue
        
        logger.debug(f"Found {len(contacts)} contacts with emails for V1 ID {v1_id}")
        
    except Exception as e:
        logger.error(f"Error scraping contacts for V1 ID {v1_id}: {e}")
    
    return contacts


def parse_contact_form(form, logger) -> Optional[Dict]:
    """
    Parse a single contact form and extract contact details.
    
    HTML structure:
    <form action="...action=updateContact...">
        <ul class="account_information">
            <li><label for="contact_651">Contact Name</label><input ... value="Rupinder Pal"></li>
            <li><label for="title_651">Title</label><select ...>...</select></li>
            <li><label for="phone_651">Phone</label><input ... value="613-794-3444"></li>
            <li><label for="email_651">Email</label><input ... value="email@example.com"></li>
            <li>
                <input type="hidden" name="id" value="651">
                <input type="hidden" name="restaurant" value="781">
            </li>
        </ul>
    </form>
    """
    try:
        # Get V1 contact ID from hidden input
        id_input = form.find('input', {'name': 'id', 'type': 'hidden'})
        v1_contact_id = id_input['value'] if id_input else None
        
        # Get V1 restaurant ID from hidden input
        restaurant_input = form.find('input', {'name': 'restaurant', 'type': 'hidden'})
        v1_restaurant_id = restaurant_input['value'] if restaurant_input else None
        
        # Get email - look for input with id containing "email_"
        email_input = form.find('input', id=lambda x: x and x.startswith('email_'))
        email = email_input.get('value', '').strip() if email_input else ''
        
        # Get contact name
        contact_input = form.find('input', id=lambda x: x and x.startswith('contact_'))
        full_name = contact_input.get('value', '').strip() if contact_input else ''
        
        # Get phone
        phone_input = form.find('input', id=lambda x: x and x.startswith('phone_'))
        phone = phone_input.get('value', '').strip() if phone_input else ''
        
        # Get title (Owner/Manager)
        title_select = form.find('select', id=lambda x: x and x.startswith('title_'))
        title = None
        if title_select:
            selected_option = title_select.find('option', selected=True)
            title = selected_option.get('value', '') if selected_option else 'owner'
        
        # Parse first and last name
        first_name, last_name = split_name(full_name)
        
        return {
            'v1_contact_id': v1_contact_id,
            'v1_restaurant_id': v1_restaurant_id,
            'email': email,
            'full_name': full_name,
            'first_name': first_name,
            'last_name': last_name,
            'phone': phone,
            'title': title
        }
        
    except Exception as e:
        logger.warning(f"Error parsing contact form: {e}")
        return None


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
    Returns the auth user's UUID if successful.
    
    Note: This uses the Supabase Admin API via HTTP requests.
    The user will be created without a password - they'll need to use
    password reset to set one.
    """
    import aiohttp
    
    try:
        # Supabase Admin API endpoint
        url = f"{SUPABASE_URL}/auth/v1/admin/users"
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Create user with email only, no password
        # They can use password reset later
        payload = {
            'email': email,
            'email_confirm': True,  # Auto-confirm email
            'user_metadata': {
                'created_by': 'v1_admin_scraper',
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
                    logger.debug(f"Auth user may already exist: {error_data}")
                    return await get_existing_auth_user(email, logger)
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
    """
    try:
        query = f"""
            INSERT INTO {db.schema}.admin_users 
            (auth_user_id, email, first_name, last_name, phone, role_id, status, 
             v1_admin_id, is_active, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, 'active', %s, true, NOW(), NOW())
            RETURNING id
        """
        
        params = (
            auth_user_id,
            contact['email'].lower(),
            contact['first_name'],
            contact['last_name'],
            contact.get('phone', ''),
            RESTAURANT_ADMIN_ROLE_ID,
            contact.get('v1_contact_id')
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
    """
    try:
        query = f"""
            UPDATE {db.schema}.admin_users 
            SET first_name = %s,
                last_name = %s,
                phone = %s,
                auth_user_id = COALESCE(auth_user_id, %s),
                v1_admin_id = COALESCE(v1_admin_id, %s),
                status = 'active',
                updated_at = NOW()
            WHERE id = %s
        """
        
        params = (
            contact['first_name'],
            contact['last_name'],
            contact.get('phone', ''),
            auth_user_id,
            contact.get('v1_contact_id'),
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


def get_v3_restaurant_id(db: DatabaseConnection, v1_id: int, logger) -> Optional[int]:
    """
    Get V3 restaurant ID from V1 legacy ID.
    """
    try:
        query = f"""
            SELECT id FROM {db.schema}.restaurants 
            WHERE legacy_v1_id = %s AND deleted_at IS NULL
        """
        result = db.execute_with_retry(query, (v1_id,), fetch=True)
        return result[0][0] if result else None
        
    except Exception as e:
        logger.error(f"Error getting V3 restaurant ID for V1 ID {v1_id}: {e}")
        return None


def get_restaurants_to_scrape(db: DatabaseConnection, logger) -> List[Dict]:
    """
    Get all restaurants with legacy_v1_id to scrape.
    Returns list of dicts with id, name, legacy_v1_id.
    """
    try:
        query = f"""
            SELECT id, name, legacy_v1_id 
            FROM {db.schema}.restaurants 
            WHERE legacy_v1_id IS NOT NULL 
              AND deleted_at IS NULL
            ORDER BY legacy_v1_id
        """
        result = db.execute_with_retry(query, fetch=True)
        
        restaurants = []
        for row in result:
            restaurants.append({
                'v3_id': row[0],
                'name': row[1],
                'v1_id': row[2]
            })
        
        logger.info(f"Found {len(restaurants)} restaurants with V1 IDs to scrape")
        return restaurants
        
    except Exception as e:
        logger.error(f"Error getting restaurants to scrape: {e}")
        return []


# =============================================================================
# Exports
# =============================================================================
__all__ = [
    'setup_logging',
    'DatabaseConnection',
    'login_to_crm',
    'scrape_restaurant_contacts',
    'parse_contact_form',
    'split_name',
    'filter_contacts_by_email',
    'create_supabase_auth_user',
    'get_existing_auth_user',
    'get_existing_admin_by_email',
    'insert_admin_user',
    'update_admin_user',
    'check_restaurant_link_exists',
    'insert_restaurant_link',
    'get_v3_restaurant_id',
    'get_restaurants_to_scrape',
    'RESTAURANT_ADMIN_ROLE_ID',
]
