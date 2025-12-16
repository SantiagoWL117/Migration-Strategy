"""Database operations for combo drinks modifier group scraping."""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List, Any
import logging

from combo_drinks_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)


class ComboDrinksDatabase:
    """Manages database operations for combo drinks modifier groups."""

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
    # Dish Queries
    # =========================================================================

    def get_dish_by_combo_source_id(self, restaurant_id: int, combo_id: int) -> Optional[Dict[str, Any]]:
        """
        Find V3 dish by combo source_id.
        
        In V1, combo dishes have URLs like: ?...&combo=57645
        The combo_id (57645) is stored as source_id in menuca_v3.dishes.
        
        Args:
            restaurant_id: V3 restaurant ID
            combo_id: V1 combo ID from URL
            
        Returns:
            Dict with dish info or None if not found
        """
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id, is_combo, is_active
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s 
              AND source_id = %s 
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            self.cursor.execute(query, (restaurant_id, combo_id))
            result = self.cursor.fetchone()
            return dict(result) if result else None
        except Exception as e:
            logger.error(f"Error getting dish by combo source_id: {e}")
            return None

    def get_combo_dishes_for_restaurant(self, restaurant_id: int) -> List[Dict[str, Any]]:
        """
        Get all combo dishes for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            
        Returns:
            List of combo dishes
        """
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id, is_active
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s 
              AND is_combo = TRUE
              AND deleted_at IS NULL
            ORDER BY id
        """
        try:
            self.cursor.execute(query, (restaurant_id,))
            results = self.cursor.fetchall()
            return [dict(r) for r in results]
        except Exception as e:
            logger.error(f"Error getting combo dishes: {e}")
            return []

    # =========================================================================
    # Modifier Group Queries
    # =========================================================================

    def get_modifier_group_by_name(self, dish_id: int, name: str) -> Optional[Dict[str, Any]]:
        """
        Find modifier group by dish_id and name.
        
        The name should match the radio button label from V1 (e.g., "Drinks can").
        
        Args:
            dish_id: V3 dish ID
            name: Modifier group name (from V1 radio label)
            
        Returns:
            Dict with modifier group info or None if not found
        """
        self.ensure_connection()
        query = f"""
            SELECT id, dish_id, name, min_selections, max_selections, free_items, 
                   display_order, updated_at
            FROM {self.schema}.modifier_groups
            WHERE dish_id = %s 
              AND name = %s 
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            self.cursor.execute(query, (dish_id, name))
            result = self.cursor.fetchone()
            return dict(result) if result else None
        except Exception as e:
            logger.error(f"Error getting modifier group by name: {e}")
            return None

    def get_modifier_groups_for_dish(self, dish_id: int) -> List[Dict[str, Any]]:
        """
        Get all modifier groups for a dish.
        
        Args:
            dish_id: V3 dish ID
            
        Returns:
            List of modifier groups
        """
        self.ensure_connection()
        query = f"""
            SELECT id, name, min_selections, max_selections, free_items, display_order
            FROM {self.schema}.modifier_groups
            WHERE dish_id = %s AND deleted_at IS NULL
            ORDER BY display_order, id
        """
        try:
            self.cursor.execute(query, (dish_id,))
            results = self.cursor.fetchall()
            return [dict(r) for r in results]
        except Exception as e:
            logger.error(f"Error getting modifier groups for dish: {e}")
            return []

    def find_drinks_modifier_group(self, dish_id: int) -> Optional[Dict[str, Any]]:
        """
        Find any drinks-related modifier group for a dish.
        
        Searches for modifier groups with names containing 'drink' (case-insensitive).
        
        Args:
            dish_id: V3 dish ID
            
        Returns:
            Dict with modifier group info or None if not found
        """
        self.ensure_connection()
        query = f"""
            SELECT id, dish_id, name, min_selections, max_selections, free_items, 
                   display_order, updated_at
            FROM {self.schema}.modifier_groups
            WHERE dish_id = %s 
              AND LOWER(name) LIKE '%%drink%%'
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            self.cursor.execute(query, (dish_id,))
            result = self.cursor.fetchone()
            return dict(result) if result else None
        except Exception as e:
            logger.error(f"Error finding drinks modifier group: {e}")
            return None

    # =========================================================================
    # Update Operations
    # =========================================================================

    def update_modifier_group_drinks_settings(
        self, 
        modifier_group_id: int, 
        name: str,
        min_selections: int, 
        max_selections: int, 
        free_items: int,
        display_order: int = None
    ) -> bool:
        """
        Update modifier group with drinks settings.
        
        Updates name, min_selections, max_selections, free_items, display_order, 
        and updated_at timestamp.
        
        Args:
            modifier_group_id: V3 modifier group ID
            name: New name for the modifier group (from drinksHeader)
            min_selections: Minimum number of selections required
            max_selections: Maximum number of selections allowed
            free_items: Number of free items included
            display_order: Display order (optional)
            
        Returns:
            True if update successful, False otherwise
        """
        self.ensure_connection()
        
        if display_order is not None:
            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET name = %s,
                    min_selections = %s,
                    max_selections = %s,
                    free_items = %s,
                    display_order = %s,
                    updated_at = NOW()
                WHERE id = %s
                RETURNING id
            """
            params = (name, min_selections, max_selections, free_items, display_order, modifier_group_id)
        else:
            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET name = %s,
                    min_selections = %s,
                    max_selections = %s,
                    free_items = %s,
                    updated_at = NOW()
                WHERE id = %s
                RETURNING id
            """
            params = (name, min_selections, max_selections, free_items, modifier_group_id)
        
        try:
            self.cursor.execute(query, params)
            result = self.cursor.fetchone()
            self.conn.commit()
            
            if result:
                logger.debug(f"Updated modifier_group {modifier_group_id}: name={name}, min={min_selections}, max={max_selections}, free={free_items}, order={display_order}")
                return True
            return False
        except Exception as e:
            logger.error(f"Error updating modifier group settings: {e}")
            self.conn.rollback()
            return False

    # =========================================================================
    # Verification Queries
    # =========================================================================

    def get_modifier_group_details(self, modifier_group_id: int) -> Optional[Dict[str, Any]]:
        """
        Get full details of a modifier group for verification.
        
        Args:
            modifier_group_id: V3 modifier group ID
            
        Returns:
            Dict with full modifier group details
        """
        self.ensure_connection()
        query = f"""
            SELECT mg.id, mg.dish_id, mg.name, mg.min_selections, mg.max_selections, 
                   mg.free_items, mg.display_order, mg.updated_at,
                   d.name as dish_name, d.restaurant_id
            FROM {self.schema}.modifier_groups mg
            JOIN {self.schema}.dishes d ON d.id = mg.dish_id
            WHERE mg.id = %s
        """
        try:
            self.cursor.execute(query, (modifier_group_id,))
            result = self.cursor.fetchone()
            return dict(result) if result else None
        except Exception as e:
            logger.error(f"Error getting modifier group details: {e}")
            return None

    def get_restaurant_drinks_stats(self, restaurant_id: int) -> Dict[str, int]:
        """
        Get statistics about drinks modifier groups for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            
        Returns:
            Dict with counts of total combo dishes, dishes with drinks modifier, etc.
        """
        self.ensure_connection()
        
        stats = {
            'total_combo_dishes': 0,
            'dishes_with_drinks_modifier': 0,
            'total_drinks_modifier_groups': 0
        }
        
        try:
            # Count combo dishes
            self.cursor.execute(f"""
                SELECT COUNT(*) as cnt
                FROM {self.schema}.dishes
                WHERE restaurant_id = %s AND is_combo = TRUE AND deleted_at IS NULL
            """, (restaurant_id,))
            stats['total_combo_dishes'] = self.cursor.fetchone()['cnt']
            
            # Count dishes with drinks modifier groups
            self.cursor.execute(f"""
                SELECT COUNT(DISTINCT d.id) as cnt
                FROM {self.schema}.dishes d
                JOIN {self.schema}.modifier_groups mg ON mg.dish_id = d.id
                WHERE d.restaurant_id = %s 
                  AND d.is_combo = TRUE 
                  AND d.deleted_at IS NULL
                  AND mg.deleted_at IS NULL
                  AND LOWER(mg.name) LIKE '%%drink%%'
            """, (restaurant_id,))
            stats['dishes_with_drinks_modifier'] = self.cursor.fetchone()['cnt']
            
            # Count drinks modifier groups
            self.cursor.execute(f"""
                SELECT COUNT(*) as cnt
                FROM {self.schema}.modifier_groups mg
                JOIN {self.schema}.dishes d ON d.id = mg.dish_id
                WHERE d.restaurant_id = %s 
                  AND d.deleted_at IS NULL
                  AND mg.deleted_at IS NULL
                  AND LOWER(mg.name) LIKE '%%drink%%'
            """, (restaurant_id,))
            stats['total_drinks_modifier_groups'] = self.cursor.fetchone()['cnt']
            
            return stats
        except Exception as e:
            logger.error(f"Error getting drinks stats: {e}")
            return stats

