/**
 * Supabase Importer - Loads validated JSON data into Supabase
 * Works with MCP for direct database access
 */

import * as fs from 'fs';
import * as path from 'path';
import { ScraperResult, ScrapedDish, ModifierGroup, ModifierOption } from '../scrapers/types';

interface ImportConfig {
  projectId?: string; // Supabase project ID (from env or MCP)
  dryRun?: boolean;   // If true, generate SQL without executing
  outputSql?: boolean; // If true, save SQL to file
}

interface ImportResult {
  restaurantId: string;
  restaurantName: string;
  success: boolean;
  imported: {
    dishes: number;
    groups: number;
    options: number;
    assignments: number;
  };
  errors: Array<{
    message: string;
    context?: any;
  }>;
}

class SupabaseImporter {
  private scrapedDataDir = './scraped-data';
  private sqlOutputDir = './sql-generated';
  private config: ImportConfig;

  constructor(config: ImportConfig = {}) {
    this.config = {
      dryRun: false,
      outputSql: true,
      ...config
    };

    if (this.config.outputSql) {
      fs.mkdirSync(this.sqlOutputDir, { recursive: true });
    }
  }

  async importAll(): Promise<ImportResult[]> {
    const results: ImportResult[] = [];

    // Find all restaurant JSON files
    const restaurantDirs = fs.readdirSync(this.scrapedDataDir, { withFileTypes: true })
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name);

    console.log(`\n🚀 Starting import for ${restaurantDirs.length} restaurants\n`);

    for (const restaurantId of restaurantDirs) {
      const result = await this.importRestaurant(restaurantId);
      results.push(result);
      this.printImportResult(result);
    }

