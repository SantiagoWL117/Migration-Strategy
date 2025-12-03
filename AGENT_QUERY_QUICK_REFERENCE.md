# 🚀 Agent Query Quick Reference

## TL;DR: Use Direct psql for Everything (Except Bulk Operations)

The timeout fix allows up to **15 minutes** for all commands. The async script is **optional** for extreme edge cases.

---

## 🎯 Decision Tree

```
Is this a bulk operation affecting 100+ rows?
│
├─ NO → Use direct psql (default)
│
└─ YES → Does it involve complex logic or joins?
          │
          ├─ NO → Use direct psql (should complete in < 15 min)
          │
          └─ YES → Consider async script (if unsure, try direct first)
```

---

## 📋 Command Templates

### Default (Use This 95% of the Time)

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_QUERY"
```

**CRITICAL:**
- `$env:PGCLIENTENCODING="UTF8"` - Handles special characters (é, è, ñ)
- `$env:PAGER=""` - Disables pager
- `--pset pager=off` - Prevents `-- More --` hangs

**Examples:**
```powershell
# ✅ SELECT queries (any size)
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "SELECT * FROM menuca_v3.restaurants WHERE id = 105;"

# ✅ COUNT queries
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "SELECT COUNT(*) FROM menuca_v3.restaurants;"

# ✅ Single row operations
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "UPDATE menuca_v3.restaurants SET status = 'active' WHERE id = 105;"

# ✅ Schema inspection
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "\d menuca_v3.restaurants"

# ✅ Small batch operations (< 100 rows)
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & psql "connection" --pset pager=off -c "UPDATE menuca_v3.restaurants SET status = 'active' WHERE id IN (1, 2, 3, 4, 5);"
```

---

### Async (Only for Extreme Cases)

```powershell
.\scripts\run_psql_async.ps1 -Query "YOUR_QUERY" -OutputFile "results.txt"
Start-Sleep -Seconds 5
Get-Content .\output\results.txt
```

**Examples:**
```powershell
# 🚀 Bulk UPDATE (100+ rows with complex conditions)
.\scripts\run_psql_async.ps1 -Query "
UPDATE menuca_v3.restaurants 
SET legacy_v2_id = NULL 
WHERE id IN (69, 241, 45, ..., 367)
RETURNING *;
" -OutputFile "bulk_nullify.txt"

# 🚀 Complex data migration
.\scripts\run_psql_async.ps1 -Query "
INSERT INTO new_table 
SELECT * FROM old_table t1 
JOIN other_table t2 ON t1.id = t2.ref_id 
WHERE complex_conditions;
" -OutputFile "migration.txt"
```

---

## 🧪 Historical Data (From Your Logs)

| Query Type | Typical Duration | Method | Risk |
|------------|------------------|--------|------|
| SELECT | 400-800ms | Direct | ✅ None |
| COUNT | 300-600ms | Direct | ✅ None |
| Single UPDATE | 500-800ms | Direct | ✅ None |
| Batch UPDATE (10 rows) | 30-60s | Direct | ✅ Low |
| Batch UPDATE (100+ rows) | 2-12 min | Direct (or async) | ⚠️ Medium |
| Complex migrations | Unknown | Async | ⚠️ High |

**Your slowest query:** 12 minutes, 48 seconds (bulk UPDATE of 72 rows)
**New timeout limit:** 15 minutes
**Conclusion:** Even your slowest query would work with direct psql now

---

## 💡 Pro Tips

### 1. Start with Direct psql
If it times out (rare), then retry with async script:
```powershell
# Try direct first
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "connection" -c "query"

# If timeout error, use async
.\scripts\run_psql_async.ps1 -Query "query" -OutputFile "retry.txt"
```

### 2. Batch Large Operations
Instead of updating 1000 rows at once:
```powershell
# ❌ Risky (might take > 15 min)
UPDATE table SET x = y WHERE id IN (1, 2, 3, ..., 1000);

# ✅ Safe (multiple smaller batches)
UPDATE table SET x = y WHERE id IN (1, 2, 3, ..., 100);    # Batch 1
UPDATE table SET x = y WHERE id IN (101, 102, ..., 200);   # Batch 2
# ... etc
```

### 3. Use RETURNING for Verification
```powershell
UPDATE menuca_v3.restaurants 
SET status = 'active' 
WHERE id = 105 
RETURNING id, name, status;  # ← See what changed
```

---

## 🔧 Troubleshooting

### "Command timed out after 15 minutes"
This is extremely rare. If it happens:

1. **Use async script:**
   ```powershell
   .\scripts\run_psql_async.ps1 -Query "..." -OutputFile "long.txt"
   ```

2. **Or break query into smaller batches**

3. **Or optimize the query** (add indexes, simplify conditions)

### "Job never completes"
```powershell
# Check job status
Get-Job

# View job output (even if running)
Receive-Job -Id 1 -Keep

# Kill stuck job
Get-Job -Id 1 | Stop-Job
Get-Job -Id 1 | Remove-Job
```

---

## 🎯 Bottom Line

**For agents:**
- **Default:** Use direct psql command
- **Exception:** Use async script if query explicitly involves bulk operations (100+ rows) with complex logic
- **If unsure:** Try direct psql first, it has a 15-minute safety net

**The async script exists as a safety valve, not a requirement.**

