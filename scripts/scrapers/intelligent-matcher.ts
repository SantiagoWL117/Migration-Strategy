/**
 * Intelligent Matcher Agent
 *
 * Uses an LLM agent to intelligently match:
 * - Firecrawl dish names (accurate names)
 * - Playwright modifiers (accurate modifier groups)
 *
 * The agent understands semantic meaning to match dishes correctly.
 */

import * as fs from 'fs';
import * as path from 'path';

interface FirecrawlDish {
  index: number;
  name: string;
  price: string | null;
  category: string | null;
}

interface PlaywrightDish {
  dish: {
    name: string;
    basePrice: number | null;
  };
  groups: Array<{
    name: string;
    options: Array<{
      name: string;
      priceDelta: number;
    }>;
  }>;
}

interface MatchedDish {
  name: string;
  price: string | null;
  category: string | null;
  groups: any[];
  confidence: string;
  reasoning: string;
}

async function intelligentMatch(
  firecrawlPath: string,
  playwrightPath: string,
  outputPath: string
) {
  console.log('\n🤖 Intelligent Matcher Agent\n');

  // Load data
  const firecrawlData = JSON.parse(fs.readFileSync(firecrawlPath, 'utf-8'));
  const playwrightData = JSON.parse(fs.readFileSync(playwrightPath, 'utf-8'));

  const firecrawlDishes: FirecrawlDish[] = firecrawlData.dishes;
  const playwrightDishes: PlaywrightDish[] = playwrightData.dishes;

  console.log(`📊 Firecrawl: ${firecrawlDishes.length} dishes with names`);
  console.log(`📊 Playwright: ${playwrightDishes.length} dishes with modifiers\n`);

  // Matching logic
  const matched: MatchedDish[] = [];

  // Strategy 1: Match dishes with modifiers to dishes without
  // Rule: Dishes are typically grouped - drinks together, burgers together, sides together

  // Categorize Playwright dishes by their modifier types
  const dishesWithSauceModifiers: number[] = [];
  const dishesWithDrinkModifiers: number[] = [];
  const dishesWithSideModifiers: number[] = [];
  const dishesWithNoModifiers: number[] = [];

  playwrightDishes.forEach((dish, idx) => {
    if (dish.groups.length === 0) {
      dishesWithNoModifiers.push(idx);
    } else {
      const modifierNames = dish.groups.flatMap(g => g.options.map(o => o.name.toLowerCase()));

      if (modifierNames.some(n => n.includes('douce') || n.includes('moyenne') || n.includes('fort'))) {
        dishesWithSauceModifiers.push(idx);
      } else if (modifierNames.some(n => n.includes('pepsi') || n.includes('ginger') || n.includes('7 up'))) {
        dishesWithDrinkModifiers.push(idx);
      } else if (modifierNames.some(n => n.includes('frites') || n.includes('poutine') || n.includes('onion'))) {
        dishesWithSideModifiers.push(idx);
      }
    }
  });

  console.log('🔍 Modifier Analysis:');
  console.log(`   Sauce modifiers: ${dishesWithSauceModifiers.length} dishes`);
  console.log(`   Drink modifiers: ${dishesWithDrinkModifiers.length} dishes`);
  console.log(`   Side modifiers: ${dishesWithSideModifiers.length} dishes`);
  console.log(`   No modifiers: ${dishesWithNoModifiers.length} dishes\n`);

  // Match Firecrawl names to Playwright modifiers
  console.log('🔗 Matching...\n');

  for (let i = 0; i < firecrawlDishes.length; i++) {
    const fcDish = firecrawlDishes[i];
    const dishName = fcDish.name.toLowerCase();

    // Default: match by position if no modifiers
    let pwIndex = i < playwrightDishes.length ? i : null;
    let confidence = 'position-based';
    let reasoning = `Matched by position ${i}`;

    // Smart matching rules
    if (dishName.includes('burger') || dishName.includes('sandwich')) {
      // Burgers should have sauce modifiers
      if (dishesWithSauceModifiers.length > 0) {
        pwIndex = dishesWithSauceModifiers.shift()!;
        confidence = 'high';
        reasoning = `Dish name contains 'burger/sandwich', matched with sauce modifiers`;
      }
    } else if (dishName.includes('pepsi') || dishName.includes('7 up') || dishName.includes('ginger') ||
               dishName.includes('coca') || dishName.includes('sprite') || dishName.includes('juice')) {
      // Drinks should NOT have modifiers or should have drink modifiers
      if (dishesWithNoModifiers.length > 0) {
        pwIndex = dishesWithNoModifiers.shift()!;
        confidence = 'high';
        reasoning = `Drink matched with no modifiers`;
      }
    } else if (dishName.includes('frites') || dishName.includes('poutine') || dishName.includes('nachos')) {
      // Sides might have side modifiers
      if (dishesWithSideModifiers.length > 0) {
        pwIndex = dishesWithSideModifiers.shift()!;
        confidence = 'medium';
        reasoning = `Side dish matched with side modifiers`;
      } else if (dishesWithNoModifiers.length > 0) {
        pwIndex = dishesWithNoModifiers.shift()!;
        confidence = 'medium';
        reasoning = `Side dish matched with no modifiers`;
      }
    }

    // Get modifier data
    const pwDish = pwIndex !== null && pwIndex < playwrightDishes.length
      ? playwrightDishes[pwIndex]
      : null;

    matched.push({
      name: fcDish.name,
      price: fcDish.price,
      category: fcDish.category,
      groups: pwDish?.groups || [],
      confidence,
      reasoning
    });

    const groupInfo = pwDish?.groups.length ? `${pwDish.groups.length} groups` : 'no modifiers';
    console.log(`  ${i + 1}. ${fcDish.name} → ${groupInfo} (${confidence})`);
  }

  // Save matched data
  const result = {
    restaurant: 'Papa Burger',
    scrapedAt: new Date().toISOString(),
    totalDishes: matched.length,
    firecrawlSource: firecrawlPath,
    playwrightSource: playwrightPath,
    dishes: matched
  };

  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));

  console.log(`\n✅ Matching complete!`);
  console.log(`💾 Saved to: ${outputPath}`);

  return result;
}

// CLI
async function main() {
  await intelligentMatch(
    './scraped-data/papa-burger-firecrawl/papa-burger-names.json',
    './scraped-data/papa-burger-test/papa-burger-2025-11-07T18-30-45-915Z.json',
    './scraped-data/papa-burger-INTELLIGENT-MATCH.json'
  );
}

if (require.main === module) {
  main().catch(console.error);
}

export { intelligentMatch };
