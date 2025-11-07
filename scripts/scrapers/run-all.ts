/**
 * Main scraper runner - scrapes all configured restaurants
 * Outputs JSON files for validation before DB import
 */

import { scrapeV1Restaurant } from './v1-scraper';
import { scrapeV2Restaurant } from './v2-scraper';
import { RESTAURANTS, RestaurantConfig } from './restaurants-config';
import { ScraperResult } from './types';
import * as fs from 'fs';
import * as path from 'path';

interface ScrapeSession {
  startTime: string;
  endTime?: string;
  totalRestaurants: number;
  results: Array<{
    restaurantId: string;
    restaurantName: string;
    version: 'v1' | 'v2';
    success: boolean;
    dishCount: number;
    groupCount: number;
    optionCount: number;
    errorCount: number;
    outputFile: string;
    duration?: number;
  }>;
  summary: {
    successCount: number;
    failureCount: number;
    totalDishes: number;
    totalGroups: number;
    totalOptions: number;
  };
}

async function scrapeRestaurant(config: RestaurantConfig): Promise<ScrapeSession['results'][0]> {
  const startTime = Date.now();
  console.log(`\n${'='.repeat(80)}`);
  console.log(`SCRAPING: ${config.name} (${config.version.toUpperCase()})`);
  console.log(`URL: ${config.baseUrl}`);
  console.log(`${'='.repeat(80)}`);

  try {
    let result: ScraperResult;

    if (config.version === 'v1') {
      result = await scrapeV1Restaurant({
        restaurantName: config.name,
        baseUrl: config.baseUrl,
        version: 'v1',
        headless: true,
        screenshotsDir: `./screenshots/${config.id}`,
        outputDir: `./scraped-data/${config.id}`
      });
    } else {
      result = await scrapeV2Restaurant({
        restaurantName: config.name,
        baseUrl: config.baseUrl,
        version: 'v2',
        headless: true,
        screenshotsDir: `./screenshots/${config.id}`,
        outputDir: `./scraped-data/${config.id}`
      }, config.dishLimit || 10);
    }

    const duration = Date.now() - startTime;

    return {
      restaurantId: config.id,
      restaurantName: config.name,
      version: config.version,
      success: result.success,
      dishCount: result.summary.successCount,
      groupCount: result.summary.totalGroups,
      optionCount: result.summary.totalOptions,
      errorCount: result.summary.errorCount,
      outputFile: `./scraped-data/${config.id}/${config.id}-latest.json`,
      duration
    };
  } catch (error: any) {
    const duration = Date.now() - startTime;
    console.error(`\n❌ FATAL ERROR scraping ${config.name}:`, error.message);

    return {
      restaurantId: config.id,
      restaurantName: config.name,
      version: config.version,
      success: false,
      dishCount: 0,
      groupCount: 0,
      optionCount: 0,
      errorCount: 1,
      outputFile: '',
      duration
    };
  }
}

