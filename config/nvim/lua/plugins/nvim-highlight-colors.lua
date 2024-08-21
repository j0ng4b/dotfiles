return {
    'brenoprata10/nvim-highlight-colors',
    config = function()
        require('nvim-highlight-colors').setup({
            render = 'virtual',

            virtual_symbol = '',
            virtual_symbol_position = 'inline',
            virtual_symbol_prefix = '',
            virtual_symbol_suffix = ' ',

            enable_rgb = true,
            enable_hex = true,
            enable_hsl = true,

            -- NOTE: If tailwind language server is installed then this
            -- option will not take any effect, LSP has priority.
            enable_tailwind = true,
            enable_var_usage = true,
            enable_short_hex = true,
            enable_named_colors = true,
        })
    end,
}

