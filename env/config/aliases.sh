#!/bin/zsh
# Bash
if [[ "Darwin" == `uname` ]] ; then
    alias ls='ls -FG'
else
    alias ls='ls -F --color=auto'
fi

alias la='eza -lahl --icons --git -s=type'
alias lagi='eza -lahl --git --git-ignore --icons -s=type'

alias search='grep --color=auto --exclude-dir=node_modules'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Handy commands
alias timestamp='date +%s'
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'

# IMPORTANT: if you are using oh-my-zsh do not source .zshrc
# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
# best options are restart terminal, `exec zsh` or omz reload
alias zshreload=". ${ZDOTDIR:-HOME}/.zshrc"

# git alias
alias gst='git status'
alias ga='git add'
alias gp='git push'
alias gl='git pull'
alias gcsm='git commit --signoff -m'
alias gcssm='git commit -S --signoff -m'
alias gco='git checkout'
alias gnb='git checkout -b'
alias gpsu='git push --set-upstream'
alias gd='git difftool --no-prompt'
alias gun='git restore --staged'
alias grst='git restore'
alias gf='git fetch --all'
alias gclean='git clean -f -d -x'
alias glog='git log --stat'

# GitHub CLI alias
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'

# zdotdir
alias zdotdir='cd ${ZDOTDIR:-HOME}'

# tmux
alias tmux='tmux -f $ZDOTDIR/tmux.conf'
alias cs=clear
