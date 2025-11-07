/**
 * Quick test script to scrape a single dish and see the output
 * Useful for debugging and understanding the data structure
 */

import { scrapeV1Restaurant } from './v1-scraper';
import { V2Scraper } from './v2-scraper';

// ============================================================================
// TEST V1 (Papa Burger)
// ============================================================================
async function testV1() {
  console.log('\n🧪 Testing V1 Scraper (Papa Burger)\n');

  const result = await scrapeV1Restaurant({
    restaurantName: 'Papa Burger TEST',
    baseUrl: 'https://papaburger.ca/?p=menu',
    version: 'v1',
    headless: false, // Set to true to hide browser
    screenshotsDir: './screenshots/test-v1',
    outputDir: './scraped-data/test-v1'
  });

  // Show first dish in detail
  if (result.dishes.length > 0) {
    const dish = result.dishes[0];
    console.log('\n📋 First Dish Details:\n');
    console.log(JSON.stringify(dish, null, 2));

    console.log('\n\n🔍 Summary:');
    console.log(`Dish: ${dish.dish.name}`);
    console.log(`Base Price: $${dish.dish.basePrice}`);
    console.log(`Modifier Groups: ${dish.groups.length}`);

    dish.groups.forEach((group, idx) => {
      console.log(`\n  Group ${idx + 1}: ${group.name}`);
      console.log(`  - Type: ${group.selectType}`);
      console.log(`  - Required: ${group.isRequired}`);
      console.log(`  - Min/Max: ${group.minSelections}/${group.maxSelections}`);
      console.log(`  - Options (${group.options.length}):`);

      group.options.forEach(opt => {
        const priceStr = opt.priceDelta === 0 ? 'FREE' : `+$${opt.priceDelta.toFixed(2)}`;
        console.log(`    • ${opt.name} (${priceStr})`);
      });
    });
  }

  return result;
}

// ============================================================================
// TEST V2 (Paréa)
// ============================================================================
async function testV2() {
  console.log('\n🧪 Testing V2 Scraper (Paréa)\n');

  const scraper = new V2Scraper({
    restaurantName: 'Paréa TEST',
    baseUrl: 'https://ordereast.eatparea.com/index.php/menu',
    version: 'v2',
    headless: false, // Set to true to hide browser
    screenshotsDir: './screenshots/test-v2',
    outputDir: './scraped-data/test-v2'
  });

  await scraper.initialize();

  // Test with one specific dish
  const testDishUrls = [
    'https://ordereast.eatparea.com/index.php/dish/create/10917/0' // Pork Gyro Pita - Regular
  ];

  const result = await scraper.scrapeMenu(testDishUrls);
  await scraper.saveResults(result);
  await scraper.close();

  // Show first dish in detail
  if (result.dishes.length > 0) {
    const dish = result.dishes[0];
    console.log('\n📋 First Dish Details:\n');
    console.log(JSON.stringify(dish, null, 2));

    console.log('\n\n🔍 Summary:');
    console.log(`Dish: ${dish.dish.name}`);
    console.log(`Base Price: $${dish.dish.basePrice}`);
    console.log(`Modifier Groups: ${dish.groups.length}`);

    dish.groups.forEach((group, idx) => {
      console.log(`\n  Group ${idx + 1}: ${group.name}`);
      console.log(`  - Type: ${group.selectType}`);
      console.log(`  - Required: ${group.isRequired}`);
      console.log(`  - Min/Max: ${group.minSelections}/${group.maxSelections}`);
      console.log(`  - Options (${group.options.length}):`);

      group.options.forEach(opt => {
        const priceStr = opt.priceDelta === 0 ? 'FREE' : `+$${opt.priceDelta.toFixed(2)}`;
        console.log(`    • ${opt.name} (${priceStr})`);
      });
    });
  }

  return result;
}

// ============================================================================
// MAIN
// ============================================================================
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--v2')) {
    await testV2();
  } else if (args.includes('--both')) {
    await testV1();
    console.log('\n' + '='.repeat(80) + '\n');
    await testV2();
  } else {
    // Default: test V1
    await testV1();
  }

  console.log('\n✅ Test complete!');
  console.log('\nTo test different versions:');
  console.log('  npm run test-scraper          # V1 only (default)');
  console.log('  npm run test-scraper -- --v2  # V2 only');
  console.log('  npm run test-scraper -- --both # Both V1 and V2');
}

if (require.main === module) {
  main().catch(error => {
    console.error('\n❌ Test failed:', error);
    process.exit(1);
  });
}
