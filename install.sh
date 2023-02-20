#!/bin/zsh
CONFIG_DIR=~/.config
MY_ZDOTDIR=$CONFIG_DIR/zdotdir

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
	clone_repo abalamilla/zdotdir $CONFIG_DIR
	[[ -z "${ZDOTDIR}" || $ZDOTDIR != $MY_ZDOTDIR ]] && backup_and_set_zdotdir || echo ZDOTDIR is already configured.
}
