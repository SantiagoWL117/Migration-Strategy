# Phase 5: Multi-Language Support - Orders & Checkout Entity
## Translation Tables for Global Reach

**Entity:** Orders & Checkout  
**Phase:** 5 of 7  
**Priority:** 🟢 LOW  
**Status:** ✅ **COMPLETE**  
**Date:** January 17, 2025  
**Duration:** 3 hours  
**Agent:** Agent 1 (Brian)

---

## 🎯 **PHASE OBJECTIVE**

Implement multi-language support for order statuses, messages, and user-facing text to enable global expansion.

**Goals:**
- ✅ Create translation tables for order content
- ✅ Support 3 languages: EN, ES, FR
- ✅ Implement automatic fallback (FR → EN)
- ✅ Update SQL functions to accept language parameter
- ✅ Document translation patterns for Santiago

---

## 🚨 **BUSINESS PROBLEM**

### **Before Phase 5 (English Only)**

```typescript
// PROBLEM: Hard-coded English text
const statusText = {
  'pending': 'Pending',
  'accepted': 'Accepted',
  'preparing': 'Preparing',
  'ready': 'Ready for Pickup',
  'completed': 'Completed'
}

// Can't serve:
// - Quebec (French required by law!)
// - Latin America (Spanish markets)
// - International expansion
```

**Problems:**
- 🚫 **Can't launch in Quebec** - French required by law (Bill 101)
- 📉 **Lost revenue** - Can't serve Spanish markets  
- 🌍 **No global expansion** - English-only platform
- ⚖️ **Legal risk** - Non-compliance with language laws
- 💔 **Poor UX** - Customers forced to use non-native language

---

## ✅ **THE SOLUTION: MULTI-LANGUAGE TABLES**

### **After Phase 5 (Global Ready)**

```typescript
// SOLUTION: Database-backed translations
const { data } = await supabase.rpc('get_order_status_text', {
  p_status: 'ready',
  p_lang: 'es'  // Spanish
})

// Returns: "Listo para Recoger" ✅

// Supported languages:
// - EN (English - default)
// - ES (Spanish - Latin America)
// - FR (French - Quebec)

// Automatic fallback:
// FR → EN if translation missing
```

**Benefits:**
- ✅ **Quebec ready** - French legal compliance
- ✅ **Latin America ready** - Spanish support
- ✅ **Global expansion** - Easy to add more languages
- ✅ **Legal compliance** - Meets language law requirements
- ✅ **Better UX** - Native language for all customers

---

## 🧩 **GAINED BUSINESS LOGIC COMPONENTS**

### **1. Translation Tables (3 tables)**

```sql
-- Order status translations
order_status_translations (status, language, text, description)

-- Cancellation reason translations  
order_cancellation_reasons_translations (reason_code, language, text)

-- Order type translations
order_type_translations (order_type, language, text)
```

### **2. Translation Functions (5 functions)**

```sql
-- Get order status in specific language
get_order_status_text(status, lang) → TEXT

-- Get cancellation reason text
get_cancellation_reason_text(reason_code, lang) → TEXT

-- Get order type text
get_order_type_text(order_type, lang) → TEXT

-- Get order details with translations
get_order_details_translated(order_id, user_id, lang) → JSONB

-- Get order history with translations
get_customer_order_history_translated(user_id, lang, limit, offset) → JSONB
```

### **3. Supported Languages**

- **EN** - English (default, fallback)
- **ES** - Spanish (Latin America)
- **FR** - French (Quebec)

---

## 💻 **BACKEND FUNCTIONALITY REQUIREMENTS**

### **API Endpoints with Language Support**

#### **1. Get Order Details (Translated)**

```typescript
/**
 * GET /api/orders/:id?lang=es
 * Get order details in specified language
 */
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const session = await getSession(request)
  const orderId = parseInt(params.id)
  const url = new URL(request.url)
  const lang = url.searchParams.get('lang') || 'en'
  
  const { data, error } = await supabase.rpc('get_order_details_translated', {
    p_order_id: orderId,
    p_user_id: session.user.id,
    p_lang: lang
  })
  
  if (error || !data) {
    return Response.json({ error: 'Order not found' }, { status: 404 })
  }
  
  return Response.json({ order: data })
}

// Example response (Spanish):
{
  "order": {
    "id": 12345,
    "order_number": "#ORD-12345",
    "status": "preparing",
    "status_text": "Preparando",  // ← Translated!
    "order_type": "delivery",
    "order_type_text": "Entrega a Domicilio",  // ← Translated!
    "placed_at": "2025-01-17T10:30:00Z",
    "grand_total": 43.39,
    "status_history": [
      {
        "status": "pending",
        "status_text": "Pendiente",  // ← Translated!
        "changed_at": "2025-01-17T10:30:00Z"
      },
      {
        "status": "accepted",
        "status_text": "Aceptado",  // ← Translated!
        "changed_at": "2025-01-17T10:32:00Z"
      },
      {
        "status": "preparing",
        "status_text": "Preparando",  // ← Translated!
        "changed_at": "2025-01-17T10:35:00Z"
      }
    ]
  }
}
```

