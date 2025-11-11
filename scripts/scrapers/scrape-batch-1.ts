/**
 * Scrape first batch of 3 restaurants in parallel
 *
 * 1. Parea East (ordereast.eatparea.com)
 * 2. Parea West (orderwest.eatparea.com)
 * 3. Pizza Marie (pizzamaisonneuve.com) - Note: URL might be wrong
 */

import { scrapeV2Restaurant } from '../../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🚀 Starting parallel scrape of 3 restaurants\n');

  const startTime = Date.now();

  // Run all 3 scrapers in parallel
  const results = await Promise.allSettled([
    // 1. Parea East
    scrapeV2Restaurant({
      restaurantName: 'Parea East',
      baseUrl: 'https://ordereast.eatparea.com/index.php/menu',
      version: 'v2',
      headless: true, // Run headless for faster performance
      screenshotsDir: './screenshots/parea-east',
      outputDir: './scraped-data/parea-east'
    }),

    // 2. Parea West
    scrapeV2Restaurant({
      restaurantName: 'Parea West',
      baseUrl: 'https://orderwest.eatparea.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/parea-west',
      outputDir: './scraped-data/parea-west'
    }),

    // 3. Pizza Marie (URL might be wrong)
    scrapeV2Restaurant({
      restaurantName: 'Pizza Marie',
      baseUrl: 'https://pizzamaisonneuve.com/?p=menu&lang=fr',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/pizza-marie',
      outputDir: './scraped-data/pizza-marie'
    })
  ]);

  const endTime = Date.now();
  const totalTime = ((endTime - startTime) / 1000 / 60).toFixed(2);

  console.log('\n' + '='.repeat(60));
  console.log('BATCH SCRAPE COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total time: ${totalTime} minutes\n`);

  // Print results for each restaurant
  results.forEach((result, idx) => {
    const names = ['Parea East', 'Parea West', 'Pizza Marie'];
    console.log(`\n${idx + 1}. ${names[idx]}:`);

    if (result.status === 'fulfilled') {
      const { summary } = result.value;
      console.log(`   ✅ Success: ${summary.successCount}/${summary.totalDishes} dishes`);
      console.log(`   📊 Groups: ${summary.totalGroups}, Options: ${summary.totalOptions}`);
      if (summary.errorCount > 0) {
        console.log(`   ⚠️  Errors: ${summary.errorCount}`);
      }
    } else {
      console.log(`   ❌ Failed: ${result.reason}`);
    }
  });

  console.log('\n' + '='.repeat(60) + '\n');

  // Check if any failed
  const failedCount = results.filter(r => r.status === 'rejected').length;
  if (failedCount > 0) {
    console.log(`⚠️  ${failedCount} restaurant(s) failed to scrape`);
    process.exit(1);
  } else {
    console.log('✅ All restaurants scraped successfully!');
  }
}

main().catch(error => {
  console.error('Batch scrape failed:', error);
  process.exit(1);
});
