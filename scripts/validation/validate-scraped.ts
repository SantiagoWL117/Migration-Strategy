/**
 * Validation script to compare scraped JSON data against live sites
 * Helps verify accuracy before importing to Supabase
 */

import * as fs from 'fs';
import * as path from 'path';
import { ScraperResult, ScrapedDish } from '../scrapers/types';

interface ValidationResult {
  restaurantId: string;
  restaurantName: string;
  isValid: boolean;
  issues: Array<{
    severity: 'error' | 'warning' | 'info';
    category: string;
    message: string;
    dishName?: string;
    groupName?: string;
  }>;
  stats: {
    totalDishes: number;
    totalGroups: number;
    totalOptions: number;
    dishesWithoutPrice: number;
    groupsWithoutOptions: number;
    duplicateGroupNames: number;
  };
}

class ScrapedDataValidator {
  private scrapedDataDir = './scraped-data';

  async validateAll(): Promise<ValidationResult[]> {
    const results: ValidationResult[] = [];

    // Find all restaurant directories
    const restaurantDirs = fs.readdirSync(this.scrapedDataDir, { withFileTypes: true })
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name);

    console.log(`\n📋 Found ${restaurantDirs.length} restaurant directories to validate\n`);

    for (const restaurantId of restaurantDirs) {
      const result = await this.validateRestaurant(restaurantId);
      results.push(result);
      this.printValidationResult(result);
    }

