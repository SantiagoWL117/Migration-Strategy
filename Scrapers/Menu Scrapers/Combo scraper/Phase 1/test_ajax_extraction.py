#!/usr/bin/env python3
"""Test the AJAX-based modifier extraction."""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from combo_scraper import ComboScraper

def test_ajax_extraction():
    """Test fetching modifiers via AJAX for Beneci Pizza."""
    print("=" * 70)
    print("AJAX EXTRACTION TEST - Beneci Pizza (V3: 241, V1: 383)")
    print("=" * 70)
    
    scraper = ComboScraper(headless=True)
    
    try:
        # Connect and login
        print("\n[1/4] Connecting...")
        scraper.connect_database()
        scraper.start_browser()
        scraper.login()
        print("      [OK] Connected and logged in")
        
        # Navigate to Beneci Pizza combo groups
        print("\n[2/4] Navigating to combo groups page...")
        scraper.navigate_to_combo_groups(383)  # V1 ID
        print("      [OK] Navigation successful")
        
        # Get combo dishes
        print("\n[3/4] Finding combo dishes...")
        combo_dishes = scraper.get_combo_dish_names()
        print(f"      Found {len(combo_dishes)} combo dishes")
        
        # Test AJAX extraction for first few dishes
        print("\n[4/4] Testing AJAX extraction...")
        
        total_modifiers = 0
        for dish_name, group_id in combo_dishes[:4]:  # Test first 4
            print(f"\n  -> Fetching modifiers for: {dish_name} (group_id={group_id})")
            
            # Fetch via AJAX
            ajax_html = scraper.fetch_combo_modifiers_ajax(383, group_id)
            
            if ajax_html:
                print(f"    [OK] Got {len(ajax_html)} bytes of HTML")
                
                # Extract modifiers
                modifiers = scraper.extract_modifiers_from_html(ajax_html)
                print(f"    [OK] Extracted {len(modifiers)} modifiers")
                
                # Show first few modifiers
                for mod in modifiers[:3]:
                    print(f"      - {mod.name} ({mod.group_name}): {mod.prices}")
                if len(modifiers) > 3:
                    print(f"      ... and {len(modifiers) - 3} more")
                
                total_modifiers += len(modifiers)
            else:
                print(f"    [FAIL] AJAX request failed")
        
        print("\n" + "=" * 70)
        print(f"RESULTS: Extracted {total_modifiers} total modifiers from 4 dishes")
        print("=" * 70)
        
        return total_modifiers > 0
        
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        scraper.close()

if __name__ == '__main__':
    success = test_ajax_extraction()
    sys.exit(0 if success else 1)

