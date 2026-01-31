local config = function()
    require('mason').setup()

    require('mason-lspconfig').setup({
        automatic_enable = false,
        ensure_installed = {
            'cssls',
            'html',
            'tailwindcss',
            'ts_ls',

            'clangd',
            'jdtls',
            'omnisharp',
            'pyright',
            'gopls',
            'lua_ls'
        },
    })
end


return {
    'williamboman/mason.nvim',
    dependencies = 'williamboman/mason-lspconfig.nvim',
    config = config,
    priority = 100,
}

