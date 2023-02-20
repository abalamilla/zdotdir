#!/bin/zsh
CURRENT_PATH="${0:a:h}"
FUNCTIONS_PATH=${1:-$CURRENT_PATH}

fpath=( $FUNCTIONS_PATH/functions "${fpath[@]}" )
autoload -Uz $fpath[1]/*(.:t)

autoload -U compinit && compinit
