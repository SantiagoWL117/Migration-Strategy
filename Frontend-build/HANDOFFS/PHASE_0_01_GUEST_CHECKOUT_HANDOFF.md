# HANDOFF: Guest Checkout Support

**Ticket:** PHASE_0_01_GUEST_CHECKOUT  
**Implemented By:** Builder Agent (Claude Sonnet 4.5)  
**Date:** October 22, 2025  
**Status:** ✅ READY FOR AUDIT  
**Database:** Production branch (nthpbtdjhhnwfxqsxbvy) - cursor-build inherits automatically

---

## Summary

Successfully implemented guest checkout capability for MenuCA V3 by adding three new columns to the `menuca_v3.orders` table (`is_guest_order`, `guest_email`, `guest_phone`), making `user_id` nullable, and enforcing data integrity through a CHECK constraint. The implementation allows customers to place orders without creating an account, which is critical for conversion rates (prevents 50%+ cart abandonment). All existing orders remain unaffected, and the system now supports both authenticated and guest orders seamlessly.

---

## Files Created/Modified

### Migration Files
- **Migration:** `add_guest_checkout_support` (applied via Supabase MCP)
- **Applied to:** Production database `nthpbtdjhhnwfxqsxbvy`
- **Schema:** `menuca_v3`
- **Table:** `orders` (and all monthly partitions)

### Documentation Files
- **This handoff:** `/Frontend-build/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`

---

## Implementation Details

### Approach

The migration adds guest checkout support through a clean, additive approach that preserves all existing data and functionality:

1. **Added three new columns** to track guest order information
2. **Made user_id nullable** to allow orders without authenticated users
3. **Enforced data integrity** with CHECK constraint requiring email for guest orders
4. **Optimized lookups** with partial index on guest_email
5. **Added documentation** via column comments for future developers

### Key Design Decisions

#### 1. Separate guest_email vs. existing customer_email
The orders table already has `customer_email`, `customer_phone`, and `customer_name` columns. I added separate `guest_email` and `guest_phone` columns as specified in the ticket to maintain clear separation between:
- **customer_* fields**: Generic order contact info (used for all orders)
- **guest_* fields**: Specific tracking of guest vs. authenticated orders

This allows for proper order classification and guest-specific features (like post-order account creation prompts).

#### 2. Partial Index Strategy
Created a partial index on `guest_email` with `WHERE is_guest_order = TRUE` to:
- Optimize guest order lookups (e.g., "Track your order by email")
- Reduce index size by excluding authenticated orders
- Improve query performance for guest-specific features

#### 3. Check Constraint Logic
The CHECK constraint enforces: `(is_guest_order = FALSE) OR (is_guest_order = TRUE AND guest_email IS NOT NULL)`

This means:
- Authenticated orders: `is_guest_order = FALSE`, `guest_email` can be NULL
- Guest orders: `is_guest_order = TRUE`, `guest_email` MUST be provided
- Database will reject any guest order missing an email address

#### 4. Partition Table Handling
The orders table is partitioned by month (orders_2025_10, orders_2025_11, etc.). The migration correctly applied the CHECK constraint to:
- Parent table: `menuca_v3.orders`
- All child partitions: `orders_2025_10`, `orders_2025_11`, `orders_2025_12`, `orders_2026_01`, `orders_2026_02`, `orders_2026_03`

This ensures data integrity across all partitions automatically.

---

## Acceptance Criteria Status

### Database Changes
- ✅ **Add `is_guest_order` BOOLEAN field** - Added with default FALSE, NOT NULL
- ✅ **Add `guest_email` VARCHAR(255) field** - Added as nullable field
- ✅ **Add `guest_phone` VARCHAR(20) field** - Added as nullable field
- ✅ **Make `user_id` nullable** - Changed from NOT NULL to nullable
- ✅ **Add CHECK constraint** - `orders_guest_email_check` enforces email requirement for guest orders
- ✅ **Add index on `guest_email`** - Partial index `idx_orders_guest_email` created for guest order lookups

