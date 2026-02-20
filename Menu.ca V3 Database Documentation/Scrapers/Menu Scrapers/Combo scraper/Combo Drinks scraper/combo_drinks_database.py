"""Database operations for combo drinks modifier group scraping using psql.

This module uses psql subprocess calls for all CRUD operations per project guidelines.
"""
import subprocess
import json
import tempfile
import os
import logging
from typing import Optional, Dict, List, Any

from combo_drinks_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)

# psql path for Windows
PSQL_PATH = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"


class ComboDrinksDatabase:
    """Manages database operations for combo drinks modifier groups using psql."""

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
        """
        Execute a SQL query using psql and return results as list of dicts.
        
        Args:
            query: SQL query to execute
            return_results: If True, parse and return JSON results
            
        Returns:
            List of dicts for SELECT queries, None for INSERT/UPDATE/DELETE
        """
        if not self.conn_string:
            logger.error("No database connection string configured")
            return None

        # Write query to temp file to handle complex SQL
        temp_file = None
        try:
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
                # For SELECT queries, wrap with JSON output
                if return_results and query.strip().upper().startswith('SELECT'):
                    # Use row_to_json to get JSON output
                    json_query = f"""
SELECT json_agg(row_to_json(t)) 
FROM ({query.rstrip(';')}) t;
"""
                    f.write(json_query)
                else:
                    f.write(query)
                temp_file = f.name

            # Build psql command
            cmd = [
                PSQL_PATH,
                self.conn_string,
                "-t",  # Tuples only (no headers)
                "-A",  # Unaligned output
                "-f", temp_file
            ]

            # Execute
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

            # Parse JSON output
            try:
                rows = json.loads(output)
                return rows if rows else []
            except json.JSONDecodeError:
                # Not JSON, return raw output
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

    def _execute_update(self, query: str) -> bool:
        """
        Execute an UPDATE/INSERT/DELETE query using psql.
        
        Args:
            query: SQL statement to execute
            
        Returns:
            True if successful, False otherwise
        """
        if not self.conn_string:
            logger.error("No database connection string configured")
            return False

        temp_file = None
        try:
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
                f.write(query)
                temp_file = f.name

            cmd = [
                PSQL_PATH,
                self.conn_string,
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
                return False

            return True

        except subprocess.TimeoutExpired:
            logger.error("Update query timed out")
            return False
        except Exception as e:
            logger.error(f"Error executing update: {e}")
            return False
        finally:
            if temp_file and os.path.exists(temp_file):
                os.remove(temp_file)

    def _escape_string(self, value: str) -> str:
        """Escape single quotes for SQL strings."""
        if value is None:
            return "NULL"
        return value.replace("'", "''")

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
            WHERE restaurant_id = {restaurant_id} 
              AND source_id = {combo_id} 
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            results = self._execute_query(query)
            return results[0] if results else None
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
            WHERE restaurant_id = {restaurant_id} 
              AND is_combo = TRUE
              AND deleted_at IS NULL
            ORDER BY id
        """
        try:
            results = self._execute_query(query)
            return results if results else []
        except Exception as e:
            logger.error(f"Error getting combo dishes: {e}")
            return []

    # =========================================================================
    # Modifier Group Queries
    # =========================================================================

    def get_modifier_group_by_name(self, dish_id: int, name: str) -> Optional[Dict[str, Any]]:
        """
        Find modifier group by dish_id and name.
        
        The name should match the drinksHeader value from V1.
        
        Args:
            dish_id: V3 dish ID
            name: Modifier group name (from drinksHeader)
            
        Returns:
            Dict with modifier group info or None if not found
        """
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        query = f"""
            SELECT id, dish_id, name, min_selections, max_selections, free_items, 
                   display_order, updated_at
            FROM {self.schema}.modifier_groups
            WHERE dish_id = {dish_id} 
              AND name = '{escaped_name}' 
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            results = self._execute_query(query)
            return results[0] if results else None
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
            WHERE dish_id = {dish_id} AND deleted_at IS NULL
            ORDER BY display_order, id
        """
        try:
            results = self._execute_query(query)
            return results if results else []
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
            WHERE dish_id = {dish_id} 
              AND LOWER(name) LIKE '%drink%'
              AND deleted_at IS NULL
            LIMIT 1
        """
        try:
            results = self._execute_query(query)
            return results[0] if results else None
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
        
        escaped_name = self._escape_string(name)
        
        if display_order is not None:
            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET name = '{escaped_name}',
                    min_selections = {min_selections},
                    max_selections = {max_selections},
                    free_items = {free_items},
                    display_order = {display_order},
                    updated_at = NOW()
                WHERE id = {modifier_group_id};
            """
        else:
            query = f"""
                UPDATE {self.schema}.modifier_groups
                SET name = '{escaped_name}',
                    min_selections = {min_selections},
                    max_selections = {max_selections},
                    free_items = {free_items},
                    updated_at = NOW()
                WHERE id = {modifier_group_id};
            """
        
        try:
            success = self._execute_update(query)
            if success:
                logger.debug(f"Updated modifier_group {modifier_group_id}: name={name}, min={min_selections}, max={max_selections}, free={free_items}, order={display_order}")
            return success
        except Exception as e:
            logger.error(f"Error updating modifier group settings: {e}")
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
            WHERE mg.id = {modifier_group_id}
        """
        try:
            results = self._execute_query(query)
            return results[0] if results else None
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
            query1 = f"""
                SELECT COUNT(*) as cnt
                FROM {self.schema}.dishes
                WHERE restaurant_id = {restaurant_id} AND is_combo = TRUE AND deleted_at IS NULL
            """
            result = self._execute_query(query1)
            if result and len(result) > 0:
                stats['total_combo_dishes'] = result[0].get('cnt', 0)
            
            # Count dishes with drinks modifier groups
            query2 = f"""
                SELECT COUNT(DISTINCT d.id) as cnt
                FROM {self.schema}.dishes d
                JOIN {self.schema}.modifier_groups mg ON mg.dish_id = d.id
                WHERE d.restaurant_id = {restaurant_id} 
                  AND d.is_combo = TRUE 
                  AND d.deleted_at IS NULL
                  AND mg.deleted_at IS NULL
                  AND LOWER(mg.name) LIKE '%drink%'
            """
            result = self._execute_query(query2)
            if result and len(result) > 0:
                stats['dishes_with_drinks_modifier'] = result[0].get('cnt', 0)
            
            # Count drinks modifier groups
            query3 = f"""
                SELECT COUNT(*) as cnt
                FROM {self.schema}.modifier_groups mg
                JOIN {self.schema}.dishes d ON d.id = mg.dish_id
                WHERE d.restaurant_id = {restaurant_id} 
                  AND d.deleted_at IS NULL
                  AND mg.deleted_at IS NULL
                  AND LOWER(mg.name) LIKE '%drink%'
            """
            result = self._execute_query(query3)
            if result and len(result) > 0:
                stats['total_drinks_modifier_groups'] = result[0].get('cnt', 0)
            
            return stats
        except Exception as e:
            logger.error(f"Error getting drinks stats: {e}")
            return stats
