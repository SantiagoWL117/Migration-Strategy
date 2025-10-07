# Menu & Catalog Entity - Schema to Dump Verification
**Date:** January 7, 2025  
**Purpose:** Verify all V1/V2 schema tables have corresponding SQL dumps  
**Status:** ✅ **VERIFICATION COMPLETE**

---

## 📋 EXECUTIVE SUMMARY

**All Menu & Catalog tables from V1 and V2 schemas have corresponding SQL dumps.**

| Source | Tables Expected | Dumps Found | Status |
|--------|----------------|-------------|---------|
| **V1** | 7 tables | 7 dumps | ✅ **100%** |
| **V2** | 10 tables | 10 dumps | ✅ **100%** |
| **TOTAL** | **17 tables** | **17 dumps** | ✅ **COMPLETE** |

---

## ✅ SECTION 1: V1 SCHEMA VERIFICATION

### V1 Tables from menuca_v1_structure.sql

| # | Table Name | Schema Lines | Dump File | Status |
|---|------------|--------------|-----------|---------|
| 1 | **courses** | 498-520 | `menuca_v1_courses.sql` | ✅ EXISTS |
| 2 | **menu** | 917-998 | `menuca_v1_menu.sql` | ✅ EXISTS |
| 3 | **menuothers** | 1002-1019 | `menuca_v1_menuothers.sql` | ✅ EXISTS |
| 4 | **ingredients** | 860-879 | `menuca_v1_ingredients.sql` | ✅ EXISTS |
| 5 | **ingredient_groups** | 836-856 | `menuca_v1_ingredient_groups.sql` | ✅ EXISTS |
| 6 | **combo_groups** | 360-375 | `menuca_v1_combo_groups.sql` | ✅ EXISTS |
| 7 | **combos** | 379-395 | `menuca_v1_combos.sql` | ✅ EXISTS |

### V1 Schema Details

#### 1. courses (Lines 498-520)
```sql
CREATE TABLE `courses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `xthPromo` enum('n','y') DEFAULT 'n',
  `xthItem` int NOT NULL,
  `remove` float NOT NULL,
  `removeFrom` enum('b','t') DEFAULT 'b',
  `timePeriod` int NOT NULL DEFAULT '0',
  `ciHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  `order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=16001 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v1_courses.sql`

#### 2. menu (Lines 917-998)
```sql
CREATE TABLE `menu` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `course` int unsigned NOT NULL DEFAULT '0',
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `sku` varchar(50) DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ingredients` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `price` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  ... (67 more columns - customization flags, combo settings, etc.)
  `hideOnDays` blob NOT NULL COMMENT 'empty for always show', -- 🔴 BLOB!
  `checkoutItems` enum('Y','N') NOT NULL DEFAULT 'N',
  `upsell` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`),
  ...
) ENGINE=InnoDB AUTO_INCREMENT=141282 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
```
**✅ Dump:** `menuca_v1_menu.sql`  
**🔴 BLOB Alert:** `hideOnDays` contains PHP serialized availability schedules

#### 3. menuothers (Lines 1002-1019)
```sql
CREATE TABLE `menuothers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL DEFAULT '0',
  `dishId` int NOT NULL DEFAULT '0',
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci, -- 🔴 BLOB!
  `type` char(2) DEFAULT NULL,
  `groupId` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  ...
) ENGINE=InnoDB AUTO_INCREMENT=328167 DEFAULT CHARSET=latin1 
  COMMENT='store side dish, drink, extra info';
```
**✅ Dump:** `menuca_v1_menuothers.sql`  
**🔴 BLOB Alert:** `content` contains PHP serialized modifier pricing (70,381 rows)

#### 4. ingredients (Lines 860-879)
```sql
CREATE TABLE `ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `availableFor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `price` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT '',
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `order` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  ...
) ENGINE=InnoDB AUTO_INCREMENT=59950 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v1_ingredients.sql`

