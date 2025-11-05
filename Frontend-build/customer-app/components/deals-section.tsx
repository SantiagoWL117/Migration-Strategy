'use client'

import { useState, useEffect } from 'react'
import { Sparkles, MapPin, Loader2, ChevronLeft, ChevronRight } from 'lucide-react'
import { DealCard } from './deal-card'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import type { DiscountType } from '@/lib/promotions/types'

interface Deal {
  deal_id: number
  deal_title: string
  deal_description?: string
  discount_type: DiscountType
  discount_value: number
  restaurant_id: number
  restaurant_name: string
  restaurant_logo?: string
  restaurant_slug: string
  start_date: string
  end_date: string
  min_order_amount?: number
  service_types: string[]
  deal_type: string
  distance_km?: number
}

interface DealsSectionProps {
  maxDeals?: number
  radius?: number // kilometers
  language?: string
}

export function DealsSection({
  maxDeals = 12,
  radius = 10,
  language = 'en'
}: DealsSectionProps) {
  const router = useRouter()
  const [deals, setDeals] = useState<Deal[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null)
  const [locationPermission, setLocationPermission] = useState<'granted' | 'denied' | 'prompt'>('prompt')

  // Get user's geolocation
  useEffect(() => {
    const getLocation = () => {
      if ('geolocation' in navigator) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            setUserLocation({
              lat: position.coords.latitude,
              lng: position.coords.longitude,
            })
            setLocationPermission('granted')
          },
          (error) => {
            console.error('Geolocation error:', error)
            setLocationPermission('denied')
            // Still fetch deals without location filtering
          }
        )
      } else {
        console.log('Geolocation not supported')
        setLocationPermission('denied')
      }
    }

    getLocation()
  }, [])

  // Fetch deals
  useEffect(() => {
    const fetchDeals = async () => {
      setIsLoading(true)
      setError(null)

      try {
        const supabase = createClient()

        // Query deals with restaurant information
        const { data: dealsData, error: dealsError } = await supabase
          .from('promotional_deals')
          .select(`
            id,
            deal_title,
            deal_description,
            discount_type,
            discount_value,
            start_date,
            end_date,
            min_order_amount,
            service_types,
            deal_type,
            is_active,
            restaurant:restaurants!inner (
              id,
              name,
              slug,
              logo_url,
              latitude,
              longitude
            )
          `)
          .eq('is_active', true)
          .gte('end_date', new Date().toISOString())
          .lte('start_date', new Date().toISOString())
          .order('display_order', { ascending: true })
          .limit(maxDeals * 2) // Fetch more for filtering

        if (dealsError) {
          console.error('Error fetching deals:', dealsError)
          setError('Failed to load deals')
          return
        }

        if (!dealsData || dealsData.length === 0) {
          setDeals([])
          return
        }

        // Transform data
        let transformedDeals: Deal[] = dealsData.map((deal: any) => ({
          deal_id: deal.id,
          deal_title: deal.deal_title,
          deal_description: deal.deal_description,
          discount_type: deal.discount_type,
          discount_value: deal.discount_value,
          restaurant_id: deal.restaurant.id,
          restaurant_name: deal.restaurant.name,
          restaurant_logo: deal.restaurant.logo_url,
          restaurant_slug: deal.restaurant.slug,
          start_date: deal.start_date,
          end_date: deal.end_date,
          min_order_amount: deal.min_order_amount,
          service_types: deal.service_types || ['delivery'],
          deal_type: deal.deal_type,
        }))

        // Filter by distance if location available
        if (userLocation) {
          transformedDeals = transformedDeals
            .map((deal: any) => {
              const restaurant = dealsData.find((d: any) => d.restaurant.id === deal.restaurant_id)?.restaurant
              if (restaurant?.latitude && restaurant?.longitude) {
                const distance = calculateDistance(
                  userLocation.lat,
                  userLocation.lng,
                  restaurant.latitude,
                  restaurant.longitude
                )
                return { ...deal, distance_km: distance }
              }
              return { ...deal, distance_km: 999 } // Put restaurants without coordinates at end
            })
            .filter((deal: Deal) => deal.distance_km! <= radius)
            .sort((a: Deal, b: Deal) => (a.distance_km || 999) - (b.distance_km || 999))
        }

        // Limit to maxDeals
        setDeals(transformedDeals.slice(0, maxDeals))
      } catch (err) {
        console.error('Failed to fetch deals:', err)
        setError('Failed to load deals')
      } finally {
        setIsLoading(false)
      }
    }

    fetchDeals()
  }, [userLocation, maxDeals, radius])

  // Calculate distance between two coordinates (Haversine formula)
  const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
    const R = 6371 // Earth's radius in kilometers
    const dLat = toRad(lat2 - lat1)
    const dLon = toRad(lon2 - lon1)
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  const toRad = (value: number): number => {
    return (value * Math.PI) / 180
  }

  const handleViewDeal = (restaurantSlug: string) => {
    router.push(`/restaurant/${restaurantSlug}`)
  }

  // Loading state
  if (isLoading) {
    return (
      <section className="py-16 bg-gradient-to-b from-gray-50 to-white">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-center py-20">
            <Loader2 className="w-8 h-8 text-red-600 animate-spin" />
          </div>
        </div>
      </section>
    )
  }

  // Error state
  if (error) {
    return (
      <section className="py-16 bg-gradient-to-b from-gray-50 to-white">
        <div className="container mx-auto px-4">
          <div className="text-center py-20">
            <p className="text-gray-600">{error}</p>
          </div>
        </div>
      </section>
    )
  }

  // No deals state
  if (deals.length === 0) {
    return null // Don't show section if no deals available
  }

  return (
    <section className="py-16 bg-gradient-to-b from-gray-50 to-white">
      <div className="container mx-auto px-4">
        {/* Section Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-white" fill="white" />
              </div>
              <h2 className="text-3xl font-bold text-gray-900">Hot Deals Near You</h2>
            </div>
            {userLocation && locationPermission === 'granted' ? (
              <p className="text-gray-600 flex items-center gap-2">
                <MapPin className="w-4 h-4 text-green-600" />
                Showing deals within {radius}km of your location
              </p>
            ) : (
              <p className="text-gray-600">Discover the best deals from local restaurants</p>
            )}
          </div>
        </div>

        {/* Location Permission Prompt */}
        {locationPermission === 'denied' && (
          <div className="mb-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <MapPin className="w-5 h-5 text-blue-600 mt-0.5" />
              <div>
                <p className="text-sm text-blue-900 font-medium">Enable location for nearby deals</p>
                <p className="text-xs text-blue-700 mt-1">
                  Allow location access to see deals from restaurants near you.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Deals Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {deals.map((deal) => (
            <DealCard
              key={deal.deal_id}
              dealId={deal.deal_id}
              title={deal.deal_title}
              description={deal.deal_description}
              discountType={deal.discount_type}
              discountValue={deal.discount_value}
              restaurantName={deal.restaurant_name}
              restaurantLogo={deal.restaurant_logo}
              restaurantSlug={deal.restaurant_slug}
              startDate={deal.start_date}
              endDate={deal.end_date}
              minOrderAmount={deal.min_order_amount}
              serviceTypes={deal.service_types}
              dealType={deal.deal_type}
              onViewDeal={() => handleViewDeal(deal.restaurant_slug)}
            />
          ))}
        </div>

        {/* View All Link */}
        {deals.length >= maxDeals && (
          <div className="text-center mt-8">
            <button
              onClick={() => router.push('/deals')}
              className="inline-flex items-center gap-2 px-6 py-3 bg-white border-2 border-red-600 text-red-600 rounded-lg font-semibold hover:bg-red-50 transition-colors"
            >
              View All Deals
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        )}
      </div>
    </section>
  )
}
