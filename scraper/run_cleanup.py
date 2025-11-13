#!/usr/bin/env python3
"""
Execute Schema Cleanup via Python
Runs the cleanup operations directly through psycopg2
"""

import psycopg2
from config import DB_CONNECTION_STRING, SCHEMA

def run_cleanup():
    """Execute the schema cleanup."""
    print("=" * 60)
    print("Starting Schema Cleanup")
    print("=" * 60)

    conn = None
    try:
        # Connect to database
        print("\nConnecting to database...")
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        conn.autocommit = False  # Use transactions
        cursor = conn.cursor()
        print("Connected successfully!")

        # Step 1: Delete data from dependent tables
        print("\nStep 1: Cleaning dependent tables...")

        dependent_deletes = [
            "DELETE FROM menuca_v3.order_items",
            "DELETE FROM menuca_v3.user_favorite_dishes",
            "DELETE FROM menuca_v3.dish_allergens",
            "DELETE FROM menuca_v3.dish_dietary_tags",
            "DELETE FROM menuca_v3.dish_inventory",
            "DELETE FROM menuca_v3.dish_size_options",
            "DELETE FROM menuca_v3.dish_translations",
            "DELETE FROM menuca_v3.dish_modifiers",
            "DELETE FROM menuca_v3.dish_modifier_prices_legacy",
            "DELETE FROM menuca_v3.course_translations",
            "DELETE FROM menuca_v3.modifier_group_translations",
        ]

        for sql in dependent_deletes:
            cursor.execute(sql)
            print(f"   Executed: {sql.split('FROM')[1].strip()}")

        # Step 2: Delete core table data
        print("\nStep 2: Cleaning core tables...")

        cursor.execute("DELETE FROM menuca_v3.modifier_groups")
        print("   Deleted data from modifier_groups")

        cursor.execute("DELETE FROM menuca_v3.dish_prices")
        print("   Deleted data from dish_prices")

        cursor.execute("DELETE FROM menuca_v3.dishes")
        print("   Deleted data from dishes")

        cursor.execute("DELETE FROM menuca_v3.courses")
        print("   Deleted data from courses")

        # Step 3: Remove constraints
        print("\nStep 3: Removing constraints...")

        # Courses constraints
        cursor.execute("ALTER TABLE menuca_v3.courses DROP CONSTRAINT IF EXISTS courses_restaurant_id_name_key")
        cursor.execute("ALTER TABLE menuca_v3.courses DROP CONSTRAINT IF EXISTS courses_source_system_check")
        cursor.execute("ALTER TABLE menuca_v3.courses DROP CONSTRAINT IF EXISTS courses_restaurant_id_fkey")
        print("   Removed courses constraints")

        # Dishes constraints
        cursor.execute("ALTER TABLE menuca_v3.dishes DROP CONSTRAINT IF EXISTS dishes_source_system_check")
        cursor.execute("ALTER TABLE menuca_v3.dishes DROP CONSTRAINT IF EXISTS dishes_course_id_fkey")
        cursor.execute("ALTER TABLE menuca_v3.dishes DROP CONSTRAINT IF EXISTS dishes_restaurant_id_fkey")
        cursor.execute("ALTER TABLE menuca_v3.dishes DROP CONSTRAINT IF EXISTS dishes_deleted_by_fkey")
        print("   Removed dishes constraints")

        # Dish prices constraints
        cursor.execute("ALTER TABLE menuca_v3.dish_prices DROP CONSTRAINT IF EXISTS dish_prices_price_check")
        cursor.execute("ALTER TABLE menuca_v3.dish_prices DROP CONSTRAINT IF EXISTS dish_prices_dish_id_fkey")
        print("   Removed dish_prices constraints")

        # Modifier groups constraints
        cursor.execute("ALTER TABLE menuca_v3.modifier_groups DROP CONSTRAINT IF EXISTS modifier_groups_check")
        cursor.execute("ALTER TABLE menuca_v3.modifier_groups DROP CONSTRAINT IF EXISTS modifier_groups_min_selections_check")
        cursor.execute("ALTER TABLE menuca_v3.modifier_groups DROP CONSTRAINT IF EXISTS valid_selection_range")
        cursor.execute("ALTER TABLE menuca_v3.modifier_groups DROP CONSTRAINT IF EXISTS modifier_groups_dish_id_fkey")
        cursor.execute("ALTER TABLE menuca_v3.modifier_groups DROP CONSTRAINT IF EXISTS modifier_groups_parent_modifier_id_fkey")
        print("   Removed modifier_groups constraints")

        # Step 4: Drop tables
        print("\nStep 4: Dropping tables...")

        tables_to_drop = [
            "dish_modifier_items",
            "dish_modifier_groups",
            "ingredient_group_items",
            "dish_ingredients",
            "ingredient_groups",
            "ingredients",
            "combo_items",
            "combo_groups",
        ]

        for table in tables_to_drop:
            cursor.execute(f"DROP TABLE IF EXISTS menuca_v3.{table} CASCADE")
            print(f"   Dropped {table}")

        # Commit transaction
        conn.commit()
        print("\n" + "=" * 60)
        print("Schema cleanup completed successfully!")
        print("=" * 60)

    except Exception as e:
        if conn:
            conn.rollback()
        print(f"\nERROR: Cleanup failed: {e}")
        print("Transaction rolled back.")
        return False
    finally:
        if conn:
            cursor.close()
            conn.close()
            print("\nDatabase connection closed.")

    return True

if __name__ == "__main__":
    success = run_cleanup()
    exit(0 if success else 1)
