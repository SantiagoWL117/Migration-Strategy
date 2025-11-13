# Quick Start Guide - 5 Minutes to First Scrape

## ⚡ Fast Track (TL;DR)

```powershell
# 1. Navigate to directory
cd "c:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"

# 2. Install dependencies
pip install -r requirements.txt
playwright install chromium

# 3. Configure credentials
copy .env.example .env
notepad .env  # Add your CRM username and password

# 4. Test database connection
python check_restaurant.py

# 5. Run scraper
python main_poc.py
```

**That's it!** ✅

---

## 📋 Prerequisites Checklist

- [x] Python 3.9+ installed
- [x] PostgreSQL client (psql) installed
- [x] Internet connection
- [ ] CRM credentials (you provide)
- [x] Supabase access (already configured)

---

## 🎯 What Happens When You Run POC

```
[Step 1] Connect to database ✓
[Step 2] Find restaurant "Aahar The Taste of India" ✓
[Step 3] Launch browser ✓
[Step 4] Login to CRM ✓
[Step 5] Navigate to menu page ✓
[Step 6] Scrape courses and dishes ✓
[Step 7] Load into menuca_v3 schema ✓
[Step 8] Display summary ✓
```

**Expected time:** ~10 seconds
**Expected result:** 5 courses, ~45 dishes loaded

---

## 🔑 Required Credentials

Edit `.env` file:

```env
CRM_USERNAME=your_email@example.com
CRM_PASSWORD=your_password
```

**⚠️ IMPORTANT:** Never commit `.env` to Git!

---

## ✅ Verify Installation

### Check Python:
```powershell
python --version
# Should show: Python 3.9 or higher
```

### Check Dependencies:
```powershell
pip list | findstr "playwright beautifulsoup4 psycopg2"
# Should show all three packages
```

### Check Database Connection:
```powershell
python check_restaurant.py
# Should show: ✅ Found 1 restaurant(s)
```

---

## 🚀 Run POC

```powershell
python main_poc.py
```

### Success Looks Like:

```
===========================================================
Menu Scraper - Proof of Concept
===========================================================
Step 1: Connecting to database...
Found restaurant: Aahar The Taste of India (ID: 561)

Step 2: Scraping menu from CRM...
Found 5 courses with 45 dishes

Step 3: Loading data into database...
Processing course: Starters
  ✓ Course created (ID: 1234)
    ✓ Dish: Samosa (2 pcs)
    ✓ Dish: Onion Bhaji (8-10 pcs)
    ...

✅ Proof of concept completed successfully!
```

---

## 🐛 Quick Troubleshooting

### "Module not found"
```powershell
pip install -r requirements.txt
```

### "Restaurant not found"
The restaurant exists (ID: 561). If you see this error, check database connection.

### "Login failed"
1. Check credentials in `.env`
2. Try logging in manually at https://menuadmin.menu.ca
3. Verify username/password are correct

### "Browser not found"
```powershell
playwright install chromium
```

---

## 📊 Verify Results

### Check Database:

```powershell
# Using psql
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 561;"

# Should show: 5 courses

"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = 561;"

# Should show: ~45 dishes
```

### Using Python:

```powershell
python check_restaurant.py
# Shows current course and dish counts
```

---

## 📁 File Overview

| File | What It Does | When to Use |
|------|--------------|-------------|
| `check_restaurant.py` | Validates database | Before running scraper |
| `main_poc.py` | Runs scraper for 1 restaurant | Testing |
| `config.py` | Settings | Edit if needed |
| `scraper.py` | Web scraping engine | Don't need to touch |
| `database.py` | Database operations | Don't need to touch |

---

## 🎓 Next Steps After POC

1. **If POC works:** Provide restaurant ID mapping → Scale to all 189
2. **If pricing needed:** Provide dish detail HTML → Extract prices
3. **If errors occur:** Check `scraper.log` → Debug

---

## 📞 Need Help?

1. Check `SETUP_GUIDE.md` - Detailed instructions
2. Check `README.md` - Complete documentation
3. Check `scraper.log` - Error details
4. Check `PROJECT_SUMMARY.md` - Technical overview

---

## 💡 Pro Tips

1. **Run check first:** `python check_restaurant.py`
2. **Watch the logs:** `scraper.log` has detailed info
3. **Start small:** POC tests 1 restaurant before scaling
4. **Database safety:** Uses upserts (won't duplicate data)

---

## ⏱️ Time Estimates

| Task | Time |
|------|------|
| Install dependencies | 2-3 minutes |
| Configure credentials | 1 minute |
| Run POC | 10 seconds |
| Verify results | 30 seconds |
| **Total** | **< 5 minutes** |

---

## 🎯 Success Criteria

POC is successful if:
- ✅ Script runs without errors
- ✅ Courses appear in database
- ✅ Dishes appear in database
- ✅ Display order is correct
- ✅ Descriptions are intact

---

**Ready?** Let's go! 🚀

```powershell
python main_poc.py
```
