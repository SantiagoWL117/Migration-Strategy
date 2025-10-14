# Supabase Edge Functions - Complete Guide

## What Are Supabase Edge Functions?

**Supabase Edge Functions** are serverless functions that run on **Deno Deploy's global edge network**. They're the Supabase equivalent of AWS Lambda, but with key differences:

- **Runtime**: Deno (TypeScript/JavaScript) - NOT Node.js
- **Location**: Deploy globally to edge locations (closer to users)
- **Pricing**: Pay-per-invocation (included in Supabase Pro plan)
- **Integration**: Native access to your Supabase database and Auth

### Think of them as:
- Serverless API endpoints
- Backend logic without managing servers
- Functions triggered by HTTP requests

---

## How Do They Work?

### Architecture Overview

```
┌─────────────────┐
│   Your App      │
│  (Frontend or   │
│   Backend API)  │
└────────┬────────┘
         │
         │ HTTP POST Request
         ▼
┌─────────────────────────────────────────┐
│  Supabase Edge Function                 │
│  (Deployed on Deno Deploy Edge Network) │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Your TypeScript Code             │ │
│  │  - Receives HTTP request          │ │
│  │  - Processes data                 │ │
│  │  - Calls database (optional)      │ │
│  │  - Returns HTTP response          │ │
│  └───────────────────────────────────┘ │
└────────┬────────────────────────────────┘
         │
         │ Can access (optional):
         ▼
┌─────────────────┐
│ Your Supabase   │
│ PostgreSQL DB   │
└─────────────────┘
```

### Request Flow

1. **Client sends HTTP request** (POST, GET, etc.)
   ```javascript
   fetch('https://YOUR_PROJECT.supabase.co/functions/v1/my-function', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify({ data: 'value' })
   })
   ```

2. **Edge Function receives request** (your TypeScript code runs)
   ```typescript
   serve(async (req) => {
     const data = await req.json()
     // Your logic here
     return new Response(JSON.stringify({ result: 'success' }))
   })
   ```

3. **Function returns HTTP response** back to client

---

## Key Concepts

### 1. **Deno Runtime** (Not Node.js!)

Deno is a modern TypeScript/JavaScript runtime created by Node.js's original author.

**Key Differences from Node.js**:

| Feature | Node.js | Deno |
|---------|---------|------|
| Package Manager | npm/yarn | URL imports (no package.json) |
| TypeScript | Needs compilation | Native support |
| Security | Open by default | Secure by default |
| Module System | CommonJS/ESM | ESM only |

**Example - Importing Modules**:

```typescript
// ❌ Node.js style (won't work):
import express from 'express'

// ✅ Deno style (use URLs):
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
```

### 2. **Function Structure**

Every Edge Function has a **main entry point** that uses the `serve()` function:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// This is the main handler
serve(async (req: Request) => {
  // Your code here
  
  // Must return a Response object
  return new Response(
    JSON.stringify({ message: "Hello" }),
    { 
      headers: { "Content-Type": "application/json" },
      status: 200 
    }
  )
})
```

### 3. **Request Object**

The `req` parameter contains the incoming HTTP request:

```typescript
serve(async (req: Request) => {
  // HTTP method
  const method = req.method  // 'GET', 'POST', etc.
  
  // Headers
  const authHeader = req.headers.get('Authorization')
  
  // Parse JSON body
  const body = await req.json()
  
  // URL and query params
  const url = new URL(req.url)
  const param = url.searchParams.get('name')
  
  // ...
})
```

### 4. **Response Object**

You must return a `Response` object:

```typescript
// JSON response
return new Response(
  JSON.stringify({ data: "value" }),
  { 
    headers: { "Content-Type": "application/json" },
    status: 200 
  }
)

// Error response
return new Response(
  JSON.stringify({ error: "Something went wrong" }),
  { 
    headers: { "Content-Type": "application/json" },
    status: 500 
  }
)

// Text response
return new Response("Plain text", {
  headers: { "Content-Type": "text/plain" }
})
```

### 5. **Environment Variables**

Access environment variables using `Deno.env.get()`:

```typescript
const supabaseUrl = Deno.env.get('SUPABASE_URL')
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
```

**Setting env vars**:
```bash
# In your terminal (for local testing)
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_ANON_KEY=your-anon-key

