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

  if (req.method !== 'PATCH') {
    return badRequest('Method not allowed. Use PATCH.');
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
    if (!body.contact_id) {
      return badRequest('Missing required field: contact_id');
    }

    // Get existing contact
    const { data: existingContact, error: fetchError } = await supabase
      .from('restaurant_contacts')
      .select('id, restaurant_id, email, phone, first_name, last_name, contact_type, contact_priority, is_active')
      .eq('id', body.contact_id)
      .is('deleted_at', null)
      .single();

    if (fetchError || !existingContact) {
      return badRequest('Contact not found', { contact_id: body.contact_id });
    }

    // Prepare update object
    const updates: any = {
      updated_at: new Date().toISOString(),
      updated_by: user.id
    };

    // Track changes for logging
    const changes: any = {};

    // Update email if provided
    if (body.email !== undefined && body.email !== existingContact.email) {
      updates.email = body.email;
      changes.email = { old: existingContact.email, new: body.email };
    }

    // Update phone if provided
    if (body.phone !== undefined && body.phone !== existingContact.phone) {
      updates.phone = body.phone;
      changes.phone = { old: existingContact.phone, new: body.phone };
    }

    // Update first_name if provided
    if (body.first_name !== undefined && body.first_name !== existingContact.first_name) {
      updates.first_name = body.first_name;
      changes.first_name = { old: existingContact.first_name, new: body.first_name };
    }

    // Update last_name if provided
    if (body.last_name !== undefined && body.last_name !== existingContact.last_name) {
      updates.last_name = body.last_name;
      changes.last_name = { old: existingContact.last_name, new: body.last_name };
    }

    // Update is_active if provided
    if (body.is_active !== undefined && body.is_active !== existingContact.is_active) {
      updates.is_active = body.is_active;
      changes.is_active = { old: existingContact.is_active, new: body.is_active };
    }

    // Handle contact_type change
    let demotedContact = null;
    if (body.contact_type !== undefined && body.contact_type !== existingContact.contact_type) {
      const validTypes = ['owner', 'manager', 'billing', 'orders', 'support', 'general'];
      if (!validTypes.includes(body.contact_type)) {
        return badRequest(`Invalid contact_type. Must be one of: ${validTypes.join(', ')}`);
      }
      updates.contact_type = body.contact_type;
      changes.contact_type = { old: existingContact.contact_type, new: body.contact_type };
    }

    // Handle priority change (most complex logic)
    if (body.contact_priority !== undefined && body.contact_priority !== existingContact.contact_priority) {
      const newPriority = body.contact_priority;
      
      if (newPriority < 1 || newPriority > 10) {
        return badRequest('contact_priority must be between 1 and 10');
      }

      // If changing to priority 1, check for existing primary of this type
      if (newPriority === 1) {
        const contactType = body.contact_type || existingContact.contact_type;
        
        const { data: existingPrimary } = await supabase
          .from('restaurant_contacts')
          .select('id, email, contact_priority')
          .eq('restaurant_id', existingContact.restaurant_id)
          .eq('contact_type', contactType)
          .eq('contact_priority', 1)
          .is('deleted_at', null)
          .neq('id', body.contact_id)
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

      updates.contact_priority = newPriority;
      changes.contact_priority = { old: existingContact.contact_priority, new: newPriority };
    }

    // If no changes, return early
    if (Object.keys(changes).length === 0) {
      return successResponse(
        {
          contact_id: existingContact.id,
          restaurant_id: existingContact.restaurant_id,
          changes: {}
        },
        'No changes made to contact'
      );
    }

    // Perform update
    const { data: updatedContact, error: updateError } = await supabase
      .from('restaurant_contacts')
      .update(updates)
      .eq('id', body.contact_id)
      .select()
      .single();

    if (updateError) {
      console.error('Update error:', updateError);
      
      // Check for unique constraint violation
      if (updateError.code === '23505') {
        if (updateError.message.includes('idx_restaurant_contacts_primary_per_type')) {
          return badRequest('A primary contact of this type already exists for this restaurant');
        }
        return badRequest('Contact already exists with this email/phone combination');
      }
      
      throw updateError;
    }

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'contact.update',
      'restaurant_contacts',
      updatedContact.id,
      {
        restaurant_id: existingContact.restaurant_id,
        changes,
        demoted_contact: demotedContact
      }
    ).catch(console.error);

    return successResponse(
      {
        contact_id: updatedContact.id,
        restaurant_id: updatedContact.restaurant_id,
        email: updatedContact.email,
        phone: updatedContact.phone,
        first_name: updatedContact.first_name,
        last_name: updatedContact.last_name,
        contact_type: updatedContact.contact_type,
        contact_priority: updatedContact.contact_priority,
        is_active: updatedContact.is_active,
        changes,
        demoted_contact: demotedContact
      },
      demotedContact
        ? 'Contact updated successfully. Previous primary demoted to secondary.'
        : 'Contact updated successfully'
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to update contact');
  }
});



