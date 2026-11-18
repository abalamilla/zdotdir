#!/usr/bin/env bash
# Install (or --uninstall) a LaunchAgent that serves $WORK_DIR/docs with gh-mini
# (file tree, live reload, HTML previews) on localhost.
#
# A plist cannot expand variables and launchd cannot read a profile kept in a synced
# folder, so $WORK_DIR and the gh-mini path are resolved now, from your shell.
# Re-run after moving WORK_DIR or upgrading the Go toolchain that holds gh-mini.
#
# DOCS_PREVIEW_PORT (default 6419) and DOCS_PREVIEW_HTML_PORT (default 6421) set the
# ports. The HTML preview port is fixed on purpose: it is the origin lesson pages keep
# their saved answers under, so a random port would lose them on every restart.
set -euo pipefail

LABEL="local.docs-preview"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/docs-preview.log"
PORT="${DOCS_PREVIEW_PORT:-6419}"
HTML_PORT="${DOCS_PREVIEW_HTML_PORT:-6421}"

unload() {
  launchctl bootout "gui/$(id -u)/$1" 2>/dev/null || true
  rm -f "$HOME/Library/LaunchAgents/$1.plist"
}

if [[ "${1:-}" == "--uninstall" ]]; then
  unload "$LABEL"
  echo "removed $LABEL"
  exit 0
fi

: "${WORK_DIR:?WORK_DIR is not set in this shell}"
DOCS="$WORK_DIR/docs"
[[ -d "$DOCS" ]] || { echo "no docs directory at $DOCS" >&2; exit 1; }
GH_MINI="$(type -P gh-mini || true)"
[[ -n "$GH_MINI" ]] || { echo "gh-mini not on PATH (go install github.com/babarot/gh-mini@latest)" >&2; exit 1; }

mkdir -p "$(dirname "$PLIST")" "$(dirname "$LOG")"
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$GH_MINI</string>
    <string>--no-open</string>
    <string>--port</string><string>$PORT</string>
    <string>--preview-port</string><string>$HTML_PORT</string>
    <string>.</string>
  </array>
  <key>WorkingDirectory</key><string>$DOCS</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLIST
plutil -lint "$PLIST" >/dev/null

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "installed $LABEL: $DOCS on http://localhost:$PORT/ (HTML previews on $HTML_PORT), log $LOG"
