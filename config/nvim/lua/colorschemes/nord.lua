vim.pack.add({
    {
        src = "https://github.com/gbprod/nord.nvim",
        name = "nord",
    },
})

require("nord").setup({
    terminal_colors = true,

    diff = { mode = "fg" },
    errors = { mode = "fg" },

    styles = {
        comments = { italic = true },

        bufferline = {
            current = {},

            modified = {
                bold = true,
                italic = true,
            },
        },
    },
})
