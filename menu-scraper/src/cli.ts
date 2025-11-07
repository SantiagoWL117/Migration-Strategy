#!/usr/bin/env ts-node
/**
 * Menu.ca Scraper CLI
 *
 * Usage:
 *   npm run scrape papa-burger          # Scrape Papa Burger (headless)
 *   npm run scrape papa-burger --watch  # Scrape with visible browser
 *   npm run scrape --all                # Scrape all configured restaurants
 *   npm run scrape --list               # List all available restaurants
 */

import * as path from 'path';
import { scrapeV1RestaurantSimple } from './scrapers/v1-scraper';
import { getRestaurantConfig, listAllRestaurants } from './config';
import { ScraperResult } from './types';

async function main() {
  const args = process.argv.slice(2);

  // Handle flags
  if (args.includes('--list')) {
    console.log('\n📋 Available restaurants:\n');
    listAllRestaurants().forEach(slug => {
      const config = getRestaurantConfig(slug);
      console.log(`  • ${slug} - ${config?.restaurantName} (${config?.version})`);
    });
    console.log('');
    return;
  }

  if (args.includes('--all')) {
    console.log('\n🚀 Scraping all restaurants...\n');
    const restaurants = listAllRestaurants();
    const results: Record<string, ScraperResult> = {};

    for (const slug of restaurants) {
      console.log(`\n${'='.repeat(60)}`);
      console.log(`Starting: ${slug}`);
      console.log('='.repeat(60));

      try {
        results[slug] = await scrapeRestaurant(slug, args.includes('--watch'));
      } catch (error: any) {
        console.error(`❌ Failed to scrape ${slug}:`, error.message);
        results[slug] = {
          success: false,
          dishes: [],
          errors: [{ error: error.message, timestamp: new Date().toISOString() }],
          summary: { totalDishes: 0, successCount: 0, errorCount: 1, totalGroups: 0, totalOptions: 0 }
        };
      }
    }

    // Print summary
    console.log('\n\n' + '='.repeat(60));
    console.log('📊 SCRAPING SUMMARY');
    console.log('='.repeat(60));

    let totalSuccess = 0;
    let totalFailed = 0;

    Object.entries(results).forEach(([slug, result]) => {
      if (result.success) {
        console.log(`✅ ${slug}: ${result.summary.successCount}/${result.summary.totalDishes} dishes`);
        totalSuccess++;
      } else {
        console.log(`❌ ${slug}: FAILED`);
        totalFailed++;
      }
    });

    console.log('\n' + '='.repeat(60));
    console.log(`Total: ${totalSuccess} succeeded, ${totalFailed} failed`);
    console.log('='.repeat(60) + '\n');

    return;
  }

  // Scrape single restaurant
  const slug = args[0];
  if (!slug) {
    console.error('❌ Error: Please provide a restaurant slug\n');
    console.log('Usage:');
    console.log('  npm run scrape <slug>           # Scrape a restaurant');
    console.log('  npm run scrape <slug> --watch   # Scrape with visible browser');
    console.log('  npm run scrape --list           # List available restaurants');
    console.log('  npm run scrape --all            # Scrape all restaurants\n');
    process.exit(1);
  }

  await scrapeRestaurant(slug, args.includes('--watch'));
}

async function scrapeRestaurant(slug: string, visible: boolean = false): Promise<ScraperResult> {
  const config = getRestaurantConfig(slug);

  if (!config) {
    throw new Error(`Restaurant '${slug}' not found. Run 'npm run scrape --list' to see available restaurants.`);
  }

  console.log(`\n🍔 Scraping: ${config.restaurantName}`);
  console.log(`🔗 URL: ${config.baseUrl}`);
  console.log(`📦 Version: ${config.version}`);
  console.log(`👁️  Headless: ${!visible}\n`);

  if (config.version === 'v1') {
    const result = await scrapeV1RestaurantSimple({
      ...config,
      headless: !visible,
      screenshotsDir: path.join(__dirname, '..', 'screenshots', slug),
      outputDir: path.join(__dirname, '..', 'output', slug)
    });

    console.log('\n✅ Done!');
    console.log(`📁 Output: ./output/${slug}/`);
    console.log(`📸 Screenshots: ./screenshots/${slug}/\n`);

    return result;
  } else {
    throw new Error('V2 scraper not implemented yet');
  }
}

// Run CLI
main().catch(error => {
  console.error('\n❌ Fatal error:', error.message);
  process.exit(1);
});
