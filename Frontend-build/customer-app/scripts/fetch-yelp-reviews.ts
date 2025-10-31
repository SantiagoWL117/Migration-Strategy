#!/usr/bin/env tsx
/**
 * Yelp Fusion API Integration Script
 *
 * Purpose: Fetch real reviews and ratings from Yelp for Menu.ca restaurants
 * and populate the restaurant_reviews table with authentic data.
 *
 * Prerequisites:
 * 1. Get a Yelp Fusion API key from https://www.yelp.com/developers/v3/manage_app
 * 2. Set YELP_FUSION_API_KEY in your .env file
 * 3. Ensure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set
 *
 * Usage:
 *   npm run yelp:fetch              # Run in production mode
 *   npm run yelp:fetch -- --dry-run # Test without inserting data
 *   npm run yelp:fetch -- --limit 5 # Process only 5 restaurants
 *
 * Rate Limits:
 * - Yelp Free Tier: 5,000 calls/day (resets at midnight UTC)
 * - This script uses ~2 calls per restaurant (match + reviews)
 * - Max restaurants per day: ~2,500
 */

import * as dotenv from 'dotenv'
import * as path from 'path'
import {
  YelpBusiness,
  YelpReviewsResponse,
  YelpAPIError,
  YelpScriptConfig,
  YelpScriptResult,
  RestaurantReviewInsert
} from './yelp-types'
import {
  supabase,
  getActiveRestaurants,
  insertRestaurantReview,
  checkYelpBusinessExists
} from './database-client'

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../.env') })

const YELP_API_BASE = 'https://api.yelp.com/v3'

// Parse command line arguments
const args = process.argv.slice(2)
const dryRun = args.includes('--dry-run')
const limitIndex = args.indexOf('--limit')
const maxRestaurants = limitIndex !== -1 ? parseInt(args[limitIndex + 1]) : undefined

// Configuration
const config: YelpScriptConfig = {
  apiKey: process.env.YELP_FUSION_API_KEY || '',
  dryRun,
  maxRestaurants,
  delayBetweenRequests: 250, // 250ms = 4 requests/second (safe for rate limits)
  maxReviewsPerRestaurant: 3 // Yelp returns max 3 reviews on free tier
}

// Validation
if (!config.apiKey) {
  console.error('\n❌ ERROR: YELP_FUSION_API_KEY is not set in .env file')
  console.error('\n📝 To get your API key:')
  console.error('   1. Go to https://www.yelp.com/developers/v3/manage_app')
  console.error('   2. Create a new app (or use existing)')
  console.error('   3. Copy the API Key')
  console.error('   4. Add to .env: YELP_FUSION_API_KEY=your_key_here\n')
  process.exit(1)
}

// Utility: Sleep function for rate limiting
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms))

// Yelp API: Match business by name and location
async function matchYelpBusiness(
  restaurantName: string,
  phone: string,
  address: string,
  city: string,
  state: string,
  postalCode: string
): Promise<YelpBusiness | null> {
  try {
    // Clean phone number (Yelp expects format: +1234567890)
    const cleanPhone = phone.replace(/\D/g, '')
    const formattedPhone = cleanPhone.startsWith('1') ? `+${cleanPhone}` : `+1${cleanPhone}`

    // Build query params - Business Match endpoint requires name + location
    const params = new URLSearchParams({
      name: restaurantName,
      address1: address,
      city: city,
      state: state.toUpperCase(), // Convert 'on' to 'ON', 'qc' to 'QC'
      postal_code: postalCode,
      country: 'CA'
    })

    // Add phone if available (improves matching accuracy)
    if (phone) {
      params.append('phone', formattedPhone)
    }

    const url = `${YELP_API_BASE}/businesses/matches?${params}`

    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Accept': 'application/json'
      }
    })

    if (!response.ok) {
      if (response.status === 429) {
        console.error('⚠️  Rate limit exceeded (429). Waiting 60 seconds...')
        await sleep(60000)
        return matchYelpBusiness(restaurantName, phone, address, city, state, postalCode) // Retry
      }

      const errorData: YelpAPIError = await response.json()
      throw new Error(`Yelp API error: ${errorData.error?.description || response.statusText}`)
    }

    const data = await response.json()

    // Business Match returns array of businesses, take first match
    if (data.businesses && data.businesses.length > 0) {
      return data.businesses[0]
    }

    return null
  } catch (error) {
    console.error(`Error matching business: ${error}`)
    return null
  }
}

