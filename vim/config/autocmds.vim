""
"""  Autocmds
""""

"" Highlight search only when searching
augroup HighlightSearch
  autocmd!
  autocmd CmdLineEnter /,? set hlsearch
  autocmd CmdLineLeave /,? set nohlsearch
augroup END

