import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // Use service role for order creation
)

interface OrderItem {
  dishId: number
  name: string
  quantity: number
  price: number
  modifiers?: Array<{
    modifier_id: number | string
    modifier_name: string
    price: number
  }>
}

interface CreateOrderRequest {
  restaurantId: number
  items: OrderItem[]
  paymentIntentId: string
  customerInfo: {
    name: string
    email: string
    phone: string
  }
  deliveryInfo: {
    address: string
    city: string
    postalCode: string
    instructions?: string
  }
  totals: {
    subtotal: number
    tax: number
    deliveryFee: number
    total: number
  }
}

export async function POST(request: NextRequest) {
  try {
    const body: CreateOrderRequest = await request.json()

    // Validate required fields
    if (!body.restaurantId || !body.items || body.items.length === 0) {
      return NextResponse.json(
        { error: 'Restaurant ID and items are required' },
        { status: 400 }
      )
    }

    if (!body.paymentIntentId) {
      return NextResponse.json(
        { error: 'Payment intent ID is required' },
        { status: 400 }
      )
    }

    // Generate order number (format: ORD-YYYYMMDD-XXXXX)
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '')
    const random = Math.floor(10000 + Math.random() * 90000)
    const orderNumber = `ORD-${today}-${random}`

    // Step 1: Create order record
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        restaurant_id: body.restaurantId,
        order_number: orderNumber,
        order_type: 'delivery',
        order_status: 'pending',
        subtotal: body.totals.subtotal,
        tax_amount: body.totals.tax,
        delivery_fee: body.totals.deliveryFee,
        tip_amount: 0,
        discount_amount: 0,
        total_amount: body.totals.total,
        customer_name: body.customerInfo.name,
        customer_email: body.customerInfo.email,
        customer_phone: body.customerInfo.phone,
        delivery_address: body.deliveryInfo.address,
        delivery_instructions: body.deliveryInfo.instructions || null,
        delivery_address_json: {
          street: body.deliveryInfo.address,
          city: body.deliveryInfo.city,
          postal_code: body.deliveryInfo.postalCode
        },
        stripe_payment_intent_id: body.paymentIntentId,
        payment_status: 'succeeded',
        payment_method: 'stripe',
        source: 'menuca-v3-web',
        is_guest_order: true,
        guest_email: body.customerInfo.email,
        guest_phone: body.customerInfo.phone,
      })
      .select()
      .single()

    if (orderError) {
      console.error('Order creation error:', orderError)
      return NextResponse.json(
        { error: 'Failed to create order', details: orderError.message },
        { status: 500 }
      )
    }

    // Step 2: Create order items
    const orderItems = body.items.map(item => ({
      order_id: order.id,
      dish_id: item.dishId,
      item_name: item.name,
      quantity: item.quantity,
      unit_price: item.price,
      total_price: item.price * item.quantity,
      customizations: item.modifiers ? {
        modifiers: item.modifiers.map(m => ({
          id: m.modifier_id,
          name: m.modifier_name,
          price: m.price
        }))
      } : null
    }))

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems)

    if (itemsError) {
      console.error('Order items creation error:', itemsError)
      // Rollback: Delete the order if items failed
      await supabase.from('orders').delete().eq('id', order.id)

      return NextResponse.json(
        { error: 'Failed to create order items', details: itemsError.message },
        { status: 500 }
      )
    }

    // Step 3: Send confirmation email (TODO: Implement in Phase 6)
    // await sendOrderConfirmationEmail(order.id, body.customerInfo.email)

    return NextResponse.json({
      success: true,
      order: {
        id: order.id,
        uuid: order.uuid,
        orderNumber: order.order_number,
        status: order.order_status,
        total: order.total_amount,
        estimatedDeliveryTime: order.estimated_delivery_time,
      }
    })

  } catch (error: any) {
    console.error('Order creation error:', error)
    return NextResponse.json(
      { error: error.message || 'Failed to create order' },
      { status: 500 }
    )
  }
}
