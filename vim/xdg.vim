""
""" VIM XDG directories compliance
"""
if empty($MYVIMRC)
	let $MYVIMRC = expand('<sfile>:t')
endif

if empty($XDG_CONFIG_HOME)
	let $XDG_CONFIG_HOME = $HOME . '/.config'
endif

if empty($XDG_STATE_HOME)
	let $XDG_STATE_HOME = $HOME . '/.local/state'
endif

if empty($XDG_CACHE_HOME)
	let $XDG_CACHE_HOME = $HOME . '/.cache'
endif

if empty($XDG_DATA_HOME)
	let $XDG_DATA_HOME = $HOME . '/.local/share'
endif

set runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath+=$XDG_DATA_HOME/vim
set runtimepath+=$XDG_CONFIG_HOME/vim/after

set packpath^=$XDG_DATA_HOME/vim
set packpath+=$XDG_DATA_HOME/vim/after

set viminfofile=$XDG_STATE_HOME/vim/viminfo
set directory=$XDG_CACHE_HOME/vim/swap//
call mkdir(&directory[:-3], 'p', 0700)

set undodir=$XDG_STATE_HOME/vim/undo//
call mkdir(&undodir[:-3], 'p', 0700)

