"""Database operations for combo modifiers scraping using psql.

This module uses psql subprocess calls for all CRUD operations per project guidelines.
"""
import subprocess
import json
import tempfile
import os
import logging
from typing import Optional, Dict, List, Any

from combo_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)

# psql path for Windows
PSQL_PATH = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"


class ComboDatabase:
    """Manages database operations for combo tables using psql."""

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
        """
        Execute an UPDATE/INSERT/DELETE query using psql with RETURNING.
        
        Args:
            query: SQL statement to execute (should include RETURNING clause if needed)
            
        Returns:
            Dict with returned values, or empty dict if no RETURNING, or None on error
        """
        if not self.conn_string:
            logger.error("No database connection string configured")
            return None

        temp_file = None
        try:
            # Wrap with JSON output for RETURNING clause using CTE pattern
            has_returning = 'RETURNING' in query.upper()
            if has_returning:
                # Use CTE pattern: WITH result AS (INSERT/UPDATE... RETURNING *) SELECT row_to_json(result) FROM result
                wrapped_query = f"""
WITH result AS (
{query.rstrip(';')}
)
SELECT row_to_json(result) FROM result;
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
    # Restaurant Queries
    # =========================================================================

    def get_restaurant_by_v1_id(self, v1_id: int) -> Optional[Dict[str, Any]]:
        """Get restaurant by V1 legacy ID."""
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE legacy_v1_id = {v1_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    def get_restaurant_by_id(self, restaurant_id: int) -> Optional[Dict[str, Any]]:
        """Get restaurant by V3 ID."""
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE id = {restaurant_id} AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    def get_restaurants_with_v1_id(self) -> List[Dict[str, Any]]:
        """Get all restaurants that have a V1 legacy ID."""
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE legacy_v1_id IS NOT NULL AND deleted_at IS NULL
            ORDER BY id
        """
        results = self._execute_query(query)
        return results if results else []

    def get_dish_by_name(self, restaurant_id: int, dish_name: str) -> Optional[Dict[str, Any]]:
        """Get dish by name for a restaurant (with fuzzy matching support)."""
        escaped_name = self._escape_string(dish_name)
        
        # First try exact match
        query = f"""
            SELECT id, name, description
            FROM {self.schema}.dishes
            WHERE restaurant_id = {restaurant_id} AND name = '{escaped_name}' AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        if results:
            return results[0]

        # Try without " HIDE" suffix
        clean_name = dish_name.replace(' HIDE', '').strip()
        escaped_clean = self._escape_string(clean_name)
        
        query = f"""
            SELECT id, name, description
            FROM {self.schema}.dishes
            WHERE restaurant_id = {restaurant_id} AND name = '{escaped_clean}' AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        if results:
            return results[0]

        # Try ILIKE match
        query = f"""
            SELECT id, name, description
            FROM {self.schema}.dishes
            WHERE restaurant_id = {restaurant_id} 
              AND LOWER(REPLACE(name, ' HIDE', '')) ILIKE LOWER('%{escaped_clean}%')
              AND deleted_at IS NULL
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    # =========================================================================
    # Combo Groups (Table 1)
    # =========================================================================

    def insert_combo_group(self, restaurant_id: int, name: str,
                           number_of_items: int = None,
                           display_header: str = None,
                           source_id: int = None) -> Optional[int]:
        """Insert a combo group and return its ID."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        escaped_header = f"'{self._escape_string(display_header)}'" if display_header else "NULL"
        num_items = str(number_of_items) if number_of_items is not None else "NULL"
        src_id = str(source_id) if source_id is not None else "NULL"
        
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_groups
                WHERE restaurant_id = {restaurant_id} AND source_id = {src_id}
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                # Update existing
                query = f"""
                    UPDATE {self.schema}.combo_groups
                    SET name = '{escaped_name}',
                        special_number_of_items = {num_items},
                        special_display_header = {escaped_header},
                        updated_at = NOW()
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                # Insert new
                query = f"""
                    INSERT INTO {self.schema}.combo_groups
                    (restaurant_id, name, special_number_of_items, special_display_header, source_id)
                    VALUES ({restaurant_id}, '{escaped_name}', {num_items}, {escaped_header}, {src_id})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert combo_group '{name}': {e}")
            return None

    # =========================================================================
    # Dish Combo Groups - Junction Table (Table 2)
    # =========================================================================

    def insert_dish_combo_group(self, dish_id: int, combo_group_id: int,
                                is_active: bool = True) -> Optional[int]:
        """Insert a dish-to-combo-group link."""
        self.ensure_connection()
        is_active_str = 'TRUE' if is_active else 'FALSE'
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.dish_combo_groups
                WHERE dish_id = {dish_id} AND combo_group_id = {combo_group_id}
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.dish_combo_groups
                    SET is_active = {is_active_str}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.dish_combo_groups
                    (dish_id, combo_group_id, is_active)
                    VALUES ({dish_id}, {combo_group_id}, {is_active_str})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert dish_combo_group (dish={dish_id}, group={combo_group_id}): {e}")
            return None

    # =========================================================================
    # Combo Group Sections (Table 3)
    # =========================================================================

    def insert_combo_group_section(self, combo_group_id: int, section_type: str,
                                   use_header: str, display_order: int,
                                   free_items: int = 0, min_selection: int = 0,
                                   max_selection: int = 1,
                                   is_active: bool = True) -> Optional[int]:
        """Insert a combo group section and return its ID."""
        self.ensure_connection()
        escaped_type = self._escape_string(section_type)
        escaped_header = self._escape_string(use_header)
        is_active_str = 'TRUE' if is_active else 'FALSE'
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.combo_group_sections
                WHERE combo_group_id = {combo_group_id} AND section_type = '{escaped_type}'
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.combo_group_sections
                    SET use_header = '{escaped_header}',
                        display_order = {display_order},
                        free_items = {free_items},
                        min_selection = {min_selection},
                        max_selection = {max_selection},
                        is_active = {is_active_str}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.combo_group_sections
                    (combo_group_id, section_type, use_header, display_order,
                     free_items, min_selection, max_selection, is_active)
                    VALUES ({combo_group_id}, '{escaped_type}', '{escaped_header}', {display_order},
                            {free_items}, {min_selection}, {max_selection}, {is_active_str})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert combo_group_section '{section_type}': {e}")
            return None

    # =========================================================================
    # Combo Modifier Groups (Table 4)
    # =========================================================================

    def insert_combo_modifier_group(self, combo_group_section_id: int, name: str,
                                    type_code: str = None,
                                    is_selected: bool = False,
                                    source_id: int = None) -> Optional[int]:
        """Insert a combo modifier group and return its ID."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        type_code_str = f"'{self._escape_string(type_code)}'" if type_code else "NULL"
        is_selected_str = 'TRUE' if is_selected else 'FALSE'
        src_id = str(source_id) if source_id is not None else "NULL"
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifier_groups
                WHERE combo_group_section_id = {combo_group_section_id} AND source_id = {src_id}
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.combo_modifier_groups
                    SET name = '{escaped_name}',
                        type_code = {type_code_str},
                        is_selected = {is_selected_str}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.combo_modifier_groups
                    (combo_group_section_id, name, type_code, is_selected, source_id)
                    VALUES ({combo_group_section_id}, '{escaped_name}', {type_code_str}, {is_selected_str}, {src_id})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert combo_modifier_group '{name}': {e}")
            return None

    # =========================================================================
    # Combo Modifiers (Table 5)
    # =========================================================================

    def insert_combo_modifier(self, combo_modifier_group_id: int, name: str,
                              display_order: int = 0) -> Optional[int]:
        """Insert a combo modifier and return its ID."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifiers
                WHERE combo_modifier_group_id = {combo_modifier_group_id} AND name = '{escaped_name}'
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.combo_modifiers
                    SET display_order = {display_order}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.combo_modifiers
                    (combo_modifier_group_id, name, display_order)
                    VALUES ({combo_modifier_group_id}, '{escaped_name}', {display_order})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert combo_modifier '{name}': {e}")
            return None

    # =========================================================================
    # Combo Modifier Prices (Table 6)
    # =========================================================================

    def insert_combo_modifier_price(self, combo_modifier_id: int,
                                    size_variant: str, price: float) -> Optional[int]:
        """Insert a combo modifier price and return its ID."""
        self.ensure_connection()
        escaped_size = self._escape_string(size_variant)
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifier_prices
                WHERE combo_modifier_id = {combo_modifier_id} AND size_variant = '{escaped_size}'
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.combo_modifier_prices
                    SET price = {price}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.combo_modifier_prices
                    (combo_modifier_id, size_variant, price)
                    VALUES ({combo_modifier_id}, '{escaped_size}', {price})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert combo_modifier_price (modifier={combo_modifier_id}, size={size_variant}): {e}")
            return None

    # =========================================================================
    # Dish Availability (Hide On Days)
    # =========================================================================

    def update_dish_hide_option(self, dish_id: int, hide_option_enabled: bool) -> bool:
        """Update the hide_option_enabled flag on a dish."""
        self.ensure_connection()
        flag = 'TRUE' if hide_option_enabled else 'FALSE'
        
        try:
            query = f"""
                UPDATE {self.schema}.dishes
                SET hide_option_enabled = {flag}, updated_at = NOW()
                WHERE id = {dish_id}
            """
            result = self._execute_update(query)
            return result is not None
        except Exception as e:
            logger.error(f"Failed to update hide_option_enabled for dish {dish_id}: {e}")
            return False

    def insert_dish_availability(self, dish_id: int, day_of_week: int,
                                 is_hidden: bool = True) -> Optional[int]:
        """Insert a dish availability record."""
        self.ensure_connection()
        is_hidden_str = 'TRUE' if is_hidden else 'FALSE'
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.dish_availability
                WHERE dish_id = {dish_id} AND day_of_week = {day_of_week}
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.dish_availability
                    SET is_hidden = {is_hidden_str}
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.dish_availability
                    (dish_id, day_of_week, is_hidden)
                    VALUES ({dish_id}, {day_of_week}, {is_hidden_str})
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert dish_availability (dish={dish_id}, day={day_of_week}): {e}")
            return None

    # =========================================================================
    # Utility Methods
    # =========================================================================

    def get_combo_group_by_source_id(self, restaurant_id: int,
                                     source_id: int) -> Optional[Dict[str, Any]]:
        """Get combo group by source_id."""
        query = f"""
            SELECT id, name, source_id
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = {restaurant_id} AND source_id = {source_id}
            LIMIT 1
        """
        results = self._execute_query(query)
        return results[0] if results else None

    # =========================================================================
    # Drinks Modifiers (Standard Menu Tables)
    # =========================================================================

    def insert_modifier_group(self, dish_id: int, name: str,
                              is_required: bool = False,
                              min_selections: int = 0,
                              max_selections: int = 1,
                              free_items: int = 0,
                              display_order: int = 0) -> Optional[int]:
        """Insert a modifier group for a dish and return its ID."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        is_req = 'TRUE' if is_required else 'FALSE'
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.modifier_groups
                WHERE dish_id = {dish_id} AND name = '{escaped_name}' AND deleted_at IS NULL
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.modifier_groups
                    SET is_required = {is_req},
                        min_selections = {min_selections},
                        max_selections = {max_selections},
                        free_items = {free_items},
                        display_order = {display_order},
                        updated_at = NOW()
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.modifier_groups
                    (dish_id, name, is_required, min_selections, max_selections,
                     free_items, display_order, is_custom)
                    VALUES ({dish_id}, '{escaped_name}', {is_req}, {min_selections}, {max_selections},
                            {free_items}, {display_order}, TRUE)
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert modifier_group '{name}' for dish {dish_id}: {e}")
            return None

    def insert_dish_modifier(self, restaurant_id: int, dish_id: int,
                             modifier_group_id: int, name: str,
                             modifier_type: str = 'drinks',
                             display_order: int = 0,
                             is_default: bool = False,
                             is_included: bool = False) -> Optional[int]:
        """Insert a dish modifier and return its ID."""
        self.ensure_connection()
        escaped_name = self._escape_string(name)
        escaped_type = self._escape_string(modifier_type)
        is_def = 'TRUE' if is_default else 'FALSE'
        is_inc = 'TRUE' if is_included else 'FALSE'
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifiers
                WHERE modifier_group_id = {modifier_group_id} AND name = '{escaped_name}' AND deleted_at IS NULL
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.dish_modifiers
                    SET modifier_type = '{escaped_type}',
                        display_order = {display_order},
                        is_default = {is_def},
                        is_included = {is_inc},
                        updated_at = NOW()
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.dish_modifiers
                    (restaurant_id, dish_id, modifier_group_id, name, modifier_type,
                     display_order, is_default, is_included, source_system)
                    VALUES ({restaurant_id}, {dish_id}, {modifier_group_id}, '{escaped_name}', '{escaped_type}',
                            {display_order}, {is_def}, {is_inc}, 'v1')
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert dish_modifier '{name}': {e}")
            return None

    def insert_dish_modifier_price(self, dish_modifier_id: int, dish_id: int,
                                   restaurant_id: int, price: float,
                                   size_variant: str = 'Standard',
                                   display_order: int = 1) -> Optional[int]:
        """Insert a dish modifier price and return its ID."""
        self.ensure_connection()
        escaped_size = self._escape_string(size_variant)
        
        try:
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifier_prices
                WHERE dish_modifier_id = {dish_modifier_id} AND size_variant = '{escaped_size}' AND deleted_at IS NULL
                LIMIT 1
            """
            existing = self._execute_query(check_query)

            if existing:
                query = f"""
                    UPDATE {self.schema}.dish_modifier_prices
                    SET price = {price},
                        display_order = {display_order},
                        updated_at = NOW()
                    WHERE id = {existing[0]['id']}
                    RETURNING id
                """
            else:
                query = f"""
                    INSERT INTO {self.schema}.dish_modifier_prices
                    (dish_modifier_id, dish_id, restaurant_id, size_variant, price,
                     display_order, is_active, source_system)
                    VALUES ({dish_modifier_id}, {dish_id}, {restaurant_id}, '{escaped_size}', {price},
                            {display_order}, TRUE, 'v1')
                    RETURNING id
                """
            
            result = self._execute_update(query)
            return result.get('id') if result else None
        except Exception as e:
            logger.error(f"Failed to insert dish_modifier_price for modifier {dish_modifier_id}: {e}")
            return None

    def get_combo_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get combo statistics for a restaurant."""
        stats = {}

        # Count combo groups
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_groups
            WHERE restaurant_id = {restaurant_id} AND deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['combo_groups'] = result[0]['count'] if result else 0

        # Count sections
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_group_sections cgs
            JOIN {self.schema}.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = {restaurant_id} AND cg.deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['sections'] = result[0]['count'] if result else 0

        # Count modifier groups
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_modifier_groups cmg
            JOIN {self.schema}.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN {self.schema}.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = {restaurant_id} AND cg.deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['modifier_groups'] = result[0]['count'] if result else 0

        # Count modifiers
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_modifiers cm
            JOIN {self.schema}.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
            JOIN {self.schema}.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN {self.schema}.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = {restaurant_id} AND cg.deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['modifiers'] = result[0]['count'] if result else 0

        # Count prices
        query = f"""
            SELECT COUNT(*) as count FROM {self.schema}.combo_modifier_prices cmp
            JOIN {self.schema}.combo_modifiers cm ON cmp.combo_modifier_id = cm.id
            JOIN {self.schema}.combo_modifier_groups cmg ON cm.combo_modifier_group_id = cmg.id
            JOIN {self.schema}.combo_group_sections cgs ON cmg.combo_group_section_id = cgs.id
            JOIN {self.schema}.combo_groups cg ON cgs.combo_group_id = cg.id
            WHERE cg.restaurant_id = {restaurant_id} AND cg.deleted_at IS NULL
        """
        result = self._execute_query(query)
        stats['prices'] = result[0]['count'] if result else 0

        return stats
