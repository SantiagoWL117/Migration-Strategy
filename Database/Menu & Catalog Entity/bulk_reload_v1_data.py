#!/usr/bin/env python3
"""
V1 Data Bulk Reload Script
Loads all incomplete V1 tables from pre-split batch files using direct PostgreSQL connection

Usage:
    python3 bulk_reload_v1_data.py

Requirements:
    pip install psycopg2-binary python-dotenv
"""

import os
import sys
import glob
import time
import psycopg2
from datetime import datetime
from pathlib import Path

# Configuration
BATCH_DIR = Path(__file__).parent / "split_pg"
CONNECTION_STRING = "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:[YOUR-PASSWORD]@aws-1-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"

# Tables to reload with expected row counts
TABLES_TO_LOAD = {
    'v1_ingredient_groups': {
        'pattern': 'menuca_v1_ingredient_groups_batch_*.sql',
        'expected_batches': 16,
        'expected_rows': 13450,
        'staging_table': 'staging.v1_ingredient_groups'
    },
    'v1_ingredients': {
        'pattern': 'menuca_v1_ingredients_batch_*.sql',
        'expected_batches': 54,
        'expected_rows': 53367,
        'staging_table': 'staging.v1_ingredients'
    },
    'v1_combo_groups': {
        'pattern': 'menuca_v1_combo_groups_batch_*.sql',
        'expected_batches': 68,
        'expected_rows': 62913,
        'staging_table': 'staging.v1_combo_groups'
    },
    'v1_menu': {
        'pattern': 'menuca_v1_menu_batch_*.sql',
        'expected_batches': 126,
        'expected_rows': 138941,
        'staging_table': 'staging.v1_menu'
    }
}


def get_db_password():
    """Get database password from environment or user input"""
    password = os.environ.get('SUPABASE_DB_PASSWORD')
    
    if not password:
        print("\n🔐 Supabase Database Password Required")
        print("=" * 60)
        password = input("Enter Supabase postgres password: ").strip()
        
        if not password:
            print("❌ Error: Password is required")
            sys.exit(1)
    
    return password


