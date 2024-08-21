local config = function()
    local catppuccin = require('catppuccin')

    catppuccin.setup({
        default_integration = false,
        term_colors = true,

        integrations = {
            cmp = true,
            neotree = true,
            gitsigns = true,
            treesitter = true,
            semantic_tokens = true,
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { 'italic' },
                    hints = { 'italic' },
                    warnings = { 'italic' },
                    information = { 'italic' },
                    ok = { 'italic' },
                },
                underlines = {
                    errors = { 'undercurl' },
                    hints = { 'undercurl' },
                    warnings = { 'undercurl' },
                    information = { 'undercurl' },
                    ok = { 'undercurl' },
                },
                inlay_hints = {
                    background = true,
                },
            }
        },

        dim_inactive = {
            enabled = true,
            shade = 'dark',
            percentage = 0.35,
        },
    })
end


return {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = config,
}

