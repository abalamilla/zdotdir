# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

# VARS
MY_FUNCTIONS_PATH=$ZDOTDIR/env/functions
AUTOLOAD_FUNCTIONS=$ZDOTDIR/env/autoload_functions.sh
MY_PROMTP_PATH=$ZDOTDIR/zstyles/custom_prompt
ZSH_OPTIONS=$ZDOTDIR/env/options

set -e
[[ -f $AUTOLOAD_FUNCTIONS ]] && source $AUTOLOAD_FUNCTIONS || { echo "$AUTOLOAD_FUNCTIONS not found."; return 127; }
set +e

SOURCE_PATHS=(
  $MY_PROMTP_PATH     # custom prompt
  $ZSH_OPTIONS        # zsh options
  )

for f ($^SOURCE_PATHS(.N)) ssource $f
unset SOURCE_PATHS

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof
