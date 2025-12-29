"""
Verification Script: Query modifier data for 5 test restaurants

Use this script after running test_5_restaurants_v2.py to verify:
1. All modifiers are stored (including duplicates with same name)
2. Each modifier has correct source_id
3. Prices are correct for each modifier
4. is_active status is correct

Key test cases:
- Asia Garden Ottawa: Should have 2 "Chow Mein" modifiers with different source_ids
- Aylmer BBQ: Should have 2 "Garlic" modifiers with different prices
- Little Gyros Greek Grill: Greek Salad should be active in correct groups
"""

import sys
import psycopg2

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# Test restaurants
TEST_RESTAURANTS = {
    735: "Amicci Pizza",
    630: "Asia Garden Ottawa",
    756: "Little Gyros Greek Grill",
    69: "Aylmer BBQ",
    328: "JN Pizza",
}


def query_restaurant(conn, v3_id: int, name: str):
    """Query and display all modifier data for a restaurant."""
    print(f"\n{'='*80}")
    print(f"RESTAURANT: {name} (V3 ID: {v3_id})")
    print(f"{'='*80}")
    
    with conn.cursor() as cur:
        # Get modifier groups
        cur.execute("""
            SELECT id, name, category, source_system
            FROM menuca_v3.modifier_groups
            WHERE restaurant_id = %s
            ORDER BY name
        """, (v3_id,))
        
        groups = cur.fetchall()
        
        if not groups:
            print("  No modifier groups found!")
            return
        
        print(f"\nTotal Modifier Groups: {len(groups)}")
        
        for group_id, group_name, category, source_system in groups:
            print(f"\n  MODIFIER GROUP: {group_name}")
            print(f"    ID: {group_id} | Category: {category} | V1 ID: {source_system}")
            print(f"    {'-'*60}")
            
            # Get modifiers for this group
            cur.execute("""
                SELECT m.id, m.name, m.source_id, m.is_active, m.display_order
                FROM menuca_v3.modifiers m
                WHERE m.modifier_group_id = %s
                ORDER BY m.display_order
            """, (group_id,))
            
            modifiers = cur.fetchall()
            
            active_count = sum(1 for m in modifiers if m[3])
            inactive_count = len(modifiers) - active_count
            print(f"    Modifiers: {len(modifiers)} total ({active_count} active, {inactive_count} inactive)")
            print()
            
            for mod_id, mod_name, source_id, is_active, display_order in modifiers:
                status = "[ACTIVE]  " if is_active else "[inactive]"
                
                # Get prices
                cur.execute("""
                    SELECT size_variant, price
                    FROM menuca_v3.modifier_prices
                    WHERE modifier_id = %s
                    ORDER BY display_order
                """, (mod_id,))
                
                prices = cur.fetchall()
                
                if len(prices) == 1:
                    price_str = f"${prices[0][1]:.2f}"
                else:
                    price_parts = [f"{p[0] or 'Base'}: ${p[1]:.2f}" for p in prices]
                    price_str = " | ".join(price_parts)
                
                print(f"      {status} {mod_name}")
                print(f"               V3 ID: {mod_id} | Source ID: {source_id} | Price: {price_str}")


def check_duplicates(conn):
    """Check for modifiers with same name but different source_ids."""
    print(f"\n{'='*80}")
    print("DUPLICATE NAME CHECK (Same name, different source_ids)")
    print(f"{'='*80}")
    
    with conn.cursor() as cur:
        cur.execute("""
            SELECT 
                mg.restaurant_id,
                r.name as restaurant_name,
                mg.name as group_name,
                m.name as modifier_name,
                COUNT(*) as count,
                STRING_AGG(m.source_id, ', ' ORDER BY m.source_id) as source_ids
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            JOIN menuca_v3.restaurants r ON mg.restaurant_id = r.id
            WHERE mg.restaurant_id IN (735, 630, 756, 69, 328)
            GROUP BY mg.restaurant_id, r.name, mg.name, m.name
            HAVING COUNT(*) > 1
            ORDER BY restaurant_name, group_name, modifier_name
        """)
        
        duplicates = cur.fetchall()
        
        if not duplicates:
            print("\n  No duplicate names found (this may indicate an issue)")
        else:
            print(f"\n  Found {len(duplicates)} modifier names with multiple source_ids:")
            for rest_id, rest_name, group_name, mod_name, count, source_ids in duplicates:
                print(f"\n    Restaurant: {rest_name}")
                print(f"    Group: {group_name}")
                print(f"    Modifier: {mod_name}")
                print(f"    Count: {count}")
                print(f"    Source IDs: {source_ids}")


