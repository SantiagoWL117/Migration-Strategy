-- =====================================================
-- DELIVERY OPERATIONS V3 - PHASE 6: MULTI-LANGUAGE SUPPORT
-- =====================================================
-- Entity: Delivery Operations (Priority 8)
-- Phase: 6 of 7 - Internationalization & Translation Tables
-- Created: January 17, 2025
-- Description: Add multi-language support for delivery zones and status messages
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE TRANSLATION TABLES
-- =====================================================

-- Table: Delivery zone translations
CREATE TABLE menuca_v3.delivery_zone_translations (
    id BIGSERIAL PRIMARY KEY,
    delivery_zone_id BIGINT NOT NULL REFERENCES menuca_v3.delivery_zones(id) ON DELETE CASCADE,
    language_code VARCHAR(5) NOT NULL CHECK (language_code IN ('en', 'fr', 'es', 'pt', 'de')),
    
    -- Translated fields
    zone_name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by INTEGER REFERENCES menuca_v3.admin_users(id),
    updated_by INTEGER REFERENCES menuca_v3.admin_users(id),
    
    -- Unique constraint (one translation per zone per language)
    CONSTRAINT uq_zone_translation UNIQUE (delivery_zone_id, language_code)
);

-- Indexes
CREATE INDEX idx_zone_translations_zone ON menuca_v3.delivery_zone_translations(delivery_zone_id);
CREATE INDEX idx_zone_translations_language ON menuca_v3.delivery_zone_translations(language_code);

COMMENT ON TABLE menuca_v3.delivery_zone_translations IS
'Multi-language translations for delivery zone names and descriptions';

-- RLS Policy
ALTER TABLE menuca_v3.delivery_zone_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_zone_translations" ON menuca_v3.delivery_zone_translations
    FOR SELECT
    USING (true); -- Public can read all translations

CREATE POLICY "restaurant_admin_manage_translations" ON menuca_v3.delivery_zone_translations
    FOR ALL
    USING (
        delivery_zone_id IN (
            SELECT id FROM menuca_v3.delivery_zones
            WHERE restaurant_id IN (
                SELECT restaurant_id 
                FROM menuca_v3.admin_user_restaurants 
                WHERE user_id = auth.uid()
            )
        )
    )
    WITH CHECK (
        delivery_zone_id IN (
            SELECT id FROM menuca_v3.delivery_zones
            WHERE restaurant_id IN (
                SELECT restaurant_id 
                FROM menuca_v3.admin_user_restaurants 
                WHERE user_id = auth.uid()
            )
        )
    );

GRANT SELECT ON menuca_v3.delivery_zone_translations TO anon, authenticated;

-- =====================================================
-- SECTION 2: STATUS MESSAGE TRANSLATIONS
-- =====================================================

-- Table: Status message translations (for customer-facing status updates)
CREATE TABLE menuca_v3.delivery_status_translations (
    id BIGSERIAL PRIMARY KEY,
    status_code VARCHAR(30) NOT NULL, -- Maps to delivery_status enum
    language_code VARCHAR(5) NOT NULL CHECK (language_code IN ('en', 'fr', 'es', 'pt', 'de')),
    
    -- Translated messages
    status_label VARCHAR(100) NOT NULL, -- "Out for Delivery", "En route", etc.
    status_description TEXT, -- Detailed explanation
    customer_message TEXT, -- Message shown to customer
    driver_message TEXT, -- Message shown to driver
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    
    CONSTRAINT uq_status_translation UNIQUE (status_code, language_code)
);

-- Indexes
CREATE INDEX idx_status_translations_code ON menuca_v3.delivery_status_translations(status_code);
CREATE INDEX idx_status_translations_language ON menuca_v3.delivery_status_translations(language_code);

COMMENT ON TABLE menuca_v3.delivery_status_translations IS
'Multi-language translations for delivery status messages shown to customers and drivers';