#### **2. Get Order History (Translated)**

```typescript
/**
 * GET /api/orders/me?lang=fr
 * Get customer order history in specified language
 */
export async function GET(request: Request) {
  const session = await getSession(request)
  const url = new URL(request.url)
  const lang = url.searchParams.get('lang') || 'en'
  const limit = parseInt(url.searchParams.get('limit') || '20')
  const offset = parseInt(url.searchParams.get('offset') || '0')
  
  const { data, error } = await supabase.rpc('get_customer_order_history_translated', {
    p_user_id: session.user.id,
    p_lang: lang,
    p_limit: limit,
    p_offset: offset
  })
  
  if (error) {
    return Response.json({ error: error.message }, { status: 500 })
  }
  
  return Response.json({ orders: data.orders, total: data.total_count })
}

// Example response (French):
{
  "orders": [
    {
      "id": 12345,
      "order_number": "#ORD-12345",
      "status": "completed",
      "status_text": "Terminé",  // ← French!
      "order_type": "delivery",
      "order_type_text": "Livraison",  // ← French!
      "placed_at": "2025-01-17T10:30:00Z",
      "grand_total": 43.39,
      "restaurant_name": "Tony's Pizza"
    }
  ],
  "total": 25
}
```

#### **3. Cancel Order (Translated Reasons)**

```typescript
/**
 * PUT /api/orders/:id/cancel
 * Cancel order with translated reason
 */
export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  const session = await getSession(request)
  const orderId = parseInt(params.id)
  const { reason_code, lang } = await request.json()
  
  // Get translated reason text
  const { data: reasonText } = await supabase.rpc('get_cancellation_reason_text', {
    p_reason_code: reason_code,
    p_lang: lang || 'en'
  })
  
  // Cancel order
  const { data, error } = await supabase.rpc('cancel_order', {
    p_order_id: orderId,
    p_user_id: session.user.id,
    p_reason: reasonText
  })
  
  return Response.json({ order: data })
}

// Example cancellation reasons:
// EN: "Changed my mind", "Wrong address", "Too long wait"
// ES: "Cambié de opinión", "Dirección incorrecta", "Espera muy larga"
// FR: "J'ai changé d'avis", "Mauvaise adresse", "Attente trop longue"
```

---

## 🗄️ **MENUCA_V3 SCHEMA MODIFICATIONS**

### **1. Create Translation Tables**

```sql
-- Order status translations
CREATE TABLE menuca_v3.order_status_translations (
  id SERIAL PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(status, language)
);

-- Order type translations
CREATE TABLE menuca_v3.order_type_translations (
  id SERIAL PRIMARY KEY,
  order_type VARCHAR(20) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(order_type, language)
);

-- Cancellation reason translations
CREATE TABLE menuca_v3.order_cancellation_reasons_translations (
  id SERIAL PRIMARY KEY,
  reason_code VARCHAR(50) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(reason_code, language)
);
```

### **2. Populate Translation Data**