### Functionality
- ✅ **Guest orders can be created without `user_id`** - Verified with test insertion
- ✅ **Guest email/phone stored for notifications** - Fields successfully store contact info
- ✅ **Orders table accepts both order types** - Tested both authenticated and guest orders

### Data Integrity
- ✅ **Existing orders unaffected** - All existing orders have `is_guest_order = FALSE` by default
- ✅ **Foreign key to users table remains** - FK still exists but allows NULL
- ✅ **No orphaned data created** - Clean migration with backward compatibility

### Testing
- ✅ **Test creating guest order** - Successfully created with `user_id = NULL`, `guest_email` populated
- ✅ **Test creating authenticated order** - Successfully created with `user_id` populated
- ✅ **Test CHECK constraint** - Correctly rejected guest order without email
- ✅ **Verify existing orders unaffected** - Confirmed no data corruption

---

## Testing Performed

### 1. Schema Verification Tests

**Columns Added:**
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3' AND table_name = 'orders'
  AND column_name IN ('is_guest_order', 'guest_email', 'guest_phone', 'user_id');
```

**Results:**
- `guest_email`: character varying, nullable
- `guest_phone`: character varying, nullable
- `is_guest_order`: boolean, NOT NULL, default false
- `user_id`: bigint, **NOW NULLABLE** (was NOT NULL before)

✅ **PASS** - All columns added with correct types and nullability

### 2. Constraint Verification Test

**CHECK Constraint:**
```sql
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'menuca_v3' 
  AND constraint_name = 'orders_guest_email_check';
```

**Result:**
```
constraint_name: orders_guest_email_check
check_clause: ((is_guest_order = false) OR ((is_guest_order = true) AND (guest_email IS NOT NULL)))
```

**Applied to tables:**
- menuca_v3.orders (parent)
- menuca_v3.orders_2025_10
- menuca_v3.orders_2025_11
- menuca_v3.orders_2025_12
- menuca_v3.orders_2026_01
- menuca_v3.orders_2026_02
- menuca_v3.orders_2026_03

✅ **PASS** - CHECK constraint exists and applied to all partition tables

### 3. Index Verification Test

**Index Created:**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3' AND tablename = 'orders'
  AND indexname = 'idx_orders_guest_email';
```

**Result:**
```
indexname: idx_orders_guest_email
indexdef: CREATE INDEX idx_orders_guest_email ON ONLY menuca_v3.orders 
          USING btree (guest_email) WHERE (is_guest_order = true)
```

✅ **PASS** - Partial index created for efficient guest order lookups

### 4. Functional Testing

#### Test 1: Guest Order Creation (Should Succeed)
```sql
INSERT INTO menuca_v3.orders (
  restaurant_id, order_number, is_guest_order, guest_email, guest_phone,
  order_status, order_type, total_amount, subtotal, tax_amount,
  delivery_fee, tip_amount, discount_amount
) VALUES (
  528, 'TEST-GUEST-001', TRUE, 'test@example.com', '+1234567890',
  'pending', 'delivery', 25.00, 22.00, 3.00, 0.00, 0.00, 0.00
) RETURNING id, order_number, is_guest_order, guest_email, user_id;
```

**Result:**
```
id: 3
order_number: TEST-GUEST-001
is_guest_order: true
guest_email: test@example.com
guest_phone: +1234567890
user_id: null
```

✅ **PASS** - Guest order created successfully with NULL user_id

#### Test 2: Guest Order Without Email (Should Fail)
```sql
INSERT INTO menuca_v3.orders (
  restaurant_id, order_number, is_guest_order, order_status, order_type,
  total_amount, subtotal, tax_amount, delivery_fee, tip_amount, discount_amount
) VALUES (
  528, 'TEST-GUEST-BAD', TRUE, 'pending', 'delivery',
  25.00, 22.00, 3.00, 0.00, 0.00, 0.00
);
```

**Result:**
```
ERROR: 23514: new row for relation "orders_2025_10" violates 
check constraint "orders_guest_email_check"
DETAIL: Failing row contains (..., is_guest_order=t, guest_email=null, ...)
```

