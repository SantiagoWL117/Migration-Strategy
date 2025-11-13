# Database Reconnection System - VERIFIED ✅

## Confirmation: YES - Full Reconnection System Implemented

**Verified Date**: November 13, 2025  
**Status**: ✅ **ACTIVE IN BOTH SCRAPERS**

---

## 🛡️ Reconnection System Components

### 1. Database Manager (`database.py`)

#### `is_connected()` Method
```python
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
```

**What it does:**
- Tests connection with `SELECT 1` query
- Returns `True` if connection is alive
- Returns `False` if connection is closed/broken
- Catches PostgreSQL operational errors

#### `ensure_connection()` Method
```python
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
```

**What it does:**
1. Checks if connection is alive using `is_connected()`
2. If disconnected:
   - Logs warning message
   - Safely closes existing cursor and connection
   - Calls `connect()` to establish new connection
   - Logs success message
3. If reconnection fails, logs error and raises exception

---

## 🔄 Where Reconnection Happens

### In Both Phase 2 Scrapers:

#### 1. **Before Initial Query** (Line 83 in both scrapers)
```python
def get_dishes_to_process(db, restaurant_ids):
    """Get all dishes from restaurants that need prices/modifiers."""
    db.ensure_connection()  # ✅ CHECK BEFORE QUERY
    
    ids_str = ','.join(map(str, restaurant_ids))
    query = f"SELECT ... FROM {SCHEMA}.dishes ..."
    db.cursor.execute(query)
```

#### 2. **Before Each Dish** (Line 133 in both scrapers)
```python
def scrape_dish_prices_modifiers(db, scraper, dish):
    try:
        # Ensure database connection
        db.ensure_connection()  # ✅ CHECK BEFORE EACH DISH
        
        logger.info(f"Scraping dish: {dish['dish_name']}...")
        details = scraper.scrape_dish_details(...)
```

#### 3. **Periodically During Processing** (Lines 323-329 in both scrapers)
```python
for i, dish in enumerate(remaining, 1):
    # Ensure database connection periodically
    if i % 50 == 1:  # ✅ CHECK EVERY 50 DISHES
        try:
            db.ensure_connection()
        except Exception as e:
            logger.error(f"Failed to ensure database connection: {e}")
            time.sleep(5)
            db.ensure_connection()  # ✅ RETRY AFTER 5 SECONDS
```

#### 4. **Before Every Database Insert** (In `database.py`)
Every insert method calls `ensure_connection()`:
- `insert_course()` - Line 101
- `insert_dish()` - Line 150
- `insert_dish_price()` - Line 201
- `insert_modifier_group()` - Line 247
- `insert_dish_modifier()` - Line 298
- `insert_dish_modifier_price()` - Line 350

---

## 🎯 Protection Levels

### Level 1: Initial Query Protection
✅ Connection checked **before** querying for dishes to process

### Level 2: Per-Dish Protection
✅ Connection checked **before processing each dish**

### Level 3: Periodic Protection
✅ Connection checked **every 50 dishes** during long runs

### Level 4: Insert Protection
✅ Connection checked **before every database insert operation**

### Level 5: Retry Logic
✅ If reconnection fails, waits **5 seconds** and retries

---

## 🔍 What Triggers Reconnection

The system automatically reconnects when:

1. **Idle Timeout**: Supabase/PostgreSQL closes idle connections
2. **Network Issues**: Temporary network interruptions
3. **Server Restart**: Database server restarts or maintenance
4. **Connection Pool Limits**: Connection pool exhaustion
5. **Long-Running Operations**: Connection times out during long scraping sessions

---

## 📊 Reconnection in Action

### Example Log Output:
```
2025-11-13 10:30:15 - WARNING - Database connection lost, reconnecting...
2025-11-13 10:30:16 - INFO - Database connection established
2025-11-13 10:30:16 - INFO - Database reconnection successful
2025-11-13 10:30:16 - INFO - Scraping dish: Extra Cheese Pizza (Dish ID: 12345...)
```

### What You'll See:
1. Warning that connection was lost
2. New connection established
3. Success confirmation
4. Processing continues seamlessly

---

## ✅ Current Status

Both Phase 2 scrapers are running with **full reconnection protection**:

- ✅ **English Scraper**: `batch_scrape_list4_prices_english.py`
  - Reconnection system: **ACTIVE**
  - Checks every 50 dishes
  - Checks before each insert
  
- ✅ **French Scraper**: `batch_scrape_list4_prices_french.py`
  - Reconnection system: **ACTIVE**
  - Checks every 50 dishes
  - Checks before each insert

---

## 🛟 Failure Recovery

If reconnection fails:
1. Error is logged to log file
2. Script waits 5 seconds
3. Retries reconnection
4. If still fails, raises exception
5. Progress is already saved (can resume later)

---

## 📝 Monitoring Reconnections

To see if reconnections are happening, check the log files:

```bash
# English scraper
grep -i "reconnect" batch_scrape_list4_prices_english.log

# French scraper
grep -i "reconnect" batch_scrape_list4_prices_french.log
```

Look for:
- `Database connection lost, reconnecting...`
- `Database reconnection successful`

---

## Summary

✅ **CONFIRMED**: Both Phase 2 scrapers have a robust reconnection system that:
- Automatically detects disconnections
- Reconnects seamlessly
- Retries on failure
- Logs all reconnection events
- Protects every database operation
- Checks connection periodically (every 50 dishes)

**The scrapers will continue running even if the database connection temporarily drops!**

---

**Verification Complete**: ✅ **RECONNECTION SYSTEM FULLY OPERATIONAL**

