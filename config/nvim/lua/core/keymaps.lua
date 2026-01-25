local map = require('core.utils.map')
local buffer = require('core.utils.buffer')

--   ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--   ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--   ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

-- Sane mode switcher from insert/visual/select to normal mode
map({ 'i', 'v' }, 'jk', '<Esc>', { noremap = true })


---
-- Disable arrow keys
---
map({ 'i', '' },    '<Up>', '<Nop>')
map({ 'i', '' },  '<Left>', '<Nop>')
map({ 'i', '' }, '<Right>', '<Nop>')
map({ 'i', '' },  '<Down>', '<Nop>')


---
-- Save
---
map({ 'i', 'n' },   '<C-s>',    '<Cmd>w<CR>')
map({ 'i', 'n' }, '<C-S-s>', '<Cmd>wall<CR>')


---
-- Quit
---
map({ 'n' },   '<C-q>',  '<Cmd>qall<CR>')
map({ 'n' }, '<C-S-q>', '<Cmd>qall!<CR>')


---
-- Buffer
---
map({ 'n' }, 'bo', '<Cmd>enew<CR>')
map({ 'n' }, 'bd', function()
    buffer.close()
end)

map({ 'n' }, 'bn', function()
    buffer.go('next')
end)

map({ 'n' }, 'bp', function()
    buffer.go('prev')
end)


---
-- Window management
---
map({ 'n' }, 'wo', '<Cmd>wincmd n<CR>') -- new
map({ 'n' }, 'wc', '<Cmd>wincmd c<CR>') -- close

map({ 'n' }, 'we', '<Cmd>wincmd =<CR>') -- equalize windows size
map({ 'n' }, 'ws', '<Cmd>wincmd s<CR>') -- split horizontal
map({ 'n' }, 'wv', '<Cmd>wincmd v<CR>') -- split vertical

map({ 'n' }, '<C-h>', '<Cmd>TmuxNavigateLeft<CR>') -- left
map({ 'n' }, '<C-j>', '<Cmd>TmuxNavigateDown<CR>') -- bottom
map({ 'n' }, '<C-k>', '<Cmd>TmuxNavigateUp<CR>') -- top
map({ 'n' }, '<C-l>', '<Cmd>TmuxNavigateRight<CR>') -- right

---
-- Tab management
---
map({ 'n' }, 'to', '<Cmd>tabnew<CR>') -- new
map({ 'n' }, 'tc', '<Cmd>tabclose<CR>') -- close

map({ 'n' }, 'tn', '<Cmd>tabnext<CR>') -- previous
map({ 'n' }, 'tp', '<Cmd>tabprevious<CR>') -- next


---
-- Move line up or down
---
map({ 'n', 'v' }, '<A-j>', '<Cmd>move .+1<CR>==') -- move down
map({ 'n', 'v' }, '<A-k>', '<Cmd>move .-2<CR>==') -- move up


---
-- Editing
---
map({ 'n' }, '<leader>ld', 'yyp', 'duplicate line down')
map({ 'v' }, '<leader>ld', 'y`>p', 'duplicate selection down')

map({ 'n', 'v' }, '<leader>d', '"_d', 'delete without yank')
map({ 'n' }, '<leader>D', '"_D', 'delete line without yank')

map({ 'x' }, 'p', '"_dP', 'paste without losing register')


---
-- Indentation
---
map({ 'v' }, '<Tab>', '>gv')
map({ 'n' }, '<Tab>', '>>')

map({ 'v' }, '<S-Tab>', '<gv')
map({ 'n' }, '<S-Tab>', '<<')


--   ╦ ╦┬ ┬┬┌─┐┬ ┬   ╦╔═┌─┐┬ ┬
--   ║║║├─┤││  ├─┤───╠╩╗├┤ └┬┘
--   ╚╩╝┴ ┴┴└─┘┴ ┴   ╩ ╩└─┘ ┴

-- Enable which-key
map.use_which_key()


---
-- Quickfix
---
map.group('QuickFix', '<leader>q')
map({ 'n' }, '<leader>qo', '<cmd>copen<cr>', 'open quickfix')
map({ 'n' }, '<leader>qc', '<cmd>cclose<cr>', 'close quickfix')
map({ 'n' }, '<leader>qn', '<cmd>cnext<cr>', 'next quickfix item')
map({ 'n' }, '<leader>qp', '<cmd>cprev<cr>', 'previous quickfix item')