```sql
-- Insert order status translations (EN/ES/FR)
INSERT INTO menuca_v3.order_status_translations (status, language, text, description) VALUES
  -- English
  ('pending', 'en', 'Pending', 'Waiting for restaurant to accept'),
  ('accepted', 'en', 'Accepted', 'Restaurant accepted your order'),
  ('preparing', 'en', 'Preparing', 'Your order is being prepared'),
  ('ready', 'en', 'Ready for Pickup', 'Your order is ready'),
  ('out_for_delivery', 'en', 'Out for Delivery', 'Driver is on the way'),
  ('completed', 'en', 'Completed', 'Order delivered successfully'),
  ('rejected', 'en', 'Rejected', 'Restaurant rejected your order'),
  ('canceled', 'en', 'Canceled', 'Order was canceled'),
  
  -- Spanish
  ('pending', 'es', 'Pendiente', 'Esperando que el restaurante acepte'),
  ('accepted', 'es', 'Aceptado', 'El restaurante aceptó tu pedido'),
  ('preparing', 'es', 'Preparando', 'Tu pedido se está preparando'),
  ('ready', 'es', 'Listo para Recoger', 'Tu pedido está listo'),
  ('out_for_delivery', 'es', 'En Camino', 'El conductor está en camino'),
  ('completed', 'es', 'Completado', 'Pedido entregado exitosamente'),
  ('rejected', 'es', 'Rechazado', 'El restaurante rechazó tu pedido'),
  ('canceled', 'es', 'Cancelado', 'El pedido fue cancelado'),
  
  -- French
  ('pending', 'fr', 'En Attente', 'En attente d''acceptation du restaurant'),
  ('accepted', 'fr', 'Accepté', 'Le restaurant a accepté votre commande'),
  ('preparing', 'fr', 'En Préparation', 'Votre commande est en préparation'),
  ('ready', 'fr', 'Prêt pour Ramassage', 'Votre commande est prête'),
  ('out_for_delivery', 'fr', 'En Livraison', 'Le livreur est en route'),
  ('completed', 'fr', 'Terminé', 'Commande livrée avec succès'),
  ('rejected', 'fr', 'Refusé', 'Le restaurant a refusé votre commande'),
  ('canceled', 'fr', 'Annulé', 'La commande a été annulée');

-- Insert order type translations
INSERT INTO menuca_v3.order_type_translations (order_type, language, text) VALUES
  ('delivery', 'en', 'Delivery'),
  ('delivery', 'es', 'Entrega a Domicilio'),
  ('delivery', 'fr', 'Livraison'),
  ('takeout', 'en', 'Takeout'),
  ('takeout', 'es', 'Para Llevar'),
  ('takeout', 'fr', 'À Emporter'),
  ('dinein', 'en', 'Dine In'),
  ('dinein', 'es', 'Comer en el Restaurante'),
  ('dinein', 'fr', 'Sur Place');

-- Insert cancellation reasons
INSERT INTO menuca_v3.order_cancellation_reasons_translations (reason_code, language, text) VALUES
  ('changed_mind', 'en', 'Changed my mind'),
  ('changed_mind', 'es', 'Cambié de opinión'),
  ('changed_mind', 'fr', 'J''ai changé d''avis'),
  
  ('wrong_address', 'en', 'Wrong delivery address'),
  ('wrong_address', 'es', 'Dirección de entrega incorrecta'),
  ('wrong_address', 'fr', 'Mauvaise adresse de livraison'),
  
  ('too_long', 'en', 'Wait time too long'),
  ('too_long', 'es', 'Tiempo de espera muy largo'),
  ('too_long', 'fr', 'Temps d''attente trop long'),
  
  ('wrong_items', 'en', 'Wrong items in order'),
  ('wrong_items', 'es', 'Artículos incorrectos en el pedido'),
  ('wrong_items', 'fr', 'Mauvais articles dans la commande'),
  
  ('other', 'en', 'Other reason'),
  ('other', 'es', 'Otra razón'),
  ('other', 'fr', 'Autre raison');
```

### **3. Create Translation Functions**

```sql
-- Function: Get order status text in language
CREATE OR REPLACE FUNCTION menuca_v3.get_order_status_text(
  p_status TEXT,
  p_lang TEXT DEFAULT 'en'
)
RETURNS TEXT AS $$
  SELECT COALESCE(
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = p_lang),
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = 'en'),
    p_status  -- Fallback to raw status if no translation
  );
$$ LANGUAGE sql STABLE;

-- Function: Get order type text
CREATE OR REPLACE FUNCTION menuca_v3.get_order_type_text(
  p_order_type TEXT,
  p_lang TEXT DEFAULT 'en'
)
RETURNS TEXT AS $$
  SELECT COALESCE(
    (SELECT text FROM menuca_v3.order_type_translations 
     WHERE order_type = p_order_type AND language = p_lang),
    (SELECT text FROM menuca_v3.order_type_translations 
     WHERE order_type = p_order_type AND language = 'en'),
    p_order_type
  );
$$ LANGUAGE sql STABLE;

-- Function: Get cancellation reason text
CREATE OR REPLACE FUNCTION menuca_v3.get_cancellation_reason_text(
  p_reason_code TEXT,
  p_lang TEXT DEFAULT 'en'
)
RETURNS TEXT AS $$
  SELECT COALESCE(
    (SELECT text FROM menuca_v3.order_cancellation_reasons_translations 
     WHERE reason_code = p_reason_code AND language = p_lang),
    (SELECT text FROM menuca_v3.order_cancellation_reasons_translations 
     WHERE reason_code = p_reason_code AND language = 'en'),
    p_reason_code
  );
$$ LANGUAGE sql STABLE;
```

---

## 🌍 **LANGUAGE FALLBACK CHAIN**

```
User requests French (FR) → Check FR translation
  ↓ (not found)
Fallback to English (EN) → Check EN translation
  ↓ (not found)
Return raw value → Original database value
```

This ensures users always see **something**, even if translation is missing.

---

## 🎯 **SUCCESS METRICS**

| Metric | Target | Delivered |
|--------|--------|-----------|
| Translation Tables | 3 | ✅ 3 |
| Languages Supported | 3 (EN/ES/FR) | ✅ 3 |
| Translation Functions | 5 | ✅ 5 |
| Fallback Logic | Working | ✅ Working |
| Translation Coverage | 100% | ✅ 100% |

---

## 🚀 **NEXT STEPS**

**Phase 6: Advanced Features** (Next!)
- Scheduled orders
- Tip management
- Order favorites
- Modification windows

---

**Phase 5 Complete! ✅**  
**Next:** Phase 6 - Advanced Features  
**Status:** Orders & Checkout now supports EN/ES/FR 🌍

