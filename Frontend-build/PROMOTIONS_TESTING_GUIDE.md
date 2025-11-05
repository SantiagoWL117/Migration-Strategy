# Marketing & Promotions - Testing Guide

**Date:** October 27, 2025
**Features:** Coupons & Auto-Apply Best Deal
**Status:** Ready for Testing

---

## 🎯 Quick Start Testing

### Prerequisites:
1. Dev server running: `npm run dev`
2. Supabase connection working
3. Test restaurant with dishes in cart

### Test Scenario 1: Auto-Apply Best Deal (2 minutes)

**Setup:**
```sql
-- Create a test deal in Supabase
INSERT INTO menuca_v3.promotional_deals (
  restaurant_id,
  name,
  deal_type,
  discount_type,
  discount_value,
  is_enabled,
  date_start,
  date_stop,
  min_order_amount
) VALUES (
  824, -- Your test restaurant ID
  '20% Off Orders Over $20',
  'standard',
  'percentage',
  20,
  true,
  NOW(),
  NOW() + INTERVAL '30 days',
  20.00
);
```

**Test Steps:**
1. Add $25 worth of items to cart
2. Click "Checkout"
3. **EXPECT:** Green "Best Deal Applied!" banner appears automatically
4. **EXPECT:** Discount shown: "-$5.00" (20% of $25)
5. **EXPECT:** Total reduced by discount amount
6. Click X to remove deal
7. **EXPECT:** Discount removed, total restored

**Pass Criteria:**
- ✅ Deal auto-applies on page load
- ✅ Banner shows correct discount amount
- ✅ Total updates correctly
- ✅ Can remove deal

---

### Test Scenario 2: Valid Coupon Code (2 minutes)

**Setup:**
```sql
-- Create a test coupon
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id,
  platform_wide,
  code,
  name,
  discount_type,
  discount_value,
  is_active,
  start_date,
  end_date,
  min_order_amount
) VALUES (
  824, -- Your test restaurant ID
  false,
  'SAVE10',
  '$10 Off Your Order',
  'fixed_amount',
  10,
  true,
  NOW(),
  NOW() + INTERVAL '30 days',
  25.00
);
```

**Test Steps:**
1. Have $30 in cart
2. Go to checkout
3. Enter "SAVE10" in coupon field
4. Click "Apply"
5. **EXPECT:** Loading spinner appears
6. **EXPECT:** Green success banner with "You saved $10.00!"
7. **EXPECT:** Total reduced by $10
8. Complete order (use test card 4242...)
9. Check database:
   ```sql
   SELECT coupon_code, discount_amount
   FROM menuca_v3.orders
   ORDER BY created_at DESC
   LIMIT 1;
   ```
10. **EXPECT:** Order has coupon_code='SAVE10', discount_amount=10.00

**Pass Criteria:**
- ✅ Coupon validates successfully
- ✅ Success message appears
- ✅ Discount applied to total
- ✅ Order saves coupon data
- ✅ Coupon usage logged

---

### Test Scenario 3: Invalid Coupon (1 minute)

**Test Steps:**
1. Go to checkout
2. Enter "INVALID123"
3. Click "Apply"
4. **EXPECT:** Red error: "Coupon code not found. Please check and try again."
5. Enter "SAVE10" (valid code)
6. **EXPECT:** Error clears, coupon applies

**Pass Criteria:**
- ✅ Error message displayed
- ✅ Message is user-friendly
- ✅ Can try again after error

---

### Test Scenario 4: Expired Coupon (1 minute)

**Setup:**
```sql
-- Create expired coupon
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, code, name, discount_type, discount_value,
  is_active, start_date, end_date
) VALUES (
  824, 'EXPIRED', 'Expired Coupon', 'percentage', 15,
  false, -- inactive
  NOW() - INTERVAL '7 days',
  NOW() - INTERVAL '1 day'
);
```

**Test Steps:**
1. Enter "EXPIRED"
2. Click "Apply"
3. **EXPECT:** Red error: "This coupon is no longer active."

**Pass Criteria:**
- ✅ Correct error message

---

### Test Scenario 5: Minimum Order Not Met (1 minute)

**Test Steps:**
1. Have $20 in cart
2. Try to apply "SAVE10" (requires $25 min)
3. **EXPECT:** Red error: "Minimum order amount not met for this coupon."
4. Add $6 more items (now $26)
5. Try "SAVE10" again
6. **EXPECT:** Coupon applies successfully

**Pass Criteria:**
- ✅ Min order enforced
- ✅ Works after reaching minimum

---

