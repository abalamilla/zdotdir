#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups

PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/.local/bin:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
