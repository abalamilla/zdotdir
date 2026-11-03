# Kitty sessions

Save every kitty OS window, tab and window, then restore it in a fresh kitty with
the same apps reopened where they were.

| Key | Action |
| --- | --- |
| `ctrl+shift+alt+s` | Save to `~/.local/share/kitty/sessions/current.kitty-session` (previous save kept as `.bak`) |
| `ctrl+shift+alt+r` | Restore, only in a fresh kitty (one window at an empty prompt) |

## What is saved per window

Decided by what is running in the window at save time, not by how it was launched:

| Running | Restored as |
| --- | --- |
| `claude` | `claude --resume <id>` in its cwd, or `claude_root` if the window has no id |
| `nvim` | `nvim` in its process cwd (the dir you `:cd`'d to), loading its persistence.nvim session |
| `yazi` | `yazi` in its cwd |
| anything else, or a prompt | zsh in the window's cwd; commands are never re-run |

Also saved: tab order, each tab's layout and window order, active window and tab,
tab titles you renamed by hand. Not saved: split proportions (kitty's
`set_layout_state` is internal-only), titles set by programs (nvim and Claude set
their own again), overlay windows.

## How the Claude session id is known

All Claude windows run in `$WORK_DIR`, so the id cannot be worked out from the
transcripts. A `SessionStart` hook (`~/.claude/scripts/kitty-claude-session.sh`,
wired in `~/.claude/settings.json`) stores it on the window as the kitty user var
`CLAUDE_SESSION_ID`. It fires on startup, resume, `/clear` and compact.

A Claude that was already running before the hook existed has no id. Tag it from
inside that Claude with:

```sh
kitten @ set-user-vars --match id:$KITTY_WINDOW_ID CLAUDE_SESSION_ID=$CLAUDE_CODE_SESSION_ID
```

## Why not `save_as_session`

kitty's built-in `save_as_session` saves the command a window was launched with:
Claude windows come back as a new `claude_root`, and nvim loses the dir you
`:cd`'d to. `--use-foreground-process` re-runs the exact foreground command,
which also replays things like `rm` or `kubectl delete`.

## Why restore refuses in a non-fresh kitty

Loading the file adds tabs next to whatever is open, so restoring while the
original windows still run would resume the same Claude sessions twice.

## Files

- `config/.config/kitty/save_session.py`, `restore_session.py`: the kittens
- `config/.claude/scripts/kitty-claude-session.sh`: the Claude hook
- New files under `config/` need `stow -v config -t ~` to be linked
