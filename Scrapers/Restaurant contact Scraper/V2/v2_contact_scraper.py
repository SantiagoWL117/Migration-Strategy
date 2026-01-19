"""
V2 CRM Restaurant Contact Scraper
=================================
Scrapes phone and email from V2 CRM for specific V2-only restaurants.
Updates restaurant_locations table with public contact info.

Usage:
    python v2_contact_scraper.py [--dry-run] [--limit N]
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

# V2 CRM Credentials (from ENV_ACCESS_GUIDE.md)
CRM_V2_BASE_URL = "https://aggregator-admin.menu.ca"
CRM_V2_LOGIN_URL = f"{CRM_V2_BASE_URL}/index.php/auth/index"
CRM_V2_USERNAME = "santiago@worklocal.ca"
CRM_V2_PASSWORD = "WL2129925*"

# Specific V2 restaurants to scrape (from V2 Instructions.md)
V2_RESTAURANTS = [
    {"v3_id": 147, "name": "Pho Dau Bo Restaurant - Kitchener", "v2_id": 1171},
    {"v3_id": 1020, "name": "Sushi Presse", "v2_id": 1285},
    {"v3_id": 950, "name": "Kirkwood Pizza", "v2_id": 1637},
    {"v3_id": 952, "name": "River Pizza", "v2_id": 1639},
    {"v3_id": 954, "name": "Wandee Thai", "v2_id": 1641},
    {"v3_id": 825, "name": "La Nawab", "v2_id": 1642},
    {"v3_id": 957, "name": "Cosenza", "v2_id": 1654},
    {"v3_id": 960, "name": "Cuisine Bombay Indienne", "v2_id": 1657},
    {"v3_id": 961, "name": "Chicco Shawarma Cantley", "v2_id": 1658},
    {"v3_id": 963, "name": "Chicco Pizza Shawarma Anger", "v2_id": 1660},
    {"v3_id": 964, "name": "Chicco Pizza Maloney", "v2_id": 1661},
    {"v3_id": 965, "name": "Chicco Shawarma Maloney", "v2_id": 1662},
    {"v3_id": 966, "name": "Chicco Pizza de l'Hopital", "v2_id": 1663},
    {"v3_id": 967, "name": "Chicco Pizza St-Louis", "v2_id": 1664},
    {"v3_id": 971, "name": "Little Gyros Greek Grill", "v2_id": 1668},
    {"v3_id": 973, "name": "Capital Bites", "v2_id": 1670},
    {"v3_id": 974, "name": "Pachino Pizza", "v2_id": 1671},
    {"v3_id": 976, "name": "Pizza Marie", "v2_id": 1673},
    {"v3_id": 977, "name": "Capri Pizza", "v2_id": 1674},
    {"v3_id": 981, "name": "Al-s Drive In", "v2_id": 1678},
]

# Logging setup
LOG_DIR = Path(__file__).parent / "logs"
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / f"v2_contact_scraper_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

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

def get_restaurant_location(v3_id: int) -> dict:
    """Get restaurant location info by V3 ID."""
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT 
                    rl.id as location_id,
                    rl.phone as current_phone,
                    rl.email as current_email
                FROM menuca_v3.restaurant_locations rl
                WHERE rl.restaurant_id = %s
                  AND rl.is_primary = true
                  AND rl.deleted_at IS NULL
                LIMIT 1
            """, (v3_id,))
            return cur.fetchone()
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

async def login_to_v2_crm(page):
    """Login to V2 CRM (aggregator-admin.menu.ca)."""
    logger.info("Logging into V2 CRM...")
    
    await page.goto(CRM_V2_LOGIN_URL, wait_until='networkidle', timeout=30000)
    
    # Check if already logged in
    content = await page.content()
    if "logout" in content.lower() or "dashboard" in content.lower():
        logger.info("Already logged in to V2 CRM")
        return True
    
    # Fill email
    email_elem = await page.query_selector('input[name="email"]')
    if email_elem:
        await email_elem.fill(CRM_V2_USERNAME)
        logger.debug("Filled email field")
    else:
        raise Exception("Could not find email field")
    
    # Fill password
    password_elem = await page.query_selector('input[name="password"]')
    if password_elem:
        await password_elem.fill(CRM_V2_PASSWORD)
        logger.debug("Filled password field")
    else:
        raise Exception("Could not find password field")
    
    # Click login button
    submit_elem = await page.query_selector('button[type="submit"]')
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
    
    if "logout" in content.lower() or "dashboard" in current_url.lower() or "restaurants" in current_url.lower():
        logger.info("[OK] Login successful")
        return True
    
    logger.warning(f"Login status unclear. Current URL: {current_url}")
    return True  # Assume success and continue


async def scrape_restaurant_contact(page, v2_id: int) -> dict:
    """Scrape phone and email from V2 CRM restaurant edit page."""
    url = f"{CRM_V2_BASE_URL}/index.php/restaurants/edit/{v2_id}/info"
    
    try:
        await page.goto(url, wait_until='networkidle', timeout=30000)
        await page.wait_for_timeout(1000)
        
        # Wait for the Contact info section to load
        try:
            await page.wait_for_selector('legend:has-text("Contact info")', timeout=10000)
        except PlaywrightTimeout:
            logger.warning(f"  Contact info section not found for V2 ID {v2_id}")
        
        # Extract phone
        phone = None
        phone_input = await page.query_selector('input#phone')
        if phone_input:
            phone = await phone_input.get_attribute("value")
            phone = phone.strip() if phone else None
        
        # Extract email
        email = None
        email_input = await page.query_selector('input#email')
        if email_input:
            email = await email_input.get_attribute("value")
            email = email.strip() if email else None
        
        return {
            "success": True,
            "phone": phone,
            "email": email
        }
    
    except PlaywrightTimeout:
        logger.warning(f"  Timeout loading restaurant V2 ID {v2_id}")
        return {"success": False, "error": "timeout"}
    except Exception as e:
        logger.error(f"  Error scraping restaurant V2 ID {v2_id}: {e}")
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
    logger.info("V2 CRM Restaurant Contact Scraper")
    logger.info(f"Started: {datetime.now().isoformat()}")
    logger.info(f"Dry Run: {dry_run}")
    logger.info(f"Limit: {limit if limit else 'None'}")
    logger.info("=" * 70)
    
    # Get restaurants to scrape
    restaurants = V2_RESTAURANTS.copy()
    total = len(restaurants)
    logger.info(f"Found {total} V2 restaurants to scrape")
    
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
            await login_to_v2_crm(page)
            
            # Scrape each restaurant
            for i, restaurant in enumerate(restaurants, 1):
                v3_id = restaurant["v3_id"]
                v2_id = restaurant["v2_id"]
                name = restaurant["name"]
                
                logger.info(f"[{i}/{len(restaurants)}] {name} (V3:{v3_id}, V2:{v2_id})")
                
                # Get current location data
                location = get_restaurant_location(v3_id)
                if not location:
                    logger.warning(f"  [WARN] No primary location found - skipping")
                    stats["errors"] += 1
                    continue
                
                location_id = location["location_id"]
                current_phone = location["current_phone"]
                current_email = location["current_email"]
                
                # Scrape
                result = await scrape_restaurant_contact(page, v2_id)
                
                if not result["success"]:
                    logger.warning(f"  [ERROR] Failed to scrape: {result.get('error', 'unknown')}")
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
    parser = argparse.ArgumentParser(description="V2 CRM Restaurant Contact Scraper")
    parser.add_argument("--dry-run", action="store_true", help="Don't actually update database")
    parser.add_argument("--limit", type=int, help="Limit number of restaurants to scrape")
    args = parser.parse_args()
    
    asyncio.run(run_scraper(dry_run=args.dry_run, limit=args.limit))


if __name__ == "__main__":
    main()
