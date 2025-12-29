"""Query modifier data for a restaurant by V3 ID."""
import sys
import psycopg2

# Database connection
DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

def query_restaurant(v3_id: int):
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()
    
    # Get restaurant name
    cur.execute("""
        SELECT name FROM menuca_v3.restaurants WHERE id = %s
    """, (v3_id,))
    result = cur.fetchone()
    if not result:
        print(f"Restaurant with V3 ID {v3_id} not found")
        return
    
    restaurant_name = result[0]
    
    print("=" * 100)
    print(f"RESTAURANT: {restaurant_name} (V3 ID: {v3_id})")
    print("=" * 100)
    
    # Get modifier groups
    cur.execute("""
        SELECT id, name, category
        FROM menuca_v3.modifier_groups
        WHERE restaurant_id = %s
        ORDER BY name
    """, (v3_id,))
    groups = cur.fetchall()
    
    print(f"\nTotal Modifier Groups: {len(groups)}")
    
    for group_id, group_name, category in groups:
        print("\n" + "=" * 100)
        print(f"MODIFIER GROUP: {group_name}")
        print(f"  V3 ID: {group_id} | Category: {category}")
        print("-" * 100)
        
        # Get modifiers for this group
        cur.execute("""
            SELECT m.id, m.name, m.is_active, m.source_id
            FROM menuca_v3.modifiers m
            WHERE m.modifier_group_id = %s
            ORDER BY m.is_active DESC, m.name
        """, (group_id,))
        modifiers = cur.fetchall()
        
        active_count = sum(1 for m in modifiers if m[2])
        inactive_count = len(modifiers) - active_count
        print(f"  Active: {active_count} | Inactive: {inactive_count}")
        
        for mod_id, mod_name, is_active, mod_source_id in modifiers:
            status = "[ACTIVE]  " if is_active else "[inactive]"
            
            # Get prices
            cur.execute("""
                SELECT size_variant, price
                FROM menuca_v3.modifier_prices
                WHERE modifier_id = %s
                ORDER BY price
            """, (mod_id,))
            prices = cur.fetchall()
            
            if prices:
                if len(prices) == 1:
                    price_str = f"${prices[0][1]:.2f}"
                else:
                    price_str = " | ".join([f"{p[0]}: ${p[1]:.2f}" for p in prices])
            else:
                price_str = "No price"
            
            print(f"\n  {status} {mod_name}")
            print(f"             source_id: {mod_source_id} | Price: {price_str}")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python query_by_id.py <v3_restaurant_id>")
        sys.exit(1)
    
    v3_id = int(sys.argv[1])
    query_restaurant(v3_id)
