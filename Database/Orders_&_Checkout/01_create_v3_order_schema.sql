-- =========================================
-- menuca_v3 Orders & Checkout Schema
-- =========================================
-- Author: AI (Brian)
-- Date: 2025-10-07
-- Purpose: Create order management tables for menuca_v3
-- Dependencies: users, restaurants, dishes, ingredients, cities
-- =========================================

BEGIN;

-- =========================================
-- 1. ORDERS (Main order record)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.orders (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Legacy IDs for traceability
    legacy_v1_id INTEGER,
    legacy_v2_id INTEGER,
    
    -- Core relationships
    user_id BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    
    -- Order identification
    order_number VARCHAR(50) NOT NULL,  -- Human-readable order number
    
    -- Order type and status
    order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('delivery', 'takeout', 'dinein')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'preparing', 'ready', 'out_for_delivery', 'completed', 'rejected', 'canceled')),
    rejection_reason TEXT,
    cancellation_reason TEXT,
    
    -- Timing
    placed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scheduled_for TIMESTAMPTZ,  -- NULL = ASAP
    is_asap BOOLEAN DEFAULT TRUE,
    accepted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    canceled_at TIMESTAMPTZ,
    
    -- Financial summary
    subtotal DECIMAL(10,2) NOT NULL,  -- Items before fees/discounts
    tax_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,
    convenience_fee DECIMAL(10,2) DEFAULT 0.00,
    service_fee DECIMAL(10,2) DEFAULT 0.00,
    driver_tip DECIMAL(10,2) DEFAULT 0.00,
    discount_total DECIMAL(10,2) DEFAULT 0.00,
    grand_total DECIMAL(10,2) NOT NULL,  -- Final amount charged
    
    -- Tax breakdown (JSONB for flexible tax structure)
    taxes JSONB,  -- {"gst": 5.00, "pst": 7.00, "hst": 13.00, etc.}
    
    -- Payment
    payment_method VARCHAR(50),  -- 'credit_card', 'cash', 'debit', etc.
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded', 'partially_refunded')),
    payment_info JSONB,  -- Stripe/payment gateway response
    
    -- Customer info
    customer_name VARCHAR(255),
    customer_email VARCHAR(255),
    customer_phone VARCHAR(20),
    
    -- Special requests
    special_instructions TEXT,
    
    -- Device and tracking
    device_type VARCHAR(20),  -- 'mobile', 'desktop', 'tablet', 'pos'
    user_ip INET,
    referral_source VARCHAR(100),
    
    -- Flags
    is_reorder BOOLEAN DEFAULT FALSE,
    is_void BOOLEAN DEFAULT FALSE,
    is_refund BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys (will be added after Restaurant Management complete)
    CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES menuca_v3.users(id),
    CONSTRAINT orders_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES menuca_v3.restaurants(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_user ON menuca_v3.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_restaurant ON menuca_v3.orders(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON menuca_v3.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_placed_at ON menuca_v3.orders(placed_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_legacy ON menuca_v3.orders(legacy_v1_id, legacy_v2_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON menuca_v3.orders(order_number);

-- Trigger for updated_at
CREATE TRIGGER trg_orders_updated_at 
BEFORE UPDATE ON menuca_v3.orders 
FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- Comments
COMMENT ON TABLE menuca_v3.orders IS 'Main order records for all customer purchases';
COMMENT ON COLUMN menuca_v3.orders.order_number IS 'Human-readable order identifier (e.g., #12345)';
COMMENT ON COLUMN menuca_v3.orders.is_asap IS 'TRUE if order is ASAP, FALSE if scheduled';
COMMENT ON COLUMN menuca_v3.orders.taxes IS 'JSON object with tax breakdown by type';

-- =========================================
-- 2. ORDER_ITEMS (Line items in orders)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_items (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_id BIGINT NOT NULL,
    dish_id BIGINT,  -- NULL if custom item
    
    -- Item identification
    item_name VARCHAR(255) NOT NULL,  -- Snapshot at time of order
    item_description TEXT,
    
    -- Item type
    is_combo BOOLEAN DEFAULT FALSE,
    
    -- Pricing
    base_price DECIMAL(10,2) NOT NULL,
    modifiers_price DECIMAL(10,2) DEFAULT 0.00,
    line_total DECIMAL(10,2) NOT NULL,  -- (base_price + modifiers_price) * quantity
    
    -- Quantity and size
    quantity SMALLINT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    size_name VARCHAR(100),  -- 'Small', 'Medium', 'Large', etc.
    size_code VARCHAR(20),  -- Internal size code
    
    -- Special requests
    special_instructions TEXT,
    
    -- Position in order (for display)
    display_order SMALLINT DEFAULT 0,
    
    -- Flags
    add_to_cart BOOLEAN DEFAULT TRUE,  -- FALSE if removed before checkout
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES menuca_v3.orders(id) ON DELETE CASCADE,
    CONSTRAINT order_items_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES menuca_v3.dishes(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_items_order ON menuca_v3.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_dish ON menuca_v3.order_items(dish_id);

-- Comments
COMMENT ON TABLE menuca_v3.order_items IS 'Line items (dishes/products) in each order';
COMMENT ON COLUMN menuca_v3.order_items.item_name IS 'Dish name at time of order (snapshot for history)';
COMMENT ON COLUMN menuca_v3.order_items.add_to_cart IS 'FALSE if user removed item before checkout';

-- =========================================
-- 3. ORDER_ITEM_MODIFIERS (Customizations)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_item_modifiers (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_item_id BIGINT NOT NULL,
    ingredient_id BIGINT,  -- NULL if custom modifier
    
    -- Modifier details
    modifier_name VARCHAR(255) NOT NULL,  -- Snapshot
    modifier_type VARCHAR(50),  -- 'extra', 'no', 'light', 'extra_extra', 'side', etc.
    
    -- Pricing
    price DECIMAL(10,2) DEFAULT 0.00,
    
    -- Quantity and position
    quantity SMALLINT DEFAULT 1,
    position VARCHAR(10),  -- 'left', 'right', 'all', 'side'
    
    -- Grouping (for ingredient groups)
    group_id INTEGER,
    group_name VARCHAR(255),
    group_index SMALLINT,
    
    -- Combo specific
    combo_index SMALLINT,  -- For combo items
    dish_id BIGINT,  -- If modifier is adding a dish (combo selections)
    dish_size SMALLINT,
    
    -- Display
    display_order SMALLINT DEFAULT 0,
    header VARCHAR(255),  -- e.g., "Choose your toppings"
    
    -- Flags
    enabled BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_item_modifiers_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES menuca_v3.order_items(id) ON DELETE CASCADE,
    CONSTRAINT order_item_modifiers_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES menuca_v3.ingredients(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_item_modifiers_order_item ON menuca_v3.order_item_modifiers(order_item_id);
CREATE INDEX IF NOT EXISTS idx_order_item_modifiers_ingredient ON menuca_v3.order_item_modifiers(ingredient_id);

-- Comments
COMMENT ON TABLE menuca_v3.order_item_modifiers IS 'Customizations and modifiers for order items (ingredients, extras, etc.)';

-- =========================================
-- 4. ORDER_DELIVERY_ADDRESSES (Address snapshot)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_delivery_addresses (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_id BIGINT NOT NULL,
    
    -- Address details (snapshot at time of order)
    street_address VARCHAR(255) NOT NULL,
    unit_number VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100),
    postal_code VARCHAR(15),
    country_code CHAR(2) DEFAULT 'CA',
    
    -- Geocoding
    latitude DECIMAL(13,10),
    longitude DECIMAL(13,10),
    place_id VARCHAR(255),  -- Google Places ID
    formatted_address TEXT,
    
    -- Delivery specifics
    phone VARCHAR(20),
    buzzer VARCHAR(50),
    extension VARCHAR(50),
    delivery_instructions TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_delivery_addresses_order_id_fkey FOREIGN KEY (order_id) REFERENCES menuca_v3.orders(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_delivery_addresses_order ON menuca_v3.order_delivery_addresses(order_id);
CREATE INDEX IF NOT EXISTS idx_order_delivery_addresses_postal ON menuca_v3.order_delivery_addresses(postal_code);

-- Comments
COMMENT ON TABLE menuca_v3.order_delivery_addresses IS 'Delivery address snapshot for each order (denormalized for historical accuracy)';

-- =========================================
-- 5. ORDER_DISCOUNTS (Coupons, deals, credits)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_discounts (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_id BIGINT NOT NULL,
    
    -- Discount details
    discount_type VARCHAR(50) NOT NULL CHECK (discount_type IN ('coupon', 'deal', 'credit', 'promo', 'loyalty', 'other')),
    discount_code VARCHAR(100),
    discount_name VARCHAR(255),
    discount_amount DECIMAL(10,2) NOT NULL,
    
    -- What was discounted
    applies_to VARCHAR(50),  -- 'order', 'item', 'delivery', etc.
    applies_to_item_id BIGINT,  -- If applies to specific item
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_discounts_order_id_fkey FOREIGN KEY (order_id) REFERENCES menuca_v3.orders(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_discounts_order ON menuca_v3.order_discounts(order_id);
CREATE INDEX IF NOT EXISTS idx_order_discounts_code ON menuca_v3.order_discounts(discount_code);

-- Comments
COMMENT ON TABLE menuca_v3.order_discounts IS 'Discounts applied to orders (coupons, deals, credits, promos)';

-- =========================================
-- 6. ORDER_STATUS_HISTORY (Audit trail)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_status_history (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_id BIGINT NOT NULL,
    
    -- Status change
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by_user_id BIGINT,
    change_reason TEXT,
    
    -- Metadata
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES menuca_v3.orders(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_status_history_order ON menuca_v3.order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_changed_at ON menuca_v3.order_status_history(changed_at DESC);

-- Comments
COMMENT ON TABLE menuca_v3.order_status_history IS 'Audit trail of order status changes';

-- =========================================
-- 7. ORDER_PDFS (Generated order receipts)
-- =========================================

CREATE TABLE IF NOT EXISTS menuca_v3.order_pdfs (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT extensions.uuid_generate_v4() NOT NULL UNIQUE,
    
    -- Relationships
    order_id BIGINT NOT NULL,
    
    -- File info
    file_path VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INTEGER,
    
    -- Metadata
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT order_pdfs_order_id_fkey FOREIGN KEY (order_id) REFERENCES menuca_v3.orders(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_pdfs_order ON menuca_v3.order_pdfs(order_id);

-- Comments
COMMENT ON TABLE menuca_v3.order_pdfs IS 'Generated PDF receipts for orders';

COMMIT;

-- =========================================
-- SUMMARY
-- =========================================
-- Tables created: 7
-- 1. orders (main order records)
-- 2. order_items (line items)
-- 3. order_item_modifiers (customizations)
-- 4. order_delivery_addresses (address snapshots)
-- 5. order_discounts (coupons, deals)
-- 6. order_status_history (audit trail)
-- 7. order_pdfs (receipts)
--
-- Total estimated rows: ~4.9M
-- Dependencies: users, restaurants, dishes, ingredients
-- =========================================
