-- ============================================================================
-- Historical Analytics: restaurant_admin_users
-- ============================================================================
-- Purpose: Extract valuable historical metrics before table deletion
-- Use for reporting, trend analysis, and user engagement insights
-- ============================================================================

-- Analytics 1: User Engagement Summary
-- ============================================================================
SELECT
    'User Engagement Summary' as analytics_section,
    COUNT(*) as total_admins,
    COUNT(DISTINCT restaurant_id) as unique_restaurants,
    AVG(login_count)::numeric(10,2) as avg_logins_per_admin,
    MAX(login_count) as max_logins,
    MIN(login_count) as min_logins,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY login_count) as median_logins,
    COUNT(*) FILTER (WHERE login_count > 100) as highly_engaged_admins,
    COUNT(*) FILTER (WHERE login_count > 1000) as super_users
FROM menuca_v3.restaurant_admin_users;

-- Analytics 2: Account Age Distribution
-- ============================================================================
SELECT
    'Account Age Distribution' as analytics_section,
    CASE
        WHEN age_days < 365 THEN '< 1 year'
        WHEN age_days < 730 THEN '1-2 years'
        WHEN age_days < 1825 THEN '2-5 years'
        WHEN age_days < 3650 THEN '5-10 years'
        ELSE '10+ years'
    END as account_age_range,
    COUNT(*) as admin_count,
    AVG(login_count)::numeric(10,2) as avg_logins,
    AVG(age_days)::numeric(10,2) as avg_age_days
FROM (
    SELECT
        id,
        login_count,
        EXTRACT(EPOCH FROM (COALESCE(last_login_at, now()) - created_at)) / 86400 as age_days
    FROM menuca_v3.restaurant_admin_users
) subquery
GROUP BY account_age_range
ORDER BY MIN(age_days);

-- Analytics 3: Login Activity Timeline
-- ============================================================================
SELECT
    'Login Activity Timeline' as analytics_section,
    DATE_TRUNC('year', last_login_at) as login_year,
    COUNT(*) as admins_logged_in,
    SUM(login_count) as total_logins,
    AVG(login_count)::numeric(10,2) as avg_logins_per_admin
FROM menuca_v3.restaurant_admin_users
WHERE last_login_at IS NOT NULL
GROUP BY DATE_TRUNC('year', last_login_at)
ORDER BY login_year DESC;

-- Analytics 4: Top 20 Most Active Admins
-- ============================================================================
SELECT
    'Top 20 Most Active Admins' as analytics_section,
    rau.id,
    rau.email,
    rau.restaurant_id,
    r.name as restaurant_name,
    rau.login_count,
    rau.created_at as account_created,
    rau.last_login_at,
    EXTRACT(EPOCH FROM (COALESCE(rau.last_login_at, now()) - rau.created_at)) / 86400 as account_age_days,
    ROUND(rau.login_count::numeric / NULLIF(EXTRACT(EPOCH FROM (COALESCE(rau.last_login_at, now()) - rau.created_at)) / 86400, 0), 2) as avg_logins_per_day
FROM menuca_v3.restaurant_admin_users rau
LEFT JOIN menuca_v3.restaurants r ON rau.restaurant_id = r.id
ORDER BY rau.login_count DESC
LIMIT 20;

-- Analytics 5: Inactive Admins
-- ============================================================================
-- Admins who never logged in or haven't logged in for over a year
SELECT
    'Inactive Admins Analysis' as analytics_section,
    COUNT(*) FILTER (WHERE last_login_at IS NULL) as never_logged_in,
    COUNT(*) FILTER (WHERE last_login_at < now() - interval '1 year') as inactive_1year,
    COUNT(*) FILTER (WHERE last_login_at < now() - interval '2 years') as inactive_2years,
    COUNT(*) FILTER (WHERE last_login_at < now() - interval '5 years') as inactive_5years,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '1 month') as active_last_month,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '3 months') as active_last_quarter
FROM menuca_v3.restaurant_admin_users;

-- Analytics 6: Restaurant Admin Coverage
-- ============================================================================
-- How many admins does each restaurant have?
SELECT
    'Restaurant Admin Coverage' as analytics_section,
    restaurant_id,
    r.name as restaurant_name,
    COUNT(*) as admin_count,
    SUM(login_count) as total_logins,
    MAX(last_login_at) as most_recent_login,
    array_agg(email ORDER BY login_count DESC) as admin_emails
