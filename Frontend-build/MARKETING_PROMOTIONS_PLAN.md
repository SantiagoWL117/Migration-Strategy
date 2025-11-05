# Marketing & Promotions - Customer Frontend Implementation Plan

**Date:** October 27, 2025
**Status:** Planning Phase
**Backend Status:** 16/20 features complete (80% ready)
**Frontend Target:** 8 customer-facing features

---

## 🎯 Overview

The Marketing & Promotions backend is 80% complete with SQL functions, API endpoints, and real-time subscriptions ready. We need to build the customer-facing UI components in the Next.js frontend.

### Backend Status Summary:
- ✅ **29 SQL Functions** - All tested and working
- ✅ **22 API Endpoints** - Ready to use via Supabase RPC
- ✅ **WebSocket Subscriptions** - Real-time updates configured
- ✅ **Multi-language Support** - EN/ES/FR translations
- ⏳ **4 Features Pending** - Platform-wide features (not customer-facing)

---

## 📋 Customer-Facing Features to Build

### Priority 1: Essential Checkout Features (Week 1)

#### **Feature 2: Apply Coupons at Checkout**
**Backend:** ✅ Complete (4 SQL functions, 1 API endpoint)
**Frontend:** Need to build

**What to Build:**
1. **Coupon Input Component** (`components/coupon-input.tsx`)
   - Text input for coupon code
   - "Apply" button
   - Loading state during validation
   - Error/success messages

2. **Update Checkout Page** (`app/checkout/page.tsx`)
   - Add coupon input below cart items
   - Call `validate_coupon` RPC function
   - Display discount in order summary
   - Update total price calculation
   - Store validated coupon for order creation

**API Integration:**
```typescript
const { data: validation } = await supabase.rpc('validate_coupon', {
  p_code: 'SAVE10',
  p_restaurant_id: restaurantId,
  p_customer_id: userId || null,
  p_order_total: subtotal,
  p_service_type: 'delivery'
});

// Returns: {valid, error_code, discount_amount, coupon_id, coupon_name, final_total}
```

**Error Handling:**
- COUPON_NOT_FOUND → "Coupon code not found"
- COUPON_EXPIRED → "This coupon has expired"
- COUPON_INACTIVE → "This coupon is no longer active"
- COUPON_INVALID_RESTAURANT → "This coupon is not valid for this restaurant"
- MIN_ORDER_NOT_MET → "Minimum order of $X required"
- USAGE_LIMIT_REACHED → "Coupon has reached its usage limit"
- CUSTOMER_ALREADY_USED → "You've already used this coupon"

**Success Flow:**
1. User enters code
2. Frontend validates via RPC
3. Show success message with discount amount
4. Update order total
5. On order creation, call `redeem_coupon` RPC

---

#### **Feature 3: Auto-Apply Best Deal**
**Backend:** ✅ Complete (3 SQL functions, 1 API endpoint)
**Frontend:** Need to build

**What to Build:**
1. **Auto-Apply Logic** (in `app/checkout/page.tsx`)
   - On page load, call `find_best_deal_for_order` RPC
   - If deal found, auto-apply and show message
   - "You saved $X with auto-applied deal!"

2. **Best Deal Banner** (`components/best-deal-banner.tsx`)
   - Show deal name and savings
   - Green highlight/badge
   - Option to remove if user wants

**API Integration:**
```typescript
const { data: bestDeal } = await supabase.rpc('find_best_deal_for_order', {
  p_restaurant_id: restaurantId,
  p_order_total: subtotal,
  p_service_type: 'delivery',
  p_customer_id: userId || null
});

// Returns: {has_deal, deal_id, coupon_id, deal_type, discount_amount, final_total, deal_title, coupon_code}
```

**UX Flow:**
1. User adds items to cart, goes to checkout
2. Frontend automatically checks for best deal
3. If found: Show success banner, apply discount
4. If user had manually entered coupon: Compare and use better one
5. If no deal: Show "No promotions available" (subtle)

---

### Priority 2: Restaurant Menu Page Enhancements (Week 1-2)

#### **Feature 1: Browse Restaurant Deals**
**Backend:** ✅ Complete (3 SQL functions, 1 API endpoint)
**Frontend:** Need to build

**What to Build:**
1. **Deals Section Component** (`components/restaurant-deals-section.tsx`)
   - Display all active deals for restaurant
   - Show deal title, description, discount amount
   - "Valid until DATE" countdown
   - Service type badges (Delivery/Pickup/Dine-in)
   - Translations support (EN/ES/FR)

2. **Deal Card Component** (`components/deal-card.tsx`)
   - Visual card with deal info
   - Discount percentage/amount highlighted
   - Terms & conditions (expandable)
   - "Add to Cart" or "Apply at Checkout" CTA

