# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

# VARS
# IMPORTANT! Order matters
MY_INITIAL_CONFIGURATION=$ZDOTDIR/env/autoload_functions.sh
MY_ZTYLES_PATH=($ZDOTDIR/zstyles/*)
MY_ENV_PATH=($ZDOTDIR/env/config/*)

source $MY_INITIAL_CONFIGURATION

SOURCE_PATHS=(
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  )

for f ($^SOURCE_PATHS(.N)) ssource $f
unset SOURCE_PATHS

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof

# vim:ft=zsh