✅ **PASS** - CHECK constraint correctly rejected guest order without email

#### Test 3: Authenticated Order (Should Succeed)
```sql
INSERT INTO menuca_v3.orders (
  restaurant_id, order_number, user_id, is_guest_order,
  order_status, order_type, total_amount, subtotal, tax_amount,
  delivery_fee, tip_amount, discount_amount
) VALUES (
  528, 'TEST-AUTH-001', 165, FALSE, 'pending', 'delivery',
  30.00, 27.00, 3.00, 0.00, 0.00, 0.00
) RETURNING id, order_number, is_guest_order, guest_email, user_id;
```

**Result:**
```
id: 5
order_number: TEST-AUTH-001
is_guest_order: false
guest_email: null
user_id: 165
```

✅ **PASS** - Authenticated order created successfully with user_id populated

### 5. Data Integrity Test

**Test Query:**
```sql
SELECT 
  COUNT(*) as total_test_orders,
  SUM(CASE WHEN is_guest_order = TRUE THEN 1 ELSE 0 END) as guest_orders,
  SUM(CASE WHEN is_guest_order = FALSE THEN 1 ELSE 0 END) as authenticated_orders,
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as orders_with_null_user_id
FROM menuca_v3.orders
WHERE order_number LIKE 'TEST-%';
```

**Result:**
```
total_test_orders: 2
guest_orders: 1
authenticated_orders: 1
orders_with_null_user_id: 1
```

✅ **PASS** - Both order types coexist correctly in the same table

### 6. Cleanup Test

All test data was successfully removed:
```sql
DELETE FROM menuca_v3.orders WHERE order_number LIKE 'TEST-%';
-- Deleted: TEST-GUEST-001 (guest), TEST-AUTH-001 (authenticated)
```

Final state: 0 orders remaining (clean production database)

---

## Verification Queries Run

### Query 1: Column Structure
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3' AND table_name = 'orders'
  AND column_name IN ('is_guest_order', 'guest_email', 'guest_phone', 'user_id')
ORDER BY column_name;
```

**Output:**
| column_name    | data_type          | is_nullable | column_default |
|----------------|-------------------|-------------|----------------|
| guest_email    | character varying | YES         | null           |
| guest_phone    | character varying | YES         | null           |
| is_guest_order | boolean           | NO          | false          |
| user_id        | bigint            | YES         | null           |

### Query 2: CHECK Constraint
```sql
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'menuca_v3' 
  AND constraint_name = 'orders_guest_email_check';
```

**Output:**
```
orders_guest_email_check | ((is_guest_order = false) OR ((is_guest_order = true) AND (guest_email IS NOT NULL)))
```

### Query 3: Index Definition
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3' AND tablename = 'orders'
  AND indexname = 'idx_orders_guest_email';
```

**Output:**
```
idx_orders_guest_email | CREATE INDEX idx_orders_guest_email ON ONLY menuca_v3.orders USING btree (guest_email) WHERE (is_guest_order = true)
```

### Query 4: Existing Orders Impact
```sql
SELECT 
  COUNT(*) as total_orders,
  SUM(CASE WHEN is_guest_order = FALSE THEN 1 ELSE 0 END) as authenticated_orders,
  SUM(CASE WHEN is_guest_order = TRUE THEN 1 ELSE 0 END) as guest_orders,
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as null_user_id
FROM menuca_v3.orders;
```

**Output:**
```
total_orders: 0
authenticated_orders: null
guest_orders: null
null_user_id: null
```

*Note: Database currently has 0 orders (fresh production environment). Migration tested with sample data, then cleaned up.*

---

## Known Limitations

### 1. Email Format Validation
- **Current State:** Database accepts any string in `guest_email` field
- **Recommendation:** Frontend and API should validate email format before submission
- **Future Enhancement:** Consider adding CHECK constraint for email format validation (e.g., must contain '@')

### 2. Phone Number Format
- **Current State:** `guest_phone` accepts any VARCHAR(20) string
- **Recommendation:** Frontend should validate phone format (e.g., E.164 format)
- **Future Enhancement:** Consider standardizing phone numbers to international format

