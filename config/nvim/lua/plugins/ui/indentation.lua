return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("ibl").setup({
            indent = {
                char = "│",
                smart_indent_cap = true,
            },

            scope = {
                char = "▏",
                show_start = true,
                show_end = true,
            },

            exclude = {
                filetypes = {
                    "alpha",
                    "help",
                    "lazy",
                    "mason",
                    "neo-tree",
                    "notify",
                    "qf",
                    "terminal",
                },
            },
        })
    end,
}
