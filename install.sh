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

	return "$RESOURCE_NAME_-$DATE.bkp"
}

backup_and_set_zdotdir() {
	echo Backing up ~/.zshenv into $MY_ZDOTDIR/backups
	[[ ! -d $MY_ZDOTDIR/backups ]] mkdir $MY_ZDOTDIR/backups || echo Skiping backup directory creation 
	BACKUP_NAME=$(get_backup_name zshenv)
	cp ~/.zshenv $BACKUP_NAME

	sed -i -E 's/ZDOTDIR=.*//g'

	set_zdotdir
}

# init
() {
	[[ -z "${ZDOTDIR}" || $ZDOTDIR != $MY_ZDOTDIR ]] && backup_and_set_zdotdir || echo ZDOTDIR is already configured.
	git clone https://github.com/abalamilla/zdotdir.git $MY_ZDOTDIR
}
