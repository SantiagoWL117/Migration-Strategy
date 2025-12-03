# 🔐 Environment Variables Access Guide for Agents

## 📍 Location

`.env` file is located at:
```
C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\.env
```

---

## 📋 Available Variables

### Database Connection
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase service role key
- `DB_CONNECTION_STRING` - PostgreSQL connection string for menuca_v3 schema

### Legacy CRM Credentials
- `CRM_BASE_URL` - CRM admin URL (varies by version)
- `CRM_USERNAME` - Admin username
- `CRM_PASSWORD` - Admin password

---

## 🚀 Quick Access Methods

### Method 1: PowerShell Direct Read (Simplest)

```powershell
# Read entire .env file
Get-Content ".\.env"

# Get specific line containing a variable
Get-Content ".\.env" | Select-String "DB_CONNECTION_STRING"
```

### Method 2: Load Environment Helper Script

```powershell
# Show all variables (with sensitive data masked)
.\scripts\load_env.ps1 -Show

# Get specific variable value
$dbConn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"
Write-Host $dbConn

# Load all variables into a hashtable
$env = .\scripts\load_env.ps1
$env["SUPABASE_URL"]
```

### Method 3: Quick DB Connection Helper

```powershell
# Get DB connection string ready for psql
$conn = .\scripts\get_db_connection.ps1

# Use it in a query
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn -c "SELECT COUNT(*) FROM menuca_v3.restaurants;"
```

---

## 💡 Common Use Cases

### 1. Run Database Query with Connection from .env

```powershell
# Get connection string
$conn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"

# Run query
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn -c "
SELECT id, name, status 
FROM menuca_v3.restaurants 
LIMIT 5;
"
```

### 2. Use in Python Scripts

```powershell
# Export variables to environment
.\scripts\load_env.ps1 -Export

# Now Python can access via os.environ
python your_script.py  # Will have access to all .env variables
```

### 3. Display All Available Credentials

```powershell
.\scripts\load_env.ps1 -Show
```

Output:
```
📋 Environment Variables from .env:
================================================================================
  CRM_BASE_URL = https://aggregator-admin.menu.ca/index.php/welcome/index
  CRM_PASSWORD = WL21...25*
  CRM_USERNAME = santiago@worklocal.ca
  DB_CONNECTION_STRING = postgresql://postgres:Gz35...MnsmGM@db.nthpbtdjhhnwfxqsxbvy...
  SUPABASE_KEY = eyJh...ch1g
  SUPABASE_URL = https://nthpbtdjhhnwfxqsxbvy.supabase.co
================================================================================
```

---

## 🔒 Security Notes

### ✅ Safe Practices

1. **Never commit .env to git** - Already in `.gitignore`
2. **Use helper scripts** - They mask sensitive values when displayed
3. **Avoid hardcoding** - Always reference .env variables
4. **Use Process scope** - Variables only exist in current session

### ⚠️ When Displaying Credentials

```powershell
# ❌ DON'T: Display raw passwords in logs
Get-Content ".\.env"

# ✅ DO: Use the helper that masks sensitive data
.\scripts\load_env.ps1 -Show

# ✅ DO: Get specific values programmatically without displaying
$password = .\scripts\load_env.ps1 -Get "CRM_PASSWORD"
# Use $password in script without echoing
```

---

## 🎯 Agent Instructions

### Default Database Query Pattern

**Option A: Use hardcoded connection (current method):**
```powershell
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR_QUERY"
```

**Option B: Use .env connection (more maintainable):**
```powershell
$conn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn -c "YOUR_QUERY"
```

**Recommended:** Stick with **Option A** for simplicity unless credentials change frequently.

---

## 📊 .env File Structure

```ini
# Supabase Connection
SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
SUPABASE_KEY=eyJhbGciOiJI...

# Database Connection String (for menuca_v3 schema)
DB_CONNECTION_STRING=postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres

# Legacy CRM (V1) CREDENTIALS
CRM_BASE_URL=https://menuadmin.menu.ca/?p=restaurants
CRM_USERNAME=santiago@worklocal.ca
CRM_PASSWORD=542sfgsgeerg4%$

# Legacy CRM (V2) CREDENTIALS
CRM_BASE_URL=https://aggregator-admin.menu.ca/index.php/welcome/index
CRM_USERNAME=santiago@worklocal.ca
CRM_PASSWORD=WL2129925*
```

---

## 🧪 Testing Access

Run this to verify everything works:

```powershell
# Test 1: Can read .env file?
Test-Path ".\.env"
# Should return: True

# Test 2: Can load variables?
.\scripts\load_env.ps1 -Show
# Should display all variables with masked sensitive data

# Test 3: Can get specific variable?
$testConn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"
Write-Host "Connection: $testConn"
# Should display the full connection string

# Test 4: Can use in query?
$conn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn -c "SELECT 'ENV access working!' as test;"
# Should return: test
#                ENV access working!
```

---

## 🔧 Troubleshooting

### ".env file not found"

```powershell
# Verify file exists
Test-Path "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\.env"

# Check you're in correct directory
Get-Location
# Should be: C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy

# Navigate if needed
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"
```

### "Variable not found"

```powershell
# List all available variables
.\scripts\load_env.ps1 -Show

# Check exact spelling (case-sensitive)
Get-Content ".\.env" | Select-String "YOUR_VAR_NAME"
```

### "Permission denied"

```powershell
# Check file permissions
Get-Acl ".\.env" | Format-List

# Ensure you can read it
Get-Content ".\.env" -ErrorAction Stop
```

---

## 📚 Summary

**For Agents:**
1. ✅ Can read `.env` directly: `Get-Content ".\.env"`
2. ✅ Can use helper script: `.\scripts\load_env.ps1 -Get "VAR_NAME"`
3. ✅ Can get DB connection: `.\scripts\get_db_connection.ps1`
4. ✅ All credentials are centralized in one place

**Best Practice:** Use the helper scripts - they handle parsing, validation, and security masking automatically.

