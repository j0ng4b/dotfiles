local function hl_color(name, fallback)
    local hl = vim.api.nvim_get_hl(0, {
        name = name,
        link = false,
    })

    return hl.fg and string.format("#%06x", hl.fg) or fallback
end

return {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local exclude_filetypes = {
            "alpha",
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "notify",
            "qf",
            "terminal",
        }

        require("hlchunk").setup({
            chunk = {
                enable = true,
                straight = false,

                style = function()
                    return {
                        { fg = hl_color("Function", "#f38ba8") },
                        { fg = hl_color("DiagnosticError", "#ff4000") },
                    }
                end,

                chars = {
                    horizontal_line = "─",
                    vertical_line = "│",
                    left_top = "╭",
                    left_bottom = "╰",
                    right_arrow = "─",
                },

                delay = 150,
                duration = 300,
                use_treesitter = true,
                exclude_filetypes = exclude_filetypes,
            },

            indent = {
                enable = true,

                style = function()
                    return {
                        { fg = hl_color("Whitespace", "#3b4261") },
                    }
                end,

                chars = {
                    "│",
                },

                delay = 100,
                use_treesitter = false,
                exclude_filetypes = exclude_filetypes,
            },
        })
    end,
}
