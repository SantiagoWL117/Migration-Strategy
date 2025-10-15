-- ============================================================================
-- Phase 5: Create V3 Production Schema for Vendors & Franchises
-- ============================================================================
-- Purpose: Create production tables in menuca_v3 schema for vendor management
-- Target: menuca_v3 (PostgreSQL/Supabase)
-- Security: Includes RLS policies for secure multi-tenant access
-- Integration: Links to Supabase Edge Function for commission calculations
-- ============================================================================

-- Ensure menuca_v3 schema exists
CREATE SCHEMA IF NOT EXISTS menuca_v3;

-- ============================================================================
-- 1. VENDORS TABLE
-- ============================================================================
-- Purpose: Core vendor/franchise entity (replaces V1 vendors + V2 admin_users group=12)
-- Relationships: Has many restaurants, generates reports
-- ============================================================================

DROP TABLE IF EXISTS menuca_v3.vendors CASCADE;

CREATE TABLE menuca_v3.vendors (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- V2 legacy ID (for migration mapping)
    legacy_v2_admin_user_id INTEGER UNIQUE,
    
    -- Vendor identity
    business_name VARCHAR(255) NOT NULL,
    contact_first_name VARCHAR(100) NOT NULL,
    contact_last_name VARCHAR(100) NOT NULL,
    
    -- Authentication (linked to Supabase Auth)
    email VARCHAR(255) UNIQUE NOT NULL,
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    
    -- Contact information
    phone VARCHAR(50),
    billing_address TEXT,
    billing_contact_info JSONB,  -- Flexible billing details
    
    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    disabled_at TIMESTAMPTZ,
    disabled_by UUID REFERENCES auth.users(id),
    
    -- Settings
    preferred_language VARCHAR(10) DEFAULT 'en',
    receives_statements BOOLEAN DEFAULT true,
    settings JSONB DEFAULT '{}',  -- Additional vendor settings
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    last_activity_at TIMESTAMPTZ,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',  -- Extensible metadata storage
    
    -- Constraints
    CONSTRAINT chk_vendor_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_vendor_business_name_length CHECK (LENGTH(business_name) >= 2)
);

-- Indexes
CREATE INDEX idx_vendors_email ON menuca_v3.vendors(email);
CREATE INDEX idx_vendors_active ON menuca_v3.vendors(is_active);
CREATE INDEX idx_vendors_auth_user ON menuca_v3.vendors(auth_user_id);
CREATE INDEX idx_vendors_legacy_id ON menuca_v3.vendors(legacy_v2_admin_user_id);
CREATE INDEX idx_vendors_created_at ON menuca_v3.vendors(created_at);

-- Comments
COMMENT ON TABLE menuca_v3.vendors IS 'Vendors and franchises managing restaurants with revenue-sharing agreements';
COMMENT ON COLUMN menuca_v3.vendors.legacy_v2_admin_user_id IS 'Original V2 admin_users.id (group=12) for migration mapping';
COMMENT ON COLUMN menuca_v3.vendors.auth_user_id IS 'FK to Supabase Auth users for authentication';
COMMENT ON COLUMN menuca_v3.vendors.billing_contact_info IS 'JSONB: invoice_email, tax_id, payment_method, etc.';
COMMENT ON COLUMN menuca_v3.vendors.settings IS 'JSONB: report_frequency, notification_preferences, etc.';

-- ============================================================================
-- 2. VENDOR_RESTAURANTS TABLE (Junction)
-- ============================================================================
-- Purpose: Links vendors to restaurants they manage (M:N relationship)
-- Relationships: vendors → restaurants (with commission config)
-- ============================================================================

DROP TABLE IF EXISTS menuca_v3.vendor_restaurants CASCADE;