-- RLS (public read)
ALTER TABLE menuca_v3.delivery_status_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_status_translations" ON menuca_v3.delivery_status_translations
    FOR SELECT
    USING (true);

GRANT SELECT ON menuca_v3.delivery_status_translations TO anon, authenticated;

-- =====================================================
-- SECTION 3: INSERT DEFAULT TRANSLATIONS
-- =====================================================

-- English translations (default)
INSERT INTO menuca_v3.delivery_status_translations (status_code, language_code, status_label, status_description, customer_message, driver_message) VALUES
('pending', 'en', 'Pending', 'Order is being prepared', 'Your order is being prepared by the restaurant', 'Order pending preparation'),
('searching_driver', 'en', 'Finding Driver', 'Looking for an available driver', 'We are finding a driver for your delivery', 'New delivery available'),
('assigned', 'en', 'Driver Assigned', 'A driver has been assigned to your delivery', 'Your driver has been assigned!', 'New delivery assigned to you'),
('accepted', 'en', 'Driver Accepted', 'Driver is on the way to restaurant', 'Your driver is heading to the restaurant', 'Heading to restaurant'),
('picked_up', 'en', 'Picked Up', 'Driver has picked up your order', 'Your order has been picked up', 'Order picked up, heading to customer'),
('in_transit', 'en', 'On the Way', 'Driver is delivering your order', 'Your order is on the way!', 'Delivering order'),
('arrived', 'en', 'Driver Arrived', 'Driver has arrived at your location', 'Your driver has arrived!', 'Arrived at delivery location'),
('delivered', 'en', 'Delivered', 'Order successfully delivered', 'Your order has been delivered. Enjoy!', 'Order delivered successfully'),
('cancelled', 'en', 'Cancelled', 'Delivery was cancelled', 'This delivery has been cancelled', 'Delivery cancelled'),
('failed', 'en', 'Failed', 'Delivery could not be completed', 'Delivery failed. Please contact support.', 'Delivery failed');

-- French translations
INSERT INTO menuca_v3.delivery_status_translations (status_code, language_code, status_label, status_description, customer_message, driver_message) VALUES
('pending', 'fr', 'En attente', 'La commande est en préparation', 'Votre commande est en préparation au restaurant', 'Commande en attente de préparation'),
('searching_driver', 'fr', 'Recherche livreur', 'Recherche d''un livreur disponible', 'Nous cherchons un livreur pour votre livraison', 'Nouvelle livraison disponible'),
('assigned', 'fr', 'Livreur assigné', 'Un livreur a été assigné à votre livraison', 'Votre livreur a été assigné!', 'Nouvelle livraison assignée'),
('accepted', 'fr', 'Livreur en route', 'Le livreur se dirige vers le restaurant', 'Votre livreur se dirige vers le restaurant', 'En route vers le restaurant'),
('picked_up', 'fr', 'Récupérée', 'Le livreur a récupéré votre commande', 'Votre commande a été récupérée', 'Commande récupérée, en route vers le client'),
('in_transit', 'fr', 'En route', 'Le livreur livre votre commande', 'Votre commande est en route!', 'Livraison en cours'),
('arrived', 'fr', 'Arrivé', 'Le livreur est arrivé à votre adresse', 'Votre livreur est arrivé!', 'Arrivé à l''adresse de livraison'),
('delivered', 'fr', 'Livrée', 'Commande livrée avec succès', 'Votre commande a été livrée. Bon appétit!', 'Commande livrée avec succès'),
('cancelled', 'fr', 'Annulée', 'La livraison a été annulée', 'Cette livraison a été annulée', 'Livraison annulée'),
('failed', 'fr', 'Échouée', 'La livraison n''a pas pu être complétée', 'Livraison échouée. Veuillez contacter le support.', 'Livraison échouée');

