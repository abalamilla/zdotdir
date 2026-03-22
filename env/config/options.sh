#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups

# PATH priority: custom tools > system > lower-priority tools
_ORIGINAL_PATH="$PATH"
PATH="/usr/local/bin"                                               # Custom system tools (highest priority)
PATH="$PATH:/opt/homebrew/opt/curl/bin"                            # Homebrew
PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"                         # Krew (Kubernetes)
PATH="$PATH:$HOME/.local/bin"                                      # Local bin
PATH="$PATH:$HOME/Applications/IntelliJ IDEA.app/Contents/MacOS"  # IntelliJ
PATH="$PATH:$_ORIGINAL_PATH"                                       # System PATH (in middle priority)
PATH="$PATH:$HOME/.local/share/nvim/mason/bin"                    # Mason (lowest priority)
unset _ORIGINAL_PATH

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

if [[ -x "$(command -v mise)" ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
  source <(~/.local/bin/mise completion zsh)
fi
