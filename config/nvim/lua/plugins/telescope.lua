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
                if vim.fn.executable 'make' == 1 then
                    return true
                end

                print('To install telescope-fzf-native is need a c compiler and make!')
                return false
            end,
        },
    },
}

