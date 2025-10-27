import { createClient } from '@/lib/supabase/server'
import { NearbyRestaurants } from '@/components/nearby-restaurants'
import { HeroSection } from '@/components/hero-section'
import { CouponsSection } from '@/components/coupons-section'
import { Footer } from '@/components/footer'
import Image from 'next/image'

export default async function HomePage() {
  const supabase = await createClient()

  // Get active restaurants with online ordering enabled
  const { data: restaurants, error } = await supabase
    .schema('menuca_v3')
    .from('restaurants')
    .select('*')
    .eq('status', 'active')
    .eq('online_ordering_enabled', true)
    .order('is_featured', { ascending: false })
    .limit(20)

  if (error) {
    console.error('Error fetching restaurants:', error)
    console.error('Error details:', JSON.stringify(error, null, 2))
  }

  console.log('Fetched restaurants count:', restaurants?.length || 0)
  if (restaurants && restaurants.length > 0) {
    console.log('Sample restaurant:', restaurants[0])

    // DEBUG: Check what data we have
    const sample = restaurants[0]
    console.log('DATA DEBUG - ACTUAL VALUES:', {
      average_rating: sample.average_rating,
      review_count: sample.review_count,
      delivery_fee: sample.delivery_fee,
      minimum_order: sample.minimum_order,
      estimated_delivery_time: sample.estimated_delivery_time,
      image_url: sample.image_url,
      og_image_url: sample.og_image_url
    })

    console.log('FULL RESTAURANT OBJECT KEYS:', Object.keys(sample))

    // Check how many have og_image_url
    const withImages = restaurants.filter(r => r.og_image_url).length
    console.log(`Restaurants with og_image_url: ${withImages} out of ${restaurants.length}`)
  }

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Image 
              src="/menu-ca-logo.png" 
              alt="Menu.ca" 
              width={140} 
              height={43}
              priority
              className="h-10 w-auto"
            />
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
      <HeroSection />

      {/* Restaurants Grid */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h3 className="text-2xl font-bold mb-6">Restaurants near you</h3>
        <NearbyRestaurants initialRestaurants={restaurants || []} />
      </section>

      {/* Coupons Section */}
      <CouponsSection />

      {/* Footer */}
      <Footer />
    </main>
  )
}
