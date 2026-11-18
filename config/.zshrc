# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

source $MY_INITIAL_CONFIGURATION

# Defined here, not in .zprofile, so non-login interactive shells (kitty launchers,
# `zsh -ic`) source the same files as login shells.
(( $+commands[brew] )) && export HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"

# IMPORTANT! Order matters
SOURCE_PATHS=(
  $HB_CNF_HANDLER
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $OFFICE_PROFILE
)

# zsh glob expansion
# . only files
# N sets the NULL_GLOB option for the current pattern
# https://zsh.sourceforge.io/Doc/Release/Expansion.html
# ------👇🏼----------👇🏼----
for f ($^SOURCE_PATHS(.N,@)) ssource $f
unset SOURCE_PATHS

eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/ab.omp.toml)"

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof

# vim:ft=zsh