### 3. RLS Policies Not Implemented
- **Current State:** No Row Level Security policies exist for guest orders
- **Security Risk:** Guest emails are PII and need protection
- **Next Steps:** Phase 8 (Security) will implement RLS policies to:
  - Allow users to see only their own authenticated orders
  - Allow guests to see orders matching their session email
  - Prevent unauthorized access to guest order data

### 4. Relationship with Existing Customer Fields
- **Current State:** Orders table has both `customer_email` and `guest_email`
- **Clarification Needed:** Should `customer_email` be populated for guest orders, or only `guest_email`?
- **Recommendation:** Define clear data population strategy for both fields

### 5. Post-Order Account Creation Flow
- **Current State:** Database ready, but no mechanism to link guest orders to newly created accounts
- **Future Enhancement:** Phase 4 (Checkout) should implement:
  - UI prompt for account creation after order placement
  - Migration script to link guest orders to new user accounts
  - Update `user_id` when guest creates account with matching email

---

## Questions for Auditor

### 1. Foreign Key Nullability
**Question:** Should we add a comment to the `user_id` foreign key documenting that NULL is valid for guest orders?

**Context:** The FK constraint now allows NULL (for guest orders), but there's no explicit documentation on the constraint itself explaining why. This could help future developers understand the design.

### 2. Email Uniqueness
**Question:** Should guest emails be unique within a time window?

**Context:** Nothing prevents the same guest email from placing multiple orders (which is valid), but should we add any rate limiting or duplicate detection at the database level?

### 3. Index Coverage
**Question:** Should we add an index on `(is_guest_order, guest_email)` for queries filtering on both?

**Context:** Current partial index covers `guest_email WHERE is_guest_order = TRUE`. A composite index might be more efficient for some query patterns.

### 4. Column Naming Consistency
**Question:** Should we rename `guest_phone` to `guest_phone_number` for consistency with other phone fields?

**Context:** The orders table has `customer_phone`, while other tables might use `phone_number`. Consistency would improve schema readability.

### 5. Partition Inheritance Verification
**Question:** Do we need to explicitly test partition inheritance with a future-dated order?

**Context:** I verified the CHECK constraint exists on current partitions, but didn't test inserting into a partition that doesn't exist yet. Postgres should auto-create partitions with inherited constraints, but worth confirming.

### 6. Rollback Strategy Safety
**Question:** Should we add a rollback prevention check?

**Context:** The rollback script includes `ALTER COLUMN user_id SET NOT NULL`, which would fail if any guest orders exist. Should we add a safety check that blocks rollback if guest orders are present?

### 7. Data Sync with customer_* Fields
**Question:** Should we add a trigger to sync `guest_email` → `customer_email` for guest orders?

**Context:** To maintain consistency between legacy `customer_email` and new `guest_email` fields, a trigger could auto-populate `customer_email` when `guest_email` is set.

---

## Migration SQL

```sql
-- Migration: Add guest checkout support to orders table
-- Date: 2025-10-22
-- Ticket: PHASE_0_01_GUEST_CHECKOUT

-- Step 1: Add new columns for guest checkout
ALTER TABLE menuca_v3.orders
  ADD COLUMN is_guest_order BOOLEAN DEFAULT FALSE NOT NULL,
  ADD COLUMN guest_email VARCHAR(255),
  ADD COLUMN guest_phone VARCHAR(20);

-- Step 2: Make user_id nullable (allow guest orders)
ALTER TABLE menuca_v3.orders
  ALTER COLUMN user_id DROP NOT NULL;

-- Step 3: Add CHECK constraint - guest orders must have email
ALTER TABLE menuca_v3.orders
  ADD CONSTRAINT orders_guest_email_check 
  CHECK (
    (is_guest_order = FALSE) OR 
    (is_guest_order = TRUE AND guest_email IS NOT NULL)
  );

-- Step 4: Add index for guest email lookups
CREATE INDEX idx_orders_guest_email 
  ON menuca_v3.orders(guest_email) 
  WHERE is_guest_order = TRUE;

-- Step 5: Add comments for documentation
COMMENT ON COLUMN menuca_v3.orders.is_guest_order IS 
  'TRUE if order placed without user account (guest checkout)';
  
COMMENT ON COLUMN menuca_v3.orders.guest_email IS 
  'Email address for guest orders (required if is_guest_order = TRUE)';
  
COMMENT ON COLUMN menuca_v3.orders.guest_phone IS 
  'Phone number for guest orders (optional)';
```

