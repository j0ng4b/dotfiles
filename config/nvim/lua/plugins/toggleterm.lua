return {
    'akinsho/toggleterm.nvim',

    opts = {
        open_mapping = '<C-\\>',
        autochdir = true,
        direction = 'float',

        highlights = {
            NormalFloat = {
                link = 'Normal'
            },

            FloatBorder = {
                link = 'NormalFloat',
            },
        },

        float_opts = {
            border = 'solid',

            width = function()
                return math.floor(vim.o.columns * 0.7 + 0.5)
            end,

            height = function()
                return math.floor(vim.o.lines * 0.6 + 0.5)
            end,

            title_pos = 'center',
        },
    },

    init = function()
        _G.set_terminal = function()
            local map = require('core.utils.map')

            map({ 't' }, '<Esc>', '<C-\\><C-n>', { buffer = 0 })
            map({ 't' }, 'jk', '<C-\\><C-n>', { buffer = 0 })

            map({ 't' }, '<C-h>', '<Cmd>TmuxNavigateRight<CR>', { buffer = 0 })
            map({ 't' }, '<C-j>', '<Cmd>TmuxNavigateDown<CR>', { buffer = 0 })
            map({ 't' }, '<C-k>', '<Cmd>TmuxNavigateUp<CR>', { buffer = 0 })
            map({ 't' }, '<C-l>', '<Cmd>TmuxNavigateLeft<CR>', { buffer = 0 })

            map({ 't' }, '<C-w>', '<C-\\><C-n><C-w>', { buffer = 0 })

            vim.opt_local.spell = false
        end

        vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal()')
    end,
}

