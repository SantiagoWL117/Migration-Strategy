"""Database operations for Distance-Based Delivery Fees scraper."""
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

# Database configuration
DB_CONNECTION_STRING = os.getenv('DB_CONNECTION_STRING', 
    'postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres')
SCHEMA = 'menuca_v3'

# MVP Restaurants to EXCLUDE from scraping
MVP_EXCLUDED_RESTAURANT_IDS = [
    105,   # Ginkgo Garden
    245,   # Orchid Sushi
    8,     # Lucky Star Chinese Food
    87,    # Champa Thai Cuisine (already has distance-based fees)
    119,   # Hung Mein
    1009,  # Econo Pizza
]


class DistanceBasedFeesDB:
    """Database operations for distance-based delivery fees scraper."""

    def __init__(self):
        self.conn_string = DB_CONNECTION_STRING
        self.schema = SCHEMA
        self.conn = None
        self.cursor = None
        self._max_retries = 3
        self._retry_delay = 2

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
        """Get all V1 restaurants for scraping, excluding MVP restaurants."""
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
            logger.info(f"Found {len(restaurants)} V1 restaurants (excluding {len(MVP_EXCLUDED_RESTAURANT_IDS)} MVP)")
            return restaurants
        return self._execute_with_retry(_fetch)

    def get_or_create_company_email(self, email: str) -> int:
        """
        Get existing company email ID or create a new one.
        
        Args:
            email: Delivery company email address
        
        Returns:
            ID of the company email record
        """
        def _get_or_create():
            email_lower = email.lower().strip()
            
            # Check if email exists
            query = f"""
                SELECT id FROM {self.schema}.delivery_company_emails
                WHERE LOWER(email) = %s
            """
            self.cursor.execute(query, (email_lower,))
            result = self.cursor.fetchone()
            
            if result:
                return result['id']
            
            # Create new email record
            # Extract company name from email local part
            local_part = email_lower.split('@')[0]
            company_name = local_part.replace('.', ' ').replace('_', ' ').title()
            
            insert_query = f"""
                INSERT INTO {self.schema}.delivery_company_emails
                (email, company_name, is_active, created_at)
                VALUES (%s, %s, true, NOW())
                RETURNING id
            """
            self.cursor.execute(insert_query, (email_lower, company_name))
            self.conn.commit()
            new_id = self.cursor.fetchone()['id']
            logger.info(f"Created new delivery company email: {email_lower} (ID: {new_id})")
            return new_id
        
        try:
            return self._execute_with_retry(_get_or_create)
        except Exception as e:
            logger.error(f"Error getting/creating company email {email}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            raise

    def upsert_delivery_company(self, restaurant_id: int, company_email_id: int,
                                 commission: Optional[float] = None,
                                 restaurant_pays_difference: Optional[float] = None) -> bool:
        """
        Insert or update restaurant_delivery_companies record.
        
        Args:
            restaurant_id: V3 restaurant ID
            company_email_id: ID from delivery_company_emails
            commission: Commission percentage
            restaurant_pays_difference: Amount restaurant pays to driver
        
        Returns:
            True if successful
        """
        def _upsert():
            # Check if record exists
            check_query = f"""
                SELECT id FROM {self.schema}.restaurant_delivery_companies
                WHERE restaurant_id = %s AND company_email_id = %s
            """
            self.cursor.execute(check_query, (restaurant_id, company_email_id))
            existing = self.cursor.fetchone()
            
            if existing:
                # Update existing
                update_query = f"""
                    UPDATE {self.schema}.restaurant_delivery_companies
                    SET commission = COALESCE(%s, commission),
                        restaurant_pays_difference = COALESCE(%s, restaurant_pays_difference),
                        sends_to_delivery = true,
                        is_active = true,
                        updated_at = NOW()
                    WHERE id = %s
                """
                self.cursor.execute(update_query, (commission, restaurant_pays_difference, existing['id']))
            else:
                # Insert new
                insert_query = f"""
                    INSERT INTO {self.schema}.restaurant_delivery_companies
                    (restaurant_id, company_email_id, commission, restaurant_pays_difference,
                     sends_to_delivery, is_active, created_at)
                    VALUES (%s, %s, %s, %s, true, true, NOW())
                """
                self.cursor.execute(insert_query, (
                    restaurant_id, company_email_id, commission, restaurant_pays_difference
                ))
            
            self.conn.commit()
            return True
        
        try:
            return self._execute_with_retry(_upsert)
        except Exception as e:
            logger.error(f"Error upserting delivery company for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

    def set_distance_based_flag(self, restaurant_id: int, value: bool) -> bool:
        """
        Set distance_based_delivery_fee flag on restaurant_delivery_areas.
        
        Args:
            restaurant_id: V3 restaurant ID
            value: True if restaurant uses distance-based fees
        
        Returns:
            True if any rows updated
        """
        def _update():
            query = f"""
                UPDATE {self.schema}.restaurant_delivery_areas
                SET distance_based_delivery_fee = %s,
                    updated_at = NOW()
                WHERE restaurant_id = %s
                AND deleted_at IS NULL
            """
            self.cursor.execute(query, (value, restaurant_id))
            self.conn.commit()
            return self.cursor.rowcount > 0
        
        try:
            return self._execute_with_retry(_update)
        except Exception as e:
            logger.error(f"Error setting distance_based flag for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

    def delete_existing_fees(self, restaurant_id: int) -> int:
        """
        Delete existing distance-based fees for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
        
        Returns:
            Number of rows deleted
        """
        def _delete():
            query = f"""
                DELETE FROM {self.schema}.restaurant_distance_based_delivery_fees
                WHERE restaurant_id = %s
            """
            self.cursor.execute(query, (restaurant_id,))
            deleted = self.cursor.rowcount
            self.conn.commit()
            return deleted
        
        try:
            return self._execute_with_retry(_delete)
        except Exception as e:
            logger.error(f"Error deleting fees for restaurant {restaurant_id}: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return 0

    def insert_fee_tier(self, restaurant_id: int, company_email_id: Optional[int],
                        distance_km: int, driver_earning: Optional[float],
                        restaurant_pays: Optional[float], vendor_pays: Optional[float],
                        total_delivery_fee: Optional[float]) -> bool:
        """
        Insert a single distance-based fee tier.
        
        Args:
            restaurant_id: V3 restaurant ID
            company_email_id: ID from delivery_company_emails (can be None)
            distance_km: Distance in km (5-10)
            driver_earning: Amount driver earns
            restaurant_pays: Amount restaurant pays
            vendor_pays: Amount vendor (Menu.ca) pays
            total_delivery_fee: Total delivery fee charged to customer
        
        Returns:
            True if successful
        """
        def _insert():
            query = f"""
                INSERT INTO {self.schema}.restaurant_distance_based_delivery_fees
                (restaurant_id, company_email_id, distance_in_km,
                 driver_earning, restaurant_pays, vendor_pays, total_delivery_fee,
                 is_active, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, true, NOW())
            """
            self.cursor.execute(query, (
                restaurant_id, company_email_id, distance_km,
                driver_earning, restaurant_pays, vendor_pays, total_delivery_fee
            ))
            self.conn.commit()
            return True
        
        try:
            return self._execute_with_retry(_insert)
        except Exception as e:
            logger.error(f"Error inserting fee tier for restaurant {restaurant_id} at {distance_km}km: {e}")
            try:
                self.conn.rollback()
            except Exception:
                pass
            return False

