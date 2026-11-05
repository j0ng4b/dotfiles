return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",

        "nvim-treesitter/nvim-treesitter",
    },

    config = function()
        require("nvim-treesitter").install({
            "vim",
            "lua",
            "bash",
            "regex",
            "markdown",
            "markdown_inline",
        })

        require("noice").setup({
            lsp = {
                -- override markdown rendering
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },

            presets = {
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            },

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
                        row = math.floor(vim.o.lines / 2),
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
                        row = math.floor(vim.o.lines / 2),
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

                {
                    view = "notify",
                    filter = {
                        event = "msg_showmode",
                    },
                },
            },
        })
    end,
}
