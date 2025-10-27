import { NextRequest, NextResponse } from 'next/server'

// Restaurant data for the AI to reference
const restaurantData = {
  restaurants: [
    { name: 'Pizza Palace', cuisine: 'Italian', tags: ['pizza', 'pasta', 'italian'] },
    { name: 'China Garden', cuisine: 'Chinese', tags: ['chinese', 'noodles', 'dim sum'] },
    { name: 'Taco Fiesta', cuisine: 'Mexican', tags: ['mexican', 'tacos', 'spicy', 'burritos'] },
    { name: 'Burger Barn', cuisine: 'American', tags: ['burgers', 'fries', 'american', 'comfort food'] },
    { name: 'Sushi Master', cuisine: 'Japanese', tags: ['sushi', 'japanese', 'fresh', 'raw fish'] },
    { name: 'Thai Spice', cuisine: 'Thai', tags: ['thai', 'spicy', 'curry', 'noodles', 'healthy'] },
    { name: 'Indian Curry House', cuisine: 'Indian', tags: ['indian', 'curry', 'spicy', 'vegetarian', 'vegan'] },
    { name: 'Mediterranean Delight', cuisine: 'Mediterranean', tags: ['mediterranean', 'healthy', 'greek', 'salads', 'vegetarian'] }
  ]
}

