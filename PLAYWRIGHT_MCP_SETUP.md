# Playwright MCP Installation for Cursor

## What is Playwright MCP?
The Playwright MCP server provides browser automation capabilities through the Model Context Protocol, allowing AI assistants to interact with web browsers for testing and automation tasks.

## Installation Steps

### Step 1: Install Playwright MCP Server
The Playwright MCP server can be run via npx without installation. However, you need to configure it in Cursor's settings.

### Step 2: Configure Cursor Settings

1. **Open Cursor Settings**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Preferences: Open User Settings (JSON)"
   - Press Enter

2. **Add MCP Configuration**:
   Add the following to your settings JSON file:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp@latest"
      ]
    }
  }
}
```

### Step 3: Restart Cursor
After saving the settings, restart Cursor for the changes to take effect.

### Alternative: Global Configuration
You can also configure MCP servers in a separate file:

**Windows Location**: `%APPDATA%\Cursor\User\globalStorage\mcp.json`
**Mac/Linux Location**: `~/.cursor/mcp.json`

Create or edit this file with:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp@latest"
      ]
    }
  }
}
```

## Verification

After installation and restart:
1. The Playwright MCP should appear in your available MCP servers
2. You can verify by checking if browser automation tools are available
3. Try asking the AI to perform browser automation tasks

## Usage Examples

Once installed, you can ask the AI to:
- Take screenshots of websites
- Navigate to URLs and extract content
- Fill out forms and click buttons
- Run browser-based tests
- Automate web interactions

## Troubleshooting

### MCP Server Not Appearing
- Ensure you've restarted Cursor completely
- Check that Node.js and npm are installed on your system
- Verify the JSON syntax in your settings file

### Permission Issues on Windows
- Make sure you're running with appropriate permissions
- Check that npx can execute in your PowerShell/CMD

### Playwright Installation Issues
- The first run may take time as Playwright downloads browser binaries
- Ensure you have a stable internet connection

## Additional Resources
- [Playwright Documentation](https://playwright.dev/)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Cursor Documentation](https://docs.cursor.com/)

