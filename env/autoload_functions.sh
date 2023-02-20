#!/bin/zsh

fpath=( ${0:a:h}/functions "${fpath[@]}" )
autoload -Uz $fpath[1]/*(.:t)

autoload -U compinit && compinit