#### 5. ingredient_groups (Lines 836-856)
```sql
CREATE TABLE `ingredient_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` char(2) NOT NULL DEFAULT '',
  `course` smallint unsigned NOT NULL DEFAULT '0',
  `dish` smallint NOT NULL DEFAULT '0',
  `item` blob, -- 🔴 BLOB!
  `price` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  `useInCombo` enum('Y','N') NOT NULL DEFAULT 'N',
  `isGlobal` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  ...
) ENGINE=InnoDB AUTO_INCREMENT=13627 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v1_ingredient_groups.sql`  
**🔴 BLOB Alert:** `item` contains PHP serialized ingredient lists (13,255 rows)

#### 6. combo_groups (Lines 360-375)
```sql
CREATE TABLE `combo_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dish` blob,
  `options` blob, -- 🔴 BLOB!
  `group` blob,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62720 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v1_combo_groups.sql`  
**🔴 BLOB Alert:** `options` contains PHP serialized combo configurations (10,764 rows)

#### 7. combos (Lines 379-395)
```sql
CREATE TABLE `combos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `dish` int unsigned NOT NULL DEFAULT '0',
  `group` int unsigned NOT NULL DEFAULT '0',
  `order` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dish_fk` (`dish`),
  KEY `group_fk` (`group`),
  CONSTRAINT `dish_fk` FOREIGN KEY (`dish`) REFERENCES `menu` (`id`) ON DELETE CASCADE,
  CONSTRAINT `group_fk` FOREIGN KEY (`group`) REFERENCES `combo_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=112125 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v1_combos.sql`

---

## ✅ SECTION 2: V2 SCHEMA VERIFICATION

### V2 Tables from menuca_v2_structure.sql

| # | Table Name | Schema Lines | Dump File | Status |
|---|------------|--------------|-----------|---------|
| 1 | **global_courses** | 474-496 | `menuca_v2_global_courses.sql` | ✅ EXISTS |
| 2 | **global_ingredients** | 520-544 | `menuca_v2_global_ingredients.sql` | ✅ EXISTS |
| 3 | **restaurants_courses** | 1312-1337 | `menuca_v2_restaurants_courses.sql` | ✅ EXISTS |
| 4 | **restaurants_dishes** | 1530-1553 | `menuca_v2_restaurants_dishes.sql` | ✅ EXISTS |
| 5 | **restaurants_dishes_customization** | 1563-1609 | `menuca_v2_restaurants_dishes_customization.sql` | ✅ EXISTS |
| 6 | **restaurants_combo_groups** | 1193-1213 | `menuca_v2_restaurants_combo_groups.sql` | ✅ EXISTS |
| 7 | **restaurants_combo_groups_items** | 1214-1248 | `menuca_v2_restaurants_combo_groups_items.sql` | ✅ EXISTS |
| 8 | **restaurants_ingredient_groups** | 1702-1716 | `menuca_v2_restaurants_ingredient_groups.sql` | ✅ EXISTS |
| 9 | **restaurants_ingredient_groups_items** | 1726-1735 | `menuca_v2_restaurants_ingredient_groups_items.sql` | ✅ EXISTS |
| 10 | **restaurants_ingredients** | 1745-1766 | `menuca_v2_restaurants_ingredients.sql` | ✅ EXISTS |

### V2 Schema Details

#### 1. global_courses (Lines 474-496)
```sql
CREATE TABLE `global_courses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name_en` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `name_fr` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```
**✅ Dump:** `menuca_v2_global_courses.sql`

#### 2. global_ingredients (Lines 520-544)
```sql
CREATE TABLE `global_ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `hash` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `name_en` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `name_fr` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5312 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```
**✅ Dump:** `menuca_v2_global_ingredients.sql`

