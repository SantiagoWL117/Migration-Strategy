# Orders & Checkout - Field Mapping (V1/V2 → V3)

**Entity:** Orders & Checkout  
**Purpose:** Map legacy order fields to menuca_v3 schema  
**Date:** 2025-10-07  
**Status:** Draft - Awaiting Data Dumps

---

## Table of Contents
1. [Orders (Main Order Record)](#1-orders-main-order-record)
2. [Order Items](#2-order-items)
3. [Order Item Modifiers](#3-order-item-modifiers)
4. [Order Delivery Addresses](#4-order-delivery-addresses)
5. [Order Discounts](#5-order-discounts)
6. [Order PDFs](#6-order-pdfs)

---

## 1. ORDERS (Main Order Record)

### menuca_v3.orders

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `legacy_v1_id` | INTEGER | V1 | `id` | - | Traceability |
| `legacy_v2_id` | INTEGER | V2 | - | `id` | Traceability |
| `user_id` | BIGINT | V1/V2 | `user` | `user_id` | FK to menuca_v3.users |
| `restaurant_id` | BIGINT | V1/V2 | `restaurant` | `restaurant_id` | FK to menuca_v3.restaurants |
| `order_number` | VARCHAR(50) | V1/V2 | `orderId` | Derived from `id` | Human-readable format |
| `order_type` | VARCHAR(20) | V2 | - | `order_type` | Map: 't'→'takeout', 'd'→'delivery' |
| `status` | VARCHAR(20) | V1/V2 | `open` | `status` | V1: '1'→'pending', '0'→'completed'; V2: direct |
| `rejection_reason` | TEXT | V2 | - | `reason` | Only if status=rejected |
| `placed_at` | TIMESTAMPTZ | V1/V2 | `time` (UNIX) | `added_on` | V1: FROM_UNIXTIME(); V2: direct |
| `scheduled_for` | TIMESTAMPTZ | V2 | - | `ordered_for` | NULL if ASAP |
| `is_asap` | BOOLEAN | V2 | - | `asap` | Map: 'y'→TRUE, 'n'→FALSE |
| `completed_at` | TIMESTAMPTZ | Derived | - | `updated_at` | If status=completed |
| `subtotal` | DECIMAL(10,2) | V2 | - | `food_value` | Items total before fees |
| `tax_total` | DECIMAL(10,2) | V2 | - | Computed from `taxes` JSON | Sum of all taxes |
| `delivery_fee` | DECIMAL(10,2) | V2 | - | `delivery_fee` | Direct |
| `convenience_fee` | DECIMAL(10,2) | V2 | - | `convenience_fee` | Direct |
| `service_fee` | DECIMAL(10,2) | V2 | - | `service_fee` | Direct |
| `driver_tip` | DECIMAL(10,2) | V2 | - | `driver_tip` | Direct |
| `discount_total` | DECIMAL(10,2) | V2 | - | `coupon_deduct + deal_deduct + other_discounts` | Sum all discounts |
| `grand_total` | DECIMAL(10,2) | V2 | - | `total` | Final charged amount |
| `taxes` | JSONB | V2 | - | `taxes` | Direct JSON copy |
| `payment_method` | VARCHAR(50) | V2 | - | `payment_method` | Map ID to name |
| `payment_status` | VARCHAR(20) | V2 | - | Derived from `is_void`, `is_refund` | Logic mapping |
| `payment_info` | JSONB | V2 | - | `payment_info` (BLOB) | Deserialize BLOB |
| `customer_phone` | VARCHAR(20) | V2 | - | From `address_id` | Lookup user address |
| `special_instructions` | TEXT | V2 | - | `comments` | Direct |
| `device_type` | VARCHAR(20) | V2 | - | `device` | Map: 'd'→'desktop', 'm'→'mobile' |
| `user_ip` | INET | V1/V2 | `ip` | `user_ip` | Cast to INET |
| `referral_source` | VARCHAR(100) | V2 | - | `referal` | Direct |
| `is_reorder` | BOOLEAN | V2 | - | `is_reorder` | Map: 'y'→TRUE, 'n'→FALSE |
| `is_void` | BOOLEAN | V2 | - | `is_void` | Map: 'y'→TRUE, 'n'→FALSE |
| `is_refund` | BOOLEAN | V2 | - | `is_refund` | Map: 'y'→TRUE, 'n'→FALSE |

### V1 Special Handling: Serialized `order` Field

**V1 Issue:** The `order` TEXT field contains PHP serialized data with full order details.

**Strategy:**
1. Deserialize PHP data (similar to Menu BLOB deserialization)
2. Extract order items, modifiers, prices
3. Transform to normalized V3 structure

**Sample V1 Deserialization (TBD after data dump):**
```
menuca_v1.orders.order (TEXT) → PHP unserialize()
→ Extract items[] → menuca_v3.order_items
→ Extract modifiers[] → menuca_v3.order_item_modifiers
```

---

## 2. ORDER_ITEMS (Line Items)

### menuca_v3.order_items

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `order_id` | BIGINT | V1/V2 | Derived | `order_id` | FK to menuca_v3.orders |
| `dish_id` | BIGINT | V1/V2 | Extracted | `item_id` | FK to menuca_v3.dishes (map V1/V2 item_id → V3 dish_id) |
| `item_name` | VARCHAR(255) | V1/V2 | Extracted | From menu lookup | Snapshot dish name |
| `is_combo` | BOOLEAN | V2 | - | `is_combo` | Map: 'y'→TRUE, 'n'→FALSE |
| `base_price` | DECIMAL(10,2) | V1/V2 | Extracted | `base_price` | Direct |
| `modifiers_price` | DECIMAL(10,2) | V1/V2 | Computed | Computed | Sum of all modifiers for this item |
| `line_total` | DECIMAL(10,2) | V1/V2 | Computed | Computed | (base_price + modifiers_price) × quantity |
| `quantity` | SMALLINT | V1/V2 | Extracted | `quantity` | Direct |
| `size_name` | VARCHAR(100) | V1/V2 | Extracted | `hr_size` | Human-readable size |
| `size_code` | VARCHAR(20) | V1/V2 | Extracted | `item_size` | Internal size code |
| `special_instructions` | TEXT | V2 | - | `special_instructions` | Direct |
| `display_order` | SMALLINT | Generated | - | - | Order items by `added_on` |
| `add_to_cart` | BOOLEAN | V2 | - | `add_to_cart` | Map: 'y'→TRUE, 'n'→FALSE |

---

## 3. ORDER_ITEM_MODIFIERS (Customizations)

### menuca_v3.order_item_modifiers

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `order_item_id` | BIGINT | V1/V2 | Derived | `main_item_id` | FK to menuca_v3.order_items |
| `ingredient_id` | BIGINT | V1/V2 | Extracted | `item_id` | FK to menuca_v3.ingredients (map V1/V2 → V3) |
| `modifier_name` | VARCHAR(255) | V1/V2 | Extracted | From menu lookup | Snapshot ingredient name |
| `modifier_type` | VARCHAR(50) | V1/V2 | Extracted | `type` | 'extra', 'no', 'light', etc. |
| `price` | DECIMAL(10,2) | V1/V2 | Extracted | `price` | Direct |
| `quantity` | SMALLINT | V1/V2 | Extracted | `item_count` | Direct |
| `position` | VARCHAR(10) | V2 | - | `position` | Map: 'l'→'left', 'r'→'right', 'a'→'all' |
| `group_id` | INTEGER | V2 | - | `group_id` | Direct |
| `group_name` | VARCHAR(255) | V2 | - | Lookup | From ingredient_groups |
| `group_index` | SMALLINT | V2 | - | `group_index` | Direct |
| `combo_index` | SMALLINT | V2 | - | `combo_index` | Direct |
| `dish_id` | BIGINT | V2 | - | `dish` | For combo selections |
| `dish_size` | SMALLINT | V2 | - | `dish_size` | Direct |
| `display_order` | SMALLINT | V2 | - | `display_order` | Direct |
| `header` | VARCHAR(255) | V2 | - | `header` | Direct |
| `enabled` | BOOLEAN | V2 | - | `enabled` | Map: 'y'→TRUE, 'n'→FALSE |

**Note:** V2 has two tables for modifiers:
- `order_sub_items` → Regular modifiers
- `order_sub_items_combo` → Combo modifiers (merge into single V3 table)

---

## 4. ORDER_DELIVERY_ADDRESSES (Address Snapshot)

### menuca_v3.order_delivery_addresses

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `order_id` | BIGINT | V1/V2 | Derived | Derived | FK to menuca_v3.orders |
| `street_address` | VARCHAR(255) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.street` |
| `unit_number` | VARCHAR(50) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.apartment` |
| `city` | VARCHAR(100) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.city` |
| `postal_code` | VARCHAR(15) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.zip` |
| `latitude` | DECIMAL(13,10) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.lat` |
| `longitude` | DECIMAL(13,10) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.lng` |
| `place_id` | VARCHAR(255) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.place_id` |
| `phone` | VARCHAR(20) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.phone` |
| `buzzer` | VARCHAR(50) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.ringer` |
| `extension` | VARCHAR(50) | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.extension` |
| `delivery_instructions` | TEXT | V2 | - | Lookup from `address_id` | From `site_users_delivery_addresses.special_instructions` |

**Note:** Only populate for `order_type = 'delivery'`

---

## 5. ORDER_DISCOUNTS (Coupons, Deals, Credits)

### menuca_v3.order_discounts

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `order_id` | BIGINT | V1/V2 | Derived | Derived | FK to menuca_v3.orders |
| `discount_type` | VARCHAR(50) | V2 | - | Derived | 'coupon' if `coupon` NOT NULL, 'deal' if `deal` NOT NULL |
| `discount_code` | VARCHAR(100) | V2 | - | `coupon` or `deal` | Direct |
| `discount_name` | VARCHAR(255) | V2 | - | `coupon_product` or `deal_item` | Direct |
| `discount_amount` | DECIMAL(10,2) | V2 | - | `coupon_deduct` or `deal_deduct` or `other_discounts` | Direct |
| `applies_to` | VARCHAR(50) | V2 | - | 'order' | Default to order-level |

**Strategy:**
- V2: Parse `coupon`, `deal`, `other_discounts` fields into separate rows
- V1: Extract from serialized `order` field if present

---

## 6. ORDER_PDFS (Generated Receipts)

### menuca_v3.order_pdfs

| V3 Field | Type | Source | V1 Field | V2 Field | Transform Notes |
|----------|------|--------|----------|----------|-----------------|
| `id` | BIGSERIAL | Generated | - | - | New sequence |
| `uuid` | UUID | Generated | - | - | Auto-generated |
| `order_id` | BIGINT | V2 | - | `order_id` | FK to menuca_v3.orders |
| `file_path` | VARCHAR(255) | V2 | - | `file` | Direct |
| `file_name` | VARCHAR(255) | V2 | - | Extracted from `file` | Parse filename |

**Source:** `menuca_v2.order_pdf` (~13,474 rows)

---

## Data Quality Checks

### Required Verifications:

1. **Order Total Calculation:**
   ```sql
   -- Verify: subtotal + tax_total + delivery_fee + convenience_fee + service_fee + driver_tip - discount_total = grand_total
   SELECT 
       id,
       (subtotal + tax_total + delivery_fee + COALESCE(convenience_fee, 0) + COALESCE(service_fee, 0) + COALESCE(driver_tip, 0) - COALESCE(discount_total, 0)) as calculated_total,
       grand_total,
       ABS((subtotal + tax_total + delivery_fee + COALESCE(convenience_fee, 0) + COALESCE(service_fee, 0) + COALESCE(driver_tip, 0) - COALESCE(discount_total, 0)) - grand_total) as difference
   FROM menuca_v3.orders
   WHERE ABS((subtotal + tax_total + delivery_fee + COALESCE(convenience_fee, 0) + COALESCE(service_fee, 0) + COALESCE(driver_tip, 0) - COALESCE(discount_total, 0)) - grand_total) > 0.01;
   ```

2. **FK Integrity:**
   ```sql
   -- Orphaned orders (invalid user_id)
   SELECT COUNT(*) FROM menuca_v3.orders o
   LEFT JOIN menuca_v3.users u ON o.user_id = u.id
   WHERE u.id IS NULL;
   
   -- Orphaned orders (invalid restaurant_id)
   SELECT COUNT(*) FROM menuca_v3.orders o
   LEFT JOIN menuca_v3.restaurants r ON o.restaurant_id = r.id
   WHERE r.id IS NULL;
   ```

3. **Order Items Integrity:**
   ```sql
   -- Orders with no items
   SELECT COUNT(*) FROM menuca_v3.orders o
   LEFT JOIN menuca_v3.order_items oi ON o.id = oi.order_id
   WHERE oi.id IS NULL;
   ```

4. **Delivery Address Integrity:**
   ```sql
   -- Delivery orders with no address
   SELECT COUNT(*) FROM menuca_v3.orders o
   LEFT JOIN menuca_v3.order_delivery_addresses oda ON o.id = oda.order_id
   WHERE o.order_type = 'delivery' AND oda.id IS NULL;
   ```

---

## Migration Priorities

### Phase 1: V2 Orders (Modern Structure)
- **Tables:** `order_details`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`
- **Volume:** ~88k orders + ~230k related rows
- **Complexity:** Medium (structured data)
- **Timeline:** 2-3 days

### Phase 2: V1 Orders (Legacy Structure)
- **Tables:** `orders` (serialized data)
- **Volume:** ~3.7M orders
- **Complexity:** High (PHP deserialization required)
- **Timeline:** 5-7 days
- **Decision:** Migrate all or recent only? (TBD)

---

## Next Steps

1. ✅ Schema design complete
2. ✅ Field mapping complete
3. ⏳ **Request data dumps from Santiago:**
   - V2: `order_details`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`
   - V2: `site_users_delivery_addresses` (for address lookups)
   - V2: Sample data for analysis
   - V1: Sample `orders` table (10-100 rows) for serialized data analysis
4. ⏳ Analyze V1 serialized format
5. ⏳ Create staging tables
6. ⏳ Load V2 data (priority)
7. ⏳ Build V1 deserialization script
8. ⏳ Transform and load to menuca_v3

---

**Status:** ✅ Mapping Complete - Awaiting Data Dumps
