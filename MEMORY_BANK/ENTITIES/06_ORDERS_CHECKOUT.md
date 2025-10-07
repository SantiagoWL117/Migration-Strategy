# Orders & Checkout Entity - PHASE 1 STARTING

**Status:** 🔄 **IN PROGRESS - Phase 1: Analysis**  
**Start Date:** October 7, 2025  
**Priority:** HIGH (Critical for revenue tracking)

---

## ENTITY OVERVIEW

Order management system for customer purchases including cart items, pricing, payments, and order status tracking.

**Business Impact:**
- Enables complete order history
- Tracks revenue and sales data
- Foundation for reporting and analytics
- Required for customer order tracking
- Critical for restaurant operations

---

## SCOPE

### V1 Order Tables (Legacy - 3.7M+ rows)

#### menuca_v1.orders
- **~3,686,498 rows** (PRIMARY SOURCE for V1 orders)
- Simple structure with serialized TEXT `order` field
- Contains: user, restaurant, orderId, order (JSON/serialized), time, ip
- Legacy PHP serialized data needs deserialization

#### Other V1 Tables (Investigation needed):
- `avs_orders` - ?
- `delivery_orders` - ?
- `tablet_orders` - ?
- `user_orders` - ?
- `user_orders_count` - ?

### V2 Order Tables (Modern - ~300k rows)

#### menuca_v2.order_details
- **~88,608 rows** (PRIMARY SOURCE for V2 order headers)
- Main order record with:
  - Restaurant, user, total, taxes (JSON)
  - Status: pending/rejected/accepted/canceled
  - Payment method, device, order type (takeout/delivery)
  - Timestamps: added_on, ordered_for, updated_at
  - Coupons, deals, fees (delivery, convenience, service)
  - Address, comments, payment_info (BLOB)

#### menuca_v2.order_main_items
- **~141,280 rows** (Order line items)
- Items added to order:
  - item_id (menu dish reference)
  - is_combo (y/n)
  - item_size, base_price, quantity
  - special_instructions
  - add_to_cart flag

#### menuca_v2.order_sub_items
- **~87,470 rows** (Item modifiers/ingredients)
- Customizations for main items:
  - main_item_id (FK to order_main_items)
  - item_id (ingredient/modifier)
  - price, position, item_count
  - type (extra, ci, etc.)
  - combo_index, group_index, group_id

#### menuca_v2.order_sub_items_combo
- **~4,191 rows** (Combo item customizations)
- Similar to order_sub_items but for combo dishes

#### Other V2 Tables:
- `cancel_order_requests` - Cancellation tracking
- `order_pdf` - Generated PDFs (~13,474 rows)
- `tablet_orders` - Tablet-specific data

---

## V3 SCHEMA DESIGN (TO BE CREATED)

### Proposed Tables:

#### menuca_v3.orders
- Core order record
- FK: user_id, restaurant_id
- Status, totals, timestamps
- Payment method, order type

#### menuca_v3.order_items
- Line items for orders
- FK: order_id, dish_id
- Quantity, price, size
- Special instructions

#### menuca_v3.order_item_modifiers
- Modifiers/customizations
- FK: order_item_id, ingredient_id
- Price, quantity, position

#### menuca_v3.order_combos
- Combo dish selections
- FK: order_item_id, combo_group_id, dish_id

#### menuca_v3.order_fees
- Delivery, convenience, service fees
- FK: order_id

#### menuca_v3.order_discounts
- Coupons, deals, credits
- FK: order_id

#### menuca_v3.order_addresses
- Delivery address snapshots
- FK: order_id (denormalized for historical accuracy)

---

## DATA VOLUME ESTIMATE

| Table | V1 Rows | V2 Rows | Total Est. |
|-------|---------|---------|------------|
| **orders** | ~3.7M | ~88k | **~3.8M** |
| **order_items** | ? | ~141k | **~500k** |
| **order_modifiers** | ? | ~87k | **~300k** |
| **order_combos** | ? | ~4k | **~50k** |
| **order_fees** | ? | ~88k | **~100k** |
| **order_discounts** | ? | ~30k | **~50k** |
| **order_addresses** | ? | ~60k | **~80k** |
| **TOTAL** | | | **~4.9M rows** |

---

## KEY CHALLENGES

### 🔴 CRITICAL

1. **V3 Schema Does Not Exist**
   - Need to design from scratch
   - Must support both V1 and V2 structures
   - Need to handle serialized V1 data

2. **V1 Serialized Data**
   - `order` field contains PHP serialized TEXT
   - Needs deserialization (similar to Menu BLOB work)
   - Estimated ~3.7M records to deserialize

