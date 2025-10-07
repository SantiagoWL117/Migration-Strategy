# Menu & Catalog Data Loading Instructions

## 🚨 Issue Identified
The staging tables were created with simplified schemas, but the dump files contain the FULL column sets from the original MySQL tables. We need to either:
1. **Use psql to load directly** (RECOMMENDED - handles large files better)
2. Recreate all staging tables with exact source schemas

## ✅ RECOMMENDED: Load via psql

### Step 1: Get Your Database Password
1. Go to: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/settings/database
2. Copy your database password (or reset it)

### Step 2: Run the Bulk Loader

```bash
cd "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity"

# Set your password
export SUPABASE_DB_PASSWORD='your-password-here'

# Run the script
./bulk_load.sh
```

**The script will:**
- ✅ Test connection
- ✅ Load 7 V1 tables
- ✅ Load 10 V2 tables
- ✅ Show progress

---

## 🔄 Alternative: Fix Staging Schemas First

If psql isn't available, I can recreate all staging tables with correct schemas. But psql is the better approach for large data files.

---

## 📊 After Loading - Verification

Run this to verify:
```bash
cd "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity"
export SUPABASE_DB_PASSWORD='your-password'

psql "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:$SUPABASE_DB_PASSWORD@aws-0-us-east-1.pooler.supabase.com:6543/postgres" <<EOF
SELECT 'v1_courses' as table, count(*) from staging.v1_courses
UNION ALL SELECT 'v1_menu', count(*) from staging.v1_menu
UNION ALL SELECT 'v1_menuothers', count(*) from staging.v1_menuothers
UNION ALL SELECT 'v1_combos', count(*) from staging.v1_combos
UNION ALL SELECT 'v2_dishes', count(*) from staging.v2_restaurants_dishes;
EOF
```

---

**Let me know which approach you want to take!** 🚀

