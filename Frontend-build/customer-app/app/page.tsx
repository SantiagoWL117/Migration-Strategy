import { createClient } from '@/lib/supabase/server'
import { RestaurantGrid } from '@/components/restaurant-grid'
import { SearchBar } from '@/components/search-bar'

export default async function HomePage() {
  const supabase = await createClient()

  // Get nearby restaurants (default location: Toronto)
  const { data: restaurants, error } = await supabase.rpc('get_restaurants_near_location', {
    p_latitude: 43.6532,
    p_longitude: -79.3832,
    p_radius_km: 10
  })

  if (error) {
    console.error('Error fetching restaurants:', error)
  }

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-red-600">Menu.ca</h1>
            <nav className="flex items-center gap-4">
              <button className="text-gray-600 hover:text-gray-900">Sign In</button>
              <button className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700">
                Sign Up
              </button>
            </nav>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="bg-gradient-to-r from-red-600 to-red-700 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl">
            <h2 className="text-4xl font-bold mb-4">
              Order food from your favorite restaurants
            </h2>
            <p className="text-xl text-red-100 mb-8">
              Browse menus from 961 restaurants and get delivery in minutes
            </p>
            <SearchBar />
          </div>
        </div>
      </section>

      {/* Restaurants Grid */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h3 className="text-2xl font-bold mb-6">Restaurants near you</h3>
        <RestaurantGrid restaurants={restaurants || []} />
      </section>
    </main>
  )
}
