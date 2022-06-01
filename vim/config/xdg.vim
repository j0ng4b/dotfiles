""
""" Vim XDG directories compliance
"""
if empty($XDG_CACHE_HOME)
    let g:xdg_vim_cache = $HOME . '/.cache'
else
    let g:xdg_vim_cache = $XDG_CACHE_HOME
endif

if empty($XDG_STATE_HOME)
    let g:xdg_vim_state = $HOME . '/.local/state'
else
    let g:xdg_vim_state = $XDG_STATE_HOME
endif

if empty($XDG_DATA_HOME)
    let g:xdg_vim_data = $HOME . '/.local/share'
else
    let g:xdg_vim_data = $XDG_DATA_HOME
endif

let g:xdg_vim_config .= '/vim'
let g:xdg_vim_cache .= '/vim'
let g:xdg_vim_state .= '/vim'
let g:xdg_vim_data .= '/vim'

if empty($MYVIMRC)
    let $MYVIMRC = g:xdg_vim_config . '/vimrc'
endif

""
"" Update runtime and pack path
""
let &runtimepath    = g:xdg_vim_config . ',' . &runtimepath
let &runtimepath   .= ',' . g:xdg_vim_data
let &runtimepath   .= ',' . g:xdg_vim_config . '/after'

let &packpath       = g:xdg_vim_data . ',' . &packpath
let &packpath      .= ',' . g:xdg_vim_data . '/after'