# Or in Supabase Dashboard → Edge Functions → Secrets
```

### 6. **Database Access**

Edge Functions can query your Supabase PostgreSQL database:

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req: Request) => {
  // Create Supabase client
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!
  )
  
  // Query database
  const { data, error } = await supabase
    .from('restaurants')
    .select('*')
    .eq('active', true)
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" }
    })
  }
  
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" }
  })
})
```

---

## Local Development

### Prerequisites

1. **Install Supabase CLI**:
   ```bash
   # Windows (Scoop)
   scoop install supabase
   
   # Or download from: https://github.com/supabase/cli/releases
   ```

2. **Login to Supabase**:
   ```bash
   supabase login
   ```

3. **Link to your project**:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

### Create a Function

```bash
# Create new function (creates folder structure)
supabase functions new my-function

# This creates:
# supabase/
#   functions/
#     my-function/
#       index.ts    <- Your code goes here
```

### Run Locally

```bash
# Start local Supabase (includes Edge Functions runtime)
supabase start

# Serve a specific function
supabase functions serve my-function

# Serve with environment variables
supabase functions serve my-function --env-file .env.local
```

**Function runs at**: `http://localhost:54321/functions/v1/my-function`

### Test Locally

```bash
# Using curl
curl -i --location --request POST 'http://localhost:54321/functions/v1/my-function' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"key":"value"}'

# Using Postman or Insomnia
# POST http://localhost:54321/functions/v1/my-function
# Headers:
#   Authorization: Bearer YOUR_ANON_KEY
#   Content-Type: application/json
# Body:
#   {"key":"value"}
```

### View Logs

```bash
# Watch function logs
supabase functions logs my-function --follow

# Or in the code:
console.log('Debug message')  // Shows in logs
console.error('Error message')
```

---

## Deployment

### Deploy to Production

```bash
# Deploy a specific function
supabase functions deploy my-function

# Deploy all functions
supabase functions deploy
```

**Production URL**: `https://YOUR_PROJECT_REF.supabase.co/functions/v1/my-function`

### Set Production Secrets

```bash
# Set environment variables for production
supabase secrets set MY_SECRET=value

# List secrets
supabase secrets list

# Unset secret
supabase secrets unset MY_SECRET
```

---

## Common Patterns

