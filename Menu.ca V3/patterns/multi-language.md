# Multi-Language Pattern

> **Internationalization Approach** - How multilingual content is handled

---

## 📋 Overview

The menuca_v3 schema supports **bilingual content** (English/French) through:
1. **Per-field translations** - For static content
2. **Language-specific columns** - For frequently accessed content
3. **Service configuration** - Restaurant language preferences

---

## 🌐 Supported Languages

| Code | Language | Status |
|------|----------|--------|
| `en` | English | Primary |
| `fr` | French | Secondary |
| `es` | Spanish | Future |

---

## 📊 Implementation Strategies

### Strategy 1: Translations Table

For content that rarely changes and isn't performance-critical:

```sql
CREATE TABLE menuca_v3.translations (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id BIGINT NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    language VARCHAR(5) NOT NULL,
    translation TEXT NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE (table_name, record_id, field_name, language)
);
```

**Usage:**
```sql
-- Get French translation for dish description
SELECT t.translation
FROM menuca_v3.translations t
WHERE t.table_name = 'dishes'
AND t.record_id = :dish_id
AND t.field_name = 'description'
AND t.language = 'fr';

-- With fallback to English
SELECT 
    d.id,
    d.name,
    COALESCE(t.translation, d.description) as description
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.translations t 
    ON t.table_name = 'dishes'
    AND t.record_id = d.id
    AND t.field_name = 'description'
    AND t.language = :requested_language
WHERE d.id = :dish_id;
```

---

### Strategy 2: Language-Specific Columns

For frequently accessed content where performance matters:

```sql
-- Example: dishes table with both languages
ALTER TABLE menuca_v3.dishes
ADD COLUMN name_fr VARCHAR(255),
ADD COLUMN description_fr TEXT;
```

**Usage:**
```sql
SELECT 
    id,
    CASE WHEN :lang = 'fr' THEN COALESCE(name_fr, name) ELSE name END as name,
    CASE WHEN :lang = 'fr' THEN COALESCE(description_fr, description) ELSE description END as description
FROM menuca_v3.dishes
WHERE id = :dish_id;
```

---

### Strategy 3: JSONB Storage

For flexible multilingual content:

```sql
-- Example: storing multilingual content in JSONB
ALTER TABLE menuca_v3.dishes
ADD COLUMN translations JSONB DEFAULT '{}';

-- Sample data:
-- {
--   "name": {"en": "Pepperoni Pizza", "fr": "Pizza Pepperoni"},
--   "description": {"en": "Classic pepperoni", "fr": "Pepperoni classique"}
-- }
```

**Usage:**
```sql
SELECT 
    id,
    COALESCE(
        translations->'name'->>:lang,
        translations->'name'->>'en',
        name
    ) as name
FROM menuca_v3.dishes
WHERE id = :dish_id;
```

---

## ⚙️ Restaurant Language Configuration

### Service Config Setting

```sql
-- restaurant_service_configs table
is_bilingual BOOLEAN DEFAULT FALSE,
default_language VARCHAR(5) DEFAULT 'en'
```

### Checking Language Support

```sql
SELECT 
    r.id,
    r.name,
    rsc.is_bilingual,
    rsc.default_language
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_service_configs rsc ON rsc.restaurant_id = r.id
WHERE r.id = :restaurant_id;
```

---

## 📱 API Response Pattern

### Language Selection Priority

1. **User preference** - From user profile
2. **Request header** - `Accept-Language: fr`
3. **Restaurant default** - From service config
4. **System default** - English

### Response Structure

```json
{
  "dish": {
    "id": 12345,
    "name": "Pizza Pepperoni",
    "description": "Pepperoni classique avec fromage mozzarella",
    "_metadata": {
      "language": "fr",
      "translated_fields": ["description"],
      "original_language": "en"
    }
  }
}
```

---

## 🔧 Translation Management

### Adding Translations

```sql
-- Add French translation for a dish name
INSERT INTO menuca_v3.translations (
    table_name, record_id, field_name, language, translation
) VALUES (
    'dishes', :dish_id, 'name', 'fr', :french_name
)
ON CONFLICT (table_name, record_id, field_name, language)
DO UPDATE SET 
    translation = EXCLUDED.translation,
    updated_at = NOW();
```

### Bulk Translation Update

```sql
-- Update all dish descriptions from CSV import
WITH translation_data AS (
    SELECT * FROM (VALUES
        (100, 'Pizza au pepperoni'),
        (101, 'Salade César'),
        (102, 'Pâtes Alfredo')
    ) AS t(dish_id, french_description)
)
INSERT INTO menuca_v3.translations (table_name, record_id, field_name, language, translation)
SELECT 'dishes', dish_id, 'description', 'fr', french_description
FROM translation_data
ON CONFLICT (table_name, record_id, field_name, language)
DO UPDATE SET translation = EXCLUDED.translation, updated_at = NOW();
```

---

## 📊 Translation Coverage Report

```sql
-- Check translation coverage for dishes
SELECT 
    r.id as restaurant_id,
    r.name as restaurant_name,
    COUNT(d.id) as total_dishes,
    COUNT(t.id) as translated_dishes,
    ROUND(100.0 * COUNT(t.id) / NULLIF(COUNT(d.id), 0), 1) as coverage_pct
FROM menuca_v3.restaurants r
JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.translations t 
    ON t.table_name = 'dishes' 
    AND t.record_id = d.id 
    AND t.field_name = 'name'
    AND t.language = 'fr'
WHERE r.deleted_at IS NULL
GROUP BY r.id, r.name
ORDER BY coverage_pct DESC;
```

---

## 🏷️ Translatable Fields by Entity

### Restaurant Entity

| Table | Field | Priority |
|-------|-------|----------|
| restaurants | meta_title | Medium |
| restaurants | meta_description | Medium |

### Menu Entity

| Table | Field | Priority |
|-------|-------|----------|
| courses | name | High |
| courses | description | Medium |
| dishes | name | High |
| dishes | description | High |
| dishes | ingredients | Medium |
| modifier_groups | name | High |
| dish_modifiers | name | High |

### Geography Entity

| Table | Field | Priority |
|-------|-------|----------|
| cities | name | High |
| provinces | name | High |
| cuisine_types | name | High |

---

## ⚠️ Considerations

### Performance

- Use language-specific columns for hot data (dish names)
- Use translations table for cold data (descriptions)
- Index translations table appropriately

```sql
CREATE INDEX idx_translations_lookup 
ON menuca_v3.translations (table_name, record_id, language);
```

### Data Consistency

- Validate language codes on insert
- Ensure fallback to default language
- Track translation verification status

### Future Expansion

- Add `es` (Spanish) support when needed
- Consider machine translation for initial content
- Implement translation queue for admin review

---

**Last Updated:** 2025-11-27