3. **Update Restaurant Page** (`app/r/[slug]/page.tsx`)
   - Add deals section at top (before menu)
   - Fetch deals on page load
   - Language selector integration

**API Integration:**
```typescript
const { data: deals } = await supabase.rpc('get_deals_i18n', {
  p_restaurant_id: restaurantId,
  p_language: 'en', // or user preference
  p_service_type: 'delivery' // optional filter
});

// Returns: Array of {id, name, description, discount_type, discount_value, date_start, date_stop, terms, ...}
```

**Design Mockup:**
```
┌─────────────────────────────────────┐
│  🎉 Active Promotions               │
├─────────────────────────────────────┤
│ ╔═══════════════════════════════╗   │
│ ║ 🏷️ 20% OFF First Order        ║   │
│ ║ Save up to $10 on your first  ║   │
│ ║ delivery order                ║   │
│ ║ ⏰ Valid until: Nov 15, 2025  ║   │
│ ║ 🚚 Delivery only              ║   │
│ ║ [View Terms] [Apply at Cart]  ║   │
│ ╚═══════════════════════════════╝   │
│                                     │
│ ╔═══════════════════════════════╗   │
│ ║ 💰 Buy 2 Get 1 Free Pizzas    ║   │
│ ║ ...                           ║   │
│ ╚═══════════════════════════════╝   │
└─────────────────────────────────────┘
```

---

#### **Feature 6: View Available Coupons**
**Backend:** ✅ Complete (2 SQL functions, 1 API endpoint)
**Frontend:** Need to build

**What to Build:**
1. **Coupons Modal** (`components/coupons-modal.tsx`)
   - Modal/drawer with all available coupons
   - Filter by restaurant/platform-wide
   - Copy code button
   - "Apply" button (goes to checkout)

2. **Coupons Button** (add to restaurant page header)
   - "View Coupons" button/link
   - Badge with count (e.g., "3 available")

**API Integration:**
```typescript
const { data: coupons } = await supabase.rpc('get_available_coupons_i18n', {
  p_restaurant_id: restaurantId,
  p_language: 'en',
  p_customer_id: userId || null
});

// Returns: Array of {id, code, name, description, discount_type, discount_value, min_order_amount, ...}
```

**UX Flow:**
1. User clicks "View Coupons" button
2. Modal opens showing all available coupons
3. User can copy code or click "Apply"
4. If "Apply": Close modal, go to checkout with code pre-filled

---

#### **Feature 4: Flash Sales**
**Backend:** ✅ Complete (2 SQL functions, 2 API endpoints)
**Frontend:** Need to build

**What to Build:**
1. **Flash Sale Banner** (`components/flash-sale-banner.tsx`)
   - Urgent design (red/orange colors)
   - Countdown timer (real-time)
   - Slots remaining counter
   - "Claim Now" CTA button

2. **Claim Flow**
   - Click "Claim Now" → Call `claim_flash_sale_slot` RPC
   - Show success: "You've claimed a spot!"
   - Show coupon code generated
   - Handle errors: SOLD_OUT, EXPIRED, ALREADY_CLAIMED

**API Integration:**
```typescript
// Check active flash sales
const { data: flashSales } = await supabase.rpc('get_deals_i18n', {
  p_restaurant_id: restaurantId,
  p_language: 'en'
}).eq('deal_type', 'flash_sale');

// Claim slot
const { data: claim } = await supabase.rpc('claim_flash_sale_slot', {
  p_deal_id: flashSaleId,
  p_customer_id: userId
});

// Returns: {success, coupon_code, message, error_code}
```

**Design:**
```
┌─────────────────────────────────────┐
│ 🔥 FLASH SALE - Limited Time!      │
│ 50% OFF - Only 3 spots left!        │
│ ⏰ Ends in: 04:23:15               │
│ [CLAIM NOW] 👈                      │
└─────────────────────────────────────┘
```

---

### Priority 3: Enhanced Discovery (Week 2)

#### **Feature 5: Filter Restaurants by Tags**
**Backend:** ✅ Complete (3 SQL functions, 2 API endpoints)
**Frontend:** Need to build

**What to Build:**
1. **Tag Filter Component** (`components/tag-filter.tsx`)
   - Chip-based tag selector
   - Categories: Cuisine, Dietary, Features
   - Multi-select with "Apply Filters" button

2. **Update Home Page** (`app/page.tsx`)
   - Add tag filter above restaurant list
   - Filter restaurants by selected tags
   - Show active filter count

