#!/bin/zsh

CONFIG_DIR=~/.config
MY_ZDOTDIR=$CONFIG_DIR/zdotdir
ZDOTDIR_PLUGINS="$MY_ZDOTDIR/plugins"
VIM_PLUGIN_PATH=$HOME/.vim/pack/plugins/start
UTILS_PATH=$MY_ZDOTDIR/utils
BACKUPS_PATH=$MY_ZDOTDIR/backups
ZDOTDIR_THEMES=$MY_ZDOTDIR/themes

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

		# themes
		"romkatv/powerlevel10k":$ZDOTDIR_THEMES:"--depth=1"
	)

	for r in $REPOS_TO_CLONE; do
		CURRENT_REPO=(${(s(:))r})
		clone_repo $CURRENT_REPO[1] $CURRENT_REPO[2] $CURRENT_REPO[3]
	done

	print_message "Finished cloning plugins and themes"
}

install_apps() {
	APPS=(
		"https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"::"brew"
		"https://get.sdkman.io"::"sdk"
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
    brew bundle install

	print_message "Installing Brewfile finished" $?
}

# init
() {
	source $UTILS_PATH/colors.sh
	source env/autoload_functions.sh $UTILS_PATH

	clone_repos
	install_apps
	install_brewfile

	print_message "Installing zdotdir environment..." -1
	[[ -z "${ZDOTDIR}" || $ZDOTDIR != $MY_ZDOTDIR ]] && backup_and_set_zdotdir || echo ZDOTDIR is already configured.

	print_message "Finish! Enjoy your new environment."
}
