return {
    'shellRaining/hlchunk.nvim',
    config = function()
        require('hlchunk').setup({
            chunk = {
                enable = true,
                delay = 100,
                duration = 300,

                style = {
                    { fg = '#806d9c' }, -- normal chunk
                    { fg = '#c21f30' }, -- error chunk
                },

                chars = {
                    horizontal_line = '─',
                    vertical_line = '│',
                    left_top = '╭',
                    left_bottom = '╰',
                    right_arrow = '─',
                },
            },

            indent = {
                enable = true,
                delay = 0,
                use_treesitter = false,

                chars = {
                    '┆',
                },
            },
        })
    end,
}

