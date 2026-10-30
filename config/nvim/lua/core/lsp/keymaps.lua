local utils = require("core.utils")

local M = {}

-- Picker name per location action. Falls back to the builtin vim.lsp.buf
-- function when the picker doesn't offer that action.
local LOCATIONS = {
    declaration = {
        builtin = vim.lsp.buf.declaration,
        fzf = "lsp_declarations",
    },

    definition = {
        builtin = vim.lsp.buf.definition,
        fzf = "lsp_definitions",
        telescope = "lsp_definitions",
    },

    implementation = {
        builtin = vim.lsp.buf.implementation,
        fzf = "lsp_implementations",
        telescope = "lsp_implementations",
    },

    type_definition = {
        builtin = vim.lsp.buf.type_definition,
        fzf = "lsp_typedefs",
        telescope = "lsp_type_definitions",
    },

    references = {
        builtin = vim.lsp.buf.references,
        fzf = "lsp_references",
        telescope = "lsp_references",
    },
}

---@param kind string
local function jump(kind)
    return function()
        local spec = LOCATIONS[kind]

        local fzf = spec.fzf and utils.safe_require("fzf-lua")
        if fzf then
            return fzf[spec.fzf]()
        end

        local telescope = spec.telescope and utils.safe_require("telescope.builtin")
        if telescope then
            return telescope[spec.telescope]({ trim_text = true, reuse_win = true })
        end

        spec.builtin()
    end
end

---@param bufnr integer
function M.setup(bufnr)
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "K", vim.lsp.buf.hover, "show symbol documentation")

    map("n", "gD", jump("declaration"), "go to declaration")
    map("n", "gd", jump("definition"), "go to definition")
    map("n", "gi", jump("implementation"), "go to implementation")
    map("n", "gt", jump("type_definition"), "go to type definition")
    map("n", "gr", jump("references"), "find references")

    map("n", "gF", function()
        local conform = utils.safe_require("conform")
        if conform then
            conform.format({ async = true, lsp_format = "fallback" })
            return
        end

        local clients = vim.lsp.get_clients({
            bufnr = bufnr,
            method = "textDocument/formatting",
        })

        if #clients > 0 then
            vim.lsp.buf.format({ bufnr = bufnr, async = true })
            return
        end
    end, "format current buffer")

    map("n", "gl", vim.lsp.codelens.run, "run code lens")

    map("n", "gR", vim.lsp.buf.rename, "rename symbol")
    map({ "n", "i" }, "<F2>", vim.lsp.buf.rename, "rename symbol")

    map("n", "gk", vim.lsp.buf.signature_help, "show signature help")

    map("n", "ga", vim.lsp.buf.code_action, "show code actions")
    map({ "n", "i" }, "<F3>", vim.lsp.buf.code_action, "show code actions")
end

return M
