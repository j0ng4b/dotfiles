local config = function()
    local treesitter = require('nvim-treesitter.configs')

    treesitter.setup({
        ensure_installed = {
            -- Programming languages
            'c',
            'cpp',
            'go',
            'javascript',
            'lua',
            'python',
            'tsx',
            'typescript',
            'yuck',

            -- Others languages(?)
            'html',
            'css',
            'sql',

            -- Build
            'cmake',
            'make',
            'gomod',

            -- Configuration files
            'dockerfile',
            'hyprlang',

            -- JSON
            'json',
            'json5',
            'jsonc',

            'rasi',
            'yaml',

            -- Vim
            'vim',
            'vimdoc',
        },

        highlight = {
            enable = true,
        },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = 'gnn',
                node_incremental = 'grn',
                scope_incremental = 'grc',
                node_decremental = 'grm',
            },
        },

        indent = {
            enable = true,
        },
    })
end


return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
    config = config,
}