---
-- Diagnostics
---
map.group('󰓙 Diagnostics', '<leader>d')
map({ 'n' }, '<Leader>dv',
    vim.diagnostic.open_float,
    'show diagnostic float window'
)

map({ 'n' }, '<Leader>dp',
    vim.diagnostic.goto_prev,
    'go to previous diagnostic'
)

map({ 'n' }, '<Leader>dn',
    vim.diagnostic.goto_next,
    'go to next diagnostic'
)

map({ 'n' }, '<Leader>dd',
    require('telescope.builtin').diagnostics,
    'show diagnostics list'
)


---
-- Telescope
---
map.group('󰈙 File search', '<leader>f')
map({ 'n' }, '<leader>ff',
    require('telescope.builtin').find_files,
    'find file'
)

map({ 'n' }, '<leader>fg',
    require('telescope.builtin').live_grep,
    'search text in files'
)

map({ 'n' }, '<leader>fb',
    require('telescope.builtin').buffers,
    'find buffer'
)

map({ 'n' }, '<leader>fs',
    require('telescope.builtin').current_buffer_fuzzy_find,
    'search text on current file'
)

map({ 'n' }, '<leader>fo',
    require('telescope.builtin').lsp_document_symbols,
    'search for lsp symbols on current file'
)

map({ 'n' }, '<leader>fu',
    require('telescope').extensions.undo.undo,
    'search for undo history'
)

---
-- Explorer
---
map.group('󰉓 Explorer', '<leader>e')
map({ 'n' }, '<leader>ef', function()
        require('neo-tree.command').execute({
            toggle = true,
            source = 'filesystem'
        })
    end,
    'toggle files explorer'
)

map({ 'n' }, '<leader>eb', function()
        require('neo-tree.command').execute({
            toggle = true,
            source = 'buffers'
        })
    end,
    'toggle buffers explorer'
)

map({ 'n' }, '<leader>eg', function()
        require('neo-tree.command').execute({
            toggle = true,
            source = 'git_status'
        })
    end,
    'toggle git status explorer'
)

map({ 'n' }, '<leader>es', function()
        require('neo-tree.command').execute({
            toggle = true,
            source = 'document_symbols'
        })
    end,
    'lsp document symbols explorer'
)


---
-- CodeCompanion.nvim
---
map.group(' AI', '<Leader>c')
map({ 'n', 'v' }, '<Leader>ca',
    require("codecompanion").actions,
    {
        desc = 'open the actions palette',
        remap = false,
    }
)

map({ 'n', 'v' }, '<Leader>cc',
    require("codecompanion").toggle,
    {
        desc = 'open a chat ',
        remap = false,
    }
)

map({ 'v' }, 'ga',
    require("codecompanion").add,
    {
        desc = 'add selected text to chat',
        remap = false,
    }
)


---
-- Neotest
---
map.group('󰙨 Test', '<Leader>t')
map({ 'n' }, '<Leader>tt', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').run.run()
    end,
    'run nearest test'
)

map({ 'n' }, '<Leader>tT', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').run.run(vim.fn.expand('%'))
    end,
    'run tests on current file'
)

map({ 'n' }, '<Leader>ts', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').run.stop()
    end,
    'stop running test'
)

map({ 'n' }, '<Leader>to', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').output.open({
            short = true,
            quiet = true,
            auto_close = true,
        })
    end,
    'show test output'
)

map({ 'n' }, '<Leader>tv', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').summary.toggle()
    end,
    'toggle test summary window'
)

map({ 'n' }, '<Leader>tw', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').watch.toggle()
    end,
    'watch nearest test'
)

map({ 'n' }, '<Leader>tW', function()
        require('plugins.neotest').setup_adapter(vim.bo.filetype)
        require('neotest').watch.toggle(vim.fn.expand('%'))
    end,
    'watch tests on current file'
)


---
-- DBUI
---
-- map({ 'n' }, '<leader>db',
    -- '<Cmd>DBUIToggle<CR>'
-- )


