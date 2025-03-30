#!/usr/bin/env zsh

CURRENT_WS=$(aerospace list-workspaces --focused)

move_window() {
	WINDOW_TITLE=$1

	WINDOW_ID=$(aerospace list-windows --all --format '%{window-id}|%{window-title}|' | rg "${WINDOW_TITLE}" | awk -F'|' 'NR==1{print $1}')

	[[ $WINDOW_ID != "" ]] && aerospace move-node-to-workspace --window-id "${WINDOW_ID}" "${CURRENT_WS}"
}

move_window "Picture in Picture"
move_window "Reminder"
