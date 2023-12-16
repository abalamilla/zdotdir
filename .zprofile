if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        # macos sillicon
        eval $(/opt/homebrew/bin/brew shellenv)
    else
        # macos intel
        eval $(/usr/local/bin/brew shellenv)
    fi
else
    # linux
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# VARS
export MY_INITIAL_CONFIGURATION=$ZDOTDIR/env/autoload_functions.sh
export MY_ZTYLES_PATH=($ZDOTDIR/zstyles/*)
export MY_ENV_PATH=($ZDOTDIR/env/config/*)
export ZSH_THEME=$ZDOTDIR/themes/powerlevel10k/powerlevel10k.zsh-theme
export HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
export AUTOJUMP_SH="$(brew --repository)/etc/autojump.sh"
export AUTOJUMP_SH_x86="/usr/local/etc/profile.d/autojump.sh"
export SDKMAN_PATH="$HOME/.sdkman/bin/sdkman-init.sh"
export NIX_DAEMON_PATH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# office profile - not under version control
OFFICE_PROFILE=$ZDOTDIR/office_profile

# IMPORTANT! Order matters
SOURCE_PATHS=(
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $ZSH_THEME
  $HB_CNF_HANDLER
  $AUTOJUMP_SH
  $AUTOJUMP_SH_x86
  $SDKMAN_PATH
  $NIX_DAEMON_PATH
  $OFFICE_PROFILE
)

# move .vimrc
export MYVIMRC=$ZDOTDIR/.vimrc
export VIMINIT="source $MYVIMRC"

export EDITOR=vim

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export ZDOTFILES_DEBUG=0
