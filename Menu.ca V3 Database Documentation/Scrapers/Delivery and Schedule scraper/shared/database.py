"""Database operations for Delivery and Schedule scrapers."""
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List, Any
import logging
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from project root .env file
env_path = Path(__file__).parent.parent.parent.parent / '.env'
load_dotenv(env_path)

logger = logging.getLogger(__name__)

# Database configuration - HARDCODED for reliability
DB_CONNECTION_STRING = os.getenv('DB_CONNECTION_STRING', 
    'postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
SCHEMA = 'menuca_v3'

# MVP Restaurants to EXCLUDE from scraping (these are manually curated)
# Do NOT modify these restaurants' data
MVP_EXCLUDED_RESTAURANT_IDS = [
    105,   # Ginkgo Garden
    245,   # Orchid Sushi
    8,     # Lucky Star Chinese Food
    87,    # Champa Thai Cuisine
    119,   # Hung Mein
    1009,  # Econo Pizza
]


class DatabaseManager:
    """Manages database connections and operations for scrapers."""

    def __init__(self):
        self.conn_string = DB_CONNECTION_STRING
        self.schema = SCHEMA
        self.conn = None
        self.cursor = None
        self._max_retries = 3
        self._retry_delay = 2  # seconds

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
        try:
            if self.cursor:
                self.cursor.close()
            if self.conn:
                self.conn.close()
                logger.info("Database connection closed")
        except Exception as e:
            logger.warning(f"Error closing connection: {e}")

    def is_connected(self) -> bool:
        """Check if the database connection is still alive."""
        if not self.conn or not self.cursor:
            return False
        try:
            self.cursor.execute("SELECT 1")
            return True
        except Exception:
            return False

    def ensure_connection(self):
        """Ensure database connection is active, reconnect if needed."""
        if not self.is_connected():
            logger.warning("Database connection lost, attempting to reconnect...")
            try:
                self.close()
            except Exception:
                pass
            
            import time
            for attempt in range(1, self._max_retries + 1):
                try:
                    self.connect()
                    logger.info(f"Reconnected to database (attempt {attempt})")
                    return True
                except Exception as e:
                    logger.error(f"Reconnection attempt {attempt} failed: {e}")
                    if attempt < self._max_retries:
                        time.sleep(self._retry_delay)
            
            raise Exception("Failed to reconnect to database after multiple attempts")
        return True

    def _execute_with_retry(self, operation, *args, **kwargs):
        """Execute a database operation with automatic reconnection on failure."""
        import time
        last_error = None
        
        for attempt in range(1, self._max_retries + 1):
            try:
                self.ensure_connection()
                return operation(*args, **kwargs)
            except (psycopg2.OperationalError, psycopg2.InterfaceError) as e:
                last_error = e
                logger.warning(f"Database operation failed (attempt {attempt}): {e}")
                if attempt < self._max_retries:
                    try:
                        self.close()
                    except Exception:
                        pass
                    time.sleep(self._retry_delay)
                    try:
                        self.connect()
                    except Exception as conn_err:
                        logger.error(f"Reconnection failed: {conn_err}")
            except Exception as e:
                # Non-connection related error, don't retry
                raise e
        
        raise last_error

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            try:
                self.conn.rollback()
            except Exception:
                pass
        self.close()

    def get_v1_restaurants(self) -> List[Dict[str, Any]]:
        """Get all restaurants with legacy_v1_id for V1 scraper, excluding MVP restaurants."""
        def _fetch():
            excluded_ids = ','.join(str(id) for id in MVP_EXCLUDED_RESTAURANT_IDS)
            query = f"""
                SELECT id, name, legacy_v1_id
                FROM {self.schema}.restaurants
                WHERE legacy_v1_id IS NOT NULL
                AND deleted_at IS NULL
                AND id NOT IN ({excluded_ids})
                ORDER BY name
            """
            self.cursor.execute(query)
            restaurants = [dict(row) for row in self.cursor.fetchall()]
            logger.info(f"Excluding {len(MVP_EXCLUDED_RESTAURANT_IDS)} MVP restaurants from V1 scraping")
            return restaurants
        return self._execute_with_retry(_fetch)

    def get_v2_restaurants(self) -> List[Dict[str, Any]]:
        """Get all restaurants with legacy_v2_id (and no v1_id) for V2 scraper, excluding MVP restaurants."""
        def _fetch():
            excluded_ids = ','.join(str(id) for id in MVP_EXCLUDED_RESTAURANT_IDS)
            query = f"""
                SELECT id, name, legacy_v2_id
                FROM {self.schema}.restaurants
                WHERE legacy_v2_id IS NOT NULL
                AND legacy_v1_id IS NULL
                AND deleted_at IS NULL
                AND id NOT IN ({excluded_ids})
                ORDER BY name
            """
            self.cursor.execute(query)
            restaurants = [dict(row) for row in self.cursor.fetchall()]
            logger.info(f"Excluding {len(MVP_EXCLUDED_RESTAURANT_IDS)} MVP restaurants from V2 scraping")
            return restaurants
        return self._execute_with_retry(_fetch)

    def get_service_config(self, restaurant_id: int) -> Optional[Dict[str, Any]]:
        """Get current service config for a restaurant."""
        query = f"""
            SELECT id, takeout_time_minutes, has_delivery_enabled, 
                   takeout_enabled, closing_warning_minutes
            FROM {self.schema}.restaurant_service_configs
            WHERE restaurant_id = %s AND deleted_at IS NULL
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def get_delivery_area(self, restaurant_id: int) -> Optional[Dict[str, Any]]:
        """Get first delivery area for a restaurant."""
        query = f"""
            SELECT id, estimated_delivery_minutes
            FROM {self.schema}.restaurant_delivery_areas
            WHERE restaurant_id = %s AND deleted_at IS NULL
            ORDER BY area_number
            LIMIT 1
        """
        self.cursor.execute(query, (restaurant_id,))
        result = self.cursor.fetchone()
        return dict(result) if result else None

    def update_service_config(self, restaurant_id: int, 
                              takeout_time_minutes: Optional[int] = None,
                              has_delivery_enabled: Optional[bool] = None,
                              pickup_enabled: Optional[bool] = None,
                              closing_warning_minutes: Optional[int] = None,
                              overwrite: bool = True) -> bool:
        """
        Update service config with scraped values.
        
        Args:
            restaurant_id: V3 restaurant ID
            takeout_time_minutes: Takeout preparation time
            has_delivery_enabled: Whether delivery is enabled
            pickup_enabled: Whether pickup/takeout is enabled
            closing_warning_minutes: Warning before close time
            overwrite: If True, overwrite existing values. If False, only update NULL values.
        
        Returns True if any update was made.
        """
        def _update():
            updates = []
            params = []
            
            if takeout_time_minutes is not None:
                if overwrite:
                    updates.append("takeout_time_minutes = %s")
                else:
                    updates.append("takeout_time_minutes = COALESCE(takeout_time_minutes, %s)")
                params.append(takeout_time_minutes)
            
            if has_delivery_enabled is not None:
                if overwrite:
                    updates.append("has_delivery_enabled = %s")
                else:
                    updates.append("has_delivery_enabled = COALESCE(has_delivery_enabled, %s)")
                params.append(has_delivery_enabled)
            
            if pickup_enabled is not None:
                if overwrite:
                    updates.append("pickup_enabled = %s")
                else:
                    updates.append("pickup_enabled = COALESCE(pickup_enabled, %s)")
                params.append(pickup_enabled)
            
            if closing_warning_minutes is not None:
                if overwrite:
                    updates.append("closing_warning_minutes = %s")
                else:
                    updates.append("closing_warning_minutes = COALESCE(closing_warning_minutes, %s)")
                params.append(closing_warning_minutes)
            
            if not updates:
                return False
            
            updates.append("updated_at = NOW()")
            params.append(restaurant_id)
            
            query = f"""
                UPDATE {self.schema}.restaurant_service_configs
                SET {', '.join(updates)}
                WHERE restaurant_id = %s AND deleted_at IS NULL
            """
            
            self.cursor.execute(query, params)
            self.conn.commit()
            return self.cursor.rowcount > 0
        
        try:
            return self._execute_with_retry(_update)
        except Exception as e:
            logger.error(f"Error updating service config for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

    def update_delivery_area_time(self, restaurant_id: int, 
                                   estimated_delivery_minutes: int,
                                   overwrite: bool = True) -> bool:
        """
        Update estimated_delivery_minutes in delivery areas.
        Updates all delivery areas for the restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            estimated_delivery_minutes: Estimated delivery time in minutes
            overwrite: If True, overwrite existing values. If False, only update NULL values.
        """
        def _update():
            if overwrite:
                query = f"""
                    UPDATE {self.schema}.restaurant_delivery_areas
                    SET estimated_delivery_minutes = %s,
                        updated_at = NOW()
                    WHERE restaurant_id = %s 
                    AND deleted_at IS NULL
                """
            else:
                query = f"""
                    UPDATE {self.schema}.restaurant_delivery_areas
                    SET estimated_delivery_minutes = COALESCE(estimated_delivery_minutes, %s),
                        updated_at = NOW()
                    WHERE restaurant_id = %s 
                    AND deleted_at IS NULL
                    AND estimated_delivery_minutes IS NULL
                """
            
            self.cursor.execute(query, (estimated_delivery_minutes, restaurant_id))
            self.conn.commit()
            return self.cursor.rowcount > 0
        
        try:
            return self._execute_with_retry(_update)
        except Exception as e:
            logger.error(f"Error updating delivery area for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

    def upsert_schedule(self, restaurant_id: int, schedule_type: str,
                        day_start: int, time_start: str, time_stop: str,
                        overwrite: bool = True, interval: int = 1) -> bool:
        """
        Insert or update a schedule entry.
        
        Args:
            restaurant_id: V3 restaurant ID
            schedule_type: 'delivery' or 'takeout'
            day_start: 1-7 (Monday-Sunday)
            time_start: Start time in HH:MM format
            time_stop: Stop time in HH:MM format
            overwrite: If True, overwrite existing values. If False, only update NULL values.
            interval: Schedule interval (1, 2, or 3) - used to match specific schedule slots
        """
        # First, get ALL existing schedules for this restaurant/type/day
        check_query = f"""
            SELECT id, time_start, time_stop FROM {self.schema}.restaurant_schedules
            WHERE restaurant_id = %s 
            AND type = %s 
            AND day_start = %s
            AND deleted_at IS NULL
            ORDER BY time_start NULLS LAST, id
        """
        self.cursor.execute(check_query, (restaurant_id, schedule_type, day_start))
        existing_schedules = self.cursor.fetchall()
        
        try:
            if existing_schedules:
                # Get the schedule at the specified interval index (0-based internally)
                idx = interval - 1
                if idx < len(existing_schedules):
                    existing = existing_schedules[idx]
                    if overwrite:
                        # Update existing - overwrite values
                        update_query = f"""
                            UPDATE {self.schema}.restaurant_schedules
                            SET time_start = %s::time,
                                time_stop = %s::time,
                                updated_at = NOW()
                            WHERE id = %s
                        """
                    else:
                        # Update existing - only if times are NULL
                        update_query = f"""
                            UPDATE {self.schema}.restaurant_schedules
                            SET time_start = COALESCE(time_start, %s::time),
                                time_stop = COALESCE(time_stop, %s::time),
                                updated_at = NOW()
                            WHERE id = %s
                            AND (time_start IS NULL OR time_stop IS NULL)
                        """
                    self.cursor.execute(update_query, (time_start, time_stop, existing['id']))
                    self.conn.commit()
                    return True
                else:
                    # This interval doesn't exist yet, but others do - skip insert to avoid overlap
                    # Log that we're skipping this interval
                    logger.debug(f"Skipping interval {interval} for restaurant {restaurant_id} day {day_start} - would overlap")
                    return False
            else:
                # No existing schedule - try to insert new one
                insert_query = f"""
                    INSERT INTO {self.schema}.restaurant_schedules
                    (restaurant_id, type, day_start, day_stop, time_start, time_stop, is_enabled, created_at)
                    VALUES (%s, %s, %s, %s, %s::time, %s::time, true, NOW())
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, schedule_type, day_start, day_start, time_start, time_stop
                ))
                self.conn.commit()
                return True
        except Exception as e:
            logger.error(f"Error upserting schedule for restaurant {restaurant_id}: {e}")
            self.conn.rollback()
            return False

    def get_existing_schedules(self, restaurant_id: int, schedule_type: str) -> List[Dict[str, Any]]:
        """Get existing schedules for a restaurant."""
        query = f"""
            SELECT id, day_start, time_start, time_stop
            FROM {self.schema}.restaurant_schedules
            WHERE restaurant_id = %s 
            AND type = %s
            AND deleted_at IS NULL
            ORDER BY day_start
        """
        self.cursor.execute(query, (restaurant_id, schedule_type))
        return [dict(row) for row in self.cursor.fetchall()]

    def delete_schedules(self, restaurant_id: int, schedule_type: str = None) -> int:
        """
        Delete all schedules for a restaurant (HARD DELETE to avoid unique constraint issues).
        
        Args:
            restaurant_id: V3 restaurant ID
            schedule_type: Optional - 'delivery' or 'takeout'. If None, deletes both.
        
        Returns:
            Number of schedules deleted
        """
        def _delete():
            if schedule_type:
                query = f"""
                    DELETE FROM {self.schema}.restaurant_schedules
                    WHERE restaurant_id = %s 
                    AND type = %s
                """
                self.cursor.execute(query, (restaurant_id, schedule_type))
            else:
                query = f"""
                    DELETE FROM {self.schema}.restaurant_schedules
                    WHERE restaurant_id = %s
                """
                self.cursor.execute(query, (restaurant_id,))
            
            deleted_count = self.cursor.rowcount
            self.conn.commit()
            return deleted_count
        
        try:
            return self._execute_with_retry(_delete)
        except Exception as e:
            logger.error(f"Error deleting schedules for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return 0

    def insert_schedule(self, restaurant_id: int, schedule_type: str,
                        day_start: int, time_start: str, time_stop: str) -> bool:
        """
        Insert a new schedule entry (used after delete_schedules).
        
        Args:
            restaurant_id: V3 restaurant ID
            schedule_type: 'delivery' or 'takeout'
            day_start: 1-7 (Monday-Sunday)
            time_start: Start time in HH:MM format
            time_stop: Stop time in HH:MM format
        """
        def _insert():
            insert_query = f"""
                INSERT INTO {self.schema}.restaurant_schedules
                (restaurant_id, type, day_start, day_stop, time_start, time_stop, is_enabled, created_at)
                VALUES (%s, %s, %s, %s, %s::time, %s::time, true, NOW())
            """
            self.cursor.execute(insert_query, (
                restaurant_id, schedule_type, day_start, day_start, time_start, time_stop
            ))
            self.conn.commit()
            return True
        
        try:
            return self._execute_with_retry(_insert)
        except Exception as e:
            logger.error(f"Error inserting schedule for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

