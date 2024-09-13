local config = function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = {
            'c',
            'cmake',
            'cpp',
            'make',

            'css',
            'html',
            'javascript',
            'tsx',
            'typescript',

            'sql',

            'java',
            'php',
            'python',

            'dockerfile',
            'yaml',

            'yuck',

            'json',
            'json5',
            'jsonc',

            'lua',
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

