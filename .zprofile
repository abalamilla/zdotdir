eval "$(/opt/homebrew/bin/brew shellenv)"

# VARS
export MY_INITIAL_CONFIGURATION=$ZDOTDIR/env/autoload_functions.sh
export MY_ZTYLES_PATH=($ZDOTDIR/zstyles/*)
export MY_ENV_PATH=($ZDOTDIR/env/config/*)
export ZSH_THEME=$ZDOTDIR/themes/powerlevel10k/powerlevel10k.zsh-theme
export HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
export AUTOJUMP_SH="$(brew --repository)/etc/autojump.sh"
export SDKMAN_PATH="$HOME/.sdkman/bin/sdkman-init.sh"
export NIX_DAEMON_PATH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"


# IMPORTANT! Order matters
SOURCE_PATHS=(
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $ZSH_THEME
  $HB_CNF_HANDLER
  $AUTOJUMP_SH
  $SDKMAN_PATH
  $NIX_DAEMON_PATH
)

# move .vimrc
export MYVIMRC=$ZDOTDIR/.vimrc
export VIMINIT="source $MYVIMRC"

