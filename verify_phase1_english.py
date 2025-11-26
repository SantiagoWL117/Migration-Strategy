#!/usr/bin/env python3
"""
Verify Phase 1 English scraping results
"""
import psycopg2
import logging
import sys
from dotenv import load_dotenv
import os

load_dotenv()

# Database connection
def get_db_connection():
    return psycopg2.connect(
        "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
    )

def verify_phase1_english():
    """Verify Phase 1 English data for all V2 English restaurants"""
    
    restaurants = {
        977: "Capri Pizza",
        950: "Kirkwood Pizza",
        952: "River Pizza",
        954: "Wandee Thai",
        957: "Cosenza",
        971: "Little Gyros Greek Grill",
        973: "Capital Bites",
        974: "Pachino Pizza",
        981: "Al-s Drive In"
    }
    
    print("=" * 100)
    print("PHASE 1 ENGLISH - DATA VERIFICATION")
    print("=" * 100)
    
    conn = get_db_connection()
    cur = conn.cursor()
    
    try:
        total_courses_all = 0
        total_dishes_all = 0
        total_prices_all = 0
        
        print(f"\n{'Restaurant':<30} | {'Courses':<8} | {'Dishes':<8} | {'Prices':<8} | {'Status':<10}")
        print("-" * 100)
        
        for db_id, name in restaurants.items():
            # Count courses
            cur.execute("""
                SELECT COUNT(*) FROM menuca_v3.courses 
                WHERE restaurant_id = %s AND source_id IS NOT NULL
            """, (db_id,))
            courses_count = cur.fetchone()[0]
            
            # Count dishes with source_id
            cur.execute("""
                SELECT COUNT(*) FROM menuca_v3.dishes 
                WHERE restaurant_id = %s AND source_id IS NOT NULL
            """, (db_id,))
            dishes_count = cur.fetchone()[0]
            
            # Count prices
            cur.execute("""
                SELECT COUNT(*) FROM menuca_v3.dish_prices dp
                JOIN menuca_v3.dishes d ON d.id = dp.dish_id
                WHERE d.restaurant_id = %s
            """, (db_id,))
            prices_count = cur.fetchone()[0]
            
            status = "OK" if (courses_count > 0 and dishes_count > 0 and prices_count > 0) else "MISSING"
            
            print(f"{name:<30} | {courses_count:<8} | {dishes_count:<8} | {prices_count:<8} | {status:<10}")
            
            total_courses_all += courses_count
            total_dishes_all += dishes_count
            total_prices_all += prices_count
        
        print("\n" + "=" * 100)
        print("SUMMARY")
        print("=" * 100)
        print(f"Total restaurants: {len(restaurants)}")
        print(f"Total courses: {total_courses_all}")
        print(f"Total dishes: {total_dishes_all}")
        print(f"Total prices: {total_prices_all}")
        
        # Sample dishes from Capri Pizza
        print("\n" + "=" * 100)
        print("SAMPLE: Capri Pizza - First 10 dishes")
        print("=" * 100)
        
        cur.execute("""
            SELECT 
                c.name as course_name,
                d.name as dish_name,
                d.source_id as v2_dish_id,
                COUNT(dp.id) as num_prices
            FROM menuca_v3.dishes d
            JOIN menuca_v3.courses c ON c.id = d.course_id
            LEFT JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id
            WHERE d.restaurant_id = 977
            GROUP BY d.id, d.name, d.source_id, d.display_order, c.name
            ORDER BY d.display_order
            LIMIT 10
        """)
        
        sample_dishes = cur.fetchall()
        for dish in sample_dishes:
            print(f"  {dish[0]}: {dish[1]} (V2: {dish[2]}, {dish[3]} price(s))")
        
        # Check for issues
        print("\n" + "=" * 100)
        print("VALIDATION")
        print("=" * 100)
        
        issues = []
        if total_courses_all == 0:
            issues.append("ERROR: No courses found!")
        if total_dishes_all == 0:
            issues.append("ERROR: No dishes found!")
        if total_prices_all == 0:
            issues.append("ERROR: No prices found!")
        
        if issues:
            print("ISSUES FOUND:")
            for issue in issues:
                print(f"  {issue}")
        else:
            print("SUCCESS: ALL CHECKS PASSED!")
            print(f"\n  - {total_courses_all} courses with valid source_id")
            print(f"  - {total_dishes_all} dishes with valid source_id")
            print(f"  - {total_prices_all} dish prices")
        
        print("=" * 100)
        
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    verify_phase1_english()