**API Integration:**
```typescript
// Get restaurants by tag
const { data: restaurants } = await supabase.rpc('get_restaurants_by_tag_i18n', {
  p_tag_id: tagId,
  p_language: 'en'
});

// Get restaurants by cuisine
const { data: restaurants } = await supabase.rpc('get_restaurants_by_cuisine', {
  p_cuisine_slug: 'pizza'
});
```

**Filter Options:**
- 🍕 Pizza
- 🍔 Burgers
- 🥗 Vegan Friendly
- 🌾 Gluten-Free Options
- 🚀 Fast Delivery
- 💎 Premium
- 🎉 Has Active Deals

---

### Priority 4: Real-Time Features (Week 2-3)

#### **Feature 8: Real-Time Deal Notifications**
**Backend:** ✅ Complete (WebSocket subscriptions)
**Frontend:** Need to build

**What to Build:**
1. **Deal Notification Toast** (`components/deal-notification-toast.tsx`)
   - Toast/snackbar when new deal published
   - "New deal available!" message
   - Click to view details

2. **WebSocket Subscription Hook** (`hooks/useDealSubscription.ts`)
   - Subscribe to promotional_deals table
   - Listen for INSERT events
   - Show toast on new deal
   - Update deals list in real-time

**API Integration:**
```typescript
// Subscribe to new deals
const supabase = createClient();
const channel = supabase
  .channel('restaurant-deals')
  .on('postgres_changes',
    {
      event: 'INSERT',
      schema: 'menuca_v3',
      table: 'promotional_deals',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      // Show notification toast
      showToast(`New deal: ${payload.new.name}`);
      // Refresh deals list
      refreshDeals();
    }
  )
  .subscribe();

// Cleanup on unmount
return () => supabase.removeChannel(channel);
```

---

#### **Feature 7: Check Coupon Usage**
**Backend:** ✅ Complete (reuses validate_coupon function)
**Frontend:** Need to build

**What to Build:**
1. **Usage Badge** (in coupon cards)
   - Show "Used 2 of 3 times"
   - Progress bar visualization
   - Disable if limit reached

**API Integration:**
```typescript
const { data: usage } = await supabase.rpc('check_coupon_usage_limit', {
  p_code: 'SAVE10',
  p_customer_id: userId
});

// Returns: {coupon_id, total_limit, total_used, total_remaining, customer_used, can_use}
```

---

## 🗂️ File Structure Plan

```
Frontend-build/customer-app/
├── app/
│   ├── checkout/
│   │   └── page.tsx                    ← Update with coupons
│   └── r/
│       └── [slug]/
│           └── page.tsx                ← Update with deals section
│
├── components/
│   ├── coupon-input.tsx               ← NEW: Coupon code input
│   ├── best-deal-banner.tsx           ← NEW: Auto-applied deal banner
│   ├── restaurant-deals-section.tsx   ← NEW: Deals display
│   ├── deal-card.tsx                  ← NEW: Individual deal card
│   ├── coupons-modal.tsx              ← NEW: All coupons modal
│   ├── flash-sale-banner.tsx          ← NEW: Flash sale with countdown
│   ├── tag-filter.tsx                 ← NEW: Tag-based filtering
│   └── deal-notification-toast.tsx    ← NEW: Real-time notifications
│
├── hooks/
│   ├── useDealSubscription.ts         ← NEW: WebSocket subscription
│   └── useCouponValidation.ts         ← NEW: Coupon validation hook
│
└── lib/
    ├── promotions/
    │   ├── types.ts                   ← NEW: TypeScript interfaces
    │   └── api.ts                     ← NEW: Promotion API wrappers
    └── utils/
        └── discount-formatter.ts      ← NEW: Format discount displays
```

---

## 📊 Implementation Phases

### **Phase 1: Checkout Integration (3-4 days)**
- [ ] Coupon input component
- [ ] Coupon validation integration
- [ ] Auto-apply best deal logic
- [ ] Update order creation to include coupons
- [ ] Error handling for all edge cases
- [ ] Testing with various coupon types

**Deliverable:** Functional coupon system at checkout

---

### **Phase 2: Restaurant Page Enhancements (3-4 days)**
- [ ] Deals section component
- [ ] Deal card design
- [ ] Multi-language support
- [ ] Flash sale banners
- [ ] Flash sale claim flow
- [ ] Coupons modal

**Deliverable:** Rich promotional content on restaurant pages

---

### **Phase 3: Discovery & Filtering (2-3 days)**
- [ ] Tag filter component
- [ ] Home page filtering
- [ ] Cuisine-based browsing
- [ ] Deal-based restaurant discovery

**Deliverable:** Enhanced restaurant discovery features

---

