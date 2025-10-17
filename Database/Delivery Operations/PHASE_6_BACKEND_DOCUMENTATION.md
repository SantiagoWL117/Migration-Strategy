# Phase 6 Backend Documentation: Multi-Language Support
## Delivery Operations Entity - For Backend Development

**Created:** January 17, 2025  
**Developer:** Brian (Database) → Santiago (Backend)  
**Phase:** 6 of 7 - Internationalization & Translation Support  
**Status:** ✅ COMPLETE - Ready for Backend Implementation

---

## 📋 **SANTIAGO'S QUICK REFERENCE**

### **Business Problem Summary**
Food delivery operates globally with **diverse customer languages**:
- **Customers** see delivery status in their own language
- **Zones** have names that need translation (e.g., "Downtown" → "Centre-ville")
- **Error messages** confuse non-English speakers
- **Support tickets** increase due to language barriers
- **International expansion** blocked by English-only system

**Impact:** Without multi-language support, we lose international customers, increase support costs, and can't expand to non-English markets.

---

### **The Solution**
Implement **database-level translations** with **automatic fallbacks**:
1. **Translation tables** for user-facing content
2. **Pre-loaded translations** for delivery status messages (EN/FR/ES)
3. **Helper functions** that return content in requested language
4. **Fallback to English** if translation missing
5. **Easy content management** for adding new languages

This creates a **"truly global system"** that speaks the customer's language.

---

### **Gained Business Logic Components**

#### **1. Translation Infrastructure**
✅ **Tables Created:** 2 translation tables for delivery content  
✅ **Languages Supported:** English, French, Spanish (German, Portuguese ready)  
✅ **Auto-Fallback:** Returns English if translation missing

**Translation Tables:**
- `delivery_zone_translations` - Zone names and descriptions
- `delivery_status_translations` - Status messages for customers and drivers

**Backend Usage:**
```typescript
// Get delivery zone in customer's language
const { data: zone } = await supabase.rpc('get_delivery_zone_translated', {
  p_zone_id: 123,
  p_language_code: user.language || 'en'
});

// zone.zone_name is now translated!
// "Downtown" → "Centre-ville" (if French)
```

---

#### **2. Pre-Loaded Status Messages**
✅ **10 status messages** × 3 languages = 30 translations  
✅ **Customer-facing** and **driver-facing** messages  
✅ **Production-ready** for EN/FR/ES markets

**Status Messages Included:**
```typescript
type DeliveryStatus = 
  | 'pending'           // "En attente" (FR), "Pendiente" (ES)
  | 'searching_driver'  // "Recherche livreur" (FR), "Buscando conductor" (ES)
  | 'assigned'          // "Livreur assigné" (FR), "Conductor asignado" (ES)
  | 'accepted'          // "Livreur en route" (FR), "Conductor en camino" (ES)
  | 'picked_up'         // "Récupérée" (FR), "Recogido" (ES)
  | 'in_transit'        // "En route" (FR), "En camino" (ES)
  | 'arrived'           // "Arrivé" (FR), "Llegó" (ES)
  | 'delivered'         // "Livrée" (FR), "Entregado" (ES)
  | 'cancelled'         // "Annulée" (FR), "Cancelado" (ES)
  | 'failed';           // "Échouée" (FR), "Fallido" (ES)
```

**Each status has:**
- `status_label` - Short label ("On the Way")
- `status_description` - Detailed explanation
- `customer_message` - Message shown to customer
- `driver_message` - Message shown to driver

---

#### **3. Translation Helper Functions**
✅ **Function:** `get_delivery_zone_translated(zone_id, language_code)`  
✅ **Function:** `get_delivery_status_message(status_code, language_code, message_type)`  
✅ **Function:** `get_all_status_translations(language_code)`

