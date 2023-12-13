#!/usr/bin/env zsh

CONFIG_DIR=~/.config
MY_ZDOTDIR=$CONFIG_DIR/zdotdir
ZDOTDIR_PLUGINS="$MY_ZDOTDIR/plugins"
VIM_PLUGIN_PATH=$HOME/.vim/pack/plugins/start
UTILS_PATH=$MY_ZDOTDIR/utils
BACKUPS_PATH=$MY_ZDOTDIR/backups
ZDOTDIR_THEMES=$MY_ZDOTDIR/themes

backup_file() {
	# backup a file
	FILE_TO_BACKUP=$1
	DEST_PATH=$2
	NEW_FILE_NAME=${3:-FILE_TO_BACKUP}
	FINAL_FILE="$DEST_PATH/$NEW_FILE_NAME"

	usage() {
		cat <<HELP_USAGE
		Backup a file to a destination path

		backup_file file_path destination_path [new_file_name]
HELP_USAGE
	}

	[[ -z $FILE_TO_BACKUP || -z $DEST_PATH ]] && { usage; return 1; }
	[[ ! -f $FILE_TO_BACKUP ]] && { print_message "The file $FILE_TO_BACKUP do not exists." 1; return 1; }
	[[ ! -w $DEST_PATH ]] && { print_message "Current user do not have write permissions over $DEST_PATH."; return 1; }

	print_message "Creating directory..." -1
	[[ -d $DEST_PATH ]] && mkdir -p $DEST_PATH || print_message "Directory already exists." -2

	print_message "Copying file..." -1
	cp $FILE_TO_BACKUP $FINAL_FILE
	print_message "File copied: $FILE_TO_BACKUP -> $FINAL_FILE"
}

set_zdotdir() {
	# update zdotdir in zshenv
	MY_ZDOTDIR=$1
	FILE_PATH=${2:-$HOME/.zshenv}

	usage() {
	  cat << HELP_USAGE
	  Updates ZDOTDIR environment variable from .zshenv

	  set_zdotdir /path/to/custom/zdotdir [/path/to/.zshenv default: $HOME/.zshenv]
HELP_USAGE
	}

	[[ -z $MY_ZDOTDIR ]] && { usage; return 1; }

	# cleaning
	sed -i -E 's/ZDOTDIR=.*//g' $FILE_PATH

	# setting new value
	echo ZDOTDIR=$MY_ZDOTDIR >> $FILE_PATH
}

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
	GIT_OPTIONS=$3
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

backup_and_set_zdotdir() {
	BACKUP_NAME="$(backup_name "zshenv")"
	backup_file ~/.zshenv $BACKUPS_PATH $BACKUP_NAME

	set_zdotdir "$MY_ZDOTDIR"
}

clone_repos() {
	print_message "Cloning plugins and themes" -1
	REPOS_TO_CLONE=(
		"abalamilla/zdotdir":$CONFIG_DIR
		
		# zsh plugins
		"Aloxaf/fzf-tab":$ZDOTDIR_PLUGINS
		"zsh-users/zsh-autosuggestions":$ZDOTDIR_PLUGINS
		"zsh-users/zsh-history-substring-search":$ZDOTDIR_PLUGINS
		"zsh-users/zsh-completions":$ZDOTDIR_PLUGINS
		"lukechilds/zsh-nvm":$ZDOTDIR_PLUGINS
		"zsh-users/zsh-syntax-highlighting":$ZDOTDIR_PLUGINS

		# vim plugins
		"sheerun/vim-polyglot":$VIM_PLUGIN_PATH
		"junegunn/fzf":$VIM_PLUGIN_PATH
		"junegunn/fzf.vim":$VIM_PLUGIN_PATH
		"eslint/eslint":$VIM_PLUGIN_PATH
		"prettier/vim-prettier":$VIM_PLUGIN_PATH
		"ludovicchabant/vim-gutentags":$VIM_PLUGIN_PATH
		"vim-autoformat/vim-autoformat":$VIM_PLUGIN_PATH
		"junegunn/vader.vim":$VIM_PLUGIN_PATH
		"JuliaEditorSupport/julia-vim":$VIM_PLUGIN_PATH
		"vim-airline/vim-airline":$VIM_PLUGIN_PATH
		"github/copilot.vim":$VIM_PLUGIN_PATH
		"tpope/vim-fugitive":$VIM_PLUGIN_PATH

		# themes
		"romkatv/powerlevel10k":$ZDOTDIR_THEMES:"--depth=1"
	)

	for r in $REPOS_TO_CLONE; do
		CURRENT_REPO=(${(s(:))r})
		clone_repo $CURRENT_REPO[1] $CURRENT_REPO[2] $CURRENT_REPO[3]
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
		"https://get.sdkman.io"::"sdk"
		"https://nixos.org/nix/install"::"nix-shell"
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

install_others() {
	install_lisp lisp
	link_file $MY_ZDOTDIR/gitconfig $HOME/.gitconfig

	HAMMERSPOON_PATH=$HOME/.hammerspoon
	[[ ! -d $HAMMERSPOON_PATH ]] && mkdir -p $HAMMERSPOON_PATH || print_message "Directory $HAMMERSPOON_PATH already exists." -2
	link_file $MY_ZDOTDIR/tools/hammerspoon/init.lua $HAMMERSPOON_PATH/init.lua
}

# init
() {
	#source $UTILS_PATH/colors.sh
	#source env/autoload_functions.sh $UTILS_PATH

	clone_repos
	install_homebrew
	load_homebrew
	install_brewfile
	install_apps
	install_others

	print_message "Installing zdotdir environment..." -1
	[[ -z "${ZDOTDIR}" || $ZDOTDIR != $MY_ZDOTDIR ]] && backup_and_set_zdotdir || print_message "ZDOTDIR is already configured." -2

	print_message "Finish! Enjoy your new environment."
}
