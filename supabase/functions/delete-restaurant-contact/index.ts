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
  return jsonResponse({ success: true, data, message }, 200);
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

  if (req.method !== 'DELETE') {
    return badRequest('Method not allowed. Use DELETE.');
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

    // Parse query parameters
    const url = new URL(req.url);
    const contactId = url.searchParams.get('contact_id');
    const reason = url.searchParams.get('reason') || 'Contact deleted by admin';

    if (!contactId || isNaN(parseInt(contactId))) {
      return badRequest('Valid contact_id query parameter is required');
    }

    // Get existing contact
    const { data: existingContact, error: fetchError } = await supabase
      .from('restaurant_contacts')
      .select('id, restaurant_id, email, phone, first_name, last_name, contact_type, contact_priority, is_active')
      .eq('id', parseInt(contactId))
      .is('deleted_at', null)
      .single();

    if (fetchError || !existingContact) {
      return badRequest('Contact not found or already deleted', { contact_id: contactId });
    }

    // Get restaurant info for response
    const { data: restaurant } = await supabase
      .from('restaurants')
      .select('id, name')
      .eq('id', existingContact.restaurant_id)
      .single();

    // Perform soft delete
    const { error: deleteError } = await supabase
      .from('restaurant_contacts')
      .update({
        deleted_at: new Date().toISOString(),
        deleted_by: user.id,
        is_active: false,
        updated_at: new Date().toISOString(),
        updated_by: user.id
      })
      .eq('id', parseInt(contactId));

    if (deleteError) {
      console.error('Delete error:', deleteError);
      throw deleteError;
    }

    // Check if this was a primary contact, and if so, promote secondary to primary
    let promotedContact = null;
    if (existingContact.contact_priority === 1) {
      const { data: secondary } = await supabase
        .from('restaurant_contacts')
        .select('id, email, contact_priority')
        .eq('restaurant_id', existingContact.restaurant_id)
        .eq('contact_type', existingContact.contact_type)
        .eq('contact_priority', 2)
        .is('deleted_at', null)
        .single();

      if (secondary) {
        // Promote secondary to primary
        const { error: promoteError } = await supabase
          .from('restaurant_contacts')
          .update({
            contact_priority: 1,
            updated_at: new Date().toISOString(),
            updated_by: user.id
          })
          .eq('id', secondary.id);

        if (promoteError) {
          console.error('Failed to promote secondary contact:', promoteError);
          // Non-critical error, continue
        } else {
          promotedContact = {
            id: secondary.id,
            email: secondary.email,
            old_priority: 2,
            new_priority: 1
          };
        }
      }
    }

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'contact.delete',
      'restaurant_contacts',
      existingContact.id,
      {
        restaurant_id: existingContact.restaurant_id,
        restaurant_name: restaurant?.name || 'Unknown',
        deleted_contact: {
          email: existingContact.email,
          phone: existingContact.phone,
          contact_type: existingContact.contact_type,
          contact_priority: existingContact.contact_priority
        },
        reason,
        promoted_contact: promotedContact
      }
    ).catch(console.error);

    return successResponse(
      {
        contact_id: existingContact.id,
        restaurant_id: existingContact.restaurant_id,
        restaurant_name: restaurant?.name || 'Unknown',
        deleted_at: new Date().toISOString(),
        deleted_contact: {
          email: existingContact.email,
          contact_type: existingContact.contact_type,
          contact_priority: existingContact.contact_priority
        },
        promoted_contact: promotedContact
      },
      promotedContact
        ? 'Contact deleted successfully. Secondary contact promoted to primary.'
        : 'Contact deleted successfully'
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to delete contact');
  }
});



