local config = function()
    local conform = require('conform')

    conform.setup({
        formatters_by_ft = {
            html            = { 'prettier' },
            htmldjango      = { 'prettier' },
            jinja           = { 'prettier' },
            css             = { 'prettier' },
            javascript      = { 'prettier' },
            typescript      = { 'prettier' },
            javascriptreact = { 'prettier' },
            typescriptreact = { 'prettier' },
            json            = { 'prettier' },
            yaml            = { 'prettier' },
            markdown        = { 'prettier' },
            python          = { 'isort', 'black' },
        },

        format_after_save = {
            lsp_fallback = true,
        },
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
        conform.format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 500,
        })
    end, { desc = 'Format file or range (in visual mode)' })
end

return {
    'stevearc/conform.nvim',
    config = config,
    event = { 'BufReadPre', 'BufNewFile' },
}
