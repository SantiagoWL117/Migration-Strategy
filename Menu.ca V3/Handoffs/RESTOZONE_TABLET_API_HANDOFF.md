# RestoZone Tablet API - Handoff Document

> **Created:** 2026-01-23  
> **Status:** ✅ Ready for Integration  
> **Audience:** Tablet App Developers

---

## Overview

This document describes the tablet API endpoints for dispatching drivers via RestoZone. The API contracts (request/response formats) **have not changed** - only the internal implementation now uses database configuration instead of hardcoded values.

---

## What Changed (Backend Only)

| Aspect | Old System | New System |
|--------|------------|------------|
| **Configuration source** | Hardcoded `RESTOZONE_RESTAURANTS` array in code | Database tables |
| **Adding new restaurants** | Code change + deployment | Database UPDATE |
| **Removing restaurants** | Code change + deployment | Database UPDATE |
| **API endpoints** | ❌ No change | ❌ No change |
| **Request format** | ❌ No change | ❌ No change |
| **Response format** | ❌ No change | ❌ No change |

### Old System (Hardcoded)

```typescript
// lib/restozone/config.ts
export const RESTOZONE_RESTAURANTS = [
  { v3Id: 131, restozoneId: 255, name: 'Centertown Donair & Pizza' },
  { v3Id: 87,  restozoneId: 203, name: 'Champa Thai Cuisine' },
  { v3Id: 943, restozoneId: 323, name: 'Charm Thai Cuisine' },
  // ... more hardcoded entries
];
```

### New System (Database-Driven)

```sql
-- Configuration now lives in database
SELECT 
  dpc.delivery_provider_external_id as restozone_id,
  dp.code as provider
FROM menuca_v3.delivery_and_pickup_configs dpc
JOIN menuca_v3.delivery_providers dp ON dpc.delivery_provider_id = dp.id
WHERE dpc.restaurant_id = 131;

-- Result: restozone_id = '255', provider = 'restozone'
```

---

## Tablet API Endpoints

### 1. Check Dispatch Availability

Determines if the "Request Driver" button should be shown.

#### Request

```
GET /api/tablet/orders/{orderId}/dispatch-driver
```

**Headers:**
| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | `Bearer <session_token>` |
| `X-Device-Id` | Yes | Device ID from registration |
| `X-Device-Key` | Yes | Device authentication key |

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `orderId` | integer | The order's numeric ID (not UUID) |

#### Response