def specific_error_checks(conn):
    """Check specific error cases from the analysis."""
    print(f"\n{'='*80}")
    print("SPECIFIC ERROR CASE VERIFICATION")
    print(f"{'='*80}")
    
    with conn.cursor() as cur:
        # Check 1: Asia Garden Ottawa - Chow Mein in Chow Mein group (ID 9790)
        print("\n  1. Asia Garden Ottawa - 'Chow Mein' modifier in 'Chow Mein' group:")
        cur.execute("""
            SELECT m.name, m.source_id, m.is_active, mp.price
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
            WHERE mg.restaurant_id = 630
              AND mg.source_system = '9790'
              AND m.name ILIKE '%Chow Mein%'
            ORDER BY m.source_id
        """)
        for row in cur.fetchall():
            status = "ACTIVE" if row[2] else "inactive"
            print(f"     {row[0]} | source_id: {row[1]} | {status} | ${row[3]:.2f}")
        
        # Check 2: Asia Garden Ottawa - Chow Mein in Pork/Shrimp/Chicken group (ID 8105)
        print("\n  2. Asia Garden Ottawa - 'Chow Mein' in 'Pork/Shrimp/Chicken' group:")
        cur.execute("""
            SELECT m.name, m.source_id, m.is_active, mp.price
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
            WHERE mg.restaurant_id = 630
              AND mg.source_system = '8105'
              AND m.name ILIKE '%Chow Mein%'
            ORDER BY m.source_id
        """)
        for row in cur.fetchall():
            status = "ACTIVE" if row[2] else "inactive"
            print(f"     {row[0]} | source_id: {row[1]} | {status} | ${row[3]:.2f}")
        
        # Check 3: Aylmer BBQ - Garlic modifiers
        print("\n  3. Aylmer BBQ - All 'Garlic' modifiers across groups:")
        cur.execute("""
            SELECT mg.name as group_name, m.name, m.source_id, m.is_active, mp.price
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
            WHERE mg.restaurant_id = 69
              AND m.name ILIKE '%Garlic%'
            ORDER BY mg.name, m.source_id
        """)
        for row in cur.fetchall():
            status = "ACTIVE" if row[3] else "inactive"
            print(f"     [{row[0]}] {row[1]} | source_id: {row[2]} | {status} | ${row[4]:.2f}")
        
        # Check 4: Little Gyros - Greek Salad
        print("\n  4. Little Gyros Greek Grill - All 'Greek Salad' modifiers:")
        cur.execute("""
            SELECT mg.name as group_name, m.name, m.source_id, m.is_active, mp.price
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            LEFT JOIN menuca_v3.modifier_prices mp ON m.id = mp.modifier_id
            WHERE mg.restaurant_id = 756
              AND m.name ILIKE '%Greek Salad%'
            ORDER BY mg.name, m.source_id
        """)
        for row in cur.fetchall():
            status = "ACTIVE" if row[3] else "inactive"
            print(f"     [{row[0]}] {row[1]} | source_id: {row[2]} | {status} | ${row[4]:.2f}")


def main():
    """Main function."""
    try:
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        
        # Query each test restaurant
        for v3_id, name in TEST_RESTAURANTS.items():
            query_restaurant(conn, v3_id, name)
        
        # Check for duplicates
        check_duplicates(conn)
        
        # Specific error checks
        specific_error_checks(conn)
        
        conn.close()
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()



