# Menu.ca Restaurant Scraper

Standalone tool for scraping dish names, descriptions, prices, and modifier groups from Menu.ca V1 and V2 restaurant sites.

## Overview

This scraper extracts complete menu data from 26 restaurant locations for database import. Built with Playwright for reliable browser automation and DOM extraction.

**Current Status**: V1 scraper working perfectly - 100% success rate on Papa Burger (61/61 dishes)

## Features

- **V1 Sites**: Multi-step modal customization (e.g., Papa Burger)
  - Extracts dish names, descriptions, prices from HTML forms
  - Navigates multi-step modifier modals
  - Handles location gates automatically
  - 100% accurate modifier extraction

- **V2 Sites**: Single-page form customization (coming soon)

## Installation

```bash
cd menu-scraper
npm install
```

## Usage

### Scrape a single restaurant

```bash
# Headless mode (default)
npm run scrape papa-burger

# Watch mode (visible browser)
npm run scrape papa-burger --watch
```

### List all configured restaurants

```bash
npm run list
```

### Scrape all restaurants

```bash
npm run scrape:all
```

## Adding New Restaurants

Edit [src/config.ts](src/config.ts):

```typescript
export const V1_RESTAURANTS: Record<string, Omit<ScraperConfig, 'headless' | 'screenshotsDir' | 'outputDir'>> = {
  'papa-burger': {
    restaurantName: 'Papa Burger',
    baseUrl: 'https://papaburger.ca/?p=menu',
    version: 'v1'
  },
  'your-restaurant': {
    restaurantName: 'Your Restaurant Name',
    baseUrl: 'https://yourrestaurant.ca/?p=menu',
    version: 'v1'
  }
};
```

## Output

### Directory structure

```
menu-scraper/
├── output/
│   └── papa-burger/
│       └── papa-burger-2025-11-07T20-09-26-626Z.json
└── screenshots/
    └── papa-burger/
        ├── 0-dish-0.png
        ├── 1-dish-1.png
        └── ...
```

### JSON format

```json
{
  "success": true,
  "dishes": [
    {
      "restaurant": "Papa Burger",
      "restaurantUrl": "https://papaburger.ca/?p=menu",
      "dish": {
        "name": "Combo Pour 1",
        "description": "Burger Original, Frites avec Sauce Brune, 6 Ailes et 1 Canette.",
        "basePrice": 22.95
      },
      "groups": [
        {
          "name": "Type de sauce",
          "selectType": "single",
          "minSelections": 1,
          "maxSelections": 1,
          "isRequired": true,
          "displayOrder": 0,
          "stepOrder": 1,
          "options": [
            { "name": "Douce", "priceDelta": 0, "isDefault": false },
            { "name": "Moyenne", "priceDelta": 0, "isDefault": false },
            { "name": "Forte", "priceDelta": 0, "isDefault": false }
          ]
        }
      ],
      "metadata": {
        "scrapedAt": "2025-11-07T20:09:26.626Z",
        "version": "v1",
        "dishUrl": "https://papaburger.ca/?p=menu"
      }
    }
  ],
  "summary": {
    "totalDishes": 61,
    "successCount": 61,
    "errorCount": 0,
    "totalGroups": 33,
    "totalOptions": 165
  }
}
```

## Architecture

```
src/
├── scrapers/
│   ├── v1-scraper.ts    # V1 sites (Papa Burger style)
│   └── v2-scraper.ts    # V2 sites (coming soon)
├── types.ts             # TypeScript interfaces
├── config.ts            # Restaurant configurations
└── cli.ts               # Command-line interface
```

## How V1 Scraper Works

1. **Navigate to restaurant URL**
2. **Handle location gate** (click "Takeout" if present)
3. **Extract dish manifest** from DOM using `form[id^="form_"]` selector
4. **For each dish**:
   - Click order button
   - Extract modifier groups from modal
   - Navigate through multi-step customization
   - Click options to advance through steps
5. **Return to menu** and repeat
6. **Save JSON output** with complete data

## Key Implementation Details

### V1 HTML Structure

```html
<form id="form_123564">
  <div style="float:left">
    <p style="font-weight: bold">Combo Pour 1</p>  <!-- DISH NAME -->
    <p>Burger Original, Frites...</p>              <!-- DESCRIPTION -->
  </div>
  <table>
    <td>$ 22.95</td>  <!-- PRICE -->
  </table>
  <a href="#"><img src="order.png"></a>  <!-- ORDER BUTTON -->
</form>
```

### Location Gate Detection

```typescript
const takeoutSelectors = [
  'a:has-text("Takeout")',
  'a:has-text("Pick up")',
  'a:has-text("Pour emporter")',
  'img[alt*="takeout"]'
];
```

## Troubleshooting

### Scraper finds 0 dishes

- Check if location gate is blocking menu
- Verify URL loads menu page directly
- Try `--watch` mode to see what's happening

### Wrong dish count

- Compare scraper count with frontend count
- Check for hidden dishes or duplicate forms
- Verify form selector is catching all dishes

### Missing modifiers

- Check if modal navigation is working
- Verify "Next" button detection
- Try increasing wait times in scraper config

## Papa Burger Results

- **Total dishes**: 61
- **Success rate**: 100% (61/61)
- **Modifier groups**: 33
- **Total options**: 165
- **Errors**: 0

## Next Steps

1. Add remaining 25 V1 restaurant configs
2. Test scraper on all locations
3. Implement V2 scraper for single-page sites
4. Create database import tool

## License

ISC
