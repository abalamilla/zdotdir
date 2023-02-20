#!/bin/zsh
CONFIG_DIR=~/.config
MY_ZDOTDIR=$CONFIG_DIR/zdotdir
ZDOTDIR_PLUGINS="$MY_ZDOTDIR/plugins"
VIM_PLUGIN_PATH=$HOME/.vim/pack/plugins/start

# Setting up ZDOTDIR
set_zdotdir() {
	echo ZDOTDIR=$MY_ZDOTDIR >> ~/.zshenv
}

get_backup_name() {
	RESOURCE_NAME=$2
	DATE=$(date +%F-%H_%M_%S)

	echo "$RESOURCE_NAME_-$DATE.bkp"
}

backup_and_set_zdotdir() {
	echo Backing up ~/.zshenv into $MY_ZDOTDIR/backups
	[[ ! -d $MY_ZDOTDIR/backups ]] && mkdir $MY_ZDOTDIR/backups || echo Skiping backup directory creation 
	BACKUP_NAME=$(get_backup_name zshenv)
	cp ~/.zshenv $BACKUP_NAME

	sed -i -E 's/ZDOTDIR=.*//g'

	set_zdotdir
}

get_project_name() {
	FROM_PATH=$1

	awk -F '/' '{print $NF}' <<< $FROM_PATH
}

clone_repo() {
	GIT_REPO_PATH=$1
    DEST_PATH=$2
	PROJECT_NAME="$(get_project_name $GIT_REPO_PATH)"
	FINAL_DEST_PATH="$2/$PROJECT_NAME"
    GITHUB_URL="https://github.com"

	echo Verifying local path: $FINAL_DEST_PATH
    if [ ! -d $FINAL_DEST_PATH ]; then
        echo "Cloning repository..."
        git clone $GITHUB_URL/$GIT_REPO_PATH $FINAL_DEST_PATH
    else
        echo "Updating repository..."
        git -C $FINAL_DEST_PATH pull
    fi
    echo "Installed on: $FINAL_DEST_PATH"
}

# init
() {
	REPOS_TO_CLONE=(
		"abalamilla/zdotdir":$CONFIG_DIR
		
		# zsh plugins
		"Aloxaf/fzf-tab":$ZDOTDIR_PLUGINS
		"Freed-Wu/fzf-tab-source":$ZDOTDIR_PLUGINS
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
	)

	typeset -T r CURRENT_REPO
	for r in $REPOS_TO_CLONE; do
		typeset -p r
		clone_repo $CURRENT_REPO[1] $CURRENT_REPO[2]
	done

	[[ -z "${ZDOTDIR}" || $ZDOTDIR != $MY_ZDOTDIR ]] && backup_and_set_zdotdir || echo ZDOTDIR is already configured.
}
