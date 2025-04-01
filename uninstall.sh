#!/usr/bin/env bash

# remove python venv
echo "Removing python venv"
rm -rf ./.venv

# remove asdf packages and plugins
echo "Removing asdf packages and plugins"
rm -rf ~/.asdf

# unstow dotfiles
echo "Unstowing dotfiles"
stow -D config

# uninstall brew packages
echo "Removing brew packages"
brew remove --force "$(brew list --formula)"
brew remove --force "$(brew list)"

# remove nvim folders
echo "Removing nvim files"
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# remove zsh plugins
echo "Removing zsh plugins"
rm -rf ./plugins

# remove zsh theme
echo "Removing zsh themes"
rm -rf ./themes

echo "Uninstall completed"
echo "Reload environment"
