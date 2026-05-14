# CLAUDE.md

Guidance for Claude Code when working in this zdotdir repository.

## Overview

Personal Zsh configuration managing shell environment, dotfiles, and development
tools. Configuration files in `config/` are symlinked to `$HOME` via GNU Stow.

## Quick Start

**Installation:**

```bash
curl -s https://raw.githubusercontent.com/abalamilla/zdotdir/main/install.sh | zsh
# Or for development
stow config -t ~
./install.sh -i
```

**Update components:**

```bash
./install.sh --component brew,plugins,mise -y
```

See `./install.sh -h` and `./uninstall.sh -h` for all options.

## Architecture

Shell boot sequence:

1. `.zprofile` — Initializes `SOURCE_PATHS` and core environment
2. `.zshenv` — Sets `MY_CONFIG_PATH` and exports key paths
3. `.zshrc` — Loads configuration from `$SOURCE_PATHS` via glob expansion

Functions auto-load from `env/functions/` and `utils/functions/` via
`autoload -Uz`.

## Adding New Documentation

When your docs grow beyond a single concern, split into path-scoped rules:

1. Create file in `.claude/rules/<topic>.md`
2. Add YAML frontmatter with glob patterns:

   ```markdown
   ---
   paths:
     - "env/**/*"
     - "config/.config/nvim/**/*"
   ---

   # Your Docs
   ```

3. Docs load only when Claude edits matching files
4. Keep each rule file under 200 lines
5. Update this file to reference new rules if needed

**Key patterns:**

- `env/**/*` — All files in env/ and subdirs
- `config/.config/nvim/**/*` — Neovim config files
- `*.sh` — All shell scripts in root
- `zstyles/**/*` — All zstyle files

See `.claude/rules/` directory for examples.

## Claude Code Integration

Scripts in `config/.claude/scripts/`:

- `task-manager.sh` — Task persistence system
- `fetch-my-jira-tickets.sh` — Fetch Jira tickets

Status line provided by oh-my-posh theme with context (git, k8s, AWS, etc.).

## Development

**Add new function:**

1. Create file in `env/functions/<name>` or `utils/functions/<name>`
2. Use shebang if needed: `#!/usr/bin/env zsh`
3. Auto-loads on next shell startup

**Add new alias/option:**

- Edit `env/config/aliases.sh` (aliases)
- Edit `env/config/options.sh` (zsh options)

**Update tools/packages:**

```bash
brew bundle install --file=./Brewfile
brew bundle dump --force  # Update lock file
mise install  # Install all tools from .tool-versions
```

## Important

- All dotfiles are stow-managed; don't edit `~/.<config>` directly, edit in
  `config/`
- Application configs in `config/.config/` are self-contained; explore config files directly
- Check `.claude/rules/*.md` for interconnected system guidance (shell boot sequence, Neovim)