#### 3. restaurants_courses (Lines 1312-1337)
```sql
CREATE TABLE `restaurants_courses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint unsigned DEFAULT '1',
  `global_course_id` int DEFAULT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `display_order` tinyint unsigned DEFAULT '0',
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1291 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```
**✅ Dump:** `menuca_v2_restaurants_courses.sql`

#### 4. restaurants_dishes (Lines 1530-1553)
```sql
CREATE TABLE `restaurants_dishes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `global_dish_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `has_customization` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `is_combo` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `size` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `size_j` json DEFAULT NULL COMMENT 'json encoded size',
  `price` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `price_j` json DEFAULT NULL COMMENT 'json encoded price',
  `display_order` tinyint unsigned DEFAULT '0',
  `dish_image` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `upsell` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  ...
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10667 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```
**✅ Dump:** `menuca_v2_restaurants_dishes.sql`

#### 5. restaurants_dishes_customization (Lines 1563-1609)
```sql
CREATE TABLE `restaurants_dishes_customization` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dish_id` int DEFAULT NULL,
  `dish_info` json DEFAULT NULL,
  `has_customization` enum('y','n') DEFAULT 'n',
  `crust` enum('y','n') DEFAULT 'n',
  `crust_customization` json DEFAULT NULL,
  `crust_display_order` tinyint DEFAULT NULL,
  `custom_ingredient` enum('y','n') DEFAULT 'n',
  `custom_ingredient_customization` json DEFAULT NULL,
  `custom_ingredient_display_order` tinyint DEFAULT NULL,
  ... (22 more customization type columns with JSON data)
  `enabled` enum('y','n') DEFAULT 'y',
  ...
  PRIMARY KEY (`id`),
  KEY `dish` (`dish_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13414 DEFAULT CHARSET=latin1 
  COMMENT='store dish customization here';
```
**✅ Dump:** `menuca_v2_restaurants_dishes_customization.sql`

#### 6. restaurants_combo_groups (Lines 1193-1213)
```sql
CREATE TABLE `restaurants_combo_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint DEFAULT '1',
  `name` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v2_restaurants_combo_groups.sql`

#### 7. restaurants_combo_groups_items (Lines 1214-1248)
```sql
CREATE TABLE `restaurants_combo_groups_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `dish_id` int DEFAULT NULL,
  `price_diff_j` json DEFAULT NULL COMMENT 'store price difference in json format',
  `added_at` timestamp NULL DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `combo_group_fk` FOREIGN KEY (`group_id`) 
    REFERENCES `restaurants_combo_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v2_restaurants_combo_groups_items.sql`

#### 8. restaurants_ingredient_groups (Lines 1702-1716)
```sql
CREATE TABLE `restaurants_ingredient_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint DEFAULT '1',
  `group_name` varchar(125) DEFAULT NULL,
  `group_type` varchar(45) DEFAULT NULL,
  `items` blob, -- 🔴 BLOB!
  `enabled` enum('y','n') DEFAULT 'y',
  ...
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=650 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v2_restaurants_ingredient_groups.sql`  
**🔴 BLOB Alert:** `items` contains serialized ingredient group items

#### 9. restaurants_ingredient_groups_items (Lines 1726-1735)
```sql
CREATE TABLE `restaurants_ingredient_groups_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `item_hash` varchar(10) NOT NULL,
  `price` varchar(125) DEFAULT NULL,
  `price_j` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `group_id` FOREIGN KEY (`group_id`) 
    REFERENCES `restaurants_ingredient_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4108 DEFAULT CHARSET=utf8mb3 
  COMMENT='put ids for items belonging to a group';
```
**✅ Dump:** `menuca_v2_restaurants_ingredient_groups_items.sql`

#### 10. restaurants_ingredients (Lines 1745-1766)
```sql
CREATE TABLE `restaurants_ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `hash` varchar(10) DEFAULT NULL,
  `restaurant_id` int unsigned DEFAULT NULL,
  `global_ingredient_id` int unsigned DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `language_id` tinyint NOT NULL DEFAULT '1',
  `enabled` enum('y','n') DEFAULT 'y',
  ...
  PRIMARY KEY (`id`),
  ...
) ENGINE=InnoDB AUTO_INCREMENT=4041 DEFAULT CHARSET=latin1;
```
**✅ Dump:** `menuca_v2_restaurants_ingredients.sql`