**Backend Implementation - Customer Tracking:**
```typescript
// Customer Tracking Page - Show status in their language
export function DeliveryTracking({ delivery, userLanguage }) {
  const [statusMessage, setStatusMessage] = useState('');

  useEffect(() => {
    fetchStatusMessage();
  }, [delivery.delivery_status, userLanguage]);

  const fetchStatusMessage = async () => {
    const { data } = await supabase.rpc('get_delivery_status_message', {
      p_status_code: delivery.delivery_status,
      p_language_code: userLanguage, // 'en', 'fr', 'es'
      p_message_type: 'customer'
    });

    setStatusMessage(data);
  };

  return (
    <div className="delivery-tracking">
      <StatusBadge status={delivery.delivery_status} />
      <h2>{statusMessage}</h2>
      {/* Rest of tracking UI */}
    </div>
  );
}

// Example outputs:
// EN: "Your order is on the way!"
// FR: "Votre commande est en route!"
// ES: "¡Tu pedido está en camino!"
```

---

#### **4. Translation Management**
✅ **Admin UI:** Manage zone translations  
✅ **Bulk Loading:** Seed translations from CSV/JSON  
✅ **Missing Translation Detection:** See untranslated content

**Admin API - Manage Zone Translations:**
```typescript
// POST /api/admin/zones/:id/translations
export async function createZoneTranslation(req, res) {
  const { zoneId } = req.params;
  const { language_code, zone_name, description } = req.body;

  // Validate language supported
  const supportedLanguages = ['en', 'fr', 'es', 'pt', 'de'];
  if (!supportedLanguages.includes(language_code)) {
    return res.status(400).json({
      error: 'Unsupported language',
      supported: supportedLanguages
    });
  }

  // Create translation
  const { data, error } = await supabase
    .from('delivery_zone_translations')
    .insert({
      delivery_zone_id: zoneId,
      language_code,
      zone_name,
      description
    })
    .select()
    .single();

  if (error) {
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({
        error: 'Translation already exists for this language'
      });
    }
    return res.status(500).json({ error: error.message });
  }

  res.json({
    success: true,
    translation: data
  });
}

// GET /api/admin/zones/:id/translations
export async function getZoneTranslations(req, res) {
  const { zoneId } = req.params;

  const { data, error } = await supabase
    .from('delivery_zone_translations')
    .select('*')
    .eq('delivery_zone_id', zoneId)
    .order('language_code');

  res.json({
    zone_id: zoneId,
    translations: data,
    missing_languages: getMissingLanguages(data)
  });
}

function getMissingLanguages(translations) {
  const allLanguages = ['en', 'fr', 'es', 'pt', 'de'];
  const existingLanguages = translations.map(t => t.language_code);
  return allLanguages.filter(lang => !existingLanguages.includes(lang));
}
```

---

#### **5. Language Detection**
✅ **Automatic:** Detect from HTTP headers  
✅ **User Preference:** Store in user profile  
✅ **Fallback:** Default to English

**Middleware - Detect User Language:**
```typescript
// middleware/detectLanguage.ts
export function detectLanguage(req, res, next) {
  let language = 'en'; // Default

  // 1. Check user profile first (if authenticated)
  if (req.user?.preferred_language) {
    language = req.user.preferred_language;
  }
  // 2. Check Accept-Language header
  else if (req.headers['accept-language']) {
    const acceptLanguage = req.headers['accept-language'];
    // Parse: "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
    const primaryLang = acceptLanguage.split(',')[0].split('-')[0];
    
    const supportedLanguages = ['en', 'fr', 'es', 'pt', 'de'];
    if (supportedLanguages.includes(primaryLang)) {
      language = primaryLang;
    }
  }
  // 3. Check query parameter (for testing)
  else if (req.query.lang) {
    language = req.query.lang;
  }

  // Attach to request
  req.userLanguage = language;
  next();
}

// Apply globally
app.use(detectLanguage);
```

---

#### **6. Customer-Facing Delivery Tracking (Translated)**
✅ **Fully translated** delivery status updates  
✅ **Real-time** language switching  
✅ **Mobile-optimized** for international users

