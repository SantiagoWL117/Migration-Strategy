#!/usr/bin/env tsx
/**
 * Test AI Search Data Structure
 * Verify that restaurants have real Yelp ratings
 */

import { supabase } from './database-client'

async function testAISearchData() {
  console.log('\n🧪 Testing AI Search Data Structure...\n')

  // Replicate the AI search query logic
  const { data: restaurants, error } = await supabase
    .schema('menuca_v3')
    .from('restaurants')
    .select(`
      id,
      name,
      slug,
      meta_description,
      is_featured,
      status,
      online_ordering_enabled,
      search_keywords,
      restaurant_cuisines!inner(
        is_primary,
        cuisine_types(name)
      ),
      restaurant_service_configs(
        delivery_time_minutes,
        delivery_min_order
      )
    `)
    .eq('status', 'active')
    .eq('online_ordering_enabled', true)
    .limit(75)

  if (error) {
    console.error('❌ Error fetching restaurants:', error)
    return
  }

  console.log(`✅ Found ${restaurants?.length || 0} active restaurants\n`)

  // Fetch delivery fees
  const restaurantIds = restaurants?.map(r => r.id) || []
  const { data: deliveryFees } = await supabase
    .schema('menuca_v3')
    .from('restaurant_delivery_fees')
    .select('restaurant_id, total_delivery_fee')
    .in('restaurant_id', restaurantIds)
    .eq('is_active', true)
    .order('total_delivery_fee', { ascending: true })

  const feeMap = new Map<number, number>()
  deliveryFees?.forEach((fee: any) => {
    if (!feeMap.has(fee.restaurant_id)) {
      feeMap.set(fee.restaurant_id, fee.total_delivery_fee)
    }
  })

  // Fetch review ratings
  const { data: reviews } = await supabase
    .schema('menuca_v3')
    .from('restaurant_reviews')
    .select('restaurant_id, rating')
    .in('restaurant_id', restaurantIds)
    .eq('source', 'yelp')

  console.log(`✅ Found ${reviews?.length || 0} Yelp reviews\n`)

  // Calculate ratings
  const ratingsMap = new Map<number, { avgRating: number; reviewCount: number }>()
  reviews?.forEach((review: any) => {
    const current = ratingsMap.get(review.restaurant_id) || { avgRating: 0, reviewCount: 0, totalRating: 0 }
    ratingsMap.set(review.restaurant_id, {
      avgRating: 0,
      reviewCount: current.reviewCount + 1,
      totalRating: (current as any).totalRating + review.rating
    } as any)
  })

  ratingsMap.forEach((value, key) => {
    const avg = (value as any).totalRating / value.reviewCount
    ratingsMap.set(key, {
      avgRating: Math.round(avg * 10) / 10,
      reviewCount: value.reviewCount
    })
  })

  console.log(`✅ Calculated ratings for ${ratingsMap.size} restaurants\n`)

  // Show sample data
  console.log('📊 Sample Restaurants with Ratings:')
  console.log('─'.repeat(80))

  const sampleRestaurants = restaurants?.slice(0, 10).map(r => {
    const primaryCuisine = r.restaurant_cuisines?.find((rc: any) => rc.is_primary)
    const cuisineTypes = primaryCuisine?.cuisine_types || r.restaurant_cuisines?.[0]?.cuisine_types
    const cuisineName = Array.isArray(cuisineTypes)
      ? (cuisineTypes[0] as any)?.name
      : (cuisineTypes as any)?.name || 'Various'

    const serviceConfig = r.restaurant_service_configs?.[0] || {}
    const deliveryTimeMinutes = serviceConfig.delivery_time_minutes
    const deliveryMinOrder = serviceConfig.delivery_min_order
    const minDeliveryFee = feeMap.get(r.id)
    const ratingData = ratingsMap.get(r.id)

    return {
      name: r.name,
      cuisine: cuisineName,
      rating: ratingData?.avgRating || null,
      reviewCount: ratingData?.reviewCount || 0,
      deliveryFee: minDeliveryFee || 2.99,
      minimumOrder: deliveryMinOrder || 15,
      deliveryTime: deliveryTimeMinutes ? `${deliveryTimeMinutes} min` : '30-45 min'
    }
  }) || []

  sampleRestaurants.forEach((r, index) => {
    console.log(`${index + 1}. ${r.name} (${r.cuisine})`)
    const ratingText = r.rating ? `${r.rating}⭐ (${r.reviewCount} reviews)` : 'No reviews yet'
    console.log(`   Rating: ${ratingText}`)
    console.log(`   Delivery: $${r.deliveryFee} fee, $${r.minimumOrder} min, ${r.deliveryTime}`)
    console.log()
  })

  // Statistics
  const restaurantsWithRatings = sampleRestaurants.filter(r => r.rating !== null).length
  const restaurantsWithoutRatings = sampleRestaurants.filter(r => r.rating === null).length

  console.log('📈 Statistics:')
  console.log(`   Restaurants with ratings: ${restaurantsWithRatings}/10 in sample`)
  console.log(`   Restaurants without ratings: ${restaurantsWithoutRatings}/10 in sample`)
  console.log(`   Total restaurants with ratings: ${ratingsMap.size}/${restaurants?.length || 0}`)

  const totalWithRatings = (ratingsMap.size / (restaurants?.length || 1) * 100).toFixed(1)
  console.log(`   Percentage with ratings: ${totalWithRatings}%`)

  console.log('\n✅ Test complete!\n')
}

testAISearchData().catch(error => {
  console.error('Fatal error:', error)
  process.exit(1)
})
