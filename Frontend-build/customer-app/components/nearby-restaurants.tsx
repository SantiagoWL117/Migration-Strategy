'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { RestaurantGrid } from './restaurant-grid'
import { Restaurant } from '@/lib/types/database'

interface NearbyRestaurantsProps {
  initialRestaurants: Restaurant[]
}

export function NearbyRestaurants({ initialRestaurants }: NearbyRestaurantsProps) {
  const [restaurants, setRestaurants] = useState<Restaurant[]>(initialRestaurants)
  const [isLoading, setIsLoading] = useState(false)
  const [location, setLocation] = useState<{ latitude: number; longitude: number } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loadingMore, setLoadingMore] = useState(false)
  const [hasMore, setHasMore] = useState(true)
  const [offset, setOffset] = useState(20)

  useEffect(() => {
    // Get user's location on mount
    if ('geolocation' in navigator) {
      setIsLoading(true)
      navigator.geolocation.getCurrentPosition(
        async (position) => {
          const { latitude, longitude } = position.coords
          setLocation({ latitude, longitude })

          // Fetch restaurants near user
          await fetchNearbyRestaurants(latitude, longitude)
        },
        (error) => {
          console.error('Geolocation error:', error)
          setError('Unable to get your location. Showing all restaurants.')
          setIsLoading(false)
        }
      )
    } else {
      setError('Geolocation not supported by your browser.')
      setIsLoading(false)
    }
  }, [])

  const fetchNearbyRestaurants = async (lat: number, lng: number, limit: number = 100) => {
    try {
      const supabase = createClient()

      console.log('Calling find_nearby_restaurants with:', { lat, lng, limit })

      // Use the RPC function to get restaurants with distance calculation - increased radius to get ALL restaurants with distances
      // Note: RPC functions need explicit schema specification even with default schema set
      const { data, error } = await supabase
        .schema('menuca_v3')
        .rpc('find_nearby_restaurants', {
          p_latitude: lat,
          p_longitude: lng,
          p_radius_km: 10000, // 10,000km radius - basically unlimited to get all restaurants with distances
          p_limit: limit
        })

      console.log('RPC response:', { data, error, dataLength: data?.length })

      if (error) {
        console.error('Error fetching nearby restaurants:', error)
        console.error('Error details:', JSON.stringify(error, null, 2))
        setError('Unable to calculate distances. Showing all restaurants.')
        // Fallback to showing initial restaurants
        setRestaurants(initialRestaurants)
      } else if (data && data.length > 0) {
        // Enhance with full restaurant data
        const restaurantIds = data.map((r: any) => r.restaurant_id)
        const { data: fullData, error: fullError } = await supabase
          .from('restaurants')
          .select('*')
          .in('id', restaurantIds)

        if (fullData && fullData.length > 0) {
          // Merge distance data with full restaurant data
          const enrichedData = fullData.map(restaurant => {
            const distanceInfo = data.find((d: any) => d.restaurant_id === restaurant.id)
            return {
              ...restaurant,
              distance_km: distanceInfo?.distance_km || null,
              can_deliver: distanceInfo?.can_deliver || false
            }
          })
          // Sort by distance (closest first)
          enrichedData.sort((a, b) => (a.distance_km || 999) - (b.distance_km || 999))
          setRestaurants(enrichedData)
        } else {
          // No full data found, keep initial restaurants
          setRestaurants(initialRestaurants)
        }
      } else {
        // RPC returned empty array - restaurants don't have location data
        console.warn('find_nearby_restaurants returned 0 results - restaurants may not have latitude/longitude data')
        setError('📍 Restaurants don\'t have location data yet. Showing all restaurants.')
        setRestaurants(initialRestaurants)
      }
    } catch (err) {
      console.error('Fetch error:', err)
      setError('Error loading restaurants. Showing all restaurants.')
      setRestaurants(initialRestaurants)
    } finally {
      setIsLoading(false)
    }
  }

  const fetchAllRestaurants = async (limit: number = 20) => {
    const supabase = createClient()
    const { data, error } = await supabase
      .schema('menuca_v3')
      .from('restaurants')
      .select('*')
      .eq('status', 'active')
      .eq('online_ordering_enabled', true)
      .order('is_featured', { ascending: false })
      .limit(limit)

    if (!error && data) {
      setRestaurants(data)
    }
  }

  const loadMore = async () => {
    setLoadingMore(true)
    try {
      const supabase = createClient()

      // Get IDs of restaurants we already have to avoid duplicates
      const existingIds = restaurants.map(r => r.id)

      const { data, error } = await supabase
        .schema('menuca_v3')
        .from('restaurants')
        .select('*')
        .eq('status', 'active')
        .eq('online_ordering_enabled', true)
        .not('id', 'in', `(${existingIds.join(',')})`)
        .order('is_featured', { ascending: false })
        .limit(20)

      if (error) {
        console.error('Error loading more:', error)
      } else if (data) {
        if (data.length < 20) {
          setHasMore(false)
        }
        if (data.length === 0) {
          setHasMore(false)
        } else {
          setRestaurants([...restaurants, ...data])
          setOffset(offset + data.length)
        }
      }
    } catch (err) {
      console.error('Load more error:', err)
    } finally {
      setLoadingMore(false)
    }
  }

  return (
    <div>
      {/* Location Status */}
      {location && (
        <div className="mb-4 text-sm text-gray-600">
          📍 Showing restaurants near your location
        </div>
      )}
      {error && (
        <div className="mb-4 text-sm text-amber-600">
          ⚠️ {error}
        </div>
      )}

      {/* Restaurant Grid */}
      <RestaurantGrid restaurants={restaurants} isLoading={isLoading} />

      {/* Load More Button */}
      {!isLoading && hasMore && restaurants.length >= 20 && (
        <div className="mt-8 text-center">
          <button
            onClick={loadMore}
            disabled={loadingMore}
            className="bg-red-600 text-white px-8 py-3 rounded-lg hover:bg-red-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            {loadingMore ? 'Loading...' : 'Load More Restaurants'}
          </button>
        </div>
      )}

      {!hasMore && restaurants.length > 20 && (
        <div className="mt-8 text-center text-gray-500">
          You've reached the end of the list
        </div>
      )}
    </div>
  )
}
