"""
Run Database Migrations

This script applies the SQL migrations to:
1. Add source_id column to modifiers table
2. Change unique constraint from (modifier_group_id, name) to (modifier_group_id, source_id)
3. Clear existing modifier data for re-scraping

Usage:
    python run_migrations.py --apply    # Run both migrations
    python run_migrations.py --schema   # Only apply schema changes (001)
    python run_migrations.py --clear    # Only clear data (002)
    python run_migrations.py --check    # Just verify current schema
"""

import argparse
import psycopg2
from pathlib import Path

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

MIGRATIONS_DIR = Path(__file__).parent / "migrations"


def check_schema(conn):
    """Check current schema of modifiers table."""
    print("\n" + "="*60)
    print("CURRENT SCHEMA CHECK")
    print("="*60)
    
    with conn.cursor() as cur:
        # Check columns
        cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_schema = 'menuca_v3' 
            AND table_name = 'modifiers'
            ORDER BY ordinal_position
        """)
        
        columns = cur.fetchall()
        print("\nColumns in menuca_v3.modifiers:")
        for col, dtype, nullable in columns:
            null_str = "NULL" if nullable == 'YES' else "NOT NULL"
            print(f"  - {col}: {dtype} ({null_str})")
        
        # Check for source_id column
        source_id_exists = any(col[0] == 'source_id' for col in columns)
        print(f"\nsource_id column exists: {source_id_exists}")
        
        # Check constraints
        cur.execute("""
            SELECT tc.constraint_name, tc.constraint_type
            FROM information_schema.table_constraints tc
            WHERE tc.table_schema = 'menuca_v3' 
            AND tc.table_name = 'modifiers'
        """)
        
        constraints = cur.fetchall()
        print("\nConstraints:")
        for name, ctype in constraints:
            print(f"  - {name} ({ctype})")
        
        # Check row counts
        cur.execute("SELECT COUNT(*) FROM menuca_v3.modifier_groups")
        group_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers")
        mod_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM menuca_v3.modifier_prices")
        price_count = cur.fetchone()[0]
        
        print(f"\nRow counts:")
        print(f"  - modifier_groups: {group_count}")
        print(f"  - modifiers: {mod_count}")
        print(f"  - modifier_prices: {price_count}")
        
        return source_id_exists


def apply_schema_migration(conn):
    """Apply schema migration (001_add_source_id_to_modifiers.sql)."""
    print("\n" + "="*60)
    print("APPLYING SCHEMA MIGRATION")
    print("="*60)
    
    with conn.cursor() as cur:
        # Step 1: Add source_id column
        print("\nStep 1: Adding source_id column...")
        try:
            cur.execute("""
                ALTER TABLE menuca_v3.modifiers 
                ADD COLUMN IF NOT EXISTS source_id VARCHAR(50)
            """)
            print("  - source_id column added (or already exists)")
        except Exception as e:
            print(f"  - Error: {e}")
            raise
        
        # Step 2: Drop old unique constraint on (modifier_group_id, name)
        print("\nStep 2: Dropping old unique constraint...")
        cur.execute("""
            SELECT tc.constraint_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.constraint_column_usage ccu 
                ON tc.constraint_name = ccu.constraint_name
            WHERE tc.table_schema = 'menuca_v3' 
            AND tc.table_name = 'modifiers' 
            AND tc.constraint_type = 'UNIQUE'
            AND ccu.column_name = 'name'
        """)
        
        constraint = cur.fetchone()
        if constraint:
            constraint_name = constraint[0]
            cur.execute(f"ALTER TABLE menuca_v3.modifiers DROP CONSTRAINT IF EXISTS {constraint_name}")
            print(f"  - Dropped constraint: {constraint_name}")
        else:
            print("  - No existing unique constraint on 'name' found")
        
        # Step 3: Create new unique constraint on (modifier_group_id, source_id)
        print("\nStep 3: Creating new unique constraint on (modifier_group_id, source_id)...")
        try:
            cur.execute("""
                ALTER TABLE menuca_v3.modifiers 
                DROP CONSTRAINT IF EXISTS modifiers_group_source_unique
            """)
            cur.execute("""
                ALTER TABLE menuca_v3.modifiers 
                ADD CONSTRAINT modifiers_group_source_unique 
                UNIQUE (modifier_group_id, source_id)
            """)
            print("  - Created constraint: modifiers_group_source_unique")
        except Exception as e:
            print(f"  - Error: {e}")
            raise
        
        # Step 4: Create index
        print("\nStep 4: Creating index on source_id...")
        try:
            cur.execute("""
                CREATE INDEX IF NOT EXISTS idx_modifiers_source_id 
                ON menuca_v3.modifiers(source_id)
            """)
            print("  - Created index: idx_modifiers_source_id")
        except Exception as e:
            print(f"  - Error: {e}")
        
        conn.commit()
        print("\nSchema migration completed successfully!")


def clear_modifier_data(conn):
    """Clear modifier data (002_clear_modifier_data.sql)."""
    print("\n" + "="*60)
    print("CLEARING MODIFIER DATA")
    print("="*60)
    
    with conn.cursor() as cur:
        # Get counts before
        cur.execute("SELECT COUNT(*) FROM menuca_v3.modifier_prices")
        price_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers")
        mod_count = cur.fetchone()[0]
        
        print(f"\nBefore deletion:")
        print(f"  - modifier_prices: {price_count}")
        print(f"  - modifiers: {mod_count}")
        
        # Confirm
        response = input("\nThis will DELETE all modifier and price data. Continue? (yes/no): ")
        if response.lower() != 'yes':
            print("Aborted.")
            return
        
        # Delete prices first (foreign key)
        cur.execute("DELETE FROM menuca_v3.modifier_prices")
        print(f"\nDeleted {price_count} prices")
        
        # Delete modifiers
        cur.execute("DELETE FROM menuca_v3.modifiers")
        print(f"Deleted {mod_count} modifiers")
        
        conn.commit()
        print("\nData cleared successfully!")


def main():
    parser = argparse.ArgumentParser(description="Run database migrations for V2 scraper")
    parser.add_argument('--apply', action='store_true', help='Apply all migrations')
    parser.add_argument('--schema', action='store_true', help='Only apply schema changes')
    parser.add_argument('--clear', action='store_true', help='Only clear data')
    parser.add_argument('--check', action='store_true', help='Just check current schema')
    
    args = parser.parse_args()
    
    if not any([args.apply, args.schema, args.clear, args.check]):
        parser.print_help()
        return
    
    try:
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        
        if args.check:
            check_schema(conn)
        elif args.apply:
            check_schema(conn)
            apply_schema_migration(conn)
            clear_modifier_data(conn)
            check_schema(conn)
        elif args.schema:
            check_schema(conn)
            apply_schema_migration(conn)
            check_schema(conn)
        elif args.clear:
            clear_modifier_data(conn)
        
        conn.close()
        
    except Exception as e:
        print(f"Error: {e}")
        raise


if __name__ == "__main__":
    main()



