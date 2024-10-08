#!/bin/zsh
CURRENT_PATH="${0:a:h}"
FUNCTIONS_PATH=${1:-$CURRENT_PATH}

fpath=( $FUNCTIONS_PATH/functions "${fpath[@]}" )

if [ ! -x "$(command -v $COMMAND)" ]; then
	fpath=( "$(brew --repository)/share/zsh/site-functions" "${fpath[@]}" )
fi

for fp ($^fpath/*(.N,@)) autoload -Uz $fp

autoload -U compinit && compinit

if [[ -x "$(command -v zoxide)" ]] then
  eval "$(zoxide init zsh)"
fi

if [[ -x "$(command -v fzf)" ]] then
  source <(fzf --zsh)
fi
