---
paths:
  - "config/.config/nvim/**/*"
---

# Neovim Configuration

## Architecture

Lazy.nvim plugin manager with modular Lua configuration.

**Structure:**

- `init.lua` — Entry point
- `lua/config/` — Core configuration (options, keymaps, autocmds, utils)
- `lua/plugins/` — Plugin specifications (individual plugin files)

## Adding Plugins

1. Create file in `lua/plugins/<plugin-name>.lua`
2. Return plugin spec table:
   ```lua
   return {
     "author/repo",
     config = function()
       -- setup code
     end
   }
   ```
3. Lazy loads on startup

## Key Directories

- `lua/config/options.lua` — Editor options (number, relativenumber, etc.)
- `lua/config/keymaps.lua` — Key bindings
- `lua/config/autocmds.lua` — Autocommands
- `lua/plugins/` — All plugin specs (31+ plugins configured)

## Development Languages

Supported via Mise (.tool-versions): Java, Scala, Python, JavaScript/TypeScript,
Go, Rust, Lua.

LSP/tools auto-installed when opening relevant file types.

## Integration

- **Claude Code:** `lua/plugins/claude-code.lua`
- **Obsidian:** `lua/plugins/obsidian.lua`
- **Debug Adapter Protocol:** `lua/plugins/dap.lua`
- **Git integration:** `lua/plugins/fugitive.lua`, `gitsigns.lua`,
  `diffview.lua`

For detailed plugin list, check `lua/plugins/` directory.
