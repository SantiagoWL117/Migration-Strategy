/**
 * IMPROVED V1 Menu Scraper
 * - Handles location/takeout gates
 * - Scrapes ALL dishes (not limited)
 * - Verifies counts against frontend
 * - Better error handling
 */

import { chromium, Page, Browser } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import {
  ScrapedDish,
  ModifierGroup,
  ScraperConfig,
  ScraperResult,
} from './types';

export class V1ScraperImproved {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private config: ScraperConfig;
  private screenshotCounter = 0;

  constructor(config: ScraperConfig) {
    this.config = {
      headless: true,
      timeout: 30000,
      screenshotsDir: './screenshots/v1',
      outputDir: './scraped-data/v1',
      ...config,
      version: 'v1'
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
      console.log(`[V1-Improved] Navigating to ${this.config.baseUrl}`);
      await this.page.goto(this.config.baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: this.config.timeout
      });

      await this.page.waitForTimeout(2000);

      // Step 1: Handle location/takeout gate
      await this.handleLocationGate();

      // Step 2: Count total dishes on page
      const dishCount = await this.countDishesOnPage();
      console.log(`[V1-Improved] Frontend shows ${dishCount} dishes`);
      result.summary.totalDishes = dishCount;

      if (dishCount === 0) {
        console.warn('[V1-Improved] No dishes found on page!');
        result.success = false;
        result.errors.push({
          error: 'No dishes found on menu page',
          timestamp: new Date().toISOString()
        });
        return result;
      }

      // Step 3: Scrape all dishes (no limit)
      for (let i = 0; i < dishCount; i++) {
        try {
          console.log(`[V1-Improved] Processing dish ${i + 1}/${dishCount}`);
          const dish = await this.scrapeSingleDish(i);
          if (dish) {
            result.dishes.push(dish);
            result.summary.successCount++;
            result.summary.totalGroups += dish.groups.length;
            result.summary.totalOptions += dish.groups.reduce((sum, g) => sum + g.options.length, 0);
          }
        } catch (error: any) {
          console.error(`[V1-Improved] Error scraping dish ${i + 1}:`, error.message);
          result.errors.push({
            dishName: `Dish ${i + 1}`,
            error: error.message,
            timestamp: new Date().toISOString()
          });
          result.summary.errorCount++;
        }

        // Go back to menu for next dish
        await this.page.goto(this.config.baseUrl, { waitUntil: 'domcontentloaded' });
        await this.handleLocationGate(); // Re-handle gate if needed
        await this.page.waitForTimeout(1000);
      }

      // Step 4: Verify counts
      console.log(`\n[V1-Improved] Verification:`);
      console.log(`  Frontend count: ${dishCount}`);
      console.log(`  Scraped count:  ${result.dishes.length}`);
      console.log(`  Success rate:   ${((result.summary.successCount / dishCount) * 100).toFixed(1)}%`);

      if (result.dishes.length < dishCount) {
        console.warn(`[V1-Improved] ⚠️  Scraped ${dishCount - result.dishes.length} fewer dishes than expected!`);
      }

    } catch (error: any) {
      console.error('[V1-Improved] Fatal error:', error);
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
      // Look for "Takeout" or "Pick up" button
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
          console.log(`[V1-Improved] Clicking takeout/pickup button`);
          await button.click();
          await this.page.waitForTimeout(2000);
          return;
        }
      }

      // If no takeout button, might already be on menu
      console.log(`[V1-Improved] No location gate detected, proceeding...`);
    } catch (error) {
      console.warn(`[V1-Improved] Could not handle location gate:`, error);
    }
  }

  private async countDishesOnPage(): Promise<number> {
    if (!this.page) return 0;

    try {
      // Count all "order" buttons on the page
      const count = await this.page.evaluate(() => {
        // V1 sites typically use these patterns for order buttons
        const selectors = [
          'a:has-text("Choisissez cet item")',
          'a:has-text("Order")',
          'a:has-text("Add to Cart")',
          'img[src*="order.png"]',
          'a[onclick*="order"]'
        ];

        let maxCount = 0;
        for (const selector of selectors) {
          try {
            const elements = document.querySelectorAll(selector);
            maxCount = Math.max(maxCount, elements.length);
          } catch {}
        }

        return maxCount;
      });

      return count;
    } catch (error) {
      console.error('[V1-Improved] Error counting dishes:', error);
      return 0;
    }
  }

  private async scrapeSingleDish(dishIndex: number): Promise<ScrapedDish | null> {
    if (!this.page) return null;

    // Find all order buttons
    const orderButtons = await this.page.locator('a:has-text("Choisissez cet item"), a:has-text("Order"), img[src*="order.png"]').all();
    if (dishIndex >= orderButtons.length) return null;

    // Extract dish info before clicking
    const dishButton = orderButtons[dishIndex];
    const dishName = await this.extractDishName(dishButton);
    const dishPrice = await this.extractDishPrice(dishButton);

    console.log(`[V1-Improved]   Dish: ${dishName} ($${dishPrice || 'unknown'})`);

    // Click to open customization
    await dishButton.click();
    await this.page.waitForTimeout(2000);

    // Take screenshot
    await this.takeScreenshot(`dish-${dishIndex}-modal`);

    // Extract modifier groups
    const groups: ModifierGroup[] = [];
    let stepNumber = 1;
    let hasMoreSteps = true;

    while (hasMoreSteps && stepNumber <= 20) { // Safety limit
      const stepData = await this.extractCurrentStep(stepNumber);
      if (!stepData || stepData.options.length === 0) {
        break;
      }

      console.log(`[V1-Improved]     Step ${stepNumber}: ${stepData.groupName} (${stepData.options.length} options)`);

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

      // Select first option
      if (stepData.options.length > 0) {
        const firstOption = await this.page.locator(`a:has-text("${stepData.options[0].name}")`).first();
        await firstOption.click().catch(() => {});
        await this.page.waitForTimeout(500);
      }

      // Check for next/submit buttons
      const nextBtn = this.page.locator('button:has-text("Suivant"), button:has-text("Next")').first();
      const submitBtn = this.page.locator('button:has-text("Ajouter"), button:has-text("Submit"), button:has-text("Add")').first();

      if (await nextBtn.isVisible().catch(() => false)) {
        await nextBtn.click();
        await this.page.waitForTimeout(1000);
        stepNumber++;
      } else if (await submitBtn.isVisible().catch(() => false)) {
        hasMoreSteps = false;
      } else {
        hasMoreSteps = false;
      }
    }

    // Close modal
    await this.page.keyboard.press('Escape');
    await this.page.waitForTimeout(500);

    return {
      restaurant: this.config.restaurantName,
      restaurantUrl: this.config.baseUrl,
      dish: {
        name: dishName,
        basePrice: dishPrice
      },
      groups,
      metadata: {
        scrapedAt: new Date().toISOString(),
        version: 'v1',
        dishUrl: this.page.url()
      }
    };
  }

  private async extractDishName(button: any): Promise<string> {
    if (!this.page) return 'Unknown';

    try {
      const name = await button.evaluateHandle((btn: any) => {
        const container = btn.closest('div, td, li');
        if (container) {
          // Look for heading or bold text
          const heading = container.querySelector('h3, h4, h5, strong, b, .dish-name');
          if (heading) return heading.textContent?.trim();

          // Fallback: find text before price
          const text = container.textContent || '';
          const priceMatch = text.match(/\$\s*\d+/);
          if (priceMatch) {
            return text.substring(0, text.indexOf(priceMatch[0])).trim();
          }
        }
        return 'Unknown';
      });

      return await name.evaluate((el: any) => el || 'Unknown');
    } catch {
      return 'Unknown';
    }
  }

  private async extractDishPrice(button: any): Promise<number | null> {
    if (!this.page) return null;

    try {
      const price = await button.evaluateHandle((btn: any) => {
        const container = btn.closest('div, td, li');
        if (container) {
          const text = container.textContent || '';
          const match = text.match(/\$\s*(\d+(?:[.,]\d{2})?)/);
          if (match) {
            return parseFloat(match[1].replace(',', '.'));
          }
        }
        return null;
      });

      return await price.evaluate((val: any) => val);
    } catch {
      return null;
    }
  }

  private async extractCurrentStep(stepNum: number): Promise<any> {
    if (!this.page) return null;

    try {
      return await this.page.evaluate(() => {
        // Find group title
        const titles = Array.from(document.querySelectorAll('h3, h4, strong, legend'));
        let groupName = 'Options';
        for (const el of titles) {
          const text = el.textContent?.trim() || '';
          if (text.length > 3 && text.length < 100 && !text.includes('Personnalisez')) {
            groupName = text;
            break;
          }
        }

        // Find options (links with prices)
        const links = Array.from(document.querySelectorAll('a[href="#"], a[href*="menu#"]'))
          .filter(a => (a.textContent || '').includes(' - $'));

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

          return { name, priceDelta };
        });

        const isRequired = document.body.textContent?.includes('il vous plaît') || false;

        return { groupName, options, isRequired };
      });
    } catch {
      return null;
    }
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
    console.log(`\n[V1-Improved] Results saved to: ${filepath}`);
  }

  async close(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Export function
export async function scrapeV1RestaurantImproved(config: ScraperConfig): Promise<ScraperResult> {
  const scraper = new V1ScraperImproved(config);

  try {
    await scraper.initialize();
    const result = await scraper.scrapeMenu();
    await scraper.saveResults(result);

    console.log('\n=== V1 IMPROVED SCRAPE SUMMARY ===');
    console.log(`Frontend count: ${result.summary.totalDishes}`);
    console.log(`Scraped:        ${result.summary.successCount}`);
    console.log(`Errors:         ${result.summary.errorCount}`);
    console.log(`Total Groups:   ${result.summary.totalGroups}`);
    console.log(`Total Options:  ${result.summary.totalOptions}`);
    console.log(`Match rate:     ${((result.summary.successCount / result.summary.totalDishes) * 100).toFixed(1)}%`);

    return result;
  } finally {
    await scraper.close();
  }
}
