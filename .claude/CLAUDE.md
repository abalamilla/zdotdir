# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Repository Overview

This is a personal Zsh configuration repository (zdotdir) that manages shell
environment, dotfiles, plugins, and development tools using a modular
architecture.

**Key Architecture**: Configuration files in `config/` are symlinked to `$HOME`
using GNU Stow during installation. The shell sources files dynamically from
multiple directories to build the complete environment.

## Installation and Setup

### Fresh Installation

```bash
# Install everything (clones repo to ~/zdotdir)
curl -s https://raw.githubusercontent.com/abalamilla/zdotdir/main/install.sh | zsh
```

### Development Setup

After cloning, symlink configurations manually for development:

```bash
# Link config files from repo to home directory
stow config -t ~
```

### Brewfile Management

```bash
# Install/update all Homebrew packages
brew bundle install --file=./Brewfile

# Generate lock file after changes
brew bundle dump --force
```

### ASDF Plugins

```bash
# Add all plugins (see install.sh lines 196-245 for complete list)
asdf plugin add <plugin-name>

# Install all tools from .tool-versions
asdf install
```

### Installation Script Features

The `install.sh` script provides intelligent installation and update
capabilities:

**Mode Detection**: Automatically detects whether to run initial setup or update
mode by checking for:

- Existence of `~/zdotdir` directory with git repository
- Presence of Homebrew in known installation paths (not just PATH)

**Component-Based Installation**: Supports selective installation/updates:

```bash
# Interactive component selection
./install.sh -i

# Update specific components
./install.sh --component brew           # Homebrew packages only
./install.sh --component plugins        # Zsh plugins only
./install.sh --component asdf           # ASDF tools only
./install.sh --component config         # Config symlinks only
./install.sh --component macos          # macOS settings only

# Force initial setup mode
./install.sh --mode initial

# Skip confirmation prompt
./install.sh -y
```

**Safety Features**:

- Trap handlers for graceful interruption (INT, TERM, EXIT signals)
- Suggests resume commands if interrupted mid-operation
- Safe stow conflict handling - displays conflicts with resolution steps rather
  than automatically deleting files
- Idempotent operations - safe to run multiple times

**Performance Optimizations**:

- Uses `brew bundle --no-upgrade` in update mode to skip unnecessary upgrades
- Skips completed operations when resuming after interruption
- Only clones plugins if they don't exist

**Error Handling**:

- Validates brew bundle operations with detailed error messages
- Detects and reports stow conflicts with clear resolution instructions
- Verifies ASDF plugin installations
- Provides context-aware error messages for each operation

### Uninstallation Script Features

The `uninstall.sh` script provides safe, component-based uninstallation with
enterprise-grade error handling:

**Component-Based Uninstallation**: Supports selective removal of components:

```bash
# Interactive component selection
./uninstall.sh -i

# Uninstall specific components
./uninstall.sh --component brew           # Homebrew packages from Brewfile
./uninstall.sh --component plugins        # Zsh plugins directory
./uninstall.sh --component asdf           # ASDF and all tools
./uninstall.sh --component config         # Config files (unstow)
./uninstall.sh --component nvim           # Neovim files
./uninstall.sh --component venv           # Python virtual environment

# Uninstall all components
./uninstall.sh --component all

# Skip confirmation prompt
./uninstall.sh -y --component all
```

**Safety Features**:

- Trap handlers for graceful interruption (INT, TERM, EXIT signals)
- Suggests resume commands if interrupted mid-operation
- Confirmation prompt showing exactly what will be removed
- Safe component removal - checks existence before attempting removal
- Continues on individual failures with clear warnings
- Idempotent operations - safe to run multiple times

**Smart Homebrew Removal**:

- Reads Brewfile to determine exact packages to remove
- Removes packages individually (formulas and casks separately)
- Continues on failure instead of aborting entire operation
- Preserves Homebrew itself with instructions for manual removal

**Error Handling**:

