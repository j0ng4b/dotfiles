local map = require('utils.map')
local status, neotree = pcall(require, 'neo-tree')
if not status then
    return
end

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
            symbol = '● ',
            highlight = 'NeoTreeModified',
        },

        git_status = {
            symbols = {
                -- Change type
                added     = '',
                deleted   = '󰆴',
                modified  = '',
                renamed   = '󰁕',

                -- Status type
                untracked = '',
                ignored   = '󰈅',
                unstaged  = '󰄱',
                staged    = '',
                conflict  = '',
            },
        },

        diagnostics = {
            symbols = {
                hint = '󰌵',
                info = '',
                warn = '󰉀',
                error = '',
            },

            highlights = {
                hint = 'DiagnosticSignHint',
                info = 'DiagnosticSignInfo',
                warn = 'DiagnosticSignWarn',
                error = 'DiagnosticSignError',
            },
        },
    },

    source_selector = {
        winbar = false,
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
                vim.cmd 'highlight! Cursor blend=100'
            end
        },

        {
            event = 'neo_tree_buffer_leave',
            handler = function()
                vim.cmd 'highlight! Cursor blend=0'
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

        -- Bufferline integration
        {
            event = 'after_render',
            handler = function(args)
                if args.current_position == 'left' or args.current_position == 'right' then
                    vim.api.nvim_win_call(args.winid, function()
                        local str = require('neo-tree.ui.selector').get()
                        if str then
                            _G.__cached_neo_tree_selector = str
                        end
                    end)
                end
            end,
        },

        -- Re-enable arrow keys on pup-up
        {
            event = 'neo_tree_popup_buffer_enter',
            handler = function(args)
                map.del_i('<Left>')
                map.del_i('<Right>')
            end,
        },

        {
            event = 'neo_tree_popup_buffer_leave',
            handler = function(args)
                map.i('<Left>', '<Nop>')
                map.i('<Right>', '<Nop>')
            end,
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

