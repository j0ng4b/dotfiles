vim9script

#############################
####    CONFIGURATION    ####
#############################

g:lightline = {
    colorscheme: g:colors_name,

    separator: { 'left': '', 'right': '' },
    subseparator: { 'left': '', 'right': '' },

    active: {
        left: [[ 'mode' ], [ 'filedata' ]],
        right: [[ 'lineinfo' ], [ 'percent' ], [ 'fileinfo' ]],
    },

    inactive: {
        left: [[ 'filedata' ]],
        right: [[ 'lineinfo' ], [ 'fileinfo' ]],
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
        filedata: 'LightlineFileData',
        fileinfo: 'LightlineFileInfo',
        percent: 'LightlinePercent',
    }
}

def g:LightlineMode(): string
    var fname = expand('%:p')

    if fname =~# 'NERD_tree'
        return 'NERDTree'
    endif

    return lightline#mode()
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

    return printf('%3.0f', percent * 100) .. ' ' .. symbols[symbol]
enddef

def g:LightlineFileInfo(): string
    var fformat = g:WebDevIconsGetFileFormatSymbol()
    var fencode = &fileencoding ==# '' ? &encoding : &fileencoding
    var ftype = g:WebDevIconsGetFileTypeSymbol()

    return $'{fformat} {fencode} {ftype}'
enddef

