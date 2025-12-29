"""Debug script to check why Drinks Can has wrong modifier names."""
import asyncio
from playwright.async_api import async_playwright

from scraper_utils import (
    setup_logging,
    login_to_crm,
    CRM_BASE_URL
)

async def main():
    logger = setup_logging("debug_drinks_can")
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)  # Show browser for debugging
        context = await browser.new_context()
        page = await context.new_page()
        
        # Login
        if not await login_to_crm(page, logger):
            print("Login failed")
            return
        
        # Navigate to Little Gyros modifier groups
        url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant=998&load=ingredientGroups&showLang=en"
        print(f"Navigating to: {url}")
        await page.goto(url, wait_until="networkidle", timeout=60000)
        
        # Wait extra time for JS to finish
        await page.wait_for_timeout(3000)
        
        # Find the Drinks Can group (ID: 10232)
        group_id = "10232"
        
        # Click to expand the group
        toggle_link = await page.query_selector(f'a[onclick*="div_{group_id}"]')
        if toggle_link:
            await toggle_link.click()
            await page.wait_for_timeout(500)
        
        # Get all checkboxes in this group
        checkboxes = await page.query_selector_all(f'#fillme_{group_id} input[type="checkbox"]')
        
        print(f"\n{'='*60}")
        print(f"DRINKS CAN GROUP (ID: {group_id})")
        print(f"Found {len(checkboxes)} checkboxes")
        print(f"{'='*60}")
        
        for checkbox in checkboxes:
            modifier_id = await checkbox.get_attribute('value')
            is_checked = await checkbox.is_checked()
            
            # Get label text - try multiple selectors
            label = await page.query_selector(f'label[for$="_{group_id}_{modifier_id}"]')
            label_text = ""
            if label:
                label_text = (await label.text_content()).strip()
            
            # Also try direct sibling approach
            label_direct = await checkbox.evaluate('(el) => el.nextElementSibling?.textContent?.trim() || "N/A"')
            
            # Get price from input
            price_input = await page.query_selector(f'#price__{group_id}_{modifier_id}')
            price = ""
            if price_input:
                price = await price_input.get_attribute('value')
            
            status = "CHECKED" if is_checked else "unchecked"
            print(f"\n  [{status}] ID: {modifier_id}")
            print(f"    Label (selector): '{label_text}'")
            print(f"    Label (sibling): '{label_direct}'")
            print(f"    Price: ${price}")
        
        # Also dump the raw HTML of the fillme div
        fillme_html = await page.inner_html(f'#fillme_{group_id}')
        print(f"\n{'='*60}")
        print("RAW HTML OF FILLME DIV:")
        print(f"{'='*60}")
        print(fillme_html[:2000])  # First 2000 chars
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())






