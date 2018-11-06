" Initialize plugins
set runtimepath+=~/.config/nvim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.config/nvim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'maralla/completor.vim'
NeoBundle 'neovimhaskell/haskell-vim'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'vim-airline/vim-airline'
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
function! s:Find(str)
    execute "silent grep! " . a:str . " | copen"
endfunction
nnoremap F :Find "\b<C-R><C-W>\b"<CR>
command! -nargs=1 Find call s:Find(<f-args>)

" Syntax highlighting
syntax on

" Mouse
set mouse=a

" Terminal
nnoremap t :term<CR>
au TermOpen * execute 'normal i'

" Buffers
nnoremap <leader><tab> :bn<CR>
nnoremap <leader><S-tab> :bp<CR>
"https://stackoverflow.com/a/8585343
nnoremap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" Auto-reload buffer
" https://stackoverflow.com/a/45428958
set autoread
au FocusGained,BufEnter * checktime

" Copying to clipboard
noremap <leader>y "*y

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

""" Plugins

" airblade/vim-gitgutter
set signcolumn=yes
let g:gitgutter_terminal_reports_focus = 0
set updatetime=100

" ctrlpvim/ctrlp
let g:ctrlp_match_window = 'order: ttb'
let g:ctrlp_working_path_mode = 'rwa'
let g:ctrlp_open_new_file = 'r'
let g:ctrlp_regexp = 1

" maralla/completor
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" neovimhaskell/haskell-vim
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_quantification = 1
let g:haskell_indent_disable = 1

" plasticboy/vim-markdown
let g:vim_markdown_folding_disabled = 1

" vim-airline/vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
