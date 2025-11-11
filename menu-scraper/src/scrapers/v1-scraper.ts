/**
 * SIMPLE V1 Scraper - Extract names first, then modifiers
 *
 * Strategy:
 * 1. Extract ALL dish names and prices from menu page DOM
 * 2. For each dish by index, click and extract modifiers
 * 3. Match by position/index
 */

import { chromium, Page, Browser } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import {
  ScrapedDish,
  ModifierGroup,
  ScraperConfig,
  ScraperResult,
} from '../types';

export class V1SimpleScraper {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private config: ScraperConfig;
  private screenshotCounter = 0;

  constructor(config: ScraperConfig) {
    this.config = {
      headless: true,
      timeout: 30000,
      screenshotsDir: './screenshots/v1-simple',
      outputDir: './scraped-data/v1-simple',
      ...config,
      version: 'v1'
    };
  }

  async initialize(): Promise<void> {
    if (this.config.screenshotsDir) {
      fs.mkdirSync(this.config.screenshotsDir, { recursive: true });}
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
      console.log(`[V1-Simple] Navigating to ${this.config.baseUrl}`);
      await this.page.goto(this.config.baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: this.config.timeout
      });

      await this.page.waitForTimeout(2000);

      // Step 1: Handle location gate
      await this.handleLocationGate();

      // Step 2: Extract ALL dish names and prices from DOM
      console.log('[V1-Simple] Extracting dish names from DOM...');
      const dishManifest = await this.extractDishManifest();
      console.log(`[V1-Simple] Found ${dishManifest.length} dishes on page`);

      result.summary.totalDishes = dishManifest.length;

      // Show sample
      console.log('\n[V1-Simple] Sample dishes:');
      dishManifest.slice(0, 10).forEach((dish, idx) => {
        console.log(`  ${idx + 1}. ${dish.name} ($${dish.price || '?'})`);
      });
      if (dishManifest.length > 10) {
        console.log(`  ... and ${dishManifest.length - 10} more\n`);
      }

