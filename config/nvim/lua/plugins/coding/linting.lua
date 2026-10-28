local JS_LINTERS = { "eslint_d", "oxlint", "eslint" }

-- Ordered candidates per filetype; the first usable one wins.
local CANDIDATES = {
    python = { "ruff", "flake8" },
    javascript = JS_LINTERS,
    javascriptreact = JS_LINTERS,
    typescript = JS_LINTERS,
    typescriptreact = JS_LINTERS,
    vue = JS_LINTERS,
    css = { "stylelint" },
    scss = { "stylelint" },
    htmldjango = { "djlint" },
    jinja = { "djlint" },
}

local ESLINT_CONFIGS = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yaml",
    ".eslintrc.yml",

    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
}

-- Linters absent from this table don't require a project config.
local CONFIGS = {
    eslint_d = ESLINT_CONFIGS,
    eslint = ESLINT_CONFIGS,
    oxlint = {
        ".oxlintrc.json",
        "oxlint.config.ts",
        "oxlint.config.mts",
    },
    stylelint = {
        ".stylelintrc",
        ".stylelintrc.json",
        ".stylelintrc.yaml",
        ".stylelintrc.yml",
        ".stylelintrc.js",
        ".stylelintrc.cjs",
        ".stylelintrc.mjs",
        "stylelint.config.js",
        "stylelint.config.cjs",
        "stylelint.config.mjs",
    },
    djlint = {
        ".djlintrc",
        "pyproject.toml",
    },
}

-- Check if a linter is available.
---@param name string
---@return boolean
local function is_available(name)
    local linter = require("lint").linters[name]
    if not linter then
        return false
    end

    local cmd = linter.cmd
    if type(cmd) == "function" then
        cmd = cmd()
    end

    return vim.fn.executable(cmd or name) == 1
end

-- Validates the presence of required configuration files in parent directories
-- to prevent running linters on unconfigured projects.
---@param bufnr integer
---@param names string[]
---@return boolean
local function has_config(bufnr, names)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        return false
    end
    return vim.fs.root(bufnr, names) ~= nil
end

--- Returns the first linter that is installed AND configured for this buffer.
---@param bufnr integer
---@return string|nil
local function resolve_linter(bufnr)
    for _, name in ipairs(CANDIDATES[vim.bo[bufnr].filetype] or {}) do
        local configs = CONFIGS[name]
        if is_available(name) and (not configs or has_config(bufnr, configs)) then
            return name
        end
    end
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            desc = "Run the first available linter for the current filetype",
            callback = function(args)
                local name = resolve_linter(args.buf)
                if name then
                    vim.api.nvim_buf_call(args.buf, function()
                        lint.try_lint(name)
                    end)
                end
            end,
        })
    end,
}
