#!/usr/bin/env zsh

set -e

BRANCH_NAME=${1:-main}

MY_ZDOTDIR=$HOME/zdotdir
ZDOTDIR_PLUGINS="$MY_ZDOTDIR/plugins"
UTILS_PATH=$MY_ZDOTDIR/utils
ZDOTDIR_THEMES=$MY_ZDOTDIR/themes

print_message() {
	# prints a message
	MESSAGE=$1
	CMD_STATUS=${2:-0}

	case $CMD_STATUS in
		-2) echo "${Purple} Skipping: ${Color_Off} $MESSAGE";;
		-1) echo "${Cyan} Processing: ${Color_Off} $MESSAGE";;
		0) echo "${Green}${CHECK_MARK} Success: ${Color_Off} $MESSAGE";;
		*) echo "${Red}${CROSS_MARK} Error: ${Color_Off} $MESSAGE";;
	esac
}

clone_repo() {
	# clone a github repository
	GIT_REPO_PATH=$1
	DEST_PATH=$2
	GIT_OPTIONS=${3:-""}
	PROJECT_NAME="$(basename $GIT_REPO_PATH)"
	FINAL_DEST_PATH="$DEST_PATH/$PROJECT_NAME"
	GITHUB_URL="https://github.com"

	print_message "Verifying local path: $FINAL_DEST_PATH" -1
	if [ ! -d $FINAL_DEST_PATH ]; then
		print_message "Cloning repository..." -1
		git clone $GIT_OPTIONS $GITHUB_URL/$GIT_REPO_PATH $FINAL_DEST_PATH
	else
		print_message "Updating repository..." -1
		git -C $FINAL_DEST_PATH pull
	fi

	print_message "Installed on: $FINAL_DEST_PATH" $?
}

install_sh() {
	# gets and execute an installer from sh file
	SH_URL=$1
	COMMAND=$2

	print_message "Attempting to install $COMMAND" -1
	print_message "$(type -w $COMMAND)" -1

	if [ "$(type -w $COMMAND)" = "$COMMAND: none" ]; then
		/bin/bash -c "$(curl -fsSL $SH_URL)"
	else
		print_message "$COMMAND is already installed" -2
	fi

	print_message "Finished processing $COMMAND installation" $?
}

load_scripts() {
	cd $MY_ZDOTDIR
	git checkout $BRANCH_NAME

	print_message "Loading scripts" -1
	source $UTILS_PATH/colors.sh
	source env/autoload_functions.sh $UTILS_PATH
	print_message "Scripts loaded" $?
}

clone_repos() {
	print_message "Cloning plugins and themes" -1

	local INDEX=1
	typeset -a REPOS_TO_CLONE

	REPOS_TO_CLONE=(
		# zsh plugins
		[((INDEX++))]=(["repo"]="Aloxaf/fzf-tab" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-autosuggestions" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-history-substring-search" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-completions" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-syntax-highlighting" ["dest"]=$ZDOTDIR_PLUGINS)

		# themes
		[((INDEX++))]=(["repo"]="romkatv/powerlevel10k" ["dest"]=$ZDOTDIR_THEMES ["options"]="--depth=1")
	)

	typeset -A CURRENT_REPO

	for CURRENT_VALUE in $REPOS_TO_CLONE; do
		eval "CURRENT_REPO=$CURRENT_VALUE"

		GIT_URL=$CURRENT_REPO[repo]
		DEST_PATH=$CURRENT_REPO[dest]
		GIT_OPTIONS=$CURRENT_REPO[options]
		CALLBACK=$CURRENT_REPO[callback]

		clone_repo $GIT_URL $DEST_PATH $GIT_OPTIONS

		[[ "$(type -w $CALLBACK)" = "$CALLBACK: function" ]] && $CALLBACK
	done

	print_message "Finished cloning plugins and themes"
}

install_homebrew() {
	# install homebrew
	print_message "Installing homebrew" -1
	NONINTERACTIVE=1 install_sh "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" "brew"
	print_message "Homebrew installed" $?
}

load_homebrew() {
	print_message "Loading homebrew" -1
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
}

install_apps() {
	APPS=(
		# "https://nixos.org/nix/install"::"nix-shell"
	)

	for a in $APPS; do
		CURRENT_APP=(${(s(::))a})
		install_sh $CURRENT_APP[1] $CURRENT_APP[2]
	done
}

install_brewfile() {
	print_message "Installing Brewfile" -1

	brew update
	brew upgrade

	# install brewfile dependencies
	brew bundle install --file=$MY_ZDOTDIR/Brewfile

	print_message "Installing Brewfile finished" $?
}

install_lisp() {
	COMMAND=$1

	if [[ ! -f ~/.quicklisp/setup.lisp ]]; then
		curl -o /tmp/ql.lisp http://beta.quicklisp.org/quicklisp.lisp
		sbcl --no-sysinit --no-userinit --load /tmp/ql.lisp \
		   --eval '(quicklisp-quickstart:install :path "~/.quicklisp")' \
		   --eval '(ql:add-to-init-file)' \
		   --quit
	else
		print_message "$COMMAND is already installed" -2
	fi
}

link_file() {
	SOURCE_FILE=$1
	DEST_PATH=$2

	print_message "Linking $SOURCE_FILE file to $DEST_PATH" -1
	if [[ ! -f $DEST_PATH ]]; then
		ln -s $SOURCE_FILE $DEST_PATH
	else
		print_message "File $DEST_PATH already linked" -2
	fi
	print_message "File $DEST_PATH linked" $?
}

configure_docker_buildx() {
	print_message "Configuring docker buildx" -1
	mkdir -p ~/.docker/cli-plugins
	link_file /usr/local/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
	print_message "Finished configuring docker buildx" $?
}

install_others() {
	install_lisp lisp

	# symlink docker buildx
	configure_docker_buildx

	# create python venv
	if [[ ! -d $MY_ZDOTDIR/.venv ]]; then
		print_message "Creating python venv" -1
		python -m venv $MY_ZDOTDIR/.venv
		source $MY_ZDOTDIR/.venv/bin/activate
		pip install -r $MY_ZDOTDIR/requirements.txt
		print_message "Python venv created" $?
	else
		print_message "Python venv already exists" -2
	fi
}

config_asdf() {
	print_message "Configuring asdf" -1

  asdf plugin add aws-sam-cli
  asdf plugin add bun
  asdf plugin add clj-kondo
  asdf plugin add cljstyle
  asdf plugin add coursier
  asdf plugin add dotnet
  asdf plugin add golang
  asdf plugin add gradle
  asdf plugin add java
  asdf plugin add kubebuilder
  asdf plugin add maven
  asdf plugin add nodejs
  asdf plugin add python
  asdf plugin add rust
  asdf plugin add scala
  asdf plugin add shfmt
  asdf plugin add terraform

	# install tools
	asdf install

	# load asdf
	source "$(brew --prefix asdf)/libexec/asdf.sh"

	print_message "Finished configuring asdf" $?
}

install_asdf() {
	print_message "Installing asdf" -1
	brew install asdf
	config_asdf
	print_message "Finished installing asdf" $?
}

init_config() {
	# install homebrew
	install_homebrew
	load_homebrew

	# load zdotdir scripts
	load_scripts
}

# init
() {
	print_message "Starting installation" -1

	# clone my zdotdir repository
	clone_repo abalamilla/zdotdir $HOME

	# setup initial configuration
	init_config

	# clone plugins and themes
	clone_repos

	# install brewfile
	install_brewfile

	stow config -t ~

	# install and configure asdf
	install_asdf

	install_apps
	install_others

	print_message "Finish! Enjoy your new environment."
}
