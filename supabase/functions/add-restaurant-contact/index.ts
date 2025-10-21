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

function badRequest(error: string, details?: any) {
  return jsonResponse({ success: false, error, ...(details && { details }) }, 400);
}

function successResponse(data: any, message: string) {
  return jsonResponse({ success: true, data, message }, 201);
}

function internalError(error: string) {
  return jsonResponse({ success: false, error }, 500);
}

async function logAdminAction(supabase: any, userId: string, action: string, resourceType: string, resourceId: number, metadata: object) {
  try {
    await supabase.from('admin_action_logs').insert({
      user_id: userId,
      action,
      resource_type: resourceType,
      resource_id: resourceId,
      metadata,
    });
  } catch (error) {
    console.error('Failed to log admin action:', error);
  }
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return badRequest('Method not allowed. Use POST.');
  }

  try {
    // Authentication
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ success: false, error: 'Missing authorization header' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl!, supabaseKey!);

    // Get user
    const userClient = createClient(supabaseUrl!, Deno.env.get('SUPABASE_ANON_KEY')!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user } } = await userClient.auth.getUser();
    if (!user) {
      return jsonResponse({ success: false, error: 'Invalid or expired token' }, 401);
    }

    // Parse request body
    const body = await req.json();

    // Input validation
    if (!body.restaurant_id || !body.email || !body.contact_type) {
      return badRequest('Missing required fields: restaurant_id, email, contact_type');
    }

    // Validate contact type
    const validTypes = ['owner', 'manager', 'billing', 'orders', 'support', 'general'];
    if (!validTypes.includes(body.contact_type)) {
      return badRequest(`Invalid contact_type. Must be one of: ${validTypes.join(', ')}`);
    }

    // Validate priority
    const priority = body.contact_priority || 1;
    if (priority < 1 || priority > 10) {
      return badRequest('contact_priority must be between 1 and 10');
    }

    // Verify restaurant exists
    const { data: restaurant, error: restaurantError } = await supabase
      .from('restaurants')
      .select('id, name')
      .eq('id', body.restaurant_id)
      .is('deleted_at', null)
      .single();

    if (restaurantError || !restaurant) {
      return badRequest('Restaurant not found', { restaurant_id: body.restaurant_id });
    }

    // If adding a primary contact (priority=1), check for existing primary
    let demotedContact = null;
    if (priority === 1) {
      const { data: existingPrimary } = await supabase
        .from('restaurant_contacts')
        .select('id, email, contact_priority')
        .eq('restaurant_id', body.restaurant_id)
        .eq('contact_type', body.contact_type)
        .eq('contact_priority', 1)
        .is('deleted_at', null)
        .single();

      if (existingPrimary) {
        // Demote existing primary to secondary
        const { error: demoteError } = await supabase
          .from('restaurant_contacts')
          .update({ 
            contact_priority: 2, 
            updated_at: new Date().toISOString(),
            updated_by: user.id
          })
          .eq('id', existingPrimary.id);

        if (demoteError) {
          console.error('Failed to demote existing primary:', demoteError);
          return internalError('Failed to demote existing primary contact');
        }

        demotedContact = {
          id: existingPrimary.id,
          email: existingPrimary.email,
          old_priority: 1,
          new_priority: 2
        };
      }
    }

    // Insert new contact
    const { data: newContact, error: insertError } = await supabase
      .from('restaurant_contacts')
      .insert({
        restaurant_id: body.restaurant_id,
        email: body.email,
        phone: body.phone || null,
        first_name: body.first_name || null,
        last_name: body.last_name || null,
        contact_type: body.contact_type,
        contact_priority: priority,
        is_active: body.is_active !== undefined ? body.is_active : true,
        created_by: user.id
      })
      .select()
      .single();

    if (insertError) {
      console.error('Insert error:', insertError);
      
      // Check for unique constraint violation
      if (insertError.code === '23505') {
        if (insertError.message.includes('idx_restaurant_contacts_primary_per_type')) {
          return badRequest('A primary contact of this type already exists for this restaurant');
        }
        return badRequest('Contact already exists with this email/phone combination');
      }
      
      throw insertError;
    }

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'contact.add',
      'restaurant_contacts',
      newContact.id,
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        contact_type: body.contact_type,
        contact_priority: priority,
        demoted_contact: demotedContact
      }
    ).catch(console.error);

    return successResponse(
      {
        contact_id: newContact.id,
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        email: newContact.email,
        phone: newContact.phone,
        contact_type: newContact.contact_type,
        contact_priority: newContact.contact_priority,
        is_active: newContact.is_active,
        demoted_contact: demotedContact
      },
      demotedContact 
        ? `Contact added as ${body.contact_type} priority ${priority}. Previous primary demoted to secondary.`
        : `Contact added as ${body.contact_type} priority ${priority}.`
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to add contact');
  }
});



