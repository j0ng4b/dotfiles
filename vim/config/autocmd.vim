vim9script

augroup VimHightlightOnSearch
    autocmd!
    autocmd CmdlineEnter /,? set hlsearch
    autocmd CmdlineLeave /,? set nohlsearch
augroup END

augroup VimCursor
    autocmd!
    autocmd VimEnter * silent !echo '\033[1 q'
    autocmd VimLeave * silent !echo '\033[4 q'
augroup END

