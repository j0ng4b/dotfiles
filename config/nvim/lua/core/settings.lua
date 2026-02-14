--   ╔═╗┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
--   ║ ║├─┘ │ ││ ││││└─┐
--   ╚═╝┴   ┴ ┴└─┘┘└┘└─┘

local set = vim.opt
local cmd = vim.cmd

-- Vim compatibility
set.cpoptions:append('EnW')

-- Indentation
set.autoindent = true
set.expandtab = true
set.shiftround = true
set.shiftwidth = 0 -- use tabstop value when zero
set.softtabstop = -1 -- user shiftwidth value when negative
set.tabstop = 4

-- Files & Buffer
set.autoread = true
set.confirm = true
set.hidden = true

-- Clipboard
set.clipboard = { 'unnamedplus' }

-- File encoding
set.encoding = 'utf-8'

-- UI & Color
set.background = 'dark'
set.colorcolumn = '+1'
set.cursorline = true
set.display = 'truncate'
set.termguicolors = true

-- Behaviour
set.backspace = 'indent,eol,start'
set.belloff = 'all'
set.completeopt = 'menuone,popup,noinsert,noselect'
set.history = 250
set.shortmess = 'stTASWIFcC'
set.showmode = false
set.signcolumn = 'number'

-- Line break
set.breakindent = true
set.breakindentopt = 'sbr'
set.linebreak = true
set.showbreak = '󱞪'

-- Command line
set.cmdheight = 0
set.cmdwinheight = 5

-- Swap
set.updatecount = 500
set.updatetime = 500

-- Special characters
set.fillchars = 'eob: '
set.list = true
set.listchars = 'tab:▎ ,trail:󰀦'

-- Fold
set.foldcolumn = '1'
set.foldenable = true
set.foldlevel = 99
set.foldlevelstart = 99
set.fillchars:append('fold: ,foldopen:,foldsep: ,foldclose:')

-- Format
set.textwidth = 80

-- Window & Preview window
set.helpheight = 0
set.previewheight = 10
set.splitbelow = true
set.splitright = true
set.winblend = 20

-- Search
set.hlsearch = false
set.ignorecase = true
set.incsearch = true
set.smartcase = true

-- Status line & Tab line
set.laststatus = 3
set.ruler = false
set.showtabline = 2
set.tabpagemax = 10

-- Mouse
set.mouse = 'ar'
set.mousemodel = 'popup_setpos'
set.mousemoveevent = true

-- Line numbering
set.number = true
set.relativenumber = true

-- Pop-up
set.pumblend = 25
set.pumheight = 10
set.pumwidth = 35
cmd.highlight({ 'PmenuSel', 'blend=0' })

-- Spell
set.spell = true
set.spelllang = 'en,pt_br'
set.spelloptions = 'camel'
set.spellsuggest = 'fast,10'

-- Scroll
set.scrolloff = 10

-- Timeout
set.ttimeoutlen = 100

-- Undo
set.undofile = true
set.undolevels = 250
set.undoreload = 2500

-- Wild menu
set.wildcharm = 9 -- Used to enable use of tab in floating window
set.wildmenu = true
set.wildmode = 'longest:full,full'
set.wildoptions = 'pum'


-- Leader key
vim.g.mapleader = ','
vim.g.maplocalleader = ','
