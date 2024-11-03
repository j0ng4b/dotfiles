local config = function()
    require('mason').setup()

    require('mason-lspconfig').setup({
        ensure_installed = {
            'cssls',
            'html',
            'tailwindcss',
            'ts_ls',

            'clangd',
            'jdtls',
            'omnisharp',
            'pyright',
        },
    })
end


return {
    'williamboman/mason.nvim',
    dependencies = 'williamboman/mason-lspconfig.nvim',
    config = config,
    priority = 100,
}

