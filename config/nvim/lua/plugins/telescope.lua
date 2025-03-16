local config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    vimgrep_arguments = nil
    if vim.fn.executable('rg') == 1 then
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case'
        }
    else
        vimgrep_arguments = {
            'grep',
            '--extended-regexp',
            '--color=never',
            '--with-filename',
            '--line-number',
            '-b',
            '--ignore-case',
            '--recursive',
            '--no-messages',
            '--exclude-dir=*cache*',
            '--exclude-dir=*.git',
            '--exclude=.*',
            '--binary-files=without-match'
        }
    end

    telescope.setup({
        defaults = {
            sorting_strategy = 'ascending',
            scroll_strategy = 'limit',
            layout_strategy = 'flex',

            selection_caret = '▋ ',
            prompt_prefix = '   ',
            multi_icon = '󱇬 ',

            results_title = false,
            prompt_title = false,

            dynamic_preview_title = true,
            vimgrep_arguments = vimgrep_arguments,

            file_ignore_patterns = {
                '.git/', 'node_modules/', '.cache/',
            },

            layout_config = {
                prompt_position = 'top',

                flex = {
                    flip_columns = 120,
                },

                horizontal = {
                    preview_width = 0.55,
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

                n = {
                    -- Close telescope on Control+C
                    ["<C-c>"] = actions.close,
                },
            },
        },

        pickers = {
            diagnostics = {
                layout_strategy = 'vertical',

                layout_config = {
                    prompt_position = 'top',

                    width = 100,
                    height = 0.50,
                    preview_height = 0,
                },
            },
        },

        extensions = {
            ['ui-select'] = {
                layout_strategy = 'vertical',

                layout_config = {
                    prompt_position = 'top',

                    width = 0.3,
                    height = 15,
                    preview_height = 0,
                },
            },
        },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('ui-select')
    telescope.load_extension('notify')
    telescope.load_extension('undo')
end


return {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    config = config,
    dependencies = {
        { 'nvim-lua/plenary.nvim' },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'debugloop/telescope-undo.nvim' },

        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
        },
    },
}

