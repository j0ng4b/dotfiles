local auto = require("core.utils.autocmd")
local utils = require("core.utils")
local icons = require("core.utils.icons")

--------------------
--- Helpers
--------------------
local get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local cmp = utils.safe_require("cmp_nvim_lsp")
    if cmp then
        capabilities = cmp.default_capabilities(capabilities)
    end

    capabilities.textDocument.colorProvider = { dynamicRegistration = true }
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    return capabilities
end

local function with_cap(client, cap, fn)
    if client.server_capabilities[cap] then
        fn()
    end
end

local telescope
local function get_telescope()
    if telescope == nil then
        local ok, tb = pcall(require, "telescope.builtin")
        telescope = ok and tb or false
    end
    return telescope
end

local function telescope_or(fallback, picker)
    return function()
        local tb = get_telescope()
        if tb then
            tb[picker]({ trim_text = true, reuse_win = true })
        else
            fallback()
        end
    end
end

--------------------
--- Server configs
--------------------
local server_configs = {
    omnisharp = function()
        local omnisharp_root = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/omnisharp"
        return {
            cmd = { omnisharp_root },
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
                },
            },
        }
    end,

    lua_ls = function()
        return {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "love" },
                    },
                    hint = {
                        enable = true,
                        setType = true,
                        arrayIndex = "Disable",
                    },
                    semantic = {
                        enable = true,
                        keyword = true,
                    },
                    workspace = {
                        useThirdParty = { os.getenv("HOME") .. "/.local/share/LuaAddons" },
                        checkThirdParty = "Apply",
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }
    end,

    ts_ls = function()
        local vue_typescript_plugin = vim.fn.expand(
            vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
        )

        return {
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vue_typescript_plugin,
                        languages = { "vue" },
                    },
                },
            },

            filetypes = {
                "javascript",
                "typescript",
                "javascriptreact",
                "typescriptreact",
                "vue",
            },

            settings = {
                typescript = {
                    tsserver = {
                        useSyntaxServer = false,
                    },
                },
            },
        }
    end,
}

--------------------
--- Extensions
--------------------
local extensions = {
    function(client, bufnr)
        with_cap(client, "documentSymbolProvider", function()
            local navic = utils.safe_require("nvim-navic")
            if navic then
                navic.attach(client, bufnr)
            end
        end)
    end,
}

--------------------
--- Setup functions
--------------------
local setup_keymaps = function(bufnr)
    local opts = { buffer = bufnr }

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", telescope_or(vim.lsp.buf.definition, "lsp_definitions"), opts)
    vim.keymap.set("n", "gi", telescope_or(vim.lsp.buf.implementation, "lsp_implementations"), opts)
    vim.keymap.set("n", "gt", telescope_or(vim.lsp.buf.type_definition, "lsp_type_definitions"), opts)
    vim.keymap.set("n", "gr", telescope_or(vim.lsp.buf.references, "lsp_references"), opts)

    -- Rename
    vim.keymap.set("n", "gR", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "i" }, "<F2>", vim.lsp.buf.rename, opts)

    -- Signature help
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)

    -- Code actions
    vim.keymap.set("n", "gf", vim.lsp.buf.code_action, opts)
    vim.keymap.set({ "n", "i" }, "<F3>", vim.lsp.buf.code_action, opts)
end

local setup_diagnostics = function()
    vim.diagnostic.config({
        virtual_text = false,
        float = {
            source = "always",
            border = "rounded",
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
                [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
                [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
                [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
            },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })

    auto.cmd("CursorHold", nil, vim.diagnostic.open_float)
end

local create_attach = function()
    return function(client, bufnr)
        setup_keymaps(bufnr)

        with_cap(client, "documentFormattingProvider", function()
            vim.keymap.set("n", "gF", function()
                vim.lsp.buf.format({ async = true })
            end, { buffer = bufnr })
        end)

        with_cap(client, "documentHighlightProvider", function()
            local group = auto.buf_group("LspDocumentHighlight_", bufnr)

            auto.cmd({ "CursorHold", "CursorHoldI" }, nil, vim.lsp.buf.document_highlight, {
                group = group,
                buffer = bufnr,
            })

            auto.cmd("CursorMoved", nil, vim.lsp.buf.clear_references, {
                group = group,
                buffer = bufnr,
            })
        end)

        with_cap(client, "inlayHintProvider", function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            local group = auto.buf_group("LspInlayHints_", bufnr)

            auto.cmd("InsertEnter", nil, function()
                if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                end
            end, { group = group, buffer = bufnr })

            auto.cmd("InsertLeave", nil, function()
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end, { group = group, buffer = bufnr })
        end)

        for _, ext in ipairs(extensions) do
            ext(client, bufnr)
        end
    end
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        -- Get servers
        local servers = require("mason-lspconfig").get_installed_servers()
        if #servers == 0 then
            vim.notify("No LSP servers found", vim.log.levels.WARN)
            return
        end

        -- Setup global configurations
        setup_diagnostics()

        local attach = create_attach()
        local capabilities = get_capabilities()

        -- Configure and enable servers
        for _, server in ipairs(servers) do
            vim.lsp.config(
                server,
                vim.tbl_deep_extend("force", {
                    capabilities = capabilities,
                    on_attach = attach,
                }, server_configs[server] and server_configs[server]() or {})
            )
        end
        vim.lsp.enable(servers)
    end,
}
