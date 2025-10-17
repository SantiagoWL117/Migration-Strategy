-- =====================================================
-- PHASE 5: MULTI-LANGUAGE SUPPORT - ORDERS & CHECKOUT
-- =====================================================
-- Entity: Orders & Checkout
-- Phase: 5 of 7 - Translation Tables
-- Date: January 17, 2025
-- Agent: Agent 1 (Brian)
-- 
-- Purpose: Enable multi-language support for global expansion
-- 
-- Contents:
--   - Translation tables (order statuses, types, reasons)
--   - Translation data (EN, ES, FR)
--   - Translation functions with fallback
--   - Updated core functions for language support
-- 
-- Supported Languages:
--   - EN (English) - default, fallback
--   - ES (Spanish) - Latin America
--   - FR (French) - Quebec
-- 
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE TRANSLATION TABLES
-- =====================================================

-- Table: Order status translations
CREATE TABLE IF NOT EXISTS menuca_v3.order_status_translations (
  id SERIAL PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(status, language)
);

CREATE INDEX idx_status_translations_lookup 
  ON menuca_v3.order_status_translations(status, language);

COMMENT ON TABLE menuca_v3.order_status_translations IS
  'Translations for order statuses in multiple languages (EN, ES, FR)';

-- Table: Order type translations
CREATE TABLE IF NOT EXISTS menuca_v3.order_type_translations (
  id SERIAL PRIMARY KEY,
  order_type VARCHAR(20) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(order_type, language)
);

CREATE INDEX idx_type_translations_lookup 
  ON menuca_v3.order_type_translations(order_type, language);

COMMENT ON TABLE menuca_v3.order_type_translations IS
  'Translations for order types (delivery, takeout, dinein) in multiple languages';

-- Table: Cancellation reason translations
CREATE TABLE IF NOT EXISTS menuca_v3.order_cancellation_reasons_translations (
  id SERIAL PRIMARY KEY,
  reason_code VARCHAR(50) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(reason_code, language)
);

CREATE INDEX idx_cancellation_translations_lookup 
  ON menuca_v3.order_cancellation_reasons_translations(reason_code, language);

COMMENT ON TABLE menuca_v3.order_cancellation_reasons_translations IS
  'Translations for order cancellation reasons in multiple languages';

-- =====================================================
-- SECTION 2: POPULATE TRANSLATION DATA
-- =====================================================

-- Insert order status translations (EN/ES/FR)
INSERT INTO menuca_v3.order_status_translations (status, language, text, description) VALUES
  -- English (EN) - Default
  ('pending', 'en', 'Pending', 'Waiting for restaurant to accept'),
  ('accepted', 'en', 'Accepted', 'Restaurant accepted your order'),
  ('preparing', 'en', 'Preparing', 'Your order is being prepared'),
  ('ready', 'en', 'Ready for Pickup', 'Your order is ready'),
  ('out_for_delivery', 'en', 'Out for Delivery', 'Driver is on the way'),
  ('completed', 'en', 'Completed', 'Order delivered successfully'),
  ('rejected', 'en', 'Rejected', 'Restaurant rejected your order'),
  ('canceled', 'en', 'Canceled', 'Order was canceled'),
  
  -- Spanish (ES) - Latin America
  ('pending', 'es', 'Pendiente', 'Esperando que el restaurante acepte'),
  ('accepted', 'es', 'Aceptado', 'El restaurante aceptó tu pedido'),
  ('preparing', 'es', 'Preparando', 'Tu pedido se está preparando'),
  ('ready', 'es', 'Listo para Recoger', 'Tu pedido está listo'),
  ('out_for_delivery', 'es', 'En Camino', 'El conductor está en camino'),
  ('completed', 'es', 'Completado', 'Pedido entregado exitosamente'),
  ('rejected', 'es', 'Rechazado', 'El restaurante rechazó tu pedido'),
  ('canceled', 'es', 'Cancelado', 'El pedido fue cancelado'),
  
  -- French (FR) - Quebec
  ('pending', 'fr', 'En Attente', 'En attente d''acceptation du restaurant'),
  ('accepted', 'fr', 'Accepté', 'Le restaurant a accepté votre commande'),
  ('preparing', 'fr', 'En Préparation', 'Votre commande est en préparation'),
  ('ready', 'fr', 'Prêt pour Ramassage', 'Votre commande est prête'),
  ('out_for_delivery', 'fr', 'En Livraison', 'Le livreur est en route'),
  ('completed', 'fr', 'Terminé', 'Commande livrée avec succès'),
  ('rejected', 'fr', 'Refusé', 'Le restaurant a refusé votre commande'),
  ('canceled', 'fr', 'Annulé', 'La commande a été annulée')
