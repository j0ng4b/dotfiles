vim9script

#############################
####    CONFIGURATION    ####
#############################
const colorscheme: string = get(g:, 'colors_name', '')
g:lightline = {
    colorscheme: colorscheme,

    separator: { 'left': '', 'right': '' },
    subseparator: { 'left': '', 'right': '' },

    active: {
        left: [[ 'mode' ], [ 'branch', 'filedata' ]],
        right: [[ 'lineinfo' ], [ 'fileinfo', 'percent' ]],
    },

    inactive: {
        left: [[ 'filedata' ]],
        right: [[ 'fileinfo' ]],
    },

    mode_map: {
        n: 'Normal',
        i: 'Insert',
        R: 'Replace',
        v: 'Visual',
        V: 'V·Line',
        "\<C-v>": 'V·Block',
        c: 'Command',
        s: 'Select',
        S: 'S·Line',
        "\<C-s>": 'S·Block',
        t: 'Terminal',
    },

    component: {
        lineinfo: '%3l   %2c ',
    },

    component_function: {
        mode: 'LightlineMode',
        branch: 'LightlineBranch',
        filedata: 'LightlineFileData',
        fileinfo: 'LightlineFileInfo',
        percent: 'LightlinePercent',
    },

    component_function_visible_condition: {
        branch: 'g:FugitiveIsGitDir() && expand("%:p") !~# "NERD_tree"'
    },

    tab: {
        active: [ 'filedata' ],
        inactive: [ 'filedata' ],
    },

    tab_component_function: {
        filedata: 'LightlineTabFileData',
    },

}

def g:LightlineMode(): string
    var fname = expand('%:p')

    if fname =~# 'NERD_tree'
        return '󰙅 NERDTree'
    endif

    return lightline#mode()
enddef

def g:LightlineBranch(): string
    var branch: string = ''

    if exists('*g:FugitiveHead') && expand('%:p') !~# 'NERD_tree'
        branch = g:FugitiveHead()
    endif

    return branch .. (branch ==# '' ? '' : ' ')
enddef

def g:LightlineFileData(): string
    var fname = expand('%:t') ==# '' ? '[No Name]' : expand('%:t')
    var ficon = g:WebDevIconsGetFileTypeSymbol()

    var freadonly = &readonly ? '󰌾 ' : ''
    var fmodify = &modified ? ' ' : ''

    if fname =~# 'NERD_tree'
        return ''
    endif

    return $'{freadonly}{fmodify}{fname} {ficon}'
enddef

def g:LightlinePercent(): string
    var symbols = [ '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' ]
    var percent = line('.') * 1.0 / line('$')

    var symbol = float2nr(percent * (len(symbols) - 1))

    return expand('%:p') !~# 'NERD_tree' ?
        printf('%3.0f', percent * 100) .. ' ' .. symbols[symbol] : ''
enddef

def g:LightlineFileInfo(): string
    var fformat = g:WebDevIconsGetFileFormatSymbol()
    var fencode = &fileencoding ==# '' ? &encoding : &fileencoding

    return expand('%:p') !~# 'NERD_tree' ? $'{fformat} {fencode}' : ''
enddef

def g:LightlineTabFileData(n: number): string
    var buflist = tabpagebuflist(n)
    var winnr = tabpagewinnr(n)

    var fname = expand('#' .. buflist[winnr - 1] .. ':t')
    var ficon = g:WebDevIconsGetFileTypeSymbol()

    var freadonly = getbufvar(buflist[winnr - 1], '&readonly') ? '󰌾 ' : ''
    var fmodify = getbufvar(buflist[winnr - 1], '&modified') ? ' ' : ''

    if fname == ''
        fname = '[No Name]'
    elseif fname =~# 'NERD_tree'
        return '󰙅 NERDTree'
    endif

    return $'{freadonly}{fmodify}{fname} {ficon}'
enddef

