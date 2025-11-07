/**
 * V2 Menu Scraper (MENU.CA V2 sites like Paréa)
 * Handles single-page grouped customization with radio/checkbox inputs
 */

import { chromium, Page, Browser } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import {
  ScrapedDish,
  ModifierGroup,
  ModifierOption,
  ScraperConfig,
  ScraperResult,
  V2GroupData
} from './types';

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
    // Create output directories
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

  async scrapeMenu(dishUrls: string[]): Promise<ScraperResult> {
    if (!this.page) throw new Error('Scraper not initialized');

    const result: ScraperResult = {
      success: true,
      dishes: [],
      errors: [],
      summary: {
        totalDishes: dishUrls.length,
        successCount: 0,
        errorCount: 0,
        totalGroups: 0,
        totalOptions: 0
      }
    };

    // Handle "PICK UP" button if present
    try {
      console.log(`[V2] Navigating to ${this.config.baseUrl}`);
      await this.page.goto(this.config.baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: this.config.timeout
      });

      const pickUpBtn = this.page.locator('button:has-text("PICK UP"), button:has-text("Pick up"), a:has-text("PICK UP")').first();
      const isPickUpVisible = await pickUpBtn.isVisible().catch(() => false);

      if (isPickUpVisible) {
        console.log('[V2] Clicking "PICK UP" button to unlock ordering');
        await pickUpBtn.click();
        await this.page.waitForTimeout(1000);
      }
    } catch (error) {
      console.warn('[V2] Could not handle PICK UP flow:', error);
    }

    // Scrape each dish URL
    for (let i = 0; i < dishUrls.length; i++) {
      const dishUrl = dishUrls[i];
      try {
        console.log(`\n[V2] Processing dish ${i + 1}/${dishUrls.length}: ${dishUrl}`);
        const dish = await this.scrapeSingleDish(dishUrl, i);
        if (dish) {
          result.dishes.push(dish);
          result.summary.successCount++;
          result.summary.totalGroups += dish.groups.length;
          result.summary.totalOptions += dish.groups.reduce((sum, g) => sum + g.options.length, 0);
        }
      } catch (error: any) {
        console.error(`[V2] Error scraping ${dishUrl}:`, error.message);
        result.errors.push({
          dishName: dishUrl,
          error: error.message,
          timestamp: new Date().toISOString()
        });
        result.summary.errorCount++;
        result.success = false;
      }
    }

    return result;
  }

  private async scrapeSingleDish(dishUrl: string, dishIndex: number): Promise<ScrapedDish | null> {
    if (!this.page) throw new Error('Page not initialized');

    console.log(`[V2] Navigating to: ${dishUrl}`);
    await this.page.goto(dishUrl, {
      waitUntil: 'domcontentloaded',
      timeout: this.config.timeout
    });

    await this.page.waitForTimeout(2000); // Let customization form render

    // Take screenshot
    await this.takeScreenshot(`dish-${dishIndex}-customization`);

    // Extract dish details
    const dishName = await this.extractDishName();
    const dishPrice = await this.extractDishPrice();
    const dishDescription = await this.extractDishDescription();

    console.log(`[V2] Dish: ${dishName} ($${dishPrice || 'unknown'})`);

    // Extract all modifier groups from the customization form
    const groups = await this.extractModifierGroups();

    console.log(`[V2] Found ${groups.length} modifier groups`);
    groups.forEach((group, idx) => {
      console.log(`[V2]   ${idx + 1}. ${group.name} (${group.selectType}, ${group.options.length} options)`);
    });

    return {
      restaurant: this.config.restaurantName,
      restaurantUrl: this.config.baseUrl,
      dish: {
        name: dishName,
        description: dishDescription,
        basePrice: dishPrice
      },
      groups,
      metadata: {
        scrapedAt: new Date().toISOString(),
        version: 'v2',
        dishUrl: dishUrl
      }
    };
  }

  private async extractDishName(): Promise<string> {
    if (!this.page) return 'Unknown Dish';

    try {
      const name = await this.page.evaluate(() => {
        const h1 = document.querySelector('h1, h2, .dish-title, .dish-name, [class*="title"]');
        if (h1) return h1.textContent?.trim() || 'Unknown Dish';

        // Fallback: find largest text on page
        const allText = Array.from(document.querySelectorAll('body *'))
          .map(el => ({
            text: el.textContent?.trim() || '',
            fontSize: parseFloat(window.getComputedStyle(el).fontSize)
          }))
          .filter(item => item.text.length > 3 && item.text.length < 100)
          .sort((a, b) => b.fontSize - a.fontSize);

        return allText[0]?.text || 'Unknown Dish';
      });

      return name;
    } catch {
      return 'Unknown Dish';
    }
  }

  private async extractDishPrice(): Promise<number | null> {
    if (!this.page) return null;

    try {
      const price = await this.page.evaluate(() => {
        const priceElements = Array.from(document.querySelectorAll('.price, .dish-price, [class*="price"]'));
        for (const el of priceElements) {
          const text = el.textContent || '';
          const match = text.match(/\$\s*(\d+(?:[.,]\d{2})?)/);
          if (match) {
            const cleaned = match[1].replace(',', '.');
            return parseFloat(cleaned);
          }
        }

        // Fallback: scan entire page for price pattern
        const bodyText = document.body.textContent || '';
        const match = bodyText.match(/\$\s*(\d+(?:[.,]\d{2})?)/);
        if (match) {
          const cleaned = match[1].replace(',', '.');
          return parseFloat(cleaned);
        }

        return null;
      });

      return price;
    } catch {
      return null;
    }
  }

  private async extractDishDescription(): Promise<string | undefined> {
    if (!this.page) return undefined;

    try {
      const description = await this.page.evaluate(() => {
        const descEl = document.querySelector('.dish-description, .description, [class*="description"]');
        if (descEl) {
          const text = descEl.textContent?.trim() || '';
          return text.length > 10 ? text : undefined;
        }
        return undefined;
      });

      return description;
    } catch {
      return undefined;
    }
  }

  private async extractModifierGroups(): Promise<ModifierGroup[]> {
    if (!this.page) return [];

    try {
      const groupsData = await this.page.evaluate(() => {
        const groups: any[] = [];

        // Strategy 1: Find fieldset elements (common in forms)
        const fieldsets = Array.from(document.querySelectorAll('fieldset, .options-group, .modifiers, .menu-options, .customization-group, section'));

        for (const block of fieldsets) {
          // Find group name (legend, heading, or label)
          const legend = block.querySelector('legend, h3, h4, h5, .group-title, .group-name');
          const groupName = legend?.textContent?.trim();

          if (!groupName || groupName.length < 2) continue;

          // Find all radio/checkbox inputs in this group
          const inputs = Array.from(block.querySelectorAll('input[type="radio"], input[type="checkbox"]'));
          if (inputs.length === 0) continue;

          const inputType = inputs[0].getAttribute('type') || 'radio';

          // Extract options
          const options: any[] = [];
          for (const input of inputs) {
            const id = input.getAttribute('id') || '';
            const name = input.getAttribute('name') || '';

            // Find associated label
            let label: Element | null = null;
            if (id) {
              label = block.querySelector(`label[for="${id}"]`);
            }
            if (!label) {
              label = input.closest('label');
            }

            const labelText = label?.textContent?.trim() || 'Option';

            // Extract price delta from label text
            let priceDelta = 0;
            const priceMatch = labelText.match(/\+?\s*\$\s*(\d+(?:\.\d+)?)/);
            if (priceMatch) {
              priceDelta = parseFloat(priceMatch[1]) || 0;
            }

            // Clean option name (remove price)
            const optionName = labelText
              .replace(/\(\+?\s*\$\s*\d+(?:\.\d+)?\)/g, '')
              .replace(/\+?\s*\$\s*\d+(?:\.\d+)?/, '')
              .trim();

            const isDefault = input.hasAttribute('checked');

            options.push({
              name: optionName,
              priceDelta,
              isDefault
            });
          }

          // Determine if required based on heuristics
          const blockText = block.textContent?.toLowerCase() || '';
          const isRequired = blockText.includes('required') ||
                             blockText.includes('choose one') ||
                             blockText.includes('select one') ||
                             blockText.includes('min') ||
                             inputType === 'radio'; // Radios are typically required

          groups.push({
            name: groupName,
            inputType,
            options,
            isRequired,
            blockText: blockText.substring(0, 200) // For debugging
          });
        }

        return groups;
      });

      // Convert to ModifierGroup format
      const groups: ModifierGroup[] = groupsData.map((g, idx) => {
        const selectType = g.inputType === 'checkbox' ? 'multi' : 'single';
        const minSelections = g.isRequired ? 1 : 0;
        const maxSelections = selectType === 'single' ? 1 : null; // Multi can be unlimited

        return {
          name: g.name,
          selectType,
          minSelections,
          maxSelections,
          isRequired: g.isRequired,
          displayOrder: idx,
          options: g.options.map((opt: any, optIdx: number) => ({
            name: opt.name,
            priceDelta: opt.priceDelta,
            isDefault: opt.isDefault
          }))
        };
      });

      return groups;
    } catch (error) {
      console.error('[V2] Error extracting modifier groups:', error);
      return [];
    }
  }

  private async takeScreenshot(name: string): Promise<void> {
    if (!this.page || !this.config.screenshotsDir) return;

    const filename = `${this.screenshotCounter++}-${name}.png`;
    const filepath = path.join(this.config.screenshotsDir, filename);

    await this.page.screenshot({
      path: filepath,
      fullPage: true
    });

    console.log(`[V2] Screenshot saved: ${filename}`);
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

// Helper function to discover dish URLs from a V2 menu page
export async function discoverV2DishUrls(baseUrl: string, limit: number = 10): Promise<string[]> {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    console.log(`[V2] Discovering dish URLs from: ${baseUrl}`);
    await page.goto(baseUrl, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(2000);

    const dishUrls = await page.evaluate((baseUrl) => {
      const links = Array.from(document.querySelectorAll('a[href*="/dish/create/"]'));
      const urls = links
        .map(a => a.getAttribute('href'))
        .filter((href): href is string => href !== null && href.includes('/dish/create/'))
        .map(href => {
          if (href.startsWith('http')) return href;
          if (href.startsWith('/')) {
            const url = new URL(baseUrl);
            return `${url.protocol}//${url.host}${href}`;
          }
          return `${baseUrl}${href}`;
        });

      // Deduplicate
      return Array.from(new Set(urls));
    }, baseUrl);

    console.log(`[V2] Discovered ${dishUrls.length} dish URLs`);
    return dishUrls.slice(0, limit);
  } finally {
    await browser.close();
  }
}

// Example usage
export async function scrapeV2Restaurant(config: ScraperConfig, dishLimit: number = 10): Promise<ScraperResult> {
  // First, discover dish URLs
  const dishUrls = await discoverV2DishUrls(config.baseUrl, dishLimit);

  if (dishUrls.length === 0) {
    console.warn('[V2] No dish URLs found. You may need to provide them manually.');
    return {
      success: false,
      dishes: [],
      errors: [{ error: 'No dish URLs discovered', timestamp: new Date().toISOString() }],
      summary: { totalDishes: 0, successCount: 0, errorCount: 0, totalGroups: 0, totalOptions: 0 }
    };
  }

  // Scrape discovered dishes
  const scraper = new V2Scraper(config);

  try {
    await scraper.initialize();
    const result = await scraper.scrapeMenu(dishUrls);
    await scraper.saveResults(result);

    console.log('\n=== V2 SCRAPE SUMMARY ===');
    console.log(`Total Dishes: ${result.summary.totalDishes}`);
    console.log(`Successful: ${result.summary.successCount}`);
    console.log(`Errors: ${result.summary.errorCount}`);
    console.log(`Total Groups: ${result.summary.totalGroups}`);
    console.log(`Total Options: ${result.summary.totalOptions}`);

    return result;
  } finally {
    await scraper.close();
  }
}