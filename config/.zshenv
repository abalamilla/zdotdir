# TODO: what is this?
# . "/Users/abralami/.wasmedge/env"

# VARS
export MY_CONFIG_PATH=$HOME/zdotdir
export MY_INITIAL_CONFIGURATION=$MY_CONFIG_PATH/env/autoload_functions.sh
export MY_ZTYLES_PATH=($MY_CONFIG_PATH/zstyles/*)
export MY_ENV_PATH=($MY_CONFIG_PATH/env/config/*)
export ZSH_THEME=$MY_CONFIG_PATH/themes/powerlevel10k/powerlevel10k.zsh-theme

# office profile - not under version control
OFFICE_PROFILE=$MY_CONFIG_PATH/office_profile

export EDITOR=nvim

export ZDOTFILES_DEBUG=0

# set docker buildkit as default
export DOCKER_BUILDKIT=1

# asdf config
export ASDF_CONFIG_FILE=$MY_CONFIG_PATH/.asdfrc

# lazygit
export LG_CONFIG_FILE=$HOME/.config/lazygit/config.yml

