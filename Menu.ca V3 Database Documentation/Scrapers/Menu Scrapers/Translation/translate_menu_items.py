"""
Menu Translation Script
Translates missing French/English values for bilingual menu support.

For English restaurants: name_en exists -> translate to name_fr
For French restaurants: name_fr exists -> translate to name_en

This script uses the identified French restaurant IDs to determine translation direction.
"""

import os
import sys
from datetime import datetime
from typing import Optional
import psycopg2
from psycopg2.extras import RealDictCursor

# Database connection string
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
)

# French restaurant IDs (identified in Phase 2)
FRENCH_RESTAURANT_IDS = [
    # Known French restaurants
    966, 964, 963, 967, 961, 965, 825,
    # Detected French restaurants (>40% French dishes)
    727, 712, 736, 70, 798, 696, 562, 716, 820, 726, 614, 644
]

# Tables and columns to translate
TRANSLATION_CONFIG = [
    {
        "table": "courses",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "description_en": "description_en",
        "description_fr": "description_fr",
        "restaurant_id_path": "restaurant_id"
    },
    {
        "table": "dishes",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "description_en": "description_en", 
        "description_fr": "description_fr",
        "restaurant_id_path": "course.restaurant_id"  # Join through courses
    },
    {
        "table": "modifier_groups",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "restaurant_id"
    },
    {
        "table": "modifiers",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "modifier_group.restaurant_id"  # Join through modifier_groups
    },
    {
        "table": "modifier_group_details",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "dish.course.restaurant_id"  # Join through dishes->courses
    },
    {
        "table": "combo_groups",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "restaurant_id"
    },
    {
        "table": "combo_group_sections",
        "name_en": "use_header_en",
        "name_fr": "use_header_fr",
        "restaurant_id_path": "combo_group.restaurant_id"  # Join through combo_groups
    },
    {
        "table": "combo_modifier_groups",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "combo_group_section.combo_group.restaurant_id"
    },
    {
        "table": "combo_modifiers",
        "name_en": "name_en",
        "name_fr": "name_fr",
        "restaurant_id_path": "combo_modifier_group.combo_group_section.combo_group.restaurant_id"
    }
]


def get_connection():
    """Get database connection."""
    return psycopg2.connect(DATABASE_URL)


def translate_text(text: str, source_lang: str, target_lang: str) -> Optional[str]:
    """
    Translate text from source language to target language.
    
    This is a placeholder function. In production, integrate with:
    - OpenAI API (GPT-4)
    - Google Cloud Translation API
    - DeepL API
    - Or other translation service
    
    Args:
        text: Text to translate
        source_lang: Source language code ('en' or 'fr')
        target_lang: Target language code ('en' or 'fr')
        
    Returns:
        Translated text or None if translation fails
    """
    # TODO: Implement actual translation API integration
    # Example with OpenAI:
    # 
    # import openai
    # openai.api_key = os.getenv("OPENAI_API_KEY")
    # 
    # response = openai.ChatCompletion.create(
    #     model="gpt-4",
    #     messages=[
    #         {"role": "system", "content": f"Translate the following menu item from {source_lang} to {target_lang}. Keep it concise and appropriate for a restaurant menu."},
    #         {"role": "user", "content": text}
    #     ]
    # )
    # return response.choices[0].message.content
    
    print(f"  [PLACEHOLDER] Would translate: '{text}' from {source_lang} to {target_lang}")
    return None  # Return None to indicate no translation performed


def get_items_needing_translation(conn, table: str, is_french_restaurant: bool) -> list:
    """
    Get items that need translation.
    
    For English restaurants: has name_en but missing name_fr
    For French restaurants: has name_fr but missing name_en
    """
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    if is_french_restaurant:
        # French restaurants: have name_fr, need name_en
        if table == "courses":
            query = """
                SELECT id, name_fr, name_en, description_fr, description_en
                FROM menuca_v3.courses
                WHERE restaurant_id = ANY(%s)
                  AND name_fr IS NOT NULL
                  AND (name_en IS NULL OR name_en = '')
                  AND deleted_at IS NULL
            """
        elif table == "dishes":
            query = """
                SELECT d.id, d.name_fr, d.name_en, d.description_fr, d.description_en
                FROM menuca_v3.dishes d
                JOIN menuca_v3.courses c ON d.course_id = c.id
                WHERE c.restaurant_id = ANY(%s)
                  AND d.name_fr IS NOT NULL
                  AND (d.name_en IS NULL OR d.name_en = '')
                  AND d.deleted_at IS NULL
            """
        else:
            return []  # Simplified for now
    else:
        # English restaurants: have name_en, need name_fr
        if table == "courses":
            query = """
                SELECT id, name_en, name_fr, description_en, description_fr
                FROM menuca_v3.courses
                WHERE restaurant_id != ALL(%s)
                  AND name_en IS NOT NULL
                  AND (name_fr IS NULL OR name_fr = '')
                  AND deleted_at IS NULL
            """
        elif table == "dishes":
            query = """
                SELECT d.id, d.name_en, d.name_fr, d.description_en, d.description_fr
                FROM menuca_v3.dishes d
                JOIN menuca_v3.courses c ON d.course_id = c.id
                WHERE c.restaurant_id != ALL(%s)
                  AND d.name_en IS NOT NULL
                  AND (d.name_fr IS NULL OR d.name_fr = '')
                  AND d.deleted_at IS NULL
            """
        else:
            return []  # Simplified for now
    
    cursor.execute(query, (FRENCH_RESTAURANT_IDS,))
    return cursor.fetchall()