    this.printSummary(results);
    return results;
  }

  async validateRestaurant(restaurantId: string): Promise<ValidationResult> {
    const result: ValidationResult = {
      restaurantId,
      restaurantName: '',
      isValid: true,
      issues: [],
      stats: {
        totalDishes: 0,
        totalGroups: 0,
        totalOptions: 0,
        dishesWithoutPrice: 0,
        groupsWithoutOptions: 0,
        duplicateGroupNames: 0
      }
    };

    // Find latest JSON file for this restaurant
    const restaurantDir = path.join(this.scrapedDataDir, restaurantId);
    if (!fs.existsSync(restaurantDir)) {
      result.isValid = false;
      result.issues.push({
        severity: 'error',
        category: 'missing_data',
        message: 'Restaurant directory not found'
      });
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
      result.isValid = false;
      result.issues.push({
        severity: 'error',
        category: 'missing_data',
        message: 'No JSON files found in restaurant directory'
      });
      return result;
    }

    // Load latest JSON
    const latestFile = jsonFiles[0];
    let scrapedData: ScraperResult;

    try {
      const fileContent = fs.readFileSync(latestFile.path, 'utf-8');
      scrapedData = JSON.parse(fileContent);
    } catch (error: any) {
      result.isValid = false;
      result.issues.push({
        severity: 'error',
        category: 'parse_error',
        message: `Failed to parse JSON: ${error.message}`
      });
      return result;
    }

    // Validate data structure
    this.validateDataStructure(scrapedData, result);
    this.validateDishes(scrapedData.dishes, result);
    this.calculateStats(scrapedData, result);

    return result;
  }

  private validateDataStructure(data: ScraperResult, result: ValidationResult): void {
    if (!data.success) {
      result.isValid = false;
      result.issues.push({
        severity: 'error',
        category: 'scrape_failed',
        message: 'Scrape was marked as failed'
      });
    }

    if (data.errors && data.errors.length > 0) {
      result.issues.push({
        severity: 'warning',
        category: 'scrape_errors',
        message: `${data.errors.length} error(s) occurred during scraping`
      });
    }

    if (!data.dishes || data.dishes.length === 0) {
      result.isValid = false;
      result.issues.push({
        severity: 'error',
        category: 'no_dishes',
        message: 'No dishes were scraped'
      });
    }
  }

  private validateDishes(dishes: ScrapedDish[], result: ValidationResult): void {
    if (!dishes || dishes.length === 0) return;

    result.restaurantName = dishes[0]?.restaurant || result.restaurantId;

    for (const dish of dishes) {
      // Validate dish has a name
      if (!dish.dish.name || dish.dish.name === 'Unknown Dish') {
        result.issues.push({
          severity: 'warning',
          category: 'missing_data',
          message: 'Dish has no name or generic name',
          dishName: dish.dish.name
        });
      }

      // Validate dish has a price
      if (dish.dish.basePrice === null || dish.dish.basePrice === undefined) {
        result.stats.dishesWithoutPrice++;
        result.issues.push({
          severity: 'warning',
          category: 'missing_price',
          message: 'Dish has no base price',
          dishName: dish.dish.name
        });
      }

      // Validate modifier groups
      if (dish.groups.length === 0) {
        result.issues.push({
          severity: 'info',
          category: 'no_modifiers',
          message: 'Dish has no modifier groups',
          dishName: dish.dish.name
        });
      } else {
        this.validateModifierGroups(dish, result);
      }
    }
  }

  private validateModifierGroups(dish: ScrapedDish, result: ValidationResult): void {
    const groupNames = new Set<string>();

    for (const group of dish.groups) {
      // Check for duplicate group names
      if (groupNames.has(group.name)) {
        result.stats.duplicateGroupNames++;
        result.issues.push({
          severity: 'warning',
          category: 'duplicate_group',
          message: `Duplicate group name: ${group.name}`,
          dishName: dish.dish.name,
          groupName: group.name
        });
      }
      groupNames.add(group.name);

      // Validate group has options
      if (group.options.length === 0) {
        result.stats.groupsWithoutOptions++;
        result.issues.push({
          severity: 'error',
          category: 'empty_group',
          message: `Group has no options`,
          dishName: dish.dish.name,
          groupName: group.name
        });
        result.isValid = false;
      }

      // Validate selection logic
      if (group.minSelections > group.options.length) {
        result.issues.push({
          severity: 'error',
          category: 'invalid_selection_rules',
          message: `Min selections (${group.minSelections}) > available options (${group.options.length})`,
          dishName: dish.dish.name,
          groupName: group.name
        });
        result.isValid = false;
      }

      if (group.maxSelections !== null && group.maxSelections < group.minSelections) {
        result.issues.push({
          severity: 'error',
          category: 'invalid_selection_rules',
          message: `Max selections (${group.maxSelections}) < min selections (${group.minSelections})`,
          dishName: dish.dish.name,
          groupName: group.name
        });
        result.isValid = false;
      }

      // Validate options
      for (const option of group.options) {
        if (!option.name || option.name.trim() === '') {
          result.issues.push({
            severity: 'error',
            category: 'missing_option_name',
            message: 'Option has no name',
            dishName: dish.dish.name,
            groupName: group.name
          });
          result.isValid = false;
        }

        if (option.priceDelta === undefined || option.priceDelta === null) {
          result.issues.push({
            severity: 'warning',
            category: 'missing_price_delta',
            message: `Option "${option.name}" has no price delta`,
            dishName: dish.dish.name,
            groupName: group.name
          });
        }
      }
    }
  }

  private calculateStats(data: ScraperResult, result: ValidationResult): void {
    result.stats.totalDishes = data.dishes.length;
    result.stats.totalGroups = data.dishes.reduce((sum, d) => sum + d.groups.length, 0);
    result.stats.totalOptions = data.dishes.reduce((sum, d) =>
      sum + d.groups.reduce((gsum, g) => gsum + g.options.length, 0), 0
    );
  }

  private printValidationResult(result: ValidationResult): void {
    const status = result.isValid ? '✅' : '❌';
    console.log(`${status} ${result.restaurantName} (${result.restaurantId})`);
    console.log(`   Dishes: ${result.stats.totalDishes}, Groups: ${result.stats.totalGroups}, Options: ${result.stats.totalOptions}`);

    if (result.issues.length > 0) {
      const errorCount = result.issues.filter(i => i.severity === 'error').length;
      const warningCount = result.issues.filter(i => i.severity === 'warning').length;
      const infoCount = result.issues.filter(i => i.severity === 'info').length;

      console.log(`   Issues: ${errorCount} errors, ${warningCount} warnings, ${infoCount} info`);

      // Show first 3 critical issues
      const criticalIssues = result.issues
        .filter(i => i.severity === 'error')
        .slice(0, 3);

      criticalIssues.forEach(issue => {
        console.log(`      ❌ ${issue.category}: ${issue.message}`);
      });

      if (errorCount > 3) {
        console.log(`      ... and ${errorCount - 3} more errors`);
      }
    }

    console.log('');
  }

  private printSummary(results: ValidationResult[]): void {
    const validCount = results.filter(r => r.isValid).length;
    const invalidCount = results.filter(r => !r.isValid).length;
    const totalDishes = results.reduce((sum, r) => sum + r.stats.totalDishes, 0);
    const totalGroups = results.reduce((sum, r) => sum + r.stats.totalGroups, 0);
    const totalOptions = results.reduce((sum, r) => sum + r.stats.totalOptions, 0);

    console.log(`${'='.repeat(80)}`);
    console.log('📊 VALIDATION SUMMARY');
    console.log(`${'='.repeat(80)}`);
    console.log(`Total Restaurants: ${results.length}`);
    console.log(`✅ Valid:          ${validCount}`);
    console.log(`❌ Invalid:        ${invalidCount}`);
    console.log(`\n📦 Total Data:`);
    console.log(`   Dishes:         ${totalDishes}`);
    console.log(`   Modifier Groups: ${totalGroups}`);
    console.log(`   Modifier Options: ${totalOptions}`);

    if (invalidCount > 0) {
      console.log(`\n⚠️  ${invalidCount} restaurant(s) have validation errors.`);
      console.log(`   Review issues above before importing to Supabase.`);
    } else {
      console.log(`\n✨ All restaurants passed validation!`);
      console.log(`   Ready to import to Supabase.`);
      console.log(`   Run: npm run import-to-supabase`);
    }

    console.log(`${'='.repeat(80)}\n`);

    // Save validation report
    const reportPath = './scraped-data/validation-report.json';
    fs.writeFileSync(reportPath, JSON.stringify(results, null, 2), 'utf-8');
    console.log(`📄 Full validation report saved to: ${reportPath}\n`);
  }
}

async function main() {
  const validator = new ScrapedDataValidator();
  await validator.validateAll();
}

if (require.main === module) {
  main().catch(error => {
    console.error('Validation failed:', error);
    process.exit(1);
  });
}

export { ScrapedDataValidator, ValidationResult };