3. **Data Volume**
   - ~3.7M orders from V1
   - ~88k orders from V2
   - Total ~3.8M order records + ~5M related rows
   - Large data transfer and transformation

4. **Complex Relationships**
   - Orders → Items → Modifiers (3-level hierarchy)
   - Orders → Combos → Combo Items
   - Orders → Fees, Discounts, Addresses

### ⚠️ HIGH PRIORITY

5. **Payment Data (BLOB)**
   - `payment_info` and `refund_info` are BLOBs
   - Need to analyze and deserialize

6. **Price Calculations**
   - Need to validate: base_price + modifiers + fees - discounts = total
   - Ensure no data corruption

7. **Order Status Migration**
   - V2: pending/rejected/accepted/canceled
   - V1: open (1/0)
   - Need unified status model

### 🟡 MEDIUM PRIORITY

8. **Date Filtering**
   - Decide: Migrate all orders or recent only?
   - Storage vs. completeness tradeoff

9. **Foreign Key Integrity**
   - Restaurant IDs (menuca_v3.restaurants)
   - User IDs (menuca_v3.users)
   - Dish IDs (menuca_v3.dishes)
   - Ingredient IDs (menuca_v3.ingredients)

---

## DEPENDENCIES

### ✅ COMPLETED DEPENDENCIES

1. **Location & Geography** ✅ (cities, provinces)
   - For delivery address validation

2. **Menu & Catalog** ✅ (121,149 rows)
   - For dish_id, ingredient_id FKs

3. **Restaurant Management** ✅
   - For restaurant_id FK

4. **Users & Access** ✅ (32,349 users)
   - For user_id FK

### ⏳ BLOCKS DOWNSTREAM

- **Payments Entity** (1.4M rows)
- **Accounting & Reporting** (depends on Orders)

---

## NEXT STEPS - PHASE 1

### 🎯 Immediate Actions:

1. ✅ Read V1/V2 order table structures (IN PROGRESS)
2. ⏳ Ask Santiago for V1/V2 order data dumps/CSVs
3. ⏳ Analyze V1 serialized `order` field format (sample data)
4. ⏳ Design V3 order schema
5. ⏳ Create field mapping document
6. ⏳ Load staging data
7. ⏳ Build deserialization scripts (V1 orders)
8. ⏳ Transform and load to menuca_v3

---

## MIGRATION STRATEGY

### Option A: Migrate All Orders (Complete History)
- **Pros:** Complete data, full audit trail
- **Cons:** ~3.8M rows, large storage, long migration time

### Option B: Migrate Recent Orders Only (2024+)
- **Pros:** Faster, smaller dataset
- **Cons:** Lost historical data

### Option C: Two-Tiered Approach
- **Tier 1:** V2 orders (88k rows) - Full detail migration
- **Tier 2:** V1 orders (3.7M rows) - Summary/archive migration

**Recommendation:** TBD after stakeholder input

---

## FILES TO CREATE

### Documentation:
- [ ] `/documentation/Orders & Checkout/orders-mapping.md`
- [ ] `/documentation/Orders & Checkout/orders_migration_plan.md`

### SQL Scripts:
- [ ] `01_create_v3_order_schema.sql`
- [ ] `02_create_staging_tables.sql`
- [ ] `03_load_staging_data.sql`
- [ ] `04_transform_and_load.sql`
- [ ] `05_verification_queries.sql`

### Python Tools:
- [ ] `deserialize_v1_orders.py` (if needed)
- [ ] `load_order_data.py`

---

## NOTES

- **Data Location:** No order data in `/Database/` folder yet - NEED DUMPS FROM SANTIAGO
- **Similar to Menu Migration:** V1 has serialized data like Menu BLOB deserialization
- **Critical for Revenue:** Orders are the core business transaction data
- **Testing Strategy:** Need sample orders to validate pricing calculations

---

## STATUS UPDATES

### 2025-10-07 (Today):
- ✅ Created entity file
- ✅ Analyzed V1/V2 table structures (6 V1 tables, 7 V2 tables)
- ✅ Designed complete V3 order schema (7 tables)
- ✅ Created comprehensive field mapping document
- ✅ Updated PROJECT_STATUS.md (4/12 entities complete - 33.3%)
- ✅ Created folder structure and documentation
- ✅ Created DATA_NEEDED.md with specific export queries for Santiago
- 🟡 **BLOCKED:** Waiting for Santiago to provide order data dumps
- 🎯 **Next:** Load staging data when dumps arrive, then transform to menuca_v3

---

*Last Updated: October 7, 2025*  
*Entity 6 of 12 - 🔄 IN PROGRESS (Phase 1: Analysis)*
