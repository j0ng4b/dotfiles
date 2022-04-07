"""
"" Setup colorschemes
"""

""
""" Disable unpleasant polyglot settings
let g:polyglot_disabled = [ 'autoindent', 'sensible' ]

""
""" Add autoload folder of colorschemes to runtimepath
packadd! everforest

""
""" Configure colorschemes
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

silent! colorscheme everforest

