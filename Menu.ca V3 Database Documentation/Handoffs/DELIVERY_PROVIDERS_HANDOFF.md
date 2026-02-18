# Delivery Providers System - Handoff Document

> **Created:** 2026-01-23  
> **Status:** ✅ Complete  
> **Purpose:** Extensible third-party delivery provider integration

---

## Overview

This feature introduces an extensible system for integrating third-party delivery providers (RestoZone, Tookan, DoorDash Drive, Uber Direct, etc.) with Menu.ca restaurants.

### Key Concepts

- **One restaurant = One delivery provider** (1:1 relationship)
- **Multiple provider companies** are supported system-wide
- **External IDs** map Menu.ca restaurant IDs to provider-specific IDs
- **Provider capabilities** are tracked (fee API, dispatch API, tracking)

---

## Database Schema

### New Table: `delivery_providers`

Master list of third-party delivery provider companies.

```sql
CREATE TABLE menuca_v3.delivery_providers (
  id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT uuid_generate_v4(),
  code VARCHAR(50) NOT NULL UNIQUE,           -- 'restozone', 'tookan', etc.
  name VARCHAR(100) NOT NULL,                  -- 'RestoZone', 'Tookan', etc.
  api_base_url VARCHAR(255),                   -- Provider's API base URL
  is_active BOOLEAN DEFAULT true,
  supports_fee_api BOOLEAN DEFAULT false,      -- Can query fees from their API?
  supports_dispatch_api BOOLEAN DEFAULT false, -- Can dispatch drivers via API?
  supports_tracking BOOLEAN DEFAULT false,     -- Provides driver tracking?
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
```

### New Columns: `delivery_and_pickup_configs`

| Column                          | Type         | Description                              |
|---------------------------------|--------------|------------------------------------------|
| `delivery_provider_id`          | SMALLINT     | FK to delivery_providers                 |
| `delivery_provider_external_id` | VARCHAR(100) | Restaurant's ID in provider's system     |

---

## Current Data

### Delivery Providers (1)

| ID | Code      | Name      | API Base URL         | Fee API | Dispatch | Tracking |
|----|-----------|-----------|----------------------|---------|----------|----------|
| 1  | restozone | RestoZone | https://restozone.ca | ✅      | ✅       | ❌       |

**Note:** Additional providers (Tookan, DoorDash Drive, Uber Direct) can be added when needed using the `INSERT` statement in the SQL section below.

### RestoZone Restaurant Mappings (8)

| V3 ID | Restaurant                | RestoZone ID | Delivery Enabled |
|-------|---------------------------|--------------|------------------|
| 131   | Centertown Donair & Pizza | 255          | ✅ Yes           |
| 87    | Champa Thai Cuisine       | 203          | ✅ Yes           |
| 943   | Charm Thai Cuisine        | 323          | ❌ No            |
| 1010  | Lemongrass Thai Cuisine   | 219          | ❌ No            |
| 15    | New Mee Fung Restaurant   | 101          | ❌ No            |
| 807   | Oh My Grill               | 1051         | ✅ Yes           |
| 199   | Pho Bo Ga King - Somerset | 337          | ❌ No            |
| 847   | Sushiyana                 | 1094         | ✅ Yes           |

---

## API Integration Pattern

### Check if Restaurant Uses External Provider

```typescript
const getProviderForRestaurant = async (restaurantId: number) => {
  const { data } = await supabase
    .from('delivery_and_pickup_configs')
    .select(`
      has_delivery_enabled,
      distance_based_delivery_fee,
      delivery_provider_external_id,
      delivery_providers (
        id,
        code,
        name,
        api_base_url,
        supports_dispatch_api
      )
    `)
    .eq('restaurant_id', restaurantId)
    .single();
  
  return data;
};
```

### Dispatch Driver Flow

```typescript
const dispatchDriver = async (orderId: number) => {
  const order = await getOrder(orderId);
  const config = await getProviderForRestaurant(order.restaurant_id);
  
  if (!config?.delivery_providers) {
    throw new Error('No delivery provider configured');
  }

  // Get provider-specific adapter
  const adapter = getAdapter(config.delivery_providers.code);
  
  // Call provider's API with external ID
  return adapter.dispatch(order, config.delivery_provider_external_id);
};

// Provider adapters
const getAdapter = (providerCode: string) => {
  switch (providerCode) {
    case 'restozone': return new RestoZoneAdapter();
    case 'tookan': return new TookanAdapter();
    case 'doordash_drive': return new DoorDashAdapter();
    case 'uber_direct': return new UberDirectAdapter();
    default: throw new Error(`Unknown provider: ${providerCode}`);
  }
};
```

### RestoZone-Specific Implementation

```typescript
class RestoZoneAdapter {
  async dispatch(order: Order, externalId: string) {
    // RestoZone expects their restaurant ID, not ours
    const response = await fetch(
      'https://restozone.ca/api3rdparty/request_delivery/...',
      {
        method: 'POST',
        body: JSON.stringify({
          idresto: parseInt(externalId),  // 255, 203, etc.
          adresse: order.delivery_address,
          codepostal: order.postal_code,
          nomclient: order.customer_name,
          telclient: order.customer_phone,
          // ... other fields
        })
      }
    );
    return response.json();
  }
  
  async getFee(distance: number, externalId: string) {
    const response = await fetch(
      'https://restozone.ca/deliveryzone/api/fraislivraison',
      {
        method: 'POST',
        body: JSON.stringify({
          idresto: parseInt(externalId),
          distance: distance
        })
      }
    );
    return response.json();
  }
}
```

