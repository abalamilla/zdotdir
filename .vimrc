set number          " turn on line numbers
set relativenumber	" line number relative to it's position
set ruler           " turn on ruler
set is              " turn on incremental search
set hls             " turn on highlight search match
set scrolloff=5     " lines to keep on top of the cursor
set incsearch       " incremental search
set ignorecase      " ignore case
set smartcase       " smart case
set wildmenu        " shows menu on tab completition
set showcmd         " show incomplete commands
set lbr             " line wrap
set ai              " copies identation from current line
set si              " smart indent
set shiftwidth=4    " change tab width
set tabstop=4       " tab equal 4 spaces

"set bg=dark         " set backgrouond color to dark
if has('nvim')
	colorscheme slate
else
	color sorbet         " sets color schema
endif

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.vim/plugged')
	Plug 'sheerun/vim-polyglot'
	Plug 'junegunn/fzf'
	Plug 'junegunn/fzf.vim'
	Plug 'prettier/vim-prettier'
	Plug 'ludovicchabant/vim-gutentags'
	Plug 'vim-autoformat/vim-autoformat'
	Plug 'junegunn/vader.vim'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'github/copilot.vim'
	Plug 'tpope/vim-fugitive'
	Plug 'iamcco/markdown-preview.nvim'
	Plug 'sillybun/vim-repl'
	Plug 'preservim/nerdtree'
	Plug 'jparise/vim-graphql'
call plug#end()

" clear highlighting on escape in normal mode
" mapping to the escape key
nnoremap <silent><esc><esc> :noh<esc>
"nnoremap <esc>^[ <esc>^[

" open files window
nnoremap <silent> <leader>f :Files<CR>
" open Git files window
nnoremap <silent> <leader>g :GFiles<CR>
" show buffers
nnoremap <silent> <leader>b :Buffers<CR>

" supress arrow keys
noremap <Up>    <Nop>
noremap <Down>  <Nop>
noremap <Left>  <Nop>
noremap <Right> <Nop>

inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>

" set movement keys for insert mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" set wrap for vimdiff
au VimEnter * if &diff | execute 'windo set wrap' | endif

let g:airline_theme='random'

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

" Nerdtree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
