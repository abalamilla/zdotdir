#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups

PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/.local/bin:$HOME/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

if [[ -x "$(command -v zoxide)" ]] then
  eval "$(zoxide init zsh)"
fi

if [[ -x "$(command -v fzf)" ]] then
  source <(fzf --zsh)
fi

eval $(thefuck --alias)
