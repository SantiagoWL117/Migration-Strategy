/**
 * Test clicking through Poutine modal properly:
 * 1. Click Poutine dish
 * 2. Modal opens showing size options
 * 3. Click first size option (the <a> link)
 * 4. Click Continue button
 * 5. Close modal
 */

import { chromium } from '@playwright/test';

async function main() {
  console.log('\n🔍 Testing Poutine modal workflow\n');

  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 1024 });

  try {
    // Navigate
    console.log('1. Navigate to menu');
    await page.goto('https://cosenzapizzancalzones.ca/index.php/menu');
    await page.waitForTimeout(2000);

    // Handle address gate
    console.log('2. Handle address gate');
    const addressInput = page.locator('input[placeholder*="address" i]').first();
    if (await addressInput.isVisible().catch(() => false)) {
      await addressInput.fill('Kanata Ave.');
      await page.waitForTimeout(2000);

      const suggestion = page.locator('.pac-item').first();
      await suggestion.click();
      await page.waitForTimeout(1500);

      const pickupBtn = page.locator('button:has-text("Pick up")').first();
      await pickupBtn.click({ force: true });
      await page.waitForTimeout(2000);
    }

    // Force dismiss restaurant closed modal
    console.log('3. Force dismiss restaurant closed modal');
    await page.evaluate(() => {
      const modal = document.querySelector('#restoScheduleModal');
      if (modal) {
        (modal as HTMLElement).style.display = 'none';
        modal.remove();
      }
      const backdrop = document.querySelector('.modal-backdrop');
      if (backdrop) {
        backdrop.remove();
      }
      document.body.classList.remove('modal-open');
      document.body.style.removeProperty('padding-right');
    });
    await page.waitForTimeout(1000);

    // Click Poutine (index 2)
    console.log('4. Click Poutine dish');
    const poutine = page.locator('li.dish').nth(2);
    await poutine.click();
    await page.waitForTimeout(2000);

    console.log('5. Modal should be open now');

    // Extract ALL radio buttons
    const options = await page.evaluate(() => {
      const radios = Array.from(document.querySelectorAll('input[type="radio"]'));
      return radios.map((radio, idx) => {
        const label = (radio as HTMLInputElement).labels?.[0]?.textContent?.trim() ||
                     radio.closest('label')?.textContent?.trim() ||
                     `Option ${idx}`;
        return {
          label,
          visible: (radio as HTMLElement).offsetParent !== null,
          id: (radio as HTMLInputElement).id,
          name: (radio as HTMLInputElement).name
        };
      });
    });

    console.log('\nFound radio options:');
    options.forEach((opt, idx) => {
      console.log(`  ${idx}. "${opt.label}" (id: ${opt.id}, visible: ${opt.visible})`);
    });

    if (options.length === 0) {
      console.log('\n❌ No radio buttons found!');
      await page.waitForTimeout(30000);
      return;
    }

    // Click the first radio button
    console.log(`\n6. Clicking first radio button`);
    const firstRadio = page.locator('input[type="radio"]').first();
    await firstRadio.click({ force: true });
    await page.waitForTimeout(1000);
    console.log('✓ Clicked radio button');

    // Check for Continue button - use correct selector!
    console.log('\n7. Looking for Continue button...');
    const continueBtn = page.locator('a#toc, a.toc, li.toc a').first();
    const btnVisible = await continueBtn.isVisible().catch(() => false);

    if (btnVisible) {
      console.log('✓ Continue button is visible');
      const btnText = await continueBtn.textContent();
      console.log(`Button text: "${btnText}"`);

      console.log('8. Clicking Continue button...');
      await continueBtn.click();
      await page.waitForTimeout(1500);
      console.log('✓ Clicked Continue');
    } else {
      console.log('❌ Continue button NOT visible');

      // Debug: find all buttons and inputs
      const allElements = await page.evaluate(() => {
        const modal = document.querySelector('#customize_dish');
        if (!modal) return { buttons: [], inputs: [], innerHtml: '' };

        const buttons = Array.from(modal.querySelectorAll('button, input[type="submit"], input[type="button"], a')).map(btn => ({
          tag: btn.tagName,
          text: btn.textContent?.trim() || '',
          type: btn.getAttribute('type'),
          value: btn.getAttribute('value'),
          class: btn.getAttribute('class'),
          visible: (btn as HTMLElement).offsetParent !== null
        }));

        const inputs = Array.from(modal.querySelectorAll('input[type="submit"], input[type="button"]')).map(inp => ({
          value: (inp as HTMLInputElement).value,
          type: inp.getAttribute('type'),
          class: inp.getAttribute('class'),
          visible: (inp as HTMLElement).offsetParent !== null
        }));

        return { buttons, inputs, innerHtml: modal.innerHTML.substring(0, 5000) };
      });

      console.log('\nAll clickable elements in modal:');
      allElements.buttons.forEach(btn => {
        if (btn.visible) {
          console.log(`  - <${btn.tag}> "${btn.text}" (type: ${btn.type}, value: ${btn.value}, class: ${btn.class})`);
        }
      });

      if (allElements.inputs.length > 0) {
        console.log('\nInput buttons:');
        allElements.inputs.forEach(inp => {
          if (inp.visible) {
            console.log(`  - value="${inp.value}" (type: ${inp.type}, class: ${inp.class})`);
          }
        });
      }
    }

    console.log('\n9. Closing modal with Escape');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(1000);

    console.log('\n✅ Test complete! Pausing for 10 seconds...\n');
    await page.waitForTimeout(10000);

  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
