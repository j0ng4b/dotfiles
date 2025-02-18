local install_required_treesitters = function()
    local treesitter = require('nvim-treesitter.configs')
    local ensure_installed = treesitter.get_ensure_installed_parsers()

    local treesitter_languages = {
        'markdown',
        'markdown_inline',
        'html',
        -- 'latex',
        'yaml',
    }

    for _, language in ipairs(treesitter_languages) do
        if not vim.tbl_contains(ensure_installed, language) then
            table.insert(ensure_installed, language)
        end
    end

    treesitter.setup { ensure_installed = ensure_installed }
end


local config = function()
    install_required_treesitters()


    local presets = require('markview.presets');
    require('markview').setup({
        markdown = {
            headings = presets.headings.simple,
            horizontal_rules = presets.horizontal_rules.thick,
            tables = presets.tables.rounded,
        }
    })

    require('markview').setup({
        preview = {
            hybrid_modes = { 'n', 'v', 'i', },
            linewise_hybrid_mode = true,

            filetypes = { 'markdown', 'codecompanion' },
            ignore_buftypes = {},

            icon_provider = 'devicons',
        },

        markdown = {
            headings = {
                heading_1 = {
                    hl = 'CursorLineNr',
                    sign_hl = 'CursorLineNr',
                },

                heading_2 = {
                    hl = 'Character',
                    sign_hl = 'Character',
                },

                heading_3 = {
                    hl = 'DiagnosticInfo',
                    sign_hl = 'DiagnosticInfo',
                },

                heading_4 = {
                    hl = 'DiagnosticError',
                    sign_hl = 'DiagnosticError',
                },

                heading_5 = {
                    hl = 'Identifier',
                    sign_hl = 'Identifier',
                },

                heading_6 = {
                    hl = 'Comment',
                    sign_hl = 'Comment',
                },
            },

            tables = {
                col_min_width = 4,
                use_virt_lines = false,
            },
        },
    })
end


return {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = config,
}

