import { createClient } from '@/lib/supabase/server'
import { notFound } from 'next/navigation'
import { RestaurantHeader } from '@/components/restaurant-header'
import { MenuDisplay } from '@/components/menu-display'
import { MiniCartButton } from '@/components/mini-cart-button'

export default async function RestaurantPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const supabase = await createClient()

  // Get restaurant by slug
  const { data: restaurant, error: restaurantError } = await supabase
    .from('restaurants')
    .select(`
      *,
      restaurant_locations (
        street_address,
        city_id,
        latitude,
        longitude
      ),
      restaurant_contacts (
        email,
        phone
      )
    `)
    .eq('slug', slug)
    .single()

  if (restaurantError || !restaurant) {
    notFound()
  }

  // Get full menu with categories and dishes
  const { data: menu, error: menuError } = await supabase
    .from('courses')
    .select(`
      id,
      name_en,
      name_fr,
      display_order,
      dishes (
        id,
        name_en,
        name_fr,
        description_en,
        description_fr,
        price,
        image_url,
        is_available,
        dish_modifiers (
          id,
          name_en,
          name_fr,
          price_modifier,
          modifier_type
        )
      )
    `)
    .eq('restaurant_id', restaurant.id)
    .eq('is_active', true)
    .order('display_order')

  if (menuError) {
    console.error('Error fetching menu:', menuError)
  }

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b sticky top-0 z-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-red-600">
              <a href="/">Menu.ca</a>
            </h1>
            <div className="flex items-center gap-4">
              <button className="text-gray-600 hover:text-gray-900">Sign In</button>
              <MiniCartButton />
            </div>
          </div>
        </div>
      </header>

      {/* Restaurant Header */}
      <RestaurantHeader restaurant={restaurant} />

      {/* Menu Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid lg:grid-cols-[1fr,380px] gap-8">
          {/* Menu Display */}
          <div>
            <MenuDisplay menu={menu || []} restaurantId={restaurant.id} />
          </div>

          {/* Sticky Cart Sidebar (Desktop) */}
          <div className="hidden lg:block">
            <div className="sticky top-24">
              {/* Cart will go here */}
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold mb-4">Your Order</h3>
                <p className="text-gray-500 text-sm">Your cart is empty</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Mobile Cart Button */}
      <div className="lg:hidden fixed bottom-0 left-0 right-0 p-4 bg-white border-t">
        <MiniCartButton fullWidth />
      </div>
    </main>
  )
}