---

## SQL Queries

### Get All Restaurants with Providers

```sql
SELECT 
  r.id as v3_id,
  r.name as restaurant_name,
  dpc.distance_based_delivery_fee,
  dpc.has_delivery_enabled,
  dp.code as provider,
  dp.name as provider_name,
  dpc.delivery_provider_external_id as provider_id
FROM menuca_v3.restaurants r
JOIN menuca_v3.delivery_and_pickup_configs dpc ON r.id = dpc.restaurant_id
LEFT JOIN menuca_v3.delivery_providers dp ON dpc.delivery_provider_id = dp.id
WHERE dpc.delivery_provider_id IS NOT NULL
ORDER BY r.name;
```

### Add New Provider Company

```sql
INSERT INTO menuca_v3.delivery_providers 
  (code, name, api_base_url, supports_fee_api, supports_dispatch_api, supports_tracking)
VALUES 
  ('skip_courier', 'Skip Courier', 'https://api.skipcourier.com', true, true, false);
```

### Assign Provider to Restaurant

```sql
UPDATE menuca_v3.delivery_and_pickup_configs 
SET 
  delivery_provider_id = (SELECT id FROM menuca_v3.delivery_providers WHERE code = 'tookan'),
  delivery_provider_external_id = 'TOOKAN_REST_123'
WHERE restaurant_id = 456;
```

### Remove Provider from Restaurant

```sql
UPDATE menuca_v3.delivery_and_pickup_configs 
SET 
  delivery_provider_id = NULL,
  delivery_provider_external_id = NULL
WHERE restaurant_id = 456;
```

---

## RLS Policies

### `delivery_providers` Table

| Policy | Operation | Description |
|--------|-----------|-------------|
| `delivery_providers_public_read` | SELECT | Public can read active providers |
| `delivery_providers_service_role_all` | ALL | Service role full access |

---

## Architecture Benefits

| Benefit | Description |
|---------|-------------|
| **Extensible** | Add new providers by inserting rows, no code changes needed |
| **Clean 1:1** | Each restaurant has at most one provider |
| **External ID Mapping** | Translates Menu.ca IDs to provider-specific IDs |
| **Capability Tracking** | Know what each provider supports (fees, dispatch, tracking) |
| **Admin-Manageable** | Providers can be enabled/disabled without code deployment |

---

## Future Enhancements

1. **Provider-specific config column** - Add JSONB `config` column for API keys, credentials
2. **Rate limiting tracking** - Track API call limits per provider
3. **Fallback providers** - If primary provider fails, try secondary (requires schema change)
4. **Driver tracking integration** - Real-time tracking for providers that support it

---

## Migration SQL (Applied)

```sql
-- 1. Create delivery_providers table
CREATE TABLE menuca_v3.delivery_providers (
  id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT uuid_generate_v4(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  api_base_url VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  supports_fee_api BOOLEAN DEFAULT false,
  supports_dispatch_api BOOLEAN DEFAULT false,
  supports_tracking BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 2. Add columns to delivery_and_pickup_configs
ALTER TABLE menuca_v3.delivery_and_pickup_configs
ADD COLUMN delivery_provider_id SMALLINT REFERENCES menuca_v3.delivery_providers(id),
ADD COLUMN delivery_provider_external_id VARCHAR(100);

-- 3. Create index
CREATE INDEX idx_dpc_delivery_provider ON menuca_v3.delivery_and_pickup_configs(delivery_provider_id) 
WHERE delivery_provider_id IS NOT NULL;

-- 4. Seed RestoZone provider (only provider currently needed)
INSERT INTO menuca_v3.delivery_providers (code, name, api_base_url, supports_fee_api, supports_dispatch_api, supports_tracking)
VALUES 
  ('restozone', 'RestoZone', 'https://restozone.ca', true, true, false);

-- Future providers can be added when needed:
-- ('tookan', 'Tookan', 'https://api.tookanapp.com', true, true, true),
-- ('doordash_drive', 'DoorDash Drive', 'https://openapi.doordash.com', true, true, true),
-- ('uber_direct', 'Uber Direct', 'https://api.uber.com', true, true, true);

-- 5. Map RestoZone restaurants
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '255' WHERE restaurant_id = 131;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '203' WHERE restaurant_id = 87;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '323' WHERE restaurant_id = 943;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '219' WHERE restaurant_id = 1010;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '101' WHERE restaurant_id = 15;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '1051' WHERE restaurant_id = 807;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '337' WHERE restaurant_id = 199;
UPDATE menuca_v3.delivery_and_pickup_configs SET delivery_provider_id = 1, delivery_provider_external_id = '1094' WHERE restaurant_id = 847;

-- 6. Enable RLS
ALTER TABLE menuca_v3.delivery_providers ENABLE ROW LEVEL SECURITY;

CREATE POLICY delivery_providers_public_read ON menuca_v3.delivery_providers
FOR SELECT USING (is_active = true);

CREATE POLICY delivery_providers_service_role_all ON menuca_v3.delivery_providers
FOR ALL TO service_role USING (true) WITH CHECK (true);
```

---

## Related Documents

- [02-delivery-zones-entity.md](../entities/02-delivery-zones-entity.md) - Full entity documentation
- [DISTANCE_BASED_RESTAURANTS_HANDOFF.md](./DISTANCE_BASED_RESTAURANTS_HANDOFF.md) - Distance-based fee details

---

**Document Created:** 2026-01-23
