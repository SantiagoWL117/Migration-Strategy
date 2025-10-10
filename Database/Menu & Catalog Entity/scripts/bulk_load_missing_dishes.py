#!/usr/bin/env python3
"""
Bulk load all 3,669 missing dishes into Supabase using REST API
Handles French characters like a boss! 🇫🇷
"""
import json
import os
import sys
import time
from pathlib import Path
from typing import List, Dict, Any

try:
    import requests
except ImportError:
    print("❌ Error: requests package not installed")
    print("Run: pip install requests")
    sys.exit(1)

# Configuration
SCRIPT_DIR = Path(__file__).parent
CSV_FILE = SCRIPT_DIR.parent / "CSV" / "missed_menu_files.csv"
BATCH_SIZE = 100  # Smaller batches for reliability

def get_supabase_config():
    """Get Supabase URL and key from environment or MCP context"""
    url = os.getenv('SUPABASE_URL')
    key = os.getenv('SUPABASE_SERVICE_ROLE_KEY')
    
    if not url or not key:
        print("❌ Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
        print("\nPlease set these environment variables:")
        print("  export SUPABASE_URL='https://your-project.supabase.co'")
        print("  export SUPABASE_SERVICE_ROLE_KEY='your-service-role-key'")
        sys.exit(1)
    
    return url, key

def read_json_batches() -> List[Dict[str, Any]]:
    """Read all JSON batch files"""
    all_rows = []
    for i in range(1, 38):  # 37 batches
        batch_file = SCRIPT_DIR / f'batch_{i}.json'
        if not batch_file.exists():
            print(f"⚠️  Warning: {batch_file} not found, skipping")
            continue
            
        with open(batch_file, 'r', encoding='utf-8') as f:
            rows = json.load(f)
            all_rows.extend(rows)
    
    return all_rows

def insert_batch(url: str, key: str, batch: List[Dict[str, Any]]) -> bool:
    """Insert a batch of rows using Supabase REST API"""
    headers = {
        'apikey': key,
        'Authorization': f'Bearer {key}',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'  # Don't return inserted data
    }
    
    # Transform data for API
    payload = []
    for row in batch:
        payload.append({
            'id': row['id'],
            'course': row['course'],
            'restaurant': row['restaurant'],
            'sku': row['sku'],
            'name': row['name'],
            'source_type': 'menu'
        })
    
    # Make request to Supabase REST API
    api_url = f"{url}/rest/v1/menuca_v1_menu_full?schema=staging"
    
    try:
        response = requests.post(api_url, headers=headers, json=payload, timeout=30)
        
        if response.status_code in [200, 201]:
            return True
        else:
            print(f"    ❌ Error: {response.status_code} - {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"    ⏱️  Timeout - retrying...")
        return False
    except Exception as e:
        print(f"    ❌ Error: {str(e)[:200]}")
        return False

def main():
    print("=" * 70)
    print("🚀 Loading 3,669 Missing Menu Dishes into Supabase")
    print("=" * 70)
    
    # Get configuration
    url, key = get_supabase_config()
    print(f"✓ Connected to: {url}")
    
    # Read data
    print(f"\n📖 Reading JSON batch files...")
    all_rows = read_json_batches()
    print(f"✓ Loaded {len(all_rows)} rows from JSON files")
    
    if len(all_rows) == 0:
        print("❌ No data to load!")
        sys.exit(1)
    
    # Insert in batches
    total_batches = (len(all_rows) + BATCH_SIZE - 1) // BATCH_SIZE
    successful_batches = 0
    failed_batches = 0
    
    print(f"\n📥 Inserting data in {total_batches} batches of {BATCH_SIZE} rows...")
    
    for i in range(0, len(all_rows), BATCH_SIZE):
        batch_num = i // BATCH_SIZE + 1
        batch = all_rows[i:i+BATCH_SIZE]
        
        print(f"  [{batch_num}/{total_batches}] Inserting {len(batch)} rows...", end=" ", flush=True)
        
        max_retries = 3
        success = False
        
        for retry in range(max_retries):
            if insert_batch(url, key, batch):
                print("✓")
                successful_batches += 1
                success = True
                break
            else:
                if retry < max_retries - 1:
                    time.sleep(2)  # Wait before retry
        
        if not success:
            print("❌ Failed after retries")
            failed_batches += 1
        
        # Small delay to avoid rate limiting
        time.sleep(0.1)
    
    # Summary
    print("\n" + "=" * 70)
    print("📊 RESULTS")
    print("=" * 70)
    print(f"✓ Successful batches: {successful_batches}/{total_batches}")
    print(f"✓ Rows inserted: ~{successful_batches * BATCH_SIZE}")
    
    if failed_batches > 0:
        print(f"⚠️  Failed batches: {failed_batches}")
        print("\nSome rows may not have been inserted. Please check the database.")
        sys.exit(1)
    else:
        print("\n🎉 All data loaded successfully!")
        print("=" * 70)

if __name__ == "__main__":
    main()

