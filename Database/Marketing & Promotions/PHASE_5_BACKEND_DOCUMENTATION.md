# Phase 5 Backend Documentation: Multi-Language Support  
## Marketing & Promotions Entity - For Backend Development

**Created:** January 17, 2025  
**Phase:** 5 of 7 - Internationalization (i18n)  
**Status:** ✅ COMPLETE

---

## 🚨 **BUSINESS PROBLEM**

**English-only promotions limit market reach:**
- Can't expand to Quebec (French required)
- Spanish-speaking customers confused
- International expansion blocked
- Competitive disadvantage in multicultural markets

---

## ✅ **THE SOLUTION**

**3 translation tables + 5 i18n functions** with automatic English fallback for EN/ES/FR support.

---

## 🧩 **GAINED BUSINESS LOGIC**

### **Translation Tables:**
- `promotional_deals_translations`
- `promotional_coupons_translations`
- `marketing_tags_translations`

### **i18n Functions:**
1. `get_deal_with_translation(deal_id, language)`
2. `get_deals_i18n(restaurant_id, language)`
3. `get_coupon_with_translation(coupon_id, language)`
4. `get_coupons_i18n(restaurant_id, language)`
5. `translate_marketing_tag(tag_id, language)`

### **Backend Usage:**
```typescript
// GET /api/restaurants/:id/deals?lang=es
const { data: deals } = await supabase.rpc('get_deals_i18n', {
  p_restaurant_id: restaurantId,
  p_language: 'es', // Spanish
  p_service_type: 'delivery'
});

// Returns deals with Spanish translations (or English fallback)
```

---

## 💻 **BACKEND APIS**

**Language Detection Middleware:**
```typescript
export function detectLanguage(req, res, next) {
  const lang = req.query.lang 
    || req.user?.preferred_language 
    || req.headers['accept-language']?.split(',')[0]?.split('-')[0] 
    || 'en';
    
  req.userLanguage = ['en', 'es', 'fr'].includes(lang) ? lang : 'en';
  next();
}
```

**Translation Management:**
```typescript
// POST /api/admin/deals/:id/translations
export async function createDealTranslation(req, res) {
  const { id: dealId } = req.params;
  const { language, title, description, terms } = req.body;
  
  const { data } = await supabase
    .from('promotional_deals_translations')
    .insert({
      deal_id: dealId,
      language_code: language,
      title, description,
      terms_and_conditions: terms
    });
    
  res.json(data);
}
```

---

## 🗄️ **SCHEMA MODIFICATIONS**

**Tables:** 3 translation tables  
**Functions:** 5 i18n functions  
**RLS Policies:** 6 (public read, admin manage)  
**Languages:** EN (English), ES (Spanish), FR (French)

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 5 Complete** - Multi-language ready
2. ⏳ **Santiago: Add language switcher to frontend**
3. ⏳ **Phase 6: Advanced Features** - Flash sales, referrals
4. ⏳ **Phase 7: Testing & Completion**

---

**Status:** ✅ Multi-language support complete! 🌍

