local config = function()
    local lualine = require('lualine')

    local icons = require('core.utils.icons')

    lualine.setup({
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = ''},
            section_separators = { left = '', right = ''},
            always_divide_middle = true,

        },

        sections = {
            lualine_a = {
                'mode',
            },
            lualine_b = {
                'branch',
            },
            lualine_c = {
                {
                    'filetype',
                    separator = '',
                    padding = { left = 1, right = 0 },
                    icon_only = true,
                },
                {
                    'filename',
                    separator = '',
                    padding = 0,
                    symbols = {
                        modified = icons.file.modified,
                        readonly = icons.file.readonly,
                        unnamed = ' [No Name]',
                        newfile = ' [New]',
                    },
                },
                { '%=', separator = '' },
                {
                    'diagnostics',
                    separator = '',
                    sources = { 'nvim_diagnostic', 'nvim_lsp' },
                    sections = { 'error', 'warn', 'info', 'hint' },
                    symbols = icons.diagnostics,
                },
            },

            lualine_x = {
                {
                    'fileformat',
                    separator = '',
                    padding = 1,
                },
                {
                    'encoding',
                    padding = {
                        left = -1,
                        right = 1,
                    },
                },
            },
            lualine_y = {
                'progress',
            },
            lualine_z = {
                'location',
            },
        },

        extensions = { 'lazy', 'neo-tree', 'quickfix', },
    })
end


return {
    'nvim-lualine/lualine.nvim',
    config = config,
    dependencies = 'nvim-tree/nvim-web-devicons',
}

