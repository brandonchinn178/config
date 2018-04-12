" Syntax file for TODO lists.
" Usage: `:set syntax=todo`

if exists("b:current_syntax")
    finish
endif

syn match todoHeader "^## .* ##$"
syn match todoDone "^x.*"
syn match todoBors "^+.*"
syn match todoPR "^\*.*"
syn match todoInProgress "^\~.*"
syn match todoBlocked "^!.*"
syn match todoTodo "^-.*"
syn match todoDetails "^\s\+-.*"

hi todoHeader     ctermfg=Cyan cterm=underline
hi todoDone       ctermfg=Green
hi todoBors       ctermfg=Blue
hi todoPR         ctermfg=Magenta
hi todoInProgress ctermfg=Yellow
hi todoBlocked    ctermfg=Red
hi todoTodo       ctermfg=White
hi todoDetails    ctermfg=DarkGray