### **Phase 4: Real-Time Features (2-3 days)**
- [ ] WebSocket subscription setup
- [ ] Deal notification toasts
- [ ] Real-time deal updates
- [ ] Coupon usage tracking

**Deliverable:** Live promotional updates

---

## 🎨 Design System Integration

### Color Scheme:
- **Deals/Promos:** `bg-green-50`, `text-green-700`, `border-green-200`
- **Flash Sales:** `bg-red-50`, `text-red-700`, `border-red-200`
- **Discounts:** `bg-yellow-50`, `text-yellow-700`
- **Success States:** `bg-emerald-50`, `text-emerald-700`

### Typography:
- Deal titles: `text-xl font-bold`
- Discount amounts: `text-2xl font-extrabold`
- Terms: `text-sm text-gray-600`
- Countdown timers: `text-lg font-mono font-bold`

### Components:
- Use existing UI patterns from checkout/cart
- Maintain consistency with current design language
- Mobile-first responsive design
- Accessibility: ARIA labels, keyboard navigation

---

## 🔗 API Endpoints Summary

### Customer-Facing RPCs:
```typescript
// Feature 1: Browse Deals
get_deals_i18n(restaurant_id, language, service_type?)
get_deal_with_translation(deal_id, language)
is_deal_active_now(deal_id)

// Feature 2: Apply Coupons
validate_coupon(code, restaurant_id, customer_id, order_total, service_type)
apply_coupon_to_order(order_id, coupon_code, discount_amount)
redeem_coupon(code, customer_id, order_id, discount_amount, order_total, ip_address, user_agent)

// Feature 3: Auto-Apply Best Deal
find_best_deal_for_order(restaurant_id, order_total, service_type, customer_id?)

// Feature 4: Flash Sales
claim_flash_sale_slot(deal_id, customer_id)

// Feature 5: Filter by Tags
get_restaurants_by_tag_i18n(tag_id, language)
get_restaurants_by_cuisine(cuisine_slug)

// Feature 6: View Coupons
get_available_coupons_i18n(restaurant_id, language, customer_id?)

// Feature 7: Check Usage
check_coupon_usage_limit(code, customer_id)
```

---

## 🧪 Testing Strategy

### Unit Tests:
- [ ] Coupon validation logic
- [ ] Discount calculation functions
- [ ] Date/time formatting utilities

### Integration Tests:
- [ ] Coupon application flow
- [ ] Deal auto-apply logic
- [ ] Flash sale claiming
- [ ] Real-time subscription handling

### E2E Tests:
- [ ] Complete checkout with coupon
- [ ] Browse deals, claim flash sale
- [ ] Filter restaurants by tags
- [ ] Multi-language switching

### Test Scenarios:
1. **Happy Path:** User applies valid coupon, gets discount
2. **Expired Coupon:** Show appropriate error message
3. **Minimum Order:** Warn user about minimum order amount
4. **Flash Sale:** Claim last slot, verify SOLD_OUT for next user
5. **Multi-Language:** Switch language, verify translations
6. **Auto-Apply:** Add items, verify best deal auto-applied
7. **Real-Time:** Admin creates deal, customer sees notification

---

## ⚠️ Important Considerations

### Security:
- **Never trust client-side validation** - Always validate server-side
- **Use RLS policies** - All Supabase queries respect RLS
- **Prevent coupon fraud** - Track IP addresses, user agents
- **Rate limiting** - Prevent abuse of validation endpoints

### Performance:
- **Cache deals data** - Use React Query with 5-minute stale time
- **Debounce coupon input** - Don't validate on every keystroke
- **Lazy load modals** - Code-split coupon/deal modals
- **Optimize WebSocket** - Limit active subscriptions

### User Experience:
- **Clear error messages** - User-friendly, not technical
- **Loading states** - Show spinners during API calls
- **Success feedback** - Celebrate savings with animations
- **Mobile-first** - Most orders from mobile devices
- **Accessibility** - Screen reader support, keyboard nav

---

## 📝 Next Steps

1. **Review this plan** with team/stakeholders
2. **Prioritize features** - Start with checkout (highest impact)
3. **Set up TypeScript types** from backend schema
4. **Create base components** - Reusable UI building blocks
5. **Implement Phase 1** - Checkout integration
6. **Test thoroughly** - Each feature before moving to next
7. **Deploy incrementally** - Feature flags for gradual rollout

---

## 📚 Resources

- **Backend Documentation:** `/documentation/Marketing & Promotions/Marketing & Promotions features.md`
- **API Reference:** Supabase RPC functions (see document)
- **Supabase Docs:** https://supabase.com/docs/guides/realtime
- **Next.js Docs:** https://nextjs.org/docs

---

**Status:** ✅ Plan Complete - Ready to Start Phase 1!