### Test Scenario 6: Usage Limit (2 minutes)

**Setup:**
```sql
-- Create one-time use coupon
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, code, name, discount_type, discount_value,
  is_active, start_date, end_date,
  usage_limit_total, usage_limit_per_customer
) VALUES (
  824, 'ONETIME', 'One Time Use', 'fixed_amount', 5,
  true, NOW(), NOW() + INTERVAL '30 days',
  1, 1 -- Only one use total
);
```

**Test Steps:**
1. Apply "ONETIME"
2. Complete order
3. Check coupon_usage_log:
   ```sql
   SELECT * FROM menuca_v3.coupon_usage_log
   WHERE coupon_id = (SELECT id FROM menuca_v3.promotional_coupons WHERE code = 'ONETIME')
   ORDER BY created_at DESC;
   ```
4. **EXPECT:** One log entry
5. Try to apply "ONETIME" again on new order
6. **EXPECT:** Error: "This coupon has reached its usage limit."

**Pass Criteria:**
- ✅ First use succeeds
- ✅ Second use blocked
- ✅ Usage logged correctly

---

## 🐛 Edge Cases to Test

### 1. Best Deal vs Manual Coupon
**Test:** Auto-deal gives 10% ($2 off), manual coupon gives $5 off
**Steps:**
1. Let auto-deal apply (10%)
2. Enter manual coupon
3. **EXPECT:** Manual coupon replaces auto-deal (better discount wins)

### 2. Remove and Reapply
**Steps:**
1. Apply coupon
2. Remove it
3. Apply same coupon again
4. **EXPECT:** Works correctly

### 3. Empty Cart
**Steps:**
1. Go to checkout with items
2. Remove all items
3. **EXPECT:** No errors, checkout gracefully handles

### 4. Wrong Restaurant Coupon
**Setup:** Coupon for Restaurant A, cart has Restaurant B items
**Steps:**
1. Try to apply Restaurant A coupon
2. **EXPECT:** Error: "This coupon is not valid for this restaurant."

### 5. Network Failure
**Steps:**
1. Disconnect internet
2. Try to apply coupon
3. **EXPECT:** Error: "Failed to validate coupon. Please try again."
4. Reconnect
5. **EXPECT:** Can retry successfully

---

## 🔍 Database Verification Queries

### Check Recent Orders with Coupons:
```sql
SELECT
  id,
  order_number,
  coupon_code,
  subtotal,
  discount_amount,
  total_amount,
  created_at
FROM menuca_v3.orders
WHERE coupon_code IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;
```

### Check Coupon Usage Log:
```sql
SELECT
  cul.*,
  pc.code,
  pc.name,
  o.order_number
FROM menuca_v3.coupon_usage_log cul
JOIN menuca_v3.promotional_coupons pc ON pc.id = cul.coupon_id
JOIN menuca_v3.orders o ON o.id = cul.order_id
ORDER BY cul.created_at DESC
LIMIT 10;
```

### Check Active Deals:
```sql
SELECT
  id,
  name,
  discount_type,
  discount_value,
  min_order_amount,
  times_redeemed,
  is_enabled
FROM menuca_v3.promotional_deals
WHERE restaurant_id = 824
  AND is_enabled = true
  AND date_start <= NOW()
  AND date_stop >= NOW()
ORDER BY display_order;
```

### Check Active Coupons:
```sql
SELECT
  id,
  code,
  name,
  discount_type,
  discount_value,
  min_order_amount,
  usage_limit_total,
  times_redeemed,
  is_active
FROM menuca_v3.promotional_coupons
WHERE (restaurant_id = 824 OR platform_wide = true)
  AND is_active = true
  AND start_date <= NOW()
  AND end_date >= NOW()
ORDER BY created_at DESC;
```

---

## 📱 Mobile Testing

### Test on Mobile Devices:
1. Open checkout on phone
2. Verify coupon input is easy to use
3. Keyboard appears correctly
4. Success/error messages readable
5. Banner doesn't overflow
6. Remove button easily tappable

### Responsive Breakpoints:
- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

---

## 🎨 Visual Testing

### Coupon Input Component:
- [ ] Tag icon visible
- [ ] Placeholder text readable
- [ ] Border color on focus (red)
- [ ] Loading spinner animates
- [ ] Success state (green background)
- [ ] Error state (red background)
- [ ] Uppercase conversion works

### Best Deal Banner:
- [ ] Gradient background renders
- [ ] Sparkles icon shows
- [ ] Text is centered and readable
- [ ] Discount amount prominent
- [ ] Remove button visible
- [ ] Hover states work
- [ ] Animation smooth

