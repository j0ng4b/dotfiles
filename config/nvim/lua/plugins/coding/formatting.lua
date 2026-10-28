-- Selects the first available formatter from a prioritized list.
---@param bufnr integer
---@param ... string
---@return string
local function first_formatter(bufnr, ...)
    local conform = require("conform")
    for i = 1, select("#", ...) do
        local formatter = select(i, ...)
        if conform.get_formatter_info(formatter, bufnr).available then
            return formatter
        end
    end
    return select(1, ...)
end

return {
    "stevearc/conform.nvim",
    -- Automatically loads the plugin when opening or creating files.
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        -- Groups formatters by language ecosystem with dynamic fallback
        -- support.
        local formatters = {
            -- Handles web development languages with automated tool priority.
            web = function(bufnr)
                return { first_formatter(bufnr, "prettierd", "prettier", "oxfmt") }
            end,

            -- Formats Lua configuration files for consistent styling.
            lua = function(_)
                return { "stylua" }
            end,

            -- Manages Python formatting and import sorting with fallback to
            -- traditional tools.
            python = function(bufnr)
                return {
                    first_formatter(bufnr, "ruff_organize_imports", "isort"),
                    first_formatter(bufnr, "ruff_format", "black"),
                }
            end,

            -- Applies official formatting rules for C# files.
            cs = function(_)
                return { "csharpier" }
            end,

            -- Handles Go code formatting and import management.
            go = function(_)
                return { "goimports", "gofumpt" }
            end,

            -- Prettier mangles Jinja tags; djlint understands them.
            jinja = function(_)
                return { "djlint" }
            end,
        }

        require("conform").setup({
            formatters_by_ft = {
                html = formatters["web"],
                css = formatters["web"],
                javascript = formatters["web"],
                typescript = formatters["web"],
                javascriptreact = formatters["web"],
                typescriptreact = formatters["web"],
                json = formatters["web"],
                yaml = formatters["web"],
                markdown = formatters["web"],

                htmldjango = formatters["jinja"],
                jinja = formatters["jinja"],

                lua = formatters["lua"],
                python = formatters["python"],

                cs = formatters["cs"],
                go = formatters["go"],
            },

            -- Triggers formatting automatically after saving, respecting
            -- global/buffer overrides.
            format_after_save = function(bufnr)
                if not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat) then
                    return { lsp_format = "fallback" }
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
