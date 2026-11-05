#!/bin/sh
# Claude Code PostToolUse hook for Edit/Write: shellcheck sh/bash scripts and
# format Lua with stylua. Exit 2 sends stderr back to Claude so it fixes the
# findings in the same turn. zsh files are skipped (shellcheck can't parse zsh).

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] && [ -f "$file" ] || exit 0

case "$file" in
*.lua)
	stylua=$(command -v stylua || echo "$HOME/.local/share/nvim/mason/bin/stylua")
	[ -x "$stylua" ] || exit 0
	# stylua looks up stylua.toml from the working directory
	cd "$(dirname "$file")" && "$stylua" --search-parent-directories "$file" 2>&1 >/dev/null | head -20 >&2
	exit 0
	;;
*.sh | *.bash) ;;
*)
	head -n1 "$file" | grep -qE '^#!.*[/ ](ba)?sh( |$)' || exit 0
	;;
esac

command -v shellcheck >/dev/null 2>&1 || exit 0
out=$(shellcheck -S warning -f gcc "$file" 2>&1) && exit 0
printf 'shellcheck found issues in %s:\n%s\n' "$file" "$out" | head -40 >&2
exit 2
