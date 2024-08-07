vim9script

if has('unix')
    import '../xdg.vim' as xdg
endif

#############################
####    CONFIGURATION    ####
#############################
### NERDTree
g:NERDTreeUseTCD = 1
g:NERDTreeWinSize = 40
g:NERDTreeMinimalUI = 1
g:NERDTreeShowHidden = 1
g:NERDTreeNaturalSort = 1

if has('unix')
    g:NERDTreeBookmarksFile = xdg.vim_state_home .. '/NERDTreeBookmarks'
elseif has('win32')
    g:NERDTreeBookmarksFile = $HOME .. '/vimfiles/NERDTreeBookmarks'
endif

g:NERDTreeBookmarksSort = 2
g:NERDTreeMarkBookmarks = 0
g:NERDTreeAutoDeleteBuffer = 1
g:NERDTreeCaseSensitiveSort = 1
g:NERDTreeDirArrowExpandable = ''
g:NERDTreeDirArrowCollapsible = ''

### NERDTreeGitStatus
g:NERDTreeGitStatusIndicatorMapCustom = {
    'Modified':  '', # hex: 0xF069
    'Staged':    '', # hex: 0xF067
    'Untracked': '', # hex: 0xF128
    'Renamed':   '', # hex: 0xF061
    'Unmerged':  '', # hex: 0xEBAB
    'Deleted':   '󰆴', # hex: 0xF01B4
    'Dirty':     '', # hex: 0xF00D
    'Ignored':   '󰈅', # hex: 0xF0205
    'Clean':     '', # hex: 0xF00C
    'Unknown':   '󰃤', # hex: 0xF00E4
}

#############################
####      FUNCTIONS      ####
#############################
def NERDTreeOpener(vimEnter: bool): void
    if exists(':NERDTree') == 0
        return
    endif

    if vimEnter
        if argc() == 1 && isdirectory(argv()[0]) && !exists('std_in')
            execute 'NERDTree ' .. argv()[0]
            wincmd p
            enew
            execute 'cd ' .. argv()[0]
        elseif argc() > 0 || exists('std_in')
            # Start NERDTree through execute command to avoid errors when vim
            # compiles this function
            execute 'NERDTree'
            wincmd p
        else
            # Start NERDTree through execute command to avoid errors when vim
            # compiles this function
            execute 'NERDTree'
        endif
    else
        if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+'
                && winnr('$') > 1 && winnr() == winnr('h')
            var buf = bufnr()
            execute 'buffer ' .. bufnr('#')
            wincmd w
            execute 'buffer ' .. buf
        endif
    endif
enddef

def NERDTreeCloser(): void
    if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()
        # Workaround of E1312, should be tested maybe 0 isn't secure value.
        timer_start(0, (_) => {
            quit
        })
    endif
enddef

#############################
####      AUTOCMDS       ####
#############################
augroup NERDTree
    autocmd!
    autocmd StdinReadPre * var std_in = 1
    autocmd VimEnter     * NERDTreeOpener(v:true)
    autocmd VimEnter     * NERDTreeSetMaps()
    autocmd BufEnter     * NERDTreeCloser()
    autocmd BufEnter     * NERDTreeOpener(v:false)
augroup END

#############################
####      KEYMAPS        ####
#############################
def NERDTreeSetMaps(): void
    if exists(':NERDTree') == 2
        nmap nt <Cmd>NERDTreeToggle<CR><Cmd>silent NERDTreeMirror<CR>
        nmap nf <Cmd>NERDTreeFocus<CR>
    endif
enddef

