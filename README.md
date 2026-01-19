# zdotdir - Personal Zsh Development Environment

A comprehensive, modular development environment configuration for Zsh with
modern tooling, automated setup, and extensive customizations.

## Features

- **Intelligent Installation**: Auto-detects initial setup vs. updates, with
  component-based installation
- **Modern Shell Experience**: Zsh with oh-my-posh prompt, interactive
  completions, and powerful plugins
- **Unified Tool Management**: ASDF for language runtimes, Homebrew for packages
- **Dotfile Management**: GNU Stow for symlink management
- **Application Configs**: Pre-configured Neovim, Kitty, Tmux, AeroSpace, and
  more
- **Cloud-Native Tooling**: Kubernetes, AWS, Docker tools pre-installed
- **Idempotent Operations**: Safe to run multiple times without errors

## Quick Start

### Fresh Installation

```bash
curl -s https://raw.githubusercontent.com/abalamilla/zdotdir/main/install.sh | zsh
```

This will:

1. Clone the repository to `~/zdotdir`
2. Install Homebrew (if not present)
3. Install all packages from Brewfile
4. Clone Zsh plugins
5. Symlink configuration files to `~/.config/` and `~/`
6. Configure ASDF and install all tools from `.tool-versions`
7. Set up Python virtual environment
8. Configure macOS settings (if on macOS)

### Update Existing Installation

```bash
cd ~/zdotdir
./install.sh
```

The script auto-detects update mode and runs faster by skipping unnecessary
steps.

## Installation Options

The `install.sh` script supports flexible installation modes:

```bash
# Show help
./install.sh --help

# Update only specific components
./install.sh --component brew           # Update Homebrew packages only
./install.sh --component plugins        # Update Zsh plugins only
./install.sh --component asdf           # Update ASDF tools only
./install.sh --component config         # Refresh config symlinks only
./install.sh --component macos          # Reconfigure macOS settings only

# Force initial setup mode
./install.sh --mode initial

# Update from specific branch
./install.sh --branch feature-branch

# Skip confirmation prompt
./install.sh -y
```

## Repository Structure

```text
zdotdir/
├── config/                 # Dotfiles (symlinked via Stow)
│   ├── .config/           # XDG config directory
│   │   ├── nvim/         # Neovim configuration (Lazy.nvim)
│   │   ├── kitty/        # Kitty terminal config
│   │   ├── tmux/         # Tmux configuration
│   │   ├── aerospace/    # AeroSpace window manager
│   │   ├── oh-my-posh/   # Shell prompt theme
│   │   ├── lazygit/      # Git TUI config
│   │   ├── yazi/         # File manager config
│   │   └── k9s/          # Kubernetes TUI config
│   ├── .claude/          # Claude Code integration
│   ├── .zshrc            # Main Zsh configuration
│   └── .zshenv           # Environment variables
├── env/
│   ├── autoload_functions.sh  # Function autoloader
│   ├── config/           # Shell configuration modules
│   │   ├── aliases.sh    # Shell aliases
│   │   ├── load_zsh_plugins.sh  # Plugin loader
│   │   └── options.sh    # Zsh options
│   └── functions/        # Custom functions (auto-loaded)
├── plugins/              # Zsh plugins (cloned externally)
├── utils/
│   ├── colors.sh         # Color definitions
│   └── functions/        # Utility functions
├── zstyles/              # Zsh style configurations
├── Brewfile              # Homebrew package definitions
├── .tool-versions        # ASDF tool versions
├── requirements.txt      # Python packages
└── install.sh            # Installation script
```

## Configuration Architecture

### Boot Sequence

1. **`.zshenv`** - Sets environment variables and core paths
2. **`.zshrc`** - Loads configuration modules and initializes prompt
3. **Autoloading** - Registers functions from `utils/functions/` and
   `env/functions/`

All configuration files in `config/` are symlinked to your home directory using
GNU Stow:

```bash
stow config -t ~
```

### Function System

Functions are automatically discovered and loaded from:

- `utils/functions/` - Utility functions
- `env/functions/` - Shell functions (awsenv, eksctx, gcl, yy, etc.)

## Zsh Plugins

