#!/bin/zsh

() {
    PLUGIN_PATHS=($HOME/zdotdir/plugins/*)

    for p in $PLUGIN_PATHS; do 
        DIR_NAME="$(awk -F '/' '{print $NF}' <<< $p)"
        FILE0="$p/$DIR_NAME.plugin.zsh"
        FILE1="$p/$DIR_NAME.zsh"

        [[ -f $FILE0 ]] && ssource $FILE0 || ssource $FILE1
    done
}
