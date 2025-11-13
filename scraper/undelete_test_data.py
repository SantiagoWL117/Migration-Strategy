from database import DatabaseManager
from config import SCHEMA

db = DatabaseManager()
db.connect()

# Undelete Mozza Pizza test data
db.cursor.execute(f'UPDATE {SCHEMA}.courses SET deleted_at = NULL WHERE restaurant_id = 35 AND deleted_at IS NOT NULL')
courses_updated = db.cursor.rowcount

db.cursor.execute(f'UPDATE {SCHEMA}.dishes SET deleted_at = NULL WHERE restaurant_id = 35 AND deleted_at IS NOT NULL')
dishes_updated = db.cursor.rowcount

db.conn.commit()

print(f'Undeleted test data for Mozza Pizza (ID: 35):')
print(f'  Courses undeleted: {courses_updated}')
print(f'  Dishes undeleted: {dishes_updated}')

db.close()

