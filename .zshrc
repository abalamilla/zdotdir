# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

# VARS
MY_PROMTP_PATH=$ZDOTDIR/zstyles/custom_prompt

# loading prompt
[[ -f $MY_PROMTP_PATH ]] && source $MY_PROMTP_PATH || echo "$MY_PROMTP_PATH not found. Skipping file load."

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof
