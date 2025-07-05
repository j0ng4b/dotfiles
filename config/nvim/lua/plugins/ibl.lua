return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
        require('ibl').setup({
            indent = {
                smart_indent_cap = true,
            },
        })
    end,
}

