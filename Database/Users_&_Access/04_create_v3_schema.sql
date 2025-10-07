-- ================================================================
-- Phase 2: V3 Schema Creation - Users & Access Entity
-- ================================================================
-- Creates production tables in menuca_v3 schema
-- Design: Unified user model, email-based identity, bcrypt passwords
-- ================================================================

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 1. CUSTOMER USERS (merged from V1 users + V2 site_users)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.users (
    id BIGSERIAL PRIMARY KEY,
    
    -- Identity
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified BOOLEAN DEFAULT FALSE,
    
    -- Profile
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    language VARCHAR(5) DEFAULT 'EN',
    
    -- Authentication
    password_hash VARCHAR(255) NOT NULL,
    password_changed_at TIMESTAMPTZ,
    
    -- Preferences
    newsletter_subscribed BOOLEAN DEFAULT FALSE,
    vegan_newsletter_subscribed BOOLEAN DEFAULT FALSE,
    
    -- Activity
    login_count INT DEFAULT 0,
    last_login_at TIMESTAMPTZ,
    last_login_ip INET,
    
    -- Credits (from V1)
    credit_balance DECIMAL(10,2) DEFAULT 0.00,
    credit_earned_at TIMESTAMPTZ,
    
    -- OAuth
    facebook_id VARCHAR(100),
    
    -- Origin Tracking (NULL for now, backfill later)
    origin_restaurant_id INT,
    origin_source VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    v1_user_id INT,  -- For traceability
    v2_user_id INT   -- For traceability
);

CREATE INDEX idx_users_email_lower ON menuca_v3.users (LOWER(email));
CREATE INDEX idx_users_last_login ON menuca_v3.users (last_login_at DESC);
CREATE INDEX idx_users_created_at ON menuca_v3.users (created_at DESC);
CREATE INDEX idx_users_v1_id ON menuca_v3.users (v1_user_id);
CREATE INDEX idx_users_v2_id ON menuca_v3.users (v2_user_id);

COMMENT ON TABLE menuca_v3.users IS 'Customer users (merged from V1 users + V2 site_users)';
COMMENT ON COLUMN menuca_v3.users.email IS 'Unique email address (case-insensitive)';
COMMENT ON COLUMN menuca_v3.users.origin_restaurant_id IS 'Restaurant where user first registered (NULL initially, backfilled later)';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 2. ADMIN USERS (restaurant staff)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.admin_users (
    id BIGSERIAL PRIMARY KEY,
    
    -- Identity
    email VARCHAR(255) NOT NULL UNIQUE,
    
    -- Profile
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    
    -- Authentication
    password_hash VARCHAR(255) NOT NULL,
    
    -- Permissions (V1 had serialized data, V3 uses JSONB)
    permissions JSONB DEFAULT '{}',
    
    -- Activity
    last_login_at TIMESTAMPTZ,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    v1_admin_id INT,  -- For traceability
    v2_admin_id INT   -- For traceability
);

CREATE INDEX idx_admin_users_email_lower ON menuca_v3.admin_users (LOWER(email));
CREATE INDEX idx_admin_users_v1_id ON menuca_v3.admin_users (v1_admin_id);
CREATE INDEX idx_admin_users_v2_id ON menuca_v3.admin_users (v2_admin_id);

COMMENT ON TABLE menuca_v3.admin_users IS 'Restaurant staff/admin users';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 3. ADMIN-RESTAURANT RELATIONSHIPS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.admin_user_restaurants (
    id BIGSERIAL PRIMARY KEY,
    
    admin_user_id BIGINT NOT NULL REFERENCES menuca_v3.admin_users(id) ON DELETE CASCADE,
    restaurant_id INT NOT NULL,  -- FK to menuca_v3.restaurants (when ready)
    
    -- Permissions specific to this restaurant
    role VARCHAR(50) DEFAULT 'staff',  -- owner, manager, staff
    permissions JSONB DEFAULT '{}',
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (admin_user_id, restaurant_id)
);

CREATE INDEX idx_admin_restaurants_admin ON menuca_v3.admin_user_restaurants (admin_user_id);
CREATE INDEX idx_admin_restaurants_restaurant ON menuca_v3.admin_user_restaurants (restaurant_id);

