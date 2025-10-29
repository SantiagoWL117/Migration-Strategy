import { createClient } from '@/lib/supabase/server'
import { notFound } from 'next/navigation'
import { RestaurantHeader } from '@/components/restaurant-header'
import { MenuDisplay } from '@/components/menu-display'
import { MiniCartButton } from '@/components/mini-cart-button'
import { CartSidebar } from '@/components/cart-sidebar'

export default async function RestaurantPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const supabase = await createClient()

  // Get restaurant by slug - using menuca_v3 schema
  const { data: restaurant, error: restaurantError } = await supabase
    .from('restaurants')
    .select('*')
    .eq('slug', slug)
    .eq('status', 'active')
    .single()

  if (restaurantError || !restaurant) {
    console.error('Restaurant not found:', restaurantError)
    notFound()
  }

  console.log('Restaurant loaded:', { id: restaurant.id, name: restaurant.name, slug: restaurant.slug })

  // Get restaurant location separately
  const { data: location } = await supabase
    .from('restaurant_locations')
    .select('*')
    .eq('restaurant_id', restaurant.id)
    .single()

  // Get courses and dishes separately (65% of dishes have NULL course_id)
  const { data: courses, error: coursesError } = await supabase
    .from('courses')
    .select('*')
    .eq('restaurant_id', restaurant.id)
    .eq('is_active', true)
    .order('display_order')

  const { data: dishes, error: dishesError } = await supabase
    .from('dishes')
    .select('*')
    .eq('restaurant_id', restaurant.id)
    .eq('is_active', true)
    .order('display_order')

  // Fetch modifiers for all dishes using NEW ingredient_groups structure
  const dishIds = dishes?.map(d => d.id) || []

  // Step 1: Get dish_modifiers (links dishes to ingredient_groups)
  const { data: dishModifiers } = await supabase
    .from('dish_modifiers')
    .select('*')
    .in('dish_id', dishIds.length > 0 ? dishIds : [0])
    .is('deleted_at', null)
    .order('display_order')

  // Step 2: Get unique ingredient_group_ids from dish_modifiers
  const groupIds = [...new Set(dishModifiers?.map(dm => dm.ingredient_group_id).filter(Boolean) || [])]

  // Step 3: Fetch ingredient_groups with their details
  const { data: ingredientGroups } = await supabase
    .from('ingredient_groups')
    .select('*')
    .in('id', groupIds.length > 0 ? groupIds : [0])

  // Step 4: Fetch ingredient_group_items (links groups to ingredients)
  const { data: groupItems } = await supabase
    .from('ingredient_group_items')
    .select('*')
    .in('ingredient_group_id', groupIds.length > 0 ? groupIds : [0])

  // Step 5: Fetch all ingredients referenced in groups
  const ingredientIds = [...new Set(groupItems?.map(gi => gi.ingredient_id).filter(Boolean) || [])]
  const { data: ingredients } = await supabase
    .from('ingredients')
    .select('id, name, base_price')
    .in('id', ingredientIds.length > 0 ? ingredientIds : [0])

  // Create lookup maps
  const ingredientMap = new Map(ingredients?.map(ing => [ing.id, ing]) || [])
  const groupMap = new Map(ingredientGroups?.map(g => [g.id, g]) || [])

  // Group items by group_id for easy lookup
  const itemsByGroup = (groupItems || []).reduce((acc, item) => {
    if (!acc[item.ingredient_group_id]) acc[item.ingredient_group_id] = []
    acc[item.ingredient_group_id].push(item)
    return acc
  }, {} as Record<number, any[]>)

  console.log('New modifier structure debug:', {
    totalDishModifiers: dishModifiers?.length || 0,
    uniqueGroups: groupIds.length,
    totalGroupItems: groupItems?.length || 0,
    totalIngredients: ingredients?.length || 0,
    sampleGroup: ingredientGroups?.[0]
  })

  // Attach modifiers to dishes
  const dishesWithModifiers = dishes?.map(dish => {
    const dishMods = dishModifiers?.filter(dm => dm.dish_id === dish.id) || []

    // For each dish_modifier, expand to show ALL ingredients in the group
    const modifiersForDish = dishMods.flatMap(dm => {
      const group = groupMap.get(dm.ingredient_group_id)
      const items = itemsByGroup[dm.ingredient_group_id] || []

      // Return ALL ingredients from this group
      return items.map((item, index) => {
        const ingredient = ingredientMap.get(item.ingredient_id)
        return {
          modifier_id: `${dm.id}_${item.id}`, // Unique ID combining modifier and item
          group_id: dm.ingredient_group_id,
          group_name: group?.name || 'Options',
          modifier_name: ingredient?.name || 'Unknown',
          price: item.base_price || dm.price || 0,
          modifier_type: dm.modifier_type || group?.group_type || 'other',
          is_default: item.is_included || dm.is_default || false,
          is_included: item.is_included || dm.is_included || false,
          display_order: item.display_order || dm.display_order || 0,
          min_selection: group?.min_selection || 0,
          max_selection: group?.max_selection || 1,
          free_quantity: group?.free_quantity || 0
        }
      })
    })

    return {
      ...dish,
      modifiers: modifiersForDish
    }
  }) || []

  // Manually group dishes by course (some dishes may have null course_id)
  const menu = courses?.map(course => ({
    ...course,
    dishes: dishesWithModifiers?.filter(dish => dish.course_id === course.id) || []
  })) || []

  // Add uncategorized dishes to a default "Other" category if they exist
  const uncategorizedDishes = dishesWithModifiers?.filter(dish => dish.course_id === null) || []
  if (uncategorizedDishes.length > 0) {
    menu.push({
      id: 999999,
      uuid: 'uncategorized',
      restaurant_id: restaurant.id,
      name: 'Other Items',
      description: 'Items not assigned to a category',
      display_order: 999,
      is_active: true,
      dishes: uncategorizedDishes,
      tenant_id: null,
      deleted_at: null,
      deleted_by: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      source_system: null,
      source_id: null,
      legacy_v1_id: null,
      legacy_v2_id: null,
      notes: null
    })
  }

  console.log('Menu query result:', {
    courseCount: courses?.length || 0,
    dishCount: dishes?.length || 0,
    uncategorizedCount: uncategorizedDishes.length,
    menuLength: menu.length,
    menuWithDishes: menu.filter(c => c.dishes && c.dishes.length > 0).length,
    coursesError: coursesError ? JSON.stringify(coursesError) : null,
    dishesError: dishesError ? JSON.stringify(dishesError) : null
  })

  // Debug: Log first menu item
  if (menu.length > 0) {
    console.log('First menu category:', {
      name: menu[0].name,
      dishCount: menu[0].dishes?.length || 0,
      firstDish: menu[0].dishes?.[0]?.name || 'no dishes'
    })
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
              <CartSidebar />
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

