local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status then
    return
end

treesitter.setup({
    ensure_installed = {
        -- Programming languages
        'c',
        'cpp',
        'go',
        'javascript',
        'lua',
        'python',
        'typescript',
        'yuck',

        -- Others languages(?)
        'html',
        'css',

        -- Build
        'cmake',
        'make',
        'gomod',

        -- Configuration files
        'dockerfile',
        'hyprlang',
        'json',
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
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },

    indent = {
        enable = true,
    },
})

