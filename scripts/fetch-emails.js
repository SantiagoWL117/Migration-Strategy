const { chromium } = require('playwright');

// Restaurant IDs we need emails for (from V3 database query)
const restaurantIds = [
  195, 322, 336, 196, 783, 784, 785, 362, 1009, 841, 833, 511, 211, 815, 7, 
  1021, 825, 1010, 174, 749, 835, 840, 821, 205, 846, 801, 790, 15, 807, 797, 
  822, 810, 795, 829, 716, 789, 745, 836, 820, 985
];

// Admin panel credentials
const ADMIN_URL = 'https://menuadmin.menu.ca';
const EMAIL = 'santiago@worklocal.ca';
const PASSWORD = '542sfgsgeerg4%$';

async function fetchEmails() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  const results = [];
  
  try {
    // Login
    console.log('Logging in to admin panel...');
    await page.goto(`${ADMIN_URL}/?p=restaurants`);
    await page.getByRole('textbox', { name: 'Username' }).fill(EMAIL);
    await page.getByRole('textbox', { name: 'Password' }).fill(PASSWORD);
    await page.getByRole('button', { name: 'Login' }).click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000); // Wait for redirect
    console.log('Logged in successfully!\n');
    
    // Process each restaurant
    for (const id of restaurantIds) {
      try {
        console.log(`Fetching restaurant ID: ${id}...`);
        await page.goto(`${ADMIN_URL}/?p=restaurants&display=editRestaurant&restaurant=${id}`);
        await page.waitForLoadState('networkidle');
        
        // Try to get the email field - look for label or various selectors
        let email = null;
        try {
          // Try multiple selectors
          const emailSelectors = [
            'input[name="email"]',
            'input[type="email"]',
            '#email',
            'input[placeholder*="email" i]'
          ];
          for (const sel of emailSelectors) {
            const el = await page.$(sel);
            if (el) {
              email = await el.inputValue();
              if (email) break;
            }
          }
          // Also try by label
          if (!email) {
            const emailByLabel = page.getByLabel(/email/i);
            if (await emailByLabel.count() > 0) {
              email = await emailByLabel.first().inputValue();
            }
          }
        } catch (e) {
          console.log(`    Warning getting email: ${e.message}`);
        }
        
        // Get restaurant name for reference
        let name = `Unknown (ID: ${id})`;
        try {
          const nameSelectors = ['input[name="name"]', '#name', 'input[name="restaurant_name"]'];
          for (const sel of nameSelectors) {
            const el = await page.$(sel);
            if (el) {
              const val = await el.inputValue();
              if (val) { name = val; break; }
            }
          }
        } catch (e) {
          // ignore
        }
        
        results.push({
          admin_id: id,
          name: name,
          email: email || 'NOT FOUND'
        });
        
        console.log(`  ${name}: ${email || 'NOT FOUND'}`);
        
        // Small delay to be nice to the server
        await page.waitForTimeout(500);
        
      } catch (err) {
        console.log(`  Error fetching ID ${id}: ${err.message}`);
        results.push({
          admin_id: id,
          name: `Error (ID: ${id})`,
          email: 'ERROR'
        });
      }
    }
    
  } finally {
    await browser.close();
  }
  
  // Output results as JSON
  console.log('\n\n=== RESULTS JSON ===');
  console.log(JSON.stringify(results, null, 2));
  
  // Output as CSV for easy viewing
  console.log('\n=== RESULTS CSV ===');
  console.log('admin_id,name,email');
  for (const r of results) {
    console.log(`${r.admin_id},"${r.name}",${r.email}`);
  }
  
  return results;
}

fetchEmails().catch(console.error);

