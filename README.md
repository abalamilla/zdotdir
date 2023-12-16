# Zsh configuration - zdotdir

## Introduction

This is my personalized configuration settings, themes, plugins and other customizations for Zsh shell.

## Installing

To install just run the following command:
```zsh
curl -s https://raw.githubusercontent.com/abalamilla/zdotdir/main/install.sh | zsh
```

The installation process will:
- Clone this repo into `$HOME/.config/zdotdir`
- Clone these [Zsh Plugins](#zsh-plugins)
- Clone these [Vim Plugins](#vim-plugins)
- Clone [Powerlevel10k](#powerlevel10k)

## Zsh Plugins

These are my plugins selection to customize Zsh shell

### fzf-tab

This plugin shows you a completion list on tab press, the list shows commands, directories, environment variables and more, depending on the context, it uses fzf to show an interactive list.

You can find more in [fzf-tab](https://github.com/Aloxaf/fzf-tab) repo.

### zsh-autosuggestions

Completion tool that suggest commands based on your history.

You can find more in [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#configuration) repo.

### zsh-history-substring-search

Search for a substring into history to execute it again

You can find more in [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) repo.

### zsh-completions

By default Zsh already have some completions, but for those that are still missing `zsh-completions` is the choosen one

You can find more in [zsh-completions](https://github.com/zsh-users/zsh-completions) repo.

### zsh-nvm

Nvm manager: installs, updates and loads nvm.

You can find more in [zsh-nvm](https://github.com/lukechilds/zsh-nvm) repo.

### zsh-syntax-highlighting

Highlights commands whilst they are typed, helpful to identify if the current command syntax is well formed before running

You can find more in [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) repo.

