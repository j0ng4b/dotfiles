local install_required_treesitters = function()
    local treesitter = require('nvim-treesitter.configs')
    local ensure_installed = treesitter.get_ensure_installed_parsers()

    local noice_treesitter_languages = {
        'vim',
        'lua',
        'bash',
        'regex',
        'markdown',
        'markdown_inline',
    }

    for _, language in ipairs(noice_treesitter_languages) do
        if not vim.tbl_contains(ensure_installed, language) then
            table.insert(ensure_installed, language)
        end
    end

    treesitter.setup { ensure_installed = ensure_installed }
end

local config = function()
    install_required_treesitters()

    require('noice').setup({
        cmdline = {
            enable = true,
            view = 'cmdline_popup',
            format = {
                cmdline = {
                    pattern = '^:',
                    icon = '',
                    lang = 'vim',
                },

                search_down = {
                    kind = 'search',
                    pattern = '^/',
                    icon = '󰱽',
                    lang = 'regex',
                },

                search_up = {
                    kind = 'search',
                    pattern = '^%?',
                    icon = '󰱽',
                    lang = 'regex',
                },

                filter = {
                    pattern = '^:%s*!',
                    icon = '󰈲',
                    lang = 'bash',
                },

                lua = {
                    pattern = {
                        '^:%s*lua%s+',
                        '^:%s*lua%s*=%s*',
                        '^:%s*=%s*',
                    },
                    icon = '',
                    lang = 'lua',
                },

                help = {
                    pattern = '^:%s*he?l?p?%s+',
                    icon = '󰋗',
                },

                input = {
                    view = 'cmdline_input',
                    icon = '󰌓 '
                },
            },
        },

        views = {
            cmdline_popup = {
                position = {
                    row = vim.api.nvim_win_get_height(0) / 2 - 5,
                    col = '50%',
                },

                size = {
                    width = 60,
                    height = 'auto',
                },
            },

            popupmenu = {
                relative = 'editor',

                position = {
                    row = vim.api.nvim_win_get_height(0) / 2 - 2,
                    col = '50%',
                },

                size = {
                    width = 60,
                    height = 6,
                },

                border = {
                    style = 'rounded',
                    padding = { 0, 1 },
                },

                win_options = {
                    winhighlight = {
                        Normal = 'Normal',
                        FloatBorder = 'DiagnosticInfo',
                    },
                },
            },
        },
    })
end

return {
    'folke/noice.nvim',
    config = config,
    dependencies = {
        'MunifTanjim/nui.nvim',
        'rcarriga/nvim-notify',
        'nvim-treesitter/nvim-treesitter',
    },
}

