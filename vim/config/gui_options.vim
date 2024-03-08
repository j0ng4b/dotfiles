vim9script

if has('gui_gtk')
    &guifont = 'IosevkaJ0ng4b Nerd Font Mono 12'

    export def FontSize(dir: number)
        var newsize: number = 12
        if dir != 0
            var cursize: number = str2nr(substitute(&guifont, '.\+ \(\d\+\)$', '\1', ''))
            newsize = cursize + dir
        endif

        &guifont = substitute(&guifont, '\d\+$', newsize, '')
    enddef
elseif has('gui_win32')
    # TODO: set font for windows
endif

# Enable ligatures
&guiligatures = '!"#$%&()*+-.:<=>?@[]^_{}\/|~'

# GUI options (terminal window, autoselect and dark mode)
&guioptions = '!ad'

# Change font size
## Normal, Visual, Select, Operator-pending
map <F12> <Cmd>call <SID>FontSize(+1)<CR>
map <C-F12> <Cmd>call <SID>FontSize(0)<CR>
map <S-F12> <Cmd>call <SID>FontSize(-1)<CR>

## Insert and Command-line
map! <F12> <Cmd>call <SID>FontSize(+1)<CR>
map! <C-F12> <Cmd>call <SID>FontSize(0)<CR>
map! <S-F12> <Cmd>call <SID>FontSize(-1)<CR>

## Terminal
tmap <F12> <Cmd>call <SID>FontSize(+1)<CR>
tmap <C-F12> <Cmd>call <SID>FontSize(0)<CR>
tmap <S-F12> <Cmd>call <SID>FontSize(-1)<CR>

