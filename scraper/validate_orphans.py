"""
Validate Orphan Records in menuca_v3 Schema
Checks for:
1. Dishes without valid course_id
2. Courses without valid restaurant_id
3. Dishes where course_id doesn't exist
4. Courses where restaurant_id doesn't exist
"""

import psycopg2
from psycopg2.extras import RealDictCursor
import logging
from database import DatabaseManager
from config import DB_CONNECTION_STRING, SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class OrphanValidator:
    def __init__(self):
        self.db = DatabaseManager()
        self.issues_found = []

    def validate_orphan_courses(self):
        """Check for courses without valid restaurant_id."""
        logger.info("\n" + "=" * 80)
        logger.info("Validating Courses (checking for orphan courses)")
        logger.info("=" * 80)

        try:
            # Check 1: Courses with NULL restaurant_id
            query_null = f"""
                SELECT id, name, restaurant_id
                FROM {SCHEMA}.courses
                WHERE restaurant_id IS NULL
                AND deleted_at IS NULL
            """
            self.db.cursor.execute(query_null)
            null_courses = self.db.cursor.fetchall()

            if null_courses:
                logger.error(f"❌ Found {len(null_courses)} courses with NULL restaurant_id:")
                for course in null_courses:
                    logger.error(f"   Course ID: {course['id']}, Name: {course['name']}")
                    self.issues_found.append(f"Course ID {course['id']} has NULL restaurant_id")
            else:
                logger.info("✅ No courses with NULL restaurant_id")

            # Check 2: Courses with restaurant_id that doesn't exist
            query_invalid = f"""
                SELECT c.id, c.name, c.restaurant_id
                FROM {SCHEMA}.courses c
                LEFT JOIN {SCHEMA}.restaurants r ON c.restaurant_id = r.id
                WHERE r.id IS NULL
                AND c.deleted_at IS NULL
            """
            self.db.cursor.execute(query_invalid)
            invalid_courses = self.db.cursor.fetchall()

            if invalid_courses:
                logger.error(f"❌ Found {len(invalid_courses)} courses with non-existent restaurant_id:")
                for course in invalid_courses[:10]:  # Show first 10
                    logger.error(f"   Course ID: {course['id']}, Name: {course['name']}, Restaurant ID: {course['restaurant_id']}")
                if len(invalid_courses) > 10:
                    logger.error(f"   ... and {len(invalid_courses) - 10} more")
                self.issues_found.append(f"{len(invalid_courses)} courses reference non-existent restaurants")
            else:
                logger.info("✅ All courses have valid restaurant_id references")

            # Summary stats
            query_total = f"""
                SELECT COUNT(*) as total
                FROM {SCHEMA}.courses
                WHERE deleted_at IS NULL
            """
            self.db.cursor.execute(query_total)
            total = self.db.cursor.fetchone()['total']

            logger.info(f"\nCourse Statistics:")
            logger.info(f"  Total courses: {total}")
            logger.info(f"  Orphan courses: {len(null_courses) + len(invalid_courses)}")

            return len(null_courses) == 0 and len(invalid_courses) == 0

        except Exception as e:
            logger.error(f"Error validating courses: {e}")
            return False

    def validate_orphan_dishes(self):
        """Check for dishes without valid course_id or restaurant_id."""
        logger.info("\n" + "=" * 80)
        logger.info("Validating Dishes (checking for orphan dishes)")
        logger.info("=" * 80)

        try:
            # Check 1: Dishes with NULL course_id
            query_null_course = f"""
                SELECT id, name, course_id, restaurant_id
                FROM {SCHEMA}.dishes
                WHERE course_id IS NULL
                AND deleted_at IS NULL
            """
            self.db.cursor.execute(query_null_course)
            null_course_dishes = self.db.cursor.fetchall()

            if null_course_dishes:
                logger.error(f"❌ Found {len(null_course_dishes)} dishes with NULL course_id:")
                for dish in null_course_dishes[:10]:  # Show first 10
                    logger.error(f"   Dish ID: {dish['id']}, Name: {dish['name']}, Restaurant ID: {dish['restaurant_id']}")
                if len(null_course_dishes) > 10:
                    logger.error(f"   ... and {len(null_course_dishes) - 10} more")
                self.issues_found.append(f"{len(null_course_dishes)} dishes have NULL course_id")
            else:
                logger.info("✅ No dishes with NULL course_id")

            # Check 2: Dishes with NULL restaurant_id
            query_null_restaurant = f"""
                SELECT id, name, course_id, restaurant_id
                FROM {SCHEMA}.dishes
                WHERE restaurant_id IS NULL
                AND deleted_at IS NULL
            """
            self.db.cursor.execute(query_null_restaurant)
            null_restaurant_dishes = self.db.cursor.fetchall()

            if null_restaurant_dishes:
                logger.error(f"❌ Found {len(null_restaurant_dishes)} dishes with NULL restaurant_id:")
                for dish in null_restaurant_dishes[:10]:  # Show first 10
                    logger.error(f"   Dish ID: {dish['id']}, Name: {dish['name']}, Course ID: {dish['course_id']}")
                if len(null_restaurant_dishes) > 10:
                    logger.error(f"   ... and {len(null_restaurant_dishes) - 10} more")
                self.issues_found.append(f"{len(null_restaurant_dishes)} dishes have NULL restaurant_id")
            else:
                logger.info("✅ No dishes with NULL restaurant_id")

            # Check 3: Dishes with course_id that doesn't exist
            query_invalid_course = f"""
                SELECT d.id, d.name, d.course_id, d.restaurant_id
                FROM {SCHEMA}.dishes d
                LEFT JOIN {SCHEMA}.courses c ON d.course_id = c.id
                WHERE c.id IS NULL
                AND d.deleted_at IS NULL
            """
            self.db.cursor.execute(query_invalid_course)
            invalid_course_dishes = self.db.cursor.fetchall()

            if invalid_course_dishes:
                logger.error(f"❌ Found {len(invalid_course_dishes)} dishes with non-existent course_id:")
                for dish in invalid_course_dishes[:10]:  # Show first 10
                    logger.error(f"   Dish ID: {dish['id']}, Name: {dish['name']}, Course ID: {dish['course_id']}")
                if len(invalid_course_dishes) > 10:
                    logger.error(f"   ... and {len(invalid_course_dishes) - 10} more")
                self.issues_found.append(f"{len(invalid_course_dishes)} dishes reference non-existent courses")
            else:
                logger.info("✅ All dishes have valid course_id references")

            # Check 4: Dishes with restaurant_id that doesn't exist
            query_invalid_restaurant = f"""
                SELECT d.id, d.name, d.course_id, d.restaurant_id
                FROM {SCHEMA}.dishes d
                LEFT JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
                WHERE r.id IS NULL
                AND d.deleted_at IS NULL
            """
            self.db.cursor.execute(query_invalid_restaurant)
            invalid_restaurant_dishes = self.db.cursor.fetchall()

            if invalid_restaurant_dishes:
                logger.error(f"❌ Found {len(invalid_restaurant_dishes)} dishes with non-existent restaurant_id:")
                for dish in invalid_restaurant_dishes[:10]:  # Show first 10
                    logger.error(f"   Dish ID: {dish['id']}, Name: {dish['name']}, Restaurant ID: {dish['restaurant_id']}")
                if len(invalid_restaurant_dishes) > 10:
                    logger.error(f"   ... and {len(invalid_restaurant_dishes) - 10} more")
                self.issues_found.append(f"{len(invalid_restaurant_dishes)} dishes reference non-existent restaurants")
            else:
                logger.info("✅ All dishes have valid restaurant_id references")

            # Summary stats
            query_total = f"""
                SELECT COUNT(*) as total
                FROM {SCHEMA}.dishes
                WHERE deleted_at IS NULL
            """
            self.db.cursor.execute(query_total)
            total = self.db.cursor.fetchone()['total']

            total_orphans = (len(null_course_dishes) + len(null_restaurant_dishes) +
                           len(invalid_course_dishes) + len(invalid_restaurant_dishes))

            logger.info(f"\nDish Statistics:")
            logger.info(f"  Total dishes: {total}")
            logger.info(f"  Orphan dishes: {total_orphans}")

            return total_orphans == 0

        except Exception as e:
            logger.error(f"Error validating dishes: {e}")
            return False

    def validate_all(self):
        """Run all orphan validations."""
        logger.info("=" * 80)
        logger.info("ORPHAN RECORD VALIDATION")
        logger.info("=" * 80)

        # Connect to database
        try:
            self.db.connect()
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            return False

        # Run validations
        courses_valid = self.validate_orphan_courses()
        dishes_valid = self.validate_orphan_dishes()

        # Final summary
        logger.info("\n" + "=" * 80)
        logger.info("VALIDATION SUMMARY")
        logger.info("=" * 80)

        if courses_valid and dishes_valid:
            logger.info("✅ ALL VALIDATIONS PASSED")
            logger.info("No orphan records found")
            logger.info("All courses have valid restaurant references")
            logger.info("All dishes have valid course and restaurant references")
        else:
            logger.error("❌ VALIDATION FAILED")
            logger.error(f"Found {len(self.issues_found)} issues:")
            for issue in self.issues_found:
                logger.error(f"  - {issue}")

        # Disconnect
        self.db.close()

        return courses_valid and dishes_valid

if __name__ == "__main__":
    validator = OrphanValidator()
    success = validator.validate_all()

    if not success:
        exit(1)

    exit(0)
