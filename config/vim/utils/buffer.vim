vim9script

# Buffer utilities functions
export def BufferClose(): void
    var curBuffer = bufnr('%')

    if getbufvar(curBuffer, '&modified')
        echo "Can't close: the buffer was modified!"
        return
    endif

    var windowsWithBuffer = filter(range(1, winnr('$')),
        'winbufnr(v:val) == ' .. curBuffer)
    var curWindow = winnr()

    for window in windowsWithBuffer
        execute ':' .. window .. 'wincmd w'

        var listedBuffers = filter(range(1, bufnr('$')),
            'buflisted(v:val) && v:val != ' .. curBuffer)

        var hiddenBuffers = filter(copy(listedBuffers), 'bufwinnr(v:val) < 0')
        var gotoBuffer = (hiddenBuffers + listedBuffers + [-1])[0]

        if gotoBuffer > 0
            execute 'buffer ' .. gotoBuffer
        else
            enew
        endif
    endfor

    execute 'bdelete ' .. curBuffer
    execute ':' .. curWindow .. 'wincmd w'
enddef

export def BufferMove(cmd: string): void
    if cmd != 'bprevious' || cmd != 'bnext'
        finish
    endif

    execute cmd
    while &buftype == 'terminal'
        execute cmd
    endwhile
enddef

