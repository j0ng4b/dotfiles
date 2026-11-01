return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local icons = require("core.utils.icons")

        require("lualine").setup({
            options = {
                theme = "auto",
                globalstatus = true,
                icons_enabled = true,
                always_divide_middle = true,

                section_separators = { left = "", right = "" },
                component_separators = { left = "", right = "" },
            },

            sections = {
                lualine_a = {
                    "mode",
                },
                lualine_b = {
                    "branch",
                },
                lualine_c = {
                    {
                        "filetype",
                        separator = "",
                        padding = { left = 1, right = 0 },
                        icon_only = true,
                    },
                    {
                        "filename",
                        separator = "",
                        padding = 0,
                        symbols = {
                            modified = icons.file.modified,
                            readonly = icons.file.readonly,
                            unnamed = " [No Name]",
                            newfile = " [New]",
                        },
                    },
                    { "%=", separator = "" },
                    {
                        "diagnostics",
                        separator = "",

                        -- previously: { 'nvim_diagnostic', 'nvim_lsp' }
                        -- but this produces duplicate diagnostics count
                        sources = { "nvim_diagnostic" },

                        sections = { "error", "warn", "info", "hint" },
                        symbols = icons.diagnostics,
                    },
                },

                lualine_x = {
                    {
                        "fileformat",
                        separator = "",
                        padding = 1,
                    },
                    {
                        "encoding",
                        padding = { left = 0, right = 1 },
                    },
                },
                lualine_y = {
                    "progress",
                },
                lualine_z = {
                    "location",
                },
            },

            extensions = {
                "lazy",
                "mason",
                "neo-tree",
                "quickfix",
                "toggleterm",
            },
        })
    end,
}
