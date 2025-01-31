local config = function()
    local lsp = require('lspconfig')

    local map = require('core.utils.map')
    local auto = require('core.utils.autocmd')
    local icons = require('core.utils.icons')

    local navic = require('nvim-navic')

    local attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end

        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true)
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
        map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)

        -- Signature help
        map({ 'n' }, 'gk', vim.lsp.buf.signature_help)
        map({ 'i' }, '<C-k>', vim.lsp.buf.signature_help)

        -- Diagnostics
        map({ 'n' }, 'gl', vim.diagnostic.open_float)
        map({ 'n' }, '[d', vim.diagnostic.goto_prev)
        map({ 'n' }, ']d', vim.diagnostic.goto_next)

        map({ 'n' }, 'gf', vim.lsp.buf.code_action)
        map({ 'n', 'i' }, '<F3>', vim.lsp.buf.code_action)


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
    end


    -- Add additional capabilities supported by nvim-cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    capabilities.textDocument.colorProvider = {
        dynamicRegistration = true,
    }

    capabilities.textDocument.foldingRange = {
        dynamicRegistration = true,
        lineFoldingOnly = true,
    }

    capabilities.textDocument.inlayHint = {
        dynamicRegistration = true,
    }


    for _, server in ipairs(require('mason-lspconfig').get_installed_servers()) do
        local server_config = {
            capabilities = capabilities,
            on_attach = attach,
        }

        if server == 'omnisharp' then
            local omnisharp_root = vim.fn.stdpath('data') .. '/mason/packages/omnisharp/omnisharp'
            server_config.cmd = { omnisharp_root }
        elseif server == 'gopls' then
            server_config.settings = {
                gopls = {
                    semanticTokens = true,
                    usePlaceholders = true,

                    hints = {
                        constantValues = true,
                        rangeVariableTypes = true,
                        assignVariableTypes = true,
                        compositeLiteralTypes = true,
                        compositeLiteralFields = true,
                    },
                }
            }
        end

        lsp[server].setup(server_config)
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
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
    })
end


return {
    'neovim/nvim-lspconfig',
    config = config,
}