-- Spanish translations
INSERT INTO menuca_v3.delivery_status_translations (status_code, language_code, status_label, status_description, customer_message, driver_message) VALUES
('pending', 'es', 'Pendiente', 'El pedido está siendo preparado', 'Tu pedido está siendo preparado por el restaurante', 'Pedido pendiente de preparación'),
('searching_driver', 'es', 'Buscando conductor', 'Buscando un conductor disponible', 'Estamos buscando un conductor para tu entrega', 'Nueva entrega disponible'),
('assigned', 'es', 'Conductor asignado', 'Se ha asignado un conductor a tu entrega', '¡Tu conductor ha sido asignado!', 'Nueva entrega asignada'),
('accepted', 'es', 'Conductor en camino', 'El conductor se dirige al restaurante', 'Tu conductor se dirige al restaurante', 'En camino al restaurante'),
('picked_up', 'es', 'Recogido', 'El conductor ha recogido tu pedido', 'Tu pedido ha sido recogido', 'Pedido recogido, en camino al cliente'),
('in_transit', 'es', 'En camino', 'El conductor está entregando tu pedido', '¡Tu pedido está en camino!', 'Entregando pedido'),
('arrived', 'es', 'Llegó', 'El conductor ha llegado a tu ubicación', '¡Tu conductor ha llegado!', 'Llegué a la ubicación de entrega'),
('delivered', 'es', 'Entregado', 'Pedido entregado exitosamente', 'Tu pedido ha sido entregado. ¡Buen provecho!', 'Pedido entregado exitosamente'),
('cancelled', 'es', 'Cancelado', 'La entrega fue cancelada', 'Esta entrega ha sido cancelada', 'Entrega cancelada'),
('failed', 'es', 'Fallido', 'No se pudo completar la entrega', 'Entrega fallida. Por favor contacta soporte.', 'Entrega fallida');

-- =====================================================
-- SECTION 4: TRANSLATION HELPER FUNCTIONS
-- =====================================================

