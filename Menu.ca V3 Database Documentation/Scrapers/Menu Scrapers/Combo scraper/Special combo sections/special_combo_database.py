"""Database operations for special combo sections scraping using psql.

This module extends ComboDatabase which uses psql subprocess calls for all CRUD operations.
"""
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
    """Extended database operations for special combo sections using psql."""

    # =========================================================================
    # Combo Group Special Section Flag
    # =========================================================================

    def update_combo_group_has_special_section(self, combo_group_id: int, 
                                                has_special: bool = True) -> bool:
        """Update the has_special_section flag on a combo group."""
        self.ensure_connection()
        flag = 'TRUE' if has_special else 'FALSE'
        
        try:
            query = f"""
                UPDATE {self.schema}.combo_groups
                SET has_special_section = {flag}, updated_at = NOW()
                WHERE id = {combo_group_id}
                RETURNING id
            """
            result = self._execute_update(query)
            
            if result is not None:
                logger.debug(f"Updated combo_group {combo_group_id}: has_special_section={has_special}")
                return True
            return False
        except Exception as e:
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
        size_str = str(size) if size is not None else "NULL"
        course_str = str(course_id) if course_id is not None else "NULL"
        display_name = f"'{self._escape_string(dish_display_name)}'" if dish_display_name else "NULL"
        
        try:
            # Check if exists (by combo_group_id, dish_id, and size)
            if size is not None:
                check_query = f"""
                    SELECT id FROM {self.schema}.combo_group_dish_selections
                    WHERE combo_group_id = {combo_group_id} AND dish_id = {dish_id} 
                      AND size = {size}
                      AND deleted_at IS NULL
                    LIMIT 1
                """
            else:
                check_query = f"""
                    SELECT id FROM {self.schema}.combo_group_dish_selections
                    WHERE combo_group_id = {combo_group_id} AND dish_id = {dish_id} 
                      AND size IS NULL
                      AND deleted_at IS NULL
                    LIMIT 1
                """
            existing = self._execute_query(check_query)

            if existing:
                # Update existing
                query = f"""
                    UPDATE {self.schema}.combo_group_dish_selections
                    SET course_id = {course_str},
                        dish_display_name = {display_name}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
                logger.debug(f"Updated dish_selection {existing[0]['id']}: dish_id={dish_id}, size={size}")
            else:
                # Insert new
                query = f"""
                    INSERT INTO {self.schema}.combo_group_dish_selections
                    (combo_group_id, dish_id, size, course_id, dish_display_name)
                    VALUES ({combo_group_id}, {dish_id}, {size_str}, {course_str}, {display_name})
                    RETURNING id
                """
                logger.debug(f"Inserted dish_selection: combo_group={combo_group_id}, dish_id={dish_id}, size={size}")

            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
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
            WHERE restaurant_id = {restaurant_id} AND source_id = {source_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    def get_combo_groups_by_restaurant(self, restaurant_id: int) -> List[Dict[str, Any]]:
        """Get all combo groups for a restaurant with their source_ids."""
        query = f"""
            SELECT id, name, source_id, has_special_section,
                   special_number_of_items, special_display_header
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = {restaurant_id} AND deleted_at IS NULL
            ORDER BY id
        """
        results = self._execute_query(query)
        return results if results else []

    def get_combo_group_by_source_id(self, restaurant_id: int, 
                                      source_id: int) -> Optional[Dict[str, Any]]:
        """Get combo group by source_id."""
        query = f"""
            SELECT id, name, source_id, has_special_section
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = {restaurant_id} AND source_id = {source_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    # =========================================================================
    # Statistics
    # =========================================================================

    def get_special_combo_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get special combo section statistics for a restaurant."""
        stats = {}

        # Count combo groups with special sections
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_groups
            WHERE restaurant_id = {restaurant_id} AND has_special_section = TRUE AND deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['special_combo_groups'] = result[0]['count'] if result else 0

        # Count dish selections
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_group_dish_selections cgds
            JOIN {self.schema}.combo_groups cg ON cgds.combo_group_id = cg.id
            WHERE cg.restaurant_id = {restaurant_id} AND cgds.deleted_at IS NULL AND cg.deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['dish_selections'] = result[0]['count'] if result else 0

        return stats
