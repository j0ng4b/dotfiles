vim.pack.add({
    {
        src = "https://github.com/neanias/everforest-nvim",
        name = "everforest",
    },
})

require("everforest").setup({
    background = "hard",

    transparent_background_level = 0,

    italics = true,

    show_eob = false,
    ui_contrast = "high",
    dim_inactive_windows = false,

    diagnostic_virtual_text = "coloured",
    diagnostic_line_highlight = true,

    spell_foreground = true,
    float_style = "dim",
    inlay_hints_background = "none",
})
