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

set bg=dark         " set backgrouond color to dark
color slate         " sets color schema


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