COMMENT ON TABLE menuca_v3.admin_user_restaurants IS 'Junction table: which admins manage which restaurants';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 4. USER DELIVERY ADDRESSES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.user_addresses (
    id BIGSERIAL PRIMARY KEY,
    
    user_id BIGINT NOT NULL REFERENCES menuca_v3.users(id) ON DELETE CASCADE,
    
    -- Address Details
    street_address VARCHAR(255),
    apartment VARCHAR(100),
    city_id INT,  -- FK to menuca_v3.cities (already exists from Location entity)
    postal_code VARCHAR(20),
    
    -- Contact
    phone VARCHAR(20),
    delivery_instructions TEXT,
    
    -- Status
    is_default BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    v2_address_id INT  -- For traceability
);

CREATE INDEX idx_user_addresses_user ON menuca_v3.user_addresses (user_id);
CREATE INDEX idx_user_addresses_city ON menuca_v3.user_addresses (city_id);
CREATE INDEX idx_user_addresses_default ON menuca_v3.user_addresses (user_id, is_default) WHERE is_default = TRUE;

COMMENT ON TABLE menuca_v3.user_addresses IS 'Saved delivery addresses for users';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 5. USER FAVORITE RESTAURANTS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.user_favorite_restaurants (
    id BIGSERIAL PRIMARY KEY,
    
    user_id BIGINT NOT NULL REFERENCES menuca_v3.users(id) ON DELETE CASCADE,
    restaurant_id INT NOT NULL,  -- FK to menuca_v3.restaurants
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (user_id, restaurant_id)
);

CREATE INDEX idx_favorites_user ON menuca_v3.user_favorite_restaurants (user_id);
CREATE INDEX idx_favorites_restaurant ON menuca_v3.user_favorite_restaurants (restaurant_id);

COMMENT ON TABLE menuca_v3.user_favorite_restaurants IS 'User-saved favorite restaurants';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 6. PASSWORD RESET TOKENS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    
    user_id BIGINT NOT NULL REFERENCES menuca_v3.users(id) ON DELETE CASCADE,
    
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reset_tokens_user ON menuca_v3.password_reset_tokens (user_id);
CREATE INDEX idx_reset_tokens_token ON menuca_v3.password_reset_tokens (token) WHERE used_at IS NULL;
CREATE INDEX idx_reset_tokens_expires ON menuca_v3.password_reset_tokens (expires_at) WHERE used_at IS NULL;

COMMENT ON TABLE menuca_v3.password_reset_tokens IS 'Password reset tokens (active only)';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 7. AUTOLOGIN TOKENS (Remember Me)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS menuca_v3.autologin_tokens (
    id BIGSERIAL PRIMARY KEY,
    
    user_id BIGINT NOT NULL REFERENCES menuca_v3.users(id) ON DELETE CASCADE,
    
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    last_used_at TIMESTAMPTZ,
    
    -- Device tracking
    user_agent TEXT,
    ip_address INET,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_autologin_user ON menuca_v3.autologin_tokens (user_id);
CREATE INDEX idx_autologin_token ON menuca_v3.autologin_tokens (token);
CREATE INDEX idx_autologin_expires ON menuca_v3.autologin_tokens (expires_at);

COMMENT ON TABLE menuca_v3.autologin_tokens IS 'Remember me tokens (active only)';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SUCCESS!
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DO $$
BEGIN
    RAISE NOTICE '✅ V3 Schema Created Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables Created:';
    RAISE NOTICE '  - menuca_v3.users (customer accounts)';
    RAISE NOTICE '  - menuca_v3.admin_users (restaurant staff)';
    RAISE NOTICE '  - menuca_v3.admin_user_restaurants (junction)';
    RAISE NOTICE '  - menuca_v3.user_addresses (delivery addresses)';
    RAISE NOTICE '  - menuca_v3.user_favorite_restaurants';
    RAISE NOTICE '  - menuca_v3.password_reset_tokens';
    RAISE NOTICE '  - menuca_v3.autologin_tokens';
    RAISE NOTICE '';
    RAISE NOTICE 'Ready for Phase 3: Data Transformation';
END $$;
