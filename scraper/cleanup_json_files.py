"""
Remove deleted restaurant entries from JSON files.
Restaurants to remove: FJ Pizzeria (743), Marina Pizza Maloney (615), Pizza 9 Grecque 9 (570)
"""
import json
from pathlib import Path

RESTAURANT_IDS_TO_REMOVE = [743, 615, 570]

def cleanup_json_file(file_path):
    """Remove restaurant entries from JSON file."""
    if not Path(file_path).exists():
        print(f"[SKIP] File not found: {file_path}")
        return
    
    print(f"\nProcessing: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    original_count = len(data) if isinstance(data, list) else len(data.get('results', [])) if isinstance(data, dict) else 0
    
    if isinstance(data, list):
        # List of restaurant results
        data = [r for r in data if r.get('restaurant_id') not in RESTAURANT_IDS_TO_REMOVE]
        removed = original_count - len(data)
    elif isinstance(data, dict):
        # Dictionary with results key
        if 'results' in data:
            original_results = len(data['results'])
            data['results'] = [r for r in data['results'] if r.get('restaurant_id') not in RESTAURANT_IDS_TO_REMOVE]
            removed = original_results - len(data['results'])
        elif 'completed' in data:
            # Progress file format
            original_completed = len(data.get('completed', []))
            original_failed = len(data.get('failed', []))
            original_skipped = len(data.get('skipped', []))
            
            data['completed'] = [r for r in data.get('completed', []) if r not in RESTAURANT_IDS_TO_REMOVE]
            data['failed'] = [r for r in data.get('failed', []) if r not in RESTAURANT_IDS_TO_REMOVE]
            data['skipped'] = [r for r in data.get('skipped', []) if r not in RESTAURANT_IDS_TO_REMOVE]
            
            removed = (original_completed + original_failed + original_skipped) - (len(data['completed']) + len(data['failed']) + len(data['skipped']))
        else:
            # Try to find restaurant_id in nested structures
            removed = 0
            for key in list(data.keys()):
                if isinstance(data[key], dict) and data[key].get('restaurant_id') in RESTAURANT_IDS_TO_REMOVE:
                    del data[key]
                    removed += 1
                elif isinstance(data[key], list):
                    original_len = len(data[key])
                    data[key] = [r for r in data[key] if (isinstance(r, dict) and r.get('restaurant_id') not in RESTAURANT_IDS_TO_REMOVE) or (isinstance(r, int) and r not in RESTAURANT_IDS_TO_REMOVE)]
                    removed += original_len - len(data[key])
    else:
        print(f"[SKIP] Unknown format: {type(data)}")
        return
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"  [OK] Removed {removed} entries, {len(data) if isinstance(data, list) else 'N/A'} remaining")

def main():
    json_files = [
        'french_scrape_results.json',
        'french_prices_results.json',
        'french_scrape_progress.json',
        'french_prices_progress.json'
    ]
    
    print("="*80)
    print("CLEANING UP JSON FILES")
    print("="*80)
    print(f"Removing restaurants: {RESTAURANT_IDS_TO_REMOVE}")
    
    for json_file in json_files:
        try:
            cleanup_json_file(json_file)
        except Exception as e:
            print(f"  [ERROR] Failed to process {json_file}: {e}")
    
    print("\n" + "="*80)
    print("CLEANUP COMPLETE")
    print("="*80)

if __name__ == "__main__":
    main()


