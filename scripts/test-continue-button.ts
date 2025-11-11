/**
 * Debug script to find the Continue button on Poutine modal
 */

import { chromium } from '@playwright/test';

async function main() {
  console.log('\n🔍 Testing Continue button selectors\n');

  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 1024 });

  try {
    // Navigate to menu
    await page.goto('https://cosenzapizzancalzones.ca/index.php/menu');
    await page.waitForTimeout(2000);

    // Handle address gate
    const addressInput = page.locator('input[placeholder*="address" i]').first();
    if (await addressInput.isVisible().catch(() => false)) {
      console.log('Entering address...');
      await addressInput.fill('Kanata Ave.');
      await page.waitForTimeout(2000);

      const suggestion = page.locator('.pac-item').first();
      await suggestion.click();
      await page.waitForTimeout(1500);

      const pickupBtn = page.locator('button:has-text("Pick up")').first();
      await pickupBtn.click();
      await page.waitForTimeout(2000);
    }

    // Click on Poutine (index 2)
    console.log('\nClicking Poutine...');
    const poutine = page.locator('li.dish').nth(2);
    await poutine.scrollIntoViewIfNeeded();
    await poutine.click();
    await page.waitForTimeout(2000);

    console.log('\nModal opened, selecting first option...');

    // Click first radio button
    const firstRadio = page.locator('input[type="radio"]:visible').first();
    await firstRadio.click();
    await page.waitForTimeout(1000);

    console.log('\nNow testing different Continue button selectors...\n');

    const buttonSelectors = [
      'button:has-text("Continue")',
      'button:has-text("continue")',
      'a:has-text("Continue")',
      'button:has-text("add to cart")',
      'button:has-text("Add to cart")',
      'input[type="submit"][value*="cart"]',
      'button[type="submit"]',
      'input[type="submit"]',
      'button',
      'a[href="#"]',
      '.btn',
      '[onclick*="continue"]',
      '[onclick*="addToCart"]'
    ];

    for (const selector of buttonSelectors) {
      const btn = page.locator(selector);
      const count = await btn.count();
      const visible = count > 0 && await btn.first().isVisible().catch(() => false);

      if (visible) {
        const text = await btn.first().textContent();
        console.log(`✓ "${selector}" - Found ${count}, visible, text: "${text?.trim()}"`);
      } else if (count > 0) {
        console.log(`⚠ "${selector}" - Found ${count} but not visible`);
      } else {
        console.log(`✗ "${selector}" - Not found`);
      }
    }

    console.log('\n\n📋 Getting all buttons in modal:\n');
    const allButtons = await page.evaluate(() => {
      const modal = document.querySelector('#customize_dish');
      if (!modal) return [];

      const buttons = Array.from(modal.querySelectorAll('button, a, input[type="submit"]'));
      return buttons.map(btn => ({
        tag: btn.tagName,
        text: btn.textContent?.trim(),
        type: btn.getAttribute('type'),
        class: btn.getAttribute('class'),
        onclick: btn.getAttribute('onclick'),
        visible: (btn as HTMLElement).offsetParent !== null
      }));
    });

    console.log(JSON.stringify(allButtons, null, 2));

    console.log('\n\n⏸️  Pausing for 30 seconds to inspect...\n');
    await page.waitForTimeout(30000);

  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