CREATE TABLE menuca_v3.vendor_restaurants (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- V2 legacy ID
    legacy_v2_id INTEGER UNIQUE,
    
    -- Relationships
    vendor_id UUID NOT NULL REFERENCES menuca_v3.vendors(id) ON DELETE CASCADE,
    restaurant_uuid UUID NOT NULL REFERENCES menuca_v3.restaurants(uuid) ON DELETE CASCADE,
    
    -- Commission configuration
    commission_template VARCHAR(50) NOT NULL,  -- 'percent_commission', 'mazen_milanos'
    last_commission_rate_used DECIMAL(10,2),  -- Last used rate (for reference and fallback)
    last_commission_type_used commission_rate_type DEFAULT 'percentage',
    
    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    
    -- Period tracking
    assignment_start_date DATE DEFAULT CURRENT_DATE NOT NULL,
    assignment_end_date DATE,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    
    -- Metadata
    metadata JSONB DEFAULT '{}',  -- Commission overrides, notes, etc.
    
    -- Constraints
    CONSTRAINT uq_vendor_restaurant_active UNIQUE (vendor_id, restaurant_uuid, is_active),
    CONSTRAINT chk_commission_template_valid CHECK (
        commission_template IN ('percent_commission', 'mazen_milanos')
    ),
    CONSTRAINT chk_assignment_dates CHECK (
        assignment_end_date IS NULL OR assignment_end_date >= assignment_start_date
    )
);

-- Indexes
CREATE INDEX idx_vendor_restaurants_vendor ON menuca_v3.vendor_restaurants(vendor_id);
CREATE INDEX idx_vendor_restaurants_restaurant ON menuca_v3.vendor_restaurants(restaurant_uuid);
CREATE INDEX idx_vendor_restaurants_template ON menuca_v3.vendor_restaurants(commission_template);
CREATE INDEX idx_vendor_restaurants_active ON menuca_v3.vendor_restaurants(is_active);
CREATE INDEX idx_vendor_restaurants_dates ON menuca_v3.vendor_restaurants(assignment_start_date, assignment_end_date);

-- Comments
COMMENT ON TABLE menuca_v3.vendor_restaurants IS 'Vendor-restaurant assignments. Commission rates are provided by client at calculation time.';
COMMENT ON COLUMN menuca_v3.vendor_restaurants.restaurant_uuid IS 'FK to menuca_v3.restaurants.uuid';
COMMENT ON COLUMN menuca_v3.vendor_restaurants.commission_template IS 'Template name: percent_commission or mazen_milanos';
COMMENT ON COLUMN menuca_v3.vendor_restaurants.last_commission_rate_used IS 'Last used commission rate - used for reference and as fallback if client does not provide rate';
COMMENT ON COLUMN menuca_v3.vendor_restaurants.last_commission_type_used IS 'Last used commission type (percentage or fixed)';

-- ============================================================================
-- 3. VENDOR_COMMISSION_REPORTS TABLE
-- ============================================================================
-- Purpose: Historical and generated commission reports
-- Integration: Results generated by Edge Function calculate-vendor-commission
-- ============================================================================

DROP TABLE IF EXISTS menuca_v3.vendor_commission_reports CASCADE;

