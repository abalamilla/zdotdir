---
paths:
  - "env/**/*"
  - "config/.zshrc"
  - "config/.zshenv"
  - "config/.zprofile"
  - "zstyles/**/*"
  - "install.sh"
  - "uninstall.sh"
---

# Shell Configuration

## Boot Sequence

1. **`.zprofile`** — Runs once at login
   - Initializes `SOURCE_PATHS` array for all config files
   - Sets core environment variables

2. **`.zshenv`** — Always loaded before `.zshrc`
   - Defines `MY_CONFIG_PATH=$HOME/zdotdir`
   - Exports paths used throughout shell

3. **`.zshrc`** — Interactive shell config
   - Sources `autoload_functions.sh` to register functions
   - Loads files from `$SOURCE_PATHS` (zstyles + env/config)
   - Initializes oh-my-posh prompt

## Functions

Functions auto-load from two directories:

- **`utils/functions/`** — Utility functions (backup_file, clone_repo, etc.)
- **`env/functions/`** — Shell integration functions (awsenv, eksctx, etc.)

Register new functions via `autoload -Uz <name>` in shell. They auto-load on
next startup.

## Configuration Modules

**`env/config/`** contains shell behavior:

- `aliases.sh` — Shell aliases
- `load_zsh_plugins.sh` — Plugin loader (sources from plugins/)
- `options.sh` — Zsh options (setopt commands)
- `oracle.sh` — Oracle-specific settings

**`zstyles/`** contains completion/behavior styling:

- Files auto-load via glob expansion in `.zshrc`

## Plugins

Plugins in `plugins/` (cloned separately):

- fzf-tab — Interactive TAB completion with fzf
- zsh-autosuggestions — History suggestions
- zsh-history-substring-search — Substring history search
- zsh-completions — Additional completion definitions
- zsh-syntax-highlighting — Command syntax highlighting

Update individual plugins: `git -C plugins/<name> pull`

## Installation/Uninstallation

**Install features** (mode detection, safety, backups):

```bash
./install.sh -i                    # Interactive component selection
./install.sh --component brew,plugins,mise -y  # Specific components
./install.sh --component upgrade-tools -y  # Upgrade tool versions
```

Safety features: trap handlers, conflict detection, idempotent operations,
backups before changes.

**Uninstall features:**

```bash
./uninstall.sh -i                  # Interactive selection
./uninstall.sh --component config -y  # Uninstall stow symlinks
```

Safety: confirmation prompt, checks existence before removal, continues on
failures.

See `./install.sh -h` and `./uninstall.sh -h` for all options.
