local utils = require("core.utils")
local keymaps = require("core.lsp.keymaps")

local M = {}

-- navic supports a single client per buffer. For these filetypes only the
-- highest-priority client that is attached feeds it.
local NAVIC_PRIORITY = {
    vue = {
        "vue_ls",
        "ts_ls",
    },

    ["yaml.docker-compose"] = {
        "docker_compose_language_service",
        "docker_language_server",
        "yamlls",
    },
}

---@param client vim.lsp.Client
---@param bufnr integer
local function navic(client, bufnr)
    local nav = utils.safe_require("nvim-navic")
    if not nav or nav.is_available(bufnr) then
        return
    end

    local priority = NAVIC_PRIORITY[vim.bo[bufnr].filetype]
    if priority then
        if not vim.tbl_contains(priority, client.name) then
            return
        end

        for _, name in ipairs(priority) do
            local top = vim.lsp.get_clients({ bufnr = bufnr, name = name })[1]
            if top then
                if top.id ~= client.id then
                    return
                end

                break
            end
        end
    end

    nav.attach(client, bufnr)
end

---@param bufnr integer
local function document_highlight(_, bufnr)
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
end

-- Hides inlay hints while typing and restores them only if they were on.
---@param bufnr integer
local function inlay_hints(_, bufnr)
    local hint = vim.lsp.inlay_hint
    local group = vim.api.nvim_create_augroup("LspInlayHints_" .. bufnr, { clear = true })

    hint.enable(true, { bufnr = bufnr })

    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        buffer = bufnr,
        callback = function()
            vim.b[bufnr].inlay_hints_were_on = hint.is_enabled({ bufnr = bufnr })
            hint.enable(false, { bufnr = bufnr })
        end,
        desc = "Disable LSP inlay hints while inserting",
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        buffer = bufnr,
        callback = function()
            if vim.b[bufnr].inlay_hints_were_on then
                hint.enable(true, { bufnr = bufnr })
            end
        end,
        desc = "Restore LSP inlay hints after inserting",
    })
end

-- Per-capability features: each runs only for clients that support the method.
local FEATURES = {
    {
        method = "textDocument/documentHighlight",
        setup = document_highlight,
    },

    {
        method = "textDocument/inlayHint",
        setup = inlay_hints,
    },

    {
        method = "textDocument/documentSymbol",
        setup = navic,
    },

    {
        method = "textDocument/codeLens",
        setup = function(_, bufnr)
            vim.lsp.codelens.enable(true, { bufnr = bufnr })
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("LspCodeLens_" .. bufnr, { clear = true }),
                buffer = bufnr,
                callback = function()
                    vim.lsp.codelens.enable(true, { bufnr = bufnr })
                end,
                desc = "Refresh code lens",
            })
        end,
    },
}

function M.setup()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        desc = "Keymaps and per-capability features for LSP buffers",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
                return
            end

            keymaps.setup(args.buf)

            for _, feature in ipairs(FEATURES) do
                if client:supports_method(feature.method, args.buf) then
                    feature.setup(client, args.buf)
                end
            end
        end,
    })
end

return M
