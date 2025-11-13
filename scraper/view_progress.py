#!/usr/bin/env python3
"""
View the current progress of the prices & modifiers scraper.
"""

import json
from pathlib import Path
from datetime import datetime

PROGRESS_FILE = 'prices_modifiers_progress.json'
RESULTS_FILE = 'prices_modifiers_results.json'

def main():
    """Display progress information."""
    
    print("=" * 70)
    print("PRICES & MODIFIERS SCRAPER - PROGRESS STATUS")
    print("=" * 70)
    
    # Load progress file
    if not Path(PROGRESS_FILE).exists():
        print("\n❌ No progress file found. Scraper hasn't been run yet.")
        print(f"   Looking for: {PROGRESS_FILE}")
        return
    
    with open(PROGRESS_FILE, 'r') as f:
        progress = json.load(f)
    
    completed = progress.get('completed', [])
    failed = progress.get('failed', [])
    skipped = progress.get('skipped', [])
    
    total_processed = len(completed) + len(failed) + len(skipped)
    
    print(f"\n📊 Progress Overview:")
    print(f"   ✅ Completed: {len(completed)}")
    print(f"   ⏭️  Skipped:   {len(skipped)}")
    print(f"   ❌ Failed:    {len(failed)}")
    print(f"   ━━━━━━━━━━━━━━━━━━━━━")
    print(f"   📦 Total:     {total_processed}")
    
    # Load results if available
    if Path(RESULTS_FILE).exists():
        with open(RESULTS_FILE, 'r') as f:
            results = json.load(f)
        
        total_prices = sum(r.get('prices_count', 0) for r in results)
        total_groups = sum(r.get('modifier_groups_count', 0) for r in results)
        total_items = sum(r.get('modifier_items_count', 0) for r in results)
        
        print(f"\n💾 Data Inserted:")
        print(f"   Prices:          {total_prices:,}")
        print(f"   Modifier Groups: {total_groups:,}")
        print(f"   Modifier Items:  {total_items:,}")
        
        # Show recent results
        if results:
            print(f"\n📝 Last 5 Processed Dishes:")
            for r in results[-5:]:
                status = "✅" if r['success'] else ("⏭️" if r.get('error') == 'No details scraped' else "❌")
                print(f"   {status} {r['dish_name']} (ID: {r['dish_id']}) - {r['restaurant_name']}")
                if r['success']:
                    print(f"      → {r['prices_count']} prices, {r['modifier_groups_count']} groups, {r['modifier_items_count']} items")
                elif r.get('error'):
                    print(f"      → Error: {r['error']}")
    
    # Show failed dishes if any
    if failed:
        print(f"\n⚠️  Failed Dishes (first 10):")
        for dish_id in failed[:10]:
            if Path(RESULTS_FILE).exists():
                with open(RESULTS_FILE, 'r') as f:
                    results = json.load(f)
                    failed_result = next((r for r in results if r['dish_id'] == dish_id), None)
                    if failed_result:
                        print(f"   ❌ {failed_result['dish_name']} (ID: {dish_id})")
                        print(f"      Restaurant: {failed_result['restaurant_name']}")
                        print(f"      Error: {failed_result.get('error', 'Unknown error')}")
            else:
                print(f"   ❌ Dish ID: {dish_id}")
        
        if len(failed) > 10:
            print(f"   ... and {len(failed) - 10} more")
    
    # File info
    progress_file = Path(PROGRESS_FILE)
    if progress_file.exists():
        mod_time = datetime.fromtimestamp(progress_file.stat().st_mtime)
        print(f"\n📁 Files:")
        print(f"   Progress: {PROGRESS_FILE} (last updated: {mod_time.strftime('%Y-%m-%d %H:%M:%S')})")
        if Path(RESULTS_FILE).exists():
            print(f"   Results:  {RESULTS_FILE}")
        if Path('batch_scrape_prices_modifiers.log').exists():
            print(f"   Log:      batch_scrape_prices_modifiers.log")
    
    print("\n" + "=" * 70)

if __name__ == "__main__":
    main()

