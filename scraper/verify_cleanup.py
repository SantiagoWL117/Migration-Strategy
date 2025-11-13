#!/usr/bin/env python3
"""
Verify Schema Cleanup Status
Checks if the cleanup script completed successfully
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from database import DatabaseManager
from config import DB_CONNECTION_STRING, SCHEMA

def verify_cleanup():
    """Verify the cleanup was successful."""
    print("=" * 60)
    print("Verifying Schema Cleanup Status")
    print("=" * 60)

    db = DatabaseManager()
    db.connect()

    try:
        # Check data counts in core tables
        print("\n1. Checking data in core tables...")
        tables_to_check = ['courses', 'dishes', 'dish_prices', 'modifier_groups']

        for table in tables_to_check:
            query = f"SELECT COUNT(*) FROM {SCHEMA}.{table}"
            result = db.execute_query(query, fetch_one=True)
            count = result[0] if result else 0
            status = "✓ EMPTY" if count == 0 else f"✗ HAS {count} ROWS"
            print(f"   {table}: {status}")

        # Check constraints on core tables
        print("\n2. Checking constraints on core tables...")

        # Check courses constraints
        query = """
            SELECT conname
            FROM pg_constraint
            WHERE conrelid = 'menuca_v3.courses'::regclass
            AND contype IN ('u', 'c', 'f')
        """
        constraints = db.execute_query(query)
        courses_constraints = [c[0] for c in constraints] if constraints else []
        print(f"   courses constraints: {len(courses_constraints)} found")
        if courses_constraints:
            for c in courses_constraints:
                print(f"      - {c}")

        # Check dishes constraints
        query = """
            SELECT conname
            FROM pg_constraint
            WHERE conrelid = 'menuca_v3.dishes'::regclass
            AND contype IN ('u', 'c', 'f')
        """
        constraints = db.execute_query(query)
        dishes_constraints = [c[0] for c in constraints] if constraints else []
        print(f"   dishes constraints: {len(dishes_constraints)} found")
        if dishes_constraints:
            for c in dishes_constraints:
                print(f"      - {c}")

        # Check if tables were dropped
        print("\n3. Checking if tables were dropped...")
        tables_to_drop = [
            'dish_modifier_groups',
            'dish_modifier_items',
            'ingredients',
            'ingredient_groups',
            'ingredient_group_items',
            'dish_ingredients',
            'combo_groups',
            'combo_items'
        ]

        for table in tables_to_drop:
            query = f"""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_schema = '{SCHEMA}'
                    AND table_name = '{table}'
                )
            """
            result = db.execute_query(query, fetch_one=True)
            exists = result[0] if result else True
            status = "✗ STILL EXISTS" if exists else "✓ DROPPED"
            print(f"   {table}: {status}")

        print("\n" + "=" * 60)
        print("Verification Complete")
        print("=" * 60)

    except Exception as e:
        print(f"Error during verification: {e}")
        return False
    finally:
        db.close()

    return True

if __name__ == "__main__":
    verify_cleanup()
