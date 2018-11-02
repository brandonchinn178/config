" Initialize plugins
set runtimepath+=~/.config/nvim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.config/nvim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'neovimhaskell/haskell-vim'
NeoBundle 'maralla/completor.vim'
NeoBundle 'tpope/vim-fugitive'
call neobundle#end()

filetype plugin indent on

NeoBundleCheck

" Indentation
set expandtab
set softtabstop=4
set shiftwidth=4

" Line numbers
set number

" Searching
set ignorecase
nnoremap <esc> :noh<cr><esc>
nnoremap <esc>^[ <esc>^[

" Syntax highlighting
syntax on

" Mouse
set mouse=a

" Terminal
nnoremap t :term<CR>
au TermOpen * execute 'normal i'

" Buffers
nnoremap <tab> :bn<CR>
nnoremap <S-tab> :bp<CR>

" Auto-reload buffer
" https://stackoverflow.com/a/45428958
set autoread
au FocusGained,BufEnter * checktime

" ctrlp
let g:ctrlp_match_window = 'order: ttb'
let g:ctrlp_working_path_mode = 'rwa'
let g:ctrlp_open_new_file = 'r'

" vim-gitgutter
set signcolumn=yes
let g:gitgutter_terminal_reports_focus = 0
set updatetime=100

" vim-airline
let g:airline#extensions#tabline#enabled = 1

" haskell-vim
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_quantification = 1
let g:haskell_indent_if = 2
let g:haskell_indent_case = 5

" completor
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" The Silver Searcher
if executable('ag')
    " Use ag over grep
    set grepprg=ag\ --vimgrep\ --\ $*

    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g "" --hidden --ignore .git'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
endif

" Highlights
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
