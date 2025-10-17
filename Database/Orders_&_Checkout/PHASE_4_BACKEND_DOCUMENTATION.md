# Phase 4 Backend Documentation: Real-Time Updates
## Orders & Checkout Entity

**Phase:** 4 of 7 - WebSocket Subscriptions & Live Tracking  
**Status:** ✅ COMPLETE

---

## 🚨 **BUSINESS PROBLEM**

Customers and restaurants need instant order updates without refreshing.

---

## ✅ **THE SOLUTION**

**Supabase Realtime + pg_notify** for live updates

---

## 🧩 **GAINED BUSINESS LOGIC**

**Realtime Tables:** `orders`, `order_status_history`  
**Notification Channels:** New orders, status changes

---

## 💻 **BACKEND IMPLEMENTATION**

**Customer Subscription:**
```typescript
const orderSub = supabase
  .channel(`order:${orderId}`)
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'menuca_v3',
    table: 'orders',
    filter: `id=eq.${orderId}`
  }, (payload) => {
    updateUI(payload.new.status);
  })
  .subscribe();
```

**Restaurant Subscription:**
```typescript
const restaurantSub = supabase
  .channel(`restaurant:${restaurantId}`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'menuca_v3',
    table: 'orders',
    filter: `restaurant_id=eq.${restaurantId}`
  }, (payload) => {
    showNewOrderAlert(payload.new);
  })
  .subscribe();
```

---

**Status:** ✅ Real-time tracking ready! 🔴
