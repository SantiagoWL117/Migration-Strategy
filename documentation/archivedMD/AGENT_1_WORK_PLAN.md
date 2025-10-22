# 🤖 Agent 1 Work Plan - Users & Access Refactoring

**Entity:** Users & Access  
**Priority:** 2 (CRITICAL - Foundation for all Auth)  
**Status:** ⚠️ MIGRATED (needs Santiago refactoring)  
**Date:** October 17, 2025  

---

## 🎯 **MISSION:**

Refactor the Users & Access entity to Santiago's standards with full RLS, Supabase Auth integration, and production-ready APIs.

---

## 📋 **CURRENT STATE:**

✅ **Data Migrated:**
- `menuca_v3.users` - Customer accounts
- `menuca_v3.admin_users` - Restaurant admin accounts
- `menuca_v3.admin_user_restaurants` - Admin-to-restaurant assignments
- `menuca_v3.user_delivery_addresses` - Customer addresses
- `menuca_v3.user_favorite_restaurants` - Customer favorites

❌ **Missing Santiago Standards:**
- No RLS policies
- No `auth_user_id` integration with Supabase Auth
- No API functions
- No audit trails
- No soft delete
- No multi-language support
- No Santiago documentation

---

## 🔧 **REFACTORING PHASES:**

### **Phase 1: Auth & Security Integration** 🔐

**Goal:** Integrate with Supabase Auth and enable RLS

1. **Add `auth_user_id` columns:**
   ```sql
   ALTER TABLE menuca_v3.users 
   ADD COLUMN auth_user_id UUID REFERENCES auth.users(id);
   
   ALTER TABLE menuca_v3.admin_users 
   ADD COLUMN auth_user_id UUID REFERENCES auth.users(id);
   ```

2. **Create unique indexes:**
   ```sql
   CREATE UNIQUE INDEX idx_users_auth_user_id ON menuca_v3.users(auth_user_id) WHERE deleted_at IS NULL;
   CREATE UNIQUE INDEX idx_admin_users_auth_user_id ON menuca_v3.admin_users(auth_user_id) WHERE deleted_at IS NULL;
   ```

3. **Enable RLS on all tables:**
   - `users`
   - `admin_users`
   - `admin_user_restaurants`
   - `user_delivery_addresses`
   - `user_favorite_restaurants`

4. **Create RLS Policies:**

   **For `users` (Customers):**
   - `users_select_own` - Users can view their own profile
   - `users_insert_own` - Users can create their own profile (via signup)
   - `users_update_own` - Users can update their own profile
   - `users_service_role_all` - Service role has full access

   **For `admin_users` (Restaurant Admins):**
   - `admin_users_select_own` - Admins can view their own profile
   - `admin_users_update_own` - Admins can update their own profile
   - `admin_users_service_role_all` - Service role has full access

   **For `admin_user_restaurants`:**
   - `admin_user_restaurants_select_own` - Admins can view their assignments
   - `admin_user_restaurants_service_role_all` - Service role manages assignments

   **For `user_delivery_addresses`:**
   - `addresses_select_own` - Users can view their addresses
   - `addresses_insert_own` - Users can add addresses
   - `addresses_update_own` - Users can update their addresses
   - `addresses_delete_own` - Users can delete their addresses
   - `addresses_service_role_all` - Service role has full access

   **For `user_favorite_restaurants`:**
   - `favorites_select_own` - Users can view their favorites
   - `favorites_insert_own` - Users can add favorites
   - `favorites_delete_own` - Users can remove favorites
   - `favorites_service_role_all` - Service role has full access

5. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_1_AUTH_INTEGRATION_SUMMARY.md`

---

### **Phase 2: Performance & Core APIs** ⚡

**Goal:** Create SQL functions and optimize performance

1. **Core Customer Functions:**
   ```sql
   -- Get user profile
   CREATE OR REPLACE FUNCTION menuca_v3.get_user_profile()
   
   -- Update user profile
   CREATE OR REPLACE FUNCTION menuca_v3.update_user_profile(...)
   
   -- Get user delivery addresses
   CREATE OR REPLACE FUNCTION menuca_v3.get_user_addresses()
   
   -- Add delivery address
   CREATE OR REPLACE FUNCTION menuca_v3.add_delivery_address(...)
   
   -- Get favorite restaurants
   CREATE OR REPLACE FUNCTION menuca_v3.get_favorite_restaurants()
   
   -- Toggle favorite restaurant
   CREATE OR REPLACE FUNCTION menuca_v3.toggle_favorite_restaurant(...)
   ```

2. **Core Admin Functions:**
   ```sql
   -- Get admin profile
   CREATE OR REPLACE FUNCTION menuca_v3.get_admin_profile()
   
   -- Get admin's assigned restaurants
   CREATE OR REPLACE FUNCTION menuca_v3.get_admin_restaurants()
   
   -- Check if admin has access to restaurant
   CREATE OR REPLACE FUNCTION menuca_v3.check_admin_restaurant_access(...)
   ```

3. **Performance Indexes:**
   ```sql
   -- User lookups
   CREATE INDEX idx_users_email ON menuca_v3.users(email) WHERE deleted_at IS NULL;
   CREATE INDEX idx_users_phone ON menuca_v3.users(phone) WHERE deleted_at IS NULL;
   
   -- Admin lookups
   CREATE INDEX idx_admin_users_email ON menuca_v3.admin_users(email) WHERE deleted_at IS NULL;
   CREATE INDEX idx_admin_user_restaurants_admin ON menuca_v3.admin_user_restaurants(admin_user_id);
   CREATE INDEX idx_admin_user_restaurants_restaurant ON menuca_v3.admin_user_restaurants(restaurant_id);
   
   -- Address lookups
   CREATE INDEX idx_user_addresses_user ON menuca_v3.user_delivery_addresses(user_id) WHERE deleted_at IS NULL;
   
   -- Favorites lookups
   CREATE INDEX idx_favorites_user ON menuca_v3.user_favorite_restaurants(user_id);
   CREATE INDEX idx_favorites_restaurant ON menuca_v3.user_favorite_restaurants(restaurant_id);
   ```

4. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_2_PERFORMANCE_APIS_SUMMARY.md`

