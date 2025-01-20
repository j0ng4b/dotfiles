local map = require('core.utils.map')
local buffer = require('core.utils.buffer')

--   ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--   ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--   ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

-- Sane mode switcher from insert/visual/select to normal mode
map({ 'i', 'v' }, 'jk', '<Esc>', { noremap = true })


-- Disable arrow keys
map({ 'i', '' },    '<Up>', '<Nop>')
map({ 'i', '' },  '<Left>', '<Nop>')
map({ 'i', '' }, '<Right>', '<Nop>')
map({ 'i', '' },  '<Down>', '<Nop>')


-- Save
map({ 'i', 'n' },   '<C-s>',    '<Cmd>w<CR>')
map({ 'i', 'n' }, '<C-S-s>', '<Cmd>wall<CR>')


-- Quit
map({ 'n' },   '<C-q>',  '<Cmd>qall<CR>')
map({ 'n' }, '<C-S-q>', '<Cmd>qall!<CR>')


-- Buffer
map({ 'n' }, 'bo', '<Cmd>enew<CR>')
map({ 'n' }, 'bd', function()
    buffer.close()
end)

map({ 'n' }, 'bn', function()
    buffer.move('bnext')
end)

map({ 'n' }, 'bp', function()
    buffer.move('bprevious')
end)


-- Window management
map({ 'n' }, 'wo', '<Cmd>wincmd =<CR>') -- new
map({ 'n' }, 'wc', '<Cmd>wincmd c<CR>') -- close

map({ 'n' }, 'ws', '<Cmd>wincmd s<CR>') -- split horizontal
map({ 'n' }, 'wv', '<Cmd>wincmd v<CR>') -- split vertical

map({ 'n' }, 'wh', '<Cmd>wincmd h<CR>') -- right
map({ 'n' }, 'wj', '<Cmd>wincmd j<CR>') -- bottom
map({ 'n' }, 'wk', '<Cmd>wincmd k<CR>') -- top
map({ 'n' }, 'wl', '<Cmd>wincmd l<CR>') -- left


-- Tab management
map({ 'n' }, 'to', '<Cmd>tabnew<CR>') -- new
map({ 'n' }, 'tc', '<Cmd>tabclose<CR>') -- close

map({ 'n' }, 'tn', '<Cmd>tabnext<CR>') -- previous
map({ 'n' }, 'tp', '<Cmd>tabprevious<CR>') -- next



-- Telescope
map({ 'n' }, '<leader>ff', require('telescope.builtin').find_files)
map({ 'n' }, '<leader>fg', require('telescope.builtin').live_grep)
map({ 'n' }, '<leader>fb', require('telescope.builtin').buffers)
map({ 'n' }, '<leader>fs', require('telescope.builtin').current_buffer_fuzzy_find)
map({ 'n' }, '<leader>fo', require('telescope.builtin').lsp_document_symbols)
map({ 'n' }, '<leader>fi', require('telescope.builtin').lsp_incoming_calls)

-- Explorer
map({ 'n' }, '<leader>ef', '<Cmd>Neotree source=filesystem toggle<CR>')
map({ 'n' }, '<leader>eb', '<Cmd>Neotree source=buffers toggle<CR>')
map({ 'n' }, '<leader>eg', '<Cmd>Neotree source=git_status toggle<CR>')
map({ 'n' }, '<leader>es', '<Cmd>Neotree source=document_symbols toggle<CR>')
map({ 'n' }, '<leader>ec', '<Cmd>Neotree close<CR>')


-- DBUI
map({ 'n' }, '<leader>db', '<Cmd>DBUIToggle<CR>')

