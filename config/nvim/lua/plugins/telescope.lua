local config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
        defaults = {
            scroll_strategy = 'limit',
            layout_strategy = 'flex',

            selection_caret = '▋ ',
            prompt_prefix = '   ',
            multi_icon = '󱇬 ',

            results_title = false,
            prompt_title = false,

            dynamic_preview_title = true,

            layout_config = {
                prompt_position = 'top',

                flex = {
                    flip_columns = 120,
                },

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

            mappings = {
                i = {
                    -- Close telescope on esc
                    ["<Esc>"] = actions.close,

                    -- Clear prompt
                    ["<C-u>"] = false,
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

