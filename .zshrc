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

source $MY_INITIAL_CONFIGURATION

SOURCE_PATHS=(
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $ZSH_THEME
  $HB_CNF_HANDLER
  )

for f ($^SOURCE_PATHS(.N)) ssource $f
unset SOURCE_PATHS

# zsh profiling disabled
[[ "${ZDOTFILES_DEBUG:-0}" == 0 ]] || zprof

# To customize prompt, run `p10k configure` or edit ~/.config/zdotdir/.p10k.zsh.
[[ ! -f ~/.config/zdotdir/.p10k.zsh ]] || source ~/.config/zdotdir/.p10k.zsh


# vim:ft=zsh
