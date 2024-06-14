local status, catppuccin = pcall(require, 'catppuccin')
if not status then
    return
end

catppuccin.setup({
    default_integration = false,
    term_colors = true,

    integrations = {
        cmp = true,
        neotree = true,
        gitsigns = true,
        treesitter = true,
        semantic_tokens = true,
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { 'italic' },
                hints = { 'italic' },
                warnings = { 'italic' },
                information = { 'italic' },
                ok = { 'italic' },
            },
            underlines = {
                errors = { 'underline' },
                hints = { 'underline' },
                warnings = { 'underline' },
                information = { 'underline' },
                ok = { 'underline' },
            },
            inlay_hints = {
                background = true,
            },
        }
    },

    dim_inactive = {
        enabled = true,
        shade = 'dark',
        percentage = 0.35,
    },
})

vim.cmd('colorscheme catppuccin')
