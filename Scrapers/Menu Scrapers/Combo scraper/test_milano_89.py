"""
Test script for Milano V3:89 (V1:205) to verify combo groups are being detected.

This restaurant should have ~46 combo groups including:
- 1 Topping, 2 Toppings, 3 Toppings, 4 Toppings
- Premium Toppings variations
- Wings Sauces, Pizza Dips
- etc.

The previous scraper run showed 22192 bytes and 0 combo groups.
After the fix, we should see the full page and all combo groups.
"""

import sys
import os
import logging
from datetime import datetime

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from combo_config import CRM_LOGIN_URL
from combo_scraper import ComboScraper

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

# Test restaurant
TEST_RESTAURANT = {
    'name': 'Milano',
    'v3_id': 89,
    'v1_id': 205,
    'expected_min_groups': 40  # Should have ~46 combo groups
}


def test_milano():
    """Test that Milano V3:89 combo groups are properly detected."""
    
    print("=" * 70)
    print(f"TESTING: {TEST_RESTAURANT['name']} (V3: {TEST_RESTAURANT['v3_id']}, V1: {TEST_RESTAURANT['v1_id']})")
    print("=" * 70)
    print()
    
    # Run with headless=False so we can see what's happening
    scraper = ComboScraper(headless=False)
    
    try:
        scraper.start()
        
        # Step 1: Login
        print("Step 1: Logging in...")
        if not scraper.login():
            print("❌ FAILED: Could not log in to CRM")
            return False
        print("✅ Login successful")
        print()
        
        # Step 2: Navigate to combo groups
        print(f"Step 2: Navigating to combo groups for V1:{TEST_RESTAURANT['v1_id']}...")
        if not scraper.navigate_to_combo_groups(TEST_RESTAURANT['v1_id']):
            print("❌ FAILED: Could not navigate to combo groups page")
            return False
        print("✅ Navigation successful")
        print()
        
        # Step 3: Get combo group links
        print("Step 3: Getting combo group links...")
        combo_groups = scraper.get_combo_group_links()
        
        print(f"\n{'=' * 70}")
        print(f"RESULTS:")
        print(f"{'=' * 70}")
        print(f"Page HTML length: {len(scraper.page.content())} bytes")
        print(f"Combo groups found: {len(combo_groups)}")
        print()
        
        if combo_groups:
            print("Combo groups detected:")
            for i, cg in enumerate(combo_groups[:10], 1):  # Show first 10
                print(f"  {i}. {cg['name']} (source_id={cg['source_id']})")
            if len(combo_groups) > 10:
                print(f"  ... and {len(combo_groups) - 10} more")
        print()
        
        # Step 4: Verify results
        print(f"{'=' * 70}")
        print("VERIFICATION:")
        print(f"{'=' * 70}")
        
        if len(combo_groups) >= TEST_RESTAURANT['expected_min_groups']:
            print(f"✅ PASSED: Found {len(combo_groups)} combo groups (expected >= {TEST_RESTAURANT['expected_min_groups']})")
            print()
            print("The fix is working! The scraper now properly waits for")
            print("combo group elements to load before capturing the page.")
            return True
        else:
            print(f"❌ FAILED: Found only {len(combo_groups)} combo groups (expected >= {TEST_RESTAURANT['expected_min_groups']})")
            print()
            print("The page may still not be loading completely.")
            print("Check debug_page.html to see what HTML was captured.")
            
            # Check if we got the "empty" page
            html_len = len(scraper.page.content())
            if html_len < 25000:
                print(f"\nPage size ({html_len} bytes) suggests the combo groups didn't load.")
                print("This could be a timing issue or authentication problem.")
            
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        print()
        print("Closing scraper...")
        scraper.stop()


if __name__ == '__main__':
    print()
    print("Milano V3:89 Combo Groups Test")
    print("=" * 70)
    print()
    print("This test verifies that the fix for waiting on combo group elements")
    print("allows the scraper to properly detect all combo groups.")
    print()
    print("Previous behavior: 22192 bytes, 0 combo groups")
    print("Expected behavior: ~140KB+, 46+ combo groups")
    print()
    
    success = test_milano()
    
    print()
    print("=" * 70)
    if success:
        print("TEST PASSED ✅")
    else:
        print("TEST FAILED ❌")
    print("=" * 70)
    
    sys.exit(0 if success else 1)



