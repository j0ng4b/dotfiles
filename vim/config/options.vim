""
"""  Huge list of options
""""

""
"" Indent
""
let &autoindent     = v:true
let &expandtab      = v:true
let &shiftwidth     = 0
let &tabstop        = 4

""
"" Files
""
let &autoread       = v:true
let &confirm        = v:true
let &hidden         = v:true

""
"" TUI
""
let &background     = 'dark'
let &colorcolumn    = '+1'
let &cursorline     = v:true
let &lazyredraw     = v:true
let &termguicolors  = v:true

""
"" Backspace
""
let &backspace      = 'indent,eol,start'

""
"" Line break and wrap
""
let &breakindent    = v:true
let &breakindentopt = 'sbr'
let &linebreak      = v:true
let &showbreak      = '⌊'
let &wrap           = v:true

""
"" Command-line
""
let &cmdheight      = 2
let &cmdwinheight   = 5
let &showcmd        = v:true

""
"" Insert mode completion
""
let &completeopt    = 'menu,menuone,popup,noinsert,noselect'
let &completepopup  = 'height:10,border:on'
let &pumheight      = 10
let &pumwidth       = 20

""
"" Swap file
""
let &directory      = g:xdg_vim_cache . '/swap//'
let &updatecount    = 500
let &updatetime     = 100

call mkdir(&directory[:-3], 'p', 0700)

""
"" Control how things must be showed
""
let &display        = 'lastline,uhex'
let &fillchars      = 'vert:│,eob: '
let &list           = v:true
let &listchars      = 'tab:│ ,lead:·,trail:*'

""
"" Encoding and file format
""
let &encoding       = 'utf-8'
let &fileencodings  = 'ucs-bom,utf-8,latin1'
let &fileformats    = 'unix'

""
"" Window
""
let &helpheight     = 0
let &splitbelow     = v:true
let &splitright     = v:true

""
"" History
""
let &history        = 10000

""
"" Search
""
let &ignorecase     = v:true
let &incsearch      = v:true
let &smartcase      = v:true

""
"" Status line and Tab line
""
let &laststatus     = 2
let &showtabline    = 2
let &statusline     = ''
let &tabline        = ''

""
"" Mouse
""
let &mouse          = 'ar'

""
"" Line numbering
""
let &number         = v:true
let &numberwidth    = 3
let &relativenumber = v:true

""
"" Preview window
""
let &previewheight  = 10
let &previewpopup   = 'height:10,width:60'

""
"" Scroll
""
let &scrolljump     = 5
let &scrolloff      = 1

""
"" Spelling
""
let &spell          = v:true
let &spelllang      = 'en'

call mkdir(g:xdg_vim_data . '/spell', 'p', 0700)

""
"" Undo
""
let &undodir        = g:xdg_vim_state . '/undo//'
let &undofile       = v:true
let &undolevels     = 2000

call mkdir(&undodir[:-3], 'p', 0700)

""
"" Vim info
""
let &viminfo        = "'200,<200,h,s100"
let &viminfofile    = g:xdg_vim_state . '/viminfo'

""
"" Command-line completion
""
let &wildmenu       = v:true
let &wildmode       = 'longest:full'

""
"" Miscellaneous
""
let &shortmess      = 'aoOstTIc'
let &signcolumn     = 'number'
let &textwidth      = 80
let &ttimeoutlen    = 80