- **[fzf-tab](https://github.com/Aloxaf/fzf-tab)** - Interactive TAB completion
  with fuzzy finding
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** -
Command suggestions from history
<!-- markdownlint-disable-next-line MD013 -->
- **[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)** -
  Substring history search
- **[zsh-completions](https://github.com/zsh-users/zsh-completions)** -
Additional completion definitions
<!-- markdownlint-disable-next-line MD013 -->
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** -
  Real-time syntax highlighting

## Application Configurations

### Neovim

Modern Neovim setup with [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin
manager.

**Key plugins**: LSP, Tree-sitter, Telescope, Git integration, DAP debugging,
Claude Code integration, Obsidian notes

**Location**: `config/.config/nvim/`

### Kitty Terminal

GPU-accelerated terminal with image preview support and Nerd Font rendering.

**Location**: `config/.config/kitty/kitty.conf`

### Tmux

Terminal multiplexer with plugins via TPM:

- tmux-sensible
- tmux.nvim (Neovim integration)
- rose-pine theme
- tmux-fzf

**Location**: `config/.config/tmux/tmux.conf`

### AeroSpace Window Manager

Tiling window manager for macOS with i3-like keybindings.

**Key features**:

- Workspace-based navigation (Alt+hjkl)
- Auto-assignment of apps to workspaces
- Multi-monitor support

**Location**: `config/.config/aerospace/aerospace.toml`

### oh-my-posh Prompt

Custom shell prompt with segments for:

- Git status
- Kubernetes context
- AWS profile
- Programming language versions
- Execution time

**Location**: `config/.config/oh-my-posh/ab.omp.toml`

## Tool Management

### ASDF

Version manager for multiple languages and tools. All versions are defined in
`.tool-versions`:

**Languages**: Go, Node.js, Python, Rust, Java, Scala, Julia **Cloud Tools**:
kubectl, helm, k9s, argocd, awscli **Development**: terraform, neovim, lazygit,
fzf, ripgrep

```bash
# Install all tools
asdf install

# Add a new plugin
asdf plugin add <name>

# List installed versions
asdf list
```

### Homebrew

Package manager for macOS/Linux. Packages defined in `Brewfile`:

```bash
# Install/update packages
brew bundle install --file=./Brewfile

# Update Brewfile with current packages
brew bundle dump --force
```

## Customization

### Adding Aliases

Edit `env/config/aliases.sh`:

```bash
alias myalias='command'
```

Reload: `source ~/.zshrc`

### Adding Functions

Create a file in `env/functions/<function-name>`:

```zsh
#!/usr/bin/env zsh
function_name() {
  # Your code here
}
```

The function is auto-loaded on next shell startup.

### Adding Zsh Options

Edit `env/config/options.sh`:

```bash
setopt AUTO_CD
```

### Modifying Zsh Plugins

Plugins are git repositories in `plugins/`. Update with:

```bash
git -C plugins/<plugin-name> pull
```

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

### Managing Brewfile

```bash
# Add packages to Brewfile manually or via:
brew bundle dump --force

# Install new packages
brew bundle install
```

### Updating ASDF Tools

```bash
# Update plugin versions in .tool-versions
asdf install
```

## Key Environment Variables

```bash
MY_CONFIG_PATH         # ~/zdotdir
ASDF_CONFIG_FILE       # ~/.asdfrc
K9S_CONFIG_DIR         # ~/.config/k9s
LG_CONFIG_FILE         # ~/.config/lazygit/config.yml
EDITOR                 # nvim
DOCKER_BUILDKIT        # 1
```

## Claude Code Integration

This repository includes Claude Code configuration:

- Custom scripts in `config/.claude/scripts/`
- Task management system
- Jira ticket fetching
- Rich status line with context information

## macOS-Specific Features

### AeroSpace

Tiling window manager with automatic app workspace assignment.

### Karabiner Elements

Key remapping:

- Caps Lock → Hyper Key (Cmd+Ctrl+Opt+Shift)
- External keyboard priority

### Hammerspoon

Lua-based automation (config in `config/.config/hammerspoon/`)

## Updating

### Update Everything

```bash
cd ~/zdotdir
./install.sh
```

### Update Specific Components

```bash
# Update Homebrew packages
./install.sh --component brew -y

# Update Zsh plugins
./install.sh --component plugins -y

# Update ASDF tools
./install.sh --component asdf -y

# Refresh config symlinks
./install.sh --component config -y
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Remove existing files/symlinks first
stow -D config -t ~  # Unstow
stow config -t ~     # Restow
```

### ASDF Plugin Errors

If plugin installation fails:

```bash
# Remove and re-add plugin
asdf plugin remove <plugin>
asdf plugin add <plugin>
asdf install
```

### Homebrew Issues

```bash
# Fix brew doctor issues
brew doctor

# Update Homebrew itself
brew update
```

## Contributing

This is a personal configuration repository, but feel free to fork and adapt for
your own use.

## License

Personal configuration - use at your own discretion.

## Resources

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [oh-my-posh Themes](https://ohmyposh.dev/docs/themes)
- [ASDF Plugins](https://github.com/asdf-vm/asdf-plugins)
- [Homebrew Formulae](https://formulae.brew.sh/)
- [Neovim Documentation](https://neovim.io/doc/)
- [AeroSpace Guide](https://nikitabobko.github.io/AeroSpace/guide)
