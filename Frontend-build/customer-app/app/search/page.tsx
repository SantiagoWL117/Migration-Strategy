import { createClient } from '@/lib/supabase/server'
import { SearchBar } from '@/components/search-bar'
import Image from 'next/image'
import Link from 'next/link'
import { ArrowLeft, Sparkles, Star, Clock, DollarSign, X, RefreshCw, ChevronDown, MapPin } from 'lucide-react'

// AI Analysis of queries
async function analyzeQuery(query: string) {
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_URL || 'http://localhost:3000'}/api/ai-search`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query }),
      cache: 'no-store'
    })
    
    if (response.ok) {
      return await response.json()
    }
  } catch (error) {
    console.error('AI analysis error:', error)
  }
  
  return null
}

export default async function SearchPage({
  searchParams
}: {
  searchParams: Promise<{ q?: string; location?: string }>
}) {
  const params = await searchParams
  const query = params.q || ''
  const supabase = await createClient()

  // Get AI analysis
  const aiAnalysis = query ? await analyzeQuery(query) : null

  // Get all active restaurants with online ordering enabled
  const { data: allRestaurants, error } = await supabase
    .schema('menuca_v3')
    .from('restaurants')
    .select('*')
    .eq('status', 'active')
    .eq('online_ordering_enabled', true)
    .order('is_featured', { ascending: false })
    .limit(50)

  if (error) {
    console.error('Error fetching restaurants:', error)
    console.error('Error details:', JSON.stringify(error, null, 2))
  }

  console.log('Search page - Fetched restaurants count:', allRestaurants?.length || 0)

  // Filter restaurants based on AI recommendations
  let filteredRestaurants = allRestaurants || []
  let perfectMatches: any[] = []
  let goodMatches: any[] = []
  let otherResults: any[] = []

  if (aiAnalysis && aiAnalysis.restaurants.length > 0) {
    perfectMatches = filteredRestaurants.filter(r => 
      aiAnalysis.restaurants.slice(0, 2).includes(r.name)
    )
    goodMatches = filteredRestaurants.filter(r => 
      aiAnalysis.restaurants.slice(2).includes(r.name)
    )
    otherResults = filteredRestaurants.filter(r => 
      !aiAnalysis.restaurants.includes(r.name)
    ).slice(0, 4)
  } else if (query) {
    filteredRestaurants = filteredRestaurants.filter(restaurant => {
      const nameMatch = restaurant.name.toLowerCase().includes(query.toLowerCase())
      const descMatch = restaurant.description?.toLowerCase().includes(query.toLowerCase())
      const cuisineMatch = restaurant.cuisine_type?.toLowerCase().includes(query.toLowerCase())
      return nameMatch || descMatch || cuisineMatch
    })
  }

  const intentTags = aiAnalysis?.message ? [
    ...(query.toLowerCase().includes('healthy') ? ['Healthy'] : []),
    ...(query.toLowerCase().includes('spicy') ? ['Spicy'] : []),
    ...(query.toLowerCase().includes('vegan') ? ['Vegan'] : []),
    ...(query.toLowerCase().includes('late') ? ['Late Night'] : []),
    ...(query.toLowerCase().includes('cheap') ? ['Budget Friendly'] : []),
  ] : []

  const relatedSearches = [
    'healthy lunch options',
    'spicy asian food',
    'vegan restaurants',
    'late night delivery',
    'romantic dinner spots'
  ]

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Premium Header */}
      <header className="bg-white border-b sticky top-0 z-20 backdrop-blur-lg bg-white/90">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <Link href="/" className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors">
              <ArrowLeft className="w-5 h-5" />
            </Link>
            <Image 
              src="/menu-ca-logo.png" 
              alt="Menu.ca" 
              width={100} 
              height={30}
              className="h-8 w-auto"
            />
            <div className="flex-1">
              <SearchBar />
            </div>
          </div>
        </div>
      </header>

      {/* AI Response Section - Premium Style */}
      {aiAnalysis && aiAnalysis.confidence > 0 && (
        <section className="relative bg-gradient-to-r from-red-600 to-orange-600 text-white overflow-hidden">
          <div className="absolute inset-0 bg-black/10" />
          <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div className="flex items-start gap-4">
              <div className="relative">
                <div className="absolute -inset-1 bg-white/30 rounded-full blur" />
                <div className="relative bg-white/20 backdrop-blur-xl p-3 rounded-full">
                  <Sparkles className="w-6 h-6 text-yellow-300 animate-pulse" />
                </div>
              </div>
              <div className="flex-1">
                <h2 className="text-xl font-bold mb-2 flex items-center gap-3 drop-shadow-lg">
                  AI understood: "{query}"
                  <span className="text-sm bg-white/20 backdrop-blur text-white px-3 py-1 rounded-full shadow-lg">
                    {Math.round(aiAnalysis.confidence * 100)}% confidence
                  </span>
                </h2>
                <p className="text-red-50 mb-4 text-lg drop-shadow">{aiAnalysis.message}</p>
                {intentTags.length > 0 && (
                  <div className="flex flex-wrap gap-2">
                    {intentTags.map((tag, index) => (
                      <span 
                        key={tag} 
                        className="bg-white/10 backdrop-blur px-4 py-1.5 rounded-full text-sm font-medium text-white border border-white/20 animate-float"
                        style={{ animationDelay: `${index * 0.1}s` }}
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        </section>
      )}

      {/* Results Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Premium Sort Options */}
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            {query ? `Results for "${query}"` : 'All Restaurants'}
          </h1>
          <div className="relative">
            <select className="appearance-none bg-white border border-gray-200 rounded-xl px-4 py-2.5 pr-10 text-sm font-medium focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all cursor-pointer hover:border-gray-300">
              <option value="ai">🤖 AI Recommended</option>
              <option value="rating">⭐ Top Rated</option>
              <option value="delivery">🚚 Fastest Delivery</option>
              <option value="price">💰 Price: Low to High</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-500 pointer-events-none" />
          </div>
        </div>

        {/* Perfect Matches - Premium Dark Section */}
        {perfectMatches.length > 0 && (
          <div className="mb-12 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-8 bg-gray-900">
            <h2 className="text-2xl font-bold mb-6 text-white flex items-center gap-3">
              <Star className="w-6 h-6 text-yellow-500 fill-current animate-pulse" />
              Perfect Matches
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {perfectMatches.map((restaurant) => (
                <Link key={restaurant.id} href={`/r/${restaurant.slug}`} className="group relative">
                  <div className="absolute -inset-0.5 bg-gradient-to-r from-red-600 to-orange-600 rounded-2xl opacity-0 group-hover:opacity-100 blur transition duration-300" />
                  <div className="relative">
                    <RestaurantCardPremium restaurant={restaurant} badge="Perfect Match" />
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Good Matches */}
        {goodMatches.length > 0 && (
          <div className="mb-12">
            <h2 className="text-xl font-bold mb-6 text-gray-900">Also Consider</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {goodMatches.map((restaurant) => (
                <Link key={restaurant.id} href={`/r/${restaurant.slug}`} className="group">
                  <RestaurantCardPremium restaurant={restaurant} badge="Good Match" badgeColor="blue" />
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* All Results */}
        {(!aiAnalysis || aiAnalysis.confidence === 0) && filteredRestaurants.length > 0 && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {filteredRestaurants.map((restaurant) => (
              <Link key={restaurant.id} href={`/r/${restaurant.slug}`} className="group">
                <RestaurantCardPremium restaurant={restaurant} />
              </Link>
            ))}
          </div>
        )}

        {/* Other Results */}
        {otherResults.length > 0 && (
          <div className="mb-12">
            <h2 className="text-xl font-bold mb-6 text-gray-900">Other Restaurants Nearby</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {otherResults.map((restaurant) => (
                <Link key={restaurant.id} href={`/r/${restaurant.slug}`} className="group">
                  <RestaurantCardPremium restaurant={restaurant} />
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* No Results */}
        {filteredRestaurants.length === 0 && perfectMatches.length === 0 && goodMatches.length === 0 && (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">🍕</div>
            <p className="text-xl text-gray-600 mb-2">No restaurants found matching your search.</p>
            <p className="text-gray-500">Try a different search term or browse all restaurants!</p>
          </div>
        )}
      </section>

      {/* Refine Search Section - Premium Style */}
      {query && (
        <section className="bg-gradient-to-b from-gray-100 to-gray-50 py-10">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h3 className="text-xl font-bold mb-6 text-gray-900">Refine your search</h3>
            <div className="flex flex-wrap gap-3">
              {['Too spicy?', 'Cheaper options', 'Faster delivery', 'Different cuisine'].map((option, index) => (
                <button 
                  key={option}
                  className="group relative bg-white px-5 py-3 rounded-xl shadow-sm hover:shadow-lg transition-all transform hover:-translate-y-0.5"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-red-600 to-orange-600 rounded-xl opacity-0 group-hover:opacity-10 transition-opacity" />
                  <span className="relative flex items-center gap-2 font-medium text-gray-700">
                    {index === 0 && <X className="w-4 h-4" />}
                    {index === 1 && <DollarSign className="w-4 h-4" />}
                    {index === 2 && <Clock className="w-4 h-4" />}
                    {index === 3 && <RefreshCw className="w-4 h-4" />}
                    {option}
                  </span>
                </button>
              ))}
            </div>

            {/* Related Searches */}
            <div className="mt-10">
              <h4 className="text-lg font-semibold mb-4 text-gray-900">Try these searches</h4>
              <div className="flex flex-wrap gap-2">
                {relatedSearches.map(search => (
                  <Link
                    key={search}
                    href={`/search?q=${encodeURIComponent(search)}`}
                    className="bg-white hover:bg-gradient-to-r hover:from-red-50 hover:to-orange-50 px-4 py-2 rounded-full text-sm text-gray-700 hover:text-red-600 transition-all border border-gray-200 hover:border-red-200"
                  >
                    {search}
                  </Link>
                ))}
              </div>
            </div>
          </div>
        </section>
      )}
    </main>
  )
}

// Premium Restaurant Card Component
function RestaurantCardPremium({ 
  restaurant, 
  badge, 
  badgeColor = 'gradient' 
}: { 
  restaurant: any
  badge?: string
  badgeColor?: 'gradient' | 'blue'
}) {
  return (
    <div className="relative bg-white rounded-2xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 group">
      {/* Badge */}
      {badge && (
        <div className={`absolute top-3 right-3 z-10 text-white text-xs px-3 py-1.5 rounded-full font-semibold ${
          badgeColor === 'blue' ? 'bg-blue-600' : 'bg-gradient-to-r from-red-600 to-orange-600'
        } shadow-lg animate-float`}>
          {badge}
        </div>
      )}

      {/* Image */}
      <div className="relative h-48 bg-gray-200 overflow-hidden">
        {restaurant.image_url ? (
          <Image
            src={restaurant.image_url}
            alt={restaurant.name}
            fill
            className="object-cover group-hover:scale-110 transition-transform duration-300"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <span className="text-4xl font-bold">{restaurant.name[0]}</span>
          </div>
        )}
        
        {/* Image Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
        
        {/* Quick Info Overlay */}
        <div className="absolute bottom-2 left-2 right-2 flex items-center justify-between text-white opacity-0 group-hover:opacity-100 transition-opacity">
          <span className="text-sm bg-black/50 backdrop-blur px-2 py-1 rounded">
            {restaurant.estimated_delivery_time || '30-45 min'}
          </span>
          {restaurant.delivery_fee !== null && (
            <span className="text-sm bg-black/50 backdrop-blur px-2 py-1 rounded">
              ${restaurant.delivery_fee.toFixed(2)} delivery
            </span>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="p-5">
        <h3 className="font-bold text-lg text-gray-900 mb-1 group-hover:text-red-600 transition-colors">
          {restaurant.name}
        </h3>
        <p className="text-sm text-gray-600 mb-3">{restaurant.cuisine_type || 'Restaurant'}</p>
        
        {/* Rating and Info */}
        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-1">
            <Star className="w-4 h-4 text-yellow-500 fill-current" />
            <span className="font-medium">{restaurant.average_rating || '4.5'}</span>
            {restaurant.review_count > 0 && (
              <span className="text-gray-500">({restaurant.review_count})</span>
            )}
          </div>
          
          <div className="flex items-center gap-1 text-gray-500">
            <MapPin className="w-3 h-3" />
            <span>1.2 km</span>
          </div>
        </div>

        {/* Minimum Order */}
        {restaurant.minimum_order > 0 && (
          <div className="mt-2 text-xs text-gray-500">
            Min order ${restaurant.minimum_order}
          </div>
        )}
      </div>
    </div>
  )
}