async function getAIResponse(query: string) {
  // For now, we'll use the mock system with the Anthropic key ready for future integration
  // In production, you would make the actual API call here
  
  const systemPrompt = `You are a helpful food ordering assistant. Based on the user's query, suggest relevant restaurants and cuisines from this list: ${JSON.stringify(restaurantData)}. 
  
  Respond with a JSON object containing:
  - cuisines: array of relevant cuisine types
  - restaurants: array of relevant restaurant names
  - message: a friendly message about the recommendations
  - confidence: a number between 0-1 indicating confidence
  
  Consider factors like: dietary preferences, meal type, price sensitivity, specific cravings, and time of day.`

  // Mock AI responses for demo (would be replaced with actual Anthropic API call)
  const mockResponses: Record<string, any> = {
    'healthy and spicy': {
      cuisines: ['thai', 'indian', 'mexican'],
      restaurants: ['Thai Spice', 'Indian Curry House', 'Mediterranean Delight'],
      message: 'Great choices for healthy dishes with a spicy kick! Thai Spice offers amazing spicy curries, while Indian Curry House has vegetarian options.'
    },
    'comfort food': {
      cuisines: ['american', 'italian'],
      restaurants: ['Burger Barn', 'Pizza Palace'],
      message: 'Nothing beats classic comfort food! Try Burger Barn for juicy burgers or Pizza Palace for hot, cheesy pizza.'
    },
    'late night': {
      cuisines: ['pizza', 'chinese', 'burgers'],
      restaurants: ['Pizza Palace', 'China Garden', 'Burger Barn'],
      message: 'Perfect late-night options! These restaurants typically have extended hours for your midnight cravings.'
    },
    'vegan': {
      cuisines: ['thai', 'indian', 'mediterranean'],
      restaurants: ['Thai Spice', 'Indian Curry House', 'Mediterranean Delight'],
      message: 'Excellent vegan-friendly restaurants! All offer substantial plant-based options.'
    },
    'date night': {
      cuisines: ['japanese', 'italian', 'mediterranean'],
      restaurants: ['Sushi Master', 'Pizza Palace', 'Mediterranean Delight'],
      message: 'Perfect for a romantic evening! Sushi Master offers an elegant dining experience.'
    }
  }

  // Check for matches in mock responses
  const lowerQuery = query.toLowerCase()
  for (const [key, value] of Object.entries(mockResponses)) {
    if (lowerQuery.includes(key)) {
      return { query, ...value, confidence: 0.95 }
    }
  }

  // Fallback intelligent matching
  const healthyKeywords = ['healthy', 'salad', 'fresh', 'light', 'vegetarian', 'vegan']
  const spicyKeywords = ['spicy', 'hot', 'heat', 'fiery']
  const comfortKeywords = ['comfort', 'hearty', 'filling', 'classic']
  const quickKeywords = ['fast', 'quick', 'asap', 'hurry']
  
  let suggestions = {
    cuisines: [] as string[],
    restaurants: [] as string[],
    message: '',
    confidence: 0
  }

  // Check for healthy food
  if (healthyKeywords.some(keyword => lowerQuery.includes(keyword))) {
    suggestions.cuisines = ['mediterranean', 'thai', 'japanese']
    suggestions.restaurants = ['Mediterranean Delight', 'Thai Spice', 'Sushi Master']
    suggestions.message = 'Here are some healthy options for you!'
    suggestions.confidence = 0.8
  }

  // Check for spicy food
  if (spicyKeywords.some(keyword => lowerQuery.includes(keyword))) {
    suggestions.cuisines = ['thai', 'indian', 'mexican']
    suggestions.restaurants = ['Thai Spice', 'Indian Curry House', 'Taco Fiesta']
    suggestions.message = 'Spice lovers rejoice! These restaurants bring the heat.'
    suggestions.confidence = 0.85
  }

  // Time-based suggestions
  const hour = new Date().getHours()
  if (suggestions.restaurants.length === 0) {
    if (hour >= 6 && hour < 11) {
      suggestions.message = 'Good morning! Looking for breakfast options?'
      suggestions.cuisines = ['american', 'mediterranean']
      suggestions.restaurants = ['Burger Barn', 'Mediterranean Delight']
      suggestions.confidence = 0.6
    } else if (hour >= 11 && hour < 14) {
      suggestions.message = 'Lunchtime! Here are some great midday options.'
      suggestions.cuisines = ['japanese', 'chinese', 'mediterranean']
      suggestions.restaurants = ['Sushi Master', 'China Garden', 'Mediterranean Delight']
      suggestions.confidence = 0.6
    } else if (hour >= 17 && hour < 21) {
      suggestions.message = 'Dinner time! Explore these popular evening choices.'
      suggestions.cuisines = ['italian', 'japanese', 'indian']
      suggestions.restaurants = ['Pizza Palace', 'Sushi Master', 'Indian Curry House']
      suggestions.confidence = 0.6
    }
  }

  if (suggestions.restaurants.length > 0) {
    return { query, ...suggestions }
  }

  // Default response
  return {
    query,
    cuisines: [],
    restaurants: [],
    message: 'Try being more specific! You can search for cuisines (pizza, sushi), preferences (healthy, spicy), or occasions (date night, quick lunch).',
    confidence: 0
  }
}

export async function POST(request: NextRequest) {
  try {
    const { query } = await request.json()
    
    if (!query) {
      return NextResponse.json({ error: 'Query is required' }, { status: 400 })
    }

    // Get AI response (currently using mock, but ready for Anthropic integration)
    const aiResponse = await getAIResponse(query)
    
    // Add CORS headers for client-side requests
    return NextResponse.json(aiResponse, {
      headers: {
        'Content-Type': 'application/json',
      }
    })
    
  } catch (error) {
    console.error('AI Search error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// Demo endpoint to show capabilities
export async function GET() {
  return NextResponse.json({
    capabilities: {
      naturalLanguage: [
        'I want something healthy and spicy',
        'Comfort food for a rainy day',
        'Good options for a date night',
        'Vegan restaurants near me',
        'Quick lunch under 30 minutes'
      ],
      dietary: ['vegan', 'vegetarian', 'gluten-free', 'halal', 'kosher'],
      occasions: ['date night', 'family dinner', 'quick lunch', 'late night'],
      preferences: ['healthy', 'spicy', 'comfort food', 'light', 'hearty']
    },
    apiKeyConfigured: !!process.env.ANTHROPIC_API_KEY
  })
}