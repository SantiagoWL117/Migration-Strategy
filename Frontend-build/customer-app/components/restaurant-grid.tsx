'use client'

import Link from 'next/link'
import { RestaurantCard } from './restaurant-card'

interface Restaurant {
  id: number
  name: string
  slug: string
  logo_url?: string
  description?: string
  cuisines?: string[]
  is_online: boolean
  distance_km?: number
  avg_rating?: number
  total_reviews?: number
}

interface RestaurantGridProps {
  restaurants: Restaurant[]
}

export function RestaurantGrid({ restaurants }: RestaurantGridProps) {
  if (!restaurants || restaurants.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500 text-lg">No restaurants found</p>
        <p className="text-gray-400 mt-2">Try adjusting your search or location</p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {restaurants.map((restaurant) => (
        <Link
          key={restaurant.id}
          href={`/r/${restaurant.slug}`}
          className="block hover:transform hover:scale-[1.02] transition-transform"
        >
          <RestaurantCard restaurant={restaurant} />
        </Link>
      ))}
    </div>
  )
}

