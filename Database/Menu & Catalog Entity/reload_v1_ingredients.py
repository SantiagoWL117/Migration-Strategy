#!/usr/bin/env python3
"""
Reload v1_ingredients Only (After Escaping Fix)
"""

import os
import sys
import glob
import time
import psycopg2
from pathlib import Path

# Configuration
BATCH_DIR = Path(__file__).parent / "split_pg"
CONNECTION_STRING = "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:[YOUR-PASSWORD]@aws-1-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"
EXPECTED_ROWS = 53367
EXPECTED_BATCHES = 54

def get_db_password():
    """Get database password from environment"""
    password = os.environ.get('SUPABASE_DB_PASSWORD')
    if not password:
        print("❌ Error: SUPABASE_DB_PASSWORD environment variable not set")
        sys.exit(1)
    return password

def connect_to_database(password):
    """Connect to Supabase"""
    connection_string = CONNECTION_STRING.replace('[YOUR-PASSWORD]', password)
    
    try:
        print("🔌 Connecting to Supabase...")
        conn = psycopg2.connect(connection_string)
        conn.autocommit = False
        print("✅ Connected successfully!\n")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)

def load_batch_file(cursor, filepath, batch_num, total_batches):
    """Load a single batch file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        start_time = time.time()
        cursor.execute(sql)
        elapsed = time.time() - start_time
        
        rows_affected = cursor.rowcount
        progress = (batch_num / total_batches) * 100
        print(f"  [{batch_num:3d}/{total_batches:3d}] {progress:5.1f}% - {filepath.name:50s} - {rows_affected:6,d} rows - {elapsed:5.2f}s")
        
        return rows_affected
        
    except Exception as e:
        print(f"\n❌ Error loading {filepath.name}: {e}")
        raise

def main():
    """Main execution"""
    print("\n" + "="*80)
    print("🚀 V1_INGREDIENTS RELOAD (Post-Escaping Fix)")
    print("="*80)
    
    # Get password
    password = get_db_password()
    
    # Connect
    conn = connect_to_database(password)
    cursor = conn.cursor()
    
    try:
        # Get batch files
        pattern = str(BATCH_DIR / "menuca_v1_ingredients_batch_*.sql")
        batch_files = sorted(glob.glob(pattern))
        
        if len(batch_files) != EXPECTED_BATCHES:
            print(f"⚠️  Warning: Found {len(batch_files)} batches, expected {EXPECTED_BATCHES}")
        
        print(f"📊 Loading v1_ingredients")
        print(f"Target: {EXPECTED_ROWS:,} rows in {len(batch_files)} batches")
        print(f"Staging Table: staging.v1_ingredients\n")
        
        # Load each batch
        total_rows = 0
        start_time = time.time()
        
        for i, batch_file in enumerate(batch_files, 1):
            rows = load_batch_file(cursor, Path(batch_file), i, len(batch_files))
            total_rows += rows
        
        # Commit transaction
        conn.commit()
        elapsed = time.time() - start_time
        
        # Verify row count
        cursor.execute("SELECT COUNT(*) FROM staging.v1_ingredients")
        actual_rows = cursor.fetchone()[0]
        
        print()
        print("─" * 80)
        print(f"✅ Load Complete")
        print(f"   Loaded: {actual_rows:,} rows in {elapsed:.1f}s ({actual_rows/elapsed:.0f} rows/sec)")
        print(f"   Expected: {EXPECTED_ROWS:,} rows")
        
        if actual_rows == EXPECTED_ROWS:
            print(f"   Status: ✅ PERFECT MATCH (100%)")
            return 0
        else:
            percentage = (actual_rows / EXPECTED_ROWS) * 100
            print(f"   Status: ⚠️  {percentage:.1f}% complete (diff: {actual_rows - EXPECTED_ROWS:+,})")
            return 1
            
    except Exception as e:
        conn.rollback()
        print(f"\n❌ Transaction rolled back: {e}")
        return 1
    finally:
        cursor.close()
        conn.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    sys.exit(main())

