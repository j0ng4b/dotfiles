local map = require('utils.map')
local buffer = require('utils.buffer')

--   ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--   ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--   ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

vim.g.mapleader = '\\'

-- Sane mode switcher from insert/visual/select to normal mode
map({ 'i', 'v' }, 'jk', '<Esc>', { desc = 'Sane mode switcher from insert/visual/select to normal mode' })


-- Disable arrow keys
map({ 'i', '' },    '<Up>', '<Nop>', { desc = 'Disable up arrow key' })
map({ 'i', '' },  '<Left>', '<Nop>', { desc = 'Disable left arrow key' })
map({ 'i', '' }, '<Right>', '<Nop>', { desc = 'Disable right arrow key' })
map({ 'i', '' },  '<Down>', '<Nop>', { desc = 'Disable down arrow key' })


-- Save
map({ 'i', 'n' },   '<C-s>',    '<Cmd>w<CR>', { desc = 'Save current buffer changes' })
map({ 'i', 'n' }, '<C-S-s>', '<Cmd>wall<CR>', { desc = 'Save all buffers changes' })


-- Quit
map({ 'n' },   '<C-q>',  '<Cmd>qall<CR>', { desc = 'Quit' })
map({ 'n' }, '<C-S-q>', '<Cmd>qall!<CR>', { desc = 'Force quit, changes are lost!' })


-- Buffer
map({ 'n' }, 'bo', '<Cmd>enew<CR>', { desc = 'Open a new buffer' })
map({ 'n' }, 'bd', function()
    buffer.close()
end, { desc = 'Close a buffer without close window' })

map({ 'n' }, 'bn', function()
    buffer.move('bnext')
end, { desc = 'Move to next non-terminal buffer' })

map({ 'n' }, 'bp', function()
    buffer.move('bprevious')
end, { desc = 'Move to previous non-terminal buffer' })


-- Window
map({ 'n' }, 'we', '<Cmd>wincmd =<CR>', { desc = 'Equalize all window high and wide' })

map({ 'n' }, 'ws', '<Cmd>wincmd s<CR>', { desc = 'Split horizontally' })
map({ 'n' }, 'wv', '<Cmd>wincmd v<CR>', { desc = 'Split vertically' })

map({ 'n' }, 'wc', '<Cmd>wincmd c<CR>', { desc = 'Close window' })
map({ 'n' }, 'wo', '<Cmd>wincmd o<CR>', { desc = 'Close others windows' })

map({ 'n' }, 'wh', '<Cmd>wincmd h<CR>', { desc = 'Focus on left window' })
map({ 'n' }, 'wj', '<Cmd>wincmd j<CR>', { desc = 'Focus on bottom window' })
map({ 'n' }, 'wk', '<Cmd>wincmd k<CR>', { desc = 'Focus on top window' })
map({ 'n' }, 'wl', '<Cmd>wincmd l<CR>', { desc = 'Focus on right window' })
map({ 'n' }, 'wp', '<Cmd>wincmd p<CR>', { desc = 'Focus on previous window' })

map({ 'n' }, 'wH', '<Cmd>wincmd H<CR>', { desc = 'Move window to left' })
map({ 'n' }, 'wJ', '<Cmd>wincmd J<CR>', { desc = 'Move window to bottom' })
map({ 'n' }, 'wK', '<Cmd>wincmd K<CR>', { desc = 'Move window to top' })
map({ 'n' }, 'wL', '<Cmd>wincmd L<CR>', { desc = 'Move window to right' })
map({ 'n' }, 'wT', '<Cmd>wincmd T<CR>', { desc = 'Move window to new tab' })


-- Explorer
map({ 'n' }, '<leader>ef', '<Cmd>Neotree source=filesystem<CR>', { desc = 'Open Neotree to show files' })
map({ 'n' }, '<leader>eb', '<Cmd>Neotree source=buffers<CR>', { desc = 'Open Neotree to show buffer' })
map({ 'n' }, '<leader>eg', '<Cmd>Neotree source=git_status<CR>', { desc = 'Open Neotree to show Git changes' })
map({ 'n' }, '<leader>es', '<Cmd>Neotree source=document_symbols<CR>', { desc = 'Open Neotree to show symbols' })