**Complete Customer Tracking Implementation:**
```typescript
// pages/tracking/[orderId].tsx
export function CustomerTrackingPage({ orderId }) {
  const [delivery, setDelivery] = useState(null);
  const [statusMessage, setStatusMessage] = useState('');
  const [userLanguage, setUserLanguage] = useState('en');

  // Detect user language
  useEffect(() => {
    const browserLang = navigator.language.split('-')[0];
    const supportedLangs = ['en', 'fr', 'es'];
    setUserLanguage(supportedLangs.includes(browserLang) ? browserLang : 'en');
  }, []);

  // Fetch delivery data
  useEffect(() => {
    fetchDelivery();
  }, [orderId]);

  // Subscribe to real-time updates
  useEffect(() => {
    const subscription = supabase
      .channel(`order_${orderId}_tracking`)
      .on('postgres_changes', {
        event: '*',
        schema: 'menuca_v3',
        table: 'deliveries',
        filter: `order_id=eq.${orderId}`
      }, async (payload) => {
        setDelivery(payload.new);
        await updateStatusMessage(payload.new.delivery_status);
      })
      .subscribe();

    return () => subscription.unsubscribe();
  }, [orderId, userLanguage]);

  const fetchDelivery = async () => {
    const { data } = await supabase
      .from('deliveries')
      .select('*')
      .eq('order_id', orderId)
      .single();

    setDelivery(data);
    await updateStatusMessage(data.delivery_status);
  };

  const updateStatusMessage = async (status) => {
    const { data } = await supabase.rpc('get_delivery_status_message', {
      p_status_code: status,
      p_language_code: userLanguage,
      p_message_type: 'customer'
    });
    setStatusMessage(data);
  };

  // Language switcher
  const changeLanguage = async (newLang) => {
    setUserLanguage(newLang);
    await updateStatusMessage(delivery.delivery_status);
  };

  if (!delivery) return <Loading />;

  return (
    <div className="customer-tracking">
      {/* Language Switcher */}
      <LanguageSelector 
        current={userLanguage}
        onChange={changeLanguage}
        languages={[
          { code: 'en', label: 'English', flag: '🇬🇧' },
          { code: 'fr', label: 'Français', flag: '🇫🇷' },
          { code: 'es', label: 'Español', flag: '🇪🇸' }
        ]}
      />

      {/* Delivery Status */}
      <DeliveryStatus 
        status={delivery.delivery_status}
        message={statusMessage}
      />

      {/* Progress Timeline (translated) */}
      <DeliveryTimeline 
        delivery={delivery}
        language={userLanguage}
      />

      {/* Driver Location Map */}
      {delivery.driver_id && (
        <DriverLocationMap 
          deliveryId={delivery.id}
          language={userLanguage}
        />
      )}

      {/* ETA (translated) */}
      <EstimatedArrival 
        deliveryId={delivery.id}
        language={userLanguage}
      />
    </div>
  );
}
```

---

### **Backend Functionality Required for This Phase**

#### **Priority 1: Language Detection Middleware** ✅ CRITICAL
**Why:** Need to automatically detect customer's preferred language

**Implementation:**
- ✅ Read `Accept-Language` HTTP header
- ✅ Check user profile for saved preference
- ✅ Allow query parameter override (?lang=fr)
- ✅ Attach to request object for all endpoints

---

#### **Priority 2: Translation Management APIs** ✅ CRITICAL
**Why:** Admins need to manage zone translations

**Endpoints to Create:**
```typescript
POST   /api/admin/zones/:id/translations     - Create zone translation
GET    /api/admin/zones/:id/translations     - Get all zone translations
PUT    /api/admin/zones/:id/translations/:lang - Update translation
DELETE /api/admin/zones/:id/translations/:lang - Delete translation

GET    /api/admin/translations/missing        - List untranslated zones
POST   /api/admin/translations/bulk-import    - Bulk import translations from CSV
```

---

#### **Priority 3: Status Message API** ✅ CRITICAL
**Why:** Customer tracking page needs translated status messages

**Implementation:**
```typescript
// GET /api/delivery-status/messages?language=fr
export async function getStatusMessages(req, res) {
  const { language = 'en' } = req.query;

  const { data, error } = await supabase.rpc(
    'get_all_status_translations',
    { p_language_code: language }
  );

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  // Format for frontend
  const messages = data.reduce((acc, msg) => {
    acc[msg.status_code] = {
      label: msg.status_label,
      description: msg.status_description,
      customer_message: msg.customer_message
    };
    return acc;
  }, {});

  res.json({
    language,
    messages,
    supported_languages: ['en', 'fr', 'es', 'pt', 'de']
  });
}
```

---

#### **Priority 4: Translated Customer Endpoints** ⚠️ IMPORTANT
**Why:** All customer-facing endpoints should support translations

