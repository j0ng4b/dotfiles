local status, lsp = pcall(require, 'lspconfig')
if not status then
    return
end

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
    })
end

