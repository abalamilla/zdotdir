#!/bin/sh
# Claude Code SessionStart hook: store the session id on the kitty window as
# the CLAUDE_SESSION_ID user var, so ~/.config/kitty/save_session.py can
# restore this window with `claude --resume <id>`. Fires on startup, resume,
# /clear and compact, so the var follows id changes. Prints nothing: stdout of
# a SessionStart hook is added to Claude's context.

[ -n "$KITTY_WINDOW_ID" ] && [ -n "$KITTY_LISTEN_ON" ] || exit 0
command -v kitten >/dev/null 2>&1 || exit 0

session_id=$(jq -r '.session_id // empty' 2>/dev/null)
[ -n "$session_id" ] || exit 0

kitten @ --to "$KITTY_LISTEN_ON" set-user-vars --match "id:$KITTY_WINDOW_ID" \
	"CLAUDE_SESSION_ID=$session_id" >/dev/null 2>&1
exit 0
