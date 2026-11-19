#!/usr/bin/env bash
# Stop orphaned `nvim --embed` servers.
#
# A terminal nvim is a UI client plus an `nvim --embed` server. When the terminal goes
# away first (kitty quit or crash), the server can survive with parent PID 1, no UI and
# nothing to attach to, holding its language servers and growing (one reached 27 GB).
# SIGTERM makes nvim keep its swap files, so unsaved edits stay recoverable; SIGKILL
# follows after 5s because a hung language server can block a clean exit.
#
# Runs after a session restore (restore_session.py). Usage: orphan_nvim_cleanup.sh [--dry-run]
set -uo pipefail

DRY=false
[[ "${1:-}" == "--dry-run" ]] && DRY=true

orphans() {
  ps -U "$(id -u)" -o pid=,ppid=,args= | awk '$2 == 1 && $3 ~ /(^|\/)nvim$/ && $4 == "--embed" {print $1}'
}

pids=()
while read -r p; do pids+=("$p"); done < <(orphans)
(( ${#pids[@]} )) || { $DRY && echo "no orphaned nvim"; exit 0; }

mem=()
for p in "${pids[@]}"; do
  mem+=("$(top -l 1 -pid "$p" -stats mem 2>/dev/null | tail -1 | tr -d ' ')")
done
summary="${#pids[@]} orphaned nvim ($(IFS=,; echo "${mem[*]}"))"

if $DRY; then
  echo "would stop $summary: ${pids[*]}"
  exit 0
fi

kill -TERM "${pids[@]}" 2>/dev/null
for _ in 1 2 3 4 5; do
  sleep 1
  alive=()
  for p in "${pids[@]}"; do kill -0 "$p" 2>/dev/null && alive+=("$p"); done
  (( ${#alive[@]} )) || break
done
(( ${#alive[@]} )) && kill -KILL "${alive[@]}" 2>/dev/null

osascript -e "display notification \"Stopped $summary. Swap files kept for unsaved edits.\" with title \"kitty\"" \
  >/dev/null 2>&1 || true
echo "stopped $summary"
