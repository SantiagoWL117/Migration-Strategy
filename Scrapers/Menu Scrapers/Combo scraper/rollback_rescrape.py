#!/usr/bin/env python3
"""
Rollback the incomplete re-scrape run.

This script deletes combo groups data for Milano V3:89 that was inserted
during the incomplete re-scrape run (started at 10:43:43, stopped at 11:37:32).
"""

import sys
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Load environment variables
env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env')
load_dotenv(env_path)

# Database connection string
DB_CONNECTION_STRING = os.getenv('DB_CONNECTION_STRING')

# Restaurant that was being processed
RESTAURANT_ID = 89  # Milano V3:89 (V1:205)

def rollback():
    """Delete combo groups for Milano V3:89."""
    
    print("=" * 70)
    print("ROLLBACK: Delete Incomplete Re-Scrape Data")
    print("=" * 70)
    print(f"Restaurant: Milano (V3: {RESTAURANT_ID}, V1: 205)")
    print()
    
    # Connect to database
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Get count of what will be deleted
        cursor.execute("""
            SELECT COUNT(*) as count FROM menuca_v3.combo_groups
            WHERE restaurant_id = %s
        """, (RESTAURANT_ID,))
        combo_groups_count = cursor.fetchone()['count']
        
        cursor.execute("""
            SELECT COUNT(*) as count FROM menuca_v3.combo_group_sections cgs
            JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = %s
        """, (RESTAURANT_ID,))
        sections_count = cursor.fetchone()['count']
        
        cursor.execute("""
            SELECT COUNT(*) as count FROM menuca_v3.combo_modifier_groups cmg
            JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = %s
        """, (RESTAURANT_ID,))
        modifier_groups_count = cursor.fetchone()['count']
        
        cursor.execute("""
            SELECT COUNT(*) as count FROM menuca_v3.combo_modifiers cm
            JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
            JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = %s
        """, (RESTAURANT_ID,))
        modifiers_count = cursor.fetchone()['count']
        
        cursor.execute("""
            SELECT COUNT(*) as count FROM menuca_v3.combo_modifier_prices cmp
            JOIN menuca_v3.combo_modifiers cm ON cmp.combo_modifier_id = cm.id
            JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
            JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = %s
        """, (RESTAURANT_ID,))
        prices_count = cursor.fetchone()['count']
        
        print("Data to be deleted:")
        print(f"  - Combo Groups: {combo_groups_count}")
        print(f"  - Sections: {sections_count}")
        print(f"  - Modifier Groups: {modifier_groups_count}")
        print(f"  - Modifiers: {modifiers_count}")
        print(f"  - Prices: {prices_count}")
        print()
        
        if combo_groups_count == 0:
            print("No data found to delete.")
            return
        
        # Ask for confirmation
        response = input("Are you sure you want to delete this data? (yes/no): ")
        if response.lower() != 'yes':
            print("Rollback cancelled.")
            return
        
        print()
        print("Deleting data...")
        
        # Delete in reverse order (child tables first)
        # combo_modifier_prices
        cursor.execute("""
            DELETE FROM menuca_v3.combo_modifier_prices
            WHERE combo_modifier_id IN (
                SELECT cm.id FROM menuca_v3.combo_modifiers cm
                JOIN menuca_v3.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
                JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id = %s
            )
        """, (RESTAURANT_ID,))
        print(f"✓ Deleted {cursor.rowcount} combo_modifier_prices")
        
        # combo_modifiers
        cursor.execute("""
            DELETE FROM menuca_v3.combo_modifiers
            WHERE combo_modifier_group_id IN (
                SELECT cmg.id FROM menuca_v3.combo_modifier_groups cmg
                JOIN menuca_v3.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id = %s
            )
        """, (RESTAURANT_ID,))
        print(f"✓ Deleted {cursor.rowcount} combo_modifiers")
        
        # combo_modifier_groups
        cursor.execute("""
            DELETE FROM menuca_v3.combo_modifier_groups
            WHERE combo_group_section_id IN (
                SELECT cgs.id FROM menuca_v3.combo_group_sections cgs
                JOIN menuca_v3.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id = %s
            )
        """, (RESTAURANT_ID,))
        print(f"✓ Deleted {cursor.rowcount} combo_modifier_groups")
        
        # combo_group_sections
        cursor.execute("""
            DELETE FROM menuca_v3.combo_group_sections
            WHERE combo_group_id IN (
                SELECT id FROM menuca_v3.combo_groups
                WHERE restaurant_id = %s
            )
        """, (RESTAURANT_ID,))
        print(f"✓ Deleted {cursor.rowcount} combo_group_sections")
        
        # combo_groups
        cursor.execute("""
            DELETE FROM menuca_v3.combo_groups
            WHERE restaurant_id = %s
        """, (RESTAURANT_ID,))
        print(f"✓ Deleted {cursor.rowcount} combo_groups")
        
        # Commit the transaction
        conn.commit()
        
        print()
        print("=" * 70)
        print("✅ ROLLBACK COMPLETE")
        print("=" * 70)
        print()
        print("All combo groups data for Milano V3:89 has been deleted.")
        print("You can now re-run the scraper with the fixes applied.")
        
    except Exception as e:
        conn.rollback()
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    print()
    rollback()