FROM menuca_v3.restaurant_admin_users rau
LEFT JOIN menuca_v3.restaurants r ON rau.restaurant_id = r.id
GROUP BY restaurant_id, r.name
ORDER BY admin_count DESC, total_logins DESC;

-- Analytics 7: User Type Distribution
-- ============================================================================
SELECT
    'User Type Distribution' as analytics_section,
    user_type,
    COUNT(*) as count,
    AVG(login_count)::numeric(10,2) as avg_logins,
    COUNT(*) FILTER (WHERE is_active = true) as active_count,
    COUNT(*) FILTER (WHERE is_active = false) as inactive_count
FROM menuca_v3.restaurant_admin_users
GROUP BY user_type
ORDER BY count DESC;

-- Analytics 8: Login Frequency Buckets
-- ============================================================================
SELECT
    'Login Frequency Buckets' as analytics_section,
    CASE
        WHEN login_count = 0 THEN '0 - Never logged in'
        WHEN login_count <= 10 THEN '1-10 - Very Low'
        WHEN login_count <= 50 THEN '11-50 - Low'
        WHEN login_count <= 100 THEN '51-100 - Moderate'
        WHEN login_count <= 500 THEN '101-500 - Regular'
        WHEN login_count <= 1000 THEN '501-1000 - High'
        WHEN login_count <= 5000 THEN '1001-5000 - Very High'
        ELSE '5000+ - Power User'
    END as login_frequency_bucket,
    COUNT(*) as admin_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM menuca_v3.restaurant_admin_users
GROUP BY login_frequency_bucket
ORDER BY MIN(login_count);

-- Analytics 9: Recent Activity Snapshot
-- ============================================================================
-- Activity in the last 6 months (important for deletion decision)
SELECT
    'Recent Activity (Last 6 Months)' as analytics_section,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '1 month') as logins_last_month,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '3 months') as logins_last_3_months,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '6 months') as logins_last_6_months,
    MAX(last_login_at) as most_recent_login_overall,
    COUNT(DISTINCT restaurant_id) FILTER (WHERE last_login_at >= now() - interval '1 month') as active_restaurants_last_month
FROM menuca_v3.restaurant_admin_users;

-- Analytics 10: Create Permanent Analytics Table
-- ============================================================================
-- Store aggregated analytics for long-term reference
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_admin_users_analytics (
    id serial PRIMARY KEY,
    report_date timestamp with time zone DEFAULT now(),
    total_admins integer,
    total_restaurants integer,
    avg_logins_per_admin numeric(10,2),
    median_logins numeric(10,2),
    max_logins integer,
    highly_engaged_count integer,
    never_logged_in_count integer,
    active_last_month integer,
    active_last_quarter integer,
    most_recent_login timestamp with time zone,
    oldest_account_date timestamp with time zone,
    migration_complete boolean,
    notes text
);

-- Insert current snapshot
INSERT INTO menuca_v3.restaurant_admin_users_analytics (
    total_admins,
    total_restaurants,
    avg_logins_per_admin,
    median_logins,
    max_logins,
    highly_engaged_count,
    never_logged_in_count,
    active_last_month,
    active_last_quarter,
    most_recent_login,
    oldest_account_date,
    migration_complete,
    notes
)
SELECT
    COUNT(*) as total_admins,
    COUNT(DISTINCT restaurant_id) as total_restaurants,
    AVG(login_count)::numeric(10,2) as avg_logins_per_admin,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY login_count) as median_logins,
    MAX(login_count) as max_logins,
    COUNT(*) FILTER (WHERE login_count > 100) as highly_engaged_count,
    COUNT(*) FILTER (WHERE last_login_at IS NULL) as never_logged_in_count,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '1 month') as active_last_month,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '3 months') as active_last_quarter,
    MAX(last_login_at) as most_recent_login,
    MIN(created_at) as oldest_account_date,
    (COUNT(*) = COUNT(migrated_to_admin_user_id)) as migration_complete,
    'Snapshot taken before deprecating restaurant_admin_users table' as notes
FROM menuca_v3.restaurant_admin_users;

-- Verify analytics snapshot created
SELECT * FROM menuca_v3.restaurant_admin_users_analytics ORDER BY report_date DESC LIMIT 1;

-- ============================================================================
-- Historical Analytics Complete
-- ============================================================================
