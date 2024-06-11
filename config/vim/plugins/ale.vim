vim9script

#############################
####    CONFIGURATION    ####
#############################
g:ale_disable_lsp = 1
g:ale_detail_to_floating_preview = 1

g:ale_floating_preview = 1
g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']

g:ale_fix_on_save = 1
g:ale_fixers = {

}

g:ale_echo_msg_error_str = ''
g:ale_echo_msg_info_str = ''
g:ale_echo_msg_warning_str = '󰉀'

g:ale_lint_delay = 2000
g:ale_linters_explicit = 1
g:ale_lint_on_text_changed = 'always'
g:ale_linters = {}
g:ale_linter_aliases = {}

g:ale_sign_error = ''
g:ale_sign_info = ''
g:ale_sign_warning = '󰉀'

g:ale_virtualtext_prefix = '%severity% '
