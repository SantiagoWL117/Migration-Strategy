# Cursor Supabase MCP Crash - Root Cause Analysis

**Issue**: Out of Memory (OOM) crash when connecting to Supabase MCP in Cursor  
**Error Code**: `-536870904`  
**Date**: October 24, 2025  
**Affected Version**: Cursor 1.7.46 and 1.7.54

---

## 🎯 Root Cause

Cursor's **renderer process** crashes when Supabase MCP attempts to load the entire database schema metadata into memory.

---

## 🔍 Technical Details

### **1. Electron Architecture Limitation**

Cursor is built on Electron, which uses two separate processes:

| Process | Memory Limit | What It Runs |
|---------|--------------|--------------|
| **Main Process** | 8GB (configurable) | Node.js backend |
| **Renderer Process** | **2GB (hardcoded)** | UI, AI agents, **MCP** |

- The Supabase MCP runs in the **renderer process** (2GB limit)
- Memory flags like `--max-old-space-size=8192` **only affect the main process**
- **The renderer process cannot be expanded beyond 2GB**

### **2. Schema Loading Mechanism**

When connecting to Supabase MCP, Cursor attempts to:
1. Load **entire database schema** (80+ tables) into memory
2. Parse all table structures, relationships, columns, constraints
3. Build complete context for AI agents
4. Store everything in renderer process memory

### **3. Memory Explosion**

**Observed behavior** (from `monitor_cursor_detailed.ps1`):

```
[19:05:48] Total: 2801MB | Max: 414MB   | Status: OK
[19:05:50] Total: 4306MB | Max: 1916MB  | Status: CRITICAL ⚠️
[19:05:52] Total: 8109MB | Max: 5724MB  | Status: CRITICAL ⚠️
[19:05:54] Total: 11765MB | Max: 9384MB | Status: CRITICAL ⚠️
[19:05:56] Total: 14875MB | Max: 12488MB | Status: CRITICAL ⚠️
[19:05:58] Total: 17253MB | Max: 14853MB | Status: CRITICAL ⚠️
[19:06:00] CRASH DETECTED | Process count: 16 → 13
```

**Memory spiked from 414MB to 14,853MB in 10 seconds**, far exceeding the 2GB renderer limit.

### **4. Crash Point**

The crash occurs immediately after attempting to connect to the Supabase MCP:

```
Error sending from webFrameMain: Error: Render frame was disposed before WebFrameMain could be accessed
[main] Extension host with pid 17932 exited with code: 0, signal: unknown
```

---

## ❌ Why Common Fixes Don't Work

| Attempted Fix | Why It Fails |
|---------------|--------------|
| Increase `--max-old-space-size` | Only affects main process, not renderer |
| Clear Cursor cache | Doesn't change MCP memory loading behavior |
| Disable indexing | MCP loading is separate from codebase indexing |
| Use `.cursorignore` | Only affects file indexing, not MCP schema loading |
| Downgrade Cursor version | Architectural limitation exists in all versions |
| Restart Cursor | Problem recurs on every MCP connection attempt |

---

## ✅ Working Solutions



### ** Bypass Cursor MCP** (Recommended)
Use **Claude Code + Supabase CLI**:

```

**Benefits**:
- ✅ No renderer process limitations
- ✅ Direct CLI access
- ✅ Full database control (queries, migrations, Edge Functions)
- ✅ No OOM crashes



## 📊 Impact

**Database Size**: 80+ tables in `menuca_v3` schema  
**Memory Required**: ~14.8 GB (7x the renderer limit)  
**Success Rate**: 0% (crashes 100% of the time)  
**Workaround**: Use Claude Code + Supabase CLI ✅

---

## 🎯 Conclusion

**The crash is NOT a bug** - it's an **architectural limitation**:
- Cursor's renderer process has a hardcoded 2GB limit
- Supabase MCP loads entire schema (14.8GB) at once
- No configuration can expand renderer memory beyond 2GB
- The only solution is to bypass Cursor's MCP entirely

**Recommended**: Use **Claude Code** with **Supabase CLI** for large database projects.

---

**Status**: ✅ RESOLVED (Using Claude Code + Supabase CLI)  
**Last Updated**: October 25, 2025

