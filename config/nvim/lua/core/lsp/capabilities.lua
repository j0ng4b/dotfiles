local M = {}

---@return table
function M.make()
    local caps = vim.lsp.protocol.make_client_capabilities()

    local cmp_lsp = require("core.utils").safe_require("cmp_nvim_lsp")
    if cmp_lsp then
        caps = cmp_lsp.default_capabilities(caps)
    end

    -- Prevent dynamic documentColor registration;
    -- color rendering is handled explicitly.
    caps.textDocument.colorProvider = { dynamicRegistration = false }

    caps.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    -- Support to snippets
    caps.textDocument.completion.completionItem.snippetSupport = true

    return caps
end

return M
