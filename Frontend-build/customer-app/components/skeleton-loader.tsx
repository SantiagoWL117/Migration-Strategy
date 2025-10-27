export function RestaurantCardSkeleton() {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden animate-pulse">
      {/* Image skeleton */}
      <div className="h-48 bg-gray-200" />
      
      {/* Content skeleton */}
      <div className="p-4 space-y-3">
        {/* Title */}
        <div className="h-6 bg-gray-200 rounded w-3/4" />
        
        {/* Description */}
        <div className="space-y-2">
          <div className="h-4 bg-gray-200 rounded" />
          <div className="h-4 bg-gray-200 rounded w-5/6" />
        </div>
        
        {/* Meta info */}
        <div className="flex items-center gap-4 pt-2">
          <div className="h-4 bg-gray-200 rounded w-16" />
          <div className="h-4 bg-gray-200 rounded w-20" />
          <div className="h-4 bg-gray-200 rounded w-24" />
        </div>
      </div>
    </div>
  )
}

export function RestaurantGridSkeleton({ count = 8 }: { count?: number }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {Array.from({ length: count }).map((_, i) => (
        <RestaurantCardSkeleton key={i} />
      ))}
    </div>
  )
}
