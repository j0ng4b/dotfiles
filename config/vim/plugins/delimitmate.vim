vim9script

#############################
####    CONFIGURATION    ####
#############################
g:delimitMate_expand_cr = 2
g:delimitMate_expand_space = 1
g:delimitMate_jump_expansion = 0
g:delimitMate_balance_matchpairs = 1

# Always set matchpairs to get LSP integration to works
g:delimitMate_matchpairs = &matchpairs

#############################
####      AUTOCMDS       ####
#############################
augroup DelimitMate
    autocmd!
    autocmd FileType vim,html,xml b:delimitMate_matchpairs = "(:),[:],{:},<:>"
augroup END

#############################
####      KEYMAPS        ####
#############################
if empty(maparg('<CR>', 'i'))
    imap <CR> <Plug>delimitMateCR
endif

