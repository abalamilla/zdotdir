if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        # macos sillicon
        eval $(/opt/homebrew/bin/brew shellenv)
    else
        # macos intel
        eval $(/usr/local/bin/brew shellenv)
    fi
else
    # linux
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

export HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
export ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
export ASDF_SET_JAVA_HOME="$HOME/.asdf/plugins/java/set-java-home.zsh"

# IMPORTANT! Order matters
SOURCE_PATHS=(
  $HB_CNF_HANDLER
  $ASDF_SH
  $ASDF_SET_JAVA_HOME
  $MY_ZTYLES_PATH         # zsh options
  $MY_ENV_PATH            # environment path
  $OFFICE_PROFILE
)

