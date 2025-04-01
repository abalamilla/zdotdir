#!/usr/bin/env bash

BUILT_IN=$(aerospace list-monitors | rg "Built-in" | awk -F'|' '{print $1}' | xargs )
FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk -F'|' '{print $1}' | xargs)

move_window() {
	WINDOW_TITLE=$1

	WINDOW_ID=$(aerospace list-windows --all --format '%{window-id}|%{window-title}|' | rg "${WINDOW_TITLE}" | awk -F'|' 'NR==1{print $1}')

	[[ $WINDOW_ID != "" && $FOCUSED_MONITOR != "$BUILT_IN" ]] && aerospace move-node-to-workspace --window-id "${WINDOW_ID}" "${AEROSPACE_FOCUSED_WORKSPACE}"
}

move_window "Picture in Picture"
move_window "Reminder"