async function runAllScrapers(restaurantIds?: string[]): Promise<void> {
  const session: ScrapeSession = {
    startTime: new Date().toISOString(),
    totalRestaurants: 0,
    results: [],
    summary: {
      successCount: 0,
      failureCount: 0,
      totalDishes: 0,
      totalGroups: 0,
      totalOptions: 0
    }
  };

  // Filter restaurants if IDs provided
  let restaurantsToScrape = RESTAURANTS;
  if (restaurantIds && restaurantIds.length > 0) {
    restaurantsToScrape = RESTAURANTS.filter(r => restaurantIds.includes(r.id));
    console.log(`\nFiltered to ${restaurantsToScrape.length} restaurant(s): ${restaurantIds.join(', ')}`);
  }

  session.totalRestaurants = restaurantsToScrape.length;

  console.log(`\n🚀 STARTING SCRAPE SESSION`);
  console.log(`Total Restaurants: ${session.totalRestaurants}`);
  console.log(`Start Time: ${session.startTime}\n`);

  // Scrape each restaurant sequentially
  for (let i = 0; i < restaurantsToScrape.length; i++) {
    const config = restaurantsToScrape[i];
    console.log(`\n[${i + 1}/${restaurantsToScrape.length}] Processing: ${config.name}`);

    const result = await scrapeRestaurant(config);
    session.results.push(result);

    // Update summary
    if (result.success) {
      session.summary.successCount++;
    } else {
      session.summary.failureCount++;
    }
    session.summary.totalDishes += result.dishCount;
    session.summary.totalGroups += result.groupCount;
    session.summary.totalOptions += result.optionCount;

    // Brief pause between restaurants
    if (i < restaurantsToScrape.length - 1) {
      console.log('\n⏳ Waiting 3 seconds before next restaurant...');
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }

  session.endTime = new Date().toISOString();

  // Save session report
  const reportDir = './scraped-data';
  fs.mkdirSync(reportDir, { recursive: true });

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const reportPath = path.join(reportDir, `scrape-session-${timestamp}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(session, null, 2), 'utf-8');

  // Print final report
  printFinalReport(session, reportPath);
}

function printFinalReport(session: ScrapeSession, reportPath: string): void {
  console.log(`\n${'='.repeat(80)}`);
  console.log('🎉 SCRAPE SESSION COMPLETE');
  console.log(`${'='.repeat(80)}`);
  console.log(`\nStart Time:  ${session.startTime}`);
  console.log(`End Time:    ${session.endTime}`);

  const startMs = new Date(session.startTime).getTime();
  const endMs = new Date(session.endTime!).getTime();
  const durationSec = Math.round((endMs - startMs) / 1000);
  const durationMin = Math.floor(durationSec / 60);
  const durationSecRem = durationSec % 60;
  console.log(`Duration:    ${durationMin}m ${durationSecRem}s`);

  console.log(`\n📊 SUMMARY`);
  console.log(`${'─'.repeat(80)}`);
  console.log(`Total Restaurants: ${session.totalRestaurants}`);
  console.log(`✅ Successful:     ${session.summary.successCount}`);
  console.log(`❌ Failed:         ${session.summary.failureCount}`);
  console.log(`\n📦 Data Collected:`);
  console.log(`   Dishes:         ${session.summary.totalDishes}`);
  console.log(`   Modifier Groups: ${session.summary.totalGroups}`);
  console.log(`   Modifier Options: ${session.summary.totalOptions}`);

  console.log(`\n📋 DETAILED RESULTS`);
  console.log(`${'─'.repeat(80)}`);

  session.results.forEach((r, idx) => {
    const status = r.success ? '✅' : '❌';
    const durationSec = r.duration ? `${(r.duration / 1000).toFixed(1)}s` : 'N/A';
    console.log(`${idx + 1}. ${status} ${r.restaurantName} (${r.version})`);
    console.log(`   Dishes: ${r.dishCount}, Groups: ${r.groupCount}, Options: ${r.optionCount}`);
    console.log(`   Duration: ${durationSec}, Errors: ${r.errorCount}`);
    if (r.outputFile) {
      console.log(`   Output: ${r.outputFile}`);
    }
  });

  console.log(`\n📄 Full session report saved to:`);
  console.log(`   ${reportPath}`);

  console.log(`\n${'='.repeat(80)}`);
  console.log(`✨ Next Steps:`);
  console.log(`   1. Review JSON files in ./scraped-data/`);
  console.log(`   2. Compare with live sites to validate accuracy`);
  console.log(`   3. Run: npm run validate-scraped-data`);
  console.log(`   4. If valid, run: npm run import-to-supabase`);
  console.log(`${'='.repeat(80)}\n`);
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
Menu Scraper - All Restaurants

Usage:
  npm run scrape-all              Scrape all ${RESTAURANTS.length} configured restaurants
  npm run scrape-all -- <id> ...  Scrape specific restaurant(s) by ID

Examples:
  npm run scrape-all
  npm run scrape-all -- papa-burger parea-greek

Options:
  --help, -h    Show this help message

Restaurant IDs:
${RESTAURANTS.map(r => `  - ${r.id} (${r.name}, ${r.version})`).join('\n')}
    `);
    process.exit(0);
  }

  // Extract restaurant IDs if provided
  const restaurantIds = args.filter(arg => !arg.startsWith('--'));

  await runAllScrapers(restaurantIds.length > 0 ? restaurantIds : undefined);
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export { runAllScrapers, scrapeRestaurant };
