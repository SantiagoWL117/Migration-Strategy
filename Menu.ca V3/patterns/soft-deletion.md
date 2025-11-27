# Soft Deletion Pattern

> **Soft Delete Implementation** - How records are logically deleted

---

## 📋 Overview

The menuca_v3 schema implements **soft deletion** for most tables:
- Records are not physically removed from the database
- A `deleted_at` timestamp indicates deletion
- An optional `deleted_by` tracks who deleted
- Queries filter by `deleted_at IS NULL`

---

## 🎯 Purpose

Soft deletion provides:
1. **Data Recovery** - Restore accidentally deleted records
2. **Audit Trail** - Track when/who deleted
3. **Referential Integrity** - Avoid cascade issues
4. **Historical Analysis** - Include deleted records in reports

---

## 📊 Implementation

### Standard Columns

Tables using soft deletion include:

```sql
deleted_at TIMESTAMPTZ DEFAULT NULL,  -- When deleted (NULL = active)
deleted_by BIGINT DEFAULT NULL        -- Admin who deleted (FK to admin_users)
```

### Tables with Soft Deletion

| Entity | Tables |
|--------|--------|
| Restaurant | restaurants, restaurant_locations, restaurant_contacts, restaurant_service_configs, restaurant_domains |
| Menu | courses, dishes, modifier_groups, dish_modifiers, dish_modifier_prices |
| Delivery | restaurant_schedules, restaurant_delivery_zones, restaurant_delivery_areas |
| User | users, user_addresses |
| Admin | admin_users, admin_restaurant_access |

---

## 🔧 Query Patterns

### Filtering Active Records

**Standard WHERE clause:**
```sql
SELECT * FROM menuca_v3.restaurants
WHERE deleted_at IS NULL;
```

**With JOIN:**
```sql
SELECT r.*, rl.street_address
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl 
    ON rl.restaurant_id = r.id 
    AND rl.deleted_at IS NULL
WHERE r.deleted_at IS NULL;
```

### Partial Indexes for Performance

```sql
-- Index only active records
CREATE INDEX idx_restaurants_active 
    ON menuca_v3.restaurants (status)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_dishes_active 
    ON menuca_v3.dishes (restaurant_id, course_id)
    WHERE deleted_at IS NULL;
```

---

## ✏️ Deletion Operations

### Soft Delete

```sql
-- Soft delete a single record
UPDATE menuca_v3.restaurants
SET 
    deleted_at = NOW(),
    deleted_by = :admin_id
WHERE id = :restaurant_id;
```

### Soft Delete with Cascade

```sql
-- Soft delete restaurant and all children
DO $$
DECLARE
    v_restaurant_id BIGINT := :restaurant_id;
    v_admin_id BIGINT := :admin_id;
BEGIN
    -- Delete restaurant
    UPDATE menuca_v3.restaurants
    SET deleted_at = NOW(), deleted_by = v_admin_id
    WHERE id = v_restaurant_id;
    
    -- Delete locations
    UPDATE menuca_v3.restaurant_locations
    SET deleted_at = NOW(), deleted_by = v_admin_id
    WHERE restaurant_id = v_restaurant_id;
    
    -- Delete courses
    UPDATE menuca_v3.courses
    SET deleted_at = NOW(), deleted_by = v_admin_id
    WHERE restaurant_id = v_restaurant_id;
    
    -- Delete dishes
    UPDATE menuca_v3.dishes
    SET deleted_at = NOW(), deleted_by = v_admin_id
    WHERE restaurant_id = v_restaurant_id;
    
    -- ... continue for other related tables
END $$;
```

### Restore Deleted Record

```sql
-- Restore a soft-deleted record
UPDATE menuca_v3.restaurants
SET 
    deleted_at = NULL,
    deleted_by = NULL
WHERE id = :restaurant_id;
```

---

## 🛡️ RLS Integration

RLS policies typically include soft deletion filter:

