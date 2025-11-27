/**
 * V2 Scraper - Single-page form sites with add-to-cart
 *
 * Strategy:
 * 1. Handle address/location gate (enter address + select pickup/delivery)
 * 2. Extract ALL dish names, descriptions, prices from single-page menu
 * 3. For each dish, click to open customization form
 * 4. Extract modifier groups (radio buttons, checkboxes) from the form
 * 5. Close form and move to next dish
 *
 * Key differences from V1:
 * - No multi-step modal wizard (single form with all options)
 * - Uses radio/checkbox inputs instead of clickable links
 * - May have "Add to Cart" instead of "Next" buttons
 */

import { chromium, Page, Browser } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import {
  ScrapedDish,
  ModifierGroup,
  ScraperConfig,
  ScraperResult,
  V2GroupData,
} from '../types';

export class V2Scraper {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private config: ScraperConfig;
  private screenshotCounter = 0;

  constructor(config: ScraperConfig) {
    this.config = {
      headless: true,
      timeout: 30000,
      screenshotsDir: './screenshots/v2',
      outputDir: './scraped-data/v2',
      ...config,
      version: 'v2'
    };
  }

  async initialize(): Promise<void> {
    if (this.config.screenshotsDir) {
      fs.mkdirSync(this.config.screenshotsDir, { recursive: true });
    }
    if (this.config.outputDir) {
      fs.mkdirSync(this.config.outputDir, { recursive: true });
    }

    this.browser = await chromium.launch({
      headless: this.config.headless
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 1024 });
  }

  async scrapeMenu(): Promise<ScraperResult> {
    if (!this.page) throw new Error('Scraper not initialized');

    const result: ScraperResult = {
      success: true,
      dishes: [],
      errors: [],
      summary: {
        totalDishes: 0,
        successCount: 0,
        errorCount: 0,
        totalGroups: 0,
        totalOptions: 0
      }
    };

    try {
      console.log(`[V2] Navigating to ${this.config.baseUrl}`);
      await this.page.goto(this.config.baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: this.config.timeout
      });

      await this.page.waitForTimeout(2000);
      await this.takeScreenshot('01-initial-load');

      // Step 1: Handle location/address gate
      await this.handleLocationGate();
      await this.takeScreenshot('02-after-location-gate');

      // Wait for menu to load - look for article elements or menu items
      console.log('[V2] Waiting for menu items to load...');
      try {
        await this.page.waitForSelector('article, [class*="menu-item"], h3', { timeout: 10000 });
      } catch (e) {
        console.warn('[V2] Warning: Timeout waiting for menu items, proceeding anyway');
      }
      await this.page.waitForTimeout(2000);

      // Take screenshot before extraction to debug
      await this.takeScreenshot('03-before-extraction');

      // Step 2: Extract all dishes from the menu page
      console.log('[V2] Extracting dish manifest from menu page...');
      console.log('[V2] Current URL:', this.page.url());

      // Debug removed for cleaner output

      const dishManifest = await this.extractDishManifest();
      console.log(`[V2] Found ${dishManifest.length} dishes on page`);

      result.summary.totalDishes = dishManifest.length;

      // Show sample
      console.log('\n[V2] Sample dishes:');
      dishManifest.slice(0, 10).forEach((dish, idx) => {
        console.log(`  ${idx + 1}. ${dish.name} ($${dish.price || '?'})`);
      });
      if (dishManifest.length > 10) {
        console.log(`  ... and ${dishManifest.length - 10} more\n`);
      }

      await this.takeScreenshot('04-menu-loaded');

      // Step 3: For each dish, extract modifiers
      for (let i = 0; i < dishManifest.length; i++) {
        try {
          console.log(`[V2] [${i + 1}/${dishManifest.length}] ${dishManifest[i].name}`);

          const groups = await this.extractModifiersForDish(i, dishManifest[i].name);

          result.dishes.push({
            restaurant: this.config.restaurantName,
            restaurantUrl: this.config.baseUrl,
            dish: {
              name: dishManifest[i].name,
              description: dishManifest[i].description || undefined,
              basePrice: dishManifest[i].price,
              category: dishManifest[i].category || undefined
            },
            groups,
            metadata: {
              scrapedAt: new Date().toISOString(),
              version: 'v2',
              dishUrl: this.page.url()
            }
          });

          result.summary.successCount++;
          result.summary.totalGroups += groups.length;
          result.summary.totalOptions += groups.reduce((sum, g) => sum + g.options.length, 0);

          console.log(`[V2]   ✓ ${groups.length} groups, ${groups.reduce((sum, g) => sum + g.options.length, 0)} options`);

        } catch (error: any) {
          console.error(`[V2]   ✗ Error: ${error.message}`);
          result.errors.push({
            dishName: dishManifest[i]?.name || `Dish ${i + 1}`,
            error: error.message,
            timestamp: new Date().toISOString()
          });
          result.summary.errorCount++;

          // Try to close any open modals
          await this.page.keyboard.press('Escape').catch(() => {});
          await this.page.waitForTimeout(500);
        }
      }

      console.log(`\n[V2] Complete: ${result.summary.successCount}/${result.summary.totalDishes} dishes`);

    } catch (error: any) {
      console.error('[V2] Fatal error:', error);
      result.success = false;
      result.errors.push({
        error: `Fatal: ${error.message}`,
        timestamp: new Date().toISOString()
      });
    }