- Validates stow operations with detailed error messages
- Checks for command availability (brew, stow) before use
- Provides helpful messages when components are missing
- Tracks CURRENT_OPERATION for interrupt recovery

## Configuration Architecture

### Boot Sequence

1. **`.zshenv`** (config/.zshenv) - Sets environment variables and paths
   - Defines `MY_CONFIG_PATH=$HOME/zdotdir`
   - Sets `MY_INITIAL_CONFIGURATION` to autoload script
   - Exports core paths: `MY_ZSTYLES_PATH`, `MY_ENV_PATH`

2. **`.zshrc`** (config/.zshrc) - Loads all configuration
   - Sources `autoload_functions.sh` to register functions
   - Loads files from `$SOURCE_PATHS` (zstyles + env/config)
   - Initializes oh-my-posh prompt

3. **Autoloading** (env/autoload_functions.sh)
   - Registers functions from `utils/functions/` and `env/functions/`
   - Initializes Zsh completion system

### Directory Structure

```text
zdotdir/
├── config/              # Stow-managed dotfiles (symlinked to ~/)
│   ├── .config/        # XDG config files (nvim, k9s, kitty, etc.)
│   ├── .claude/        # Claude Code integration
│   ├── .zshrc          # Main Zsh configuration
│   └── .zshenv         # Environment variables
├── env/
│   ├── autoload_functions.sh  # Function registration
│   ├── config/         # Shell configuration modules
│   │   ├── aliases.sh
│   │   ├── load_zsh_plugins.sh
│   │   └── options.sh
│   └── functions/      # Custom Zsh functions (auto-loaded)
├── plugins/            # Zsh plugins (cloned externally)
├── utils/
│   ├── colors.sh       # Color definitions
│   └── functions/      # Utility functions (auto-loaded)
├── zstyles/            # Zsh style configurations
├── Brewfile            # Homebrew package definitions
├── install.sh          # Complete installation script
└── uninstall.sh        # Complete uninstallation script
```

### Configuration Modules

