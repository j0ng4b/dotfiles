local server_configs = {
    omnisharp = function()
        local omnisharp_root = vim.fn.stdpath('data') .. '/mason/packages/omnisharp/omnisharp'
        return {
            cmd = { omnisharp_root }
        }
    end,

    gopls = function()
        return {
            settings = {
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
        }
    end,

    lua_ls = function()
        return {
            settings = {
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
                        useThirdParty = { os.getenv('HOME') .. '/.local/share/LuaAddons' },
                        checkThirdParty = 'Apply',
                    },
                    telemetry = {
                        enable = false,
                    },
                }
            }
        }
    end,

    qmlls = function()
        return {
            filetypes = { 'qml', 'qmljs' },
            cmd = { '/usr/lib/qt6/bin/qmlls' }
        }
    end,
}


local setup_keymaps = function(bufnr, map)
    local opts = { buffer = bufnr }

    -- Hover documentation
    map('n', 'K', vim.lsp.buf.hover, opts)

    -- Navigation (Gotos)
    map('n', 'gD', vim.lsp.buf.declaration, opts)

    map('n', 'gd', function()
        require('telescope.builtin').lsp_definitions {
            trim_text = true,
            reuse_win = true,
        }
    end, opts)

    map('n', 'gi', function()
        require('telescope.builtin').lsp_implementations {
            trim_text = true,
            reuse_win = true,
        }
    end, opts)

    map('n', 'gt', function()
        require('telescope.builtin').lsp_type_definitions {
            trim_text = true,
            reuse_win = true,
        }
    end, opts)

    map('n', 'gr', function()
        require('telescope.builtin').lsp_references {
            trim_text = true,
            reuse_win = true,
        }
    end, opts)

    -- Rename
    map('n', 'gR', vim.lsp.buf.rename, opts)
    map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, opts)

    -- Signature help
    map('n', 'gk', vim.lsp.buf.signature_help, opts)
    map('i', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Code actions
    map('n', 'gf', vim.lsp.buf.code_action, opts)
    map({ 'n', 'i' }, '<F3>', vim.lsp.buf.code_action, opts)
end


local setup_formatting = function(bufnr, map)
    map('n', 'gF', function()
        vim.lsp.buf.format({ async = true })
    end, { buffer = bufnr })
end


local setup_inlay_hints_toggle = function(bufnr)
    local augroup = vim.api.nvim_create_augroup('LspInlayHints_' .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd('InsertEnter', {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
            end
        end,
    })

    vim.api.nvim_create_autocmd('InsertLeave', {
        group = augroup,
        buffer = bufnr,
        callback = function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
    })
end


local setup_document_highlight = function(bufnr)
    local augroup = vim.api.nvim_create_augroup('LspDocumentHighlight_' .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = augroup,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
        group = augroup,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })
end


local get_capabilities = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Enable color provider
    capabilities.textDocument.colorProvider = {
        dynamicRegistration = true,
    }

    -- Enable folding range
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = true,
        lineFoldingOnly = true,
    }

    -- Enable inlay hints
    capabilities.textDocument.inlayHint = {
        dynamicRegistration = true,
    }

    return capabilities
end


local setup_diagnostics = function(icons)
    local signs = {
        Error = icons.diagnostics.error,
        Warn = icons.diagnostics.warn,
        Info = icons.diagnostics.info,
        Hint = icons.diagnostics.hint,
    }

    for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, {
            text = icon,
            texthl = hl,
            numhl = '',
        })
    end

    vim.diagnostic.config({
        virtual_text = {
            prefix = '●',
            source = 'if_many',
        },
        float = {
            source = 'always',
            border = 'rounded',
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })
end


local setup_handlers = function()
    local handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = 'rounded',
        }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = 'rounded',
        }),
    }

    for handler, handler_config in pairs(handlers) do
        vim.lsp.handlers[handler] = handler_config
    end
end


local create_attach = function(map, navic)
    return function(client, bufnr)
        -- Setup navic if available
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end

        -- Enable inlay hints if supported
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            setup_inlay_hints_toggle(bufnr)
        end

        -- Setup keymaps
        setup_keymaps(bufnr, map)

        -- Setup formatting if supported
        if client.server_capabilities.documentFormattingProvider then
            setup_formatting(bufnr, map)
        end

        -- Setup document highlight if supported
        if client.server_capabilities.documentHighlightProvider then
            setup_document_highlight(bufnr)
        end
    end
end


local config = function()
    local map = require('core.utils.map')
    local icons = require('core.utils.icons')
    local navic = require('nvim-navic')

    -- Setup global configurations
    setup_diagnostics(icons)
    setup_handlers()

    -- Create attach function with dependencies
    local attach = create_attach(map, navic)

    -- Get capabilities
    local capabilities = get_capabilities()

    -- Get servers
    local servers = require('mason-lspconfig').get_installed_servers()

    -- Add additional system installed servers
    servers = vim.list_extend(servers or {}, {
        'qmlls'
    })

    if #servers == 0 then
        vim.notify('No LSP servers found', vim.log.levels.WARN)
        return
    end

    -- Configure and enable servers
    for _, server in ipairs(servers) do
        local server_config = {
            capabilities = capabilities,
            on_attach = attach,
        }

        -- Merge server-specific config if exists
        if server_configs[server] then
            server_config = vim.tbl_deep_extend('force', server_config, server_configs[server]())
        end

        vim.lsp.config(server, server_config)
    end

    vim.lsp.enable(servers)
end


return {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'SmiteshP/nvim-navic',
        'williamboman/mason-lspconfig.nvim',
    },
    config = config,
}
