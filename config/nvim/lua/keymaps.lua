local map = require('utils.map')
local buffer = require('utils.buffer')

--   ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--   ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--   ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

-- Sane mode switcher from insert/visual/select to normal mode
map.i('jk', '<Esc>')
map.v('jk', '<Esc>')

-- Disable arrow keys
map.i('<Up>', '<Nop>')
map.i('<Left>', '<Nop>')
map.i('<Right>', '<Nop>')
map.i('<Down>', '<Nop>')

map('<Up>', '<Nop>')
map('<Left>', '<Nop>')
map('<Right>', '<Nop>')
map('<Down>', '<Nop>')

-- Save
map.i('<C-s>', '<Cmd>w<CR>')
map.i('<C-S-s>', '<Cmd>wall<CR>')

map('<C-s>', '<Cmd>w<CR>')
map('<C-S-s>', '<Cmd>wall<CR>')

-- Quit
map.i('<C-q>', '<Cmd>qall<CR>')
map.i('<C-S-q>', '<Cmd>qall!<CR>')

map('<C-q>', '<Cmd>qall<CR>')
map('<C-S-q>', '<Cmd>qall!<CR>')

-- Buffer
map.n('bo', '<Cmd>enew<CR>') -- Open a new buffer
map.n('bd', function() buffer.close() end) -- Close a buffer without close window

map.n('bn', function() buffer.move('bnext') end) -- Move to next non-terminal buffer
map.n('bp', function() buffer.move('bprevious') end) -- Move to previous non-terminal buffer

-- Window
map.n('we', '<Cmd>wincmd =<CR>') -- Equalize all window high and wide

map.n('ws', '<Cmd>wincmd s<CR>') -- Split horizontally
map.n('wv', '<Cmd>wincmd v<CR>') -- Split vertically

map.n('wc', '<Cmd>wincmd c<CR>') -- Close window
map.n('wo', '<Cmd>wincmd o<CR>') -- Close others windows

map.n('wh', '<Cmd>wincmd h<CR>') -- Focus on left window
map.n('wj', '<Cmd>wincmd j<CR>') -- Focus on bottom window
map.n('wk', '<Cmd>wincmd k<CR>') -- Focus on top window
map.n('wl', '<Cmd>wincmd l<CR>') -- Focus on right window
map.n('wp', '<Cmd>wincmd p<CR>') -- Focus on previous window

map.n('wmh', '<Cmd>wincmd H<CR>') -- Move window to left
map.n('wmj', '<Cmd>wincmd J<CR>') -- Move window to bottom
map.n('wmk', '<Cmd>wincmd K<CR>') -- Move window to top
map.n('wml', '<Cmd>wincmd L<CR>') -- Move window to right
map.n('wmt', '<Cmd>wincmd T<CR>') -- Move window to new tab

-- Neotree
map.n('nt', '<Cmd>Neotree toggle<CR>')
map.n('nf', '<Cmd>Neotree focus source=last<CR>')

