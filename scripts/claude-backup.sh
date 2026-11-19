#!/usr/bin/env bash
# Hourly local backup of ~/.claude (memories, chats, prompt history, small configs)
# into the git repo that lives in ~/.claude itself. Its .gitignore is a whitelist,
# so caches and other rebuildable state never get staged.
#
#   claude-backup.sh              run one backup (what the LaunchAgent does)
#   claude-backup.sh --install    write and load the LaunchAgent (run from your shell)
#   claude-backup.sh --uninstall  unload and remove it
#
# Rules:
# - New and changed files are staged, deletions never are. Chats that Claude Code
#   cleans up after cleanupPeriodDays stay in the repo.
# - gitleaks scans what is staged. A file with a finding is left out of this run
#   and logged; redact the value by hand and the next run picks the file up.
# - It only commits locally. Pushing is not part of this script.
#
# A plist cannot expand variables and launchd has a minimal PATH, so --install
# resolves the tool paths now, from your shell. Re-run it after a jq/gitleaks move.
# The scheduled run only touches ~/.claude, ~/.agents and ~/Library/Logs, which
# launchd can read (OneDrive and ~/Documents it cannot).
set -uo pipefail

LABEL="local.claude-backup"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/claude-backup.log"
REPO="$HOME/.claude"
INTERVAL="${CLAUDE_BACKUP_INTERVAL:-3600}"

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >> "$LOG"; }

case "${1:-}" in
  --uninstall)
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "removed $LABEL"
    exit 0 ;;
  --install)
    set -e
    for t in git jq gitleaks; do
      type -P "$t" >/dev/null || { echo "$t not on PATH" >&2; exit 1; }
    done
    path="$(dirname "$(type -P jq)"):$(dirname "$(type -P gitleaks)"):$(dirname "$(type -P git)"):/usr/bin:/bin:/usr/sbin:/sbin"
    self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    mkdir -p "$(dirname "$PLIST")" "$(dirname "$LOG")"
    cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$self</string></array>
  <key>EnvironmentVariables</key>
  <dict><key>PATH</key><string>$path</string></dict>
  <key>StartInterval</key><integer>$INTERVAL</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLIST
    plutil -lint "$PLIST" >/dev/null
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
    echo "installed $LABEL: every ${INTERVAL}s, log $LOG"
    exit 0 ;;
esac

cd "$REPO" || { log "no repo at $REPO"; exit 1; }
[ -d .git ] || { log "$REPO is not a git repo"; exit 1; }

# One run at a time.
LOCK="$REPO/.git/claude-backup.lock"
mkdir "$LOCK" 2>/dev/null || { log "another run holds $LOCK, skipping"; exit 0; }
trap 'rm -rf "$LOCK"' EXIT

# Exports of state that lives outside the whitelist.
mkdir -p exports
if jq '{mcpServers: (.mcpServers // {}),
        projects: (.projects | with_entries(select((.value.mcpServers // {}) != {})
                   | .value = {mcpServers: .value.mcpServers}))}' \
     "$HOME/.claude.json" > exports/mcp-servers.json.tmp 2>/dev/null; then
  mv exports/mcp-servers.json.tmp exports/mcp-servers.json
else
  rm -f exports/mcp-servers.json.tmp; log "mcp export failed"
fi
[ -f "$HOME/.agents/.skill-lock.json" ] && cp "$HOME/.agents/.skill-lock.json" exports/skill-lock.json

# Stage new and modified files only, never deletions.
git add --ignore-removal . || { log "git add failed"; exit 1; }
git diff --cached --quiet && exit 0

# Leave out any staged file gitleaks flags.
report="$(mktemp)"
gitleaks git --pre-commit --staged --redact --no-banner \
  --report-format json --report-path "$report" . >/dev/null 2>&1
rc=$?
if [ $rc -ne 0 ] && [ -s "$report" ] && [ "$(jq length "$report")" -gt 0 ]; then
  jq -r '.[] | "\(.File)\t\(.RuleID)"' "$report" | sort -u | while IFS=$'\t' read -r f rule; do
    git reset -q -- "$f" 2>/dev/null || git rm -q --cached -- "$f" 2>/dev/null
    log "skipped $f ($rule)"
  done
elif [ $rc -ne 0 ]; then
  rm -f "$report"; log "gitleaks failed (exit $rc), nothing committed"; exit 1
fi
rm -f "$report"
git diff --cached --quiet && exit 0

git commit -q -m "backup: $(date -u +%Y-%m-%dT%H:%M:%SZ)" || { log "commit failed"; exit 1; }
log "committed $(git rev-parse --short HEAD)"
