'use client'

import Link from 'next/link'
import { RestaurantCard } from './restaurant-card'
import { RestaurantGridSkeleton } from './skeleton-loader'
import { Restaurant } from '@/lib/types/database'

interface RestaurantGridProps {
  restaurants: Restaurant[]
  isLoading?: boolean
}

export function RestaurantGrid({ restaurants, isLoading }: RestaurantGridProps) {
  if (isLoading) {
    return <RestaurantGridSkeleton count={6} />
  }
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

