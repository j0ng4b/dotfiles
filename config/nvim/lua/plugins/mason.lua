local config = function()
    require('mason').setup()

    require('mason-lspconfig').setup({
        automatic_enable = false,
        ensure_installed = {
            'cssls',
            'html',
            'tailwindcss',
            'ts_ls',
            'vue_ls',

            'clangd',
            'jdtls',
            'omnisharp',
            'pyright',
            'gopls',
            'lua_ls'
        },
    })

    require('mason-tool-installer').setup({
        ensure_installed = {
            'prettier',
            'isort',
            'black',
        },
    })
end


return {
    'williamboman/mason.nvim',
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = config,
    priority = 100,
}

