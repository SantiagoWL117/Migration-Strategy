"""
V1 CRM Restaurant Contact Scraper
=================================
Scrapes phone and email from V1 CRM for restaurants with legacy_v1_id (no legacy_v2_id)
Updates restaurant_locations table with public contact info.

Usage:
    python v1_contact_scraper.py [--dry-run] [--limit N]
"""

import asyncio
import argparse
import logging
import sys
from datetime import datetime
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from playwright.async_api import async_playwright, TimeoutError as PlaywrightTimeout

# ============================================================================
# Configuration
# ============================================================================

# Database connection (from ENV_ACCESS_GUIDE.md - Option A)
DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# V1 CRM Credentials (from ENV_ACCESS_GUIDE.md)
CRM_V1_BASE_URL = "https://menuadmin.menu.ca"
CRM_V1_LOGIN_URL = f"{CRM_V1_BASE_URL}/?p=login"
CRM_V1_USERNAME = "santiago@worklocal.ca"
CRM_V1_PASSWORD = "542sfgsgeerg4%$"

# Logging setup
LOG_DIR = Path(__file__).parent / "logs"
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / f"v1_contact_scraper_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)-8s | %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# ============================================================================
# Database Functions
# ============================================================================

def get_v1_restaurants():
    """Get all V1-only restaurants that need scraping."""
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT 
                    r.id as v3_id,
                    r.legacy_v1_id,
                    r.name,
                    rl.id as location_id,
                    rl.phone as current_phone,
                    rl.email as current_email
                FROM menuca_v3.restaurants r
                LEFT JOIN menuca_v3.restaurant_locations rl 
                    ON rl.restaurant_id = r.id 
                    AND rl.is_primary = true 
                    AND rl.deleted_at IS NULL
                WHERE r.deleted_at IS NULL
                  AND r.legacy_v1_id IS NOT NULL
                  AND r.legacy_v2_id IS NULL
                ORDER BY r.legacy_v1_id
            """)
            return cur.fetchall()
    finally:
        conn.close()


def update_location_contact(location_id: int, phone: str = None, email: str = None, dry_run: bool = False):
    """Update restaurant_locations with new phone/email."""
    if dry_run:
        logger.info(f"  [DRY-RUN] Would update location {location_id}: phone={phone}, email={email}")
        return True
    
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    try:
        with conn.cursor() as cur:
            updates = []
            params = []
            
            if phone is not None:
                updates.append("phone = %s")
                params.append(phone)
            if email is not None:
                updates.append("email = %s")
                params.append(email)
            
            if not updates:
                return False
            
            updates.append("updated_at = NOW()")
            params.append(location_id)
            
            query = f"UPDATE menuca_v3.restaurant_locations SET {', '.join(updates)} WHERE id = %s"
            cur.execute(query, params)
            conn.commit()
            return True
    except Exception as e:
        logger.error(f"  Database error: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()


# ============================================================================
# Scraper Functions
# ============================================================================

async def login_to_v1_crm(page):
    """Login to V1 CRM (same approach as existing scrapers)."""
    logger.info("Logging into V1 CRM...")
    
    await page.goto(CRM_V1_LOGIN_URL, wait_until='networkidle', timeout=30000)
    
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
        raise Exception("Could not find username field")
    
    # Fill password
    password_elem = await page.query_selector('input[name="password"]')
    if password_elem:
        await password_elem.fill(CRM_V1_PASSWORD)
        logger.debug("Filled password field")
    else:
        raise Exception("Could not find password field")
    
    # Click login button
    submit_elem = await page.query_selector('input[type="submit"]')
    if submit_elem:
        await submit_elem.click()
        logger.debug("Clicked submit button")
    else:
        raise Exception("Could not find submit button")
    
    # Wait for navigation
    await page.wait_for_load_state('networkidle', timeout=15000)
    await page.wait_for_timeout(2000)
    
    # Verify login success
    content = await page.content()
    current_url = page.url
    
    if "error" in content.lower() and ("invalid" in content.lower() or "incorrect" in content.lower()):
        raise Exception("Login failed - invalid credentials")
    
    if "logout" in content.lower() or "restaurants" in current_url.lower():
        logger.info("[OK] Login successful")
        return True
    
    logger.warning(f"Login status unclear. Current URL: {current_url}")
    return True  # Assume success and continue


async def scrape_restaurant_contact(page, legacy_v1_id: int) -> dict:
    """Scrape phone and email from V1 CRM restaurant edit page."""
    url = f"{CRM_V1_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={legacy_v1_id}"
    
    try:
        await page.goto(url, wait_until="networkidle", timeout=30000)
        
        # Wait for the form to load
        await page.wait_for_selector("form[action*='updateRestaurant']", timeout=10000)
        
        # Extract phone - look for form with action containing "updateRestaurant"
        phone = None
        phone_input = await page.query_selector('form[action*="updateRestaurant"] input#phone')
        if not phone_input:
            phone_input = await page.query_selector('input#phone')
        if phone_input:
            phone = await phone_input.get_attribute("value")
            phone = phone.strip() if phone else None
        
        # Extract email - mainEmail is the restaurant email field
        email = None
        email_input = await page.query_selector('form[action*="updateRestaurant"] input#mainEmail')
        if not email_input:
            email_input = await page.query_selector('input#mainEmail')
        if email_input:
            email = await email_input.get_attribute("value")
            email = email.strip() if email else None
        
        return {
            "success": True,
            "phone": phone,
            "email": email
        }
    
    except PlaywrightTimeout:
        logger.warning(f"  Timeout loading restaurant {legacy_v1_id}")
        return {"success": False, "error": "timeout"}
    except Exception as e:
        logger.error(f"  Error scraping restaurant {legacy_v1_id}: {e}")
        return {"success": False, "error": str(e)}


def normalize_phone(phone: str) -> str:
    """Normalize phone number for comparison (digits only)."""
    if not phone:
        return ""
    return ''.join(c for c in phone if c.isdigit())


def normalize_email(email: str) -> str:
    """Normalize email for comparison (lowercase, stripped)."""
    if not email:
        return ""
    return email.lower().strip()


def should_update(current_value: str, scraped_value: str, field_type: str) -> bool:
    """Determine if we should update the value."""
    if not scraped_value:
        return False
    
    if field_type == "phone":
        return normalize_phone(current_value) != normalize_phone(scraped_value)
    elif field_type == "email":
        return normalize_email(current_value) != normalize_email(scraped_value)
    
    return False


# ============================================================================
# Main Scraper
# ============================================================================

async def run_scraper(dry_run: bool = False, limit: int = None):
    """Main scraper function."""
    logger.info("=" * 70)
    logger.info("V1 CRM Restaurant Contact Scraper")
    logger.info(f"Started: {datetime.now().isoformat()}")
    logger.info(f"Dry Run: {dry_run}")
    logger.info(f"Limit: {limit if limit else 'None'}")
    logger.info("=" * 70)
    
    # Get restaurants to scrape
    restaurants = get_v1_restaurants()
    total = len(restaurants)
    logger.info(f"Found {total} V1-only restaurants to scrape")
    
    if limit:
        restaurants = restaurants[:limit]
        logger.info(f"Limited to first {limit} restaurants")
    
    # Stats
    stats = {
        "total": len(restaurants),
        "scraped": 0,
        "phone_updated": 0,
        "email_updated": 0,
        "skipped_same": 0,
        "errors": 0
    }
    
    async with async_playwright() as p:
        # Use headless=True for production, False for debugging
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        try:
            # Login
            await login_to_v1_crm(page)
            
            # Scrape each restaurant
            for i, restaurant in enumerate(restaurants, 1):
                v3_id = restaurant["v3_id"]
                v1_id = restaurant["legacy_v1_id"]
                name = restaurant["name"]
                location_id = restaurant["location_id"]
                current_phone = restaurant["current_phone"]
                current_email = restaurant["current_email"]
                
                logger.info(f"[{i}/{len(restaurants)}] {name} (V3:{v3_id}, V1:{v1_id})")
                
                if not location_id:
                    logger.warning(f"  ⚠️ No primary location found - skipping")
                    stats["errors"] += 1
                    continue
                
                # Scrape
                result = await scrape_restaurant_contact(page, v1_id)
                
                if not result["success"]:
                    logger.warning(f"  ❌ Failed to scrape: {result.get('error', 'unknown')}")
                    stats["errors"] += 1
                    continue
                
                stats["scraped"] += 1
                scraped_phone = result["phone"]
                scraped_email = result["email"]
                
                logger.info(f"  Scraped: phone={scraped_phone}, email={scraped_email}")
                logger.info(f"  Current: phone={current_phone}, email={current_email}")
                
                # Determine what to update
                update_phone = should_update(current_phone, scraped_phone, "phone")
                update_email = should_update(current_email, scraped_email, "email")
                
                if update_phone or update_email:
                    phone_to_update = scraped_phone if update_phone else None
                    email_to_update = scraped_email if update_email else None
                    
                    if update_phone:
                        logger.info(f"  [PHONE] Change: {current_phone} -> {scraped_phone}")
                        stats["phone_updated"] += 1
                    if update_email:
                        logger.info(f"  [EMAIL] Change: {current_email} -> {scraped_email}")
                        stats["email_updated"] += 1
                    
                    update_location_contact(location_id, phone_to_update, email_to_update, dry_run)
                else:
                    logger.info(f"  [OK] No changes needed")
                    stats["skipped_same"] += 1
                
                # Small delay to avoid rate limiting
                await asyncio.sleep(0.5)
        
        finally:
            await browser.close()
    
    # Summary
    logger.info("")
    logger.info("=" * 70)
    logger.info("SCRAPING COMPLETE")
    logger.info("=" * 70)
    logger.info(f"Total restaurants:  {stats['total']}")
    logger.info(f"Successfully scraped: {stats['scraped']}")
    logger.info(f"Phone updates:      {stats['phone_updated']}")
    logger.info(f"Email updates:      {stats['email_updated']}")
    logger.info(f"No changes needed:  {stats['skipped_same']}")
    logger.info(f"Errors:             {stats['errors']}")
    logger.info("=" * 70)
    
    return stats


# ============================================================================
# Entry Point
# ============================================================================

def main():
    parser = argparse.ArgumentParser(description="V1 CRM Restaurant Contact Scraper")
    parser.add_argument("--dry-run", action="store_true", help="Don't actually update database")
    parser.add_argument("--limit", type=int, help="Limit number of restaurants to scrape")
    args = parser.parse_args()
    
    asyncio.run(run_scraper(dry_run=args.dry_run, limit=args.limit))


if __name__ == "__main__":
    main()
