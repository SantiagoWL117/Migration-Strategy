"""
Cleanup script to delete modifiers with NULL source_id and their associated prices.
Keeps the 5 test restaurants that were scraped correctly with V2.
"""
import psycopg2

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# 5 test restaurants (V3 IDs) - these should have source_ids populated
TEST_RESTAURANT_IDS = [69, 630, 756, 735, 328]

def main():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()
    
    print("=" * 60)
    print("CHECKING 5 TEST RESTAURANTS")
    print("=" * 60)
    
    for v3_id in TEST_RESTAURANT_IDS:
        # Get restaurant name
        cur.execute("SELECT name FROM menuca_v3.restaurants WHERE id = %s", (v3_id,))
        name = cur.fetchone()[0]
        
        # Count modifiers with and without source_id
        cur.execute("""
            SELECT 
                COUNT(*) FILTER (WHERE m.source_id IS NULL) as null_count,
                COUNT(*) FILTER (WHERE m.source_id IS NOT NULL) as has_count
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            WHERE mg.restaurant_id = %s
        """, (v3_id,))
        null_count, has_count = cur.fetchone()
        
        status = "[OK]" if null_count == 0 else "[HAS NULL]"
        print(f"{name} (V3: {v3_id}): {has_count} with source_id, {null_count} NULL - {status}")
    
    print("\n" + "=" * 60)
    print("OVERALL STATISTICS")
    print("=" * 60)
    
    # Total counts
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NULL")
    total_null = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NOT NULL")
    total_has = cur.fetchone()[0]
    
    print(f"Total modifiers with NULL source_id: {total_null}")
    print(f"Total modifiers with source_id: {total_has}")
    
    # Count prices that will be deleted
    cur.execute("""
        SELECT COUNT(*) 
        FROM menuca_v3.modifier_prices mp
        JOIN menuca_v3.modifiers m ON mp.modifier_id = m.id
        WHERE m.source_id IS NULL
    """)
    prices_to_delete = cur.fetchone()[0]
    print(f"Prices to be deleted (associated with NULL source_id modifiers): {prices_to_delete}")
    
    if total_null == 0:
        print("\n[OK] No cleanup needed!")
        cur.close()
        conn.close()
        return
    
    print("\n" + "=" * 60)
    print("CLEANUP")
    print("=" * 60)
    
    # Delete prices first (foreign key constraint)
    print(f"Deleting {prices_to_delete} prices...")
    cur.execute("""
        DELETE FROM menuca_v3.modifier_prices 
        WHERE modifier_id IN (
            SELECT id FROM menuca_v3.modifiers WHERE source_id IS NULL
        )
    """)
    deleted_prices = cur.rowcount
    print(f"  Deleted: {deleted_prices} prices")
    
    # Delete modifiers with NULL source_id
    print(f"Deleting {total_null} modifiers with NULL source_id...")
    cur.execute("DELETE FROM menuca_v3.modifiers WHERE source_id IS NULL")
    deleted_modifiers = cur.rowcount
    print(f"  Deleted: {deleted_modifiers} modifiers")
    
    conn.commit()
    
    print("\n" + "=" * 60)
    print("VERIFICATION")
    print("=" * 60)
    
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NULL")
    remaining_null = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers WHERE source_id IS NOT NULL")
    remaining_has = cur.fetchone()[0]
    
    print(f"Remaining modifiers with NULL source_id: {remaining_null}")
    print(f"Remaining modifiers with source_id: {remaining_has}")
    
    print("\n[OK] Cleanup complete!")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()

