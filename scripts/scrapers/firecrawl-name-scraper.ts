/**
 * Firecrawl Name Scraper - Get dish names using Firecrawl
 */

import FirecrawlApp from '@mendable/firecrawl-js';
import * as fs from 'fs';
import * as path from 'path';

interface DishName {
  index: number;
  name: string;
  description: string | null;
  price: string | null;
  category: string | null;
}

async function scrapeNamesWithFirecrawl(url: string, restaurantName: string, outputDir: string = './scraped-data/firecrawl') {
  console.log('\n🔥 Firecrawl Name Scraper\n');
  console.log(`Restaurant: ${restaurantName}`);
  console.log(`URL: ${url}\n`);

  fs.mkdirSync(outputDir, { recursive: true });

  const firecrawl = new FirecrawlApp({ apiKey: 'fc-ac838657c3104fb78ac162ef8792fc97' });

  try {
    console.log('🕷️  Scraping with Firecrawl...');
    const result = await firecrawl.scrape(url, {
      formats: ['markdown'],
      waitFor: 3000
    });

    if (!result.markdown) {
      throw new Error('No markdown content returned');
    }

    console.log(`✅ Got ${result.markdown.length} characters of content\n`);

    // Save raw markdown
    const mdPath = path.join(outputDir, `${restaurantName.toLowerCase().replace(/\s+/g, '-')}-raw.md`);
    fs.writeFileSync(mdPath, result.markdown);
    console.log(`💾 Saved raw markdown to: ${mdPath}\n`);

    // Parse dish names from markdown
    console.log('📝 Parsing dish names...\n');
    const dishes: DishName[] = [];
    const lines = result.markdown.split('\n');

    let currentCategory: string | null = null;
    let potentialDishName: string | null = null;
    let potentialDescription: string | null = null;
    let dishIndex = 0;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Skip empty lines and navigation
      if (!line || line === 'Haut' || line.includes('![')) {
        continue;
      }

      // Detect category headers (headers appear after "Haut" or at start)
      const prevLine = i > 0 ? lines[i - 1].trim() : '';
      const nextLine = i < lines.length - 1 ? lines[i + 1].trim() : '';

      // Category detection: standalone text line followed by a dish name
      if (line.length > 3 && line.length < 50 &&
          !line.includes('$') && !line.includes('|') && !line.match(/^-+/) &&
          !line.includes('Burger Original') && !line.includes('Frites') &&
          (prevLine === 'Haut' || prevLine === '' || i === 31)) {
        // Check if next non-empty line looks like a dish name (not a description)
        let j = i + 1;
        while (j < lines.length && !lines[j].trim()) j++;
        const potentialNext = lines[j]?.trim() || '';

        // If next line is short and doesn't start with description patterns
        if (potentialNext.length > 0 && potentialNext.length < 60 &&
            !potentialNext.includes('Burger Original') &&
            !potentialNext.includes('Avec frites')) {
          currentCategory = line;
          console.log(`\n📁 ${currentCategory}`);
          continue;
        }
      }

      // Check if this is an order button line (has price)
      const isMenuItem = line.includes('Choisissez cet item') || line.includes('order.png');

      // Potential dish name or description: non-table line that's not too long
      if (!isMenuItem && !line.match(/^\|/) && !line.match(/^-+/) &&
          !line.includes('$') && line.length > 2 && line.length < 200) {

        // Check if next line is a table with order button (indicates this is dish-related)
        const nextIsTable = nextLine.match(/^\|/) || nextLine.includes('order.png');
        const nextNextLine = i < lines.length - 2 ? lines[i + 2].trim() : '';
        const nextNextIsTable = nextNextLine.match(/^\|/) || nextNextLine.includes('order.png');

        if (nextIsTable) {
          // Next line is price table - this is dish name
          potentialDishName = line;
          potentialDescription = null;
        } else if (nextNextIsTable && potentialDishName === null) {
          // Two lines before table - first is name, second will be description
          potentialDishName = line;
        } else if (nextNextIsTable && potentialDishName !== null) {
          // Second line before table - this is description
          potentialDescription = line;
        }
        continue;
      }

      // Look for price in table format
      if (isMenuItem && line.includes('$')) {
        const priceMatch = line.match(/\$\s*(\d+[.,]\d{2})/);

        if (priceMatch && potentialDishName) {
          // Check for size variant
          const sizeMatch = line.match(/\|\s*»\s*([^|$]+?)\s*\|/);

          let finalDishName: string;
          let finalDescription: string | null = potentialDescription;

          if (sizeMatch && sizeMatch[1].trim()) {
            // Has size variant - use potential name
            finalDishName = `${potentialDishName} (${sizeMatch[1].trim()})`;
          } else {
            // No size variant
            finalDishName = potentialDishName;
            potentialDishName = null; // Clear after use
            potentialDescription = null;
          }

          dishes.push({
            index: dishIndex++,
            name: finalDishName,
            description: finalDescription,
            price: priceMatch[1],
            category: currentCategory
          });

          console.log(`  ${dishIndex}. ${finalDishName} - $${priceMatch[1]}`);
        }
      }
    }

    console.log(`\n✅ Found ${dishes.length} dishes\n`);

    // Save parsed dishes
    const jsonPath = path.join(outputDir, `${restaurantName.toLowerCase().replace(/\s+/g, '-')}-names.json`);
    fs.writeFileSync(jsonPath, JSON.stringify({
      restaurant: restaurantName,
      url,
      scrapedAt: new Date().toISOString(),
      totalDishes: dishes.length,
      dishes
    }, null, 2));

    console.log(`💾 Saved dish names to: ${jsonPath}`);

    return {
      success: true,
      totalDishes: dishes.length,
      dishes,
      outputPath: jsonPath
    };

  } catch (error: any) {
    console.error('❌ Firecrawl error:', error.message);
    return {
      success: false,
      totalDishes: 0,
      dishes: [],
      error: error.message
    };
  }
}

// CLI
async function main() {
  const result = await scrapeNamesWithFirecrawl(
    'https://papaburger.ca/?p=menu',
    'Papa Burger',
    './scraped-data/papa-burger-firecrawl'
  );

  if (result.success) {
    console.log('\n🎉 Done!');
  } else {
    console.error('\n❌ Failed:', result.error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { scrapeNamesWithFirecrawl };
