local config = function()
    require('mason').setup({
        ui = {
            check_outdated_packages_on_open = false,
        },
    })

    require('mason-lspconfig').setup({
        ensure_installed = {
            'cssls',
            'html',
            'tailwindcss',
            'ts_ls',

            'clangd',
            'jdtls',
            'omnisharp',
        },
    })
end


return {
    'williamboman/mason.nvim',
    dependencies = 'williamboman/mason-lspconfig.nvim',
    config = config,
    priority = 100,
}

