#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
