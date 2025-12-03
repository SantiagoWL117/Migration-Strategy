# 🤖 Standard Agent Database Command Template

**Copy-paste this into every agent prompt that needs database access:**

---

## 📋 Standard Query Command

**Use this EXACT command for ALL database queries:**

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
```

---

## 🎯 Include This in Agent Prompts

```
CRITICAL DATABASE QUERY PROTOCOL:

You MUST use this exact command for all database queries:

$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"

ALL THREE COMPONENTS ARE REQUIRED:
- $env:PGCLIENTENCODING="UTF8" - Handles special characters
- $env:PAGER="" - Prevents system pager hangs  
- --pset pager=off - Prevents psql "-- More --" hangs

DO NOT simplify or omit any part of this command.
Queries without all components WILL hang on result sets >20 rows.
```

---

## ✅ Example Usage

**User asks:** "Show me all restaurants"

**Agent responds with:**
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT id, name, status, created_at
FROM menuca_v3.restaurants
WHERE deleted_at IS NULL
ORDER BY name;
"
```

---

## ❌ Common Mistakes to Avoid

### ❌ Providing only SQL
```sql
SELECT * FROM menuca_v3.restaurants;
```
**Problem:** Missing command wrapper, won't execute properly

### ❌ Simplified command
```powershell
& psql "connection" -c "SELECT * FROM menuca_v3.restaurants;"
```
**Problem:** Missing encoding and pager fixes, will hang on large results

### ❌ Omitting environment variables
```powershell
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" --pset pager=off -c "SQL"
```
**Problem:** Missing `PGCLIENTENCODING` and `PAGER`, will fail on special characters and may hang

---

## 📖 Reference Documentation

Full details: `Menu.ca V3/README.md` section **"Database Query Protocol"**

Troubleshooting: `PSQL_PAGER_FIX.md`

---

## 🔄 Quick Copy Templates

### SELECT Query
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT * FROM menuca_v3.TABLE_NAME WHERE condition;
"
```

### UPDATE Query
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
UPDATE menuca_v3.TABLE_NAME 
SET column = value 
WHERE condition
RETURNING *;
"
```

### COUNT Query
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT COUNT(*) FROM menuca_v3.TABLE_NAME WHERE condition;
"
```

### JOIN Query
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT t1.*, t2.column
FROM menuca_v3.table1 t1
JOIN menuca_v3.table2 t2 ON t1.id = t2.foreign_id
WHERE condition;
"
```

---

## 📝 Agent Instruction Template

**Add this to your agent's system prompt or initial instructions:**

```
You are working with the menuca_v3 PostgreSQL database on Supabase.

MANDATORY: For ALL database queries, you MUST use this exact command:

$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"

Never provide SQL queries without this complete command wrapper.
Never omit or simplify any part of this command.
All three components ($env:PGCLIENTENCODING, $env:PAGER, --pset pager=off) are required.

When the user asks for a query, provide the full executable command, not just the SQL.
```

---

**Last Updated:** 2025-12-01  
**Status:** ✅ Tested and verified working

