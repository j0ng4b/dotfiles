return {
    'folke/which-key.nvim',
    event = 'VeryLazy',

    opts = {
        preset = 'helix',

        triggers = {
            { '<auto>', mode = 'nixsotc' },
        },

        win = {
            height = { min = 4, max = 10 },

            title = true,
            title_pos = 'center',

            wo = {
                winblend = 60,
            },
        },

        layout = {
            align = 'center',
        },

        icons = {
            group = '',
            rules = false,
        },

        plugins = {
            spelling = {
                suggestions = 10,
            },
        },

        show_keys = false,
        ignore_missing = true,
    },

    keys = {
        {
            '<leader>?',
            function()
                require('which-key').show({ global = false })
            end,
            desc = 'Buffer Local Keymaps (which-key)',
        },
    },
}

