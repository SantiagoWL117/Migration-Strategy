/**
 * Debug test for dishes 74-76 (Hamburger, Cheeseburger, Bacon Cheeseburger)
 * to see why they're failing to click
 */

import { chromium } from '@playwright/test';

async function testFailedDishes() {
  console.log('\n🔍 Testing dishes 74-76 with visible browser\n');

  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 1024 });

  try {
    // Navigate to menu
    await page.goto('https://cosenzapizzancalzones.ca/index.php/menu');
    await page.waitForTimeout(2000);

    // Handle location gate
    const addressInput = page.locator('input[placeholder*="address" i]').first();
    if (await addressInput.isVisible().catch(() => false)) {
      console.log('Handling location gate...');
      await addressInput.fill('Kanata Ave.');
      await page.waitForTimeout(2000);

      // Click suggestion
      const suggestion = page.locator('.pac-item').first();
      await suggestion.click();
      await page.waitForTimeout(1500);

      // Click pickup
      const pickupBtn = page.locator('button:has-text("Pick up")').first();
      await pickupBtn.click();
      await page.waitForTimeout(2000);
    }

    // Count all li.dish items
    const allDishes = await page.locator('li.dish').all();
    console.log(`\nTotal li.dish items found: ${allDishes.length}`);

    // Test clicking dishes 73, 74, 75, 76 (0-indexed: 72, 73, 74, 75)
    const testIndices = [72, 73, 74, 75];

    for (const index of testIndices) {
      console.log(`\n--- Testing dish at index ${index} (dish #${index + 1}) ---`);

      try {
        // Refresh dish list
        const dishes = await page.locator('li.dish').all();
        console.log(`Dish count: ${dishes.length}`);

        if (index >= dishes.length) {
          console.log(`❌ Index ${index} is out of range (only ${dishes.length} dishes)`);
          continue;
        }

        const dish = dishes[index];

        // Get dish name
        const dishName = await dish.locator('p.name').textContent().catch(() => 'Unknown');
        console.log(`Dish name: ${dishName}`);

        // Check if visible
        const isVisible = await dish.isVisible();
        console.log(`Is visible: ${isVisible}`);

        // Scroll into view
        await dish.scrollIntoViewIfNeeded();
        await page.waitForTimeout(500);

        // Try clicking
        console.log('Attempting to click...');
        await dish.click({ timeout: 5000 });
        console.log('✅ Clicked successfully!');

        await page.waitForTimeout(2000);

        // Check if modal opened
        const modalVisible = await page.locator('[role="dialog"], .modal, [class*="modal"]').first().isVisible().catch(() => false);
        console.log(`Modal opened: ${modalVisible}`);

        // Close modal
        await page.keyboard.press('Escape');
        await page.waitForTimeout(1000);

      } catch (error: any) {
        console.log(`❌ Error: ${error.message}`);
      }
    }

    console.log('\n\n⏸️  Pausing for 10 seconds to inspect...\n');
    await page.waitForTimeout(10000);

  } finally {
    await browser.close();
  }
}

testFailedDishes().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
