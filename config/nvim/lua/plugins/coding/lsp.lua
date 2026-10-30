-- Appended to the server's default filetypes (lists are replaced on merge, not
-- appended, so they can't live in after/lsp/).
local EXTRA_FILETYPES = {
    tailwindcss = { "jinja", "jinja2" },
    emmet_language_server = { "jinja", "jinja2" },
}

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "mason-org/mason-lspconfig.nvim",
    config = function()
        require("core.lsp.diagnostics").setup()
        require("core.lsp.attach").setup()

        vim.lsp.config("*", { capabilities = require("core.lsp.capabilities").make() })

        -- Setup extra filetypes
        for name, extra in pairs(EXTRA_FILETYPES) do
            local defaults = (vim.lsp.config[name] or {}).filetypes or {}
            vim.lsp.config(name, { filetypes = vim.list_extend(vim.deepcopy(defaults), extra) })
        end

        -- Enables every server installed through Mason (automatic_enable).
        require("mason-lspconfig").setup()
    end,
}
