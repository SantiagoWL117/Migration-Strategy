# Orders & Checkout - Data Dumps Needed

**Date:** 2025-10-07  
**Status:** Waiting for Santiago  
**Priority:** HIGH

---

## 📦 Required Data Dumps from V2 (Priority)

### 1. V2 Order Tables (REQUIRED)

```sql
-- menuca_v2.order_details (~88k rows)
SELECT * FROM menuca_v2.order_details
ORDER BY id;

-- menuca_v2.order_main_items (~141k rows)
SELECT * FROM menuca_v2.order_main_items
ORDER BY id;

-- menuca_v2.order_sub_items (~87k rows)
SELECT * FROM menuca_v2.order_sub_items
ORDER BY id;

-- menuca_v2.order_sub_items_combo (~4k rows)
SELECT * FROM menuca_v2.order_sub_items_combo
ORDER BY id;

-- menuca_v2.order_pdf (~13k rows)
SELECT * FROM menuca_v2.order_pdf
ORDER BY id;

-- menuca_v2.cancel_order_requests
SELECT * FROM menuca_v2.cancel_order_requests
ORDER BY id;
```

**Export Format:** CSV or SQL dump  
**Estimated Size:** ~300MB  
**Location:** `/Database/Orders_&_Checkout/CSV/` or `/Database/Orders_&_Checkout/dumps/`

---

### 2. V2 Address Data (REQUIRED for address lookup)

```sql
-- menuca_v2.site_users_delivery_addresses
SELECT * FROM menuca_v2.site_users_delivery_addresses
ORDER BY id;
```

**Note:** This is needed to populate `menuca_v3.order_delivery_addresses` by looking up `address_id` from `order_details`.

---

## 📦 V1 Order Data (For Analysis)

### 3. V1 Sample Orders (SAMPLE ONLY)

```sql
-- menuca_v1.orders (SAMPLE: 100 rows for analysis)
SELECT * FROM menuca_v1.orders
WHERE time > UNIX_TIMESTAMP('2024-01-01')
ORDER BY id DESC
LIMIT 100;
```

**Purpose:** Analyze the serialized PHP `order` field structure before attempting full migration.

**Export Format:** SQL dump preferred (preserves serialization)  
**Location:** `/Database/Orders_&_Checkout/dumps/menuca_v1_orders_sample.sql`

---

## 🔍 Analysis Questions for Santiago

### Question 1: V1 Order Data Volume
**Q:** The V1 `orders` table has ~3.7M rows. Do we want to migrate:
- **Option A:** All orders (complete history)
- **Option B:** Recent orders only (e.g., 2024+)
- **Option C:** V2 orders only (skip V1)

**Impact:**
- Option A: ~3.7M rows, large migration time, complete audit trail
- Option B: ~200k rows (estimated), faster, recent data only
- Option C: ~88k rows, fastest, but loses historical V1 orders

### Question 2: V1 Serialized Data Format
**Q:** What format is the V1 `orders.order` field?
- PHP serialize()?
- JSON?
- Custom format?

**Action:** Sample data will help determine deserialization strategy.

### Question 3: Payment Info BLOBs
**Q:** The V2 `order_details.payment_info` and `refund_info` columns are BLOBs. What format are they?
- PHP serialize()?
- JSON?
- Binary?

**Action:** Sample data needed to understand structure.

---

## 📋 Data Export Commands (for Santiago)

### Option 1: MySQL CSV Export

```bash
# Export V2 order tables to CSV
mysql -u root -p menuca_v2 -e "SELECT * FROM order_details" > order_details.csv
mysql -u root -p menuca_v2 -e "SELECT * FROM order_main_items" > order_main_items.csv
mysql -u root -p menuca_v2 -e "SELECT * FROM order_sub_items" > order_sub_items.csv
mysql -u root -p menuca_v2 -e "SELECT * FROM order_sub_items_combo" > order_sub_items_combo.csv
mysql -u root -p menuca_v2 -e "SELECT * FROM order_pdf" > order_pdf.csv
mysql -u root -p menuca_v2 -e "SELECT * FROM site_users_delivery_addresses" > site_users_delivery_addresses.csv
```

### Option 2: MySQL Dump Export

```bash
# Export V2 order tables to SQL dump
mysqldump -u root -p menuca_v2 order_details order_main_items order_sub_items order_sub_items_combo order_pdf cancel_order_requests > menuca_v2_orders_dump.sql

# Export V1 sample orders
mysqldump -u root -p menuca_v1 orders --where="time > UNIX_TIMESTAMP('2024-01-01')" --limit=100 > menuca_v1_orders_sample.sql
```

---

## ✅ What We Have So Far

- ✅ V3 schema design complete (`01_create_v3_order_schema.sql`)
- ✅ Field mapping complete (`orders-field-mapping.md`)
- ✅ Entity documentation (`/MEMORY_BANK/ENTITIES/06_ORDERS_CHECKOUT.md`)
- ✅ Folder structure created

---

## 🚀 Next Steps (After Data Received)

1. Load V2 data into staging tables
2. Analyze V1 serialized format
3. Create transformation queries
4. Load V2 orders to menuca_v3
5. Build V1 deserialization script (if migrating V1)
6. Validate data integrity
7. Create completion summary

---

## 📞 Contact

**Waiting for:** Santiago to provide data dumps  
**Expected Delivery:** TBD  
**Status:** 🟡 Blocked - Waiting for data

---

**Note:** Once data is received, migration can proceed rapidly. V2 data is structured and straightforward to migrate. V1 data will require deserialization work similar to the Menu BLOB migration.
