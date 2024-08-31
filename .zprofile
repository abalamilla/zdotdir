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
export ZDOTDIR=$ZDOTDIR # reexporting to make it available in nvim
export MY_INITIAL_CONFIGURATION=$ZDOTDIR/env/autoload_functions.sh
export MY_ZTYLES_PATH=($ZDOTDIR/zstyles/*)
export MY_ENV_PATH=($ZDOTDIR/env/config/*)
export ZSH_THEME=$ZDOTDIR/themes/powerlevel10k/powerlevel10k.zsh-theme
export HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
export AUTOJUMP_SH="$(brew --repository)/etc/autojump.sh"
export AUTOJUMP_SH_x86="/usr/local/etc/profile.d/autojump.sh"
export NIX_DAEMON_PATH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
export ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
export ASDF_SET_JAVA_HOME="$HOME/.asdf/plugins/java/set-java-home.zsh"

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
  $NIX_DAEMON_PATH
  $OFFICE_PROFILE
  $ASDF_SH
  $ASDF_SET_JAVA_HOME
)

# move .vimrc
export MYVIMRC=$ZDOTDIR/.vimrc
export VIMINIT="source $MYVIMRC"

export EDITOR=nvim

export ZDOTFILES_DEBUG=0

# set docker buildkit as default
export DOCKER_BUILDKIT=1

# asdf config
export ASDF_CONFIG_FILE=$ZDOTDIR/.asdfrc

# lazygit
export LG_CONFIG_FILE=$ZDOTDIR/lazygit/config.yml

# yazi
export YAZI_CONFIG_HOME=$ZDOTDIR/tools/yazi
