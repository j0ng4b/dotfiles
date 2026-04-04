return {
    "gbprod/nord.nvim",
    name = "nord",
    priority = 100,
    config = function()
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
    end,
}
