#!/usr/bin/env bash
# Semi-transparent, always-on-top terminal ("LogOverlay") at the top-right of the focused
# screen, as a kitty panel (real NSWindow level, so it stays above other windows).
# Width is COLS cells, anchored to the right edge. Height is LINES cells worth of pixels
# (panels size vertically by margins), clamped to 60% of the screen height.
set -eu
COLS=90 LINES_=37
LINE_H=19   # points per line at font_size 16; adjust if the font changes
OPACITY=0.6

visible_h=$(osascript -l JavaScript -e "ObjC.import('AppKit'); Math.round(\$.NSScreen.mainScreen.visibleFrame.size.height)")
want=$((LINES_ * LINE_H))
max=$((visible_h * 6 / 10))
((want > max)) && want=$max
margin_bottom=$((visible_h - want))

exec /Applications/kitty.app/Contents/MacOS/kitten panel \
  --edge=right --layer=top --columns="$COLS" \
  --margin-top=0 --margin-bottom="$margin_bottom" \
  --focus-policy=on-demand --override background_opacity="$OPACITY"
