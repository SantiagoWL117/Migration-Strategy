# Restaurant Management Entity

**Status:** 🔄 IN PROGRESS (Other Developer)  
**Started:** Before 2025-09-30  
**Developer:** Other team member

---

## 📊 Entity Overview

**Purpose:** Core restaurant data including locations, contacts, domains, admin users, and schedules

**Scope:** Primary business entity for restaurant onboarding and configuration

**Dependencies:** Location & Geography (for restaurant_locations) ✅ COMPLETE

**Blocks:** Service Schedules, Menu & Catalog, Marketing, Vendors, Devices

---

## 📋 Tables in Scope

### Core Tables
1. `menuca_v3.restaurants` - Main restaurant records
2. `menuca_v3.restaurant_locations` - Physical locations (needs cities/provinces ✅)
3. `menuca_v3.restaurant_domains` - Custom domain mappings
4. `menuca_v3.restaurant_contacts` - Contact information
5. `menuca_v3.restaurant_admin_users` - Restaurant admin access
6. `menuca_v3.restaurant_schedules` - Operating hours

### Status
- 🔄 Migration in progress by other developer
- Some tables may already be complete
- Check with team for current status

---

## 📁 Documentation

**Existing Files:**
- `/documentation/Restaurants/restaurant-management-mapping.md` - Field mapping
- `/documentation/Restaurants/restaurants_migration_plan.md` - Core restaurant plan
- `/documentation/Restaurants/restaurant_locations_migration_plan.md` - Locations plan
- `/documentation/Restaurants/restaurant_domains_migration_plan.md` - Domains plan
- `/documentation/Restaurants/restaurant_contacts_migration_plan.md` - Contacts plan
- `/documentation/Restaurants/restaurant_admin_users_migration_plan.md` - Admin users plan

---

## 🔗 Dependencies Status

**Required (Completed):**
- ✅ Location & Geography (provinces, cities) - DONE

**Blocks (Waiting on this entity):**
- ⏳ Service Configuration & Schedules
- ⏳ Menu & Catalog
- ⏳ Marketing & Promotions
- ⏳ Vendors & Franchises
- ⏳ Devices & Infrastructure

---

**Note:** Coordinate with other developer before working on dependent entities.
