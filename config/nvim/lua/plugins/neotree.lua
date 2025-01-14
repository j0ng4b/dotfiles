local config = function()
    local neotree = require('neo-tree')

    local map = require('core.utils.map')
    local icons = require('core.utils.icons')

    neotree.setup({
        close_if_last_window = true,

        sources = {
            'filesystem',
            'buffers',
            'git_status',
            'document_symbols',
        },

        window = {
            position = 'left',
            width = 50,
            mappings = {
                ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
                ['b'] = function() vim.api.nvim_exec('Neotree focus buffers left', true) end,
                ['g'] = function() vim.api.nvim_exec('Neotree focus git_status left', true) end,
            },
        },

        filesystem = {
            filtered_items = {
                visible = true,
                hide_gitignored = true,
                use_libuv_file_watcher = true,
            },
        },

        default_component_configs = {
            indent = {
                with_markers = true,
                indent_marker = '│',
                last_indent_marker = '╰',
                indent_size = 2,
            },

            modified = {
                symbol = icons.file.modified,
                highlight = 'NeoTreeModified',
            },

            git_status = {
                symbols = icons.git,
            },

            diagnostics = {
                symbols = icons.diagnostics,
                highlights = {
                    hint = 'DiagnosticSignHint',
                    info = 'DiagnosticSignInfo',
                    warn = 'DiagnosticSignWarn',
                    error = 'DiagnosticSignError',
                },
            },
        },

        source_selector = {
            winbar = true,
            statusline = false,
            content_layout = 'center',
            tabs_layout = 'equal',

            separator = {
                left = '',
                right = '',
            },

            sources = {
                {
                    source = 'filesystem',
                    display_name = '󰉓 Files',
                },
                {
                    source = 'buffers',
                    display_name = '󰈚 Buffer',
                },
                {
                    source = 'git_status',
                    display_name = '󰊢 Git',
                },
                {
                    source = 'document_symbols',
                    display_name = ' Symbols',
                },
            },
        },

        event_handlers = {
            {
                event = 'neo_tree_buffer_enter',
                handler = function()
                    -- Workaround for error when re-enter neotree buffer after a
                    -- pop-up leave
                    map({ 'i' }, '<Left>', '<Nop>')
                    map({ 'i' }, '<Right>', '<Nop>')

                    -- On NeoTree buffers movement with left and right arrows are
                    -- needed to move on pop-up
                    map.del({ 'i' }, '<Left>')
                    map.del({ 'i' }, '<Right>')

                    vim.cmd 'highlight! Cursor blend=100'
                end
            },

            -- Equalize windows sizes when open or close
            {
                event = 'neo_tree_window_after_open',
                handler = function(args)
                    if args.position == 'left' or args.position == 'right' then
                        vim.cmd('wincmd =')
                    end
                end
            },

            {
                event = 'neo_tree_window_after_close',
                handler = function(args)
                    if args.position == 'left' or args.position == 'right' then
                        vim.cmd('wincmd =')
                    end
                end
            },
        },

        nesting_rules = {
            ['package.json'] = {
                pattern = '^package%.json$',
                files = { 'package-lock.json' }
            },

            ['js'] = {
                pattern = '(.+)%.js$',
                files = { '%1.js.map', '%1.min.js', '%1.d.ts' },
            },

            ['docker'] = {
                pattern = '^dockerfile$',
                files = { '.dockerignore', 'docker-compose.*', 'dockerfile*', 'compose.*' },
                ignore_case = true,
            },
        },
    })
end


return {
    'nvim-neo-tree/neo-tree.nvim',
    config = config,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons',
    },
}

