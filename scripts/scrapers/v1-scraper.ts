/**
 * V1 Menu Scraper (Papa Burger / Menu.ca V1 sites)
 * Handles multi-step modal customization flows
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
  V1StepData
} from './types';

export class V1Scraper {
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
    await this.page.setViewportSize({ width: 1280, height: 720 });
  }

  async scrapeMenu(dishLimit: number = 10): Promise<ScraperResult> {
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
      console.log(`[V1] Navigating to ${this.config.baseUrl}`);
      await this.page.goto(this.config.baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: this.config.timeout
      });

      await this.page.waitForTimeout(2000); // Let menu render

      // Find all "Add to cart" or "Choisissez cet item" buttons
      const dishButtons = await this.page.locator('a:has-text("Choisissez cet item"), a:has-text("Add to Cart"), a:has-text("Order")').all();
      const totalFound = dishButtons.length;
      console.log(`[V1] Found ${totalFound} dishes, will scrape up to ${dishLimit}`);

      result.summary.totalDishes = Math.min(totalFound, dishLimit);

      for (let i = 0; i < Math.min(dishButtons.length, dishLimit); i++) {
        try {
          console.log(`\n[V1] Processing dish ${i + 1}/${result.summary.totalDishes}`);
          const dish = await this.scrapeSingleDish(i);
          if (dish) {
            result.dishes.push(dish);
            result.success = result.success && true;
            result.summary.successCount++;
            result.summary.totalGroups += dish.groups.length;
            result.summary.totalOptions += dish.groups.reduce((sum, g) => sum + g.options.length, 0);
          }
        } catch (error: any) {
          console.error(`[V1] Error scraping dish ${i + 1}:`, error.message);
          result.errors.push({
            dishName: `Dish ${i + 1}`,
            error: error.message,
            timestamp: new Date().toISOString()
          });
          result.summary.errorCount++;
          result.success = false;
        }

        // Go back to menu for next dish
        await this.page.goto(this.config.baseUrl, { waitUntil: 'domcontentloaded' });
        await this.page.waitForTimeout(1000);
      }
    } catch (error: any) {
      console.error('[V1] Fatal error during menu scraping:', error);
      result.success = false;
      result.errors.push({
        error: `Fatal: ${error.message}`,
        timestamp: new Date().toISOString()
      });
    }

    return result;
  }

  private async scrapeSingleDish(dishIndex: number): Promise<ScrapedDish | null> {
    if (!this.page) throw new Error('Page not initialized');

    // Click the dish button
    const dishButtons = await this.page.locator('a:has-text("Choisissez cet item"), a:has-text("Add to Cart"), a:has-text("Order")').all();
    if (dishIndex >= dishButtons.length) return null;

    // Extract dish name from nearby context before clicking
    const dishButton = dishButtons[dishIndex];
    const dishName = await this.extractDishName(dishButton);
    const dishPrice = await this.extractDishPrice(dishButton);

    console.log(`[V1] Clicking dish: ${dishName} ($${dishPrice || 'unknown'})`);
    await dishButton.click();

    // Wait for customization modal
    await this.page.waitForSelector('text=Personnalisez votre commande, text=Customize your order', { timeout: 5000 }).catch(() => {});
    await this.page.waitForTimeout(1000);

    // Take initial screenshot
    await this.takeScreenshot(`dish-${dishIndex}-modal-opened`);

    // Extract all modifier groups by stepping through the modal
    const groups: ModifierGroup[] = [];
    let stepNumber = 1;
    let hasMoreSteps = true;

    while (hasMoreSteps) {
      const stepData = await this.extractCurrentStep(stepNumber);
      if (!stepData || stepData.options.length === 0) {
        break;
      }

      console.log(`[V1]   Step ${stepNumber}: ${stepData.groupName} (${stepData.options.length} options)`);

      const group: ModifierGroup = {
        name: stepData.groupName,
        selectType: 'single', // V1 combos are typically single-select per step
        minSelections: stepData.isRequired ? 1 : 0,
        maxSelections: 1,
        isRequired: stepData.isRequired,
        displayOrder: stepNumber - 1,
        stepOrder: stepNumber,
        options: stepData.options.map((opt, idx) => ({
          name: opt.name,
          priceDelta: opt.priceDelta
        }))
      };

      groups.push(group);

      // Select first option to proceed to next step
      if (stepData.options.length > 0) {
        const firstOptionLink = await this.page.locator(`a:has-text("${stepData.options[0].linkText}")`).first();
        await firstOptionLink.click();
        await this.page.waitForTimeout(500);
      }

      // Try to click "Suivant" (Next) or check if we're on the final step
      const nextButton = this.page.locator('button:has-text("Suivant"), button:has-text("Next"), button:has-text("Étape suivante")').first();
      const submitButton = this.page.locator('button:has-text("Ajouter"), button:has-text("Add to Cart"), button:has-text("Submit")').first();

      const nextVisible = await nextButton.isVisible().catch(() => false);
      const submitVisible = await submitButton.isVisible().catch(() => false);

      if (nextVisible) {
        await this.takeScreenshot(`dish-${dishIndex}-step-${stepNumber}`);
        await nextButton.click();
        await this.page.waitForTimeout(1000);
        stepNumber++;
      } else if (submitVisible) {
        await this.takeScreenshot(`dish-${dishIndex}-final-step`);
        hasMoreSteps = false;
      } else {
        hasMoreSteps = false;
      }
    }

    // Close modal without submitting (press Escape or click close button)
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

  private async extractDishName(buttonElement: any): Promise<string> {
    if (!this.page) return 'Unknown Dish';

    try {
      // Try to find dish name in parent container
      const nameElement = await buttonElement.evaluateHandle((btn: any) => {
        // Look for nearest heading or strong text above the button
        const container = btn.closest('.menu-item, .dish-item, div');
        if (container) {
          const heading = container.querySelector('h3, h4, h5, strong, .dish-name, .item-name');
          if (heading) return heading;

          // Fallback: find any text node that looks like a dish name
          const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT);
          let node;
          while (node = walker.nextNode()) {
            const text = node.textContent?.trim() || '';
            if (text.length > 3 && text.length < 100 && !text.includes('$') && !text.includes('Choisissez')) {
              return node.parentElement;
            }
          }
        }
        return null;
      });

      const name = await nameElement.evaluate((el: any) => el?.textContent?.trim() || 'Unknown Dish');
      return name;
    } catch {
      return 'Unknown Dish';
    }
  }

  private async extractDishPrice(buttonElement: any): Promise<number | null> {
    if (!this.page) return null;

    try {
      const priceText = await buttonElement.evaluateHandle((btn: any) => {
        const container = btn.closest('.menu-item, .dish-item, div');
        if (container) {
          const priceEl = container.querySelector('.price, .dish-price, [class*="price"]');
          if (priceEl) return priceEl.textContent;

          // Fallback: regex search for price pattern
          const text = container.textContent || '';
          const match = text.match(/\$\s*(\d+(?:[.,]\d{2})?)/);
          if (match) return match[0];
        }
        return null;
      });

      const price = await priceText.evaluate((text: any) => {
        if (!text) return null;
        const cleaned = text.replace(/[^0-9.,]/g, '').replace(',', '.');
        const num = parseFloat(cleaned);
        return isNaN(num) ? null : num;
      });

      return price;
    } catch {
      return null;
    }
  }

  private async extractCurrentStep(stepNum: number): Promise<V1StepData | null> {
    if (!this.page) return null;

    try {
      const stepData = await this.page.evaluate(() => {
        // Find group title (usually a heading or strong text near the top of the modal)
        const possibleTitles = Array.from(document.querySelectorAll('h3, h4, strong, .group-title, legend'));
        let groupTitle = 'Modifier Group';

        for (const el of possibleTitles) {
          const text = el.textContent?.trim() || '';
          if (text.length > 3 && text.length < 100 && !text.toLowerCase().includes('personnalisez')) {
            groupTitle = text;
            break;
          }
        }

        // Find option links (format: "Name - $0.00" or "Name - $X.XX")
        const optionLinks = Array.from(document.querySelectorAll('a[href="#"], a[href*="menu#"]'))
          .filter(a => {
            const text = a.textContent || '';
            return text.includes(' - $') || text.includes('-$');
          });

        const options = optionLinks.map(link => {
          const text = link.textContent?.trim() || '';
          const parts = text.split(' - ');
          let name = parts[0]?.trim() || 'Option';
          let priceDelta = 0;

          if (parts[1]) {
            const priceMatch = parts[1].replace(',', '.').match(/([+-]?\$?\s*\d+(?:\.\d+)?)/);
            if (priceMatch) {
              const priceStr = priceMatch[1].replace(/[^0-9.-]/g, '');
              priceDelta = parseFloat(priceStr) || 0;
            }
          }

          // Remove trailing price from name if it exists
          name = name.replace(/\s*\$\s*\d+(\.\d+)?$/, '').trim();

          return {
            name,
            priceDelta,
            linkText: text
          };
        });

        // Check if there's a required message
        const requiredHint = document.body.textContent?.includes('il vous plaît') ||
                             document.body.textContent?.includes('Please') ||
                             document.body.textContent?.includes('required');

        return {
          groupName: groupTitle,
          options,
          isRequired: !!requiredHint
        };
      });

      return {
        stepNumber: stepNum,
        groupName: stepData.groupName,
        options: stepData.options,
        isRequired: stepData.isRequired,
        nextButtonEnabled: true
      };
    } catch (error) {
      console.error(`[V1] Error extracting step ${stepNum}:`, error);
      return null;
    }
  }

  private async takeScreenshot(name: string): Promise<void> {
    if (!this.page || !this.config.screenshotsDir) return;

    const filename = `${this.screenshotCounter++}-${name}.png`;
    const filepath = path.join(this.config.screenshotsDir, filename);

    await this.page.screenshot({
      path: filepath,
      fullPage: false
    });

    console.log(`[V1] Screenshot saved: ${filename}`);
  }

  async saveResults(result: ScraperResult): Promise<void> {
    if (!this.config.outputDir) return;

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `${this.config.restaurantName.toLowerCase().replace(/\s+/g, '-')}-${timestamp}.json`;
    const filepath = path.join(this.config.outputDir, filename);

    fs.writeFileSync(filepath, JSON.stringify(result, null, 2), 'utf-8');
    console.log(`\n[V1] Results saved to: ${filepath}`);
  }

  async close(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Example usage
export async function scrapeV1Restaurant(config: ScraperConfig): Promise<ScraperResult> {
  const scraper = new V1Scraper(config);

  try {
    await scraper.initialize();
    const result = await scraper.scrapeMenu(10); // Scrape up to 10 dishes
    await scraper.saveResults(result);

    console.log('\n=== V1 SCRAPE SUMMARY ===');
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