// Yelp API: Fetch reviews for a business
async function fetchYelpReviews(yelpBusinessId: string): Promise<YelpReviewsResponse | null> {
  try {
    const url = `${YELP_API_BASE}/businesses/${yelpBusinessId}/reviews`

    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Accept': 'application/json'
      }
    })

    if (!response.ok) {
      if (response.status === 429) {
        console.error('⚠️  Rate limit exceeded (429). Waiting 60 seconds...')
        await sleep(60000)
        return fetchYelpReviews(yelpBusinessId) // Retry
      }

      const errorData: YelpAPIError = await response.json()
      throw new Error(`Yelp API error: ${errorData.error?.description || response.statusText}`)
    }

    const data: YelpReviewsResponse = await response.json()
    return data
  } catch (error) {
    console.error(`Error fetching reviews: ${error}`)
    return null
  }
}

// Main processing function for a single restaurant
async function processRestaurant(restaurant: any): Promise<YelpScriptResult> {
  const result: YelpScriptResult = {
    restaurantId: restaurant.id,
    restaurantName: restaurant.name,
    matched: false,
    reviewsInserted: 0
  }

  try {
    console.log(`\n🔍 Processing: ${restaurant.name}`)

    const location = restaurant.restaurant_locations[0]
    if (!location) {
      result.error = 'No location data'
      console.log('   ⚠️  Skipped - No location data')
      return result
    }

    // Step 1: Match restaurant to Yelp business
    console.log('   📞 Matching with Yelp...')

    // Extract city and province from the nested data
    const cityName = location.cities?.name || ''
    const provinceName = location.cities?.provinces?.short_name || ''

    const yelpBusiness = await matchYelpBusiness(
      restaurant.name,
      location.phone || '',
      location.street_address || '',
      cityName,
      provinceName,
      location.postal_code || ''
    )

    await sleep(config.delayBetweenRequests) // Rate limiting

    if (!yelpBusiness) {
      result.error = 'No Yelp match found'
      console.log('   ❌ No match found on Yelp')
      return result
    }

    result.matched = true
    result.yelpBusinessId = yelpBusiness.id
    result.yelpRating = yelpBusiness.rating
    result.yelpReviewCount = yelpBusiness.review_count

    console.log(`   ✅ Matched! Yelp ID: ${yelpBusiness.id}`)
    console.log(`   ⭐ Rating: ${yelpBusiness.rating} (${yelpBusiness.review_count} reviews)`)

    // Check if we've already imported reviews for this Yelp business
    if (!config.dryRun) {
      const alreadyExists = await checkYelpBusinessExists(yelpBusiness.id)
      if (alreadyExists) {
        result.error = 'Reviews already imported'
        console.log('   ℹ️  Reviews already imported for this business')
        return result
      }
    }

    // Step 2: Fetch reviews
    if (yelpBusiness.review_count === 0) {
      console.log('   ℹ️  No reviews available on Yelp')
      return result
    }

    console.log('   📄 Fetching reviews...')
    const reviewsData = await fetchYelpReviews(yelpBusiness.id)
    await sleep(config.delayBetweenRequests) // Rate limiting

    if (!reviewsData || !reviewsData.reviews || reviewsData.reviews.length === 0) {
      result.error = 'No reviews returned'
      console.log('   ⚠️  No reviews returned from API')
      return result
    }

    // Step 3: Insert reviews into database
    console.log(`   💾 Inserting ${reviewsData.reviews.length} reviews...`)

    if (config.dryRun) {
      console.log('   🔸 DRY RUN - Would insert:')
      reviewsData.reviews.forEach((review, index) => {
        console.log(`      ${index + 1}. ${review.user.name} - ${review.rating}⭐ - "${review.text.substring(0, 50)}..."`)
      })
      result.reviewsInserted = reviewsData.reviews.length
    } else {
      for (const review of reviewsData.reviews) {
        try {
          const reviewInsert: RestaurantReviewInsert = {
            restaurant_id: restaurant.id,
            user_id: null, // External review, no Menu.ca user
            order_id: null,
            rating: review.rating,
            review_text: review.text, // Note: Only first 160 chars from Yelp
            source: 'yelp',
            external_review_id: review.id,
            external_user_name: review.user.name,
            external_user_image: review.user.image_url || null,
            yelp_business_id: yelpBusiness.id,
            yelp_business_url: yelpBusiness.url,
            created_at: review.time_created
          }

          await insertRestaurantReview(reviewInsert)
          result.reviewsInserted++
        } catch (error) {
          console.error(`      ❌ Failed to insert review: ${error}`)
        }
      }

      console.log(`   ✅ Inserted ${result.reviewsInserted} reviews`)
    }

  } catch (error) {
    result.error = error instanceof Error ? error.message : String(error)
    console.error(`   ❌ Error: ${result.error}`)
  }

  return result
}

