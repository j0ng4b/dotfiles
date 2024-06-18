local status, lsp = pcall(require, 'lspconfig')
if not status then
    return
end

local navic = require('nvim-navic')

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
    'clangd',

    'cssls',
    'html',
    'tsserver',

    'pylsp',
    'pyright',

    'jsonls',
}

for _, server in ipairs(servers) do
    lsp[server].setup({
        capabilities = capabilities,

        on_attach = function(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
    })
end

