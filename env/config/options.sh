#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups

PATH="/opt/homebrew/opt/curl/bin:${KREW_ROOT:-$HOME/.krew}/bin:$HOME/.local/bin:$HOME/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

if [[ -x "$(command -v zoxide)" ]] then
  eval "$(zoxide init zsh)"
fi

if [[ -x "$(command -v fzf)" ]] then
  source <(fzf --zsh)
fi

if [[ -x "$(command -v thefuck)" ]]; then
  eval $(thefuck --alias)
fi

if [[ -x "$(command -v colima)" ]]; then
  source <(colima completion zsh)
fi

# kubectl completion zsh
if [[ -x "$(command -v kubectl)" ]]; then
  source <(kubectl completion zsh)
fi
