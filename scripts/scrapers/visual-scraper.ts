/**
 * VISUAL-FIRST SCRAPER
 *
 * Approach:
 * 1. Load menu page
 * 2. Take full-page screenshot
 * 3. Extract ALL visible dish data (names, prices, descriptions) from DOM
 * 4. Save a manifest of what we can SEE
 * 5. For each dish, click and extract modifiers
 * 6. Match modifiers back to the dish manifest
 *
 * Simple. Visual. Reliable.
 */

import { chromium, Page, Browser } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

interface DishManifestEntry {
  index: number;
  name: string;
  price: number | null;
  description: string | null;
  category: string | null;
}

interface ModifierData {
  dishIndex: number;
  groups: Array<{
    name: string;
    options: Array<{
      name: string;
      priceDelta: number;
    }>;
  }>;
}

class VisualScraper {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private outputDir: string;

  constructor(outputDir: string = './scraped-data/visual') {
    this.outputDir = outputDir;
    fs.mkdirSync(outputDir, { recursive: true });
    fs.mkdirSync(path.join(outputDir, 'screenshots'), { recursive: true });
  }

  async initialize(): Promise<void> {
    this.browser = await chromium.launch({ headless: false }); // Always visible for debugging
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1920, height: 1080 });
  }

  async scrapeRestaurant(url: string, restaurantName: string): Promise<void> {
    if (!this.page) throw new Error('Not initialized');

    console.log(`\n📸 VISUAL SCRAPER - ${restaurantName}`);
    console.log(`URL: ${url}\n`);

    // Step 1: Load page and handle gates
    console.log('[1/4] Loading menu page...');
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });
    await this.page.waitForTimeout(2000);

    // Try clicking takeout if present
    try {
      const takeout = this.page.locator('img[src*="takeout"], a:has-text("Pour emporter")').first();
      if (await takeout.isVisible().catch(() => false)) {
        await takeout.click();
        await this.page.waitForTimeout(2000);
      }
    } catch {}

    // Step 2: Take full-page screenshot
    console.log('[2/4] Taking full-page screenshot...');
    await this.page.screenshot({
      path: path.join(this.outputDir, 'screenshots', 'full-menu.png'),
      fullPage: true
    });

    // Step 3: Extract visible dish manifest
    console.log('[3/4] Extracting visible dish data...');
    const manifest = await this.extractDishManifest();
    console.log(`\n✅ Found ${manifest.length} dishes on page:`);

    // Show first 10 as sample
    manifest.slice(0, 10).forEach((dish, idx) => {
      console.log(`  ${idx + 1}. ${dish.name} ($${dish.price || '?'}) - ${dish.category || 'No category'}`);
    });
    if (manifest.length > 10) {
      console.log(`  ... and ${manifest.length - 10} more`);
    }

    // Save manifest
    fs.writeFileSync(
      path.join(this.outputDir, 'dish-manifest.json'),
      JSON.stringify(manifest, null, 2)
    );

    // Step 4: Extract modifiers for each dish
    console.log('\n[4/4] Extracting modifiers...');
    const modifiers: ModifierData[] = [];

    for (let i = 0; i < manifest.length; i++) {
      const dish = manifest[i];
      console.log(`\n[${i + 1}/${manifest.length}] ${dish.name}`);

      try {
        const modifierData = await this.extractModifiersForDish(i);
        if (modifierData.groups.length > 0) {
          console.log(`  ✓ Found ${modifierData.groups.length} modifier groups`);
          modifiers.push(modifierData);
        } else {
          console.log(`  - No modifiers`);
        }
      } catch (error: any) {
        console.error(`  ✗ Error: ${error.message}`);
      }

      // Return to menu
      await this.page.goto(url, { waitUntil: 'domcontentloaded' });
      await this.page.waitForTimeout(500);
    }

    // Step 5: Combine manifest + modifiers
    console.log('\n[5/5] Combining data...');
    const combined = manifest.map(dish => {
      const modData = modifiers.find(m => m.dishIndex === dish.index);
      return {
        ...dish,
        groups: modData?.groups || []
      };
    });

    fs.writeFileSync(
      path.join(this.outputDir, 'complete-menu.json'),
      JSON.stringify(combined, null, 2)
    );

    console.log(`\n✅ COMPLETE!`);
    console.log(`Manifest: ${this.outputDir}/dish-manifest.json`);
    console.log(`Complete: ${this.outputDir}/complete-menu.json`);
    console.log(`Screenshots: ${this.outputDir}/screenshots/`);
  }

  private async extractDishManifest(): Promise<DishManifestEntry[]> {
    if (!this.page) return [];

    return await this.page.evaluate(() => {
      const dishes: DishManifestEntry[] = [];

      // Find all menu items
      // V1 sites typically have items in tables or divs with order buttons
      const containers = Array.from(document.querySelectorAll('table, .menu-item, .dish-item, div'));

      let dishIndex = 0;
      const processedTexts = new Set<string>();

      for (const container of containers) {
        // Must have an order button
        const orderBtn = container.querySelector('a:has-text("Choisissez"), img[src*="order.png"]');
        if (!orderBtn) continue;

        // Extract dish name (look for bold/heading text)
        let name = '';
        const headings = Array.from(container.querySelectorAll('strong, b, h3, h4, h5, .dish-name, .item-name'));
        for (const h of headings) {
          const text = h.textContent?.trim() || '';
          if (text.length > 2 && text.length < 150 && !text.includes('$')) {
            name = text;
            break;
          }
        }

        // Fallback: get first text node that's not a price
        if (!name) {
          const textNodes = Array.from(container.querySelectorAll('*'))
            .map(el => el.textContent?.trim())
            .filter(t => t && t.length > 3 && t.length < 150 && !t.includes('$'));
          name = textNodes[0] || 'Unknown';
        }

        // Extract price
        let price: number | null = null;
        const priceMatch = container.textContent?.match(/\$\s*(\d+[.,]\d{2})/);
        if (priceMatch) {
          price = parseFloat(priceMatch[1].replace(',', '.'));
        }

        // Extract description (look for smaller text or italic)
        let description: string | null = null;
        const descElements = Array.from(container.querySelectorAll('p, span, em, i, .description'));
        for (const desc of descElements) {
          const text = desc.textContent?.trim() || '';
          if (text.length > 10 && text.length < 500 && text !== name) {
            description = text;
            break;
          }
        }

        // Extract category (look for parent headings)
        let category: string | null = null;
        let parent = container.parentElement;
        while (parent && !category) {
          const heading = parent.querySelector('h1, h2, h3');
          if (heading) {
            const catText = heading.textContent?.trim() || '';
            if (catText.length > 2 && catText.length < 100) {
              category = catText;
            }
          }
          parent = parent.parentElement;
        }

        // De-duplicate by name
        const key = `${name}-${price}`;
        if (processedTexts.has(key)) continue;
        processedTexts.add(key);

        dishes.push({
          index: dishIndex++,
          name,
          price,
          description,
          category
        });
      }

      return dishes;
    });
  }

  private async extractModifiersForDish(dishIndex: number): Promise<ModifierData> {
    if (!this.page) throw new Error('No page');

    // Click the order button for this dish
    const orderButtons = await this.page.locator('a:has-text("Choisissez"), img[src*="order.png"]').all();
    if (dishIndex >= orderButtons.length) {
      throw new Error('Dish index out of range');
    }

    await orderButtons[dishIndex].click();
    await this.page.waitForTimeout(1500);

    // Take screenshot of modal
    await this.page.screenshot({
      path: path.join(this.outputDir, 'screenshots', `dish-${dishIndex}-modal.png`)
    });

    // Extract all modifier groups (multi-step)
    const groups: ModifierData['groups'] = [];
    let stepNum = 0;

    while (stepNum < 20) { // Safety limit
      const stepData = await this.page.evaluate(() => {
        // Find group title
        const titles = Array.from(document.querySelectorAll('h3, h4, strong, legend, .group-title'));
        let groupName = '';
        for (const t of titles) {
          const text = t.textContent?.trim() || '';
          if (text.length > 2 && text.length < 100 && !text.toLowerCase().includes('personnalisez')) {
            groupName = text;
            break;
          }
        }

        if (!groupName) return null;

        // Find option links
        const links = Array.from(document.querySelectorAll('a[href="#"], a[href*="menu#"]'))
          .filter(a => (a.textContent || '').includes(' - $'));

        const options = links.map(link => {
          const text = link.textContent?.trim() || '';
          const parts = text.split(' - ');
          const name = parts[0]?.trim() || 'Option';
          let priceDelta = 0;

          if (parts[1]) {
            const match = parts[1].match(/\$?\s*(\d+(?:\.\d+)?)/);
            if (match) priceDelta = parseFloat(match[1]) || 0;
          }

          return { name, priceDelta };
        });

        return { groupName, options };
      });

      if (!stepData || stepData.options.length === 0) break;

      groups.push({
        name: stepData.groupName,
        options: stepData.options
      });

      // Select first option and proceed
      if (stepData.options.length > 0) {
        const firstOpt = await this.page.locator(`a:has-text("${stepData.options[0].name}")`).first();
        await firstOpt.click().catch(() => {});
        await this.page.waitForTimeout(500);
      }

      // Check for next button
      const nextBtn = this.page.locator('button:has-text("Suivant"), button:has-text("Next")').first();
      if (await nextBtn.isVisible().catch(() => false)) {
        await nextBtn.click();
        await this.page.waitForTimeout(1000);
        stepNum++;
      } else {
        break;
      }
    }

    // Close modal
    await this.page.keyboard.press('Escape');
    await this.page.waitForTimeout(500);

    return { dishIndex, groups };
  }

  async close(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// CLI
async function main() {
  const scraper = new VisualScraper('./scraped-data/papa-burger-visual');

  try {
    await scraper.initialize();
    await scraper.scrapeRestaurant(
      'https://papaburger.ca/?p=menu',
      'Papa Burger'
    );
  } finally {
    await scraper.close();
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export { VisualScraper };