    this.printSummary(results);
    return results;
  }

  async importRestaurant(restaurantId: string): Promise<ImportResult> {
    const result: ImportResult = {
      restaurantId,
      restaurantName: '',
      success: true,
      imported: {
        dishes: 0,
        groups: 0,
        options: 0,
        assignments: 0
      },
      errors: []
    };

    // Find latest JSON file
    const restaurantDir = path.join(this.scrapedDataDir, restaurantId);
    if (!fs.existsSync(restaurantDir)) {
      result.success = false;
      result.errors.push({ message: 'Restaurant directory not found' });
      return result;
    }

    const jsonFiles = fs.readdirSync(restaurantDir)
      .filter(f => f.endsWith('.json'))
      .map(f => ({
        name: f,
        path: path.join(restaurantDir, f),
        mtime: fs.statSync(path.join(restaurantDir, f)).mtime
      }))
      .sort((a, b) => b.mtime.getTime() - a.mtime.getTime());

    if (jsonFiles.length === 0) {
      result.success = false;
      result.errors.push({ message: 'No JSON files found' });
      return result;
    }

    // Load data
    let scrapedData: ScraperResult;
    try {
      const fileContent = fs.readFileSync(jsonFiles[0].path, 'utf-8');
      scrapedData = JSON.parse(fileContent);
    } catch (error: any) {
      result.success = false;
      result.errors.push({ message: `Failed to parse JSON: ${error.message}` });
      return result;
    }

    if (scrapedData.dishes.length === 0) {
      result.success = false;
      result.errors.push({ message: 'No dishes to import' });
      return result;
    }

    result.restaurantName = scrapedData.dishes[0].restaurant;

    // Generate SQL for this restaurant
    const sql = this.generateImportSQL(scrapedData, result);

    if (this.config.outputSql) {
      const sqlFilePath = path.join(this.sqlOutputDir, `${restaurantId}-import.sql`);
      fs.writeFileSync(sqlFilePath, sql, 'utf-8');
      console.log(`   💾 SQL saved to: ${sqlFilePath}`);
    }

    if (!this.config.dryRun) {
      // TODO: Execute SQL via MCP or Supabase client
      console.log(`   ⚠️  Auto-execution not implemented yet.`);
      console.log(`   📋 Use MCP agent or run SQL manually from ${this.sqlOutputDir}`);
    }

    return result;
  }

  private generateImportSQL(data: ScraperResult, result: ImportResult): string {
    const lines: string[] = [];

    lines.push('-- ============================================================');
    lines.push(`-- Import for: ${data.dishes[0].restaurant}`);
    lines.push(`-- Generated: ${new Date().toISOString()}`);
    lines.push(`-- Dishes: ${data.dishes.length}`);
    lines.push('-- ============================================================\n');

    lines.push('BEGIN;\n');

    // For each dish
    for (const dish of data.dishes) {
      lines.push(`-- Dish: ${dish.dish.name}`);
      lines.push(`-- Base Price: $${dish.dish.basePrice || 0}`);
      lines.push(`-- Groups: ${dish.groups.length}\n`);

      // 1. Find or get restaurant_id
      const restaurantUrl = dish.restaurantUrl;
      lines.push(`-- Get restaurant ID (assumes restaurant already exists in menuca_v3.restaurants)`);
      lines.push(`DO $$`);
      lines.push(`DECLARE`);
      lines.push(`  v_restaurant_id INTEGER;`);
      lines.push(`  v_dish_id BIGINT;`);
      lines.push(`BEGIN`);
      lines.push(`  -- Find restaurant by URL or name`);
      lines.push(`  SELECT id INTO v_restaurant_id`);
      lines.push(`  FROM menuca_v3.restaurants`);
      lines.push(`  WHERE website = '${this.escapeSql(restaurantUrl)}'`);
      lines.push(`     OR name ILIKE '%${this.escapeSql(dish.restaurant)}%'`);
      lines.push(`  LIMIT 1;`);
      lines.push(``);
      lines.push(`  IF v_restaurant_id IS NULL THEN`);
      lines.push(`    RAISE EXCEPTION 'Restaurant not found: ${this.escapeSql(dish.restaurant)}';`);
      lines.push(`  END IF;`);
      lines.push(``);

      // 2. Find or create dish
      lines.push(`  -- Find or create dish`);
      lines.push(`  SELECT id INTO v_dish_id`);
      lines.push(`  FROM menuca_v3.dishes`);
      lines.push(`  WHERE restaurant_id = v_restaurant_id`);
      lines.push(`    AND name = '${this.escapeSql(dish.dish.name)}'`);
      lines.push(`  LIMIT 1;`);
      lines.push(``);
      lines.push(`  IF v_dish_id IS NULL THEN`);
      lines.push(`    INSERT INTO menuca_v3.dishes (restaurant_id, name, description, base_price, is_active)`);
      lines.push(`    VALUES (`);
      lines.push(`      v_restaurant_id,`);
      lines.push(`      '${this.escapeSql(dish.dish.name)}',`);
      lines.push(`      ${dish.dish.description ? `'${this.escapeSql(dish.dish.description)}'` : 'NULL'},`);
      lines.push(`      ${dish.dish.basePrice || 0},`);
      lines.push(`      TRUE`);
      lines.push(`    )`);
      lines.push(`    RETURNING id INTO v_dish_id;`);
      lines.push(`  END IF;`);
      lines.push(``);

      result.imported.dishes++;

      // 3. For each modifier group
      for (let gIdx = 0; gIdx < dish.groups.length; gIdx++) {
        const group = dish.groups[gIdx];
        const groupVarName = `v_group_${gIdx}_id`;

        lines.push(`  -- Group ${gIdx + 1}: ${group.name}`);
        lines.push(`  DECLARE ${groupVarName} BIGINT;`);
        lines.push(`  BEGIN`);
        lines.push(`    -- Find or create modifier group`);
        lines.push(`    SELECT id INTO ${groupVarName}`);
        lines.push(`    FROM menuca_v3.modifier_groups`);
        lines.push(`    WHERE restaurant_id = v_restaurant_id`);
        lines.push(`      AND name = '${this.escapeSql(group.name)}'`);
        lines.push(`    LIMIT 1;`);
        lines.push(``);
        lines.push(`    IF ${groupVarName} IS NULL THEN`);
        lines.push(`      INSERT INTO menuca_v3.modifier_groups (`);
        lines.push(`        restaurant_id, name, description, select_type, min_selections,`);
        lines.push(`        max_selections, is_required, display_order`);
        lines.push(`      ) VALUES (`);
        lines.push(`        v_restaurant_id,`);
        lines.push(`        '${this.escapeSql(group.name)}',`);
        lines.push(`        ${group.description ? `'${this.escapeSql(group.description)}'` : 'NULL'},`);
        lines.push(`        '${group.selectType}',`);
        lines.push(`        ${group.minSelections},`);
        lines.push(`        ${group.maxSelections !== null ? group.maxSelections : 'NULL'},`);
        lines.push(`        ${group.isRequired},`);
        lines.push(`        ${group.displayOrder}`);
        lines.push(`      )`);
        lines.push(`      RETURNING id INTO ${groupVarName};`);
        lines.push(`    END IF;`);
        lines.push(``);

        result.imported.groups++;

        // 4. For each option in this group
        for (let oIdx = 0; oIdx < group.options.length; oIdx++) {
          const option = group.options[oIdx];

          lines.push(`    -- Option ${oIdx + 1}: ${option.name}`);
          lines.push(`    INSERT INTO menuca_v3.modifier_options (`);
          lines.push(`      group_id, name, description, price_delta, is_default, display_order`);
          lines.push(`    ) VALUES (`);
          lines.push(`      ${groupVarName},`);
          lines.push(`      '${this.escapeSql(option.name)}',`);
          lines.push(`      ${option.description ? `'${this.escapeSql(option.description)}'` : 'NULL'},`);
          lines.push(`      ${option.priceDelta || 0},`);
          lines.push(`      ${option.isDefault || false},`);
          lines.push(`      ${oIdx}`);
          lines.push(`    )`);
          lines.push(`    ON CONFLICT (group_id, name) DO UPDATE`);
          lines.push(`    SET price_delta = EXCLUDED.price_delta,`);
          lines.push(`        is_default = EXCLUDED.is_default;`);
          lines.push(``);

          result.imported.options++;
        }

        // 5. Create assignment (link group to dish)
        lines.push(`    -- Assign group to dish`);
        lines.push(`    INSERT INTO menuca_v3.modifier_group_assignments (`);
        lines.push(`      restaurant_id, group_id, dish_id, is_required, step_order, display_order`);
        lines.push(`    ) VALUES (`);
        lines.push(`      v_restaurant_id,`);
        lines.push(`      ${groupVarName},`);
        lines.push(`      v_dish_id,`);
        lines.push(`      ${group.isRequired},`);
        lines.push(`      ${group.stepOrder !== undefined ? group.stepOrder : 'NULL'},`);
        lines.push(`      ${group.displayOrder}`);
        lines.push(`    )`);
        lines.push(`    ON CONFLICT (group_id, restaurant_id, dish_id, course_id) DO UPDATE`);
        lines.push(`    SET is_required = EXCLUDED.is_required,`);
        lines.push(`        step_order = EXCLUDED.step_order,`);
        lines.push(`        display_order = EXCLUDED.display_order;`);
        lines.push(``);

        result.imported.assignments++;

        lines.push(`  END;`);
        lines.push(``);
      }

      lines.push(`END $$;\n`);
      lines.push('');
    }

    lines.push('COMMIT;\n');

    lines.push('-- ============================================================');
    lines.push('-- Import Summary:');
    lines.push(`--   Dishes: ${result.imported.dishes}`);
    lines.push(`--   Groups: ${result.imported.groups}`);
    lines.push(`--   Options: ${result.imported.options}`);
    lines.push(`--   Assignments: ${result.imported.assignments}`);
    lines.push('-- ============================================================');

    return lines.join('\n');
  }

  private escapeSql(str: string): string {
    if (!str) return '';
    return str.replace(/'/g, "''");
  }

  private printImportResult(result: ImportResult): void {
    const status = result.success ? '✅' : '❌';
    console.log(`${status} ${result.restaurantName} (${result.restaurantId})`);
    console.log(`   Dishes: ${result.imported.dishes}, Groups: ${result.imported.groups}, Options: ${result.imported.options}`);

    if (result.errors.length > 0) {
      result.errors.forEach(err => {
        console.log(`      ❌ ${err.message}`);
      });
    }

    console.log('');
  }

  private printSummary(results: ImportResult[]): void {
    const successCount = results.filter(r => r.success).length;
    const failCount = results.filter(r => !r.success).length;
    const totalDishes = results.reduce((sum, r) => sum + r.imported.dishes, 0);
    const totalGroups = results.reduce((sum, r) => sum + r.imported.groups, 0);
    const totalOptions = results.reduce((sum, r) => sum + r.imported.options, 0);

    console.log(`${'='.repeat(80)}`);
    console.log('📊 IMPORT SUMMARY');
    console.log(`${'='.repeat(80)}`);
    console.log(`Total Restaurants: ${results.length}`);
    console.log(`✅ Successful:     ${successCount}`);
    console.log(`❌ Failed:         ${failCount}`);
    console.log(`\n📦 SQL Generated for:`);
    console.log(`   Dishes:         ${totalDishes}`);
    console.log(`   Modifier Groups: ${totalGroups}`);
    console.log(`   Modifier Options: ${totalOptions}`);

    if (this.config.dryRun) {
      console.log(`\n⚠️  DRY RUN MODE - No data was written to database`);
    }

    console.log(`\n📄 SQL files saved to: ${this.sqlOutputDir}/`);
    console.log(`\n✨ Next Steps:`);
    console.log(`   1. Review generated SQL files in ${this.sqlOutputDir}/`);
    console.log(`   2. Use MCP agent to execute SQL with Supabase connection`);
    console.log(`   3. Or manually run via Supabase SQL editor`);
    console.log(`${'='.repeat(80)}\n`);
  }
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes('--dry-run');

  console.log(`\n🗄️  Supabase Import Tool`);
  console.log(`Mode: ${dryRun ? 'DRY RUN (SQL only)' : 'GENERATE SQL'}\n`);

  const importer = new SupabaseImporter({
    dryRun,
    outputSql: true
  });

  await importer.importAll();
}

if (require.main === module) {
  main().catch(error => {
    console.error('Import failed:', error);
    process.exit(1);
  });
}

export { SupabaseImporter, ImportResult };
