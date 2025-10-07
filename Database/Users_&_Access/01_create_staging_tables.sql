-- ================================================================
-- Users & Access Entity - Phase 1: Create Staging Tables
-- ================================================================
-- Purpose: Load V1/V2 user data into staging for analysis & transformation
-- Created: 2025-10-06
-- Strategy: Active users only (96% reduction from original dataset)
--
-- Key Filters Applied:
-- - V1 users: lastLogin > '2020-01-01' (skip 433k inactive users)
-- - V2 tokens: expires_at > NOW() (skip expired tokens)
-- - V2 sessions: SKIP entirely (start fresh)
-- ================================================================

-- Create staging schema if not exists
CREATE SCHEMA IF NOT EXISTS staging;

-- ================================================================
-- V1 STAGING TABLES
-- ================================================================

-- ----------------------------------------------------------------
-- V1: users (Customer accounts) - FILTERED for active users only
-- ----------------------------------------------------------------
-- Source: menuca_v1_users.csv (14,292 rows - main)
--         menuca_v1_users_part1/2/3.csv (427,994 rows - split files)
-- Filter: lastLogin > '2020-01-01' (active users only)
-- Expected: ~10,000-15,000 rows after filtering

DROP TABLE IF EXISTS staging.v1_users CASCADE;
CREATE TABLE staging.v1_users (
    id INTEGER,
    isActive VARCHAR(1),
    fname VARCHAR(50),
    lname VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(255),
    passwordChangedOn TIMESTAMP,
    language CHAR(2),
    newsletter VARCHAR(1),
    vegan_newsletter VARCHAR(1),
    isEmailConfirmed VARCHAR(1),
    lastLogin TIMESTAMP,
    loginCount INTEGER,
    autologinCode VARCHAR(40),
    restaurant INTEGER,
    globalUser VARCHAR(1),
    createdFrom VARCHAR(1),
    creationip VARCHAR(15),
    forwardedfor VARCHAR(15),
    firstMailFeedback VARCHAR(1),
    unsub INTEGER,
    sent INTEGER,
    opens INTEGER,
    clicks INTEGER,
    total_opens INTEGER,
    total_clicks INTEGER,
    last_send INTEGER,
    last_click INTEGER,
    last_open INTEGER,
    creditValue FLOAT,
    creditStartOn INTEGER,
    fbid BIGINT,
    storageToken VARCHAR(255),
    fsi VARCHAR(255),
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW(),
    _source_file VARCHAR(50)
);

-- Index for filtering active users
CREATE INDEX idx_v1_users_lastlogin ON staging.v1_users(lastLogin);
CREATE INDEX idx_v1_users_email ON staging.v1_users(LOWER(TRIM(email)));
CREATE INDEX idx_v1_users_active ON staging.v1_users(isActive) WHERE isActive = 'y';

COMMENT ON TABLE staging.v1_users IS 'V1 customer accounts - FILTERED for lastLogin > 2020-01-01 (active users only)';

-- ----------------------------------------------------------------
-- V1: callcenter_users (Call center staff)
-- ----------------------------------------------------------------
-- Source: menuca_v1_callcenter_users.csv (38 rows)
-- Filter: None (all staff accounts needed)

