local config = function()
    local ensure_installed = {
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
    }

    if vim.fn.executable('cc') == 0 or vim.fn.executable('make') == 0 then
        ensure_installed = nil
        vim.notify('Install a C compiler and Make to proper use treesitter!')
    end


    require('nvim-treesitter.configs').setup({
        ensure_installed = ensure_installed,

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
    priority = 100,
}

