import { createClient } from '@/lib/supabase/server'
import { RestaurantGrid } from '@/components/restaurant-grid'
import { SearchBar } from '@/components/search-bar'

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; location?: string }>
}) {
  const params = await searchParams
  const query = params.q || ''
  const location = params.location || ''

  const supabase = await createClient()

  // Use full-text search if query provided
  const { data: restaurants, error } = query
    ? await supabase.rpc('search_restaurants_full_text', {
        p_search_query: query,
        p_limit: 50
      })
    : await supabase.rpc('get_restaurants_near_location', {
        p_latitude: 43.6532,
        p_longitude: -79.3832,
        p_radius_km: 10
      })

  if (error) {
    console.error('Error searching restaurants:', error)
  }

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-2xl font-bold text-red-600">
              <a href="/">Menu.ca</a>
            </h1>
            <nav className="flex items-center gap-4">
              <button className="text-gray-600 hover:text-gray-900">Sign In</button>
              <button className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700">
                Sign Up
              </button>
            </nav>
          </div>
          <SearchBar />
        </div>
      </header>

      {/* Search Results */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-6">
          <h2 className="text-2xl font-bold">
            {query ? `Search results for "${query}"` : 'All restaurants'}
          </h2>
          <p className="text-gray-600 mt-1">
            {restaurants?.length || 0} restaurants found
          </p>
        </div>

        <RestaurantGrid restaurants={restaurants || []} />
      </section>
    </main>
  )
}

