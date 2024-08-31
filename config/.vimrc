set number          		" turn on line numbers
set relativenumber			" line number relative to it's position
set ruler           		" turn on ruler
set is              		" turn on incremental search
set hls             		" turn on highlight search match
set scrolloff=5     		" lines to keep on top of the cursor
set incsearch       		" incremental search
set ignorecase      		" ignore case
set smartcase       		" smart case
set wildmenu        		" shows menu on tab completition
set showcmd         		" show incomplete commands
set lbr             		" line wrap
set ai              		" copies identation from current line
set si              		" smart indent
set shiftwidth=2    		" change tab width
set tabstop=2       		" tab equal 4 spaces
set backupcopy=yes  		" backup file

"set bg=dark         " set backgrouond color to dark
if ! has('nvim')
	color sorbet         " sets color schema
endif

if (&diff)
	" set wrap for vimdiff
	au VimEnter * execute 'windo set wrap'
elseif has('vim')
	let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
	if empty(glob(data_dir . '/autoload/plug.vim'))
		silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
		au VimEnter * PlugInstall --sync | source $MYVIMRC
	endif

	au BufRead,BufNewFile k setfiletype=kcl

	call plug#begin('$HOME/.vim/plugged')
	Plug 'sheerun/vim-polyglot'
	Plug 'junegunn/fzf'
	Plug 'junegunn/fzf.vim'
	Plug 'ludovicchabant/vim-gutentags'
	Plug 'vim-autoformat/vim-autoformat'
	Plug 'github/copilot.vim'
	Plug 'tpope/vim-fugitive'
	Plug 'jparise/vim-graphql'
	Plug 'voldikss/vim-floaterm'

	if has('nvim')
		Plug 'nvim-tree/nvim-web-devicons'
		Plug 'nvim-tree/nvim-tree.lua'
		Plug 'lewis6991/gitsigns.nvim'
		Plug 'kcl-lang/vim-kcl', { 'for': 'kcl'}
		Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
		Plug 'aserowy/tmux.nvim'
		Plug 'nvim-lua/plenary.nvim'
		Plug 'nvim-telescope/telescope.nvim'
		Plug 'freddiehaddad/feline.nvim'
	else
		Plug 'sillybun/vim-repl'
		Plug 'preservim/nerdtree'
		Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
	endif
	call plug#end()

	" vim-repl
	let g:repl_program = {
				\ 'julia': ['julia'],
				\ 'default': ['zsh'],
				\ 'lua': 'lua',
				\ 'clojure': 'lein repl',
				\ 'crystal': 'crystal i',
				\ 'scala': 'scala',
				\ }
	let g:repl_exit_commands = {
				\ 'julia': 'exit()',
				\ 'scala': ':q',
				\ }
	let g:repl_output_copy_to_register = "t"
	nnoremap <leader>r :REPLToggle<CR>

	" julia-vim
	let g:latex_to_unicode_auto = 1

	" copilot maps
	imap <C-L> <Plug>(copilot-accept-word)

	if has('nvim')
		lua require 'nvim-tree'.setup()
		lua require('gitsigns').setup({ current_line_blame = true })
		lua require('rose-pine').setup({ variant = 'main' })
		colorscheme rose-pine

		lua require('tmux').setup()

		lua require('feline').setup()
		lua require('feline').winbar.setup()

		au VimEnter * NvimTreeToggle

		" nvim-tree
		nnoremap <leader>e :NvimTreeToggle<CR>
		nnoremap <C-f> :NvimTreeFindFile<CR>
		nnoremap <C-n> :NvimTreeRefresh<CR>

		" python
		let g:python3_host_prog = '$ZDOTDIR/py3nvim/bin/python'
	else
		" Nerdtree
		nnoremap <leader>n :NERDTreeFocus<CR>
		nnoremap <C-n> :NERDTree<CR>
		nnoremap <C-t> :NERDTreeToggle<CR>
		nnoremap <C-f> :NERDTreeFind<CR>

		let g:NERDTreeShowHidden=1
		let g:NERDTreeShowLineNumbers=1
		au VimEnter * NERDTree

		let g:airline_theme='angr'
		let g:airline_powerline_fonts = 1

	endif
	
	" open files window
	nnoremap <silent> <leader>f :Files<CR>
	" open Git files window
	nnoremap <silent> <leader>g :GFiles<CR>
	" show buffers
	nnoremap <silent> <leader>b :Buffers<CR>

endif

" clear highlighting on escape in normal mode
" mapping to the escape key
nnoremap <silent><esc><esc> :noh<esc>
"nnoremap <esc>^[ <esc>^[

" buffer navigation
nnoremap <silent> <C-h> :bp<CR>
nnoremap <silent> <C-l> :bn<CR>

" supress arrow keys
noremap <Up>    <Nop>
noremap <Down>  <Nop>
noremap <Left>  <Nop>
noremap <Right> <Nop>

inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>

" map <C-s> to save
noremap <C-s> :w<CR>

" require init.lua
if has('nvim')
	luafile $ZDOTDIR/nvim/init.lua
endif
