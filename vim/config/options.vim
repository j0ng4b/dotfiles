vim9script

import './xdg.vim' as xdg

# Vim Compatibility
if &compatible
    &compatible = v:false
endif
&cpoptions = &cpoptions .. 'EMnW'

# Indentation
&autoindent = v:true
&expandtab = v:true
&shiftround = v:true
&shiftwidth = 0
&softtabstop = -1
&tabstop = 4

# Files and Buffer
&autoread = v:true
&confirm = v:true
&hidden = v:true

# UI and Colors
&background = 'dark'
&colorcolumn = '+1'
&cursorline = v:true
&display = 'truncate'
&termguicolors = v:true

# Behaviour
&backspace = 'indent,eol,start'
&belloff = 'all'
&completeopt = 'menuone,popup,noinsert,noselect'
&encoding = 'utf-8'
&history = 250
&scrolloff = 5
&shortmess = 'astTcC'
&showmode = v:false
&signcolumn = 'number'

# Line break
&breakindent = v:true
&breakindentopt = 'sbr'
&linebreak = v:true
&showbreak = '󱞩'

# Command line
&cmdheight = 2
&cmdwinheight = 5

# Swap file
&directory = xdg.vim_state_home .. '/swap//'
&updatetime = 100
mkdir(&directory[0 : -3], 'p', 0o700)

# Special characters
&fillchars = 'eob: ,vert:┊,lastline:+'
&list = v:true
&listchars = 'eol:󱞣,tab:┊ ,lead:·,leadmultispace:┊   ,trail:*'

# Format
&textwidth = 80

# Window and Preview window
&helpheight = 0
&previewheight = 10
&splitbelow = v:true
&splitright = v:true

# Search
&ignorecase = v:true
&incsearch = v:true
&smartcase = v:true

# Status line and Tab line
&laststatus = 2
&showtabline = 2
&tabpagemax = 25

# Mouse
&mouse = 'ar'
&mousemodel = 'popup' # setup a menu
&ttymouse = 'sgr'

# Line number
&number = v:true
&relativenumber = v:true

# Spell check
&spell = v:true
&spellfile = xdg.vim_data_home .. '/spell/words.utf-8.add'
&spelllang = 'en,pt_br'
&spelloptions = 'camel'
&spellsuggest = 'fast,10'
mkdir(xdg.vim_data_home .. '/spell', 'p', 0o700)

# Timeout
&timeoutlen = 350
&ttimeoutlen = 100

# Undo
&undodir = xdg.vim_state_home .. '/undo//'
&undofile = v:true
&undolevels = 250
&undoreload = 2500
mkdir(&undodir[0 : -3], 'p', 0o700)

# Viminfo
&viminfofile = xdg.vim_state_home .. '/viminfo'

# Wild menu
&wildcharm = 9             # 9 is <Tab>
&wildmenu = v:true
&wildmode = 'longest:full'
&wildoptions = 'pum'

