# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zdotdir/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

# VARS
# IMPORTANT! Order matters
MY_INITIAL_CONFIGURATION=$ZDOTDIR/env/autoload_functions.sh
MY_ZTYLES_PATH=($ZDOTDIR/zstyles/*)
MY_ENV_PATH=($ZDOTDIR/env/config/*)
ZSH_THEME=$ZDOTDIR/themes/powerlevel10k/powerlevel10k.zsh-theme
HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
AUTOJUMP_SH="$(brew --repository)/etc/autojump.sh"
SDKMAN_PATH="$HOME/.sdkman/bin/sdkman-init.sh"
NIX_DAEMON_PATH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

source $MY_INITIAL_CONFIGURATION

SOURCE_PATHS=(
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $ZSH_THEME
  $HB_CNF_HANDLER
  $AUTOJUMP_SH
  $SDKMAN_PATH
  $NIX_DAEMON_PATH
)

# zsh glob expansion
# . only files
# N sets the NULL_GLOB option for the current pattern
# @ symlinks (required for autojump)
# https://zsh.sourceforge.io/Doc/Release/Expansion.html
# ------👇🏼----------👇🏼----
for f ($^SOURCE_PATHS(.N,@)) ssource $f
unset SOURCE_PATHS

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof

# To customize prompt, run `p10k configure` or edit ~/.config/zdotdir/.p10k.zsh.
[[ ! -f ~/.config/zdotdir/.p10k.zsh ]] || source ~/.config/zdotdir/.p10k.zsh


# vim:ft=zsh
