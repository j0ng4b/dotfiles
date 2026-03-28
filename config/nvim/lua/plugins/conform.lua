local config = function()
    local conform = require("conform")

    conform.setup({
        formatters_by_ft = {
            html = { "prettier" },
            htmldjango = { "prettier" },
            jinja = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            lua = { "stylua" },
            python = { "isort", "black" },
        },

        format_after_save = {
            lsp_fallback = true,
        },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 500,
        })
    end, { desc = "Format file or range (in visual mode)" })

    vim.api.nvim_create_user_command("ConformDisable", function(args)
        if args.bang then
            vim.b.disable_autoformat = true
        else
            vim.g.disable_autoformat = true
        end
    end, {
        desc = "Disable autoformat-on-save",
        bang = true,
    })

    vim.api.nvim_create_user_command("ConformEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
    end, {
        desc = "Re-enable autoformat-on-save",
    })
end

return {
    "stevearc/conform.nvim",
    config = config,
    event = { "BufReadPre", "BufNewFile" },
}
