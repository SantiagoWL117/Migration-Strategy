# Order Flow

> **Order Processing Pipeline** - From cart to completion

---

## 📋 Overview

The order flow describes how an order moves through the system:
1. **Cart Creation** - Items added to cart
2. **Checkout** - Cart converted to order
3. **Payment** - Payment processed
4. **Fulfillment** - Order prepared and delivered
5. **Completion** - Order marked complete

---

## 🔄 Order Lifecycle

```
┌────────────────────────────────────────────────────────────────────────────┐
│                           ORDER LIFECYCLE                                   │
└────────────────────────────────────────────────────────────────────────────┘

    User Action                 System Tables              Order Status
    ───────────                 ─────────────              ────────────

    Add to Cart ──────────────► carts                     (no order yet)
                                cart_items
                                    │
                                    ▼
    Place Order ──────────────► orders ◄──────────────── pending
                                order_items               │
                                    │                     │
                                    ▼                     ▼
    Pay ──────────────────────► payment_transactions     paid
                                    │                     │
                                    ▼                     ▼
    Restaurant Confirms ──────► orders.status ────────── confirmed
                                order_status_history      │
                                    │                     │
                                    ▼                     ▼
    Start Preparing ──────────► orders.status ────────── preparing
                                    │                     │
                                    ▼                     ▼
    Ready for Pickup/Delivery ► orders.status ────────── ready
                                    │                     │
                                    ▼                     ▼
    Out for Delivery ─────────► orders.status ────────── out_for_delivery
    (delivery only)                 │                     │
                                    ▼                     ▼
    Delivered/Picked Up ──────► orders.status ────────── completed
                                orders.actual_delivered_at

    ─────────────────────────── ALTERNATIVE FLOWS ───────────────────────────

    Cancel Order ─────────────► orders.status ────────── cancelled
                                orders.cancelled_at
                                orders.cancelled_reason
                                    │
                                    ▼
    Process Refund ───────────► refunds ──────────────── refunded
                                orders.refund_amount
```

---

## 📊 Tables Involved

### Cart Phase

| Table | Purpose |
|-------|---------|
| `carts` | Shopping cart header |
| `cart_items` | Items in cart |

### Order Phase

| Table | Purpose |
|-------|---------|
| `orders` | Order header |
| `order_items` | Order line items |
| `order_item_modifiers` | Modifiers on items |
| `order_status_history` | Status audit trail |

### Payment Phase

| Table | Purpose |
|-------|---------|
| `payment_transactions` | Payment records |
| `refunds` | Refund records |

---

## 🔑 Order Status Values

| Status | Description | Next States |
|--------|-------------|-------------|
| `pending` | Order created, awaiting payment | `paid`, `cancelled` |
| `paid` | Payment received | `confirmed`, `cancelled` |
| `confirmed` | Restaurant accepted | `preparing`, `cancelled` |
| `preparing` | Being made | `ready`, `cancelled` |
| `ready` | Ready for pickup/delivery | `out_for_delivery`, `completed` |
| `out_for_delivery` | Driver dispatched | `completed` |
| `completed` | Order fulfilled | - |
| `cancelled` | Order cancelled | - |
| `refunded` | Payment refunded | - |

---

## 💰 Order Calculations

### Order Total Formula

```
order_total = subtotal + tax_amount + delivery_fee - discount_amount + tip_amount

Where:
  subtotal = SUM(order_items.unit_price * order_items.quantity)
           + SUM(modifier_prices)
  
  tax_amount = subtotal * tax_rate (typically 13% HST in Ontario)
  
  delivery_fee = from restaurant_delivery_zones based on address
  
  discount_amount = from coupon/promotion if applied
  
  tip_amount = customer-selected tip
```

### SQL Example

```sql
SELECT 
    o.id,
    o.subtotal,
    o.tax_amount,
    o.delivery_fee,
    o.discount_amount,
    o.tip_amount,
    o.total,
    (o.subtotal + o.tax_amount + o.delivery_fee - o.discount_amount + o.tip_amount) as calculated_total
FROM menuca_v3.orders o
WHERE o.id = :order_id;
```