def connect_to_database(password):
    """Connect to Supabase via connection pooler"""
    connection_string = CONNECTION_STRING.replace('[YOUR-PASSWORD]', password)
    
    try:
        print("\n🔌 Connecting to Supabase...")
        conn = psycopg2.connect(connection_string)
        conn.autocommit = False  # Use transactions
        print("✅ Connected successfully!")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def load_batch_file(cursor, filepath, batch_num, total_batches, table_name):
    """Load a single batch file"""
    try:
        # Read SQL file
        with open(filepath, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        # Execute SQL
        start_time = time.time()
        cursor.execute(sql)
        elapsed = time.time() - start_time
        
        # Get row count for this batch
        rows_affected = cursor.rowcount
        
        # Progress indicator
        progress = (batch_num / total_batches) * 100
        print(f"  [{batch_num:3d}/{total_batches:3d}] {progress:5.1f}% - {filepath.name:50s} - {rows_affected:6,d} rows - {elapsed:5.2f}s")
        
        return rows_affected
        
    except Exception as e:
        print(f"\n❌ Error loading {filepath.name}: {e}")
        raise


def load_table(conn, table_name, table_config):
    """Load all batches for a single table"""
    cursor = conn.cursor()
    
    print(f"\n{'='*80}")
    print(f"📊 Loading: {table_name.upper()}")
    print(f"{'='*80}")
    print(f"Target: {table_config['expected_rows']:,} rows in {table_config['expected_batches']} batches")
    print(f"Staging Table: {table_config['staging_table']}")
    print()
    
    # Get all batch files sorted by number
    pattern = str(BATCH_DIR / table_config['pattern'])
    batch_files = sorted(glob.glob(pattern))
    
    if not batch_files:
        print(f"❌ Error: No batch files found matching {table_config['pattern']}")
        return False
    
    if len(batch_files) != table_config['expected_batches']:
        print(f"⚠️  Warning: Found {len(batch_files)} batches, expected {table_config['expected_batches']}")
    
    # Load each batch
    total_rows = 0
    start_time = time.time()
    
    try:
        for i, batch_file in enumerate(batch_files, 1):
            rows = load_batch_file(cursor, Path(batch_file), i, len(batch_files), table_name)
            total_rows += rows
        
        # Commit transaction
        conn.commit()
        elapsed = time.time() - start_time
        
        # Verify row count
        cursor.execute(f"SELECT COUNT(*) FROM {table_config['staging_table']}")
        actual_rows = cursor.fetchone()[0]
        
        print()
        print(f"{'─'*80}")
        print(f"✅ Table Complete: {table_name}")
        print(f"   Loaded: {actual_rows:,} rows in {elapsed:.1f}s ({actual_rows/elapsed:.0f} rows/sec)")
        print(f"   Expected: {table_config['expected_rows']:,} rows")
        
        if actual_rows == table_config['expected_rows']:
            print(f"   Status: ✅ PERFECT MATCH")
            return True
        else:
            print(f"   Status: ⚠️  MISMATCH (diff: {actual_rows - table_config['expected_rows']:+,})")
            return False
            
    except Exception as e:
        conn.rollback()
        print(f"\n❌ Transaction rolled back due to error: {e}")
        return False
    finally:
        cursor.close()


def verify_final_counts(conn):
    """Verify final row counts for all tables"""
    cursor = conn.cursor()
    
    print(f"\n{'='*80}")
    print("🔍 FINAL VERIFICATION")
    print(f"{'='*80}\n")
    
    all_passed = True
    
    for table_name, config in TABLES_TO_LOAD.items():
        cursor.execute(f"SELECT COUNT(*) FROM {config['staging_table']}")
        actual = cursor.fetchone()[0]
        expected = config['expected_rows']
        status = "✅ PASS" if actual == expected else "❌ FAIL"
        
        print(f"{table_name:25s} {actual:8,d} / {expected:8,d}  {status}")
        
        if actual != expected:
            all_passed = False
    
    cursor.close()
    
    print()
    return all_passed


def main():
    """Main execution"""
    print("\n" + "="*80)
    print("🚀 V1 DATA BULK RELOAD - PostgreSQL Direct Connection")
    print("="*80)
    print(f"Batch Directory: {BATCH_DIR}")
    print(f"Total Tables: {len(TABLES_TO_LOAD)}")
    print(f"Total Batches: {sum(t['expected_batches'] for t in TABLES_TO_LOAD.values())}")
    print(f"Total Rows: {sum(t['expected_rows'] for t in TABLES_TO_LOAD.values()):,}")
    
    # Get password
    password = get_db_password()
    
    # Connect to database
    conn = connect_to_database(password)
    
    try:
        overall_start = time.time()
        results = {}
        
        # Load each table
        for table_name, config in TABLES_TO_LOAD.items():
            success = load_table(conn, table_name, config)
            results[table_name] = success
        
        # Final verification
        verification_passed = verify_final_counts(conn)
        
        # Summary
        overall_elapsed = time.time() - overall_start
        
        print(f"\n{'='*80}")
        print("📈 RELOAD SUMMARY")
        print(f"{'='*80}")
        print(f"Total Time: {overall_elapsed:.1f}s ({overall_elapsed/60:.1f} minutes)")
        print(f"Success Rate: {sum(results.values())}/{len(results)} tables")
        print()
        
        if all(results.values()) and verification_passed:
            print("✅ SUCCESS! All tables reloaded with correct row counts!")
            print("\n🎯 Next Steps:")
            print("   1. Re-run Phase 2 transformations (V1→V3)")
            print("   2. Handle v1_courses separately (13,238 rows)")
            print("   3. Deploy updated data to production")
            return 0
        else:
            print("⚠️  INCOMPLETE! Some tables have mismatched row counts.")
            print("Review errors above and retry failed tables.")
            return 1
            
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user. Rolling back current transaction...")
        conn.rollback()
        return 1
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        return 1
    finally:
        conn.close()
        print("\n🔌 Database connection closed.")


if __name__ == "__main__":
    sys.exit(main())