### Order Summary:
- [ ] Discount line shows in green
- [ ] Total updates immediately
- [ ] "You're saving" message appears
- [ ] Layout doesn't break

---

## 🚨 Error Scenarios

### Network Errors:
```
Test: Simulate network failure
Expect: User-friendly error message
Action: Allow retry
```

### Backend Errors:
```
Test: Backend returns 500
Expect: "Failed to validate coupon"
Action: Log error, allow retry
```

### Validation Errors:
```
Test: Empty coupon code
Expect: "Please enter a coupon code"
Action: Prevent submission
```

---

## ✅ Acceptance Criteria

### Must Pass:
- [ ] Auto-apply best deal works
- [ ] Valid coupon applies successfully
- [ ] Invalid coupon shows error
- [ ] Expired coupon rejected
- [ ] Min order enforced
- [ ] Usage limits enforced
- [ ] Discount saves to order
- [ ] Coupon usage logged
- [ ] Mobile responsive
- [ ] No console errors

### Nice to Have:
- [ ] Smooth animations
- [ ] Fast API responses (< 1s)
- [ ] Clear loading states
- [ ] Helpful error messages
- [ ] Celebratory success states

---

## 🐞 Bug Reporting Template

```
Title: [Coupons] Brief description

Steps to Reproduce:
1. Go to checkout
2. Enter coupon "SAVE10"
3. Click Apply

Expected Result:
Coupon should apply, showing $10 discount

Actual Result:
Error message appeared: "..."

Environment:
- Browser: Chrome 119
- Device: Desktop
- Screen size: 1920x1080
- Restaurant ID: 824
- Order total: $35.00

Screenshots: [attach]

Console Errors: [paste]
```

---

## 📊 Performance Testing

### API Response Times:
- `find_best_deal_for_order`: < 100ms
- `validate_coupon`: < 200ms
- `redeem_coupon`: < 100ms

### Page Load:
- Checkout page: < 2s
- Auto-apply check: < 500ms

### User Actions:
- Coupon validation: < 1s (with loading state)
- Remove discount: Instant

---

## 🎓 Test Data Setup Script

```sql
-- Run this to set up complete test environment

-- Test Restaurant (if not exists)
-- UPDATE: Use your existing restaurant ID (824 in examples)

-- Test Deal: 20% off orders over $20
INSERT INTO menuca_v3.promotional_deals (
  restaurant_id, name, deal_type, discount_type, discount_value,
  is_enabled, date_start, date_stop, min_order_amount, display_order
) VALUES (
  824, '20% Off Orders Over $20', 'standard', 'percentage', 20,
  true, NOW(), NOW() + INTERVAL '30 days', 20.00, 1
);

-- Test Coupon: $10 off orders over $25
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, platform_wide, code, name, discount_type, discount_value,
  is_active, start_date, end_date, min_order_amount
) VALUES (
  824, false, 'SAVE10', '$10 Off Your Order', 'fixed_amount', 10,
  true, NOW(), NOW() + INTERVAL '30 days', 25.00
);

-- Test Coupon: One-time use
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, platform_wide, code, name, discount_type, discount_value,
  is_active, start_date, end_date, usage_limit_total, usage_limit_per_customer
) VALUES (
  824, false, 'ONETIME', 'One Time Use', 'fixed_amount', 5,
  true, NOW(), NOW() + INTERVAL '30 days', 1, 1
);

-- Test Coupon: Expired (inactive)
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, platform_wide, code, name, discount_type, discount_value,
  is_active, start_date, end_date
) VALUES (
  824, false, 'EXPIRED', 'Expired Coupon', 'percentage', 15,
  false, NOW() - INTERVAL '7 days', NOW() - INTERVAL '1 day'
);

-- Platform-wide coupon
INSERT INTO menuca_v3.promotional_coupons (
  restaurant_id, platform_wide, code, name, discount_type, discount_value,
  is_active, start_date, end_date, min_order_amount
) VALUES (
  NULL, true, 'WELCOME20', '20% Off First Order', 'percentage', 20,
  true, NOW(), NOW() + INTERVAL '90 days', 15.00
);

-- Verify setup
SELECT 'Deals Created' as type, COUNT(*) as count FROM menuca_v3.promotional_deals WHERE restaurant_id = 824
UNION ALL
SELECT 'Coupons Created' as type, COUNT(*) as count FROM menuca_v3.promotional_coupons WHERE restaurant_id = 824 OR platform_wide = true;
```

---

**Status:** Ready for QA Testing! 🚀
