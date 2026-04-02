return {
    src = "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("ibl").setup({
            indent = {
                smart_indent_cap = true,
            },

            scope = {
                show_start = true,
                show_end = false,
            },
        })
    end,
}