def update_translation(conn, table: str, item_id: int, column: str, value: str):
    """Update a translation in the database."""
    cursor = conn.cursor()
    query = f"UPDATE menuca_v3.{table} SET {column} = %s WHERE id = %s"
    cursor.execute(query, (value, item_id))
    conn.commit()


def get_translation_stats(conn) -> dict:
    """Get current translation statistics."""
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    stats = {}
    
    # Courses stats
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_en != '' THEN 1 END) as has_en,
            COUNT(CASE WHEN name_fr IS NOT NULL AND name_fr != '' THEN 1 END) as has_fr,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_fr IS NOT NULL THEN 1 END) as has_both
        FROM menuca_v3.courses WHERE deleted_at IS NULL
    """)
    stats['courses'] = cursor.fetchone()
    
    # Dishes stats
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_en != '' THEN 1 END) as has_en,
            COUNT(CASE WHEN name_fr IS NOT NULL AND name_fr != '' THEN 1 END) as has_fr,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_fr IS NOT NULL THEN 1 END) as has_both
        FROM menuca_v3.dishes WHERE deleted_at IS NULL
    """)
    stats['dishes'] = cursor.fetchone()
    
    # Modifier groups stats
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_en != '' THEN 1 END) as has_en,
            COUNT(CASE WHEN name_fr IS NOT NULL AND name_fr != '' THEN 1 END) as has_fr,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_fr IS NOT NULL THEN 1 END) as has_both
        FROM menuca_v3.modifier_groups WHERE deleted_at IS NULL
    """)
    stats['modifier_groups'] = cursor.fetchone()
    
    # Modifiers stats
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_en != '' THEN 1 END) as has_en,
            COUNT(CASE WHEN name_fr IS NOT NULL AND name_fr != '' THEN 1 END) as has_fr,
            COUNT(CASE WHEN name_en IS NOT NULL AND name_fr IS NOT NULL THEN 1 END) as has_both
        FROM menuca_v3.modifiers WHERE deleted_at IS NULL
    """)
    stats['modifiers'] = cursor.fetchone()
    
    return stats


def print_stats(stats: dict):
    """Print translation statistics."""
    print("\n" + "=" * 60)
    print("TRANSLATION STATISTICS")
    print("=" * 60)
    
    for table, data in stats.items():
        total = data['total']
        has_en = data['has_en']
        has_fr = data['has_fr']
        has_both = data['has_both']
        needs_en = total - has_en
        needs_fr = total - has_fr
        
        print(f"\n{table.upper()}:")
        print(f"  Total records: {total}")
        print(f"  Has English (name_en): {has_en} ({100*has_en/total:.1f}%)")
        print(f"  Has French (name_fr): {has_fr} ({100*has_fr/total:.1f}%)")
        print(f"  Has Both: {has_both} ({100*has_both/total:.1f}%)")
        print(f"  Needs English translation: {needs_en}")
        print(f"  Needs French translation: {needs_fr}")


def main():
    """Main function to run translation process."""
    print("=" * 60)
    print("MENU TRANSLATION SCRIPT")
    print(f"Started at: {datetime.now()}")
    print("=" * 60)
    
    print(f"\nFrench Restaurant IDs: {FRENCH_RESTAURANT_IDS}")
    print(f"Total French restaurants: {len(FRENCH_RESTAURANT_IDS)}")
    
    conn = get_connection()
    
    # Get and print current stats
    stats = get_translation_stats(conn)
    print_stats(stats)
    
    print("\n" + "=" * 60)
    print("TRANSLATION PREVIEW (Dry Run)")
    print("=" * 60)
    
    # Preview what would be translated
    for table in ['courses', 'dishes']:
        print(f"\n--- {table.upper()} ---")
        
        # Items needing English (French restaurants)
        french_items = get_items_needing_translation(conn, table, is_french_restaurant=True)
        print(f"  French restaurants needing EN translation: {len(french_items)}")
        if french_items[:3]:
            print("  Sample items:")
            for item in french_items[:3]:
                print(f"    - ID {item['id']}: '{item.get('name_fr', 'N/A')}'")
        
        # Items needing French (English restaurants)
        english_items = get_items_needing_translation(conn, table, is_french_restaurant=False)
        print(f"  English restaurants needing FR translation: {len(english_items)}")
        if english_items[:3]:
            print("  Sample items:")
            for item in english_items[:3]:
                print(f"    - ID {item['id']}: '{item.get('name_en', 'N/A')}'")
    
    print("\n" + "=" * 60)
    print("TO ENABLE ACTUAL TRANSLATION:")
    print("1. Implement translate_text() function with your chosen API")
    print("2. Set DRY_RUN=False in environment or modify script")
    print("3. Run: python translate_menu_items.py --execute")
    print("=" * 60)
    
    conn.close()


if __name__ == "__main__":
    main()



