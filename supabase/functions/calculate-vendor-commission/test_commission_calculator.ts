import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts"

// Import the calculation functions (you'll need to export them from index.ts for testing)
// For now, we'll redefine them here for testing purposes

interface CommissionInput {
  template_name: string
  total: number
  restaurant_commission: number
  commission_type?: 'percentage' | 'fixed'
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
  for_menu_ottawa?: number
  for_menuca: number
}

function calculatePercentCommission(data: CommissionInput): CommissionResult {
  let totalCommission: number
  
  const commissionType = data.commission_type || 'percentage'
  
  if (commissionType === 'fixed') {
    totalCommission = data.restaurant_commission
  } else {
    totalCommission = data.total * (data.restaurant_commission / 100)
  }
  
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare
  
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
  const totalCommission = data.total * (data.restaurant_commission / 100)
  const forVendor = totalCommission * 0.3
  const afterVendorShare = totalCommission - forVendor
  const afterFixedFee = afterVendorShare - data.menuottawa_share
  const forMenuOttawa = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare
  
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

Deno.test("percent_commission calculation accuracy", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 10000.00,
    restaurant_commission: 10,
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 123,
    restaurant_name: 'Test Restaurant',
    restaurant_address: '123 Main St'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 10000 * 0.10 = 1000
  // afterFixedFee = 1000 - 80 = 920
  // forVendor = 920 / 2 = 460
  // forMenucaShare = 920 / 2 = 460
  // forMenucaTotal = 80 + 460 = 540
  assertEquals(result.for_vendor, 460.00, 'Vendor amount calculation failed')
  assertEquals(result.for_menuca, 540.00, 'Menu.ca total (fixed + share) calculation failed')
})

Deno.test("mazen_milanos calculation accuracy - 10% commission", () => {
  const testData = {
    template_name: 'mazen_milanos',
    total: 10000.00,
    restaurant_commission: 10,  // 10% commission rate
    menuottawa_share: 80.00,
    vendor_id: 1,
    restaurant_id: 1171,
    restaurant_name: 'Pho Dau Bo',
    restaurant_address: '456 King St'
  }
  
  const result = calculateMazenMilanos(testData)
  
  // Expected: 
  // totalCommission = 10000 * (10 / 100) = 1000
  // forVendor = 1000 * 0.30 = 300 (Mazen gets 30% of commission)
  // afterVendorShare = 1000 - 300 = 700
  // afterFixedFee = 700 - 80 = 620
  // forMenuOttawa = 620 / 2 = 310
  // forMenucaShare = 620 / 2 = 310
  // forMenucaTotal = 80 + 310 = 390
  assertEquals(result.for_vendor, 300.00, 'Vendor (Mazen) amount calculation failed')
  assertEquals(result.for_menu_ottawa, 310.00, 'Menu Ottawa amount calculation failed')
  assertEquals(result.for_menuca, 390.00, 'Menu.ca total (fixed + share) calculation failed')
})

Deno.test("mazen_milanos calculation accuracy - 15% commission", () => {
  const testData = {
    template_name: 'mazen_milanos',
    total: 10000.00,
    restaurant_commission: 15,  // 15% commission rate
    menuottawa_share: 80.00,
    vendor_id: 1,
    restaurant_id: 1171,
    restaurant_name: 'Pho Dau Bo',
    restaurant_address: '456 King St'
  }
  
  const result = calculateMazenMilanos(testData)
  
  // Expected: 
  // totalCommission = 10000 * (15 / 100) = 1500
  // forVendor = 1500 * 0.30 = 450
  // afterVendorShare = 1500 - 450 = 1050
  // afterFixedFee = 1050 - 80 = 970
  // forMenuOttawa = 970 / 2 = 485
  // forMenucaShare = 970 / 2 = 485
  // forMenucaTotal = 80 + 485 = 565
  assertEquals(result.for_vendor, 450.00, 'Vendor (Mazen) amount calculation failed')
  assertEquals(result.for_menu_ottawa, 485.00, 'Menu Ottawa amount calculation failed')
  assertEquals(result.for_menuca, 565.00, 'Menu.ca total (fixed + share) calculation failed')
})

Deno.test("percent_commission - different commission rate", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 5000.00,
    restaurant_commission: 12,  // 12% commission
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 456,
    restaurant_name: 'Pizza Place',
    restaurant_address: '789 Oak Ave'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 5000 * 0.12 = 600
  // afterFixedFee = 600 - 80 = 520
  // forVendor = 520 / 2 = 260
  // forMenucaTotal = 80 + 260 = 340
  assertEquals(result.for_vendor, 260.00, 'Vendor amount calculation failed')
  assertEquals(result.for_menuca, 340.00, 'Menu.ca total calculation failed')
})

Deno.test("edge case - low commission (commission < fixed fee)", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 500.00,  // Small order
    restaurant_commission: 10,
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 999,
    restaurant_name: 'Small Restaurant',
    restaurant_address: '111 Small St'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 500 * 0.10 = 50
  // afterFixedFee = 50 - 80 = -30 (negative!)
  // forVendor = -30 / 2 = -15
  // forMenucaTotal = 80 + (-15) = 65
  
  // This is a valid edge case - vendor would owe money or get negative
  // The logic still works mathematically
  assertEquals(result.for_vendor, -15.00, 'Vendor amount (negative) calculation failed')
  assertEquals(result.for_menuca, 65.00, 'Menu.ca total calculation failed')
})

Deno.test("percent_commission with FIXED commission amount", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 10000.00,
    restaurant_commission: 1200.00,  // Fixed $1,200 commission (not a percentage)
    commission_type: 'fixed' as const,
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 555,
    restaurant_name: 'Fixed Commission Restaurant',
    restaurant_address: '222 Fixed St'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 1200.00 (fixed amount, NOT calculated from percentage)
  // afterFixedFee = 1200 - 80 = 1120
  // forVendor = 1120 / 2 = 560
  // forMenucaTotal = 80 + 560 = 640
  assertEquals(result.for_vendor, 560.00, 'Vendor amount calculation failed')
  assertEquals(result.for_menuca, 640.00, 'Menu.ca total calculation failed')
})

Deno.test("percent_commission with FIXED commission - small amount", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 5000.00,
    restaurant_commission: 250.00,  // Fixed $250 commission
    commission_type: 'fixed' as const,
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 666,
    restaurant_name: 'Small Fixed Commission',
    restaurant_address: '333 Small Fixed Ave'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 250.00 (fixed)
  // afterFixedFee = 250 - 80 = 170
  // forVendor = 170 / 2 = 85
  // forMenucaTotal = 80 + 85 = 165
  assertEquals(result.for_vendor, 85.00, 'Vendor amount calculation failed')
  assertEquals(result.for_menuca, 165.00, 'Menu.ca total calculation failed')
})

