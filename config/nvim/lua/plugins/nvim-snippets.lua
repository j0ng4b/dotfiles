return {
    'garymjr/nvim-snippets',
    dependencies = 'rafamadriz/friendly-snippets',
    config = function()
        require('snippets').setup({
            highlight_preview = true,
            create_cmp_source = true,
            friendly_snippets = true,
        })
    end,
}