**Success (200):**
```json
{
  "uses_restozone": true,
  "restozone_id": 255,
  "dispatch_available": true
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `uses_restozone` | boolean | Restaurant uses RestoZone for delivery |
| `restozone_id` | integer \| null | Restaurant's ID in RestoZone system |
| `dispatch_available` | boolean | Can dispatch driver for this order right now |

**When `dispatch_available` is false:**

| Scenario | `uses_restozone` | `restozone_id` | `dispatch_available` |
|----------|------------------|----------------|---------------------|
| Restaurant doesn't use RestoZone | `false` | `null` | `false` |
| Order is not delivery type | `true` | `255` | `false` |
| Order status not valid for dispatch | `true` | `255` | `false` |
| Driver already dispatched | `true` | `255` | `false` |

**Error Responses:**

| Code | Error | Cause |
|------|-------|-------|
| 401 | Unauthorized | Missing or invalid token |
| 404 | Order not found | Order doesn't exist or wrong restaurant |

---

### 2. Request Driver Dispatch

Dispatches a driver through RestoZone.

#### Request

```
POST /api/tablet/orders/{orderId}/dispatch-driver
```

**Headers:**
| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | `Bearer <session_token>` |
| `X-Device-Id` | Yes | Device ID from registration |
| `X-Device-Key` | Yes | Device authentication key |
| `Content-Type` | Yes | `application/json` |

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `orderId` | integer | The order's numeric ID (not UUID) |

**Request Body (Optional):**

All fields are optional overrides. If not provided, values are calculated from order data.

```json
{
  "prepTime": "18:30",
  "driverEarning": 8.00,
  "distanceKm": 6,
  "postalCode": "K1R6J6"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `prepTime` | string | Override prep/ready time (HH:MM format) |
| `driverEarning` | number | Override driver earning amount |
| `distanceKm` | number | Override distance in kilometers |
| `postalCode` | string | Override postal code |

#### Response

**Success (200):**
```json
{
  "success": true,
  "order_id": 12345,
  "used_backup_email": false,
  "message": "Driver request sent to RestoZone"
}
```

**Success with Fallback (200):**
```json
{
  "success": true,
  "order_id": 12345,
  "used_backup_email": true,
  "message": "Driver request sent via backup email"
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether dispatch request was successful |
| `order_id` | integer | The order ID that was dispatched |
| `used_backup_email` | boolean | True if RestoZone API failed and backup email was sent |
| `message` | string | Human-readable status message |

**Error Responses:**

| Code | Error | Cause |
|------|-------|-------|
| 400 | Invalid order ID | ID is not a number |
| 400 | Order not eligible for dispatch | Wrong order type or status |
| 400 | Restaurant not configured for RestoZone | No provider configured |
| 401 | Unauthorized | Missing or invalid token |
| 404 | Order not found | Order doesn't exist or wrong restaurant |
| 500 | Dispatch failed | Both RestoZone API and backup email failed |

---

## UI Integration Guide

### When to Show "Request Driver" Button

```typescript
// Only show button when ALL conditions are true
const shouldShowDispatchButton = (order: Order, dispatchCheck: DispatchCheck) => {
  return (
    order.order_type === 'delivery' &&
    ['confirmed', 'preparing', 'ready'].includes(order.order_status) &&
    dispatchCheck.uses_restozone &&
    dispatchCheck.dispatch_available
  );
};
```

### Complete Integration Example

```typescript
import { useState, useEffect } from 'react';

interface DispatchCheck {
  uses_restozone: boolean;
  restozone_id: number | null;
  dispatch_available: boolean;
}

interface DispatchResult {
  success: boolean;
  order_id: number;
  used_backup_email: boolean;
  message: string;
}

// Hook to check dispatch availability
const useDispatchAvailability = (orderId: number, deviceId: string, deviceKey: string) => {
  const [dispatchInfo, setDispatchInfo] = useState<DispatchCheck | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkDispatch = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/tablet/orders/${orderId}/dispatch-driver`, {
          method: 'GET',
          headers: {
            'X-Device-Id': deviceId,
            'X-Device-Key': deviceKey,
          },
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const data: DispatchCheck = await response.json();
        setDispatchInfo(data);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to check dispatch');
        setDispatchInfo(null);
      } finally {
        setLoading(false);
      }
    };

    checkDispatch();
  }, [orderId, deviceId, deviceKey]);

  return { dispatchInfo, loading, error };
};

// Function to request driver
const requestDriver = async (
  orderId: number,
  deviceId: string,
  deviceKey: string,
  overrides?: {
    prepTime?: string;
    driverEarning?: number;
    distanceKm?: number;
    postalCode?: string;
  }
): Promise<DispatchResult> => {
  const response = await fetch(`/api/tablet/orders/${orderId}/dispatch-driver`, {
    method: 'POST',
    headers: {
      'X-Device-Id': deviceId,
      'X-Device-Key': deviceKey,
      'Content-Type': 'application/json',
    },
    body: overrides ? JSON.stringify(overrides) : undefined,
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || `HTTP ${response.status}`);
  }

  return response.json();
};

// Example Component
const OrderActions: React.FC<{ order: Order }> = ({ order }) => {
  const { deviceId, deviceKey } = useDeviceAuth();
  const { dispatchInfo, loading } = useDispatchAvailability(order.id, deviceId, deviceKey);
  const [dispatching, setDispatching] = useState(false);

  const handleDispatch = async () => {
    try {
      setDispatching(true);
      const result = await requestDriver(order.id, deviceId, deviceKey);
      
      if (result.used_backup_email) {
        showToast('Driver requested via backup email', 'warning');
      } else {
        showToast('Driver requested successfully', 'success');
      }
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Failed to request driver', 'error');
    } finally {
      setDispatching(false);
    }
  };

  const canDispatch = 
    order.order_type === 'delivery' &&
    ['confirmed', 'preparing', 'ready'].includes(order.order_status) &&
    dispatchInfo?.uses_restozone &&
    dispatchInfo?.dispatch_available;

  return (
    <View style={styles.actions}>
      {/* Always show standard actions */}
      <Button title="Print Receipt" onPress={handlePrint} />
      
      {/* Only show dispatch button for RestoZone restaurants */}
      {loading ? (
        <ActivityIndicator />
      ) : canDispatch ? (
        <Button
          title={dispatching ? 'Requesting...' : 'Request Driver'}
          onPress={handleDispatch}
          disabled={dispatching}
          color="#4CAF50"
        />
      ) : null}
    </View>
  );
};
```

---

## Configured Restaurants (Current)

| Restaurant | V3 ID | RestoZone ID | Delivery Enabled |
|------------|-------|--------------|------------------|
| Centertown Donair & Pizza | 131 | 255 | ✅ Yes |
| Champa Thai Cuisine | 87 | 203 | ✅ Yes |
| Charm Thai Cuisine | 943 | 323 | ❌ No |
| Lemongrass Thai Cuisine | 1010 | 219 | ❌ No |
| New Mee Fung Restaurant | 15 | 101 | ❌ No |
| Oh My Grill | 807 | 1051 | ✅ Yes |
| Pho Bo Ga King - Somerset | 199 | 337 | ❌ No |
| Sushiyana | 847 | 1094 | ✅ Yes |

**Note:** 4 restaurants have RestoZone configured but `has_delivery_enabled = false`. The dispatch button will not appear for these restaurants.

---

## Fallback Behavior

When the RestoZone API fails, the system automatically sends backup emails:

| Email | Recipient |
|-------|-----------|
| Deliveryzonecanada@gmail.com | Primary dispatch |
| mattmenuottawa2@gmail.com | Secondary dispatch |
| restozonedispatch@gmail.com | RestoZone dispatch |

The response will include `"used_backup_email": true` so the UI can show an appropriate message.

---

## Testing Checklist

### For Tablet Developers

- [ ] Verify `GET /dispatch-driver` returns correct `uses_restozone` for RestoZone restaurant
- [ ] Verify `GET /dispatch-driver` returns `uses_restozone: false` for non-RestoZone restaurant
- [ ] Verify "Request Driver" button only shows for delivery orders
- [ ] Verify "Request Driver" button only shows for valid statuses (confirmed, preparing, ready)
- [ ] Verify `POST /dispatch-driver` shows success toast
- [ ] Verify backup email scenario shows warning toast
- [ ] Verify error handling for 401, 404, 500 responses

### Test Restaurant IDs

| Scenario | Restaurant ID | Expected `uses_restozone` |
|----------|---------------|---------------------------|
| RestoZone restaurant | 131, 87, 807, 847 | `true` |
| Non-RestoZone restaurant | Any other ID | `false` |

---

## Sequence Diagram

```
┌─────────┐          ┌─────────┐          ┌──────────┐          ┌───────────┐
│ Tablet  │          │   API   │          │ Database │          │ RestoZone │
└────┬────┘          └────┬────┘          └────┬─────┘          └─────┬─────┘
     │                    │                    │                      │
     │ GET /dispatch-driver                    │                      │
     │───────────────────>│                    │                      │
     │                    │ Query provider     │                      │
     │                    │───────────────────>│                      │
     │                    │<───────────────────│                      │
     │                    │ (provider_id=1,    │                      │
     │                    │  external_id=255)  │                      │
     │<───────────────────│                    │                      │
     │ { uses_restozone: true, ... }           │                      │
     │                    │                    │                      │
     │ [User taps "Request Driver"]            │                      │
     │                    │                    │                      │
     │ POST /dispatch-driver                   │                      │
     │───────────────────>│                    │                      │
     │                    │ Get order details  │                      │
     │                    │───────────────────>│                      │
     │                    │<───────────────────│                      │
     │                    │                    │                      │
     │                    │ POST /request_delivery (idresto=255)      │
     │                    │───────────────────────────────────────────>│
     │                    │<───────────────────────────────────────────│
     │                    │ { success: true }  │                      │
     │<───────────────────│                    │                      │
     │ { success: true, used_backup_email: false }                    │
     │                    │                    │                      │
```

---

## Related Documents

- [DELIVERY_PROVIDERS_HANDOFF.md](./DELIVERY_PROVIDERS_HANDOFF.md) - Database schema for providers
- [DISTANCE_BASED_RESTAURANTS_HANDOFF.md](./DISTANCE_BASED_RESTAURANTS_HANDOFF.md) - Fee tier details
- [02-delivery-zones-entity.md](../entities/02-delivery-zones-entity.md) - Full entity documentation

---

**Document Created:** 2026-01-23
