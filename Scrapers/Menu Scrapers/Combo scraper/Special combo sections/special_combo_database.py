"""Database operations for special combo sections scraping."""
import sys
import os
import logging
from typing import Optional, Dict, List, Any

# Add parent directories to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from combo_database import ComboDatabase

logger = logging.getLogger(__name__)


class SpecialComboDatabase(ComboDatabase):
    """Extended database operations for special combo sections."""

    # =========================================================================
    # Combo Group Special Section Flag
    # =========================================================================

    def update_combo_group_has_special_section(self, combo_group_id: int, 
                                                has_special: bool = True) -> bool:
        """Update the has_special_section flag on a combo group."""
        self.ensure_connection()
        try:
            query = f"""
                UPDATE {self.schema}.combo_groups
                SET has_special_section = %s, updated_at = NOW()
                WHERE id = %s
                RETURNING id
            """
            self.cursor.execute(query, (has_special, combo_group_id))
            result = self.cursor.fetchone()
            self.conn.commit()
            
            if result:
                logger.debug(f"Updated combo_group {combo_group_id}: has_special_section={has_special}")
                return True
            return False
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to update has_special_section for combo_group {combo_group_id}: {e}")
            return False

    # =========================================================================
    # Combo Group Dish Selections
    # =========================================================================

    def insert_combo_group_dish_selection(self, combo_group_id: int, dish_id: int,
                                          size: Optional[int], course_id: Optional[int],
                                          dish_display_name: Optional[str] = None) -> Optional[int]:
        """Insert a dish selection for a special combo group."""
        self.ensure_connection()
        try:
            # Check if exists (by combo_group_id, dish_id, and size)
            check_query = f"""
                SELECT id FROM {self.schema}.combo_group_dish_selections
                WHERE combo_group_id = %s AND dish_id = %s 
                  AND (size = %s OR (size IS NULL AND %s IS NULL))
                  AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (combo_group_id, dish_id, size, size))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_group_dish_selections
                    SET course_id = %s,
                        dish_display_name = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (course_id, dish_display_name, existing['id']))
                result = self.cursor.fetchone()
                logger.debug(f"Updated dish_selection {existing['id']}: dish_id={dish_id}, size={size}")
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_group_dish_selections
                    (combo_group_id, dish_id, size, course_id, dish_display_name)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    combo_group_id, dish_id, size, course_id, dish_display_name
                ))
                result = self.cursor.fetchone()
                logger.debug(f"Inserted dish_selection: combo_group={combo_group_id}, dish_id={dish_id}, size={size}")

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert combo_group_dish_selection (combo={combo_group_id}, dish={dish_id}): {e}")
            return None

    # =========================================================================
    # Lookup Methods
    # =========================================================================

    def get_dish_by_source_id(self, restaurant_id: int, source_id: int) -> Optional[Dict[str, Any]]:
        """Get dish by V1 source_id. Returns id, course_id, and name."""
        query = f"""
            SELECT id, course_id, name
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def get_combo_groups_by_restaurant(self, restaurant_id: int) -> List[Dict[str, Any]]:
        """Get all combo groups for a restaurant with their source_ids."""
        query = f"""
            SELECT id, name, source_id, has_special_section,
                   special_number_of_items, special_display_header
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = %s AND deleted_at IS NULL
            ORDER BY id
        """
        self.cursor.execute(query, (restaurant_id,))
        return [dict(row) for row in self.cursor.fetchall()]

    def get_combo_group_by_source_id(self, restaurant_id: int, 
                                      source_id: int) -> Optional[Dict[str, Any]]:
        """Get combo group by source_id."""
        query = f"""
            SELECT id, name, source_id, has_special_section
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    # =========================================================================
    # Statistics
    # =========================================================================

    def get_special_combo_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get special combo section statistics for a restaurant."""
        stats = {}

        # Count combo groups with special sections
        self.cursor.execute(f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_groups
            WHERE restaurant_id = %s AND has_special_section = TRUE AND deleted_at IS NULL
        """, (restaurant_id,))
        stats['special_combo_groups'] = self.cursor.fetchone()['count']

        # Count dish selections
        self.cursor.execute(f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_group_dish_selections cgds
            JOIN {self.schema}.combo_groups cg ON cgds.combo_group_id = cg.id
            WHERE cg.restaurant_id = %s AND cgds.deleted_at IS NULL AND cg.deleted_at IS NULL
        """, (restaurant_id,))
        stats['dish_selections'] = self.cursor.fetchone()['count']

        return stats