```sql
CREATE POLICY "public_read_active" ON menuca_v3.restaurants
    FOR SELECT
    USING (
        status = 'active' 
        AND deleted_at IS NULL
    );
```

---

## ⚙️ Trigger for Cascade Soft Delete

Optionally, create a trigger for automatic cascade:

```sql
CREATE OR REPLACE FUNCTION menuca_v3.cascade_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- When restaurant is soft deleted, cascade to children
    IF TG_TABLE_NAME = 'restaurants' THEN
        IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
            UPDATE menuca_v3.restaurant_locations
            SET deleted_at = NEW.deleted_at, deleted_by = NEW.deleted_by
            WHERE restaurant_id = NEW.id AND deleted_at IS NULL;
            
            UPDATE menuca_v3.courses
            SET deleted_at = NEW.deleted_at, deleted_by = NEW.deleted_by
            WHERE restaurant_id = NEW.id AND deleted_at IS NULL;
            
            UPDATE menuca_v3.dishes
            SET deleted_at = NEW.deleted_at, deleted_by = NEW.deleted_by
            WHERE restaurant_id = NEW.id AND deleted_at IS NULL;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cascade_soft_delete
    AFTER UPDATE OF deleted_at ON menuca_v3.restaurants
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.cascade_soft_delete();
```

---

## 🆚 Hard Delete vs Soft Delete

### When to Use Soft Delete

- Core business data (restaurants, dishes, orders)
- Data that may need recovery
- Data with historical value
- Data with foreign key dependencies

### When to Use Hard Delete

- Session data (carts, expired sessions)
- Temporary data (failed payment attempts)
- PII data requiring GDPR compliance
- Test/development data

**Hard delete example:**
```sql
-- Hard delete cart items (expired)
DELETE FROM menuca_v3.cart_items
WHERE cart_id IN (
    SELECT id FROM menuca_v3.carts
    WHERE expires_at < NOW() - INTERVAL '7 days'
);

DELETE FROM menuca_v3.carts
WHERE expires_at < NOW() - INTERVAL '7 days';
```

---

## 📊 Monitoring Deleted Records

### Find Recently Deleted

```sql
SELECT 
    table_name,
    record_id,
    deleted_at,
    au.email as deleted_by_email
FROM (
    SELECT 'restaurants' as table_name, id as record_id, deleted_at, deleted_by
    FROM menuca_v3.restaurants WHERE deleted_at IS NOT NULL
    UNION ALL
    SELECT 'dishes', id, deleted_at, deleted_by
    FROM menuca_v3.dishes WHERE deleted_at IS NOT NULL
) deleted_records
LEFT JOIN menuca_v3.admin_users au ON au.id = deleted_records.deleted_by
WHERE deleted_at > NOW() - INTERVAL '7 days'
ORDER BY deleted_at DESC;
```

### Count by Status

```sql
SELECT 
    'restaurants' as table_name,
    COUNT(*) FILTER (WHERE deleted_at IS NULL) as active,
    COUNT(*) FILTER (WHERE deleted_at IS NOT NULL) as deleted
FROM menuca_v3.restaurants
UNION ALL
SELECT 
    'dishes',
    COUNT(*) FILTER (WHERE deleted_at IS NULL),
    COUNT(*) FILTER (WHERE deleted_at IS NOT NULL)
FROM menuca_v3.dishes;
```

---

## ⚠️ Considerations

### Performance

- Partial indexes significantly improve query performance
- Consider periodic hard delete of old soft-deleted records

### Data Cleanup Job

```sql
-- Permanently delete records soft-deleted over 1 year ago
DELETE FROM menuca_v3.dishes
WHERE deleted_at < NOW() - INTERVAL '1 year';
```

### Unique Constraints

Handle unique constraints with soft deletion:

```sql
-- Unique slug only for active restaurants
CREATE UNIQUE INDEX idx_restaurants_slug_unique 
    ON menuca_v3.restaurants (slug) 
    WHERE deleted_at IS NULL;
```

---

**Last Updated:** 2025-11-27