### Pattern 1: Simple API Endpoint

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req: Request) => {
  try {
    const { name } = await req.json()
    
    return new Response(
      JSON.stringify({ message: `Hello, ${name}!` }),
      { headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})
```

### Pattern 2: Database Query

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // Use service role for admin access
  )
  
  const { id } = await req.json()
  
  const { data, error } = await supabase
    .from('restaurants')
    .select('*')
    .eq('id', id)
    .single()
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" }
    })
  }
  
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" }
  })
})
```

### Pattern 3: Authentication

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req: Request) => {
  // Get auth token from request
  const authHeader = req.headers.get('Authorization')!
  
  // Create client with user's token
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } }
  )
  
  // Verify user is authenticated
  const { data: { user }, error } = await supabase.auth.getUser()
  
  if (error || !user) {
    return new Response(
      JSON.stringify({ error: 'Unauthorized' }),
      { status: 401, headers: { "Content-Type": "application/json" } }
    )
  }
  
  // User is authenticated, proceed...
  return new Response(
    JSON.stringify({ message: `Hello, ${user.email}` }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

### Pattern 4: Business Logic (Our Use Case!)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

interface CommissionInput {
  total: number
  restaurant_commission: number
  menuottawa_share: number
  vendor_id: number
  restaurant_id: number
}

function calculateCommission(data: CommissionInput) {
  // Pure business logic - no database needed
  const tenPercent = data.total * (data.restaurant_commission / 100)
  const firstSplit = tenPercent - data.menuottawa_share
  const forVendor = firstSplit / 2
  const forJames = forVendor / 2
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_james: Math.round(forJames * 100) / 100
  }
}

serve(async (req: Request) => {
  try {
    const input: CommissionInput = await req.json()
    const result = calculateCommission(input)
    
    return new Response(
      JSON.stringify(result),
      { headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})
```

---

## Calling Edge Functions

### From Frontend (JavaScript)

```javascript
// Using fetch
const response = await fetch('https://YOUR_PROJECT.supabase.co/functions/v1/calculate-commission', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${supabaseAnonKey}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    total: 10000,
    restaurant_commission: 10,
    menuottawa_share: 80,
    vendor_id: 2,
    restaurant_id: 123
  })
})

const result = await response.json()
console.log(result)
```

### From Supabase Client Library

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

const { data, error } = await supabase.functions.invoke('calculate-commission', {
  body: {
    total: 10000,
    restaurant_commission: 10,
    menuottawa_share: 80,
    vendor_id: 2,
    restaurant_id: 123
  }
})

if (error) console.error(error)
else console.log(data)
```

### From PostgreSQL (Using pg_net extension)

```sql
-- Call Edge Function from database trigger or function
SELECT content::jsonb 
FROM http((
  'POST',
  'https://YOUR_PROJECT.supabase.co/functions/v1/calculate-commission',
  ARRAY[http_header('Authorization', 'Bearer ' || current_setting('app.service_role_key'))],
  'application/json',
  '{"total": 10000, "restaurant_commission": 10, "menuottawa_share": 80}'::text
)::http_request);
```

### From Backend API (Node.js/Python/etc.)

```javascript
// Node.js example
const response = await fetch('https://YOUR_PROJECT.supabase.co/functions/v1/calculate-commission', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ /* data */ })
})
```

---

## Security & Best Practices

### 1. **Use Service Role Key for Admin Operations**

```typescript
// For admin operations (bypass RLS)
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // Admin key
)

// For user operations (respects RLS)
const supabaseUser = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!,
  { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
)
```

### 2. **Validate Input**

```typescript
serve(async (req: Request) => {
  const data = await req.json()
  
  // Validate required fields
  if (!data.total || !data.restaurant_commission) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields' }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    )
  }
  
  // Validate data types
  if (typeof data.total !== 'number') {
    return new Response(
      JSON.stringify({ error: 'Total must be a number' }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    )
  }
  
  // ... rest of logic
})
```

### 3. **Error Handling**

```typescript
serve(async (req: Request) => {
  try {
    // Your logic
  } catch (error) {
    console.error('Error:', error)  // Logs to Supabase dashboard
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        details: error.message  // Be careful exposing error details in production
      }),
      { 
        status: 500,
        headers: { "Content-Type": "application/json" }
      }
    )
  }
})
```

### 4. **CORS Headers** (if calling from browser)

```typescript
serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type'
      }
    })
  }
  
  // Your logic...
  
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    }
  })
})
```

---

## Pricing & Limits

### Supabase Edge Functions Pricing

| Plan | Invocations | Bandwidth |
|------|-------------|-----------|
| **Free** | 500K/month | 2GB/month |
| **Pro** | 2M/month | 50GB/month |
| **Team** | 2M/month | 50GB/month |
| **Enterprise** | Custom | Custom |

**Overage pricing**: $2 per 1M invocations, $0.09 per GB bandwidth

### Limits

- **Execution time**: 150 seconds max
- **Memory**: 512MB per invocation
- **Response size**: 2MB max
- **Cold start**: ~100-200ms (first invocation)

---

## Debugging

### View Logs in Dashboard

1. Go to **Supabase Dashboard** → Your Project
2. Click **Edge Functions** in left sidebar
3. Click your function name
4. View **Logs** tab (real-time logs)

### View Logs in CLI

```bash
# Tail logs in real-time
supabase functions logs calculate-commission --follow

# View recent logs
supabase functions logs calculate-commission --limit 50
```

### Add Debug Logging

```typescript
serve(async (req: Request) => {
  console.log('Request received:', req.method, req.url)
  
  const data = await req.json()
  console.log('Input data:', data)
  
  const result = calculateCommission(data)
  console.log('Calculation result:', result)
  
  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" }
  })
})
```

---

## For Our Vendor Commission Use Case

### Why Edge Functions are Perfect for This:

1. **Pure Calculation Logic**: No database writes needed during calculation
2. **Stateless**: Each commission calculation is independent
3. **Testable**: Can test locally before deployment
4. **Secure**: No `eval()` or dynamic code execution
5. **Scalable**: Automatically scales with traffic
6. **Fast**: Runs close to users on edge network

### What We'll Build:

```
HTTP POST Request
    ↓
Edge Function (TypeScript)
    ↓ calculatePercentCommission()
    ↓
JSON Response with commission amounts
```

**No database access needed** during calculation - it's a pure function that takes inputs and returns outputs!

---

## Next Steps for Phase 3

Now that you understand Edge Functions, we'll:

1. ✅ Create the TypeScript function with our commission logic
2. ✅ Test it locally with real data
3. ✅ Verify calculations match V2 behavior
4. ✅ Deploy to your Supabase project

**Ready to proceed with implementation?**