// Main execution
async function main() {
  console.log('\n╔════════════════════════════════════════════════════╗')
  console.log('║   Yelp Fusion API - Restaurant Reviews Importer   ║')
  console.log('╚════════════════════════════════════════════════════╝\n')

  if (config.dryRun) {
    console.log('🔸 DRY RUN MODE - No data will be inserted\n')
  }

  console.log('⚙️  Configuration:')
  console.log(`   - API Key: ${config.apiKey.substring(0, 10)}...`)
  console.log(`   - Dry Run: ${config.dryRun}`)
  console.log(`   - Max Restaurants: ${config.maxRestaurants || 'All'}`)
  console.log(`   - Rate Limit Delay: ${config.delayBetweenRequests}ms`)
  console.log(`   - Max Reviews/Restaurant: ${config.maxReviewsPerRestaurant}`)

  // Fetch active restaurants
  console.log('\n📊 Fetching active restaurants from database...')
  const restaurants = await getActiveRestaurants()

  const processCount = config.maxRestaurants
    ? Math.min(config.maxRestaurants, restaurants.length)
    : restaurants.length

  console.log(`   Found ${restaurants.length} active restaurants`)
  console.log(`   Will process: ${processCount} restaurants\n`)

  // Process each restaurant
  const results: YelpScriptResult[] = []
  const restaurantsToProcess = restaurants.slice(0, processCount)

  for (let i = 0; i < restaurantsToProcess.length; i++) {
    const restaurant = restaurantsToProcess[i]
    console.log(`[${i + 1}/${processCount}]`, '-'.repeat(50))

    const result = await processRestaurant(restaurant)
    results.push(result)

    // Extra delay between restaurants to be safe with rate limits
    if (i < restaurantsToProcess.length - 1) {
      await sleep(config.delayBetweenRequests * 2)
    }
  }

  // Summary
  console.log('\n╔════════════════════════════════════════════════════╗')
  console.log('║                   📊 SUMMARY                       ║')
  console.log('╚════════════════════════════════════════════════════╝\n')

  const matched = results.filter(r => r.matched).length
  const notMatched = results.filter(r => !r.matched).length
  const totalReviews = results.reduce((sum, r) => sum + r.reviewsInserted, 0)

  console.log(`✅ Matched with Yelp:        ${matched}`)
  console.log(`❌ No Yelp match:            ${notMatched}`)
  console.log(`📝 Total reviews inserted:   ${totalReviews}`)

  // Details of unmatched restaurants
  if (notMatched > 0) {
    console.log('\n⚠️  Restaurants without Yelp match:')
    results
      .filter(r => !r.matched)
      .forEach(r => {
        console.log(`   - ${r.restaurantName} (ID: ${r.restaurantId})`)
        if (r.error) console.log(`     Error: ${r.error}`)
      })
  }

  // Details of matched restaurants
  if (matched > 0) {
    console.log('\n✅ Successfully matched restaurants:')
    results
      .filter(r => r.matched)
      .forEach(r => {
        console.log(`   - ${r.restaurantName}`)
        console.log(`     Yelp: ${r.yelpRating}⭐ (${r.yelpReviewCount} reviews)`)
        console.log(`     Imported: ${r.reviewsInserted} reviews`)
      })
  }

  console.log('\n✨ Script completed!\n')
}

// Run the script
main().catch(error => {
  console.error('\n❌ Fatal error:', error)
  process.exit(1)
})