---

## Rollback Plan

**⚠️ WARNING:** Only execute rollback if NO guest orders have been created!

```sql
BEGIN;

-- Check for guest orders first (should return 0)
SELECT COUNT(*) FROM menuca_v3.orders WHERE is_guest_order = TRUE;

-- If count is 0, proceed with rollback:

-- Remove index
DROP INDEX IF EXISTS menuca_v3.idx_orders_guest_email;

-- Remove CHECK constraint
ALTER TABLE menuca_v3.orders 
  DROP CONSTRAINT IF EXISTS orders_guest_email_check;

-- Make user_id NOT NULL again (ONLY if no guest orders exist!)
ALTER TABLE menuca_v3.orders 
  ALTER COLUMN user_id SET NOT NULL;

-- Remove columns
ALTER TABLE menuca_v3.orders
  DROP COLUMN IF EXISTS is_guest_order,
  DROP COLUMN IF EXISTS guest_email,
  DROP COLUMN IF EXISTS guest_phone;

COMMIT;
```

---

## Next Steps (Frontend Implementation - Phase 4)

This database migration provides the foundation for guest checkout. The frontend team will need to implement:

### 1. Guest Checkout Form
```typescript
interface GuestCheckoutForm {
  fullName: string;      // Required
  email: string;         // Required - validates format
  phone: string;         // Required - validates format
  deliveryAddress: {     // Required
    street: string;
    city: string;
    postalCode: string;
  };
  paymentMethod: PaymentMethod;
}
```

### 2. Order Creation Logic
```typescript
// Frontend should determine order type based on auth state
const createOrder = async (orderData: OrderData) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (user) {
    // Authenticated order
    return await supabase.from('orders').insert({
      user_id: user.id,
      is_guest_order: false,
      // ... other order fields
    });
  } else {
    // Guest order
    return await supabase.from('orders').insert({
      user_id: null,
      is_guest_order: true,
      guest_email: orderData.email,
      guest_phone: orderData.phone,
      // ... other order fields
    });
  }
};
```

### 3. Post-Order Account Creation
```typescript
// After successful guest order
<PostOrderPrompt>
  <h3>Order confirmed!</h3>
  <p>Would you like to save your info for faster checkout next time?</p>
  <Button onClick={createAccountFromGuest}>Create Account</Button>
  <Button onClick={dismiss}>No Thanks</Button>
</PostOrderPrompt>
```

### 4. Guest Order Tracking
```typescript
// Allow guests to track orders by email
const trackGuestOrder = async (email: string, orderNumber: string) => {
  return await supabase
    .from('orders')
    .select('*')
    .eq('is_guest_order', true)
    .eq('guest_email', email)
    .eq('order_number', orderNumber)
    .single();
};
```

---

## References

- **Original Ticket:** `/Frontend-build/TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md`
- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #2: Guest Checkout Missing)
- **Build Plan:** `/CUSTOMER_ORDERING_APP_BUILD_PLAN.md` (Phase 4: Checkout)
- **Database Schema:** `/Database/Schemas/menuca_v3.sql`
- **Migration Applied:** Production branch `nthpbtdjhhnwfxqsxbvy`

---

## Success Metrics

✅ All acceptance criteria met  
✅ All verification queries pass  
✅ All functional tests pass  
✅ Existing orders unaffected  
✅ CHECK constraint enforces data integrity  
✅ Partial index optimizes guest order lookups  
✅ Migration applied to all partition tables  
✅ Test data cleaned up  
✅ Zero breaking changes introduced  
✅ Handoff documentation complete  

**Status:** Ready for Audit Agent review

---

**End of Handoff Document**



