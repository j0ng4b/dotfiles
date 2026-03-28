local config = function()
    require('mason').setup()

    require('mason-tool-installer').setup({
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
            'lua_ls',

            'prettier',
            'stylua',
            'isort',
            'black',

            {
                'gopls',
                condition = function()
                    return vim.fn.executable('go') == 1
                end,
            },
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

