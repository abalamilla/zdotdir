# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zdotdir/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.config/zdotdir/.p10k.zsh.
[[ ! -f ~/.config/zdotdir/.p10k.zsh ]] || source ~/.config/zdotdir/.p10k.zsh

# begin zshrc
# zsh profiling enabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zmodload zsh/zprof

source $MY_INITIAL_CONFIGURATION

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

# vim:ft=zsh