DROP TABLE IF EXISTS staging.v1_callcenter_users CASCADE;
CREATE TABLE staging.v1_callcenter_users (
    id INTEGER,
    fname VARCHAR(25),
    lname VARCHAR(25),
    email VARCHAR(50),
    password VARCHAR(255),
    last_login TIMESTAMP,
    is_active VARCHAR(1),
    rank SMALLINT,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v1_callcenter_email ON staging.v1_callcenter_users(LOWER(TRIM(email)));

COMMENT ON TABLE staging.v1_callcenter_users IS 'V1 call center staff accounts - merge into admin_users with role=callcenter';

-- ----------------------------------------------------------------
-- V1: pass_reset - SKIP (decision: active V2 tokens only)
-- ----------------------------------------------------------------
-- Original: 203,018 rows
-- Decision: Skip all V1 tokens (5+ years old, not relevant)

-- ================================================================
-- V2 STAGING TABLES
-- ================================================================

-- ----------------------------------------------------------------
-- V2: site_users (Customer accounts)
-- ----------------------------------------------------------------
-- Source: menuca_v2_site_users.csv (8,943 rows)
-- Filter: None (all V2 users are active)

DROP TABLE IF EXISTS staging.v2_site_users CASCADE;
CREATE TABLE staging.v2_site_users (
    id INTEGER,
    active VARCHAR(1),
    fname VARCHAR(45),
    lname VARCHAR(45),
    email VARCHAR(45),
    password VARCHAR(125),
    language_id INTEGER,
    gender VARCHAR(6),
    locale VARCHAR(6),
    oauth_provider VARCHAR(125),
    oauth_uid VARCHAR(125),
    picture_url VARCHAR(255),
    profile_url VARCHAR(255),
    created_at TIMESTAMP,
    newsletter VARCHAR(1),
    sms VARCHAR(1),
    origin_restaurant SMALLINT,
    last_login TIMESTAMP,
    disabled_by INTEGER,
    disabled_at TIMESTAMP,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_site_users_email ON staging.v2_site_users(LOWER(TRIM(email)));
CREATE INDEX idx_v2_site_users_active ON staging.v2_site_users(active) WHERE active = 'y';

COMMENT ON TABLE staging.v2_site_users IS 'V2 customer accounts - all active (last 5 years)';

-- ----------------------------------------------------------------
-- V2: admin_users (Platform/restaurant admins)
-- ----------------------------------------------------------------
-- Source: menuca_v2_admin_users.csv (53 rows)
-- Filter: None (all needed)

DROP TABLE IF EXISTS staging.v2_admin_users CASCADE;
CREATE TABLE staging.v2_admin_users (
    id INTEGER,
    preferred_language INTEGER,
    fname VARCHAR(45),
    lname VARCHAR(45),
    email VARCHAR(45),
    password VARCHAR(125),
    "group" INTEGER, -- Reserved keyword, needs quotes
    receive_statements VARCHAR(1),
    phone VARCHAR(20),
    active VARCHAR(1),
    override_restaurants VARCHAR(1),
    settings TEXT, -- JSON stored as text initially
    billing_info TEXT,
    allow_login_to_sites VARCHAR(1),
    last_activity TIMESTAMP,
    created_by INTEGER,
    created_at TIMESTAMP,
    disabled_by INTEGER,
    disabled_at TIMESTAMP,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_admin_users_email ON staging.v2_admin_users(LOWER(TRIM(email)));
CREATE INDEX idx_v2_admin_users_active ON staging.v2_admin_users(active) WHERE active = 'y';

COMMENT ON TABLE staging.v2_admin_users IS 'V2 platform/restaurant admin accounts';

-- ----------------------------------------------------------------
-- V2: admin_users_restaurants (Admin-restaurant junction)
-- ----------------------------------------------------------------
-- Source: menuca_v2_admin_users_restaurants.csv (100 rows)
-- Filter: None

DROP TABLE IF EXISTS staging.v2_admin_users_restaurants CASCADE;
CREATE TABLE staging.v2_admin_users_restaurants (
    id INTEGER,
    user_id INTEGER,
    restaurant_id INTEGER,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_admin_rest_userid ON staging.v2_admin_users_restaurants(user_id);
CREATE INDEX idx_v2_admin_rest_restid ON staging.v2_admin_users_restaurants(restaurant_id);

COMMENT ON TABLE staging.v2_admin_users_restaurants IS 'V2 admin-restaurant many-to-many relationship';

-- ----------------------------------------------------------------
-- V2: site_users_delivery_addresses (User saved addresses)
-- ----------------------------------------------------------------
-- Source: menuca_v2_site_users_delivery_addresses.csv (11,710 rows)
-- Filter: None (need all addresses for active users)

DROP TABLE IF EXISTS staging.v2_site_users_delivery_addresses CASCADE;
CREATE TABLE staging.v2_site_users_delivery_addresses (
    id INTEGER,
    active VARCHAR(1),
    place_id VARCHAR(255),
    user_id INTEGER,
    lat DECIMAL(20,17),
    lng DECIMAL(20,17),
    street VARCHAR(125),
    apartment VARCHAR(15),
    zip VARCHAR(7),
    ringer VARCHAR(45),
    extension VARCHAR(6),
    special_instructions VARCHAR(255),
    city VARCHAR(50),
    province VARCHAR(50),
    phone VARCHAR(15),
    missingData VARCHAR(1),
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_addresses_userid ON staging.v2_site_users_delivery_addresses(user_id);
CREATE INDEX idx_v2_addresses_city ON staging.v2_site_users_delivery_addresses(LOWER(TRIM(city)));
CREATE INDEX idx_v2_addresses_province ON staging.v2_site_users_delivery_addresses(LOWER(TRIM(province)));

COMMENT ON TABLE staging.v2_site_users_delivery_addresses IS 'V2 user saved delivery addresses - needs city/province lookup';

-- ----------------------------------------------------------------
-- V2: reset_codes (Password reset tokens) - FILTERED
-- ----------------------------------------------------------------
-- Source: menuca_v2_reset_codes.csv (3,630 rows)
-- Filter: expires_at > NOW() (active tokens only)
-- Expected: ~500-1,000 rows after filtering

DROP TABLE IF EXISTS staging.v2_reset_codes CASCADE;
CREATE TABLE staging.v2_reset_codes (
    id INTEGER,
    code VARCHAR(15),
    user_id INTEGER,
    added_at TIMESTAMP,
    expires_at TIMESTAMP,
    request_ip VARCHAR(15),
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_reset_userid ON staging.v2_reset_codes(user_id);
CREATE INDEX idx_v2_reset_expires ON staging.v2_reset_codes(expires_at);

COMMENT ON TABLE staging.v2_reset_codes IS 'V2 password reset tokens - FILTERED for expires_at > NOW() (active only)';

-- ----------------------------------------------------------------
-- V2: site_users_autologins (Remember me tokens) - FILTERED
-- ----------------------------------------------------------------
-- Source: menuca_v2_site_users_autologins.csv (891 rows)
-- Filter: expire > NOW() (active tokens only)
-- Expected: ~300-500 rows after filtering

DROP TABLE IF EXISTS staging.v2_site_users_autologins CASCADE;
CREATE TABLE staging.v2_site_users_autologins (
    id INTEGER,
    user_login VARCHAR(125),
    selector VARCHAR(255),
    password VARCHAR(255), -- Hashed validator
    expire TIMESTAMP,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_autologin_user ON staging.v2_site_users_autologins(user_login);
CREATE INDEX idx_v2_autologin_expires ON staging.v2_site_users_autologins(expire);

COMMENT ON TABLE staging.v2_site_users_autologins IS 'V2 remember me tokens - FILTERED for expire > NOW() (active only)';

-- ----------------------------------------------------------------
-- V2: site_users_favorite_restaurants (User favorites)
-- ----------------------------------------------------------------
-- Source: menuca_v2_site_users_favorite_restaurants.csv (2 rows)
-- Note: Defer FK validation until Restaurant Management completes

DROP TABLE IF EXISTS staging.v2_site_users_favorite_restaurants CASCADE;
CREATE TABLE staging.v2_site_users_favorite_restaurants (
    id INTEGER,
    user_id INTEGER,
    restaurant_id INTEGER,
    created_at TIMESTAMP,
    removed_at TIMESTAMP,
    enabled VARCHAR(1),
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_v2_favorites_userid ON staging.v2_site_users_favorite_restaurants(user_id);

COMMENT ON TABLE staging.v2_site_users_favorite_restaurants IS 'V2 user favorite restaurants - FK validation deferred';

-- ----------------------------------------------------------------
-- V2: site_users_fb (Facebook OAuth profiles)
-- ----------------------------------------------------------------
-- Source: menuca_v2_site_users_fb.csv (1 row)
-- Note: May merge into site_users table (OAuth fields already present)

DROP TABLE IF EXISTS staging.v2_site_users_fb CASCADE;
CREATE TABLE staging.v2_site_users_fb (
    id INTEGER,
    oauth_provider VARCHAR(255),
    oauth_uid VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    gender VARCHAR(10),
    locale VARCHAR(10),
    picture_url VARCHAR(255),
    profile_url VARCHAR(255),
    created TIMESTAMP,
    modified TIMESTAMP,
    
    -- Metadata
    _loaded_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE staging.v2_site_users_fb IS 'V2 Facebook OAuth profiles - consider merging into site_users';

-- ----------------------------------------------------------------
-- V2: ci_sessions - SKIP (decision: start fresh)
-- ----------------------------------------------------------------
-- Original: 111 rows
-- Decision: Skip all sessions (ephemeral data, start fresh)

-- ----------------------------------------------------------------
-- V2: login_attempts - SKIP (empty table)
-- ----------------------------------------------------------------
-- Original: 0 rows
-- Decision: Skip (table is empty, create structure only for V3)

-- ================================================================
-- SUMMARY
-- ================================================================

-- Total staging tables created: 10
-- V1: 2 tables (users, callcenter_users)
-- V2: 8 tables (site_users, admin_users, addresses, tokens, etc.)
--
-- Skipped tables:
-- - V1 pass_reset (203k rows - too old)
-- - V2 ci_sessions (111 rows - ephemeral)
-- - V2 login_attempts (0 rows - empty)
--
-- Estimated total rows after filters: ~28,000 rows
-- Down from original: 670,792 rows (96% reduction!)

SELECT 
    'Staging tables created successfully!' as status,
    10 as tables_created,
    '~28,000 rows expected' as estimated_data,
    '96% reduction from original' as optimization;