      // Step 3: For each dish, extract modifiers
      for (let i = 0; i < dishManifest.length; i++) {
        try {
          console.log(`[V1-Simple] [${i + 1}/${dishManifest.length}] ${dishManifest[i].name}`);

          const groups = await this.extractModifiersForDish(i);

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
              version: 'v1',
              dishUrl: this.page.url()
            }
          });

          result.summary.successCount++;
          result.summary.totalGroups += groups.length;
          result.summary.totalOptions += groups.reduce((sum, g) => sum + g.options.length, 0);

          console.log(`[V1-Simple]   ✓ ${groups.length} groups, ${groups.reduce((sum, g) => sum + g.options.length, 0)} options`);

        } catch (error: any) {
          console.error(`[V1-Simple]   ✗ Error: ${error.message}`);
          result.errors.push({
            dishName: dishManifest[i]?.name || `Dish ${i + 1}`,
            error: error.message,
            timestamp: new Date().toISOString()
          });
          result.summary.errorCount++;
        }

        // Go back to menu
        await this.page.goto(this.config.baseUrl, { waitUntil: 'domcontentloaded' });
        await this.handleLocationGate();
        await this.page.waitForTimeout(1000);
      }

      console.log(`\n[V1-Simple] Complete: ${result.summary.successCount}/${result.summary.totalDishes} dishes`);

    } catch (error: any) {
      console.error('[V1-Simple] Fatal error:', error);
      result.success = false;
      result.errors.push({
        error: `Fatal: ${error.message}`,
        timestamp: new Date().toISOString()
      });
    }

    return result;
  }

  private async handleLocationGate(): Promise<void> {
    if (!this.page) return;

    try {
      const takeoutSelectors = [
        'a:has-text("Takeout")',
        'a:has-text("Pick up")',
        'a:has-text("Pour emporter")',
        'img[alt*="takeout"]',
        'img[src*="takeout"]'
      ];

      for (const selector of takeoutSelectors) {
        const button = this.page.locator(selector).first();
        if (await button.isVisible().catch(() => false)) {
          console.log(`[V1-Simple] Clicking takeout button`);
          await button.click();
          await this.page.waitForTimeout(2000);
          return;
        }
      }
    } catch (error) {
      // Silent fail
    }
  }

  private async extractDishManifest(): Promise<Array<{ name: string; price: number | null; description: string | null; category: string | null }>> {
    if (!this.page) return [];

    return await this.page.evaluate(() => {
      const dishes: Array<{ name: string; price: number | null; description: string | null; category: string | null }> = [];

      // Find all category sections (divs with id starting with "f_")
      const sections = Array.from(document.querySelectorAll('div[id^="f_"]'));

      for (const section of sections) {
        let categoryName: string | null = null;

        // Find category name in the category name div (id starting with "cname_")
        const cnameDiv = section.querySelector('div[id^="cname_"]');
        if (cnameDiv) {
          const categoryP = cnameDiv.querySelector('p[style*="font-weight: bold"], p[style*="font-weight:bold"]');
          if (categoryP) {
            categoryName = categoryP.textContent?.trim() || null;
          }
        }

        // Find all forms (dishes) within this section
        const forms = Array.from(section.querySelectorAll('form[id^="form_"]'));

        for (const form of forms) {
          let dishName = '';
          let price: number | null = null;
          let description: string | null = null;

          // Find the dish name (first bold <p> in the left float div)
          const leftDiv = form.querySelector('div[style*="float:left"]');
          if (leftDiv) {
            const boldPs = Array.from(leftDiv.querySelectorAll('p[style*="font-weight: bold"], p[style*="font-weight:bold"]'));
            if (boldPs.length > 0) {
              dishName = boldPs[0].textContent?.trim() || '';
            }

            // Find description (second <p> in left div, not bold)
            const allPs = Array.from(leftDiv.querySelectorAll('p'));
            if (allPs.length > 1) {
              // Skip the first (name), get second (description)
              const descP = allPs[1];
              if (descP && !descP.style.fontWeight) {
                description = descP.textContent?.trim() || null;
              }
            }
          }

          // Find price in the table
          const priceCell = form.querySelector('td:nth-child(2)');
          if (priceCell) {
            const priceText = priceCell.textContent?.trim() || '';
            const priceMatch = priceText.match(/\$\s*(\d+[.,]\d{2})/);
            if (priceMatch) {
              price = parseFloat(priceMatch[1].replace(',', '.'));
            }
          }

          if (dishName && dishName.length > 0) {
            dishes.push({ name: dishName, price, description, category: categoryName });
          }
        }
      }

      return dishes;
    });
  }

  private async extractModifiersForDish(dishIndex: number): Promise<ModifierGroup[]> {
    if (!this.page) return [];

    // Find all order buttons
    const orderButtons = await this.page.locator('a[href*="menu#"], img[src*="order"]').all();
    if (dishIndex >= orderButtons.length) {
      throw new Error(`Dish index ${dishIndex} out of range (${orderButtons.length} buttons)`);
    }

    // Click button
    await orderButtons[dishIndex].click();
    await this.page.waitForTimeout(2000);

    // Take screenshot
    await this.takeScreenshot(`dish-${dishIndex}`);

    // Extract modifier groups
    const groups: ModifierGroup[] = [];
    let stepNumber = 1;
    let hasMoreSteps = true;

    while (hasMoreSteps && stepNumber <= 20) {
      const stepData = await this.page.evaluate(() => {
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

        // Find options (links with prices)
        const links = Array.from(document.querySelectorAll('a[href="#"], a[href*="menu#"]'))
          .filter(a => {
            const text = a.textContent || '';
            return text.includes(' - $') || text.includes('$');
          });

        const options = links.map(link => {
          const text = link.textContent?.trim() || '';
          const parts = text.split(' - ');
          let name = parts[0]?.trim() || 'Option';
          let priceDelta = 0;

          if (parts[1]) {
            const priceMatch = parts[1].match(/\$?\s*(\d+(?:\.\d+)?)/);
            if (priceMatch) {
              priceDelta = parseFloat(priceMatch[1]) || 0;
            }
          }

          return { name, priceDelta, isDefault: false };
        });

        const isRequired = document.body.textContent?.includes('il vous plaît') || false;

        return { groupName, options, isRequired };
      });

      if (!stepData || stepData.options.length === 0) {
        break;
      }

      groups.push({
        name: stepData.groupName,
        selectType: 'single',
        minSelections: stepData.isRequired ? 1 : 0,
        maxSelections: 1,
        isRequired: stepData.isRequired,
        displayOrder: stepNumber - 1,
        stepOrder: stepNumber,
        options: stepData.options
      });

      // Click first option
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
        stepNumber++;
      } else {
        hasMoreSteps = false;
      }
    }

    // Close modal
    await this.page.keyboard.press('Escape');
    await this.page.waitForTimeout(500);

    return groups;
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
    console.log(`\n[V1-Simple] Results saved to: ${filepath}`);
  }

  async close(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Export function
export async function scrapeV1RestaurantSimple(config: ScraperConfig): Promise<ScraperResult> {
  const scraper = new V1SimpleScraper(config);

  try {
    await scraper.initialize();
    const result = await scraper.scrapeMenu();
    await scraper.saveResults(result);

    console.log('\n=== V1 SIMPLE SCRAPE SUMMARY ===');
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
