// TypeScript types for Yelp Fusion API v3
// Documentation: https://www.yelp.com/developers/documentation/v3

export interface YelpBusinessMatchResponse {
  businesses: YelpBusiness[]
}

export interface YelpBusiness {
  id: string
  alias: string
  name: string
  image_url: string
  is_closed: boolean
  url: string
  review_count: number
  categories: YelpCategory[]
  rating: number
  coordinates: YelpCoordinates
  transactions: string[]
  price?: string
  location: YelpLocation
  phone: string
  display_phone: string
  distance?: number
}

export interface YelpCategory {
  alias: string
  title: string
}

export interface YelpCoordinates {
  latitude: number
  longitude: number
}

export interface YelpLocation {
  address1: string
  address2?: string | null
  address3?: string | null
  city: string
  zip_code: string
  country: string
  state: string
  display_address: string[]
}

export interface YelpReviewsResponse {
  reviews: YelpReview[]
  total: number
  possible_languages: string[]
}

export interface YelpReview {
  id: string
  url: string
  text: string // Note: Only first 160 characters returned
  rating: number
  time_created: string // ISO 8601 format
  user: YelpUser
}

export interface YelpUser {
  id: string
  profile_url: string
  image_url?: string | null
  name: string
}

export interface YelpAPIError {
  error: {
    code: string
    description: string
  }
}

// Database types for inserting reviews
export interface RestaurantReviewInsert {
  restaurant_id: number
  user_id?: number | null // NULL for external Yelp reviews
  order_id?: number | null
  rating: number // 1-5
  review_text: string
  source: 'yelp' | 'menu.ca'
  external_review_id?: string | null // Yelp review ID
  external_user_name?: string | null // Yelp user name
  external_user_image?: string | null // Yelp user image
  created_at?: string
  yelp_business_id?: string | null // Store for future reference
  yelp_business_url?: string | null
}

// Script configuration
export interface YelpScriptConfig {
  apiKey: string
  dryRun: boolean
  maxRestaurants?: number
  delayBetweenRequests: number // milliseconds
  maxReviewsPerRestaurant: number
}

// Script result tracking
export interface YelpScriptResult {
  restaurantId: number
  restaurantName: string
  matched: boolean
  yelpBusinessId?: string
  yelpRating?: number
  yelpReviewCount?: number
  reviewsInserted: number
  error?: string
}