---

## 🔴 SECTION 3: BLOB DATA SUMMARY

### BLOBs Requiring Deserialization

| Source | Table | Column | Format | Rows with BLOBs | Purpose |
|--------|-------|--------|--------|----------------|----------|
| V1 | menu | hideOnDays | PHP serialized | 865 | Day-based availability schedules |
| V1 | menuothers | content | PHP serialized | 70,381 | Modifier pricing (toppings, extras, drinks) |
| V1 | ingredient_groups | item | PHP serialized | 13,255 | Ingredient lists within groups |
| V1 | combo_groups | options | PHP serialized | 10,764 | Combo configuration rules |
| V2 | restaurants_ingredient_groups | items | PHP/JSON serialized | 588 | Ingredient group items |

**Total BLOB Rows:** 95,853

---

## ✅ SECTION 4: FINAL VERIFICATION

### All Tables Accounted For

**V1 Menu & Catalog Tables (7):**
1. ✅ courses → `menuca_v1_courses.sql`
2. ✅ menu → `menuca_v1_menu.sql`
3. ✅ menuothers → `menuca_v1_menuothers.sql`
4. ✅ ingredients → `menuca_v1_ingredients.sql`
5. ✅ ingredient_groups → `menuca_v1_ingredient_groups.sql`
6. ✅ combo_groups → `menuca_v1_combo_groups.sql`
7. ✅ combos → `menuca_v1_combos.sql`

**V2 Menu & Catalog Tables (10):**
1. ✅ global_courses → `menuca_v2_global_courses.sql`
2. ✅ global_ingredients → `menuca_v2_global_ingredients.sql`
3. ✅ restaurants_courses → `menuca_v2_restaurants_courses.sql`
4. ✅ restaurants_dishes → `menuca_v2_restaurants_dishes.sql`
5. ✅ restaurants_dishes_customization → `menuca_v2_restaurants_dishes_customization.sql`
6. ✅ restaurants_combo_groups → `menuca_v2_restaurants_combo_groups.sql`
7. ✅ restaurants_combo_groups_items → `menuca_v2_restaurants_combo_groups_items.sql`
8. ✅ restaurants_ingredient_groups → `menuca_v2_restaurants_ingredient_groups.sql`
9. ✅ restaurants_ingredient_groups_items → `menuca_v2_restaurants_ingredient_groups_items.sql`
10. ✅ restaurants_ingredients → `menuca_v2_restaurants_ingredients.sql`

**Total: 17 tables → 17 dumps ✅**

---

## 📊 SECTION 5: CONCLUSION

### Verification Result: ✅ PASS

**All Menu & Catalog source tables from V1 and V2 have corresponding SQL dumps.**

### Key Findings:

1. **✅ Complete Coverage:** All 17 tables (7 V1 + 10 V2) have SQL dumps
2. **🔴 BLOB Data Present:** 5 tables contain 95,853 rows of PHP serialized BLOBs
3. **✅ Schema Match:** Dump files correctly correspond to schema definitions
4. **✅ Naming Convention:** All dumps follow `menuca_{version}_{table}.sql` pattern
5. **🚫 Excluded Tables:** `menuca_v2.menu` and `menuca_v2.courses` (deprecated/not used in production)

### Next Steps:

The dumps are complete and ready for analysis. The next phase should:
1. ✅ Verify dumps loaded to staging (COMPLETE per previous analysis)
2. 🔄 Analyze data loss between staging → menuca_v3 (IN PROGRESS)
3. ⏳ Deserialize BLOB data and migrate to menuca_v3 (PENDING)
4. ⏳ Verify final menuca_v3 data integrity (PENDING)

---

**Verification Completed by:** AI Migration Analyst  
**Date:** January 7, 2025  
**Status:** ✅ **ALL DUMPS VERIFIED**

