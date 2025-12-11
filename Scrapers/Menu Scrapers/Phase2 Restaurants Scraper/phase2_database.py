"""Database operations for Phase 2 Restaurants Scraper.

Handles all 12 tables:
- Combo: combo_groups, dish_combo_groups, combo_group_sections, 
         combo_modifier_groups, combo_modifiers, combo_modifier_prices
- Menu: courses, dishes, dish_prices, modifier_groups, dish_modifiers, dish_modifier_prices
"""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List, Any
import logging

from phase2_config import DB_CONNECTION_STRING, SCHEMA

logger = logging.getLogger(__name__)


class Phase2Database:
    """Manages database operations for Phase 2 Restaurants Scraper."""

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
    # Restaurant Queries
    # =========================================================================

    def get_restaurant_by_v1_id(self, v1_id: int) -> Optional[Dict[str, Any]]:
        """Get restaurant by V1 legacy ID."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, legacy_v1_id
            FROM {self.schema}.restaurants
            WHERE legacy_v1_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (v1_id,))
        result = self.cursor.fetchone()
        return dict(result) if result else None

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
    # COURSES (Table 7)
    # =========================================================================

    def insert_course(self, restaurant_id: int, name: str,
                      display_order: int = 0,
                      source_id: int = None) -> Optional[int]:
        """Insert a course and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists by source_id or name
            if source_id:
                check_query = f"""
                    SELECT id FROM {self.schema}.courses
                    WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
                    LIMIT 1
                """
                self.cursor.execute(check_query, (restaurant_id, source_id))
            else:
                check_query = f"""
                    SELECT id FROM {self.schema}.courses
                    WHERE restaurant_id = %s AND name = %s AND deleted_at IS NULL
                    LIMIT 1
                """
                self.cursor.execute(check_query, (restaurant_id, name))

            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.courses
                    SET name = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(
                    update_query, (name, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.courses
                    (restaurant_id, name, display_order, source_id)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, name, display_order, source_id
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert course '{name}': {e}")
            return None

    def get_course_by_source_id(self, restaurant_id: int, source_id: int) -> Optional[Dict[str, Any]]:
        """Get course by source_id."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id, display_order
            FROM {self.schema}.courses
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    # =========================================================================
    # DISHES (Table 8)
    # =========================================================================

    def insert_dish(self, restaurant_id: int, course_id: int, name: str,
                    description: str = None,
                    display_order: int = 0,
                    is_combo: bool = False,
                    source_id: int = None,
                    hide_option_enabled: bool = False) -> Optional[int]:
        """Insert a dish and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists by source_id or name+course
            if source_id:
                check_query = f"""
                    SELECT id FROM {self.schema}.dishes
                    WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
                    LIMIT 1
                """
                self.cursor.execute(check_query, (restaurant_id, source_id))
            else:
                check_query = f"""
                    SELECT id FROM {self.schema}.dishes
                    WHERE restaurant_id = %s AND course_id = %s AND name = %s AND deleted_at IS NULL
                    LIMIT 1
                """
                self.cursor.execute(
                    check_query, (restaurant_id, course_id, name))

            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dishes
                    SET course_id = %s,
                        name = %s,
                        description = %s,
                        display_order = %s,
                        is_combo = %s,
                        hide_option_enabled = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    course_id, name, description, display_order,
                    is_combo, hide_option_enabled, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dishes
                    (restaurant_id, course_id, name, description, display_order, 
                     is_combo, source_id, hide_option_enabled)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, course_id, name, description, display_order,
                    is_combo, source_id, hide_option_enabled
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert dish '{name}': {e}")
            return None

    def get_dish_by_name(self, restaurant_id: int, dish_name: str) -> Optional[Dict[str, Any]]:
        """Get dish by name for a restaurant."""
        self.ensure_connection()
        # First try exact match
        query = f"""
            SELECT id, name, description, course_id, is_combo
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND name = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, dish_name))
        result = self.cursor.fetchone()
        if result:
            return dict(result)

        # Try without " HIDE" suffix
        clean_name = dish_name.replace(' HIDE', '').strip()
        self.cursor.execute(query, (restaurant_id, clean_name))
        result = self.cursor.fetchone()
        if result:
            return dict(result)

        # Try case-insensitive match
        ilike_query = f"""
            SELECT id, name, description, course_id, is_combo
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s 
              AND LOWER(REPLACE(name, ' HIDE', '')) = LOWER(%s)
              AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(ilike_query, (restaurant_id, clean_name))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def get_dish_by_source_id(self, restaurant_id: int, source_id: int) -> Optional[Dict[str, Any]]:
        """Get dish by source_id."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, course_id, is_combo
            FROM {self.schema}.dishes
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def update_dish_hide_option(self, dish_id: int, hide_option_enabled: bool) -> bool:
        """Update the hide_option_enabled flag on a dish."""
        self.ensure_connection()
        try:
            query = f"""
                UPDATE {self.schema}.dishes
                SET hide_option_enabled = %s, updated_at = NOW()
                WHERE id = %s
            """
            self.cursor.execute(query, (hide_option_enabled, dish_id))
            self.conn.commit()
            return True
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to update hide_option_enabled for dish {dish_id}: {e}")
            return False

    # =========================================================================
    # DISH PRICES (Table 9)
    # =========================================================================

    def insert_dish_price(self, dish_id: int, restaurant_id: int,
                          price: float, size_variant: str = 'Standard',
                          display_order: int = 1) -> Optional[int]:
        """Insert a dish price and return its ID.

        Note: restaurant_id is accepted for compatibility but not used in the table.
        """
        self.ensure_connection()

        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_prices
                WHERE dish_id = %s AND size_variant = %s AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, size_variant))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dish_prices
                    SET price = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(
                    update_query, (price, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_prices
                    (dish_id, size_variant, price, display_order)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    dish_id, size_variant, price, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert dish_price for dish {dish_id}: {e}")
            return None

    # =========================================================================
    # DISH AVAILABILITY (Hide On Days)
    # =========================================================================

    def insert_dish_availability(self, dish_id: int, day_of_week: int,
                                 is_hidden: bool = True) -> Optional[int]:
        """Insert a dish availability record."""
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
                self.cursor.execute(
                    insert_query, (dish_id, day_of_week, is_hidden))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert dish_availability (dish={dish_id}, day={day_of_week}): {e}")
            return None

    # =========================================================================
    # COMBO GROUPS (Table 1)
    # =========================================================================

    def insert_combo_group(self, restaurant_id: int, name: str,
                           number_of_items: int = None,
                           display_header: str = None,
                           source_id: int = None) -> Optional[int]:
        """Insert a combo group and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_groups
                WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (restaurant_id, source_id))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_groups
                    SET name = %s,
                        number_of_items = %s,
                        display_header = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    name, number_of_items, display_header, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_groups
                    (restaurant_id, name, number_of_items, display_header, source_id)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, name, number_of_items, display_header, source_id
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert combo_group '{name}': {e}")
            return None

    def get_combo_group_by_source_id(self, restaurant_id: int,
                                     source_id: int) -> Optional[Dict[str, Any]]:
        """Get combo group by source_id."""
        self.ensure_connection()
        query = f"""
            SELECT id, name, source_id
            FROM {self.schema}.combo_groups
            WHERE restaurant_id = %s AND source_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id, source_id))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    # =========================================================================
    # DISH COMBO GROUPS - Junction Table (Table 2)
    # =========================================================================

    def insert_dish_combo_group(self, dish_id: int, combo_group_id: int,
                                is_active: bool = True) -> Optional[int]:
        """Insert a dish-to-combo-group link."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_combo_groups
                WHERE dish_id = %s AND combo_group_id = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, combo_group_id))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dish_combo_groups
                    SET is_active = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (is_active, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_combo_groups
                    (dish_id, combo_group_id, is_active)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(
                    insert_query, (dish_id, combo_group_id, is_active))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert dish_combo_group (dish={dish_id}, group={combo_group_id}): {e}")
            return None

    # =========================================================================
    # COMBO GROUP SECTIONS (Table 3)
    # =========================================================================

    def insert_combo_group_section(self, combo_group_id: int, section_type: str,
                                   use_header: str = '', display_order: int = 0,
                                   free_items: int = 0, min_selection: int = 0,
                                   max_selection: int = 1,
                                   is_active: bool = True) -> Optional[int]:
        """Insert a combo group section and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_group_sections
                WHERE combo_group_id = %s AND section_type = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (combo_group_id, section_type))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_group_sections
                    SET use_header = %s,
                        display_order = %s,
                        free_items = %s,
                        min_selection = %s,
                        max_selection = %s,
                        is_active = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    use_header, display_order, free_items, min_selection,
                    max_selection, is_active, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_group_sections
                    (combo_group_id, section_type, use_header, display_order,
                     free_items, min_selection, max_selection, is_active)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    combo_group_id, section_type, use_header, display_order,
                    free_items, min_selection, max_selection, is_active
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert combo_group_section '{section_type}': {e}")
            return None

    # =========================================================================
    # COMBO MODIFIER GROUPS (Table 4)
    # =========================================================================

    def insert_combo_modifier_group(self, combo_group_section_id: int, name: str,
                                    type_code: str = None,
                                    is_selected: bool = False,
                                    source_id: int = None) -> Optional[int]:
        """Insert a combo modifier group and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifier_groups
                WHERE combo_group_section_id = %s AND source_id = %s
                LIMIT 1
            """
            self.cursor.execute(
                check_query, (combo_group_section_id, source_id))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_modifier_groups
                    SET name = %s,
                        type_code = %s,
                        is_selected = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    name, type_code, is_selected, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_modifier_groups
                    (combo_group_section_id, name, type_code, is_selected, source_id)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    combo_group_section_id, name, type_code, is_selected, source_id
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert combo_modifier_group '{name}': {e}")
            return None

    # =========================================================================
    # COMBO MODIFIERS (Table 5)
    # =========================================================================

    def insert_combo_modifier(self, combo_modifier_group_id: int, name: str,
                              display_order: int = 0) -> Optional[int]:
        """Insert a combo modifier and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifiers
                WHERE combo_modifier_group_id = %s AND name = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (combo_modifier_group_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_modifiers
                    SET display_order = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(
                    update_query, (display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_modifiers
                    (combo_modifier_group_id, name, display_order)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    combo_modifier_group_id, name, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert combo_modifier '{name}': {e}")
            return None

    # =========================================================================
    # COMBO MODIFIER PRICES (Table 6)
    # =========================================================================

    def insert_combo_modifier_price(self, combo_modifier_id: int,
                                    size_variant: str, price: float) -> Optional[int]:
        """Insert a combo modifier price and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.combo_modifier_prices
                WHERE combo_modifier_id = %s AND size_variant = %s
                LIMIT 1
            """
            self.cursor.execute(check_query, (combo_modifier_id, size_variant))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.combo_modifier_prices
                    SET price = %s
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (price, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.combo_modifier_prices
                    (combo_modifier_id, size_variant, price)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    combo_modifier_id, size_variant, price
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert combo_modifier_price (modifier={combo_modifier_id}, size={size_variant}): {e}")
            return None

    # =========================================================================
    # MODIFIER GROUPS (Table 10) - For normal dishes
    # =========================================================================

    def insert_modifier_group(self, dish_id: int, name: str,
                              is_required: bool = False,
                              min_selections: int = 0,
                              max_selections: int = 1,
                              free_items: int = 0,
                              display_order: int = 0) -> Optional[int]:
        """Insert a modifier group for a dish and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.modifier_groups
                WHERE dish_id = %s AND name = %s AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.modifier_groups
                    SET is_required = %s,
                        min_selections = %s,
                        max_selections = %s,
                        free_items = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    is_required, min_selections, max_selections,
                    free_items, display_order, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.modifier_groups
                    (dish_id, name, is_required, min_selections, max_selections,
                     free_items, display_order, is_custom)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, TRUE)
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    dish_id, name, is_required, min_selections, max_selections,
                    free_items, display_order
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(
                f"Failed to insert modifier_group '{name}' for dish {dish_id}: {e}")
            return None

    # =========================================================================
    # DISH MODIFIERS (Table 11) - For normal dishes
    # =========================================================================

    def insert_dish_modifier(self, restaurant_id: int, dish_id: int,
                             modifier_group_id: int, name: str,
                             modifier_type: str = None,
                             display_order: int = 0,
                             is_default: bool = False,
                             is_included: bool = False,
                             source_id: int = None) -> Optional[int]:
        """Insert a dish modifier and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifiers
                WHERE modifier_group_id = %s AND name = %s AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (modifier_group_id, name))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dish_modifiers
                    SET modifier_type = %s,
                        display_order = %s,
                        is_default = %s,
                        is_included = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(update_query, (
                    modifier_type, display_order, is_default, is_included, existing['id']
                ))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_modifiers
                    (restaurant_id, dish_id, modifier_group_id, name, modifier_type,
                     display_order, is_default, is_included, source_id, source_system)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'v1')
                    RETURNING id
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, dish_id, modifier_group_id, name, modifier_type,
                    display_order, is_default, is_included, source_id
                ))
                result = self.cursor.fetchone()

            self.conn.commit()
            return result['id'] if result else None
        except Exception as e:
            self.conn.rollback()
            logger.error(f"Failed to insert dish_modifier '{name}': {e}")
            return None

    # =========================================================================
    # DISH MODIFIER PRICES (Table 12)
    # =========================================================================

    def insert_dish_modifier_price(self, dish_modifier_id: int, dish_id: int,
                                   restaurant_id: int, price: float,
                                   size_variant: str = 'Standard',
                                   display_order: int = 1) -> Optional[int]:
        """Insert a dish modifier price and return its ID."""
        self.ensure_connection()
        try:
            # Check if exists
            check_query = f"""
                SELECT id FROM {self.schema}.dish_modifier_prices
                WHERE dish_modifier_id = %s AND size_variant = %s AND deleted_at IS NULL
                LIMIT 1
            """
            self.cursor.execute(check_query, (dish_modifier_id, size_variant))
            existing = self.cursor.fetchone()

            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.dish_modifier_prices
                    SET price = %s,
                        display_order = %s,
                        updated_at = NOW()
                    WHERE id = %s
                    RETURNING id
                """
                self.cursor.execute(
                    update_query, (price, display_order, existing['id']))
                result = self.cursor.fetchone()
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.dish_modifier_prices
                    (dish_modifier_id, dish_id, restaurant_id, size_variant, price,
                     display_order, is_active, source_system)
                    VALUES (%s, %s, %s, %s, %s, %s, TRUE, 'v1')
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
            logger.error(
                f"Failed to insert dish_modifier_price for modifier {dish_modifier_id}: {e}")
            return None

    # =========================================================================
    # Statistics
    # =========================================================================

    def get_restaurant_stats(self, restaurant_id: int) -> Dict[str, int]:
        """Get menu and combo statistics for a restaurant."""
        self.ensure_connection()
        stats = {}

        try:
            # Count courses
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.courses
                WHERE restaurant_id = %s AND deleted_at IS NULL
            """, (restaurant_id,))
            stats['courses'] = self.cursor.fetchone()['count']

            # Count dishes
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.dishes
                WHERE restaurant_id = %s AND deleted_at IS NULL
            """, (restaurant_id,))
            stats['dishes'] = self.cursor.fetchone()['count']

            # Count combo dishes
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.dishes
                WHERE restaurant_id = %s AND is_combo = TRUE AND deleted_at IS NULL
            """, (restaurant_id,))
            stats['combo_dishes'] = self.cursor.fetchone()['count']

            # Count dish prices
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.dish_prices dp
                JOIN {self.schema}.dishes d ON dp.dish_id = d.id
                WHERE d.restaurant_id = %s AND d.deleted_at IS NULL AND dp.deleted_at IS NULL
            """, (restaurant_id,))
            stats['dish_prices'] = self.cursor.fetchone()['count']

            # Count combo groups
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.combo_groups
                WHERE restaurant_id = %s AND deleted_at IS NULL
            """, (restaurant_id,))
            stats['combo_groups'] = self.cursor.fetchone()['count']

            # Count combo group sections
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.combo_group_sections cgs
                JOIN {self.schema}.combo_groups cg ON cgs.combo_group_id = cg.id
                WHERE cg.restaurant_id = %s AND cg.deleted_at IS NULL
            """, (restaurant_id,))
            stats['combo_sections'] = self.cursor.fetchone()['count']

            # Count modifier groups
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.modifier_groups mg
                JOIN {self.schema}.dishes d ON mg.dish_id = d.id
                WHERE d.restaurant_id = %s AND mg.deleted_at IS NULL
            """, (restaurant_id,))
            stats['modifier_groups'] = self.cursor.fetchone()['count']

            # Count dish modifiers
            self.cursor.execute(f"""
                SELECT COUNT(*) as count FROM {self.schema}.dish_modifiers dm
                WHERE dm.restaurant_id = %s AND dm.deleted_at IS NULL
            """, (restaurant_id,))
            stats['dish_modifiers'] = self.cursor.fetchone()['count']

        except Exception as e:
            logger.error(
                f"Failed to get stats for restaurant {restaurant_id}: {e}")

        return stats
