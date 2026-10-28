return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        local tools = require("plugins.utils.tools")

        -- Formatters are resolved per buffer from tools.json.
        local formatters_by_ft = {}
        for _, ft in ipairs(tools.filetypes("format")) do
            formatters_by_ft[ft] = function(bufnr)
                return tools.resolve("format", bufnr, function(name)
                    return conform.get_formatter_info(name, bufnr).available
                end)
            end
        end

        conform.setup({
            formatters_by_ft = formatters_by_ft,

            -- Triggers formatting automatically after saving, respecting
            -- global/buffer overrides.
            format_after_save = function(bufnr)
                if not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat) then
                    return { lsp_format = "never" }
                end
            end,
        })

        vim.api.nvim_create_user_command("ConformDisable", function(args)
            if args.bang then
                vim.g.disable_autoformat = true
            else
                vim.b.disable_autoformat = true
            end
        end, {
            desc = "Disable autoformat on save (! = global)",
            bang = true,
        })

        vim.api.nvim_create_user_command("ConformEnable", function(args)
            if args.bang then
                vim.g.disable_autoformat = false
            else
                vim.b.disable_autoformat = false
            end
        end, {
            desc = "Re-enable autoformat on save (! = global)",
            bang = true,
        })
    end,
}