---

### **Phase 3: Audit Trails & Soft Delete** 📝

**Goal:** Add comprehensive audit trails

1. **Add audit columns (if missing):**
   ```sql
   -- created_by, updated_by, deleted_by, deleted_at
   ```

2. **Create soft delete views:**
   ```sql
   CREATE VIEW menuca_v3.active_users AS ...
   CREATE VIEW menuca_v3.active_admin_users AS ...
   ```

3. **Create audit trail functions:**
   ```sql
   -- User activity logging
   -- Admin action logging
   ```

4. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_3_AUDIT_SUMMARY.md`

---

### **Phase 4: Real-Time Features** 🔔

**Goal:** Enable real-time updates via Supabase Realtime

1. **Enable realtime on tables:**
   ```sql
   ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.users;
   ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.admin_users;
   ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.user_delivery_addresses;
   ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.user_favorite_restaurants;
   ```

2. **Create notification triggers:**
   ```sql
   -- Notify on profile updates
   -- Notify on new addresses
   -- Notify on favorites changes
   ```

3. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_4_REALTIME_SUMMARY.md`

---

### **Phase 5: Multi-Language Support** 🌍

**Goal:** Support EN/FR/ES for user-facing content

1. **Create translation tables (if needed):**
   ```sql
   -- User interface strings
   -- Error messages
   -- Validation messages
   ```

2. **Add language preference:**
   ```sql
   ALTER TABLE menuca_v3.users ADD COLUMN preferred_language VARCHAR(5) DEFAULT 'en';
   ```

3. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_5_MULTILANG_SUMMARY.md`

---

### **Phase 6: Advanced Features** 🚀

**Goal:** Add production-ready features

1. **Email verification:**
   ```sql
   -- Email verification functions
   -- Phone verification functions
   ```

2. **Account security:**
   ```sql
   -- Password reset tracking
   -- Login attempt tracking
   -- 2FA support (future)
   ```

3. **User analytics:**
   ```sql
   -- Last login tracking
   -- Activity metrics
   ```

4. **Create Santiago Summary:**
   - `Database/Users_&_Access/PHASE_6_ADVANCED_SUMMARY.md`

---

### **Phase 7: Testing & Validation** ✅

**Goal:** Validate all functionality

1. **Test all RLS policies:**
   - Customer isolation
   - Admin isolation
   - Cross-tenant security

2. **Test all SQL functions:**
   - Profile management
   - Address management
   - Favorites management
   - Admin access control

3. **Performance validation:**
   - All queries < 100ms
   - Index usage verified

4. **Create Final Report:**
   - `Database/Users_&_Access/USERS_ACCESS_COMPLETION_REPORT.md`

---

### **Phase 8: Santiago Backend Integration Guide** 📚

**Goal:** Create the master documentation

1. **Create comprehensive guide:**
   - `documentation/Users & Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

2. **Include:**
   - Business problem summary
   - Solution overview
   - Gained business logic
   - Backend API requirements
   - Schema modifications
   - Links to all phase docs

---

## 🎯 **SUCCESS CRITERIA:**

✅ All 5 tables have RLS enabled  
✅ `auth_user_id` integration complete  
✅ 20+ RLS policies created  
✅ 10+ SQL functions for APIs  
✅ Performance indexes in place  
✅ Audit trails complete  
✅ Real-time updates enabled  
✅ Multi-language support  
✅ All phase summaries created  
✅ Santiago Backend Integration Guide complete  
✅ Updated SANTIAGO_MASTER_INDEX.md  

---

## 📊 **WORKFLOW:**

1. **Read current schema** - Use Supabase MCP to check tables
2. **Execute Phase 1** - Auth integration & RLS
3. **Create Phase 1 Summary** - Santiago style
4. **Validate Phase 1** - Check policies work
5. **Repeat for Phases 2-8**
6. **Commit & Push** after each phase
7. **Update master index** when complete

---

## 🚀 **LET'S GO!**

Ready to refactor Users & Access to Santiago's standards!

