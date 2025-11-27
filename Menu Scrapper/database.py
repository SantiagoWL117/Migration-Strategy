"""Database operations for menu data."""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List, Any
import logging
from config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)


class DatabaseManager:
    """Manages database connections and operations."""

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
            # Test the connection with a simple query
            self.cursor.execute("SELECT 1")
            return True
        except (psycopg2.OperationalError, psycopg2.InterfaceError):
            return False
    
    def ensure_connection(self):
        """Ensure database connection is active, reconnect if needed."""
        if not self.is_connected():
            logger.warning("Database connection lost, reconnecting...")
            try:
                # Close existing connection objects if they exist
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
                
                # Establish new connection
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

    def get_restaurant_by_name(self, name: str) -> Optional[Dict[str, Any]]:
        """Get restaurant ID by name."""
        query = f"""
            SELECT id, name, legacy_v1_id, legacy_v2_id
            FROM {self.schema}.restaurants
            WHERE name = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (name,))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def insert_course(self, restaurant_id: int, name: str, description: str,
                     display_order: int) -> Optional[int]:
        """Insert a course (menu category) and return its ID.

        Uses manual upsert logic since unique constraints were removed.
        Checks if course exists first, then updates or inserts accordingly.
        """
        self.ensure_connection()
        try:
            # Check if course already exists
            check_query = f"""
                SELECT id FROM {self.schema}.courses
                WHERE restaurant_id = %s AND name = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (restaurant_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing course
                update_query = f"""
                    UPDATE {self.schema}.courses
                    SET description = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (description, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new course
                insert_query = f"""
                    INSERT INTO {self.schema}.courses
                    (restaurant_id, name, description, display_order, is_active)
                    VALUES (%s, %s, %s, %s, TRUE)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (restaurant_id, name, description, display_order))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update course '{name}': {e}")
            return None

    def insert_dish(self, restaurant_id: int, course_id: int, name: str,
                   description: str, display_order: int,
                   legacy_menu_entry_id: int = None) -> Optional[int]:
        """Insert a dish and return its ID.

        Uses manual upsert logic since unique constraints were removed.
        Checks if dish exists first, then updates or inserts accordingly.
        """
        self.ensure_connection()
        try:
            # Check if dish already exists
            check_query = f"""
                SELECT id FROM {self.schema}.dishes
                WHERE restaurant_id = %s AND course_id = %s AND name = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (restaurant_id, course_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing dish
                update_query = f"""
                    UPDATE {self.schema}.dishes
                    SET description = %s,
                        display_order = %s,
                        source_id = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    description, display_order, legacy_menu_entry_id, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new dish
                insert_query = f"""
                    INSERT INTO {self.schema}.dishes
                    (restaurant_id, course_id, name, description, display_order,
                     is_active, source_id)
                    VALUES (%s, %s, %s, %s, %s, TRUE, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, course_id, name, description,
                    display_order, legacy_menu_entry_id
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update dish '{name}': {e}")
            return None

    def insert_dish_price(self, dish_id: int, size_variant: Optional[str],
                         price: float, display_order: int = 0) -> Optional[int]:
        """Insert a dish price with manual upsert logic."""
        self.ensure_connection()
        try:
            # Check if price exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_prices
                WHERE dish_id = %s AND 
                      COALESCE(size_variant, '') = COALESCE(%s, '')
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, size_variant))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing price
                update_query = f"""
                    UPDATE {self.schema}.dish_prices
                    SET price = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (price, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new price
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_prices
                    (dish_id, size_variant, price, display_order, is_active)
                    VALUES (%s, %s, %s, %s, TRUE)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (dish_id, size_variant, price, display_order))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update price for dish_id {dish_id}: {e}")
            return None

    def insert_modifier_group(self, dish_id: int, name: str, is_required: bool = False,
                             min_selections: int = 0, max_selections: int = 1,
                             display_order: int = 0) -> Optional[int]:
        """Insert a modifier group with manual upsert logic."""
        self.ensure_connection()
        try:
            # Check if modifier group exists
            check_query = f"""
                SELECT id FROM {self.schema}.modifier_groups
                WHERE dish_id = %s AND name = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing modifier group
                update_query = f"""
                    UPDATE {self.schema}.modifier_groups
                    SET is_required = %s,
                        min_selections = %s,
                        max_selections = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    is_required, min_selections, max_selections, display_order, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new modifier group
                insert_query = f"""
                    INSERT INTO {self.schema}.modifier_groups
                    (dish_id, name, is_required, min_selections, max_selections, display_order)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    dish_id, name, is_required, min_selections, max_selections, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update modifier group '{name}' for dish {dish_id}: {e}")
            return None

    def insert_dish_modifier(self, restaurant_id: int, dish_id: int, modifier_group_id: int,
                           name: str, modifier_type: str = 'other',
                           is_default: bool = False, display_order: int = 0) -> Optional[int]:
        """Insert a dish modifier item with manual upsert logic (no price - use insert_dish_modifier_price for prices)."""
        self.ensure_connection()
        try:
            # Check if modifier item exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifiers
                WHERE dish_id = %s AND modifier_group_id = %s AND name = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, modifier_group_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing modifier item
                update_query = f"""
                    UPDATE {self.schema}.dish_modifiers
                    SET is_default = %s,
                        display_order = %s,
                        modifier_type = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    is_default, display_order, modifier_type, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new modifier item
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_modifiers
                    (restaurant_id, dish_id, modifier_group_id, name, 
                     modifier_type, is_default, display_order)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, dish_id, modifier_group_id, name,
                    modifier_type, is_default, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update modifier item '{name}': {e}")
            return None

    def insert_dish_modifier_price(self, dish_modifier_id: int, dish_id: int, restaurant_id: int,
                                   size_variant: str = 'standard', price: float = 0.0,
                                   display_order: int = 0) -> Optional[int]:
        """Insert a dish modifier price for a specific size variant."""
        self.ensure_connection()
        try:
            # Check if price for this size variant exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifier_prices
                WHERE dish_modifier_id = %s AND size_variant = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_modifier_id, size_variant))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing price
                update_query = f"""
                    UPDATE {self.schema}.dish_modifier_prices
                    SET price = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (price, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new price
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_modifier_prices
                    (dish_modifier_id, dish_id, restaurant_id, size_variant, price, display_order)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    dish_modifier_id, dish_id, restaurant_id, size_variant, price, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert/update modifier price for size '{size_variant}': {e}")
            return None

    def course_exists(self, restaurant_id: int, name: str) -> bool:
        """Check if a course already exists."""
        query = f"""
            SELECT id FROM {self.schema}.courses
            WHERE restaurant_id = %s AND name = %s AND deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id, name))
        return self.cursor.fetchone() is not None

    def dish_exists(self, restaurant_id: int, name: str) -> bool:
        """Check if a dish already exists."""
        query = f"""
            SELECT id FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND name = %s AND deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id, name))
        return self.cursor.fetchone() is not None

    def get_course_count(self, restaurant_id: int) -> int:
        """Get the number of courses for a restaurant."""
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.courses
            WHERE restaurant_id = %s AND deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return result['count'] if result else 0

    def get_dish_count(self, restaurant_id: int) -> int:
        """Get the number of dishes for a restaurant."""
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND deleted_at IS NULL
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return result['count'] if result else 0
