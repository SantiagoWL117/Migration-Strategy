# 🔧 PSQL Pager Fix - Preventing "-- More --" Hangs

## 🚨 Problem

When psql results exceed one screen, it uses a pager (like `less` or `more`) that shows:
```
-- More --
```

This **waits for user input**, causing agent commands to **hang indefinitely** because agents can't interact with the pager prompt.

**Evidence:**
```powershell
PS> & psql "connection" -c "SELECT * FROM large_table;"
# ... results ...
-- More --    ← HUNG! Waiting for spacebar/enter, agent times out
```

---

## ✅ Solution

**Always disable the pager** when running psql commands in agents.

### Method 1: Command-Line Flag (Recommended)

Add `--pset pager=off` to every psql command:

```powershell
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" --pset pager=off -c "QUERY"
```

### Method 2: Environment Variable

Set `PAGER` to empty before running psql:

```powershell
$env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" -c "QUERY"
```

### Method 3: Combined (Safest + Encoding Fix)

Use both methods plus encoding fix for maximum reliability:

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" --pset pager=off -c "QUERY"
```

**Why `PGCLIENTENCODING="UTF8"`?**
- Handles special characters (é, è, ñ, etc.) in restaurant names and addresses
- Prevents encoding errors like: `ERROR: character with byte sequence 0xef in encoding "UTF8" has no equivalent in encoding "WIN1252"`

---

## 📋 Updated Command Templates

### Standard Query (Direct Connection)

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_QUERY"
```

### Using .env Connection

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; $conn = .\scripts\get_db_connection.ps1
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn --pset pager=off -c "YOUR_QUERY"
```

### Async Script

The async script (`run_psql_async.ps1`) has been updated to automatically include `--pset pager=off`.

```powershell
.\scripts\run_psql_async.ps1 -Query "YOUR_QUERY" -OutputFile "results.txt"
```

---

## 🧪 Testing the Fix

### Before Fix (Would Hang)

```powershell
# This would hang on large result sets
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" -c "
SELECT r.id, r.name, rl.street_address 
FROM menuca_v3.restaurants r 
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id 
ORDER BY r.name;
"
```

### After Fix (Works)

```powershell
# This completes successfully regardless of result size
$env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT r.id, r.name, rl.street_address 
FROM menuca_v3.restaurants r 
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id 
ORDER BY r.name;
"
```

---

## 🎯 Agent Guidelines

### CRITICAL Rule

**Every psql command MUST include `--pset pager=off`**

### Quick Reference

| Scenario | Command Template |
|----------|------------------|
| **Quick query** | `$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "conn" --pset pager=off -c "QUERY"` |
| **With .env** | `$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; $conn = .\scripts\get_db_connection.ps1; & psql $conn --pset pager=off -c "QUERY"` |
| **Async query** | `.\scripts\run_psql_async.ps1 -Query "QUERY" -OutputFile "results.txt"` |

### Example: Your Problematic Query (Fixed)

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT 
  r.id as v3_id, 
  r.legacy_v1_id as v1_id, 
  r.legacy_v2_id as v2_id, 
  r.name, 
  rl.street_address 
FROM menuca_v3.restaurants r 
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id 
WHERE 
  r.legacy_v1_id IS NOT NULL 
  AND r.legacy_v1_id != 0 
  AND r.deleted_at IS NULL 
  AND r.id NOT IN (265, 607, 924, 948, 949) 
ORDER BY r.name, rl.street_address;
"
```

This will now return **all results immediately** without the `-- More --` hang.

---

## 🔧 What Was Updated

### 1. MVP_RESTAURANTS.md
- ✅ Default query method includes `--pset pager=off`
- ✅ Environment variable examples include `$env:PAGER=""`
- ✅ All psql examples updated

### 2. run_psql_async.ps1
- ✅ Script automatically sets `$env:PAGER=""` 
- ✅ Script includes `--pset pager=off` flag

### 3. ENV_ACCESS_GUIDE.md
- ✅ All psql examples updated with pager fix

---

## 📊 Why This Happens

### Pager Behavior

- psql uses a pager when output > terminal height (usually ~20-50 lines)
- Common pagers: `less`, `more`, `bat`
- Pagers wait for user input:
  - `Space` = next page
  - `Enter` = next line
  - `q` = quit

### Why Agents Hang

1. Agent runs psql command
2. Results exceed screen size
3. Pager activates: `-- More --`
4. Pager waits for keypress
5. Agent can't send keypress
6. Command hangs until timeout (15 minutes)

### The Fix

`--pset pager=off` tells psql: "Don't use a pager, just dump all output at once"

---

## 🐛 Troubleshooting

### "Still seeing -- More --"

Check your command includes **both**:
```powershell
$env:PAGER=""                    # Environment variable
& psql ... --pset pager=off ...  # Command flag
```

### "Results cut off"

The pager isn't the issue - results should be complete. Check:
```powershell
# Redirect to file to see full output
& psql "conn" --pset pager=off -c "QUERY" > results.txt
Get-Content results.txt
```

### "Works in terminal but not in agent"

Terminals can handle interactive prompts, agents can't. Always use `--pset pager=off` in agent commands.

---

## ✅ Summary

**Problem:** psql pager (`-- More --`) hangs agent commands
**Solution:** Always add `--pset pager=off` to psql commands
**Updated:** All scripts, documentation, and examples

**Every agent psql command must now look like:**
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "QUERY"
```

**Fixed:**
- ✅ No more `-- More --` hangs
- ✅ No more encoding errors  
- ✅ Complete results returned every time

🎉

