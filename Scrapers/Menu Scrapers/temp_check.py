import psycopg2
import os
from dotenv import load_dotenv

# Load environment variables
env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), '.env files', '.env.supabase')
load_dotenv(env_path)

DB_HOST = os.getenv('DB_HOST')
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_PORT = os.getenv('DB_PORT', '5432')

def main():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )
    
    cursor = conn.cursor()
    
    # Get RLS policies for Delivery & Zones Entity tables
    query = """
    SELECT 
        schemaname,
        tablename,
        policyname,
        permissive,
        roles,
        cmd,
        qual,
        with_check
    FROM pg_policies
    WHERE schemaname = 'menuca_v3'
    AND tablename IN (
        'restaurant_schedules',
        'restaurant_special_schedules',
        'restaurant_delivery_areas',
        'delivery_and_pickup_configs',
        'restaurant_delivery_companies',
        'restaurant_distance_based_delivery_fees',
        'delivery_company_emails',
        'user_delivery_addresses'
    )
    ORDER BY tablename, policyname;
    """
    
    cursor.execute(query)
    rows = cursor.fetchall()
    
    print("=" * 100)
    print("DELIVERY & ZONES ENTITY - RLS POLICIES")
    print("=" * 100)
    
    current_table = None
    table_count = {}
    
    for row in rows:
        schema, table, policy, permissive, roles, cmd, qual, with_check = row
        
        if table != current_table:
            if current_table:
                print()
            current_table = table
            print(f"\n{'='*80}")
            print(f"TABLE: {table}")
            print(f"{'='*80}")
        
        if table not in table_count:
            table_count[table] = 0
        table_count[table] += 1
        
        roles_str = ', '.join(roles) if roles else 'N/A'
        perm_type = 'PERMISSIVE' if permissive == 'PERMISSIVE' else 'RESTRICTIVE'
        
        print(f"\n  Policy: {policy}")
        print(f"  Type: {perm_type} | Command: {cmd} | Roles: {roles_str}")
        if qual:
            print(f"  USING: {qual[:200]}..." if len(str(qual)) > 200 else f"  USING: {qual}")
        if with_check:
            print(f"  WITH CHECK: {with_check[:200]}..." if len(str(with_check)) > 200 else f"  WITH CHECK: {with_check}")
    
    print("\n" + "=" * 100)
    print("SUMMARY BY TABLE")
    print("=" * 100)
    for table, count in table_count.items():
        print(f"  {table}: {count} policies")
    print(f"\nTOTAL POLICIES: {sum(table_count.values())}")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()

