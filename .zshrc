# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:- 0}" == 1 ]] && zmodload zsh/zprof


# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:- 0}" == 1 ]] && zprof
