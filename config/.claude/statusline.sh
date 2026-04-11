#!/usr/bin/env bash
# Dynamic status line that adapts to terminal width

# Get terminal width
width=$(tput cols 2>/dev/null || echo 120)

# Get directory name
dir=$(pwd | xargs basename)

# Get ccusage status (without newlines initially)
ccusage_output=$(bun x ccusage statusline 2>/dev/null)

# Build status line based on width
if (( width < 80 )); then
  # Very narrow: stack vertically
  printf "%s\n" "$dir"
  printf "%s\n" "$ccusage_output"
elif (( width < 120 )); then
  # Medium: split into two logical sections
  printf "%s\n%s\n" "$dir" "$ccusage_output"
else
  # Wide: single line
  printf "%s | %s\n" "$dir" "$ccusage_output"
fi
