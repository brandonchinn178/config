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
let ag_args = [
    \'--nocolor',
    \'--hidden',
    \'--ignore .git',
    \'--ignore *.parq*',
    \'--ignore *.out',
    \]
function! s:Find(str)
    execute "cexpr system('ag " . join(g:ag_args, ' ') . "-- \"" . a:str . "\"') | copen"
endfunction
nnoremap K :Find \b<C-R><C-W>\b<CR>
command! -nargs=1 Find call s:Find(<f-args>)

" QuickFix
function! IsQuickFixOpen()
    return len(filter(range(1, winnr('$')), 'getwinvar(v:val, "&ft") == "qf"')) == 1
endfunction
nnoremap <expr> <leader>c IsQuickFixOpen() ? ':cclose<cr>' : ':close<cr>'
nnoremap <leader><tab> :cnext<cr>
nnoremap <leader><S-tab> :cprev<cr>

" Syntax highlighting
syntax on

" Mouse
set mouse=a

" Terminal
nnoremap t :term<CR>
au TermOpen * execute 'normal i'

" Buffers
set hidden
nnoremap <tab> :bn<CR>
nnoremap <S-tab> :bp<CR>
"https://stackoverflow.com/a/8585343
nnoremap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" Auto-reload buffer
" https://stackoverflow.com/a/45428958
set autoread
au FocusGained,BufEnter * checktime

" Copying to clipboard
noremap <leader>y "*y

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
let g:ctrlp_user_command = join(['ag %s -l -g ""'] + ag_args, ' ')
let g:ctrlp_use_caching = 0

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
