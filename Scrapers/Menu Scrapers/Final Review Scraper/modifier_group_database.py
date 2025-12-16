"""Database operations for the Modifier Group Details scraper."""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List, Any
import logging

from modifier_group_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)


class ModifierGroupDatabase:
    """Database operations for modifier groups and dish availability."""

    def __init__(self):
        self.conn_string = DB_CONNECTION_STRING
        self.schema = SCHEMA
        self.conn = None
        self.cursor = None

    def connect(self):
        """Establish database connection."""
        try:
            self.conn = psycopg2.connect(self.conn_string)
            self.cursor = self.conn.cursor(cursor_factory=RealDictCursor)
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise

    def close(self):
        """Close database connection."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            logger.info("Database connection closed")

    def is_connected(self) -> bool:
        """Check if database connection is alive."""
        if not self.conn or not self.cursor:
            return False
        try:
            self.cursor.execute("SELECT 1")
            return True
        except (psycopg2.OperationalError, psycopg2.InterfaceError):
            return False

    def ensure_connection(self):
        """Ensure database connection is active, reconnect if needed."""
        if not self.is_connected():
            logger.warning("Database connection lost, reconnecting...")
            try:
                if self.cursor:
                    try:
                        self.cursor.close()
                    except:
                        pass
                if self.conn:
                    try:
                        self.conn.close()
                    except:
                        pass
                self.connect()
                logger.info("Database reconnection successful")
            except Exception as e:
                logger.error(f"Failed to reconnect to database: {e}")
                raise

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            self.conn.rollback()
        self.close()

    # =========================================================================
    # Restaurant Methods
    # =========================================================================

    def get_restaurant_by_id(self, restaurant_id: int) -> Optional[Dict[str, Any]]:
        """Get restaurant by V3 ID."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    # =========================================================================
    # Dish Methods
    # =========================================================================

    def get_dishes_by_restaurant(self, restaurant_id: int) -> List[Dict[str, Any]]:
        """
        Get all non-combo dishes for a restaurant.
        Returns dishes with their source_id (V1 menuEntry ID).
        """
        self.ensure_connection()
        query = f"""
            SELECT d.id, d.name, d.source_id, d.course_id, c.name as course_name
            FROM {self.schema}.dishes d
            JOIN {self.schema}.courses c ON d.course_id = c.id
            WHERE d.restaurant_id = %s 
              AND d.deleted_at IS NULL 
              AND d.is_combo = FALSE
              AND d.source_id IS NOT NULL
            ORDER BY c.display_order, d.display_order
        """
        self.cursor.execute(query, (restaurant_id,))
        return [dict(row) for row in self.cursor.fetchall()]

    def get_dish_by_source_id(self, restaurant_id: int, source_id: int) -> Optional[Dict[str, Any]]:
        """Get dish by V1 source_id."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id, course_id
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    # =========================================================================
    # Modifier Group Methods
    # =========================================================================

    def get_modifier_groups_by_dish(self, dish_id: int) -> List[Dict[str, Any]]:
        """Get all modifier groups for a dish."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, min_selections, max_selections, free_items, display_order
            FROM {self.schema}.modifier_groups
            WHERE dish_id = %s AND deleted_at IS NULL
            ORDER BY display_order, id
        """
        self.cursor.execute(query, (dish_id,))
        return [dict(row) for row in self.cursor.fetchall()]

    def get_modifier_group_by_name(self, dish_id: int, name: str) -> Optional[Dict[str, Any]]:
        """Get modifier group by dish_id and name."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, min_selections, max_selections, free_items, display_order
            FROM {self.schema}.modifier_groups
            WHERE dish_id = %s AND name = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (dish_id, name))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def update_modifier_group_details(self, modifier_group_id: int,
                                      min_selections: Optional[int] = None,
                                      max_selections: Optional[int] = None,
                                      free_items: Optional[int] = None,
                                      display_order: Optional[int] = None,
                                      name: Optional[str] = None) -> bool:
        """
        Update modifier group details.
        Only updates fields that are provided (not None).
        """
        self.ensure_connection()
        try:
            # Build dynamic update query
            updates = []
            params = []

            if min_selections is not None:
                updates.append("min_selections = %s")
                params.append(min_selections)
            if max_selections is not None:
                updates.append("max_selections = %s")
                params.append(max_selections)
            if free_items is not None:
                updates.append("free_items = %s")
                params.append(free_items)
            if display_order is not None:
                updates.append("display_order = %s")
                params.append(display_order)
            if name is not None:
                updates.append("name = %s")
                params.append(name)

            if not updates:
                logger.debug(f"No updates for modifier_group {modifier_group_id}")
                return True

            updates.append("updated_at = NOW()")
            params.append(modifier_group_id)

            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET {', '.join(updates)}
                WHERE id = %s
            """
            self.cursor.execute(query, params)
            self.conn.commit()

            logger.debug(f"Updated modifier_group {modifier_group_id}")
            return True

        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to update modifier_group {modifier_group_id}: {e}")
            return False

    # =========================================================================
    # Dish Availability Methods
    # =========================================================================

    def update_dish_hide_option(self, dish_id: int, enabled: bool) -> bool:
        """Set the hide_option_enabled flag on a dish."""
        self.ensure_connection()
        try:
            query = f"""
                UPDATE {self.schema}.dishes
                SET hide_option_enabled = %s, updated_at = NOW()
                WHERE id = %s
            """
            self.cursor.execute(query, (enabled, dish_id))
            self.conn.commit()
            logger.debug(f"Set hide_option_enabled={enabled} for dish {dish_id}")
            return True
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to update hide_option_enabled for dish {dish_id}: {e}")
            return False

    def upsert_dish_availability(self, dish_id: int, day_of_week: int,
                                  is_hidden: bool = True) -> Optional[int]:
        """
        Insert or update a dish availability record.
        
        Args:
            dish_id: V3 dish ID
            day_of_week: 0=Sunday, 1=Monday, ..., 6=Saturday
            is_hidden: Whether the dish is hidden on this day
            
        Returns:
            The dish_availability ID if successful, None otherwise
        """
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_availability
                WHERE dish_id = %s AND day_of_week = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, day_of_week))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dish_availability
                    SET is_hidden = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (is_hidden, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_availability
                    (dish_id, day_of_week, is_hidden)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (dish_id, day_of_week, is_hidden))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None

        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to upsert dish_availability for dish {dish_id}, day {day_of_week}: {e}")
            return None

    def clear_dish_availability(self, dish_id: int) -> bool:
        """Remove all dish_availability records for a dish."""
        self.ensure_connection()
        try:
            query = f"""
                DELETE FROM {self.schema}.dish_availability
                WHERE dish_id = %s
            """
            self.cursor.execute(query, (dish_id,))
            self.conn.commit()
            return True
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to clear dish_availability for dish {dish_id}: {e}")
            return False

    # =========================================================================
    # Stats Methods
    # =========================================================================

    def get_modifier_group_count(self, restaurant_id: int) -> int:
        """Get count of modifier groups for a restaurant."""
        self.ensure_connection()
        query = f"""
            SELECT COUNT(DISTINCT mg.id) as count
            FROM {self.schema}.modifier_groups mg
            JOIN {self.schema}.dishes d ON mg.dish_id = d.id
            WHERE d.restaurant_id = %s 
              AND mg.deleted_at IS NULL 
              AND d.deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return result['count'] if result else 0

    def get_dish_availability_count(self, restaurant_id: int) -> int:
        """Get count of dish_availability records for a restaurant."""
        self.ensure_connection()
        query = f"""
            SELECT COUNT(da.id) as count
            FROM {self.schema}.dish_availability da
            JOIN {self.schema}.dishes d ON da.dish_id = d.id
            WHERE d.restaurant_id = %s AND d.deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return result['count'] if result else 0

    def get_restaurant_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get statistics for a restaurant."""
        self.ensure_connection()
        return {
            'modifier_groups': self.get_modifier_group_count(restaurant_id),
            'dish_availability_records': self.get_dish_availability_count(restaurant_id),
        }