---

## 🔄 Cart to Order Conversion

When checkout is triggered:

```sql
-- 1. Create order from cart
INSERT INTO menuca_v3.orders (
    restaurant_id, user_id, order_number, status, order_type,
    subtotal, tax_amount, delivery_fee, total, delivery_address
)
SELECT 
    c.restaurant_id,
    c.user_id,
    generate_order_number(), -- custom function
    'pending',
    :order_type,
    c.subtotal,
    c.subtotal * 0.13, -- HST
    :delivery_fee,
    c.subtotal + (c.subtotal * 0.13) + :delivery_fee,
    :delivery_address
FROM menuca_v3.carts c
WHERE c.id = :cart_id
RETURNING id INTO :order_id;

-- 2. Copy cart items to order items
INSERT INTO menuca_v3.order_items (
    order_id, dish_id, quantity, unit_price, size_variant, subtotal, modifiers
)
SELECT 
    :order_id,
    ci.dish_id,
    ci.quantity,
    ci.unit_price,
    ci.size_variant,
    ci.unit_price * ci.quantity,
    ci.modifiers
FROM menuca_v3.cart_items ci
WHERE ci.cart_id = :cart_id;

-- 3. Clear cart
DELETE FROM menuca_v3.cart_items WHERE cart_id = :cart_id;
DELETE FROM menuca_v3.carts WHERE id = :cart_id;
```

---

## 📝 Status Change Triggers

Status changes are logged automatically:

```sql
CREATE OR REPLACE FUNCTION menuca_v3.log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO menuca_v3.order_status_history (
            order_id, old_status, new_status, reason, changed_at
        ) VALUES (
            NEW.id, OLD.status, NEW.status, NEW.status_change_reason, NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔔 Real-time Notifications

Order status changes trigger real-time notifications:

1. **Restaurant Dashboard** - New order notification
2. **Customer** - Order status updates (SMS/email)
3. **Delivery Partner** - Ready for pickup notification

```sql
-- Supabase Realtime subscription pattern
-- Client subscribes to orders table changes
supabase
  .channel('orders')
  .on('postgres_changes', { 
    event: 'UPDATE', 
    schema: 'menuca_v3', 
    table: 'orders',
    filter: `restaurant_id=eq.${restaurantId}`
  }, handleOrderUpdate)
  .subscribe()
```

---

## ⚠️ Edge Cases

### Partial Refunds

```sql
-- Record partial refund
INSERT INTO menuca_v3.refunds (
    order_id, payment_transaction_id, amount, reason, status
) VALUES (
    :order_id, :payment_id, :partial_amount, :reason, 'processed'
);

-- Update order
UPDATE menuca_v3.orders 
SET refund_amount = COALESCE(refund_amount, 0) + :partial_amount
WHERE id = :order_id;
```

### Order Modifications (Before Confirmation)

- Items can be modified while `status = 'pending'`
- After payment, modifications require restaurant approval

### Failed Payments

```sql
-- Log failed payment
INSERT INTO menuca_v3.payment_transactions (
    order_id, amount, currency, status, error_message
) VALUES (
    :order_id, :amount, 'CAD', 'failed', :error_message
);

-- Order remains pending for retry
```

---

## 📈 Metrics & Analytics

### Common Queries

```sql
-- Orders per day by restaurant
SELECT 
    restaurant_id,
    DATE(created_at) as order_date,
    COUNT(*) as order_count,
    SUM(total) as revenue
FROM menuca_v3.orders
WHERE status = 'completed'
GROUP BY restaurant_id, DATE(created_at)
ORDER BY order_date DESC;

-- Average order value
SELECT 
    restaurant_id,
    AVG(total) as aov,
    AVG(tip_amount) as avg_tip
FROM menuca_v3.orders
WHERE status = 'completed'
GROUP BY restaurant_id;
```

---

**Last Updated:** 2025-11-27