CREATE TABLE menuca_v3.vendor_commission_reports (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- V2 legacy ID
    legacy_v2_report_id INTEGER UNIQUE,
    
    -- Relationships
    vendor_id UUID NOT NULL REFERENCES menuca_v3.vendors(id) ON DELETE CASCADE,
    restaurant_uuid UUID NOT NULL REFERENCES menuca_v3.restaurants(uuid) ON DELETE CASCADE,
    
    -- Report identification
    statement_number INTEGER NOT NULL,  -- Incremental per vendor
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    
    -- Commission calculation results (from Edge Function)
    calculation_template VARCHAR(50) NOT NULL,
    calculation_input JSONB NOT NULL,  -- Input parameters sent to Edge Function
    calculation_result JSONB NOT NULL,  -- Result returned from Edge Function
    
    -- Financial summary (denormalized for quick access)
    total_order_amount DECIMAL(10,2) NOT NULL,
    vendor_commission_amount DECIMAL(10,2) NOT NULL,
    platform_fee_amount DECIMAL(10,2) NOT NULL,
    menu_ottawa_amount DECIMAL(10,2),  -- For percent_commission template
    
    -- Commission rate tracking (historical - actual rate used in this calculation)
    commission_rate_used DECIMAL(10,2),  -- The actual rate used for THIS report
    commission_type_used commission_rate_type DEFAULT 'percentage',  -- percentage or fixed
    
    -- Report metadata
    report_generated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    report_generated_by UUID REFERENCES auth.users(id),
    pdf_file_url TEXT,  -- S3/Supabase Storage URL for generated PDF
    
    -- Status
    report_status VARCHAR(20) DEFAULT 'draft' CHECK (
        report_status IN ('draft', 'finalized', 'sent', 'paid', 'cancelled')
    ),
    sent_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',  -- Notes, adjustments, payment details
    
    -- Constraints
    CONSTRAINT chk_report_period CHECK (report_period_end >= report_period_start),
    CONSTRAINT chk_amounts_positive CHECK (
        total_order_amount >= 0 AND 
        vendor_commission_amount >= 0 AND 
        platform_fee_amount >= 0
    )
    -- NOTE: No unique constraint on statement_number - multiple reports per statement (one per restaurant)
);

-- Indexes
CREATE INDEX idx_commission_reports_vendor ON menuca_v3.vendor_commission_reports(vendor_id);
CREATE INDEX idx_commission_reports_restaurant ON menuca_v3.vendor_commission_reports(restaurant_uuid);
CREATE INDEX idx_commission_reports_period ON menuca_v3.vendor_commission_reports(report_period_start, report_period_end);
CREATE INDEX idx_commission_reports_status ON menuca_v3.vendor_commission_reports(report_status);
CREATE INDEX idx_commission_reports_statement ON menuca_v3.vendor_commission_reports(vendor_id, statement_number);
CREATE INDEX idx_commission_reports_generated ON menuca_v3.vendor_commission_reports(report_generated_at);

-- Comments
COMMENT ON TABLE menuca_v3.vendor_commission_reports IS 'Commission calculation reports generated via Edge Function. Each statement number contains multiple reports (one per restaurant).';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.restaurant_uuid IS 'FK to menuca_v3.restaurants.uuid';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.statement_number IS 'Monthly batch identifier (not unique - multiple restaurants share same statement number)';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.calculation_template IS 'Template used: percent_commission or mazen_milanos';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.calculation_input IS 'JSONB input sent to Edge Function calculate-vendor-commission';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.calculation_result IS 'JSONB result from Edge Function with commission breakdown';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.commission_rate_used IS 'Historical record: the actual commission rate used for THIS specific calculation';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.commission_type_used IS 'Historical record: whether the rate was percentage or fixed amount';
COMMENT ON COLUMN menuca_v3.vendor_commission_reports.report_status IS 'Report lifecycle: draft → finalized → sent → paid';

-- ============================================================================
-- 4. VENDOR_STATEMENT_NUMBERS TABLE
-- ============================================================================
-- Purpose: Track incremental statement numbers per vendor
-- Usage: Ensures sequential numbering of reports
-- ============================================================================

DROP TABLE IF EXISTS menuca_v3.vendor_statement_numbers CASCADE;

CREATE TABLE menuca_v3.vendor_statement_numbers (
    -- Primary key
    vendor_id UUID PRIMARY KEY REFERENCES menuca_v3.vendors(id) ON DELETE CASCADE,
    
    -- Statement tracking
    current_statement_number INTEGER DEFAULT 0 NOT NULL,
    last_statement_generated_at TIMESTAMPTZ,
    
    -- PDF file prefix (e.g., "menuottawa_statement_")
    pdf_file_prefix VARCHAR(125) DEFAULT 'vendor_statement_',
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT chk_statement_number_positive CHECK (current_statement_number >= 0)
);