    return result;
  }

  /**
   * Handle address/location gate that appears on first load
   */
  private async handleLocationGate(): Promise<void> {
    if (!this.page) return;

    try {
      console.log('[V2] Looking for location gate...');

      // Wait for location modal to appear
      await this.page.waitForTimeout(2000);

      // Common selectors for address input
      const addressSelectors = [
        'input[placeholder*="address" i]',
        'input[placeholder*="Address" i]',
        'input[name*="address"]',
        'input[id*="address"]',
        'input[type="text"]'
      ];

      let addressInput = null;
      for (const selector of addressSelectors) {
        addressInput = this.page.locator(selector).first();
        if (await addressInput.isVisible().catch(() => false)) {
          console.log(`[V2] Found address input: ${selector}`);
          break;
        }
      }

      if (addressInput && await addressInput.isVisible().catch(() => false)) {
        // Type the address
        await addressInput.fill('Kanata Ave.');
        console.log('[V2] Typed address, waiting for suggestions...');
        await this.page.waitForTimeout(2000);

        // Look for autocomplete suggestions (Google Places autocomplete)
        const suggestionSelectors = [
          '.pac-item',
          '[role="option"]',
          '.autocomplete-item',
          '.suggestion',
          'li[data-value]',
          '[class*="suggestion"]'
        ];

        let suggestionClicked = false;
        for (const selector of suggestionSelectors) {
          const suggestion = this.page.locator(selector).first();
          if (await suggestion.isVisible().catch(() => false)) {
            console.log(`[V2] Clicking first address suggestion: ${selector}`);
            await suggestion.click();
            await this.page.waitForTimeout(1500);
            suggestionClicked = true;
            break;
          }
        }

        if (!suggestionClicked) {
          console.warn('[V2] Warning: No address suggestion found to click');
        }

        // Look for pickup/delivery buttons
        const pickupSelectors = [
          'button:has-text("Pickup")',
          'button:has-text("Pick up")',
          'button:has-text("Takeout")',
          '[data-testid="pickup"]',
          'button[value="pickup"]'
        ];

        for (const selector of pickupSelectors) {
          const pickupBtn = this.page.locator(selector).first();
          if (await pickupBtn.isVisible().catch(() => false)) {
            console.log(`[V2] Clicking pickup button: ${selector}`);
            await pickupBtn.click();
            await this.page.waitForTimeout(2000);
            break;
          }
        }

        // Look for continue/confirm button
        const continueSelectors = [
          'button:has-text("Continue")',
          'button:has-text("Confirm")',
          'button:has-text("Submit")',
          'button[type="submit"]'
        ];

        for (const selector of continueSelectors) {
          const continueBtn = this.page.locator(selector).first();
          if (await continueBtn.isVisible().catch(() => false)) {
            console.log(`[V2] Clicking continue button: ${selector}`);
            await continueBtn.click();
            await this.page.waitForTimeout(2000);
            break;
          }
        }

        console.log('[V2] Location gate handled successfully');
      } else {
        console.log('[V2] No location gate found or already passed');
      }

    } catch (error: any) {
      console.warn(`[V2] Warning handling location gate: ${error.message}`);
      // Don't fail the whole scrape if location gate fails
    }
  }

  /**
   * Extract all dishes from the menu page DOM
   */
  private async extractDishManifest(): Promise<Array<{
    name: string;
    price: number | null;
    description: string | null;
    category: string | null;
  }>> {
    if (!this.page) return [];

    return await this.page.evaluate(() => {
      const dishes: Array<{
        name: string;
        price: number | null;
        description: string | null;
        category: string | null;
      }> = [];

      // Look for menu items - try li.dish first (Cosenza Pizza structure)
      let menuItems: Element[] = Array.from(document.querySelectorAll('li.dish'));

      // If no li.dish, try other patterns
      if (menuItems.length === 0) {
        menuItems = Array.from(document.querySelectorAll('article'));
      }

      if (menuItems.length === 0) {
        const menuItemSelectors = [
          '[data-testid*="menu-item"]',
          '[class*="menu-item"]',
          '[class*="MenuItem"]',
          '[class*="product-card"]',
          '.item',
        ];

        for (const selector of menuItemSelectors) {
          const items: Element[] = Array.from(document.querySelectorAll(selector));
          if (items.length > 5) {
            menuItems = items;
            break;
          }
        }
      }

      // Track unique dish names to avoid duplicates
      const seenNames = new Set<string>();

      for (const item of menuItems) {
        const text = item.textContent || '';

        // Extract name - look for p.name (Cosenza structure) or h3
        let name = '';
        const nameP = item.querySelector('p.name');
        if (nameP) {
          name = nameP.textContent?.trim() || '';
        }

        // Fallback to h3
        if (!name) {
          const h3 = item.querySelector('h3');
          if (h3) {
            name = h3.textContent?.trim() || '';
          }
        }

        // Fallback to other headings
        if (!name) {
          const headings = item.querySelectorAll('h1, h2, h4, h5, h6, strong, b');
          if (headings.length > 0) {
            name = headings[0].textContent?.trim() || '';
          }
        }

        // Skip if no name or already seen
        if (!name || seenNames.has(name)) {
          continue;
        }

        // Extract price - look for span.price or match in text
        let price: number | null = null;
        const priceSpan = item.querySelector('span.price, .price');
        if (priceSpan) {
          const priceText = priceSpan.textContent?.trim() || '';
          const priceMatch = priceText.match(/(\d+(?:[.,]\d{2})?)/);
          if (priceMatch) {
            price = parseFloat(priceMatch[1].replace(',', '.'));
          }
        }

        // Fallback: search in full text
        if (price === null) {
          const priceMatch = text.match(/\$\s*(\d+(?:[.,]\d{2})?)/);
          if (priceMatch) {
            price = parseFloat(priceMatch[1].replace(',', '.'));
          }
        }

        // Extract description - look for p.description or iterate through p tags
        let description: string | null = null;
        const descP = item.querySelector('p.description');
        if (descP) {
          const descText = descP.textContent?.trim() || '';
          if (descText.length > 2 && descText !== '&nbsp;') {
            description = descText;
          }
        }

        // Fallback: iterate through p tags
        if (!description) {
          const paragraphs = Array.from(item.querySelectorAll('p'));
          for (const p of paragraphs) {
            const pText = p.textContent?.trim() || '';
            if (pText.length > 10 && pText.length < 300 && pText !== name && !pText.includes('$') && !pText.startsWith('from') && pText !== '&nbsp;') {
              description = pText;
              break;
            }
          }
        }

        // Find category - look for section headers above this item
        let category: string | null = null;
        let parent = item.parentElement;
        let depth = 0;
        while (parent && depth < 5) {
          // Look for a previous sibling or parent sibling that's a heading
          let sibling = parent.previousElementSibling;
          while (sibling) {
            if (sibling.tagName.match(/^H[1-6]$/)) {
              const catText = sibling.textContent?.trim() || '';
              if (catText.length > 0 && catText.length < 100 && !catText.includes('$')) {
                category = catText;
                break;
              }
            }
            sibling = sibling.previousElementSibling;
          }
          if (category) break;

          parent = parent.parentElement;
          depth++;
        }

        if (name.length > 0) {
          seenNames.add(name);
          dishes.push({ name, price, description, category });
        }
      }

      return dishes;
    });
  }

  /**
   * Dismiss the restaurant closed modal if it's visible
   * This modal can reappear throughout the session
   */
  private async dismissRestaurantClosedModal(): Promise<void> {
    if (!this.page) return;

    // Force remove the modal from DOM using JavaScript
    await this.page.evaluate(() => {
      const modal = document.querySelector('#restoScheduleModal');
      if (modal) {
        (modal as HTMLElement).style.display = 'none';
        modal.remove();
      }
      // Also remove modal backdrop if present
      const backdrop = document.querySelector('.modal-backdrop');
      if (backdrop) {
        backdrop.remove();
      }
      // Remove modal-open class from body
      document.body.classList.remove('modal-open');
    }).catch(() => {});

    await this.page.waitForTimeout(500);
  }

  /**
   * Click on a dish and extract its modifier groups
   */
  private async extractModifiersForDish(dishIndex: number, dishName: string): Promise<ModifierGroup[]> {
    if (!this.page) return [];

    // IMPORTANT: Check and dismiss restaurant closed modal if it's blocking
    await this.dismissRestaurantClosedModal();

    // Click the dish item to open customization form
    // Try different selector strategies to find clickable menu items
    const itemSelectors = [
      'li.dish',  // Cosenza Pizza structure
      'article',
      '[data-testid*="menu-item"]',
      '[class*="menu-item"]',
      '[class*="MenuItem"]',
      'button[class*="dish"]',
      'div[role="button"]'
    ];

    let clicked = false;
    for (const selector of itemSelectors) {
      const items = await this.page.locator(selector).all();
      console.log(`[V2-Debug] Selector '${selector}' found ${items.length} items, need index ${dishIndex}`);

      if (items.length > dishIndex) {
        try {
          // Try clicking directly (no scrollIntoViewIfNeeded to avoid endless scrolling)
          await items[dishIndex].click({ timeout: 5000 });
          clicked = true;
          console.log(`[V2-Debug] Successfully clicked using selector '${selector}'`);
          break;
        } catch (e: any) {
          console.log(`[V2-Debug] Failed to click with '${selector}': ${e.message}`);
          // Try next selector
          continue;
        }
      }
    }

    if (!clicked) {
      throw new Error('Could not find clickable dish item');
    }

    await this.page.waitForTimeout(2000);
    await this.takeScreenshot(`dish-${dishIndex}-${dishName.replace(/[^a-z0-9]/gi, '-').toLowerCase()}`);

    // Extract modifier groups using wizard approach (same as V1)
    const groups: ModifierGroup[] = [];
    let stepNumber = 1;
    let hasMoreSteps = true;

    while (hasMoreSteps && stepNumber <= 20) {
      // Wait for modal content to load - either inputs appear OR Add to Cart button appears
      try {
        await Promise.race([
          this.page.locator('input[type="radio"], input[type="checkbox"]').first().waitFor({ state: 'visible', timeout: 5000 }),
          this.page.locator('a.to_cart, li.to_cart a').first().waitFor({ state: 'visible', timeout: 5000 })
        ]);
        // Extra wait to ensure DOM is fully ready
        await this.page.waitForTimeout(500);
      } catch (error) {
        console.log(`[V2-Debug] Timeout waiting for modal content to load`);
        // Even if timeout, wait a bit more for slow-loading modals
        await this.page.waitForTimeout(1500);
      }

      // NOW check what appeared - Add to Cart button (simple item) or inputs (modal item)?
      const hasAddToCartBtn = await this.page.locator('a.to_cart, li.to_cart a').first().isVisible({ timeout: 500 }).catch(() => false);
      const hasInputs = await this.page.locator('input[type="radio"], input[type="checkbox"]').first().isVisible({ timeout: 500 }).catch(() => false);

      let stepData: any = null;

      if (hasInputs) {
        // Has modifiers - retry until we find inputs (modals ALWAYS have inputs!)
        let retryCount = 0;
        const maxRetries = 2;

        while (retryCount < maxRetries) {
          stepData = await this.page.evaluate(() => {
          // Find group title
          const titles = Array.from(document.querySelectorAll('h3, h4, strong, legend, b'));
          let groupName = 'Options';
          for (const el of titles) {
            const text = el.textContent?.trim() || '';
            if (text.length > 3 && text.length < 100 && !text.toLowerCase().includes('personnalisez')) {
              groupName = text;
              break;
            }
          }

          // Find options (radio buttons OR checkboxes with their labels)
          const radios = Array.from(document.querySelectorAll('input[type="radio"]'));
          const checkboxes = Array.from(document.querySelectorAll('input[type="checkbox"]'));
          const allInputs = [...radios, ...checkboxes];

          const options = allInputs.map((input) => {
            // Get label text
            const label = (input as HTMLInputElement).labels?.[0]?.textContent?.trim() ||
                         input.closest('label')?.textContent?.trim() ||
                         '';

            // Parse "Small - 9.75" or "Add Veggies 3.50" format
            let name = label;
            let priceDelta = 0;

            // Try to extract price from label
            const priceMatch = label.match(/(\d+\.\d+)/);
            if (priceMatch) {
              priceDelta = parseFloat(priceMatch[1]) || 0;
              // Remove price from name
              name = label.replace(/\s*\d+\.\d+\s*$/, '').trim();
            }

            return { name, priceDelta, isDefault: false };
          });

          const isRequired = document.body.textContent?.includes('il vous plaît') || document.body.textContent?.includes('please') || false;
          const hasRadios = radios.length > 0;
          const hasCheckboxes = checkboxes.length > 0;

          return { groupName, options, isRequired, hasRadios, hasCheckboxes };
        });

        // If we found inputs, break out of retry loop
        if (stepData && stepData.options.length > 0) {
          break;
        }

          // Didn't find inputs - BULLSHIT! Wait 2 more seconds and check again
          retryCount++;
          console.log(`[V2-Debug] No inputs found (attempt ${retryCount}/${maxRetries}), waiting 2 more seconds...`);
          await this.page.waitForTimeout(2000);
        }
      } else if (hasAddToCartBtn) {
        // Simple item (Add to Cart button appeared immediately) - no retries needed
        console.log(`[V2-Debug] Simple item detected (Add to Cart button visible), no modifiers`);
        stepData = { groupName: '', options: [], isRequired: false, hasRadios: false, hasCheckboxes: false };
      } else {
        // Neither inputs nor Add to Cart button found - this shouldn't happen, but handle it
        console.log(`[V2-Debug] Neither inputs nor Add to Cart button found, assuming simple item`);
        stepData = { groupName: '', options: [], isRequired: false, hasRadios: false, hasCheckboxes: false };
      }

      if (!stepData || stepData.options.length === 0) {
        // No radio buttons found - check if there's an Add to Cart button to click
        console.log(`[V2-Debug] No radio buttons found on step ${stepNumber}`);

        const addToCartBtn = this.page.locator('a.to_cart, li.to_cart a, section.to_cart a, .to_cart a').first();
        const addToCartVisible = await addToCartBtn.isVisible({ timeout: 1000 }).catch(() => false);

        if (addToCartVisible) {
          console.log(`[V2-Debug] Found Add to Cart button, clicking it to close modal`);
          try {
            await addToCartBtn.click({ timeout: 3000 });
            console.log(`[V2-Debug] ✓ Clicked Add to Cart`);
          } catch (error) {
            console.log(`[V2-Debug] Failed to click Add to Cart, trying JavaScript`);
            await this.page.evaluate(() => {
              const btn = document.querySelector('a.to_cart, li.to_cart a, section.to_cart a, .to_cart a') as HTMLAnchorElement;
              if (btn) btn.click();
            });
          }
          await this.page.waitForTimeout(1000);
        }

        break;
      }

      groups.push({
        name: stepData.groupName,
        selectType: stepData.hasCheckboxes ? 'multi' : 'single',
        minSelections: stepData.isRequired ? 1 : 0,
        maxSelections: stepData.hasCheckboxes ? stepData.options.length : 1,
        isRequired: stepData.isRequired,
        displayOrder: stepNumber - 1,
        stepOrder: stepNumber,
        options: stepData.options
      });

      // Click first input (radio OR checkbox - they work the same way)
      if (stepData.options.length > 0) {
        try {
          if (stepData.hasRadios) {
            console.log(`[V2-Debug] Clicking first radio button`);
            const firstInput = await this.page.locator('input[type="radio"]').first();
            // Wait for the input to be visible
            await firstInput.waitFor({ state: 'visible', timeout: 3000 });
            await firstInput.click({ force: true });
            console.log(`[V2-Debug] ✓ Clicked first radio button`);
          } else if (stepData.hasCheckboxes) {
            console.log(`[V2-Debug] Clicking first checkbox`);
            const firstInput = await this.page.locator('input[type="checkbox"]').first();
            // Wait for the input to be visible
            await firstInput.waitFor({ state: 'visible', timeout: 3000 });
            await firstInput.click({ force: true });
            console.log(`[V2-Debug] ✓ Clicked first checkbox`);
          }

          // Wait for the button to become active after selection
          await this.page.waitForTimeout(1500);
        } catch (error: any) {
          console.log(`[V2-Debug] ✗ Failed to click input: ${error.message}`);
          // Force close modal on error
          await this.page.evaluate(() => {
            const modal = document.querySelector('#customize_dish');
            if (modal) {
              (modal as HTMLElement).style.display = 'none';
              modal.classList.remove('in', 'show');
            }
            const backdrop = document.querySelector('.modal-backdrop');
            if (backdrop) backdrop.remove();
            document.body.classList.remove('modal-open');
            document.body.style.removeProperty('padding-right');
          });
          throw error; // Re-throw to trigger dish error handling
        }
      }

      // Check for Continue link OR "Add to cart" button (final step)
      console.log(`[V2-Debug] Looking for Continue or Add to cart button...`);

      // More flexible selector - try multiple approaches
      const continueBtnSelectors = [
        'a.toc',           // Most common
        'li.toc a',        // Inside list item
        'a#toc',           // With ID
        '.toc a',          // Inside toc class
        'a[href*="toc"]',  // Link with toc in href
      ];

      let continueBtn = null;
      let continueVisible = false;

      // Try each selector until we find a visible button
      for (const selector of continueBtnSelectors) {
        const btn = this.page.locator(selector).first();
        const visible = await btn.isVisible({ timeout: 1000 }).catch(() => false);
        if (visible) {
          continueBtn = btn;
          continueVisible = true;
          console.log(`[V2-Debug] ✓ Found Continue button with selector: ${selector}`);
          break;
        }
      }

      // Check for Add to Cart button with multiple selectors
      const addToCartSelectors = [
        'a.to_cart',
        'li.to_cart a',
        'section.to_cart a',
        '.to_cart a',
        'a[href*="to_cart"]',
      ];

      let addToCartBtn = null;
      let addToCartVisible = false;

      for (const selector of addToCartSelectors) {
        const btn = this.page.locator(selector).first();
        const visible = await btn.isVisible({ timeout: 1000 }).catch(() => false);
        if (visible) {
          addToCartBtn = btn;
          addToCartVisible = true;
          console.log(`[V2-Debug] ✓ Found Add to Cart button with selector: ${selector}`);
          break;
        }
      }

      console.log(`[V2-Debug] Continue visible: ${continueVisible}, Add to cart visible: ${addToCartVisible}`);

      // Always click whatever red button we found (Continue or Add to Cart)
      if (continueVisible && continueBtn) {
        console.log(`[V2-Debug] Clicking "Continue" button...`);

        try {
          await continueBtn.click({ timeout: 3000 });
          console.log(`[V2-Debug] ✓ Clicked Continue with Playwright`);
        } catch (error) {
          console.log(`[V2-Debug] Playwright click failed, trying JavaScript click...`);
          await this.page.evaluate(() => {
            const selectors = ['a.toc', 'li.toc a', 'a#toc', '.toc a'];
            for (const sel of selectors) {
              const btn = document.querySelector(sel) as HTMLAnchorElement;
              if (btn && btn.offsetParent !== null) {
                btn.click();
                return;
              }
            }
          });
          console.log(`[V2-Debug] ✓ Clicked Continue with JavaScript`);
        }

        await this.page.waitForTimeout(1500);
        stepNumber++;
      } else if (addToCartVisible && addToCartBtn) {
        console.log(`[V2-Debug] Clicking "Add to Cart" button...`);

        try {
          await addToCartBtn.click({ timeout: 3000 });
          console.log(`[V2-Debug] ✓ Clicked Add to Cart with Playwright`);
        } catch (error) {
          console.log(`[V2-Debug] Playwright click failed, trying JavaScript click...`);
          await this.page.evaluate(() => {
            const selectors = ['a.to_cart', 'li.to_cart a', 'section.to_cart a', '.to_cart a'];
            for (const sel of selectors) {
              const btn = document.querySelector(sel) as HTMLAnchorElement;
              if (btn && btn.offsetParent !== null) {
                btn.click();
                return;
              }
            }
          });
          console.log(`[V2-Debug] ✓ Clicked Add to Cart with JavaScript`);
        }

        await this.page.waitForTimeout(1500);
        stepNumber++;
      } else {
        console.log(`[V2-Debug] No Continue or Add to cart button found, ending wizard`);
        hasMoreSteps = false;
      }

      // Check if modal closed after clicking the button
      const modalStillOpen = await this.page.locator('#customize_dish.modal.in, .modal.show, .modal[style*="display: block"]').isVisible().catch(() => false);
      if (!modalStillOpen) {
        console.log(`[V2-Debug] ✓ Modal closed, wizard complete`);
        hasMoreSteps = false;
      }
    }

    // Force close modal if still open
    const modalStillOpen2 = await this.page.locator('#customize_dish.modal.in, .modal.show').isVisible().catch(() => false);
    if (modalStillOpen2) {
      console.log(`[V2-Debug] Modal still open after wizard, force closing...`);

      // Try clicking X button
      const closeBtn = this.page.locator('.modal .close, button.close, .modal-header .close').first();
      const closeBtnVisible = await closeBtn.isVisible().catch(() => false);
      if (closeBtnVisible) {
        await closeBtn.click();
        console.log(`[V2-Debug] ✓ Clicked X button to close modal`);
      } else {
        // Click outside modal (backdrop)
        await this.page.evaluate(() => {
          const backdrop = document.querySelector('.modal-backdrop');
          if (backdrop) (backdrop as HTMLElement).click();
        });
        console.log(`[V2-Debug] ✓ Clicked backdrop to close modal`);
      }

      await this.page.waitForTimeout(1000);
    }

    return groups;
  }

  /**
   * Extract modifier groups from an open customization form
   */
  private async extractModifierGroupsFromForm(): Promise<ModifierGroup[]> {
    if (!this.page) return [];

    const groupsData = await this.page.evaluate(() => {
      const groups: Array<{
        name: string;
        selectType: 'single' | 'multi';
        isRequired: boolean;
        options: Array<{ name: string; priceDelta: number; isDefault: boolean }>;
      }> = [];

      // Find all fieldsets or sections that contain modifier groups
      const groupContainers: Element[] = Array.from(document.querySelectorAll('fieldset, [role="group"], [class*="group"], section'));

      for (const container of groupContainers) {
        // Find group name
        let groupName = 'Options';
        const legend = container.querySelector('legend, h3, h4, label[class*="title"], [class*="group-title"]');
        if (legend) {
          groupName = legend.textContent?.trim() || 'Options';
        }

        // Skip if group name is too generic or empty
        if (!groupName || groupName.length < 2) continue;

        // Check for radio buttons (single selection)
        const radioInputs: Element[] = Array.from(container.querySelectorAll('input[type="radio"]'));
        // Check for checkboxes (multi selection)
        const checkboxInputs: Element[] = Array.from(container.querySelectorAll('input[type="checkbox"]'));

        const inputs = radioInputs.length > 0 ? radioInputs : checkboxInputs;
        const selectType = radioInputs.length > 0 ? 'single' : 'multi';

        if (inputs.length === 0) continue;

        // Check if required
        const isRequired = container.textContent?.toLowerCase().includes('required') ||
                          container.textContent?.toLowerCase().includes('choose') ||
                          container.querySelector('[required]') !== null ||
                          false;

        // Extract options
        const options: Array<{ name: string; priceDelta: number; isDefault: boolean }> = [];

        for (const input of inputs) {
          const htmlInput = input as HTMLInputElement;

          // Find associated label
          let label = container.querySelector(`label[for="${htmlInput.id}"]`);
          if (!label) {
            // Try finding parent label
            label = htmlInput.closest('label');
          }

          let optionName = 'Option';
          let priceDelta = 0;
          let isDefault = htmlInput.checked;

          if (label) {
            const labelText = label.textContent?.trim() || '';

            // Parse name and price
            // Common formats: "Option Name - $1.50", "Option Name (+$1.50)", "Option Name $1.50"
            const priceMatch = labelText.match(/[+]?\$\s*(\d+(?:[.,]\d{2})?)/);
            if (priceMatch) {
              priceDelta = parseFloat(priceMatch[1].replace(',', '.'));
              // Remove price from name
              optionName = labelText.replace(/[+]?\$\s*\d+(?:[.,]\d{2})?/, '').replace(/[-()]/g, '').trim();
            } else {
              optionName = labelText;
            }

            // Clean up option name
            optionName = optionName.replace(/\s+/g, ' ').trim();
          }

          if (optionName && optionName.length > 0) {
            options.push({ name: optionName, priceDelta, isDefault });
          }
        }

        if (options.length > 0) {
          groups.push({
            name: groupName,
            selectType,
            isRequired,
            options
          });
        }
      }

      return groups;
    });

    // Convert to ModifierGroup format
    const modifierGroups: ModifierGroup[] = groupsData.map((group, index) => {
      return {
        name: group.name,
        selectType: group.selectType,
        minSelections: group.isRequired ? 1 : 0,
        maxSelections: group.selectType === 'single' ? 1 : null,
        isRequired: group.isRequired,
        displayOrder: index,
        stepOrder: null, // V2 doesn't use steps
        options: group.options
      };
    });

    return modifierGroups;
  }

  private async takeScreenshot(name: string): Promise<void> {
    if (!this.page || !this.config.screenshotsDir) return;

    const filename = `${this.screenshotCounter++}-${name}.png`;
    const filepath = path.join(this.config.screenshotsDir, filename);

    await this.page.screenshot({ path: filepath, fullPage: false });
  }

  async saveResults(result: ScraperResult): Promise<void> {
    if (!this.config.outputDir) return;

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `${this.config.restaurantName.toLowerCase().replace(/\s+/g, '-')}-${timestamp}.json`;
    const filepath = path.join(this.config.outputDir, filename);

    fs.writeFileSync(filepath, JSON.stringify(result, null, 2), 'utf-8');
    console.log(`\n[V2] Results saved to: ${filepath}`);
  }

  async close(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Export function for easy use
export async function scrapeV2Restaurant(config: ScraperConfig): Promise<ScraperResult> {
  const scraper = new V2Scraper(config);

  try {
    await scraper.initialize();
    const result = await scraper.scrapeMenu();
    await scraper.saveResults(result);

    console.log('\n=== V2 SCRAPE SUMMARY ===');
    console.log(`Total dishes:   ${result.summary.totalDishes}`);
    console.log(`Scraped:        ${result.summary.successCount}`);
    console.log(`Errors:         ${result.summary.errorCount}`);
    console.log(`Total Groups:   ${result.summary.totalGroups}`);
    console.log(`Total Options:  ${result.summary.totalOptions}`);
    console.log(`Success rate:   ${((result.summary.successCount / result.summary.totalDishes) * 100).toFixed(1)}%`);

    return result;
  } finally {
    await scraper.close();
  }
}