**Endpoints to Update:**
```typescript
// Add language parameter to existing endpoints
GET /api/orders/:id/tracking?lang=fr          - Translated tracking
GET /api/restaurants/:id/delivery-zones?lang=fr - Translated zones
GET /api/delivery/:id/eta?lang=fr             - Translated ETA message
```

**Pattern:**
```typescript
// Before (English only)
const zone = await getDeliveryZone(zoneId);
// zone.zone_name = "Downtown"

// After (Translated)
const zone = await supabase.rpc('get_delivery_zone_translated', {
  p_zone_id: zoneId,
  p_language_code: req.userLanguage // from middleware
});
// zone.zone_name = "Centre-ville" (if French)
```

---

### **Schema Modifications Summary**

#### **New Tables Created (2):**
- ✅ `delivery_zone_translations` - Zone name/description translations
- ✅ `delivery_status_translations` - Status message translations

#### **Pre-Loaded Data:**
- ✅ 10 delivery statuses × 3 languages = 30 status translations
- ✅ English (EN), French (FR), Spanish (ES) complete
- ✅ German (DE), Portuguese (PT) ready for content

#### **Translation Functions (3):**
- ✅ `get_delivery_zone_translated()` - Get zone in language
- ✅ `get_delivery_status_message()` - Get status message
- ✅ `get_all_status_translations()` - Get all statuses for language

#### **Views (1):**
- ✅ `delivery_zones_with_translations` - Zones with all translations as JSONB

#### **RLS Policies:**
- ✅ Public can read all translations
- ✅ Restaurant admins can manage their zone translations

---

### **Testing Checklist for Backend**

#### **Test 1: Translation Fallback**
```typescript
// Request translation for unsupported language
const { data } = await supabase.rpc('get_delivery_status_message', {
  p_status_code: 'in_transit',
  p_language_code: 'zh', // Chinese (not supported)
  p_message_type: 'customer'
});

// Expected: Falls back to English
// "Your order is on the way!"
```

#### **Test 2: Zone Translation**
```typescript
// Create zone
const { data: zone } = await supabase
  .from('delivery_zones')
  .insert({
    restaurant_id: 123,
    zone_name: 'Downtown',
    zone_code: 'DT'
  })
  .select()
  .single();

// Add French translation
await supabase
  .from('delivery_zone_translations')
  .insert({
    delivery_zone_id: zone.id,
    language_code: 'fr',
    zone_name: 'Centre-ville',
    description: 'Zone du centre-ville'
  });

// Get translated
const { data: translatedZone } = await supabase.rpc(
  'get_delivery_zone_translated',
  { p_zone_id: zone.id, p_language_code: 'fr' }
);

// Expected: zone_name = "Centre-ville"
```

#### **Test 3: Language Detection**
```http
GET /api/delivery-status/messages
Accept-Language: fr-FR,fr;q=0.9,en;q=0.8

Expected Response:
{
  "language": "fr",
  "messages": {
    "in_transit": {
      "label": "En route",
      "customer_message": "Votre commande est en route!"
    }
  }
}
```

---

## 🎯 **IMPLEMENTATION PRIORITY**

### **This Week (Critical):**
1. ✅ Add language detection middleware
2. ✅ Create translation management APIs
3. ✅ Update customer tracking page with translations
4. ✅ Test all 3 languages (EN/FR/ES)

### **Next Week (Important):**
1. ⚠️ Build admin translation management UI
2. ⚠️ Add language switcher to customer app
3. ⚠️ Update driver app with translations
4. ⚠️ Create bulk translation import tool

### **Future (Nice to Have):**
1. 💡 Add more languages (German, Portuguese, Chinese)
2. 💡 Automated translation (Google Translate API)
3. 💡 Translation quality review workflow
4. 💡 A/B testing for message variations

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 6 Complete** - Multi-language support ready
2. ⏳ **Santiago: Implement Translation APIs** - Follow this guide
3. ⏳ **Phase 7: Testing & Validation** - Comprehensive tests
4. ⏳ **Final: Deployment** - Production-ready system

---

**Status:** ✅ Multi-language infrastructure deployed, ready for global expansion! 🌍

