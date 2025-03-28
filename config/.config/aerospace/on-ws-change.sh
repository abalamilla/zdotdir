#!/usr/bin/env bash

chrome_pip=$(aerospace list-windows --all --format '%{window-id}|%{window-title}|' | rg "Picture in Picture" | awk -F'|' 'NR==1{print $1}')
outlook_reminder=$(aerospace list-windows --all --format '%{window-id}|%{window-title}' | rg "Reminder" | awk -F'|' 'NR==1{print $1}')
ws=$(aerospace list-workspaces --focused)

[[ $chrome_pip != "" ]] && aerospace move-node-to-workspace --window-id "${chrome_pip}" "${ws}"
[[ $outlook_reminder != "" ]] && aerospace move-node-to-workspace --window-id "${outlook_reminder}" "${ws}"
