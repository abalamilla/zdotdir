# Zsh configuration - zdotdir

## Introduction

This is my personalized configuration settings, themes, plugins and other customizations for Zsh shell.

## Installing

To install just run the following command:

```zsh
curl -s https://raw.githubusercontent.com/abalamilla/zdotdir/main/install.sh | zsh
```

The installation process will:

-   Clone this repo into `$HOME/.config/zdotdir`
-   Clone these [Zsh Plugins](#zsh-plugins)
-   Clone these [Vim Plugins](#vim-plugins)
-   Clone [Powerlevel10k](#powerlevel10k)

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

## Vim Plugins

### vim-polyglot

Syntax highlighter for extra file types that are not included within vim itself

You can find more in [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot) repo.

### fzf

Wrapper for fzf that is an utility for interactive searches, it offers a fast processing speed, approximate searches, file content preview, and much more

You can find more in [fzf](https://github.com/junegunn/fzf) repo.

### fzf.vim

fzf vim plugin with multiple predefined commands and mappings like:

-   `:GFiles` to filter files inside a git repository
-   `:Files` to search accross any path in the filesystem
-   `:Buffers` to search in current buffer list

You can find more in [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) repo.

### vim-prettier

Prettier plugin to format javascript, typescript, less, scss, css, json, graphql and markdown files

You can find more in [prettier/vim-prettier](https://github.com/prettier/vim-prettier) repo.

### vim-gutentags

This plugin manage tags files for vim, useful to navigate code within vim

You can find more in [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags) repo.

### vim-autoformat

Formats code manually or automatically on save

You can find more in [vim-autoformat/vim-autoformat](https://github.com/vim-autoformat/vim-autoformat) repo.

### vader.vim

Run VimScript tests

You can find more in [junegunn/vader.vim](https://github.com/junegunn/vader.vim) repo.

### julia-vim

Julia support for Vim

You can find more in [JuliaEditorSupport/julia-vim](https://github.com/JuliaEditorSupport/julia-vim) repo.

### vim-airline

Status tabline for Vim

You can find more in [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline) repo.

### vim-airline-themes

Vim airline themes

You can find more in [vim-airline/vim-airline-themes](https://github.com/vim-airline/vim-airline-themes) repo.

### copilot.vim

GitHub Copilot vim integration

You can find more in [github/copilot.vim](https://github.com/github/copilot.vim) repo.

### vim-fugitive

Git Vim integration, allows you to run Git commands within Vim

You can find more in [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) repo.

### markdown-preview.nvim

Live preview Markdown changes in your web explorer

You can find more in [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) repo.

## Zsh themes

### powerlevel10k

Zsh theme lightweight, fast and flexible

You can find more in [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) repo.


