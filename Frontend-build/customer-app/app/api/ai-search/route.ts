import { NextRequest, NextResponse } from 'next/server'
import OpenAI from 'openai'
import { createServiceClient } from '@/lib/supabase/server'

// Force dynamic rendering - do not cache this route
export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// Initialize OpenAI client (check both naming conventions)
const apiKey = process.env.OPENAI_API_KEY || process.env.OPEN_AI_API_KEY
const openai = apiKey ? new OpenAI({ apiKey }) : null

if (openai) {
  console.log('✓ OpenAI client initialized')
} else {
  console.warn('⚠ OpenAI API key not found. Set OPENAI_API_KEY or OPEN_AI_API_KEY env var.')
}

// Cache for restaurant data (5 minute TTL)
let restaurantCache: { data: any[]; timestamp: number } | null = null
const CACHE_TTL = 5 * 60 * 1000 // 5 minutes

// Fetch real restaurants from Supabase
async function getRestaurantData() {
  // Check cache first
  if (restaurantCache && Date.now() - restaurantCache.timestamp < CACHE_TTL) {
    return { restaurants: restaurantCache.data }
  }

  // Check environment variables
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !serviceKey) {
    console.error('❌ Missing Supabase environment variables')
    return { restaurants: [] }
  }

  try {
    const supabase = await createServiceClient()

    // Query with service role to bypass RLS - filter for active restaurants only
    // Join with restaurant_cuisines, cuisine_types, and operational data tables
    const { data: restaurants, error, count } = await supabase
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
      `, { count: 'exact' })
      .eq('status', 'active')
      .eq('online_ordering_enabled', true)
      .limit(75)

    if (error) {
      console.error('❌ Error fetching restaurants:', error.message)
      return { restaurants: [] }
    }

    if (!restaurants || restaurants.length === 0) {
      console.warn('⚠ No active restaurants found')
      return { restaurants: [] }
    }

    // Fetch minimum delivery fees for all restaurants in a single query
    const restaurantIds = restaurants.map(r => r.id)
    const { data: deliveryFees } = await supabase
      .schema('menuca_v3')
      .from('restaurant_delivery_fees')
      .select('restaurant_id, total_delivery_fee')
      .in('restaurant_id', restaurantIds)
      .eq('is_active', true)
      .order('total_delivery_fee', { ascending: true })

    // Create a map of restaurant_id to minimum delivery fee
    const feeMap = new Map<number, number>()
    deliveryFees?.forEach((fee: any) => {
      if (!feeMap.has(fee.restaurant_id)) {
        feeMap.set(fee.restaurant_id, fee.total_delivery_fee)
      }
    })

    // Fetch review ratings for all restaurants (Yelp reviews)
    const { data: reviews } = await supabase
      .schema('menuca_v3')
      .from('restaurant_reviews')
      .select('restaurant_id, rating')
      .in('restaurant_id', restaurantIds)
      .eq('source', 'yelp')

    // Calculate average ratings and review counts
    const ratingsMap = new Map<number, { avgRating: number; reviewCount: number }>()
    reviews?.forEach((review: any) => {
      const current = ratingsMap.get(review.restaurant_id) || { avgRating: 0, reviewCount: 0, totalRating: 0 }
      ratingsMap.set(review.restaurant_id, {
        avgRating: 0, // Will calculate after
        reviewCount: current.reviewCount + 1,
        totalRating: (current as any).totalRating + review.rating
      } as any)
    })

    // Calculate averages
    ratingsMap.forEach((value, key) => {
      const avg = (value as any).totalRating / value.reviewCount
      ratingsMap.set(key, {
        avgRating: Math.round(avg * 10) / 10, // Round to 1 decimal place
        reviewCount: value.reviewCount
      })
    })

    // Transform to AI-friendly format (already filtered by query)
    const formattedRestaurants = restaurants
      ?.sort((a, b) => {
        // Sort by featured first, then by name
        if (a.is_featured && !b.is_featured) return -1
        if (!a.is_featured && b.is_featured) return 1
        return a.name.localeCompare(b.name)
      })
      ?.map(r => {
        // Extract primary cuisine or first cuisine
        const primaryCuisine = r.restaurant_cuisines?.find((rc: any) => rc.is_primary)
        const cuisineTypes = primaryCuisine?.cuisine_types || r.restaurant_cuisines?.[0]?.cuisine_types
        const cuisineName = Array.isArray(cuisineTypes)
          ? (cuisineTypes[0] as any)?.name
          : (cuisineTypes as any)?.name || 'Various'

        // Extract operational data from service configs
        const serviceConfig = r.restaurant_service_configs?.[0] || {}
        const deliveryTimeMinutes = serviceConfig.delivery_time_minutes
        const deliveryMinOrder = serviceConfig.delivery_min_order

        // Get minimum delivery fee from the fee map
        const minDeliveryFee = feeMap.get(r.id)

        // Get ratings from the ratings map
        const ratingData = ratingsMap.get(r.id)

        return {
          name: r.name,
          slug: r.slug,
          cuisine: cuisineName,
          description: r.meta_description || r.search_keywords || '',
          rating: ratingData?.avgRating || null, // Real Yelp rating or null if no reviews
          reviewCount: ratingData?.reviewCount || 0, // Real review count
          deliveryFee: minDeliveryFee || 2.99, // Use real fee or default
          minimumOrder: deliveryMinOrder || 15, // Use real min order or default
          deliveryTime: deliveryTimeMinutes ? `${deliveryTimeMinutes} min` : '30-45 min', // Use real time or default
          featured: r.is_featured || false
        }
      }) || []

    // Update cache
    restaurantCache = {
      data: formattedRestaurants,
      timestamp: Date.now()
    }

    return { restaurants: formattedRestaurants }
  } catch (error) {
    console.error('❌ Supabase error:', error)
    return { restaurants: [], error: error instanceof Error ? error.message : 'Unknown error' }
  }
}

// Improved keyword fallback matching
function keywordFallback(query: string, restaurants: any[]) {
  const lowerQuery = query.toLowerCase()

  // Keyword categories
  const keywords = {
    healthy: ['healthy', 'salad', 'fresh', 'light', 'clean', 'nutritious', 'fit', 'wellness'],
    spicy: ['spicy', 'hot', 'heat', 'fiery', 'kick', 'burn'],
    comfort: ['comfort', 'hearty', 'filling', 'classic', 'cozy', 'warm', 'soul food'],
    quick: ['fast', 'quick', 'asap', 'hurry', 'express', 'speedy'],
    vegan: ['vegan', 'plant-based', 'no meat', 'no animal'],
    vegetarian: ['vegetarian', 'veggie', 'no meat'],
    glutenFree: ['gluten free', 'gluten-free', 'celiac', 'no gluten'],
    romantic: ['date', 'romantic', 'anniversary', 'special occasion', 'fancy'],
    family: ['family', 'kids', 'children', 'group'],
    late: ['late night', 'midnight', 'after hours'],
    breakfast: ['breakfast', 'morning', 'brunch'],
    lunch: ['lunch', 'midday'],
    dinner: ['dinner', 'evening']
  }

  // Cuisine matching
  const cuisines = ['italian', 'chinese', 'mexican', 'american', 'japanese', 'thai', 'indian', 'mediterranean', 'korean', 'vietnamese', 'greek', 'french', 'spanish']

  let matchedCuisines: string[] = []
  let matchedRestaurants: any[] = []
  let message = ''
  let confidence = 0

  // Check for cuisine keywords
  for (const cuisine of cuisines) {
    if (lowerQuery.includes(cuisine)) {
      matchedCuisines.push(cuisine)
      const cuisineRestaurants = restaurants.filter(r =>
        r.cuisine.toLowerCase().includes(cuisine)
      ).slice(0, 5)
      matchedRestaurants.push(...cuisineRestaurants)
      confidence = 0.8
      message = `Great ${cuisine} options found!`
    }
  }

  // Check for dietary/preference keywords
  if (keywords.healthy.some(k => lowerQuery.includes(k))) {
    const healthyCuisines = ['mediterranean', 'japanese', 'thai', 'vietnamese']
    matchedCuisines.push(...healthyCuisines)
    matchedRestaurants = restaurants.filter(r =>
      healthyCuisines.some(c => r.cuisine.toLowerCase().includes(c))
    ).slice(0, 5)
    confidence = 0.75
    message = 'Here are some healthy dining options with fresh ingredients!'
  }

  if (keywords.spicy.some(k => lowerQuery.includes(k))) {
    const spicyCuisines = ['thai', 'indian', 'mexican', 'korean']
    matchedCuisines.push(...spicyCuisines)
    matchedRestaurants = restaurants.filter(r =>
      spicyCuisines.some(c => r.cuisine.toLowerCase().includes(c))
    ).slice(0, 5)
    confidence = 0.75
    message = 'Spice lovers rejoice! These restaurants bring the heat.'
  }

  if (keywords.romantic.some(k => lowerQuery.includes(k))) {
    // Prioritize higher-rated restaurants for date night
    matchedRestaurants = restaurants
      .filter(r => r.rating && r.rating >= 4.0)
      .sort((a, b) => (b.rating || 0) - (a.rating || 0))
      .slice(0, 5)
    // If not enough highly-rated restaurants, add featured ones
    if (matchedRestaurants.length < 3) {
      const featured = restaurants.filter(r => r.featured).slice(0, 5 - matchedRestaurants.length)
      matchedRestaurants.push(...featured)
    }
    matchedCuisines = [...new Set(matchedRestaurants.map(r => r.cuisine.toLowerCase()))]
    confidence = 0.7
    message = 'Perfect spots for a special evening together!'
  }

  // Time-based suggestions
  if (matchedRestaurants.length === 0) {
    const hour = new Date().getHours()
    if (hour >= 6 && hour < 11 || keywords.breakfast.some(k => lowerQuery.includes(k))) {
      message = 'Good morning! Here are some breakfast options.'
      matchedRestaurants = restaurants.slice(0, 5)
      confidence = 0.6
    } else if (hour >= 11 && hour < 14 || keywords.lunch.some(k => lowerQuery.includes(k))) {
      message = 'Lunchtime! Here are some great midday options.'
      matchedRestaurants = restaurants.slice(0, 5)
      confidence = 0.6
    } else if (hour >= 17 && hour < 22 || keywords.dinner.some(k => lowerQuery.includes(k))) {
      message = 'Dinner time! Explore these popular evening choices.'
      matchedRestaurants = restaurants.slice(0, 5)
      confidence = 0.6
    }
  }

  // Default fallback
  if (matchedRestaurants.length === 0) {
    matchedRestaurants = restaurants.slice(0, 5)
    matchedCuisines = [...new Set(matchedRestaurants.map(r => r.cuisine.toLowerCase()))]
    message = 'Try being more specific! Search for cuisines (pizza, sushi), preferences (healthy, spicy), or occasions (date night, quick lunch).'
    confidence = 0.3
  }

  // Remove duplicates and limit
  matchedRestaurants = Array.from(new Set(matchedRestaurants.map(r => r.name)))
    .map(name => matchedRestaurants.find(r => r.name === name))
    .slice(0, 5)

  matchedCuisines = Array.from(new Set(matchedCuisines)).slice(0, 5)

  return {
    query,
    cuisines: matchedCuisines,
    restaurants: matchedRestaurants.map(r => r.name),
    message,
    confidence
  }
}

// OpenAI-powered semantic search
async function getAIResponse(query: string, restaurants: any[]) {
  if (!openai || restaurants.length === 0) {
    return keywordFallback(query, restaurants)
  }

  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o', // Full model for better understanding
      messages: [
        {
          role: 'system',
          content: `You are an expert restaurant recommendation assistant. Based on the user's query, analyze their intent and recommend the most relevant restaurants from the provided list.

Consider:
- Dietary restrictions and preferences (vegan, gluten-free, etc.)
- Cuisine types and specific dishes
- Mood and occasion (romantic, family-friendly, quick bite, comfort food)
- Time of day (breakfast, lunch, dinner, late night)
- Price sensitivity (look at minimum_order)
- Quality indicators (rating, reviewCount)

Respond with ONLY a JSON object (no markdown, no explanation):
{
  "cuisines": ["cuisine1", "cuisine2"],
  "restaurants": ["Restaurant Name 1", "Restaurant Name 2"],
  "message": "Friendly 1-2 sentence explanation of why these match",
  "confidence": 0.85
}`
        },
        {
          role: 'user',
          content: `User query: "${query}"

Available restaurants:
${JSON.stringify(restaurants.slice(0, 75), null, 2)}

Recommend the top 3-5 restaurants that best match the query.`
        }
      ],
      temperature: 0.7,
      max_tokens: 500
    }, {
      timeout: 5000 // 5 second timeout in options
    })

    const responseText = completion.choices[0]?.message?.content || ''

    // Parse JSON response
    const jsonMatch = responseText.match(/\{[\s\S]*\}/)
    if (jsonMatch) {
      const aiResponse = JSON.parse(jsonMatch[0])
      return {
        query,
        ...aiResponse
      }
    }

    // Fallback if parsing fails
    console.error('Failed to parse AI response:', responseText)
    return keywordFallback(query, restaurants)

  } catch (error: any) {
    console.error('OpenAI error:', error.message)
    // Fallback to keyword matching
    return keywordFallback(query, restaurants)
  }
}

export async function POST(request: NextRequest) {
  try {
    const { query } = await request.json()

    if (!query || query.trim().length === 0) {
      return NextResponse.json({ error: 'Query is required' }, { status: 400 })
    }

    // Get restaurant data from Supabase (with caching)
    const { restaurants } = await getRestaurantData()

    if (restaurants.length === 0) {
      return NextResponse.json({
        query,
        cuisines: [],
        restaurants: [],
        message: 'No restaurants available at the moment. Please try again later.',
        confidence: 0
      })
    }

    // Get AI-powered recommendations
    const aiResponse = await getAIResponse(query, restaurants)

    return NextResponse.json(aiResponse, {
      headers: {
        'Content-Type': 'application/json',
      }
    })

  } catch (error) {
    console.error('AI Search error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// Demo endpoint to show capabilities
export async function GET(request: NextRequest) {
  // Check for cache bypass parameter
  const clearCache = request.nextUrl.searchParams.get('clearCache')
  if (clearCache === 'true') {
    restaurantCache = null
  }

  const { restaurants } = await getRestaurantData()

  return NextResponse.json({
    status: 'ready',
    restaurantCount: restaurants.length,
    aiEnabled: !!openai,
    capabilities: {
      naturalLanguage: [
        'I want something healthy and spicy',
        'Comfort food for a rainy day',
        'Good options for a date night',
        'Vegan restaurants near me',
        'Quick lunch under 30 minutes'
      ],
      dietary: ['vegan', 'vegetarian', 'gluten-free', 'halal', 'kosher'],
      occasions: ['date night', 'family dinner', 'quick lunch', 'late night'],
      preferences: ['healthy', 'spicy', 'comfort food', 'light', 'hearty']
    },
    sampleRestaurants: restaurants.slice(0, 5).map(r => r.name)
  }, {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0'
    }
  })
}
