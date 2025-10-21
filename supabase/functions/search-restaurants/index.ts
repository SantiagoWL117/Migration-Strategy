import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Utilities
function jsonResponse(data: any, status: number = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return jsonResponse({ success: false, error: 'Method not allowed. Use GET.' }, 400);
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    const supabase = createClient(supabaseUrl!, supabaseAnonKey!);

    // Parse query parameters
    const url = new URL(req.url);
    const cuisine = url.searchParams.get('cuisine');
    const tags = url.searchParams.get('tags')?.split(',').filter(t => t.trim()) || [];
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');

    // Build base query
    let query = supabase
      .from('restaurants')
      .select(`
        id,
        name,
        status,
        restaurant_cuisines!inner (
          is_primary,
          cuisine_types (
            id,
            name,
            slug
          )
        ),
        restaurant_tag_assignments (
          restaurant_tags (
            id,
            name,
            slug,
            category
          )
        )
      `)
      .eq('status', 'active')
      .is('deleted_at', null);

    // Filter by cuisine if provided
    if (cuisine) {
      query = query.eq('restaurant_cuisines.cuisine_types.slug', cuisine);
    }

    // Apply limit and offset
    query = query.range(offset, offset + limit - 1);

    const { data: restaurants, error } = await query;

    if (error) {
      console.error('Database error:', error);
      return jsonResponse({ success: false, error: error.message }, 500);
    }

    // Filter by tags if provided (client-side filtering for now)
    let filteredRestaurants = restaurants || [];
    
    if (tags.length > 0) {
      filteredRestaurants = filteredRestaurants.filter(restaurant => {
        const restaurantTags = restaurant.restaurant_tag_assignments?.map(
          (ta: any) => ta.restaurant_tags?.slug
        ) || [];
        
        // Check if restaurant has all required tags
        return tags.every(tag => restaurantTags.includes(tag));
      });
    }

    // Format response
    const formattedRestaurants = filteredRestaurants.map(restaurant => ({
      id: restaurant.id,
      name: restaurant.name,
      status: restaurant.status,
      cuisines: Array.isArray(restaurant.restaurant_cuisines)
        ? restaurant.restaurant_cuisines.map((rc: any) => ({
            id: rc.cuisine_types?.id,
            name: rc.cuisine_types?.name,
            slug: rc.cuisine_types?.slug,
            is_primary: rc.is_primary
          })).filter((c: any) => c.id) // Filter out null cuisine types
        : [],
      tags: restaurant.restaurant_tag_assignments?.map((ta: any) => ({
        id: ta.restaurant_tags?.id,
        name: ta.restaurant_tags?.name,
        slug: ta.restaurant_tags?.slug,
        category: ta.restaurant_tags?.category
      })).filter((t: any) => t.id) || []
    }));

    return jsonResponse({
      success: true,
      data: {
        restaurants: formattedRestaurants,
        total: formattedRestaurants.length,
        limit,
        offset,
        filters: {
          cuisine: cuisine || null,
          tags: tags.length > 0 ? tags : null
        }
      }
    });

  } catch (error) {
    console.error('Error:', error);
    return jsonResponse({ success: false, error: 'Internal server error' }, 500);
  }
});

