local status, lsp = pcall(require, 'lspconfig')
if not status then
    return
end

local map = require('utils.map')
local auto = require('utils.autocmd')
local icons = require('utils.icons')

local navic = require('nvim-navic')


-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.textDocument.colorProvider = {
    dynamicRegistration = true
}

capabilities.textDocument.foldingRange = {
    dynamicRegistration = true,
    lineFoldingOnly = true
}

local servers = {
    'clangd',

    'cssls',
    'html',
    'tsserver',

    -- NOTE: tailwindcss language server only works if a configuration file
    -- exists.
    'tailwindcss',

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

            map({ 'n' }, 'K', vim.lsp.buf.hover)

            -- Gotos
            map({ 'n' }, 'gD', vim.lsp.buf.declaration)
            map({ 'n' }, 'gd', vim.lsp.buf.definition)
            map({ 'n' }, 'gi', vim.lsp.buf.implementation)
            map({ 'n' }, 'gt', vim.lsp.buf.type_definition)
            map({ 'n' }, 'gr', vim.lsp.buf.references)

            -- Rename
            map({ 'n' }, 'gR', vim.lsp.buf.rename)

            -- Signature help
            map({ 'n' }, 'gk', vim.lsp.buf.signature_help)
            map({ 'i' }, '<C-k>', vim.lsp.buf.signature_help)

            -- Diagnostics
            map({ 'n' }, 'gl', vim.diagnostic.open_float)
            map({ 'n' }, '[d', vim.diagnostic.goto_prev)
            map({ 'n' }, ']d', vim.diagnostic.goto_next)


            -- Auto commands
            if client.server_capabilities.documentFormattingProvider then
                map({ 'n' }, 'gf', function()
                    vim.lsp.buf.format({ async = true })
                end)
            end

            if client.server_capabilities.documentHighlightProvider then
                auto.cmd(
                    'CursorHold', nil,
                    vim.lsp.buf.document_highlight,
                    {
                        buffer = bufnr,
                    }
                )

                auto.cmd(
                    'CursorHoldI', nil,
                    vim.lsp.buf.document_highlight,
                    {
                        buffer = bufnr,
                    }
                )

                auto.cmd(
                    'CursorMoved', nil,
                    vim.lsp.buf.clear_references,
                    {
                        buffer = bufnr,
                    }
                )
            end
        end,
    })
end

-- Diagnostics signs
vim.fn.sign_define('DiagnosticSignError', {
    text = icons.diagnostics.error,
    texthl = 'DiagnosticSignError'
})

vim.fn.sign_define('DiagnosticSignWarn', {
    text = icons.diagnostics.warn,
    texthl = 'DiagnosticSignWarn'
})

vim.fn.sign_define('DiagnosticSignInfo', {
    text = icons.diagnostics.info,
    texthl = 'DiagnosticSignInfo'
})

vim.fn.sign_define('DiagnosticSignHint', {
    text = icons.diagnostics.hint,
    texthl = 'DiagnosticSignHint'
})


-- Document hover window with rounded borders
vim.lsp.handlers['textDocument/hover'] = lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

