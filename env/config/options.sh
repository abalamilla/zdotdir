#!/bin/zsh

HISTSIZE=10000
SAVEHIST=10000

PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
