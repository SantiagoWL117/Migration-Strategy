# Partitioning Strategy

> **Time-Series Data Partitioning** - How high-volume tables are partitioned

---

## 📋 Overview

The menuca_v3 schema uses **table partitioning** for high-volume, time-series data to:
- Improve query performance on recent data
- Enable efficient data archival
- Simplify maintenance operations (vacuum, analyze)
- Allow partition pruning for date-range queries

---

## 📊 Partitioned Tables

### `orders` Table

**Partitioning Key:** `created_at`  
**Partition Scheme:** Monthly (RANGE)

```sql
CREATE TABLE menuca_v3.orders (
    id BIGSERIAL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- ... other columns ...
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);
```

**Partitions Created:**
```
orders_2025_01  (2025-01-01 to 2025-02-01)
orders_2025_02  (2025-02-01 to 2025-03-01)
orders_2025_03  (2025-03-01 to 2025-04-01)
... through ...
orders_2025_12  (2025-12-01 to 2026-01-01)
orders_2026_01  (2026-01-01 to 2026-02-01)
... through ...
orders_2026_12  (2026-12-01 to 2027-01-01)
```

---

### `order_items` Table

**Partitioning Key:** `created_at`  
**Partition Scheme:** Monthly (RANGE)

```sql
CREATE TABLE menuca_v3.order_items (
    id BIGSERIAL,
    order_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- ... other columns ...
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);
```

**Partitions:** Same structure as orders

---

### `audit_log` Table

**Partitioning Key:** `changed_at`  
**Partition Scheme:** Monthly (RANGE)

```sql
CREATE TABLE menuca_v3.audit_log (
    id BIGSERIAL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- ... other columns ...
    PRIMARY KEY (id, changed_at)
) PARTITION BY RANGE (changed_at);
```

**Partitions:** Same structure as orders

---

## 🔧 Partition Management

### Creating New Partitions

```sql
-- Create partition for January 2027
CREATE TABLE menuca_v3.orders_2027_01 PARTITION OF menuca_v3.orders
    FOR VALUES FROM ('2027-01-01') TO ('2027-02-01');

-- Create matching order_items partition
CREATE TABLE menuca_v3.order_items_2027_01 PARTITION OF menuca_v3.order_items
    FOR VALUES FROM ('2027-01-01') TO ('2027-02-01');

-- Create matching audit_log partition
CREATE TABLE menuca_v3.audit_log_2027_01 PARTITION OF menuca_v3.audit_log
    FOR VALUES FROM ('2027-01-01') TO ('2027-02-01');
```

### Automated Partition Creation

Create partitions ahead of time (recommended 3-6 months in advance):

```sql
DO $$
DECLARE
    start_date DATE := '2027-01-01';
    end_date DATE;
    partition_name TEXT;
BEGIN
    FOR i IN 0..11 LOOP
        end_date := start_date + INTERVAL '1 month';
        partition_name := 'orders_' || TO_CHAR(start_date, 'YYYY_MM');
        
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS menuca_v3.%I PARTITION OF menuca_v3.orders FOR VALUES FROM (%L) TO (%L)',
            partition_name, start_date, end_date
        );
        
        start_date := end_date;
    END LOOP;
END $$;
```

---

## 🎯 Query Optimization

### Partition Pruning

The query planner automatically prunes partitions when filtering by partition key:

```sql
-- This query only scans orders_2025_11 and orders_2025_12
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.orders
WHERE created_at >= '2025-11-01' AND created_at < '2026-01-01';

-- Plan output shows:
-- -> Append
--    -> Seq Scan on orders_2025_11 (actual rows: ...)
--    -> Seq Scan on orders_2025_12 (actual rows: ...)
```

### Best Practices for Queries

**DO:**
```sql
-- Filter by partition key (fast - partition pruning)
SELECT * FROM menuca_v3.orders
WHERE created_at >= '2025-11-01'
AND restaurant_id = 105;
```

**DON'T:**
```sql
-- Missing partition key filter (scans all partitions)
SELECT * FROM menuca_v3.orders
WHERE restaurant_id = 105;
```

---

## 📁 Index Strategy

### Per-Partition Indexes

Each partition maintains its own indexes:

```sql
-- Primary key is automatic (partition key included)
-- Additional indexes needed per partition:

CREATE INDEX idx_orders_2025_11_restaurant 
    ON menuca_v3.orders_2025_11 (restaurant_id);

CREATE INDEX idx_orders_2025_11_user 
    ON menuca_v3.orders_2025_11 (user_id);

CREATE INDEX idx_orders_2025_11_status 
    ON menuca_v3.orders_2025_11 (status);
```

### Automated Index Creation

```sql
-- Template for new partitions
DO $$
DECLARE
    partition_name TEXT := 'orders_2027_01';
BEGIN
    EXECUTE format(
        'CREATE INDEX idx_%s_restaurant ON menuca_v3.%I (restaurant_id)',
        partition_name, partition_name
    );
    EXECUTE format(
        'CREATE INDEX idx_%s_user ON menuca_v3.%I (user_id)',
        partition_name, partition_name
    );
    EXECUTE format(
        'CREATE INDEX idx_%s_status ON menuca_v3.%I (status)',
        partition_name, partition_name
    );
END $$;
```

---

## 🗄️ Data Archival

### Detaching Old Partitions

```sql
-- Detach partition (keeps data, removes from parent)
ALTER TABLE menuca_v3.orders 
DETACH PARTITION menuca_v3.orders_2023_01;

-- Optionally move to archive schema
ALTER TABLE menuca_v3.orders_2023_01 
SET SCHEMA archive;
```

### Dropping Old Partitions

```sql
-- Drop partition and all data
ALTER TABLE menuca_v3.orders 
DETACH PARTITION menuca_v3.orders_2023_01;

DROP TABLE menuca_v3.orders_2023_01;
```

---

## ⚙️ Maintenance

### Vacuum and Analyze

Partitions can be maintained individually:

```sql
-- Vacuum specific partition
VACUUM (ANALYZE) menuca_v3.orders_2025_11;

-- Or vacuum all partitions
VACUUM (ANALYZE) menuca_v3.orders;
```

### Statistics

```sql
-- Check partition sizes
SELECT 
    schemaname || '.' || tablename as partition,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as size
FROM pg_tables
WHERE schemaname = 'menuca_v3'
AND tablename LIKE 'orders_202%'
ORDER BY tablename;
```

---

## ⚠️ Constraints and Limitations

### Foreign Key Considerations

1. **FKs TO partitioned tables:** Require partition key in FK
2. **FKs FROM partitioned tables:** Work normally

```sql
-- order_items references orders
-- Both must include created_at in the relationship
ALTER TABLE menuca_v3.order_items 
ADD CONSTRAINT fk_order 
FOREIGN KEY (order_id, created_at) 
REFERENCES menuca_v3.orders (id, created_at);
```

### Primary Key Requirements

Partition key MUST be included in primary key:

```sql
-- Correct
PRIMARY KEY (id, created_at)

-- Incorrect (will fail)
PRIMARY KEY (id)
```

---

## 📅 Partition Calendar

| Year | Months | Tables Affected |
|------|--------|-----------------|
| 2025 | 01-12 | orders, order_items, audit_log |
| 2026 | 01-12 | orders, order_items, audit_log |
| 2027+ | TBD | Create as needed |

---

**Last Updated:** 2025-11-27

