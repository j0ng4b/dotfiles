local config = function()
    require("nvim-treesitter").install({
        "markdown",
        "markdown_inline",
        "html",
        "yaml",
    })

    local presets = require("markview.presets")
    require("markview").setup({
        markdown = {
            headings = presets.headings.simple,
            horizontal_rules = presets.horizontal_rules.thick,
            tables = presets.tables.rounded,
        },
    })

    require("markview").setup({
        preview = {
            hybrid_modes = { "n", "v", "i" },
            linewise_hybrid_mode = true,

            filetypes = { "markdown", "codecompanion" },
            ignore_buftypes = {},

            icon_provider = "devicons",
        },

        markdown = {
            headings = {
                heading_1 = {
                    hl = "CursorLineNr",
                    sign_hl = "CursorLineNr",
                },

                heading_2 = {
                    hl = "Character",
                    sign_hl = "Character",
                },

                heading_3 = {
                    hl = "DiagnosticInfo",
                    sign_hl = "DiagnosticInfo",
                },

                heading_4 = {
                    hl = "DiagnosticError",
                    sign_hl = "DiagnosticError",
                },

                heading_5 = {
                    hl = "Identifier",
                    sign_hl = "Identifier",
                },

                heading_6 = {
                    hl = "Comment",
                    sign_hl = "Comment",
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
    "OXY2DEV/markview.nvim",
    config = config,
}