ON CONFLICT (status, language) DO NOTHING;

-- Insert order type translations
INSERT INTO menuca_v3.order_type_translations (order_type, language, text) VALUES
  -- English
  ('delivery', 'en', 'Delivery'),
  ('takeout', 'en', 'Takeout'),
  ('dinein', 'en', 'Dine In'),
  
  -- Spanish
  ('delivery', 'es', 'Entrega a Domicilio'),
  ('takeout', 'es', 'Para Llevar'),
  ('dinein', 'es', 'Comer en el Restaurante'),
  
  -- French
  ('delivery', 'fr', 'Livraison'),
  ('takeout', 'fr', 'À Emporter'),
  ('dinein', 'fr', 'Sur Place')
ON CONFLICT (order_type, language) DO NOTHING;

-- Insert cancellation reason translations
INSERT INTO menuca_v3.order_cancellation_reasons_translations (reason_code, language, text) VALUES
  -- Changed mind
  ('changed_mind', 'en', 'Changed my mind'),
  ('changed_mind', 'es', 'Cambié de opinión'),
  ('changed_mind', 'fr', 'J''ai changé d''avis'),
  
  -- Wrong address
  ('wrong_address', 'en', 'Wrong delivery address'),
  ('wrong_address', 'es', 'Dirección de entrega incorrecta'),
  ('wrong_address', 'fr', 'Mauvaise adresse de livraison'),
  
  -- Wait time too long
  ('too_long', 'en', 'Wait time too long'),
  ('too_long', 'es', 'Tiempo de espera muy largo'),
  ('too_long', 'fr', 'Temps d''attente trop long'),
  
  -- Wrong items
  ('wrong_items', 'en', 'Wrong items in order'),
  ('wrong_items', 'es', 'Artículos incorrectos en el pedido'),
  ('wrong_items', 'fr', 'Mauvais articles dans la commande'),
  
  -- Price changed
  ('price_changed', 'en', 'Price is different than expected'),
  ('price_changed', 'es', 'El precio es diferente al esperado'),
  ('price_changed', 'fr', 'Le prix est différent de celui attendu'),
  
  -- Restaurant closed
  ('restaurant_closed', 'en', 'Restaurant is closed'),
  ('restaurant_closed', 'es', 'El restaurante está cerrado'),
  ('restaurant_closed', 'fr', 'Le restaurant est fermé'),
  
  -- Other
  ('other', 'en', 'Other reason'),
  ('other', 'es', 'Otra razón'),
  ('other', 'fr', 'Autre raison')
ON CONFLICT (reason_code, language) DO NOTHING;

-- =====================================================
-- SECTION 3: TRANSLATION FUNCTIONS
-- =====================================================

-- Function: Get order status text in specified language
CREATE OR REPLACE FUNCTION menuca_v3.get_order_status_text(
  p_status TEXT,
  p_lang TEXT DEFAULT 'en'
)
RETURNS TEXT AS $$
  SELECT COALESCE(
    -- Try requested language
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = p_lang),
    -- Fallback to English
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = 'en'),
    -- Fallback to raw status
    p_status
  );
$$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION menuca_v3.get_order_status_text IS
  'Returns translated order status text with automatic fallback (requested lang → EN → raw value)';

-- Function: Get order type text in specified language
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

COMMENT ON FUNCTION menuca_v3.get_order_type_text IS
  'Returns translated order type text with automatic fallback';

-- Function: Get cancellation reason text in specified language
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

COMMENT ON FUNCTION menuca_v3.get_cancellation_reason_text IS
  'Returns translated cancellation reason with automatic fallback';

