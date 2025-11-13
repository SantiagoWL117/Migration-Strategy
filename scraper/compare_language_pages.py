#!/usr/bin/env python3
"""Compare English vs French dish detail pages."""
import time
from bs4 import BeautifulSoup
from scraper import MenuScraper

# Initialize scraper
scraper = MenuScraper()
scraper.start()
print("[OK] Scraper initialized\n")

try:
    # Test dish: Mozzarella Pizza from Mozza Pizza
    restaurant_id = 132
    menu_entry_id = 13208
    
    # Load ENGLISH version
    print("="*80)
    print("LOADING ENGLISH VERSION (&showLang=en)")
    print("="*80)
    url_en = f"{scraper.base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=editDish&showLang=en&menuEntry={menu_entry_id}"
    print(f"URL: {url_en}")
    
    scraper.page.goto(url_en, wait_until='networkidle')
    time.sleep(scraper.delay)
    
    html_en = scraper.page.content()
    soup_en = BeautifulSoup(html_en, 'html.parser')
    
    # Check for modifiers
    modifiers_en = scraper._extract_modifiers(soup_en)
    prices_en = scraper._extract_prices(soup_en)
    
    print(f"English version - Prices: {len(prices_en)}, Modifiers: {len(modifiers_en)}")
    
    # Load FRENCH version
    print("\n" + "="*80)
    print("LOADING FRENCH VERSION (&showLang=fr)")
    print("="*80)
    url_fr = f"{scraper.base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=editDish&showLang=fr&menuEntry={menu_entry_id}"
    print(f"URL: {url_fr}")
    
    scraper.page.goto(url_fr, wait_until='networkidle')
    time.sleep(scraper.delay)
    
    html_fr = scraper.page.content()
    soup_fr = BeautifulSoup(html_fr, 'html.parser')
    
    # Check for modifiers
    modifiers_fr = scraper._extract_modifiers(soup_fr)
    prices_fr = scraper._extract_prices(soup_fr)
    
    print(f"French version - Prices: {len(prices_fr)}, Modifiers: {len(modifiers_fr)}")
    
    # Compare
    print("\n" + "="*80)
    print("COMPARISON")
    print("="*80)
    
    if len(prices_en) != len(prices_fr):
        print(f"[DIFFERENCE] Prices: EN={len(prices_en)} vs FR={len(prices_fr)}")
    else:
        print(f"[SAME] Prices: {len(prices_en)}")
    
    if len(modifiers_en) != len(modifiers_fr):
        print(f"[DIFFERENCE] Modifiers: EN={len(modifiers_en)} vs FR={len(modifiers_fr)}")
        print("\nEnglish modifier groups:")
        for mg in modifiers_en:
            print(f"  - {mg['name']} ({mg['type_code']}): {len(mg['items'])} items")
        print("\nFrench modifier groups:")
        for mg in modifiers_fr:
            print(f"  - {mg['name']} ({mg['type_code']}): {len(mg['items'])} items")
    else:
        print(f"[SAME] Modifiers: {len(modifiers_en)}")
    
    # Conclusion
    print("\n" + "="*80)
    print("CONCLUSION")
    print("="*80)
    
    if len(modifiers_en) == 0 and len(modifiers_fr) > 0:
        print("[CRITICAL] English page has NO modifiers, French page HAS modifiers!")
        print("This confirms batch_scrape_french_prices.py is loading the WRONG language!")
    elif len(prices_en) == 0 and len(prices_fr) > 0:
        print("[CRITICAL] English page has NO prices, French page HAS prices!")
    else:
        print("[INFO] Both pages have similar data structure")

finally:
    scraper.stop()
    print("\n[OK] Browser stopped")

