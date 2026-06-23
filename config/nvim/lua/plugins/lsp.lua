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

    -- Prevent dynamic documentColor registration.
    -- Color rendering is handled explicitly in on_attach.
    capabilities.textDocument.colorProvider = { dynamicRegistration = false }

    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    return capabilities
end

local function with_cap(client, method, fn)
    if client:supports_method(method) then
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
    cssls = function(_)
        return {
            settings = {
                css = {
                    validate = true,
                    lint = { unknownAtRules = "ignore" },
                },

                scss = {
                    validate = true,
                    lint = { unknownAtRules = "ignore" },
                },

                less = { validate = true },
            },
        }
    end,

    ts_ls = function(_)
        -- Vue.js setup tutorial:
        -- https://github.com/vuejs/language-tools/discussions/5931#discussion-9320143
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
                "javascriptreact",
                "typescript",
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

    tailwindcss = function(resolved)
        local filetypes = vim.deepcopy(resolved.filetypes or {})
        vim.list_extend(filetypes, { "jinja", "jinja2" })

        return {
            filetypes = filetypes,
            settings = {
                tailwindCSS = {
                    emmetCompletions = true,
                    classFunctions = { "clsx", "cn", "tw\\.[a-z-]+" },
                    includeLanguages = {
                        jinja = "html",
                        jinja2 = "html",
                    },
                },
            },
        }
    end,

    emmet_language_server = function(resolved)
        local filetypes = vim.deepcopy(resolved.filetypes or {})
        vim.list_extend(filetypes, { "jinja", "jinja2" })
        return { filetypes = filetypes }
    end,

    omnisharp = function(_)
        local omnisharp_root = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/OmniSharp"
        return {
            cmd = { omnisharp_root },
        }
    end,

    gopls = function(_)
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

    lua_ls = function(_)
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
}

--------------------
--- Extensions
--------------------
local extensions = {
    function(client, bufnr)
        with_cap(client, "textDocument/documentSymbol", function()
            local navic = utils.safe_require("nvim-navic")
            if navic then
                -- Prevents navic to attach to ts_ls and vue_ls at same time.
                -- Also prefer attach to vue_ls over ts_ls for Vue buffers.
                local ft = vim.bo[bufnr].filetype
                if not (ft == "vue" and client.name == "ts_ls") then
                    navic.attach(client, bufnr)
                end
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

        with_cap(client, "textDocument/formatting", function()
            vim.keymap.set("n", "gF", function()
                vim.lsp.buf.format({ async = true })
            end, { buffer = bufnr })
        end)

        with_cap(client, "textDocument/documentHighlight", function()
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

        with_cap(client, "textDocument/inlayHint", function()
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

        with_cap(client, "textDocument/documentColor", function()
            -- nvim-highlight-colors will handle rendering of colors
            vim.lsp.document_color.enable(false, { bufnr = bufnr })
        end)

        for _, ext in ipairs(extensions) do
            ext(client, bufnr)
        end
    end
end

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "williamboman/mason-lspconfig.nvim",
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
            local resolved = vim.lsp.config[server] or {}
            local srv_config = server_configs[server] and server_configs[server](resolved) or {}

            -- Chain existing on_attach from lspconfig defaults (e.g. ts_ls registers user commands)
            local existing_attach = resolved and resolved.on_attach

            local final_attach = existing_attach
                    and function(client, bufnr)
                        existing_attach(client, bufnr)
                        attach(client, bufnr)
                    end
                or attach

            vim.lsp.config(
                server,
                vim.tbl_deep_extend("force", srv_config, {
                    capabilities = capabilities,
                    on_attach = final_attach,
                })
            )
        end
        vim.lsp.enable(servers)
    end,
}
