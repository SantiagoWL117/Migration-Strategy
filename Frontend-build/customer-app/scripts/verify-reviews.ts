#!/usr/bin/env tsx
/**
 * Verify Yelp Reviews Import
 * Quick verification script to check imported review data
 */

import { supabase } from './database-client'

async function verifyReviews() {
  console.log('\n📊 Verifying Yelp Reviews Import...\n')

  // Overall statistics
  const { data: stats, error: statsError } = await supabase
    .schema('menuca_v3')
    .from('restaurant_reviews')
    .select('id, rating, restaurant_id')
    .eq('source', 'yelp')

  if (statsError) {
    console.error('Error fetching stats:', statsError)
    return
  }

  const totalReviews = stats?.length || 0
  const uniqueRestaurants = new Set(stats?.map(r => r.restaurant_id)).size
  const avgRating = stats?.reduce((sum, r) => sum + r.rating, 0) / totalReviews
  const minRating = Math.min(...(stats?.map(r => r.rating) || [0]))
  const maxRating = Math.max(...(stats?.map(r => r.rating) || [0]))

  console.log('📈 Overall Statistics:')
  console.log(`   Total Reviews: ${totalReviews}`)
  console.log(`   Restaurants with Reviews: ${uniqueRestaurants}`)
  console.log(`   Average Rating: ${avgRating.toFixed(2)}`)
  console.log(`   Rating Range: ${minRating} - ${maxRating}`)

  // Top restaurants by review count
  const reviewsByRestaurant = stats?.reduce((acc, review) => {
    acc[review.restaurant_id] = (acc[review.restaurant_id] || 0) + 1
    return acc
  }, {} as Record<number, number>)

  const topRestaurantIds = Object.entries(reviewsByRestaurant || {})
    .sort(([, a], [, b]) => b - a)
    .slice(0, 15)
    .map(([id]) => parseInt(id))

  // Fetch restaurant names and calculate averages
  const { data: restaurants, error: restaurantsError } = await supabase
    .schema('menuca_v3')
    .from('restaurants')
    .select('id, name')
    .in('id', topRestaurantIds)

  if (restaurantsError) {
    console.error('Error fetching restaurants:', restaurantsError)
    return
  }

  const restaurantMap = new Map(restaurants?.map(r => [r.id, r.name]) || [])

  console.log('\n🏆 Top 15 Restaurants by Review Count:')
  console.log('─'.repeat(70))

  topRestaurantIds.forEach((id, index) => {
    const reviewCount = reviewsByRestaurant?.[id] || 0
    const restaurantReviews = stats?.filter(r => r.restaurant_id === id) || []
    const avgRating = restaurantReviews.reduce((sum, r) => sum + r.rating, 0) / reviewCount
    const name = restaurantMap.get(id) || `Restaurant ${id}`

    console.log(`${index + 1}. ${name}`)
    console.log(`   Reviews: ${reviewCount} | Avg Rating: ${avgRating.toFixed(2)}⭐`)
  })

  console.log('\n✅ Verification complete!\n')
}

verifyReviews().catch(error => {
  console.error('Fatal error:', error)
  process.exit(1)
})
