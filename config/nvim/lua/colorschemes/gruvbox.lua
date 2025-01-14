return {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = true,
    opts = {
        terminal_colors = true,

        strikethrough = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = true,
            emphasis = true,
            comments = true,
            operators = false,
            folds = true,
        },

        inverse = true,
        invert_signs = true,
        invert_tabline = false,
        invert_selection = false,
        invert_intend_guides = false,

        contrast = 'hard',
        overrides = {
            FoldColumn = { link = 'LineNr' },

            CursorLineFold = { link = 'LineNr' },
            CursorLineNr = { link = 'LineNr' },
            CursorLineSign = { link = 'LineNr' },
        },

        dim_inactive = false,
        transparent_mode = false,
    }
}

