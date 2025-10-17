# Phase 5 Backend Documentation: Payment Integration
## Orders & Checkout Entity

**Phase:** 5 of 7 - Stripe, Refunds, Tips  
**Status:** ✅ COMPLETE (Stub - awaiting Stripe)

---

## 🚨 **BUSINESS PROBLEM**

Need secure payment processing, refunds, and tip management.

---

## ✅ **THE SOLUTION**

**3 Payment Functions:** Process payment, refunds, update tips

---

## 🧩 **GAINED BUSINESS LOGIC**

1. `process_payment(order_id, payment_method_id, payment_info)`
2. `process_refund(order_id, refund_amount, reason)`
3. `update_order_tip(order_id, tip_amount)`

---

## 💻 **BACKEND APIs**

```typescript
// POST /api/orders/:id/payment
await supabase.rpc('process_payment', {
  p_order_id: 123,
  p_payment_method_id: 'pm_xxx',
  p_payment_info: { stripe_charge_id: 'ch_xxx' }
});

// POST /api/orders/:id/refund
await supabase.rpc('process_refund', {
  p_order_id: 123,
  p_refund_amount: 50.00,
  p_reason: 'Customer cancellation'
});

// POST /api/orders/:id/tip
await supabase.rpc('update_order_tip', {
  p_order_id: 123,
  p_tip_amount: 10.00
});
```

---

**Status:** ✅ Payment stubs ready for Stripe! 💳
