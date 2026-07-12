local config = function()
    require("nvim-treesitter").install({
        "vim",
        "lua",
        "bash",
        "regex",
        "markdown",
    })

    require("noice").setup({
        cmdline = {
            enable = true,
            view = "cmdline_popup",
            format = {
                cmdline = {
                    pattern = "^:",
                    icon = "",
                    lang = "vim",
                },

                search_down = {
                    kind = "search",
                    pattern = "^/",
                    icon = "󰱽",
                    lang = "regex",
                },

                search_up = {
                    kind = "search",
                    pattern = "^%?",
                    icon = "󰱽",
                    lang = "regex",
                },

                filter = {
                    pattern = "^:%s*!",
                    icon = "󰈲",
                    lang = "bash",
                },

                lua = {
                    pattern = {
                        "^:%s*lua%s+",
                        "^:%s*lua%s*=%s*",
                        "^:%s*=%s*",
                    },
                    icon = "",
                    lang = "lua",
                },

                help = {
                    pattern = "^:%s*he?l?p?%s+",
                    icon = "󰋗",
                },

                input = {
                    view = "cmdline_input",
                    icon = "󰌓 ",
                },
            },
        },

        views = {
            cmdline_popup = {
                position = {
                    row = vim.api.nvim_win_get_height(0) / 2 - 5,
                    col = "50%",
                },

                size = {
                    width = 60,
                    height = "auto",
                },
            },

            popupmenu = {
                relative = "editor",

                position = {
                    row = vim.api.nvim_win_get_height(0) / 2 - 2,
                    col = "50%",
                },

                size = {
                    width = 60,
                    height = 6,
                },

                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },

                win_options = {
                    winhighlight = {
                        Normal = "Normal",
                        FloatBorder = "DiagnosticInfo",
                    },
                },
            },
        },

        routes = {
            -- Re-route long notifications to split
            {
                view = "split",
                filter = {
                    event = "notify",
                    min_height = 10,
                },
            },
        },
    })
end

return {
    "folke/noice.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
    },
    config = config,
}
