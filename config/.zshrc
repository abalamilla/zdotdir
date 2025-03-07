# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

source $MY_INITIAL_CONFIGURATION

# zsh glob expansion
# . only files
# N sets the NULL_GLOB option for the current pattern
# https://zsh.sourceforge.io/Doc/Release/Expansion.html
# ------👇🏼----------👇🏼----
for f ($^SOURCE_PATHS(.N,@)) ssource $f
unset SOURCE_PATHS

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof

# vim:ft=zsh

