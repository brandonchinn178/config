filetype plugin indent on

" Indentation
set expandtab
set softtabstop=4
set shiftwidth=4

" Line numbers
set number
set ruler

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

" Colors
color slate
syntax on

" Mouse
set mouse=a

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

" ctrl+v is configured for Maccy, so we'll need to remap visual-block
nnoremap <C-B> <C-V>

au BufReadCmd *.whl call zip#Browse(expand("<amatch>"))
autocmd BufNewFile,BufRead *.star set syntax=python
