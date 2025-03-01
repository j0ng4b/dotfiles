local config = function()
    local nord = require('nord')

    nord.setup({
        terminal_colors = true,

        diff = { mode = 'fg' },
        errors = { mode = 'fg' },

        styles = {
            comments = { italic = true },

            bufferline = {
                current = {},

                modified = {
                    bold = true,
                    italic = true
                },
            },
        },
    })
end


return {
    'gbprod/nord.nvim',
    config = config,
    priority = 1000,
}

