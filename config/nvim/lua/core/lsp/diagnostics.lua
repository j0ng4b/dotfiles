local icons = require("core.utils.icons")

local M = {}

function M.setup()
    vim.diagnostic.config({
        virtual_text = false,

        float = {
            source = true,
            border = "rounded"
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
        group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
        callback = function()
            vim.diagnostic.open_float({ focus = false })
        end,
        desc = "Show diagnostics under the cursor",
    })
end

return M
