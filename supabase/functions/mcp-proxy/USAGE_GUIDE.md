# MCP Proxy Usage Guide for Background Agents

## Quick Start

### 1. Deploy the Function

```bash
cd /Users/brianlapp/Documents/GitHub/Migration-Strategy
supabase functions deploy mcp-proxy
```

### 2. Use from Background Agent

```javascript
// Example: Execute a database operation
const executeDbOperation = async (tool, args) => {
  const response = await fetch(
    'https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/mcp-proxy',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ tool, args }),
    }
  );
  
  return await response.json();
};

// Example: Apply a migration
const result = await executeDbOperation('apply_migration', {
  name: 'add_test_column',
  query: 'ALTER TABLE restaurants ADD COLUMN test_field TEXT;'
});
```

## Common Use Cases

### Apply Database Migrations

```javascript
await executeDbOperation('apply_migration', {
  name: 'migration_name',
  query: 'ALTER TABLE table_name ADD COLUMN column_name TYPE;'
});
```

### Get Project Info

```javascript
const projectUrl = await executeDbOperation('get_project_url');
console.log(projectUrl.data.url);
```

## Important Notes

⚠️ **Current Limitations:**

1. **Raw SQL execution** is limited - Supabase JS client doesn't support arbitrary SQL
2. **Use migrations** for DDL operations (CREATE, ALTER, DROP)
3. **Use Supabase client methods** for DML operations (INSERT, UPDATE, DELETE, SELECT)
4. **Complex queries** should use RPC functions or client methods

## Recommended Approach

For background agents, the **best practice** is:

1. **DDL Operations** → Use `apply_migration` tool (via this proxy)
2. **DML Operations** → Use Supabase client methods directly in your code
3. **Complex Queries** → Create RPC functions, then call them

## Security

⚠️ **Important:** This function uses service role key internally, giving it **full database access**. 

**Before production:**
- Add API key authentication
- Implement rate limiting
- Add comprehensive logging
- Validate all inputs

