"""Check if the 5 test restaurants have the price bug (inactive modifiers with $0.00)."""
import psycopg2

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

TEST_RESTAURANTS = [
    (69, "Aylmer BBQ"),
    (630, "Asia Garden Ottawa"),
    (756, "Little Gyros Greek Grill"),
    (735, "Amicci Pizza"),
    (328, "JN Pizza"),
]

def main():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()
    
    print("=" * 80)
    print("CHECKING FOR PRICE BUG IN 5 TEST RESTAURANTS")
    print("Looking for INACTIVE modifiers with $0.00 price")
    print("=" * 80)
    
    for v3_id, name in TEST_RESTAURANTS:
        print(f"\n{'='*80}")
        print(f"RESTAURANT: {name} (V3: {v3_id})")
        print("="*80)
        
        # Find inactive modifiers with $0.00 price
        cur.execute("""
            SELECT mg.name as group_name, m.name as modifier_name, m.source_id,
                   COALESCE(mp.price, 0) as price
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
            WHERE mg.restaurant_id = %s 
              AND m.is_active = false
            ORDER BY mg.name, m.name
        """, (v3_id,))
        
        results = cur.fetchall()
        
        zero_price_count = 0
        non_zero_count = 0
        
        for group_name, mod_name, source_id, price in results:
            if price == 0:
                zero_price_count += 1
                print(f"  [ZERO] {group_name} -> {mod_name} (ID: {source_id}) = $0.00")
            else:
                non_zero_count += 1
        
        print(f"\n  Summary: {zero_price_count} inactive with $0.00, {non_zero_count} inactive with price > $0")
        
        if zero_price_count > 0:
            print("  [WARNING] May be affected by price bug!")
        else:
            print("  [OK] No suspicious $0.00 prices found")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()

