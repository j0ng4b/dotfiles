local config = function()
    local telescope = require('telescope')

    telescope.setup({
        defaults = {
            scroll_strategy = 'limit',
            layout_strategy = 'flex',

            selection_caret = '▋ ',
            prompt_prefix = '   ',
            multi_icon = '󱇬 ',

            dynamic_preview_title = true,

            layout_config = {
                prompt_position = 'top',

                vertical = {
                    width = 0.75,
                    mirror = true,
                    prompt_position = 'bottom',
                },
            },

            path_display = {
                'smart',
                filename_first = {
                    reverse_directories = true
                },
            },
        },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('cmdline')
end


return {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    config = config,
    dependencies = {
        { 'nvim-lua/plenary.nvim' },
        { 'jonarrien/telescope-cmdline.nvim' },

        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
        },
    },
}

