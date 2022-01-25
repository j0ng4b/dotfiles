"""
"" Setup colorschemes
"""

""
""" Disable unpleasant polyglot settings
let g:polyglot_disabled = [ 'autoindent', 'sensible' ]

""
""" Add autoload folder of colorschemes to runtimepath
packadd! dracula
packadd! everforest
packadd! onedark.vim

""
""" Configure colorschemes
let g:dracula_italic = 0
let g:dracula_full_special_attrs_support = 1

let g:everforest_show_eob = 0
let g:everforest_background = 'hard'
let g:everforest_enable_italic = 0
let g:everforest_ui_contrast = 'high'
let g:everforest_spell_foreground = 'colored'
let g:everforest_better_performance = 1
let g:everforest_disable_italic_comment = 1
let g:everforest_sign_column_background = 'none'
let g:everforest_transparent_background = 0
let g:everforest_diagnostic_text_highlight = 1

let g:onedark_hide_endofbuffer = 1
let g:onedark_terminal_italics = 0

""
""" Pick random colorscheme on enter
function! s:SetColorScheme() abort
    let l:colors = [ 'dracula', 'everforest', 'onedark' ]
    let l:color  = l:colors[rand() % len(l:colors)]

    execute "silent! colorscheme " . l:color
endfunction

autocmd VimEnter * call s:SetColorScheme()