-- Function: Get delivery zone with translation
CREATE OR REPLACE FUNCTION menuca_v3.get_delivery_zone_translated(
    p_zone_id BIGINT,
    p_language_code VARCHAR DEFAULT 'en'
)
RETURNS TABLE (
    zone_id BIGINT,
    zone_code VARCHAR,
    zone_name VARCHAR,
    description TEXT,
    base_delivery_fee DECIMAL,
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dz.id AS zone_id,
        dz.zone_code,
        COALESCE(dzt.zone_name, dz.zone_name) AS zone_name,
        COALESCE(dzt.description, dz.description) AS description,
        dz.base_delivery_fee,
        dz.is_active
    FROM menuca_v3.delivery_zones dz
    LEFT JOIN menuca_v3.delivery_zone_translations dzt 
        ON dz.id = dzt.delivery_zone_id 
        AND dzt.language_code = p_language_code
    WHERE dz.id = p_zone_id
        AND dz.deleted_at IS NULL;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_delivery_zone_translated IS
'Returns delivery zone with translated name/description for specified language. Falls back to default if translation missing.';

GRANT EXECUTE ON FUNCTION menuca_v3.get_delivery_zone_translated TO anon, authenticated;

-- =====================================================

-- Function: Get delivery status message in language
CREATE OR REPLACE FUNCTION menuca_v3.get_delivery_status_message(
    p_status_code VARCHAR,
    p_language_code VARCHAR DEFAULT 'en',
    p_message_type VARCHAR DEFAULT 'customer' -- 'customer' or 'driver'
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_message TEXT;
BEGIN
    -- Get translated message
    IF p_message_type = 'customer' THEN
        SELECT customer_message INTO v_message
        FROM menuca_v3.delivery_status_translations
        WHERE status_code = p_status_code
            AND language_code = p_language_code;
    ELSE
        SELECT driver_message INTO v_message
        FROM menuca_v3.delivery_status_translations
        WHERE status_code = p_status_code
            AND language_code = p_language_code;
    END IF;

    -- Fallback to English if translation not found
    IF v_message IS NULL THEN
        IF p_message_type = 'customer' THEN
            SELECT customer_message INTO v_message
            FROM menuca_v3.delivery_status_translations
            WHERE status_code = p_status_code
                AND language_code = 'en';
        ELSE
            SELECT driver_message INTO v_message
            FROM menuca_v3.delivery_status_translations
            WHERE status_code = p_status_code
                AND language_code = 'en';
        END IF;
    END IF;

    RETURN v_message;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_delivery_status_message IS
'Returns customer or driver message for delivery status in specified language. Falls back to English.';

GRANT EXECUTE ON FUNCTION menuca_v3.get_delivery_status_message TO anon, authenticated;

-- =====================================================

-- Function: Get all status translations for language
CREATE OR REPLACE FUNCTION menuca_v3.get_all_status_translations(
    p_language_code VARCHAR DEFAULT 'en'
)
RETURNS TABLE (
    status_code VARCHAR,
    status_label VARCHAR,
    status_description TEXT,
    customer_message TEXT,
    driver_message TEXT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dst.status_code,
        dst.status_label,
        dst.status_description,
        dst.customer_message,
        dst.driver_message
    FROM menuca_v3.delivery_status_translations dst
    WHERE dst.language_code = p_language_code
    ORDER BY 
        CASE dst.status_code
            WHEN 'pending' THEN 1
            WHEN 'searching_driver' THEN 2
            WHEN 'assigned' THEN 3
            WHEN 'accepted' THEN 4
            WHEN 'picked_up' THEN 5
            WHEN 'in_transit' THEN 6
            WHEN 'arrived' THEN 7
            WHEN 'delivered' THEN 8
            WHEN 'cancelled' THEN 9
            WHEN 'failed' THEN 10
        END;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_all_status_translations IS
'Returns all delivery status translations for specified language in correct order';

GRANT EXECUTE ON FUNCTION menuca_v3.get_all_status_translations TO anon, authenticated;

-- =====================================================
-- SECTION 5: UPDATED VIEWS WITH TRANSLATIONS
-- =====================================================

-- View: Delivery zones with default language translations
CREATE OR REPLACE VIEW menuca_v3.delivery_zones_with_translations AS
SELECT 
    dz.id,
    dz.restaurant_id,
    dz.zone_code,
    dz.zone_name AS default_name,
    dz.description AS default_description,
    jsonb_object_agg(
        dzt.language_code,
        jsonb_build_object(
            'zone_name', dzt.zone_name,
            'description', dzt.description
        )
    ) FILTER (WHERE dzt.language_code IS NOT NULL) AS translations,
    dz.zone_type,
    dz.base_delivery_fee,
    dz.is_active,
    dz.created_at
FROM menuca_v3.delivery_zones dz
LEFT JOIN menuca_v3.delivery_zone_translations dzt ON dz.id = dzt.delivery_zone_id
WHERE dz.deleted_at IS NULL
GROUP BY dz.id;

COMMENT ON VIEW menuca_v3.delivery_zones_with_translations IS
'Delivery zones with all translations aggregated as JSONB';

GRANT SELECT ON menuca_v3.delivery_zones_with_translations TO anon, authenticated;

-- =====================================================

COMMIT;

-- =====================================================
-- VALIDATION QUERIES (Run after migration)
-- =====================================================

-- Verify translation tables created
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND table_name = t.table_name) AS column_count
FROM information_schema.tables t
WHERE table_schema = 'menuca_v3'
    AND table_name LIKE '%translation%'
ORDER BY table_name;

-- Verify status translations inserted
SELECT 
    language_code,
    COUNT(*) AS translation_count
FROM menuca_v3.delivery_status_translations
GROUP BY language_code
ORDER BY language_code;

-- Test translation function
SELECT menuca_v3.get_delivery_status_message('in_transit', 'fr', 'customer');
-- Expected: "Votre commande est en route!"

-- =====================================================
-- END OF PHASE 6 MIGRATION
-- =====================================================

