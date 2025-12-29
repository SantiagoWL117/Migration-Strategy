"""Clear ALL modifier data from the database."""
import psycopg2

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

def main():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()
    
    print("=" * 60)
    print("CLEARING ALL MODIFIER DATA")
    print("=" * 60)
    
    # Count before
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifier_prices")
    prices_before = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers")
    modifiers_before = cur.fetchone()[0]
    
    print(f"Before: {modifiers_before} modifiers, {prices_before} prices")
    
    # Delete prices first (foreign key)
    print("\nDeleting all modifier prices...")
    cur.execute("DELETE FROM menuca_v3.modifier_prices")
    deleted_prices = cur.rowcount
    print(f"  Deleted: {deleted_prices} prices")
    
    # Delete modifiers
    print("Deleting all modifiers...")
    cur.execute("DELETE FROM menuca_v3.modifiers")
    deleted_modifiers = cur.rowcount
    print(f"  Deleted: {deleted_modifiers} modifiers")
    
    conn.commit()
    
    # Verify
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifier_prices")
    prices_after = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM menuca_v3.modifiers")
    modifiers_after = cur.fetchone()[0]
    
    print(f"\nAfter: {modifiers_after} modifiers, {prices_after} prices")
    print("\n[OK] All modifier data cleared!")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()