**env/config/** contains shell behavior modules:

- `aliases.sh` - Shell aliases
- `load_zsh_plugins.sh` - Plugin loader (sources from plugins/)
- `options.sh` - Zsh options (setopt commands)

**zstyles/** contains completion and behavior styling:

- `fzf-tab.sh` - fzf-tab integration configuration
- `general.sh` - General Zsh styles

All files in these directories are automatically sourced via glob expansion in
`.zshrc`.

### Function System

Functions are automatically loaded from two directories:

- **utils/functions/** - Utility functions (backup_file, clone_repo, etc.)
- **env/functions/** - Shell functions (awsenv\_, eksctx, gcl, yy, etc.)

Functions are autoloaded via `autoload -Uz` in `autoload_functions.sh`.

## Zsh Plugin System

Plugins are cloned into `plugins/` and loaded via `load_zsh_plugins.sh`:

**Active Plugins**:

- `fzf-tab` - Interactive TAB completion with fzf
- `zsh-autosuggestions` - Command suggestions from history
- `zsh-history-substring-search` - Substring history search
- `zsh-completions` - Additional completion definitions
- `zsh-syntax-highlighting` - Command syntax highlighting

**Plugin Loading**: Searches for `<plugin>/<plugin>.plugin.zsh` or
`<plugin>/<plugin>.zsh`.

## Application Configurations

All application configs in `config/.config/` are symlinked to `~/.config/` via
Stow.

### AeroSpace (Window Manager)

**Config**: `config/.config/aerospace/aerospace.toml`

Tiling window manager for macOS with i3-like keybindings:

- **Workspaces**: W (tools), F (fun/music), B (books), C (communication), O
  (office/email), P (preview), T (terminal/chrome)
- **Keybindings**: Alt+hjkl for navigation, Alt+Shift+hjkl for moving windows
- **Auto-assignment**: Apps automatically move to designated workspaces on
  launch
  - Communication: Teams, Telegram, Slack → C
  - Email: Outlook, Mail → O
  - Browsers: Chrome, Safari → T
  - Terminal: Kitty → T
  - Music: Apple Music → F
- **Workspace change hook**: Runs `on-ws-change.sh` script on workspace switch
- **Monitor assignment**: Forces specific workspaces to monitors (F → built-in,
  B → Virtual Ab)

Key commands:

- Alt+slash: Horizontal tiles layout
- Alt+comma: Vertical accordion layout
- Alt+Shift+s: Enter service mode (reload config, reset layout, toggle floating)
- Alt+tab: Workspace back-and-forth

### Neovim

**Config**: `config/.config/nvim/`

**Architecture**: Lazy.nvim plugin manager with modular Lua configuration

**Structure**:

- `init.lua` - Entry point
- `lua/config/` - Core configuration (options, keymaps, autocmds, utils)
- `lua/plugins/` - Plugin specifications (26+ plugins)

**Key plugins**:

- `claude-code.lua` - Claude Code integration
- `obsidian.lua` - Obsidian note-taking integration
- `blink.lua` - Completion framework
- `diffview.lua` - Git diff viewer
- `fugitive.lua` - Git integration
- `gitsigns.lua` - Git signs in gutter
- `none-ls.lua` - LSP formatting/linting
- `dap.lua` - Debug Adapter Protocol
- `jdtls.lua` - Java language server
- `yazi.lua` - File manager integration
- `img-clip.lua` - Image clipboard
- `calendar.lua` - Calendar integration

Development languages supported: Java, Scala, Python, JavaScript/TypeScript, Go,
Rust, Lua, and more via ASDF.

### Kitty (Terminal)

**Config**: `config/.config/kitty/kitty.conf`

GPU-accelerated terminal emulator:

- Font size: 20pt
- Configured for optimal rendering with Nerd Fonts (MesloLG)
- Image preview support (for yazi file manager)
- Clipboard integration
- Custom color schemes and window styling

### Tmux

**Config**: `config/.config/tmux/tmux.conf`

Terminal multiplexer with custom bindings:

**Key bindings**:

- `prefix + r`: Reload config
- `prefix + c`: New window in current path
- `prefix + g`: Open lazygit in popup (100% size)
- `prefix + h`: Open taskwarrior-tui in popup (80% size)
- `prefix + k`: Open zsh in popup (80x75%)
- `prefix + R`: Respawn pane

**Plugins** (via TPM):

- `tmux-sensible` - Sensible defaults
- `tmux.nvim` - Neovim integration (aserowy/tmux.nvim)
- `rose-pine/tmux` - Rose Pine theme (main variant)
- `tmux-fzf` - FZF integration (Ctrl+f to launch)
- `tmux-mode-indicator` - Mode indicator in status line

**Configuration**:

- Base index: 1 (windows and panes start at 1)
- Status position: top
- Auto-renumber windows
- Shows current directory as window name
- Image passthrough for yazi

### Lazygit

**Config**: `config/.config/lazygit/config.yml`

Terminal UI for git with minimal configuration:

- Nerd Fonts v3 support
- GPG override enabled
- Sign-off commits by default
- Editor preset: nvim
- Quit on top-level return

### Yazi (File Manager)

**Config**: `config/.config/yazi/`

Modern terminal file manager with:

- `yazi.toml` - Main configuration
- `keymap.toml` - Custom keybindings
- `package.toml` - Plugin package manager config
- `plugins/` - Custom plugins directory

Integration with Neovim and tmux for image previews.

### Karabiner Elements (Keyboard Customization)

**Config**: `config/.config/karabiner/karabiner.json`

Key remapping configuration:

- **Caps Lock → Hyper Key**: Maps Caps Lock to Cmd+Ctrl+Opt+Shift for custom
  shortcuts
- **External keyboard priority**: Disables built-in keyboard when external
  keyboards are connected (vendor_id: 6645, product_id: 12885)

Useful for creating global shortcuts that don't conflict with applications.

### K9s (Kubernetes UI)

**Config**: `config/.config/k9s/`

Terminal UI for Kubernetes cluster management. Custom skins, shortcuts, and
cluster-specific configurations.

Environment variable: `K9S_CONFIG_DIR=$HOME/.config/k9s`

### Oh-My-Posh (Prompt)

**Config**: `config/.config/oh-my-posh/ab.omp.toml`

Custom prompt theme with segments for:

- Git status
- Kubernetes context
- AWS profile
- Programming language versions
- Execution time
- Error status

Initialized in `.zshrc` with:
`oh-my-posh init zsh --config $HOME/.config/oh-my-posh/ab.omp.toml`

## Claude Code Integration

### Custom Scripts

Located in `config/.claude/scripts/`:

```bash
# Task management system
~/.claude/scripts/task-manager.sh list
~/.claude/scripts/task-manager.sh add "Task description" "when"

# Fetch Jira tickets
~/.claude/scripts/fetch-my-jira-tickets.sh
```

### Status Line

`config/.claude/statusline.sh` provides rich context display:

- Current directory and git branch
- Kubernetes context (with production warnings)
- AWS profile (with production warnings)
- Claude model and token usage
- Cost estimates and message count

## Development Workflow

### Testing Configuration Changes

```bash
# Enable debug profiling
export ZDOTFILES_DEBUG=1
source ~/.zshrc

# Test specific function
autoload -Uz function_name
function_name args
```

### Adding New Functions

1. Create file in `env/functions/<function-name>` or
   `utils/functions/<function-name>`
2. Use Zsh script shebang if needed: `#!/usr/bin/env zsh`
3. Function is auto-loaded on next shell startup
4. Test immediately: `autoload -Uz <function-name>`

### Adding New Aliases/Options

- Edit `env/config/aliases.sh` for new aliases
- Edit `env/config/options.sh` for Zsh options
- Changes take effect on next `source ~/.zshrc`

### Modifying Zsh Plugins

Plugins in `plugins/` are git repositories. Update with:

```bash
git -C plugins/<plugin-name> pull
```

### Brewfile Changes

After modifying Brewfile:

```bash
brew bundle install --file=./Brewfile
brew bundle dump --force  # Update lock file
```

## Key Environment Variables

```bash
MY_CONFIG_PATH         # ~/zdotdir
MY_INITIAL_CONFIGURATION  # autoload_functions.sh path
MY_ZSTYLES_PATH        # Array of zstyle files
MY_ENV_PATH            # Array of env/config files
ASDF_CONFIG_FILE       # Points to config/.asdfrc
K9S_CONFIG_DIR         # ~/.config/k9s
LG_CONFIG_FILE         # ~/.config/lazygit/config.yml
EDITOR                 # nvim
DOCKER_BUILDKIT        # 1 (enabled by default)
```

## Important Tools

### Version Management

**asdf** manages all language runtimes and CLI tools. See
`config/.tool-versions` for complete list including:

- Programming languages: golang, nodejs, python, rust, java, scala
- Kubernetes tools: kubectl, helm, k9s, kubectx
- AWS tools: awscli, aws-sam-cli
- Others: terraform, neovim, jq, yq, fzf

### Container Management

Docker is configured with BuildKit enabled. Docker Buildx plugin is symlinked
during installation.

### Git Configuration

Supports multiple git configs:

- `config/.gitconfig` - Main config (stowed to ~/.gitconfig)
- `gitconfig-office` - Office-specific config (not under version control)
- `gitconfig-personal` - Personal config

### Neovim Configuration

Full Neovim config in `config/.config/nvim/`. Uses Lazy plugin manager and
various plugins for development.

## Notes

- The `office_profile` file is sourced if it exists but is not under version
  control
- Python virtual environment in `.venv/` is created during installation
- Hammerspoon, Karabiner, and AeroSpace configs are in `config/.config/`
- Alfred workflows are in `alfred/Alfred.alfredpreferences/`
- iTerm2 preferences in `iterm2/com.googlecode.iterm2.plist`
