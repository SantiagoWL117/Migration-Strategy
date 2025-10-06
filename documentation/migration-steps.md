# Migration Strategy Overview

## Original Process Definition

**Purpose:** 
Extract step:
    1.    Field mapping:
    2. Verification: Review other possible tables that could be useful in V1 and V2
    3. Santiago step: Based on field mapping, add Dump of the required data to the Project for further analysis.
    4. Create the menuca_v3 tables according to the columns and format of the data dumps.
    5.  Extract data as CSV from the tables and columns defined in step 1 (Field mapping) 
    6.  Based on the CSV data build the staging tables. please suggest p[olicies for me to review before implimenting
Transform Step:
    1. Verify format discrepencies accoross the CSV file
Load step: 
    1. Build a transaction for the Transform and Upsert step to load the data from the staging tables to the menuca_v3 tables
Verification step: 
     Create verification queries that verify data integrity and that ensure that all the relevant data was migrated from the staging tables to menuca_v3 tables. Always include an explanation of the query and the expected outcome.

---

## Core Business Entities - Migration Status

### 1. Restaurant Management ✅ (Completed/In Progress)
- [x] **restaurants** - Main restaurant profiles (Base entity)
- [x] **restaurant_locations** - Physical addresses and geocoding
- [x] **restaurant_domains** - Domain mappings
- [x] **restaurant_contacts** - Contact information
- [x] **restaurant_admin_users** - Admin access and authentication
- [] **restaurant_schedules** - Business hours and service availability (See dedicated plan)

### 2. Service Configuration & Schedules 🔄 (In Progress - Phase 2 Complete)
**Documentation**: `Service Configuration & Schedules/SERVICE_SCHEDULES_MIGRATION_GUIDE.md`

**V3 Schema Created** (2025-10-03):
- [x] `restaurant_schedules` - Regular delivery/takeout hours
- [x] `restaurant_special_schedules` - Holiday/vacation schedules
- [x] `restaurant_service_configs` - Service capabilities
- [x] `restaurant_time_periods` - Named time windows (Lunch, Dinner)

**Data Extraction Completed** (2025-10-04):
- [x] Phase 1: Schema Creation ✅
- [x] Phase 2: Data Extraction ✅ (9,898 rows extracted to CSV)
- [ ] Phase 3: Staging Tables (Next)
- [ ] Phase 4: Data Transformation
- [ ] Phase 5: Load to V3
- [ ] Phase 6: Verification

**Data Sources**:
- V1: `restaurants_schedule_normalized` (6,341 rows), service flags (847 restaurants)
- V2: `restaurants_schedule` (1,984 rows), `restaurants_special_schedule` (84 rows), `restaurants_time_periods` (8 rows), service flags (629 restaurants)

**Status**: ✅ Ready for Phase 3: Staging Tables  
**Timeline**: 6-8 days | **Complexity**: 🟢 LOW-MEDIUM

### 3. Location & Geography 🔄 (In Progress)
- Geography reference tables (provinces, cities)
- Delivery areas and radius configurations

### 4. Menu & Catalog ⏳ (Not Started)
- Menu structure (courses, dishes)
- Ingredients and customizations
- Combos and meal deals

### 5. Orders & Checkout ⏳ (Not Started)
- Order lifecycle management
- Line items and customizations

### 6. Payments ⏳ (Not Started)
- Payment profiles and transactions
- Provider integrations

### 7. Users & Access ⏳ (Not Started)
- Customer accounts
- Access control and sessions

---

## Standard Migration Process

### Purpose
Migrate data from legacy systems (V1/V2) to the new V3 schema using an ETL approach.

### Extract Step:
1. **(AI responsibility)** Field mapping: Analyze source and target schemas
2. **(User responsibility)** Review other possible tables that could be useful in V1 and V2
3. **(User responsibility)** Based on field mapping, add Dump of the required data to the Project for further analysis
4. **(AI responsibility)** Preconditions: Create the menuca_v3 tables according to the columns and format of the data dumps
5. **(User responsibility)** Extract data as CSV from the tables and columns defined in step 1 (Field mapping) 
6. **(AI responsibility)** Based on the CSV data build the staging tables

### Transform Step:
1. Verify format discrepancies across the CSV file
2. Handle data type conversions
3. Resolve conflicts between V1 and V2 sources
4. Apply business rules and validations
5. Generate audit trails

### Load Step: 
1. Build a Transform and Upsert step to load the data from the staging tables to the menuca_v3 tables
2. Handle foreign key relationships
3. Maintain referential integrity

### Verification Step: 
**(AI responsibility)** Create verification queries that verify data integrity and that ensure that all the relevant data was migrated from the staging tables to menuca_v3 tables. Always include an explanation of the query and the expected outcome.

