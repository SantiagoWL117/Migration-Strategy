import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

interface CommissionInput {
  template_name: string
  total: number
  restaurant_commission: number  // Required: % (e.g., 10 = 10%) OR fixed amount (e.g., 150.00)
  commission_type?: 'percentage' | 'fixed'  // Optional: defaults to 'percentage' if not provided
  menuottawa_share: number
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
}

interface CommissionResult {
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
  use_total: number
  for_vendor: number
  for_menu_ottawa?: number  // Only for mazen_milanos
  for_menuca: number
}

function calculatePercentCommission(data: CommissionInput): CommissionResult {
  // Template: percent_commission (NET basis)
  // Replaces V2 eval() call with safe, typed calculation
  // Supports both percentage and fixed commission amounts
  
  let totalCommission: number
  
  // Determine if commission is a percentage or fixed amount
  const commissionType = data.commission_type || 'percentage'
  
  if (commissionType === 'fixed') {
    // Commission is a fixed dollar amount
    totalCommission = data.restaurant_commission
  } else {
    // Commission is a percentage (default behavior)
    totalCommission = data.total * (data.restaurant_commission / 100)
  }
  
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menuca: Math.round(forMenucaTotal * 100) / 100
  }
}

function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  // Template: mazen_milanos (Commission-based with 30% vendor priority)
  // Replaces V2 eval() call with safe, typed calculation
  
  const totalCommission = data.total * (data.restaurant_commission / 100)  // Variable % per restaurant
  const forVendor = totalCommission * 0.3  // Vendor gets 30% of commission
  const afterVendorShare = totalCommission - forVendor
  const afterFixedFee = afterVendorShare - data.menuottawa_share  // Subtract $80
  const forMenuOttawa = afterFixedFee / 2  // Menu Ottawa gets half
  const forMenucaShare = afterFixedFee / 2  // Menu.ca gets half
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menu_ottawa: Math.round(forMenuOttawa * 100) / 100,
    for_menuca: Math.round(forMenucaTotal * 100) / 100
  }
}

serve(async (req) => {
  try {
    const input: CommissionInput = await req.json()
    
    // Validate required fields
    if (!input.template_name || !input.total || !input.restaurant_commission || !input.menuottawa_share) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields',
          required: ['template_name', 'total', 'restaurant_commission', 'menuottawa_share']
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }
    
    // Route to appropriate calculation based on template name
    let result: CommissionResult
    
    if (input.template_name === 'percent_commission') {
      result = calculatePercentCommission(input)
    } else if (input.template_name === 'mazen_milanos') {
      result = calculateMazenMilanos(input)
    } else {
      return new Response(
        JSON.stringify({ 
          error: `Unknown template: ${input.template_name}`,
          available_templates: ['percent_commission', 'mazen_milanos']
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }
    
    return new Response(
      JSON.stringify(result),
      { headers: { "Content-Type": "application/json" } }
    )
    
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: error.message,
        type: error.name 
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})

