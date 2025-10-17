# Phase 4 Backend Documentation: Real-Time Updates
## Marketing & Promotions Entity - For Backend Development

**Created:** January 17, 2025  
**Phase:** 4 of 7 - WebSocket Subscriptions & Live Notifications  
**Status:** ✅ COMPLETE - Ready for Backend Implementation

---

## 🚨 **BUSINESS PROBLEM**

Customers and restaurants need **instant updates** for promotions:
- **Delayed Notifications:** Customers miss flash sales
- **Stale Data:** Admin dashboards show outdated stats
- **No Live Updates:** Must refresh page to see new deals
- **Missed Opportunities:** Coupons expire without warning
- **Poor UX:** Static, non-responsive promotion displays

**Impact:** Lost revenue from missed promotions, poor customer experience, and inefficient restaurant management.

---

## ✅ **THE SOLUTION**

Implement **Supabase Realtime + pg_notify** for instant updates:
1. **WebSocket Subscriptions** - Live data streaming
2. **Event Notifications** - pg_notify channels
3. **Live Analytics** - Real-time performance metrics
4. **Expiry Warnings** - Proactive alerts
5. **Multi-Channel Broadcasts** - Targeted notifications

---

## 🧩 **GAINED BUSINESS LOGIC COMPONENTS**

### **Realtime Tables (5):**
- ✅ promotional_deals
- ✅ promotional_coupons
- ✅ marketing_tags
- ✅ restaurant_tag_associations
- ✅ coupon_usage_log

### **Notification Channels (10+):**
- `deal_published` - Global deal notifications
- `restaurant_{id}_deal_published` - Restaurant-specific
- `restaurant_{id}_deal_status` - Status changes
- `restaurant_{id}_coupon_created` - New coupons
- `restaurant_{id}_coupon_redeemed` - Redemptions
- `customer_{id}_coupon_redeemed` - Customer savings
- `coupon_limit_reached` - Usage limits
- `restaurant_{id}_deal_expiring` - Expiry warnings

### **Backend Implementation Examples:**

**Customer App - Subscribe to New Deals:**
```typescript
// Real-time new deal notifications
const dealsSub = supabase
  .channel(`restaurant:${restaurantId}:deals`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'menuca_v3',
    table: 'promotional_deals',
    filter: `restaurant_id=eq.${restaurantId},is_active=eq.true`
  }, (payload) => {
    showNotification({
      title: 'New Deal Available!',
      message: payload.new.title,
      action: 'View Deal'
    });
  })
  .subscribe();
```

**Restaurant Dashboard - Live Coupon Redemptions:**
```typescript
// WebSocket connection for live redemptions
const redemptionsSub = supabase
  .channel(`restaurant:${restaurantId}:redemptions`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'menuca_v3',
    table: 'coupon_usage_log',
    filter: `restaurant_id=eq.${restaurantId}`
  }, (payload) => {
    // Update live dashboard
    incrementRedemptionCount();
    addToRecentActivity(payload.new);
    playSuccessSound();
  })
  .subscribe();
```

**Admin - pg_notify Listener:**
```typescript
// Listen for custom pg_notify events
const pgNotifyChannel = supabase
  .channel('custom-notifications')
  .on('postgres_changes', {
    event: '*',
    schema: 'menuca_v3',
    table: 'promotional_deals'
  }, (payload) => {
    console.log('Deal change detected:', payload);
  })
  .subscribe();

// Or use native pg_notify (requires backend websocket)
pg.on('notification', (msg) => {
  if (msg.channel === 'deal_published') {
    const data = JSON.parse(msg.payload);
    broadcast ToAllClients('new_deal', data);
  }
});
```

**Live Analytics Dashboard:**
```typescript
// Fetch live performance every 30 seconds
setInterval(async () => {
  const { data: liveStats } = await supabase.rpc('get_live_deal_performance', {
    p_restaurant_id: restaurantId
  });
  
  updateDashboard(liveStats);
}, 30000);
```

---

## 💻 **BACKEND FUNCTIONALITY REQUIRED**

### **Priority 1: WebSocket Infrastructure** ✅ CRITICAL
- Set up Supabase Realtime client
- Handle connection/disconnection
- Implement reconnection logic
- Manage subscription lifecycle

### **Priority 2: Notification System** ⚠️ IMPORTANT
- Subscribe to pg_notify channels
- Broadcast to frontend clients
- Filter by user permissions
- Rate limit notifications

### **Priority 3: Live Dashboards** 💡 NICE TO HAVE
- Real-time analytics widgets
- Live redemption counters
- Active deals ticker
- Performance graphs

---

## 🗄️ **SCHEMA MODIFICATIONS**

**Realtime Enabled:** 5 tables  
**Notification Triggers:** 5  
**Real-Time Functions:** 4  
**Channels:** 10+ for targeted notifications

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 4 Complete** - Real-time infrastructure ready
2. ⏳ **Santiago: Implement WebSockets** - Connect frontend to realtime
3. ⏳ **Phase 5: Multi-Language** - Translation tables
4. ⏳ **Phase 6: Advanced Features** - Flash sales, referrals

---

**Status:** ✅ Real-time updates complete, live notifications ready! 🔴