-- =====================================================
-- SECTION 4: UPDATED FUNCTIONS WITH LANGUAGE SUPPORT
-- =====================================================

-- Function: Get order details with translations
CREATE OR REPLACE FUNCTION menuca_v3.get_order_details_translated(
  p_order_id BIGINT,
  p_user_id UUID,
  p_lang TEXT DEFAULT 'en'
)
RETURNS JSONB AS $$
DECLARE
  v_order JSONB;
  v_items JSONB;
  v_address JSONB;
  v_history JSONB;
BEGIN
  -- Get order with translated fields
  SELECT jsonb_build_object(
    'id', o.id,
    'order_number', o.order_number,
    'status', o.status,
    'status_text', menuca_v3.get_order_status_text(o.status, p_lang),
    'order_type', o.order_type,
    'order_type_text', menuca_v3.get_order_type_text(o.order_type, p_lang),
    'placed_at', o.placed_at,
    'accepted_at', o.accepted_at,
    'completed_at', o.completed_at,
    'subtotal', o.subtotal,
    'tax_total', o.tax_total,
    'delivery_fee', o.delivery_fee,
    'grand_total', o.grand_total,
    'payment_method', o.payment_method,
    'payment_status', o.payment_status,
    'special_instructions', o.special_instructions,
    'restaurant', jsonb_build_object(
      'id', r.id,
      'name', r.name,
      'phone', r.phone
    )
  ) INTO v_order
  FROM menuca_v3.orders o
  JOIN menuca_v3.restaurants r ON o.restaurant_id = r.id
  WHERE o.id = p_order_id;
  
  IF v_order IS NULL THEN
    RETURN jsonb_build_object('error', 'Order not found');
  END IF;
  
  -- Get items
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', oi.id,
      'dish_id', oi.dish_id,
      'item_name', oi.item_name,
      'quantity', oi.quantity,
      'base_price', oi.base_price,
      'modifiers_price', oi.modifiers_price,
      'line_total', oi.line_total
    )
  ) INTO v_items
  FROM menuca_v3.order_items oi
  WHERE oi.order_id = p_order_id;
  
  -- Get delivery address
  SELECT jsonb_build_object(
    'street', street_address,
    'unit', unit_number,
    'city', city,
    'province', province,
    'postal_code', postal_code,
    'phone', phone
  ) INTO v_address
  FROM menuca_v3.order_delivery_addresses
  WHERE order_id = p_order_id;
  
  -- Get status history with translations
  SELECT jsonb_agg(
    jsonb_build_object(
      'status', new_status,
      'status_text', menuca_v3.get_order_status_text(new_status, p_lang),
      'changed_at', changed_at,
      'reason', change_reason
    ) ORDER BY changed_at
  ) INTO v_history
  FROM menuca_v3.order_status_history
  WHERE order_id = p_order_id;
  
  -- Combine and return
  RETURN v_order || jsonb_build_object(
    'items', COALESCE(v_items, '[]'::jsonb),
    'delivery_address', v_address,
    'status_history', COALESCE(v_history, '[]'::jsonb)
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION menuca_v3.get_order_details_translated IS
  'Returns complete order details with all text translated to specified language';

-- Function: Get order history with translations
CREATE OR REPLACE FUNCTION menuca_v3.get_customer_order_history_translated(
  p_user_id UUID,
  p_lang TEXT DEFAULT 'en',
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS JSONB AS $$
BEGIN
  RETURN (
    SELECT jsonb_build_object(
      'orders', jsonb_agg(
        jsonb_build_object(
          'id', o.id,
          'order_number', o.order_number,
          'status', o.status,
          'status_text', menuca_v3.get_order_status_text(o.status, p_lang),
          'order_type', o.order_type,
          'order_type_text', menuca_v3.get_order_type_text(o.order_type, p_lang),
          'placed_at', o.placed_at,
          'grand_total', o.grand_total,
          'restaurant_name', r.name,
          'items_count', (
            SELECT COUNT(*) FROM menuca_v3.order_items 
            WHERE order_id = o.id
          )
        ) ORDER BY o.placed_at DESC
      ),
      'total_count', COUNT(*) OVER()
    )
    FROM menuca_v3.orders o
    JOIN menuca_v3.restaurants r ON o.restaurant_id = r.id
    WHERE o.user_id = p_user_id
      AND o.deleted_at IS NULL
    ORDER BY o.placed_at DESC
    LIMIT p_limit OFFSET p_offset
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION menuca_v3.get_customer_order_history_translated IS
  'Returns customer order history with status/type text translated';

-- =====================================================
-- SECTION 5: LANGUAGE DETECTION HELPER
-- =====================================================

-- Function: Detect language from locale code
CREATE OR REPLACE FUNCTION menuca_v3.normalize_language_code(
  p_locale TEXT
)
RETURNS TEXT AS $$
  SELECT CASE
    WHEN p_locale ILIKE 'en%' THEN 'en'
    WHEN p_locale ILIKE 'es%' THEN 'es'
    WHEN p_locale ILIKE 'fr%' THEN 'fr'
    ELSE 'en'  -- Default to English
  END;
$$ LANGUAGE sql IMMUTABLE;

COMMENT ON FUNCTION menuca_v3.normalize_language_code IS
  'Converts locale codes (en-US, es-MX, fr-CA) to supported language codes (en, es, fr)';

-- =====================================================
-- SECTION 6: VERIFICATION QUERIES
-- =====================================================

-- Verify translations exist for all statuses
SELECT 
  status,
  COUNT(*) FILTER (WHERE language = 'en') as en_count,
  COUNT(*) FILTER (WHERE language = 'es') as es_count,
  COUNT(*) FILTER (WHERE language = 'fr') as fr_count,
  COUNT(*) as total_translations
FROM menuca_v3.order_status_translations
GROUP BY status
ORDER BY status;

-- Verify translations exist for all order types
SELECT 
  order_type,
  COUNT(*) FILTER (WHERE language = 'en') as en_count,
  COUNT(*) FILTER (WHERE language = 'es') as es_count,
  COUNT(*) FILTER (WHERE language = 'fr') as fr_count
FROM menuca_v3.order_type_translations
GROUP BY order_type;

-- Verify translations exist for cancellation reasons
SELECT 
  reason_code,
  COUNT(*) FILTER (WHERE language = 'en') as en_count,
  COUNT(*) FILTER (WHERE language = 'es') as es_count,
  COUNT(*) FILTER (WHERE language = 'fr') as fr_count
FROM menuca_v3.order_cancellation_reasons_translations
GROUP BY reason_code;

-- Test translation functions
SELECT 
  'pending' as status,
  menuca_v3.get_order_status_text('pending', 'en') as english,
  menuca_v3.get_order_status_text('pending', 'es') as spanish,
  menuca_v3.get_order_status_text('pending', 'fr') as french;

COMMIT;

-- =====================================================
-- PHASE 5 MIGRATION COMPLETE ✅
-- =====================================================
-- 
-- Summary:
-- ✅ 3 translation tables created
-- ✅ 3 languages supported (EN, ES, FR)
-- ✅ 40+ translation records inserted
-- ✅ 5 translation functions created
-- ✅ Automatic fallback logic (FR → EN → raw)
-- ✅ Core functions updated for language support
-- 
-- Translation Coverage:
-- - Order statuses: 8 statuses × 3 languages = 24 translations
-- - Order types: 3 types × 3 languages = 9 translations
-- - Cancellation reasons: 7 reasons × 3 languages = 21 translations
-- 
-- Functions:
-- 1. get_order_status_text() - Translated status
-- 2. get_order_type_text() - Translated type
-- 3. get_cancellation_reason_text() - Translated reason
-- 4. get_order_details_translated() - Full order with translations
-- 5. get_customer_order_history_translated() - History with translations
-- 6. normalize_language_code() - Locale detection
-- 
-- Features:
-- - Quebec ready (French legal requirement)
-- - Latin America ready (Spanish support)
-- - Global expansion ready (easy to add languages)
-- - Fallback chain ensures users always see text
-- 
-- Next: Phase 6 - Advanced Features (Scheduled Orders, Tips, Favorites)
-- =====================================================

