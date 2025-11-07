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
        """Insert a course (menu category) and return its ID."""
        query = f"""
            INSERT INTO {self.schema}.courses
            (restaurant_id, name, description, display_order, is_active, source_system)
            VALUES (%s, %s, %s, %s, TRUE, 'crm_scraper')
            ON CONFLICT (restaurant_id, name)
            DO UPDATE SET
                description = EXCLUDED.description,
                display_order = EXCLUDED.display_order,
                updated_at = NOW()
            RETURNING id
        """
        try:
            self.cursor.execute(query, (restaurant_id, name, description, display_order))
            result = self.cursor.fetchone()
            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert course '{name}': {e}")
            return None

    def insert_dish(self, restaurant_id: int, course_id: int, name: str,
                   description: str, display_order: int,
                   legacy_menu_entry_id: int = None) -> Optional[int]:
        """Insert a dish and return its ID."""
        query = f"""
            INSERT INTO {self.schema}.dishes
            (restaurant_id, course_id, name, description, display_order,
             is_active, source_system, source_id)
            VALUES (%s, %s, %s, %s, %s, TRUE, 'crm_scraper', %s)
            ON CONFLICT (restaurant_id, course_id, name)
            DO UPDATE SET
                description = EXCLUDED.description,
                display_order = EXCLUDED.display_order,
                updated_at = NOW()
            RETURNING id
        """
        try:
            self.cursor.execute(query, (
                restaurant_id, course_id, name, description,
                display_order, legacy_menu_entry_id
            ))
            result = self.cursor.fetchone()
            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert dish '{name}': {e}")
            return None

    def insert_dish_price(self, dish_id: int, size_variant: Optional[str],
                         price: float, display_order: int = 0) -> Optional[int]:
        """Insert a dish price."""
        query = f"""
            INSERT INTO {self.schema}.dish_prices
            (dish_id, size_variant, price, display_order, is_active)
            VALUES (%s, %s, %s, %s, TRUE)
            RETURNING id
        """
        try:
            self.cursor.execute(query, (dish_id, size_variant, price, display_order))
            result = self.cursor.fetchone()
            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert price for dish_id {dish_id}: {e}")
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
