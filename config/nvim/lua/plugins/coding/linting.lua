-- Selects the first available linter from a prioritized list
-- to ensure active linting regardless of specific tool installations.
---@param ... string
---@return string
local function first_linter(...)
    local lint = require("lint")

    for i = 1, select("#", ...) do
        local linter_name = select(i, ...)

        -- Check if the linter is registered and its binary is available in the path
        if lint.linters[linter_name] and vim.fn.executable(lint.linters[linter_name].cmd or linter_name) == 1 then
            return linter_name
        end
    end
    return select(1, ...)
end

local ESLINT_CONFIGS = {
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yaml",
    ".eslintrc.yml",

    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
}

local STYLELINT_CONFIGS = {
    ".stylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
}

-- Defines linters and configuration rules categorized by language ecosystem.
---@param filetype string
---@return table
local function get_linters(filetype)
    local linters_by_ft = {
        python = {
            names = { first_linter("ruff", "flake8") },
        },

        javascript = {
            names = { first_linter("eslint_d", "oxlint", "eslint") },
            configs = ESLINT_CONFIGS,
        },

        javascriptreact = {
            names = { first_linter("eslint_d", "oxlint", "eslint") },
            configs = ESLINT_CONFIGS,
        },

        typescript = {
            names = { first_linter("eslint_d", "oxlint", "eslint") },
            configs = ESLINT_CONFIGS,
        },

        typescriptreact = {
            names = { first_linter("eslint_d", "oxlint", "eslint") },
            configs = ESLINT_CONFIGS,
        },

        vue = {
            names = { first_linter("eslint_d", "oxlint", "eslint") },
            configs = ESLINT_CONFIGS,
        },

        css = {
            names = { "stylelint" },
            configs = STYLELINT_CONFIGS,
        },
    }

    return linters_by_ft[filetype]
end

-- Validates the presence of required configuration files in parent directories
-- to prevent running linters on unconfigured projects.
---@param bufnr integer
---@param config_names table<string>
---@return boolean
local function has_config(bufnr, config_names)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return false
    end

    return vim.fs.find(config_names, {
        path = vim.fs.dirname(filename),
        upward = true,
        type = "file",
    })[1] ~= nil
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        -- Triggers asynchronous linting checks after saving a buffer.
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            callback = function(args)
                local entry = get_linters(vim.bo[args.buf].filetype)
                if not entry then
                    return
                end

                if entry.configs and not has_config(args.buf, entry.configs) then
                    return
                end

                lint.try_lint(entry.names)
            end,
            desc = "Run configured linters for the current file type",
        })
    end,
}
