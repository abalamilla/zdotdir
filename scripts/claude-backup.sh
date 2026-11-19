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
# - gitleaks scans what is staged. Flagged values are replaced with [REDACTED]
#   in the staged copy only; the file on disk is left as it is. A file whose
#   finding survives the replace is left out of the run and logged. Unreferenced
#   objects (the unredacted blobs `git add` wrote) are pruned after each commit.
# - It commits locally every run, and pushes only when a remote named origin
#   is configured.
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

# Secret scan of what is staged. gitleaks writes the matched values into the
# report, so it lives in a 0600 temp file that is removed on exit and never printed.
report="$(mktemp)"
# On every exit: `git add` wrote the unredacted blobs into .git/objects before the
# index was swapped to the redacted ones (or the file was skipped). Nothing
# references them, so prune them at once instead of waiting for gc to expire them.
cleanup() {
  rm -f "$report"
  git prune --expire=now >/dev/null 2>&1 || log "prune failed"
  rm -rf "$LOCK"
}
trap cleanup EXIT
scan() {
  : > "$report"
  gitleaks git --pre-commit --staged --no-banner \
    --report-format json --report-path "$report" . >/dev/null 2>&1
}
findings() { [ -s "$report" ] && [ "$(jq length "$report")" -gt 0 ]; }

scan; rc=$?
if [ $rc -ne 0 ] && ! findings; then
  log "gitleaks failed (exit $rc), nothing committed"; exit 1
fi

# Redact flagged values in the staged copy only. The file on disk keeps its
# original text; the index gets a blob with [REDACTED] in place of each value.
if findings; then
  python3 -I - "$report" <<'PY' | while IFS= read -r line; do log "$line"; done
import collections, json, subprocess, sys
secrets, rules = collections.defaultdict(set), collections.defaultdict(set)
for f in json.load(open(sys.argv[1])):
    if f.get("Secret"):
        secrets[f["File"]].add(f["Secret"].encode())
        rules[f["File"]].add(f["RuleID"])
for path, values in secrets.items():
    blob = subprocess.run(["git", "show", ":" + path], capture_output=True).stdout
    for v in sorted(values, key=len, reverse=True):
        blob = blob.replace(v, b"[REDACTED]")
    sha = subprocess.run(["git", "hash-object", "-w", "--stdin"], input=blob,
                         capture_output=True, check=True).stdout.decode().strip()
    subprocess.run(["git", "update-index", "--cacheinfo", f"100644,{sha},{path}"], check=True)
    print(f"redacted {path} ({', '.join(sorted(rules[path]))}; {len(values)} values)")
PY
  # Anything still flagged (a value the replace could not match) stays out.
  scan
  if findings; then
    jq -r '.[] | "\(.File)\t\(.RuleID)"' "$report" | sort -u | while IFS=$'\t' read -r f rule; do
      git reset -q -- "$f" 2>/dev/null || git rm -q --cached -- "$f" 2>/dev/null
      log "skipped $f ($rule)"
    done
  fi
fi
git diff --cached --quiet && exit 0

git commit -q -m "backup: $(date -u +%Y-%m-%dT%H:%M:%SZ)" || { log "commit failed"; exit 1; }
log "committed $(git rev-parse --short HEAD)"

# Push only once a remote named origin is configured. Off VPN it fails and the
# next run pushes the backlog.
if git remote get-url origin >/dev/null 2>&1; then
  out="$(git push -q origin HEAD 2>&1)" || log "push failed: $(printf '%s' "$out" | tail -1)"
fi
