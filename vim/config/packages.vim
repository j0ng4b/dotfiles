"""
"" Setup plugins
"""

""" LSC
""""
let g:lsc_auto_map = v:true
let g:lsc_auto_completeopt = v:false
let g:lsc_autocomplete_length = 1
let g:lsc_enable_diagnostics = v:false
let g:lsc_server_commands = {
\   'c': {
\       'command': 'clangd --background-index',
\       'suppress_stderr': v:true
\   },
\   'cpp': {
\       'command': 'clangd --background-index',
\       'suppress_stderr': v:true
\   },
\}

"""
"""" Syntastic
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_error_symbol = ''
let g:syntastic_warning_symbol = ''
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_jump = 3
let g:syntastic_auto_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_c_compiler_options = '-std=c99 -Wall -Wextra -Wpedantic'

"""
"""" Gitgutter
let g:gitgutter_sign_priority = 10
let g:gitgutter_sign_allow_clobber = 0
let g:gitgutter_sign_added = '\ '
let g:gitgutter_sign_modified = '\ '
let g:gitgutter_sign_removed = '\ '
let g:gitgutter_sign_removed_first_line = '\ '
let g:gitgutter_sign_removed_above_and_below = '\ '
let g:gitgutter_sign_modified_removed = '\ '
let g:gitgutter_set_sign_backgrounds = 1
let g:gitgutter_preview_win_floating = 1
let g:gitgutter_use_location_list = 1
let g:gitgutter_floating_window_options = {
\   'line': 'cursor+1',
\   'col': 'cursor',
\   'resize': 'FALSE',
\   'moved': 'any'
\}

"""
"""" lexima
let g:lexima_accept_pum_with_enter = 1

"""
"""" NERDCommenter
let NERDCommentWholeLinesInVMode = 1
let NERDSpaceDelims = 1
let NERDTrimTrailingWhitespace = 1
let NERDDefaultNesting = 0

