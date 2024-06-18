local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status then
    return
end

treesitter.setup({
    ensure_installed = {
        'c', 'cpp', 'cmake', 'make',

        'html', 'css', 'javascript',

        'lua',
        'python',
        'typescript',

        'vim', 'vimdoc',

        'yaml',
        'dockerfile',

        -- Others
        'hyprlang',
        'rasi',
        'yuck',
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

