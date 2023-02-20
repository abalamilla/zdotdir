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

# loading prompt
[[ -f $MY_PROMTP_PATH ]] && source $MY_PROMTP_PATH || echo "$MY_PROMTP_PATH not found. Skipping file load."

# setting up zsh options
[[ -f $ZSH_OPTIONS ]] && source $ZSH_OPTIONS || echo "$ZSH_OPTIONS not found. Skipping file load."

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof
