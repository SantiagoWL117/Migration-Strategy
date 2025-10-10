# Windows Paths - Deployment Guide

**Created**: January 10, 2025  
**System**: Windows 11 (Santiago's machine)  
**Base Path**: `C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\`

---

## Quick Reference - All Deployment Paths

### Base Configuration

```powershell
# PowerShell variables for easy copy-paste
$BASE = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database"
$PERF = "$BASE\Performance"
$SECURITY = "$BASE\Security"
$COMBOS = "$BASE\Menu & Catalog Entity\combos"
```

---

## Critical Script Paths

### 1. Performance Indexes

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Performance\add_critical_indexes.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$PERF\add_critical_indexes.sql"
```

---

### 2. RLS Policies

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Security\create_rls_policies.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$SECURITY\create_rls_policies.sql"
```

---

### 3. RLS Tests

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/test_rls_policies.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Security\test_rls_policies.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$SECURITY\test_rls_policies.sql"
```

---

### 4. Combo Fix Migration

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/fix_combo_items_migration.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Menu & Catalog Entity\combos\fix_combo_items_migration.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$COMBOS\fix_combo_items_migration.sql"
```

---

### 5. Combo Fix Validation

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/validate_combo_fix.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Menu & Catalog Entity\combos\validate_combo_fix.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$COMBOS\validate_combo_fix.sql"
```

---

### 6. Combo Fix Rollback

**macOS (Original)**:
```bash
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/rollback_combo_fix.sql
```

**Windows (Your System)**:
```powershell
"C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Menu & Catalog Entity\combos\rollback_combo_fix.sql"
```

**PowerShell Command**:
```powershell
psql -h your-db.supabase.co -U postgres -d postgres -f "$COMBOS\rollback_combo_fix.sql"
```

---

## Complete Deployment Script (PowerShell)

### Day 2: Staging Deployment

Save this as `deploy_staging.ps1`:

```powershell
# Santiago's Staging Deployment Script
# Date: January 10, 2025
# Environment: Staging

# Configuration
$BASE = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database"
$PERF = "$BASE\Performance"
$SECURITY = "$BASE\Security"
$COMBOS = "$BASE\Menu & Catalog Entity\combos"

# Database connection (update with your staging DB)
$DB_HOST = "your-staging-db.supabase.co"
$DB_USER = "postgres"
$DB_NAME = "postgres"

Write-Host "=== STAGING DEPLOYMENT START ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

# Stage 1: Backup (Manual via Supabase Dashboard)
Write-Host "`n[STAGE 1] Create backup in Supabase Dashboard" -ForegroundColor Cyan
Write-Host "Press Enter when backup complete..."
Read-Host

# Stage 2: Deploy Performance Indexes
Write-Host "`n[STAGE 2] Deploying Performance Indexes..." -ForegroundColor Cyan
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$PERF\add_critical_indexes.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Indexes deployed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Index deployment failed" -ForegroundColor Red
    exit 1
}

# Stage 3: Deploy RLS Policies
Write-Host "`n[STAGE 3] Deploying RLS Policies..." -ForegroundColor Cyan
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$SECURITY\create_rls_policies.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ RLS policies deployed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ RLS deployment failed" -ForegroundColor Red
    exit 1
}

# Stage 4: Test RLS Policies
Write-Host "`n[STAGE 4] Testing RLS Policies..." -ForegroundColor Cyan
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$SECURITY\test_rls_policies.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ RLS tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠️ RLS tests failed - review output" -ForegroundColor Yellow
}

# Stage 5: Deploy Combo Fix
Write-Host "`n[STAGE 5] Deploying Combo Fix..." -ForegroundColor Cyan
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$COMBOS\fix_combo_items_migration.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Combo fix deployed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Combo fix failed" -ForegroundColor Red
    exit 1
}

# Stage 6: Validate Combo Fix
Write-Host "`n[STAGE 6] Validating Combo Fix..." -ForegroundColor Cyan
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$COMBOS\validate_combo_fix.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Combo validation complete" -ForegroundColor Green
} else {
    Write-Host "⚠️ Combo validation issues - review output" -ForegroundColor Yellow
}

Write-Host "`n=== STAGING DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host "`nNext: Monitor staging for 24 hours before production deployment" -ForegroundColor Cyan
```

---

## Verification Commands

### Check Files Exist

```powershell
# Verify all files exist before deployment
$files = @(
    "$PERF\add_critical_indexes.sql",
    "$SECURITY\create_rls_policies.sql",
    "$SECURITY\test_rls_policies.sql",
    "$COMBOS\fix_combo_items_migration.sql",
    "$COMBOS\validate_combo_fix.sql",
    "$COMBOS\rollback_combo_fix.sql"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
    }
}
```

---

## Database Connection Test

### Test Connection

```powershell
# Test database connection
psql -h your-staging-db.supabase.co -U postgres -d postgres -c "SELECT version();"

# If successful, you'll see PostgreSQL version info
# If failed, check credentials and network connection
```

---

## Quick Commands Cheat Sheet

### Navigate to Base Directory

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database"
```

### List All SQL Files

```powershell
Get-ChildItem -Recurse -Filter "*.sql" | Select-Object FullName
```

### View File Contents

```powershell
Get-Content "$PERF\add_critical_indexes.sql" | Select-Object -First 20
```

### Search for Text in Files

```powershell
Select-String -Path "$PERF\*.sql" -Pattern "CREATE INDEX"
```

---

## Updated QUICK_START_SANTIAGO.md Commands

### Replace These Commands

**OLD (macOS)**:
```bash
psql -h staging-db.supabase.co -f Database/Performance/add_critical_indexes.sql
```

**NEW (Windows)**:
```powershell
psql -h staging-db.supabase.co -U postgres -d postgres -f "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Performance\add_critical_indexes.sql"
```

---

**OLD (macOS)**:
```bash
psql -h staging-db.supabase.co -f Database/Security/create_rls_policies.sql
```

**NEW (Windows)**:
```powershell
psql -h staging-db.supabase.co -U postgres -d postgres -f "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Security\create_rls_policies.sql"
```

---

**OLD (macOS)**:
```bash
psql -h staging-db.supabase.co -f Database/Menu\ &\ Catalog\ Entity/combos/fix_combo_items_migration.sql
```

**NEW (Windows)**:
```powershell
psql -h staging-db.supabase.co -U postgres -d postgres -f "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Menu & Catalog Entity\combos\fix_combo_items_migration.sql"
```

---

## Environment Variables (Optional)

### Set Once Per Session

```powershell
# Add to PowerShell profile or run at start of session
$env:MIGRATION_BASE = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database"
$env:DB_HOST_STAGING = "your-staging-db.supabase.co"
$env:DB_HOST_PROD = "your-production-db.supabase.co"

# Then use like this:
psql -h $env:DB_HOST_STAGING -U postgres -d postgres -f "$env:MIGRATION_BASE\Performance\add_critical_indexes.sql"
```

---

## Common Issues

### Issue 1: Path Not Found

**Error**: `psql: error: could not open file "..." for reading: No such file or directory`

**Solution**: 
- Ensure path is quoted (has spaces)
- Use full path, not relative
- Check file exists: `Test-Path "C:\path\to\file.sql"`

---

### Issue 2: Permission Denied

**Error**: `psql: error: connection to server at "..." failed`

**Solution**:
- Check Supabase credentials
- Verify IP allowlist in Supabase dashboard
- Use correct database URL (check Supabase project settings)

---

### Issue 3: Syntax Error in Script

**Error**: `psql: ...: ERROR: syntax error at or near ...`

**Solution**:
- Review the SQL file for typos
- Check if file is complete (not truncated)
- Run query directly in Supabase SQL editor for testing

---

## Summary

### ✅ Ready to Use

All paths updated from macOS to Windows format. Key differences:

| Aspect | macOS | Windows |
|--------|-------|---------|
| Path separator | `/` | `\` |
| Base path | `/Users/brianlapp/` | `C:\Users\santi\` |
| Project name | `Migration-Strategy` | `Legacy Database\Migration Strategy` |
| Spaces | Escape with `\ ` | Quote entire path |
| Shell | bash | PowerShell |

---

**Last Updated**: January 10, 2025  
**System**: Windows 11  
**User**: Santiago  
**Status**: ✅ **READY FOR DEPLOYMENT**

