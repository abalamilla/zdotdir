#!/bin/zsh

fpath=( $MY_FUNCTIONS_PATH "${fpath[@]}" )
autoload -Uz $fpath[1]/*(.:t)

