# MenuCA V3 User/Admin Database Audit Report

## Summary
All user and admin data is stored in the **`menuca_v3` schema**, not in the public schema. The system uses Supabase Auth integration with custom user tables.

## User Tables Overview

### 1. Regular Users (`menuca_v3.users`)
- **Total Records**: 32,318 users
- **Unique Emails**: 32,318
- **Auth Integration**: 29,219 linked to auth.users (90.4%)
- **Legacy Users**: 3,099 not linked to auth (9.6%)

**Key Columns**:
- `id` (bigint) - Primary key
- `auth_user_id` (uuid) - Links to Supabase auth.users
- `email`, `first_name`, `last_name`, `phone`
- `has_email_verified` (boolean)
- `credit_balance` (numeric)
- `last_login_at`, `last_login_ip`
- `v1_user_id`, `v2_user_id` - Legacy system references

### 2. Admin Users (`menuca_v3.admin_users`)
- **Total Records**: 456 admin users
- **Unique Emails**: 456
- **MFA Support**: `mfa_enabled`, `mfa_secret`, `mfa_backup_codes[]`

**Key Columns**:
- `id` (bigint) - Primary key
- `auth_user_id` (uuid) - Links to Supabase auth.users
- `email`, `first_name`, `last_name`
- `v1_admin_id`, `v2_admin_id` - Legacy references
- `deleted_at`, `deleted_by` - Soft delete support

### 3. Restaurant Admin Users (`menuca_v3.restaurant_admin_users`)
- **Total Records**: 438 restaurant-specific admins
- Links admin users to specific restaurants they manage

## Related User Tables

### Customer Data:
- `menuca_v3.user_addresses` - Customer addresses
- `menuca_v3.user_delivery_addresses` - Delivery-specific addresses
- `menuca_v3.user_payment_methods` - Saved payment methods
- `menuca_v3.user_favorite_dishes` - Favorite menu items
- `menuca_v3.user_favorite_restaurants` - Favorite restaurants

### Admin Data:
- `menuca_v3.admin_user_preferences` - Admin UI preferences
- `menuca_v3.admin_user_restaurants` - Admin-restaurant associations
- `menuca_v3.admin_roles` - Role-based permissions
- `menuca_v3.admin_action_logs` - Audit trail

## Authentication Architecture

### Supabase Auth Integration:
- **auth.users**: 31,414 records (Supabase managed)
- **menuca_v3.users**: 32,318 records (application managed)
- **Linked Records**: 29,219 (90.4% have auth integration)

### Authentication Flow:
1. New users register via Supabase Auth ? creates `auth.users` record
2. Application creates corresponding `menuca_v3.users` record with `auth_user_id` link
3. Legacy users (3,099) exist only in `menuca_v3.users` without auth linkage

## Key Findings

### ? Positives:
- All user data properly segregated in `menuca_v3` schema
- Clear separation between customers and admins
- MFA support built into admin system
- Soft delete capability for admins
- Legacy user references preserved for migration tracking

### ?? Considerations:
- 3,099 legacy users (9.6%) not linked to Supabase Auth
- These users may need auth migration or password reset flow
- Admin users stored separately from auth.users (may need RLS policies)

## Testing Recommendations

### Customer Login Test:
1. Try logging in with a user that has `auth_user_id` (should work via Supabase Auth)
2. Try a legacy user without `auth_user_id` (may need special handling)

### Admin Login Test:
1. Check if admin login uses `menuca_v3.admin_users` table
2. Verify MFA flow if enabled
3. Test restaurant-specific admin access via `restaurant_admin_users`

### Data Integrity Checks:
```sql
-- Check for duplicate emails across user types
SELECT email, COUNT(*) 
FROM (
  SELECT email FROM menuca_v3.users
  UNION ALL
  SELECT email FROM menuca_v3.admin_users
) combined
GROUP BY email
HAVING COUNT(*) > 1;

-- Verify auth linkage consistency
SELECT 
  COUNT(*) as orphaned_auth_records
FROM auth.users au
LEFT JOIN menuca_v3.users u ON u.auth_user_id = au.id
WHERE u.id IS NULL;
```

## Conclusion
User and admin data is **fully contained within the `menuca_v3` schema**, with proper Supabase Auth integration for 90% of users. The remaining 10% are legacy users that may require migration assistance.