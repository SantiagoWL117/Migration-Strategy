# Phase 6 Backend Documentation: Advanced Features  
## Marketing & Promotions Entity - For Backend Development

**Created:** January 17, 2025  
**Phase:** 6 of 7 - Dynamic Pricing, Flash Sales, Referrals  
**Status:** ✅ COMPLETE

---

## 🚨 **BUSINESS PROBLEM**

**Basic promotions aren't enough to compete:**
- Competitors have flash sales
- No referral program
- Manual deal selection is slow
- No time-based pricing

---

## ✅ **THE SOLUTION**

**5 advanced promotional features:**
1. Auto-apply best deal
2. Referral coupon generation
3. Flash sales with limited quantity
4. Dynamic time-based pricing
5. Atomic flash sale claims

---

## 🧩 **GAINED BUSINESS LOGIC**

### **1. Auto-Apply Best Deal:**
```typescript
const { data } = await supabase.rpc('auto_apply_best_deal', {
  p_restaurant_id: 123,
  p_order_total: 50.00,
  p_service_type: 'delivery',
  p_customer_id: customerId
});
// Returns best applicable deal automatically
```

### **2. Generate Referral Coupon:**
```typescript
const { data } = await supabase.rpc('generate_referral_coupon', {
  p_referrer_customer_id: referrerId,
  p_discount_value: 10.00,
  p_valid_days: 30
});
// Creates unique referral code: REF123ABC
```

### **3. Flash Sales:**
```typescript
// Create flash sale
const { data } = await supabase.rpc('create_flash_sale', {
  p_restaurant_id: 123,
  p_title: '⚡ 50% Off - Next 100 Orders!',
  p_discount_value: 50,
  p_quantity_limit: 100,
  p_duration_hours: 24
});

// Customer claims slot
const { data: claim } = await supabase.rpc('claim_flash_sale_slot', {
  p_deal_id: flashSaleId,
  p_customer_id: customerId
});
```

### **4. Time-Based Pricing:**
```typescript
// Check if happy hour deal is active now
const { data: isActive } = await supabase.rpc('is_deal_active_now', {
  p_deal_id: happyHourDealId
});
```

---

## 💻 **BACKEND APIS**

**Checkout Flow with Auto-Apply:**
```typescript
// POST /api/checkout
export async function checkout(req, res) {
  const { restaurant_id, items, service_type } = req.body;
  const customerId = req.user.id;
  const orderTotal = calculateTotal(items);
  
  // Auto-apply best deal
  const { data: bestDeal } = await supabase.rpc('auto_apply_best_deal', {
    p_restaurant_id: restaurant_id,
    p_order_total: orderTotal,
    p_service_type: service_type,
    p_customer_id: customerId
  });
  
  if (bestDeal.has_deal) {
    // Apply best deal automatically
    return res.json({
      subtotal: orderTotal,
      discount: bestDeal.discount_amount,
      total: bestDeal.final_total,
      deal_applied: bestDeal.deal_title
    });
  }
  
  res.json({ subtotal: orderTotal, total: orderTotal });
}
```

---

## 🗄️ **SCHEMA MODIFICATIONS**

**Functions:** 5 advanced features  
**Atomic Operations:** Flash sale slot claiming  
**Dynamic Logic:** Time-based deal activation

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 6 Complete** - Advanced features ready
2. ⏳ **Phase 7: Testing & Completion** - Final documentation

---

**Status:** ✅ Advanced promotional features complete! 🚀

