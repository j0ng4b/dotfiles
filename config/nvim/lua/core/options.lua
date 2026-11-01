--   ╔═╗┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
--   ║ ║├─┘ │ ││ ││││└─┐
--   ╚═╝┴   ┴ ┴└─┘┘└┘└─┘

local set = vim.opt

-- Vim compatibility
--   E: error on yank/delete of an empty region
--   n: the 'number' column is also used for wrapped text
--   W: don't overwrite a readonly file without `!`
set.cpoptions:append("EnW")


-- Indentation
set.autoindent = true
set.expandtab = true
set.shiftround = true
set.shiftwidth = 0 -- when zero this uses tabstop value
set.softtabstop = -1 -- when negative this use shiftwidth value
set.tabstop = 4


-- Files & Buffer
set.autoread = true
set.confirm = true
set.hidden = true


-- Clipboard
set.clipboard = { "unnamedplus" }


-- UI & Color
set.background = "dark"
set.colorcolumn = "+1"
set.display = "lastline"
set.termguicolors = true
set.synmaxcol = 240 -- stop syntax highlighting past this column (protects against huge lines)
set.guicursor = {
    "n-v-c:block",
    "i-ci-ve:ver25",
    "r-cr:hor20",
    "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250-Cursor",
    "sm:block-blinkwait175-blinkoff150-blinkon175",
}


-- Cursor line
set.cursorline = true
set.cursorlineopt = "both"


-- Scrolling
set.scrolloff = 10
set.sidescrolloff = 15
set.smoothscroll = true -- scroll by screen line instead of buffer line when wrapping


-- Behaviour
set.backspace = { "indent", "eol", "start" }
set.belloff = "all"
set.completeopt = { "menuone", "popup", "noinsert", "noselect" }
set.history = 1000

-- Message suppression:
--   s: no "search hit BOTTOM, continuing at TOP"
--   t: truncate file messages at the start when too long
--   T: truncate other messages in the middle when too long
--   A: no ATTENTION message when a swap file already exists
--   W: no "written" message when saving
--   I: no intro message on startup
--   F: no file info when opening a file
--   c: no ins-completion-menu messages ("match 1 of 2", "Pattern not found")
--   C: no messages while scanning for ins-completion items
set.shortmess = "stTAWIFcC"

set.showmode = false
set.signcolumn = "number"
set.virtualedit = "block" -- let the cursor go past end of line in visual block mode
set.jumpoptions = "view" -- restore scroll position when jumping with <C-o>/<C-i>


-- Line break
set.wrap = true
set.breakindent = true
set.breakindentopt = { "shift:2", "sbr" }
set.linebreak = true
set.showbreak = "󱞪"


-- Command line
set.cmdheight = 0
set.cmdwinheight = 10


-- Swap
set.updatecount = 500
set.updatetime = 500


-- Special characters
set.list = true
set.listchars = {
    tab = "│ ",
    trail = "󱁐",
    nbsp = "␣",
    extends = "›",
    precedes = "‹",
}

set.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldclose = "",
    foldsep = " ",
    diff = "╱",
}


-- Fold
set.foldmethod = "manual"
set.foldcolumn = "1"
set.foldenable = true
set.foldlevel = 99
set.foldlevelstart = 99


-- Format
set.textwidth = 80

-- Automatic formatting flags.
--   t: auto-wrap text using 'textwidth'
--   c: auto-wrap comments using 'textwidth', inserting the comment leader
--   r: insert the comment leader after <CR> in insert mode
--   q: allow formatting comments with `gq`
--   n: recognize numbered lists when formatting
--   l: don't re-wrap lines that were already longer than 'textwidth' when insert started
--   1: don't break a line after a one-letter word
--   j: remove the comment leader when joining lines
--
-- Not included on purpose: "o" (no comment leader on o/O), see autocmds
set.formatoptions = "tcrqnl1j"


-- Window & Preview window
set.helpheight = 0
set.previewheight = 15
set.splitbelow = true
set.splitright = true
set.splitkeep = "screen" -- keep text stable when open, close or resize windows
set.winblend = 20

if vim.fn.has("nvim-0.11") == 1 then
    set.winborder = "rounded"
end


-- Search
set.hlsearch = false
set.ignorecase = true
set.incsearch = true
set.smartcase = true
set.wrapscan = true
set.inccommand = "split"

if vim.fn.executable("rg") == 1 then
    set.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
    set.grepformat = "%f:%l:%c:%m" -- file:line:column:message
end


-- Status line & Tab line
set.laststatus = 3
set.ruler = false
set.showtabline = 0
set.tabpagemax = 10


-- Mouse
set.mouse = "ar"
set.mousemodel = "popup_setpos"
set.mousemoveevent = true


-- Line numbering
set.number = true
set.relativenumber = true


-- Pop-up
set.pumblend = 25
set.pumheight = 30
set.pumwidth = 60


-- Session
set.sessionoptions = {
    "buffers", -- hidden and unloaded buffers
    "curdir", -- current directory
    "tabpages", -- all tab pages
    "winsize", -- window sizes
    "help", -- help windows
    "globals", -- global variables (uppercase start)
    "skiprtp", -- don't save 'runtimepath'
    "folds", -- manual folds
}


-- Spell
set.spell = true
set.spelllang = { "en", "pt_br" }
set.spelloptions = { "camel", "noplainbuffer" }
set.spellsuggest = { "fast", "10" }
set.spellfile = {
    vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
    vim.fn.stdpath("config") .. "/spell/pt.utf-8.add",
}


-- Timeout
set.timeout = true
set.ttimeout = true
set.timeoutlen = 500
set.ttimeoutlen = 100


-- Undo
set.undofile = true
set.undolevels = 1000
set.undoreload = 10000


-- Wild menu
set.wildcharm = 9 -- key code (9 = <Tab>) that triggers completion inside mappings and macros
set.wildmenu = true
set.wildmode = "longest:full,full"
set.wildoptions = "pum"
set.wildignorecase = true
