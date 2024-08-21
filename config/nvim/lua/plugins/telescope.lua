local config = function()
    local telescope = require('telescope')

    telescope.setup({
        defaults = {
            layout_config = {
                vertical = {
                    width = 0.75
                },
            },
            path_display = {
                filename_first = {
                    reverse_directories = true
                },
            },
        },

        pickers = {
            find_files = {
                theme = 'dropdown',
            }
        },
    })

    telescope.load_extension('fzf')
end


return {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    config = config,
    dependencies = {
        { 'nvim-lua/plenary.nvim' },

        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
    },
}

