// Database client for scripts (Node.js environment)
// This file creates a Supabase client that works outside of Next.js context

import { createClient } from '@supabase/supabase-js'
import * as dotenv from 'dotenv'
import * as path from 'path'

// Load environment variables FIRST
dotenv.config({ path: path.resolve(__dirname, '../.env') })

const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error(
    'Missing Supabase environment variables. Please ensure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set in .env'
  )
}

// Create a Supabase client with service role key (bypasses RLS)
export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  db: {
    schema: 'menuca_v3'
  },
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
})

// Utility functions for common queries

export async function getActiveRestaurants() {
  const { data, error } = await supabase
    .from('restaurants')
    .select(`
      id,
      name,
      slug,
      restaurant_locations!inner(
        id,
        phone,
        street_address,
        city_id,
        postal_code,
        latitude,
        longitude,
        cities(
          name,
          provinces(
            short_name
          )
        )
      )
    `)
    .eq('status', 'active')
    .eq('online_ordering_enabled', true)
    .eq('restaurant_locations.is_active', true)

  if (error) {
    throw new Error(`Failed to fetch restaurants: ${error.message}`)
  }

  return data
}

export async function insertRestaurantReview(review: {
  restaurant_id: number
  user_id?: number | null
  order_id?: number | null
  rating: number
  review_text: string
  source?: string
  external_review_id?: string | null
  external_user_name?: string | null
  external_user_image?: string | null
  yelp_business_id?: string | null
  yelp_business_url?: string | null
}) {
  const { data, error } = await supabase
    .from('restaurant_reviews')
    .insert({
      ...review,
      source: review.source || 'yelp',
      created_at: new Date().toISOString()
    })
    .select()
    .single()

  if (error) {
    throw new Error(`Failed to insert review: ${error.message}`)
  }

  return data
}

export async function getRestaurantReviewCount(restaurantId: number) {
  const { count, error } = await supabase
    .from('restaurant_reviews')
    .select('*', { count: 'exact', head: true })
    .eq('restaurant_id', restaurantId)

  if (error) {
    throw new Error(`Failed to count reviews: ${error.message}`)
  }

  return count || 0
}

export async function checkYelpBusinessExists(yelpBusinessId: string) {
  const { data, error } = await supabase
    .from('restaurant_reviews')
    .select('id')
    .eq('yelp_business_id', yelpBusinessId)
    .limit(1)

  if (error) {
    throw new Error(`Failed to check Yelp business: ${error.message}`)
  }

  return data && data.length > 0
}
