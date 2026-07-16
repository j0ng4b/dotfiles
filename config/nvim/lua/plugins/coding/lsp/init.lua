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

local fzf_aliases = {
    lsp_type_definitions = "lsp_typedefs",
}

local lsp_builtins = {
    lsp_declarations = vim.lsp.buf.declaration,
    lsp_definitions = vim.lsp.buf.definition,
    lsp_implementations = vim.lsp.buf.implementation,
    lsp_type_definitions = vim.lsp.buf.type_definition,
    lsp_references = vim.lsp.buf.references,
}

local picker
local function get_picker()
    if picker then
        return picker
    end

    local ok, mod = pcall(require, "fzf-lua")
    if ok then
        picker = { type = "fzf", mod = mod }
        return picker
    end

    ok, mod = pcall(require, "telescope.builtin")
    if ok then
        picker = { type = "telescope", mod = mod }
        return picker
    end

    picker = { type = "builtin" }
    return picker
end

local function picker_for(method)
    return function()
        local p = get_picker()
        if p.type == "fzf" then
            p.mod[fzf_aliases[method] or method]()
        elseif p.type == "telescope" then
            p.mod[method]({ trim_text = true, reuse_win = true })
        else
            local fn = lsp_builtins[method]
            if fn then
                fn()
            end
        end
    end
end

local function format_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local conform = utils.safe_require("conform")
    if conform then
        conform.format({
            bufnr = bufnr,
            async = true,
            lsp_format = "fallback",
        })

        return
    end

    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/formatting",
    })

    if #clients > 0 then
        vim.lsp.buf.format({
            bufnr = bufnr,
            async = true,
        })

        return
    end

    vim.notify("No formatter available for this buffer", vim.log.levels.WARN)
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
        -- Vue.js setup
        --
        -- See:
        --   https://github.com/vuejs/language-tools/wiki/Neovim
        --   https://github.com/vuejs/language-tools/discussions/5931#discussion-9320143
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

    roslyn = function(_)
        return {
            settings = {
                ["csharp|completion"] = {
                    dotnet_show_completion_items_from_unimported_namespaces = true,
                    dotnet_show_name_completion_suggestions = true,
                },

                ["csharp|inlay_hints"] = {
                    csharp_enable_inlay_hints_for_implicit_object_creation = true,
                    csharp_enable_inlay_hints_for_implicit_variable_types = true,
                    csharp_enable_inlay_hints_for_lambda_parameter_types = true,

                    dotnet_enable_inlay_hints_for_parameters = true,
                    dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                },

                ["csharp|symbol_search"] = {
                    dotnet_search_reference_assemblies = true,
                },
            },
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
    vim.keymap.set("n", "gD", picker_for("lsp_declarations"), opts)
    vim.keymap.set("n", "gd", picker_for("lsp_definitions"), opts)
    vim.keymap.set("n", "gi", picker_for("lsp_implementations"), opts)
    vim.keymap.set("n", "gt", picker_for("lsp_type_definitions"), opts)
    vim.keymap.set("n", "gr", picker_for("lsp_references"), opts)

    -- Format
    vim.keymap.set("n", "gF", function()
        format_buffer(bufnr)
    end, opts)

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

    vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("DiagnosticFloat", {
            clear = true,
        }),
        callback = vim.diagnostic.open_float,
    })
end

local create_attach = function()
    return function(client, bufnr)
        setup_keymaps(bufnr)

        with_cap(client, "textDocument/documentHighlight", function()
            local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. bufnr, { clear = true })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = group,
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
                desc = "Highlight symbol references",
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
                group = group,
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
                desc = "Clear symbol references",
            })
        end)

        with_cap(client, "textDocument/inlayHint", function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            local group = vim.api.nvim_create_augroup("LspInlayHints_" .. bufnr, { clear = true })

            vim.api.nvim_create_autocmd("InsertEnter", {
                group = group,
                buffer = bufnr,
                callback = function()
                    if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                    end
                end,
                desc = "Disable LSP inlay hints while inserting",
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                group = group,
                buffer = bufnr,
                callback = function()
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end,
                desc = "Enable LSP inlay hints after inserting",
            })
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
