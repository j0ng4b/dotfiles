return {
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = 'ibl',
    config = function()
        require('ibl').setup({
            indent = {
                smart_indent_cap = true,
            },
        })
    end,
}

