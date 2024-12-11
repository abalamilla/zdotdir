#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups

PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