-- Comments
COMMENT ON TABLE menuca_v3.vendor_statement_numbers IS 'Tracks incremental statement numbers per vendor';
COMMENT ON COLUMN menuca_v3.vendor_statement_numbers.current_statement_number IS 'Last used statement number (next report will be current + 1)';

-- ============================================================================
-- 5. UPDATED_AT TRIGGER FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables
CREATE TRIGGER update_vendors_updated_at
    BEFORE UPDATE ON menuca_v3.vendors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vendor_restaurants_updated_at
    BEFORE UPDATE ON menuca_v3.vendor_restaurants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_commission_reports_updated_at
    BEFORE UPDATE ON menuca_v3.vendor_commission_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_statement_numbers_updated_at
    BEFORE UPDATE ON menuca_v3.vendor_statement_numbers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE menuca_v3.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.vendor_restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.vendor_commission_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.vendor_statement_numbers ENABLE ROW LEVEL SECURITY;

-- Vendors: Can view/edit their own profile
CREATE POLICY "Vendors can view own profile"
    ON menuca_v3.vendors
    FOR SELECT
    USING (auth_user_id = auth.uid());

CREATE POLICY "Vendors can update own profile"
    ON menuca_v3.vendors
    FOR UPDATE
    USING (auth_user_id = auth.uid());

-- Vendor Restaurants: Vendors can view their assignments
CREATE POLICY "Vendors can view own restaurant assignments"
    ON menuca_v3.vendor_restaurants
    FOR SELECT
    USING (vendor_id IN (
        SELECT id FROM menuca_v3.vendors WHERE auth_user_id = auth.uid()
    ));

-- Commission Reports: Vendors can view their own reports
CREATE POLICY "Vendors can view own commission reports"
    ON menuca_v3.vendor_commission_reports
    FOR SELECT
    USING (vendor_id IN (
        SELECT id FROM menuca_v3.vendors WHERE auth_user_id = auth.uid()
    ));

-- Statement Numbers: Vendors can view their own statement tracking
CREATE POLICY "Vendors can view own statement numbers"
    ON menuca_v3.vendor_statement_numbers
    FOR SELECT
    USING (vendor_id IN (
        SELECT id FROM menuca_v3.vendors WHERE auth_user_id = auth.uid()
    ));

-- Admin policies (for service role / admin users)
-- These policies would be refined based on your admin role structure

-- ============================================================================
-- 7. HELPER FUNCTIONS
-- ============================================================================

