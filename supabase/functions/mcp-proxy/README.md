# MCP Proxy Edge Function

## Overview

This Edge Function provides an **HTTP bridge** for Cursor background agents to execute Supabase database operations. Since background agents can't directly call MCP tools (only Composer can), this proxy allows them to perform database updates via HTTP requests.

## Purpose

- ✅ Enable background agents to execute DB operations
- ✅ Provide secure HTTP endpoint for Supabase operations
- ✅ Bridge MCP functionality to HTTP API
- ✅ Maintain audit trail and error handling

## Endpoint

```
POST https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/mcp-proxy
```

## Authentication

The function uses the **service role key** internally, so all operations have full database access. For security, you should:

1. **Add API key authentication** to the endpoint (recommended)
2. **Use Cursor's built-in auth** when calling from agents
3. **Rate limit** requests to prevent abuse

## Supported Operations

### 1. Execute SQL (`execute_sql`)

Execute raw SQL queries (with limitations - see notes below).

**Request:**
```json
{
  "tool": "execute_sql",
  "args": {
    "query": "SELECT * FROM restaurants LIMIT 5;"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "SELECT queries should use Supabase client methods...",
    "query": "SELECT * FROM restaurants LIMIT 5;"
  }
}
```

**Note:** For complex queries, use Supabase client methods. DDL operations should use `apply_migration`.

---

### 2. Apply Migration (`apply_migration`)

Apply database schema changes safely.

**Request:**
```json
{
  "tool": "apply_migration",
  "args": {
    "name": "add_new_column",
    "query": "ALTER TABLE restaurants ADD COLUMN new_field TEXT;"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "migration_name": "add_new_column",
    "status": "applied",
    "result": {}
  }
}
```

---

### 3. List Tables (`list_tables`)

List tables in specified schemas.

**Request:**
```json
{
  "tool": "list_tables",
  "args": {
    "schemas": ["public", "menuca_v3"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Use Supabase dashboard or MCP tools directly...",
    "schemas_requested": ["public", "menuca_v3"]
  }
}
```

---

### 4. Get Project URL (`get_project_url`)

Get the Supabase project URL.

**Request:**
```json
{
  "tool": "get_project_url"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://nthpbtdjhhnwfxqsxbvy.supabase.co"
  }
}
```

---

### 5. Get Anonymous Key (`get_anon_key`)

Get the anonymous API key (if configured in env vars).

**Request:**
```json
{
  "tool": "get_anon_key"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 6. List Extensions (`list_extensions`)

List installed PostgreSQL extensions.

**Request:**
```json
{
  "tool": "list_extensions"
}
```

---

### 7. List Migrations (`list_migrations`)

List applied migrations.

**Request:**
```json
{
  "tool": "list_migrations"
}
```

---

### 8. Get Logs (`get_logs`)

Get service logs (placeholder - requires dashboard access).

**Request:**
```json
{
  "tool": "get_logs",
  "args": {
    "service": "api"
  }
}
```

---

## Usage from Cursor Background Agent

```javascript
// Example: Apply a migration
const response = await fetch(
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/mcp-proxy',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY', // If auth added
    },
    body: JSON.stringify({
      tool: 'apply_migration',
      args: {
        name: 'add_restaurant_column',
        query: 'ALTER TABLE restaurants ADD COLUMN test_field TEXT;'
      }
    })
  }
);

const result = await response.json();
console.log(result);
```

## Deployment

```bash
# Deploy the function
supabase functions deploy mcp-proxy

# Test locally (if using Supabase CLI)
supabase functions serve mcp-proxy
```

## Environment Variables

The function uses these environment variables (automatically available in Supabase):

- `SUPABASE_URL` - Project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key (full access)
- `SUPABASE_ANON_KEY` - (Optional) Anonymous key

## Security Considerations

⚠️ **Important:**

1. **This function has FULL database access** (service role)
2. **Add authentication** before production use
3. **Rate limit** requests to prevent abuse
4. **Log all operations** for audit trail
5. **Validate inputs** thoroughly

## Limitations

- **Raw SQL execution** is limited - Supabase JS client doesn't support arbitrary SQL
- **Complex SELECT queries** should use Supabase client methods
- **DDL operations** should use migrations (recommended)
- **Some operations** (like logs) require dashboard/CLI access

## Future Enhancements

- [ ] Add API key authentication
- [ ] Implement rate limiting
- [ ] Add comprehensive audit logging
- [ ] Support batch operations
- [ ] Add query validation and sanitization
- [ ] Implement RPC function for raw SQL execution

## Related Documentation

- [Supabase MCP Setup](../SUPABASE_MCP_SETUP.md)
- [Edge Functions Deployment Guide](./DEPLOYMENT_GUIDE.md)

