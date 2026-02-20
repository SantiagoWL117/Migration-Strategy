"""Database operations for the Modifier Group Details scraper using psql.

This module uses psql subprocess calls for all CRUD operations per project guidelines.
"""
import subprocess
import json
import tempfile
import os
import logging
from typing import Optional, Dict, List, Any

from modifier_group_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)

# psql path for Windows
PSQL_PATH = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"


class ModifierGroupDatabase:
    """Database operations for modifier groups and dish availability using psql."""

    def __init__(self):
        self.conn_string = DB_CONNECTION_STRING
        self.schema = SCHEMA
        self._connected = False

    def connect(self):
        """Verify database connection via psql."""
        try:
            result = self._execute_query("SELECT 1 as test")
            if result and len(result) > 0:
                self._connected = True
                logger.info("Database connection verified via psql")
            else:
                raise Exception("Failed to verify connection")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise

    def close(self):
        """Close database connection (no-op for psql subprocess approach)."""
        self._connected = False
        logger.info("Database connection closed")

    def is_connected(self) -> bool:
        """Check if database connection is configured."""
        return self._connected and bool(self.conn_string)

    def ensure_connection(self):
        """Ensure database connection is active."""
        if not self._connected:
            self.connect()

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    # =========================================================================
    # psql Execution Helper
    # =========================================================================

    def _execute_query(self, query: str, return_results: bool = True) -> Optional[List[Dict[str, Any]]]:
        """Execute a SQL query using psql and return results as list of dicts."""
        if not self.conn_string:
            logger.error("No database connection string configured")
            return None

        temp_file = None
        try:
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
                if return_results and query.strip().upper().startswith('SELECT'):
                    json_query = f"""
SELECT json_agg(row_to_json(t)) 
FROM ({query.rstrip(';')}) t;
"""
                    f.write(json_query)
                else:
                    f.write(query)
                temp_file = f.name

            cmd = [
                PSQL_PATH,
                self.conn_string,
                "-t",
                "-A",
                "-f", temp_file
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace',
                timeout=30
            )

            if result.returncode != 0:
                logger.error(f"psql error: {result.stderr}")
                return None

            output = result.stdout.strip()
            
            if not return_results:
                return None
                
            if not output or output == '' or output == 'null':
                return []

            try:
                rows = json.loads(output)
                return rows if rows else []
            except json.JSONDecodeError:
                logger.debug(f"Raw output: {output}")
                return []

        except subprocess.TimeoutExpired:
            logger.error("Query timed out")
            return None
        except Exception as e:
            logger.error(f"Error executing query: {e}")
            return None
        finally:
            if temp_file and os.path.exists(temp_file):
                os.remove(temp_file)

    def _execute_update(self, query: str) -> Optional[Dict[str, Any]]:
        """Execute an UPDATE/INSERT/DELETE query using psql with RETURNING."""
        if not self.conn_string:
            logger.error("No database connection string configured")
            return None

        temp_file = None
        try:
            has_returning = 'RETURNING' in query.upper()
            if has_returning:
                wrapped_query = f"""
SELECT row_to_json(t) FROM (
{query.rstrip(';')}
) t;
"""
            else:
                wrapped_query = query
            
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
                f.write(wrapped_query)
                temp_file = f.name

            cmd = [
                PSQL_PATH,
                self.conn_string,
                "-t",
                "-A",
                "-v", "ON_ERROR_STOP=1",
                "-f", temp_file
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace',
                timeout=30
            )

            if result.returncode != 0:
                logger.error(f"psql error: {result.stderr}")
                return None

            output = result.stdout.strip()
            
            if not has_returning or not output:
                return {}
            
            try:
                return json.loads(output)
            except json.JSONDecodeError:
                return {}

        except subprocess.TimeoutExpired:
            logger.error("Update query timed out")
            return None
        except Exception as e:
            logger.error(f"Error executing update: {e}")
            return None
        finally:
            if temp_file and os.path.exists(temp_file):
                os.remove(temp_file)

    def _escape_string(self, value: str) -> str:
        """Escape single quotes for SQL strings."""
        if value is None:
            return "NULL"
        return value.replace("'", "''")

    # =========================================================================
    # Restaurant Methods
    # =========================================================================

    def get_restaurant_by_id(self, restaurant_id: int) -> Optional[Dict[str, Any]]:
        """Get restaurant by V3 ID."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE id = {restaurant_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

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
            WHERE d.restaurant_id = {restaurant_id} 
              AND d.deleted_at IS NULL 
              AND d.is_combo = FALSE
              AND d.source_id IS NOT NULL
            ORDER BY c.display_order, d.display_order
        """
        results = self._execute_query(query)
        return results if results else []

    def get_dish_by_source_id(self, restaurant_id: int, source_id: int) -> Optional[Dict[str, Any]]:
        """Get dish by V1 source_id."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id, course_id
            FROM {self.schema}.dishes
            WHERE restaurant_id = {restaurant_id} AND source_id = {source_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    # =========================================================================
    # Modifier Group Methods
    # =========================================================================

    def get_modifier_groups_by_dish(self, dish_id: int) -> List[Dict[str, Any]]:
        """Get all modifier groups for a dish."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, min_selections, max_selections, free_items, display_order
            FROM {self.schema}.modifier_groups
            WHERE dish_id = {dish_id} AND deleted_at IS NULL
            ORDER BY display_order, id
        """
        results = self._execute_query(query)
        return results if results else []

    def get_modifier_group_by_name(self, dish_id: int, name: str) -> Optional[Dict[str, Any]]:
        """Get modifier group by dish_id and name."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        query = f"""
            SELECT id, name, min_selections, max_selections, free_items, display_order
            FROM {self.schema}.modifier_groups
            WHERE dish_id = {dish_id} AND name = '{escaped_name}' AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

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

            if min_selections is not None:
                updates.append(f"min_selections = {min_selections}")
            if max_selections is not None:
                updates.append(f"max_selections = {max_selections}")
            if free_items is not None:
                updates.append(f"free_items = {free_items}")
            if display_order is not None:
                updates.append(f"display_order = {display_order}")
            if name is not None:
                updates.append(f"name = '{self._escape_string(name)}'")

            if not updates:
                logger.debug(f"No updates for modifier_group {modifier_group_id}")
                return True

            updates.append("updated_at = NOW()")

            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET {', '.join(updates)}
                WHERE id = {modifier_group_id}
            """
            result = self._execute_update(query)

            if result is not None:
                logger.debug(f"Updated modifier_group {modifier_group_id}")
                return True
            return False

        except Exception as e:
            logger.error(f"Failed to update modifier_group {modifier_group_id}: {e}")
            return False

    # =========================================================================
    # Dish Availability Methods
    # =========================================================================

    def update_dish_hide_option(self, dish_id: int, enabled: bool) -> bool:
        """Set the hide_option_enabled flag on a dish."""
        self.ensure_connection()
        flag = 'TRUE' if enabled else 'FALSE'
        
        try:
            query = f"""
                UPDATE {self.schema}.dishes
                SET hide_option_enabled = {flag}, updated_at = NOW()
                WHERE id = {dish_id}
            """
            result = self._execute_update(query)
            if result is not None:
                logger.debug(f"Set hide_option_enabled={enabled} for dish {dish_id}")
                return True
            return False
        except Exception as e:
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
        is_hidden_str = 'TRUE' if is_hidden else 'FALSE'
        
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_availability
                WHERE dish_id = {dish_id} AND day_of_week = {day_of_week}
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                # Update existing
                query = f"""
                    UPDATE {self.schema}.dish_availability
                    SET is_hidden = {is_hidden_str}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                # Insert new
                query = f"""
                    INSERT INTO {self.schema}.dish_availability
                    (dish_id, day_of_week, is_hidden)
                    VALUES ({dish_id}, {day_of_week}, {is_hidden_str})
                    RETURNING id
                """

            result = self._execute_update(query)
            return result.get('id') if result else None

        except Exception as e:
            logger.error(f"Failed to upsert dish_availability for dish {dish_id}, day {day_of_week}: {e}")
            return None

    def clear_dish_availability(self, dish_id: int) -> bool:
        """Remove all dish_availability records for a dish."""
        self.ensure_connection()
        try:
            query = f"""
                DELETE FROM {self.schema}.dish_availability
                WHERE dish_id = {dish_id}
            """
            result = self._execute_update(query)
            return result is not None
        except Exception as e:
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
            WHERE d.restaurant_id = {restaurant_id} 
              AND mg.deleted_at IS NULL 
              AND d.deleted_at IS NULL
        """
        result = self._execute_query(query)
        return result[0]['count'] if result else 0

    def get_dish_availability_count(self, restaurant_id: int) -> int:
        """Get count of dish_availability records for a restaurant."""
        self.ensure_connection()
        query = f"""
            SELECT COUNT(da.id) as count
            FROM {self.schema}.dish_availability da
            JOIN {self.schema}.dishes d ON da.dish_id = d.id
            WHERE d.restaurant_id = {restaurant_id} AND d.deleted_at IS NULL
        """
        result = self._execute_query(query)
        return result[0]['count'] if result else 0

    def get_restaurant_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get statistics for a restaurant."""
        self.ensure_connection()
        return {
            'modifier_groups': self.get_modifier_group_count(restaurant_id),
            'dish_availability_records': self.get_dish_availability_count(restaurant_id),
        }
