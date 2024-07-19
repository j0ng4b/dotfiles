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

    auto_install = true,

    highlight = {
        enable = true,

        -- See: https://www.reddit.com/r/neovim/comments/1cyta15/neovim_crash_on_editing_html_with_exit_code_139/
        disable = function(lang, buf)
            if lang == 'html' then
                return true
            end

            return false
        end
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

        -- See: https://www.reddit.com/r/neovim/comments/1cyta15/neovim_crash_on_editing_html_with_exit_code_139/
        disable = function(lang, buf)
            if lang == 'html' then
                return true
            end

            return false
        end
    },
})

