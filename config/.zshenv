# TODO: what is this?
# . "/Users/abralami/.wasmedge/env"

export XDG_RUNTIME_DIR="/tmp/"

# VARS
export MY_CONFIG_PATH=$HOME/zdotdir
export MY_INITIAL_CONFIGURATION=$MY_CONFIG_PATH/env/autoload_functions.sh
export MY_ZTYLES_PATH=($MY_CONFIG_PATH/zstyles/*)
export MY_ENV_PATH=($MY_CONFIG_PATH/env/config/*)

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

# zoxide
export _ZO_ECHO=1

# gpg: signing failed: Inappropriate ioctl for device
# https://github.com/keybase/keybase-issues/issues/2798
export GPG_TTY=$(tty)

# custom k9s config path
export K9S_CONFIG_DIR=$HOME/.config/k9s
