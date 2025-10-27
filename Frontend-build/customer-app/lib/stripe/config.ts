import { loadStripe, Stripe } from '@stripe/stripe-js'

let stripePromise: Promise<Stripe | null>

export const getStripe = () => {
  if (!stripePromise) {
    const key = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY

    if (!key) {
      console.error('Stripe publishable key is missing!')
      return Promise.resolve(null)
    }

    stripePromise = loadStripe(key)
  }

  return stripePromise
}

// Test mode configuration
export const STRIPE_CONFIG = {
  currency: 'cad', // Canadian dollars
  country: 'CA',
  testMode: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY?.startsWith('pk_test_')
}
