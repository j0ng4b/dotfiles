local status, gitsigns = pcall(require, 'gitsigns')
if not status then
    return
end

gitsigns.setup({
    signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signs_staged = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    signs_staged_enable = false,
    on_attach = function(bufnr)
        local function map(mode, lhs, rhs, opts)
            opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
            vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end

        -- Navigation
        map('n', '<Leader>hn', '<Cmd>Gitsigns next_hunk<CR>')
        map('n', '<Leader>hp', '<Cmd>Gitsigns prev_hunk<CR>')

        -- Actions
        map('n', '<leader>hS', '<Cmd>Gitsigns stage_buffer<CR>')
        map('n', '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>')
        map('v', '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>')

        map('n', '<leader>hR', '<Cmd>Gitsigns reset_buffer<CR>')
        map('n', '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>')
        map('v', '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>')

        map('n', '<leader>hp', '<Cmd>Gitsigns preview_hunk_inline<CR>')
        map('n', '<leader>hb', '<Cmd>Gitsigns blame_line<CR>')
    end,
})

