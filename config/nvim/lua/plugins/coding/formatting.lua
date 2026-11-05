local WEB_FTS = {
    "html",
    "css",
    "scss",
    "less",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "json",
    "jsonc",
    "yaml",
    "markdown",
}

--- One formatter per group, in order: the first available of each group runs.
--- (stop_after_first covers the whole list, so two groups need a function.)
---
---@param groups string[][]
local function first_of_each(groups)
    return function(bufnr)
        local conform = require("conform")
        local result = {}

        for _, group in ipairs(groups) do
            for _, name in ipairs(group) do
                if conform.get_formatter_info(name, bufnr).available then
                    result[#result + 1] = name
                    break
                end
            end
        end

        return result
    end
end

---@return table
local function get_formatters_by_ft()
    local by_ft = {
        lua = { "stylua" },
        cs = { "csharpier" },
        go = { "goimports", "gofumpt" },
        htmldjango = { "djlint" },
        jinja = { "djlint" },

        python = first_of_each({
            { "ruff_organize_imports", "isort" },
            { "ruff_format", "black" },
        }),
    }

    for _, ft in ipairs(WEB_FTS) do
        by_ft[ft] = {
            "prettier",
            "oxfmt",
            stop_after_first = true,
        }
    end

    return by_ft
end

return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },

    keys = {
        {
            -- On demand: falls back to the LSP when no project formatter
            -- applies.
            "<leader>cf",
            function()
                require("conform").format({
                    async = true,
                    lsp_format = "fallback",
                })
            end,

            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },

    config = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

        require("conform").setup({
            formatters_by_ft = get_formatters_by_ft(),

            -- Triggers formatting automatically after saving, respecting
            -- global/buffer overrides.
            format_after_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end

                return { lsp_format = "never" }
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