-- Function to get next statement number for a vendor
CREATE OR REPLACE FUNCTION menuca_v3.get_next_statement_number(p_vendor_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_next_number INTEGER;
BEGIN
    -- Insert or update statement number record
    INSERT INTO menuca_v3.vendor_statement_numbers (vendor_id, current_statement_number)
    VALUES (p_vendor_id, 1)
    ON CONFLICT (vendor_id) DO UPDATE
    SET current_statement_number = vendor_statement_numbers.current_statement_number + 1,
        last_statement_generated_at = NOW(),
        updated_at = NOW()
    RETURNING current_statement_number INTO v_next_number;
    
    RETURN v_next_number;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.get_next_statement_number IS 'Atomically increments and returns next statement number for vendor';

-- Function to prepare payload for Edge Function commission calculation
CREATE OR REPLACE FUNCTION menuca_v3.prepare_commission_calculation(
    p_template_name VARCHAR(50),
    p_total DECIMAL(10,2),
    p_restaurant_commission DECIMAL(10,2),
    p_commission_type VARCHAR(20),
    p_menuottawa_share DECIMAL(10,2),
    p_vendor_id UUID,
    p_restaurant_uuid UUID
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_restaurant_name VARCHAR(255);
    v_restaurant_address TEXT;
BEGIN
    -- Get restaurant details
    SELECT name INTO v_restaurant_name
    FROM menuca_v3.restaurants
    WHERE uuid = p_restaurant_uuid;
    
    -- Get restaurant address (assuming you have a locations table or address field)
    -- For now, using placeholder
    v_restaurant_address := 'Address from restaurants table';
    
    -- Build input payload for Edge Function
    v_result := jsonb_build_object(
        'template_name', p_template_name,
        'total', p_total,
        'restaurant_commission', p_restaurant_commission,
        'commission_type', COALESCE(p_commission_type, 'percentage'),
        'menuottawa_share', p_menuottawa_share,
        'vendor_id', p_vendor_id::text,
        'restaurant_id', p_restaurant_uuid::text,
        'restaurant_name', v_restaurant_name,
        'restaurant_address', v_restaurant_address
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.prepare_commission_calculation IS 'Prepares JSONB payload for Edge Function calculate-vendor-commission';

-- ============================================================================
-- 8. VIEWS FOR REPORTING
-- ============================================================================

-- View: Active vendor-restaurant relationships
CREATE OR REPLACE VIEW menuca_v3.v_active_vendor_restaurants AS
SELECT 
    vr.id,
    vr.vendor_id,
    v.business_name as vendor_business_name,
    v.contact_first_name || ' ' || v.contact_last_name as vendor_contact_name,
    v.email as vendor_email,
    vr.restaurant_uuid,
    r.name as restaurant_name,
    vr.commission_template,
    vr.commission_rate,
    vr.commission_type,
    vr.fixed_platform_fee,
    vr.delivery_commission_extra,
    vr.assignment_start_date,
    vr.created_at
FROM menuca_v3.vendor_restaurants vr
JOIN menuca_v3.vendors v ON v.id = vr.vendor_id
JOIN menuca_v3.restaurants r ON r.uuid = vr.restaurant_uuid
WHERE vr.is_active = true 
  AND v.is_active = true
  AND (vr.assignment_end_date IS NULL OR vr.assignment_end_date >= CURRENT_DATE);

COMMENT ON VIEW menuca_v3.v_active_vendor_restaurants IS 'Active vendor-restaurant relationships with commission details';

-- View: Vendor report summary
CREATE OR REPLACE VIEW menuca_v3.v_vendor_report_summary AS
SELECT 
    vcr.id,
    vcr.vendor_id,
    v.business_name as vendor_name,
    vcr.restaurant_uuid,
    r.name as restaurant_name,
    vcr.statement_number,
    vcr.report_period_start,
    vcr.report_period_end,
    vcr.calculation_template,
    vcr.total_order_amount,
    vcr.vendor_commission_amount,
    vcr.platform_fee_amount,
    vcr.report_status,
    vcr.report_generated_at,
    vcr.sent_at,
    vcr.paid_at
FROM menuca_v3.vendor_commission_reports vcr
JOIN menuca_v3.vendors v ON v.id = vcr.vendor_id
JOIN menuca_v3.restaurants r ON r.uuid = vcr.restaurant_uuid
ORDER BY vcr.report_generated_at DESC;

COMMENT ON VIEW menuca_v3.v_vendor_report_summary IS 'Vendor commission report summary for dashboards';

-- ============================================================================
-- TRIGGERS: Auto-update last_commission_rate_used
-- ============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.update_last_commission_rate()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE menuca_v3.vendor_restaurants
  SET 
    last_commission_rate_used = NEW.commission_rate_used,
    last_commission_type_used = NEW.commission_type_used,
    updated_at = NOW()
  WHERE vendor_id = NEW.vendor_id
    AND restaurant_uuid = NEW.restaurant_uuid
    AND is_active = true;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_last_commission_rate
  AFTER INSERT OR UPDATE OF commission_rate_used, commission_type_used
  ON menuca_v3.vendor_commission_reports
  FOR EACH ROW
  WHEN (NEW.commission_rate_used IS NOT NULL)
  EXECUTE FUNCTION menuca_v3.update_last_commission_rate();

COMMENT ON FUNCTION menuca_v3.update_last_commission_rate() IS 
'Automatically updates last_commission_rate_used in vendor_restaurants when a report is saved';

-- ============================================================================
-- End of V3 Schema Creation
-- ============================================================================
