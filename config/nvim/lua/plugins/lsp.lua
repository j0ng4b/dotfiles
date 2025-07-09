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
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        map({ 'n' }, 'K', vim.lsp.buf.hover)

        -- Gotos
        map({ 'n' }, 'gD', vim.lsp.buf.declaration)

        map({ 'n' }, 'gd', function()
            require('telescope.builtin').lsp_definitions {
                trim_text = true,
                reuse_win = true,
            }
        end)

        map({ 'n' }, 'gi', function()
            require('telescope.builtin').lsp_implementations {
                trim_text = true,
                reuse_win = true,
            }
        end)

        map({ 'n' }, 'gt', function()
            require('telescope.builtin').lsp_type_definitions {
                trim_text = true,
                reuse_win = true,
            }
        end)

        map({ 'n' }, 'gr', function()
            require('telescope.builtin').lsp_references {
                trim_text = true,
                reuse_win = true,
            }
        end)

        -- Rename
        map({ 'n' }, 'gR', vim.lsp.buf.rename)
        map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)

        -- Signature help
        map({ 'n' }, 'gk', vim.lsp.buf.signature_help)
        map({ 'i' }, '<C-k>', vim.lsp.buf.signature_help)

        map({ 'n' }, 'gf', vim.lsp.buf.code_action)
        map({ 'n', 'i' }, '<F3>', vim.lsp.buf.code_action)


        -- Auto commands
        if client.server_capabilities.documentFormattingProvider then
            map({ 'n' }, 'gF', function()
                vim.lsp.buf.format({ async = true })
            end)
        end

        if client.server_capabilities.documentHighlightProvider then
            auto.cmd(
                'InsertEnter', nil,
                function()
                    local filter = { bufnr = bufnr }
                    if vim.lsp.inlay_hint.is_enabled(filter) then
                        vim.lsp.inlay_hint.enable(false)

                        auto.cmd(
                            'InsertLeave', nil,
                            function()
                                vim.lsp.inlay_hint.enable(true, filter)
                            end,
                            {
                                buffer = bufnr,
                            }
                        )
                    end
                end,
                {
                    buffer = bufnr,
                }
            )

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


    local servers = require('mason-lspconfig').get_installed_servers()
    if not servers or #servers == 0 then
        return
    end

    -- Add additional system installed servers
    servers = vim.list_extend(servers, {
        'qmlls'
    })

    for _, server in ipairs(servers) do
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
        elseif server == 'lua_ls' then
            server_config.settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim', 'love' }
                    },

                    hint = {
                        enable = true,
                        setType = true,
                        arrayIndex = 'Enable',
                    },

                    semantic = {
                        enable = true,
                        keyword = true,
                    },

                    workspace = {
                        useThirdParty = { os.getenv('HOME') .. '.local/share/LuaAddons' },
                        checkThirdParty = 'Apply',
                    },

                    telemetry = {
                        enable = false,
                    },
                }
            }
        elseif server == 'qmlls' then
            server_config.filetypes = { 'qml', 'qmljs' }
            server_config.cmd = { '/usr/lib/qt6/bin/qmlls' }
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

